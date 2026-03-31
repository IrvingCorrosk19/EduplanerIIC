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

    private static string?                _chromiumPath;
    private static readonly SemaphoreSlim _lock = new(1, 1);

    private readonly ILogger<StudentIdCardHtmlCaptureService> _logger;
    private readonly IHttpContextAccessor                     _http;

    public StudentIdCardHtmlCaptureService(
        ILogger<StudentIdCardHtmlCaptureService> logger,
        IHttpContextAccessor http)
    {
        _logger = logger;
        _http   = http;
    }

    public async Task<byte[]> GenerateFromUrl(string url)
    {
        _logger.LogInformation("[CardPdf] GenerateFromUrl {Url}", url);

        var execPath = await ResolveChromiumAsync();

        var launchOpts = new LaunchOptions
        {
            Headless = true,
            Args     = ["--no-sandbox", "--disable-setuid-sandbox",
                        "--disable-dev-shm-usage", "--disable-gpu"]
        };
        if (!string.IsNullOrWhiteSpace(execPath))
            launchOpts.ExecutablePath = execPath;

        await using var browser = await Puppeteer.LaunchAsync(launchOpts);
        await using var page    = await browser.NewPageAsync();

        // Auth: propagar cookies de la sesión actual
        var reqCookies = _http.HttpContext?.Request.Cookies;
        if (reqCookies?.Count > 0)
        {
            var host   = new Uri(url).Host;
            var cpList = reqCookies
                .Select(c => new CookieParam { Name = c.Key, Value = c.Value, Domain = host })
                .ToArray();
            await page.SetCookieAsync(cpList);
        }

        await page.GoToAsync(url, WaitUntilNavigation.Networkidle0);
        await page.WaitForSelectorAsync(".idcard-face");
        await Task.Delay(500);

        // Selección de elementos
        var front = await page.QuerySelectorAsync("#idCardFront")
            ?? throw new InvalidOperationException("No se encontró #idCardFront.");

        var allFaces = await page.QuerySelectorAllAsync(".idcard-face");
        var back     = allFaces.Length > 1 ? allFaces[1] : null;

        // Captura
        var frontImg = await Capture(front);
        var backImg  = back != null ? await Capture(back) : null;

        // PDF
        QuestPDF.Settings.License         = LicenseType.Community;
        QuestPDF.Settings.EnableDebugging = false;

        return Document.Create(container =>
        {
            container.Page(p =>
            {
                p.Size(WidthMm, HeightMm, Unit.Millimetre);
                p.Margin(0);
                p.Content().Image(frontImg).FitArea();
            });

            if (backImg != null)
            {
                container.Page(p =>
                {
                    p.Size(WidthMm, HeightMm, Unit.Millimetre);
                    p.Margin(0);
                    p.Content().Image(backImg).FitArea();
                });
            }
        }).GeneratePdf();
    }

    // ─────────────────────────────────────────────────────────────────────────

    private async Task<byte[]> Capture(IElementHandle el)
    {
        var img = await el.ScreenshotDataAsync(new ElementScreenshotOptions
        {
            Type = ScreenshotType.Png
        });

        using var input   = SKBitmap.Decode(img);
        using var resized = input.Resize(new SKImageInfo(WidthPx, HeightPx), SKFilterQuality.High);
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

        await _lock.WaitAsync();
        try
        {
            if (_chromiumPath != null) return _chromiumPath;
            _logger.LogWarning("[CardPdf] Descargando Chromium (configure PUPPETEER_EXECUTABLE_PATH en prod)...");
            var installed = await new BrowserFetcher().DownloadAsync();
            _chromiumPath = installed.GetExecutablePath();
            _logger.LogInformation("[CardPdf] Chromium listo: {P}", _chromiumPath);
            return _chromiumPath;
        }
        finally { _lock.Release(); }
    }
}
