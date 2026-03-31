using PuppeteerSharp;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using SchoolManager.Services.Interfaces;
using SkiaSharp;

namespace SchoolManager.Services.Implementations;

/// <summary>
/// Genera el PDF del carnet capturando el HTML de la vista Generate con Chromium headless
/// (PuppeteerSharp). Cada elemento .idcard-face se fotografía a DeviceScaleFactor=3 y se
/// redimensiona a los píxeles exactos de CR80/ISO ID-1 antes de embeberlo en QuestPDF.
/// </summary>
public class StudentIdCardHtmlCaptureService : IStudentIdCardHtmlCaptureService
{
    // CR80 / ISO ID-1 @ 300 DPI
    private const int LandscapeW = 1011;
    private const int LandscapeH = 638;
    private const int PortraitW  = 638;
    private const int PortraitH  = 1011;
    private const float CardMmW  = 85.60f;
    private const float CardMmH  = 53.98f;

    // Rutas de Chromium conocidas en Linux (Render, Docker, etc.)
    private static readonly string[] KnownChromePaths =
    [
        "/usr/bin/google-chrome",
        "/usr/bin/google-chrome-stable",
        "/usr/bin/chromium-browser",
        "/usr/bin/chromium",
        "/usr/local/bin/chromium",
        "/snap/bin/chromium"
    ];

    private static string? _resolvedChromiumPath;
    private static readonly SemaphoreSlim _downloadLock = new(1, 1);

    private readonly ILogger<StudentIdCardHtmlCaptureService> _logger;

    public StudentIdCardHtmlCaptureService(ILogger<StudentIdCardHtmlCaptureService> logger)
    {
        _logger = logger;
    }

    public async Task<byte[]> GeneratePdfFromHtmlAsync(
        Guid studentId, string baseUrl, IRequestCookieCollection cookies)
    {
        _logger.LogInformation(
            "[HtmlCapture] Iniciando captura StudentId={StudentId} BaseUrl={BaseUrl}", studentId, baseUrl);

        var execPath = await ResolveChromiumPathAsync();

        var launchOpts = new LaunchOptions
        {
            Headless = true,
            Args     = new[]
            {
                "--no-sandbox",
                "--disable-setuid-sandbox",
                "--disable-dev-shm-usage",
                "--disable-gpu",
                "--disable-extensions",
                "--hide-scrollbars",
                "--mute-audio"
            }
        };

        if (!string.IsNullOrWhiteSpace(execPath))
            launchOpts.ExecutablePath = execPath;

        await using var browser = await Puppeteer.LaunchAsync(launchOpts);
        await using var page    = await browser.NewPageAsync();

        // Viewport grande + escala 3× para resolución nativa CR80
        await page.SetViewportAsync(new ViewPortOptions
        {
            Width             = 1920,
            Height            = 1080,
            DeviceScaleFactor = 3
        });

        // Propagar cookies de autenticación al browser headless
        var host = new Uri(baseUrl).Host;
        var cookieParams = cookies
            .Select(c => new CookieParam { Name = c.Key, Value = c.Value, Domain = host })
            .ToArray();

        if (cookieParams.Length > 0)
            await page.SetCookieAsync(cookieParams);

        var url = $"{baseUrl}/StudentIdCard/ui/generate/{studentId}";
        _logger.LogInformation("[HtmlCapture] Navegando a {Url}", url);

        await page.GoToAsync(url, new NavigationOptions
        {
            WaitUntil = new[] { WaitUntilNavigation.Networkidle0 },
            Timeout   = 30_000
        });

        // Verificar que la vista tiene carnet activo (no error / redirigido)
        var title = await page.GetTitleAsync();
        _logger.LogInformation("[HtmlCapture] Título de página: {Title}", title);

        var cards = await page.QuerySelectorAllAsync(".idcard-face");
        if (cards.Length == 0)
            throw new InvalidOperationException(
                "No se encontraron elementos .idcard-face. " +
                "Asegúrese de que el carnet esté generado y el pago confirmado.");

        _logger.LogInformation("[HtmlCapture] Encontrados {N} elemento(s) .idcard-face", cards.Length);

        var pngFaces = new List<(byte[] Png, bool IsVertical)>();

        foreach (var card in cards)
        {
            var box = await card.BoundingBoxAsync();
            if (box == null)
            {
                _logger.LogWarning("[HtmlCapture] BoundingBox nulo para un .idcard-face, ignorado.");
                continue;
            }

            var rawPng   = await card.ScreenshotDataAsync(new ElementScreenshotOptions { Type = ScreenshotType.Png });
            bool isVert  = box.Height > box.Width;
            var (tw, th) = isVert ? (PortraitW, PortraitH) : (LandscapeW, LandscapeH);
            var resized  = ResizePng(rawPng, tw, th);
            pngFaces.Add((resized, isVert));

            _logger.LogInformation(
                "[HtmlCapture] Face capturada: box={W}×{H} isVertical={V} → redim {TW}×{TH}",
                (int)box.Width, (int)box.Height, isVert, tw, th);
        }

        if (pngFaces.Count == 0)
            throw new InvalidOperationException("No se pudo capturar ninguna cara del carnet.");

        // Generar PDF: una página QuestPDF por cara, tamaño CR80 exacto
        QuestPDF.Settings.License         = LicenseType.Community;
        QuestPDF.Settings.EnableDebugging = false;

        var pdf = Document.Create(container =>
        {
            foreach (var (png, isVert) in pngFaces)
            {
                var (wmm, hmm) = isVert ? (CardMmH, CardMmW) : (CardMmW, CardMmH);
                container.Page(p =>
                {
                    p.Size(wmm, hmm, Unit.Millimetre);
                    p.Margin(0);
                    p.Content().Image(png).FitArea();
                });
            }
        }).GeneratePdf();

        _logger.LogInformation(
            "[HtmlCapture] PDF generado StudentId={StudentId} Páginas={Pages} Bytes={Bytes}",
            studentId, pngFaces.Count, pdf.Length);

        return pdf;
    }

