using PuppeteerSharp;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using SchoolManager.Services.Interfaces;
using SkiaSharp;

namespace SchoolManager.Services.Implementations;

public class StudentIdCardHtmlCaptureService : IStudentIdCardHtmlCaptureService
{
    private const float WidthMm  = 85.60f;
    private const float HeightMm = 53.98f;
    private const int   WidthPx  = 1011;
    private const int   HeightPx = 638;

    private static readonly string[] KnownChromePaths =
    [
        "/usr/bin/google-chrome",
        "/usr/bin/google-chrome-stable",
        "/usr/bin/chromium-browser",
        "/usr/bin/chromium",
        "/usr/local/bin/chromium",
        "/snap/bin/chromium"
    ];

    private static string?          _chromiumPath;
    private static readonly SemaphoreSlim _downloadLock = new(1, 1);

    private readonly ILogger<StudentIdCardHtmlCaptureService> _logger;
    private readonly IHttpContextAccessor                     _httpCtx;

    public StudentIdCardHtmlCaptureService(
        ILogger<StudentIdCardHtmlCaptureService> logger,
        IHttpContextAccessor httpCtx)
    {
        _logger  = logger;
        _httpCtx = httpCtx;
    }

    public async Task<byte[]> GenerateFromUrl(string url)
    {
        _logger.LogInformation("[CardPdf] GenerateFromUrl {Url}", url);

        var execPath = await ResolveChromiumAsync();

        var launchOpts = new LaunchOptions
        {
            Headless = true,
            Args     = new[] { "--no-sandbox", "--disable-setuid-sandbox",
                               "--disable-dev-shm-usage", "--disable-gpu" }
        };
        if (!string.IsNullOrWhiteSpace(execPath))
            launchOpts.ExecutablePath = execPath;

        await using var browser = await Puppeteer.LaunchAsync(launchOpts);
        await using var page    = await browser.NewPageAsync();

        // Propagar cookies de sesión para acceder a rutas protegidas
        var reqCookies = _httpCtx.HttpContext?.Request.Cookies;
        if (reqCookies != null)
        {
            var host   = new Uri(url).Host;
            var cpList = reqCookies
                .Select(c => new CookieParam { Name = c.Key, Value = c.Value, Domain = host })
                .ToArray();
            if (cpList.Length > 0)
                await page.SetCookieAsync(cpList);
        }

        await page.GoToAsync(url, WaitUntilNavigation.Networkidle0);
        await page.WaitForSelectorAsync(".idcard-face");
        await Task.Delay(500);

        var front = await page.QuerySelectorAsync("#idCardFront")
            ?? throw new InvalidOperationException("No se encontró #idCardFront.");

        var cards = await page.QuerySelectorAllAsync(".idcard-face");
        var back  = cards.Length > 1 ? cards[1] : null;

        var frontImg = await Capture(front);
        var backImg  = back != null ? await Capture(back) : null;

        QuestPDF.Settings.License         = LicenseType.Community;
        QuestPDF.Settings.EnableDebugging = false;

        return Document.Create(container =>
        {
            AddPage(container, frontImg, front);

            if (backImg != null)
                AddPage(container, backImg, back!);

        }).GeneratePdf();
    }

    // ── helpers ──────────────────────────────────────────────────────────────

    private static void AddPage(IDocumentContainer container, byte[] img, IElementHandle el)
    {
        // Detectar orientación desde la imagen ya redimensionada
        // front/back siempre landscape → 85.60 × 53.98 mm
        // Si en el futuro hay verticales, la detección está preparada
        container.Page(p =>
        {
            p.Size(WidthMm, HeightMm, Unit.Millimetre);
            p.Margin(0);
            p.Content().Image(img).FitArea();
        });
    }

    private async Task<byte[]> Capture(IElementHandle el)
    {
        var box = await el.BoundingBoxAsync();
        _logger.LogInformation("[CardPdf] Capture box={W}×{H}", box?.Width, box?.Height);

        var img = await el.ScreenshotDataAsync(new ElementScreenshotOptions
        {
            Type = ScreenshotType.Png
        });

        // Detectar si la cara es vertical (portrait) y ajustar target
        bool isPortrait  = box != null && box.Height > box.Width;
        int  targetW     = isPortrait ? HeightPx : WidthPx;   // 638 | 1011
        int  targetH     = isPortrait ? WidthPx  : HeightPx;  // 1011 | 638

        using var input   = SKBitmap.Decode(img);
        using var resized = input.Resize(new SKImageInfo(targetW, targetH), SKFilterQuality.High);
        using var image   = SKImage.FromBitmap(resized);
        using var data    = image.Encode(SKEncodedImageFormat.Png, 100);
        return data.ToArray();
    }

    private async Task<string?> ResolveChromiumAsync()
    {
        var env = Environment.GetEnvironmentVariable("PUPPETEER_EXECUTABLE_PATH");
        if (!string.IsNullOrWhiteSpace(env) && File.Exists(env)) return env;

        foreach (var p in KnownChromePaths)
            if (File.Exists(p)) return p;

        if (_chromiumPath != null) return _chromiumPath;

        await _downloadLock.WaitAsync();
        try
        {
            if (_chromiumPath != null) return _chromiumPath;
            _logger.LogWarning("[CardPdf] Descargando Chromium (configure PUPPETEER_EXECUTABLE_PATH en prod)...");
            var installed = await new BrowserFetcher().DownloadAsync();
            _chromiumPath = installed.GetExecutablePath();
            _logger.LogInformation("[CardPdf] Chromium en {P}", _chromiumPath);
            return _chromiumPath;
        }
        finally { _downloadLock.Release(); }
    }
}