    // ══════════════════════════════════════════════════════════════════════════
    // Helpers
    // ══════════════════════════════════════════════════════════════════════════

    private static byte[] ResizePng(byte[] src, int targetW, int targetH)
    {
        using var data     = SKData.CreateCopy(src);
        using var original = SKImage.FromEncodedData(data)
            ?? throw new InvalidOperationException("No se pudo decodificar la imagen capturada.");

        var info = new SKImageInfo(targetW, targetH, SKColorType.Rgba8888, SKAlphaType.Premul);
        using var surface = SKSurface.Create(info);
        using var canvas  = surface.Canvas;
        canvas.Clear(SKColors.White);

        using var paint = new SKPaint { IsAntialias = true, FilterQuality = SKFilterQuality.High };
        canvas.DrawImage(original, new SKRect(0, 0, targetW, targetH), paint);

        using var snapshot = surface.Snapshot();
        using var encoded  = snapshot.Encode(SKEncodedImageFormat.Png, 100);
        using var ms       = new MemoryStream();
        encoded.SaveTo(ms);
        return ms.ToArray();
    }

    private async Task<string?> ResolveChromiumPathAsync()
    {
        // 1. Variable de entorno de producción (Render / Docker)
        var envPath = Environment.GetEnvironmentVariable("PUPPETEER_EXECUTABLE_PATH");
        if (!string.IsNullOrWhiteSpace(envPath) && File.Exists(envPath))
        {
            _logger.LogInformation("[HtmlCapture] Chrome desde PUPPETEER_EXECUTABLE_PATH: {P}", envPath);
            return envPath;
        }

        // 2. Rutas conocidas en Linux
        foreach (var p in KnownChromePaths)
        {
            if (File.Exists(p))
            {
                _logger.LogInformation("[HtmlCapture] Chrome del sistema encontrado: {P}", p);
                return p;
            }
        }

        // 3. Cache de la descarga anterior en este proceso
        if (_resolvedChromiumPath != null)
            return _resolvedChromiumPath;

        // 4. Descargar Chromium (primera vez — puede tardar en producción)
        await _downloadLock.WaitAsync();
        try
        {
            if (_resolvedChromiumPath != null) return _resolvedChromiumPath;

            _logger.LogWarning(
                "[HtmlCapture] Chrome no encontrado en el sistema — descargando Chromium. " +
                "Configure PUPPETEER_EXECUTABLE_PATH en producción para evitar esta descarga.");

            var fetcher  = new BrowserFetcher();
            var installed = await fetcher.DownloadAsync();
            _resolvedChromiumPath = installed.GetExecutablePath();

            _logger.LogInformation("[HtmlCapture] Chromium descargado en {P}", _resolvedChromiumPath);
            return _resolvedChromiumPath;
        }
        finally
        {
            _downloadLock.Release();
        }
    }
}
