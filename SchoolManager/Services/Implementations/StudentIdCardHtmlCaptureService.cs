using PuppeteerSharp;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using SchoolManager.Services.Interfaces;
using SkiaSharp;
using Microsoft.Extensions.Options;
using System.Runtime.InteropServices;

namespace SchoolManager.Services.Implementations;

public class StudentIdCardHtmlCaptureService : IStudentIdCardHtmlCaptureService
{
    private readonly ILogger<StudentIdCardHtmlCaptureService> _logger;
    private readonly IHttpContextAccessor                     _http;
    private readonly StudentIdCardPdfPrintOptions             _printOptions;

    public StudentIdCardHtmlCaptureService(
        ILogger<StudentIdCardHtmlCaptureService> logger,
        IHttpContextAccessor http,
        IOptions<StudentIdCardPdfPrintOptions> printOptions)
    {
        _logger       = logger;
        _http         = http;
        _printOptions = printOptions.Value ?? new StudentIdCardPdfPrintOptions();
    }

    public async Task<byte[]> GenerateFromUrl(string url)
    {
        var executablePath = await ResolveChromiumExecutablePath();
        _logger.LogInformation("[CardPdf] Using Chromium path: {Path}", executablePath);
        var pageSize = ResolvePageSize();

        var launchOpts = new LaunchOptions
        {
            Headless       = true,
            ExecutablePath = executablePath,
            Timeout        = 60000,
            Args           = BuildLaunchArgs()
        };

        byte[] frontImg;
        byte[]? backImg;
        try
        {
            (frontImg, backImg) = await CaptureCardFaces(url, launchOpts);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "[CardPdf] First capture attempt failed. Retrying once...");
            await Task.Delay(500);
            (frontImg, backImg) = await CaptureCardFaces(url, launchOpts);
        }

        QuestPDF.Settings.License         = LicenseType.Community;
        QuestPDF.Settings.EnableDebugging = false;

        return Document.Create(container =>
        {
            container.Page(p =>
            {
                p.Size(pageSize.WidthMm, pageSize.HeightMm, Unit.Millimetre);
                p.Margin(0);
                p.Content().Image(frontImg).FitArea();
            });

            if (backImg != null)
            {
                container.Page(p =>
                {
                    p.Size(pageSize.WidthMm, pageSize.HeightMm, Unit.Millimetre);
                    p.Margin(0);
                    p.Content().Image(backImg).FitArea();
                });
            }
        }).GeneratePdf();
    }

    private async Task<(byte[] Front, byte[]? Back)> CaptureCardFaces(string url, LaunchOptions launchOpts)
    {
        await using var browser = await Puppeteer.LaunchAsync(launchOpts);
        await using var page    = await browser.NewPageAsync();
        var pageSize = ResolvePageSize();

        page.DefaultNavigationTimeout = 60000;
        page.DefaultTimeout           = 60000;
        await page.SetViewportAsync(new ViewPortOptions
        {
            Width  = pageSize.WidthPx + 120,
            Height = pageSize.HeightPx + 120
        });

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

        await page.GoToAsync(url, new NavigationOptions
        {
            WaitUntil = [WaitUntilNavigation.DOMContentLoaded, WaitUntilNavigation.Networkidle2],
            Timeout   = 60000
        });
        await ApplyContentScale(page);
        await page.WaitForSelectorAsync(".idcard-face", new WaitForSelectorOptions { Timeout = 60000 });
        await Task.Delay(400);

        var front = await page.QuerySelectorAsync("#idCardFront")
            ?? throw new InvalidOperationException("No se encontró #idCardFront.");

        var allFaces = await page.QuerySelectorAllAsync(".idcard-face");
        var back     = allFaces.Length > 1 ? allFaces[1] : null;

        var frontImg = await Capture(front, pageSize.WidthPx, pageSize.HeightPx);
        var backImg  = back != null ? await Capture(back, pageSize.WidthPx, pageSize.HeightPx) : null;
        return (frontImg, backImg);
    }

    private async Task ApplyContentScale(IPage page)
    {
        var scale = (double)Math.Clamp((float)_printOptions.ContentScale, 0.85f, 1.00f);
        await page.EvaluateExpressionAsync(
            $"document.documentElement.style.zoom = '{scale.ToString(System.Globalization.CultureInfo.InvariantCulture)}';");
    }

    private (float WidthMm, float HeightMm, int WidthPx, int HeightPx) ResolvePageSize()
    {
        if (string.Equals(_printOptions.Profile, "A4Portrait", StringComparison.OrdinalIgnoreCase))
        {
            // A4 retrato con proporción de preview vertical (sirve para impresión en hoja).
            return (148.0f, 235.0f, 1750, 2777);
        }

        // CardPrinter (default): ID-1 portrait (vertical): 53.98mm x 85.60mm
        return (53.98f, 85.60f, 638, 1011);
    }

    private static string[] BuildLaunchArgs()
    {
        var args = new List<string>
        {
            "--disable-dev-shm-usage",
            "--disable-gpu",
            "--disable-background-networking",
            "--disable-background-timer-throttling",
            "--disable-renderer-backgrounding"
        };

        // En Linux de servidores sin sandbox habilitado estos flags suelen ser necesarios.
        if (!RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
        {
            args.Add("--no-sandbox");
            args.Add("--disable-setuid-sandbox");
        }

        return args.ToArray();
    }

    private async Task<string> ResolveChromiumExecutablePath()
    {
        var envPath = Environment.GetEnvironmentVariable("PUPPETEER_EXECUTABLE_PATH");
        if (!string.IsNullOrWhiteSpace(envPath) && File.Exists(envPath))
            return envPath;

        var candidates = RuntimeInformation.IsOSPlatform(OSPlatform.Windows)
            ? new[]
            {
                @"C:\Program Files\Google\Chrome\Application\chrome.exe",
                @"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
                @"C:\Program Files\Microsoft\Edge\Application\msedge.exe",
                @"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
            }
            : new[]
            {
                "/usr/bin/chromium",
                "/usr/bin/chromium-browser",
                "/usr/bin/google-chrome",
                "/snap/bin/chromium"
            };

        var localExecutable = candidates.FirstOrDefault(File.Exists);
        if (!string.IsNullOrWhiteSpace(localExecutable))
            return localExecutable;

        _logger.LogInformation("[CardPdf] No local Chromium/Chrome found, downloading managed browser...");
        var browserFetcher = new BrowserFetcher();
        var installed      = await browserFetcher.DownloadAsync();
        return installed.GetExecutablePath();
    }

    private async Task<byte[]> Capture(IElementHandle el, int targetWidth, int targetHeight)
    {
        var img = await el.ScreenshotDataAsync(new ElementScreenshotOptions
        {
            Type = ScreenshotType.Png
        });

        using var input   = SKBitmap.Decode(img);
        using var resized = input.Resize(new SKImageInfo(targetWidth, targetHeight), SKFilterQuality.High);
        using var image   = SKImage.FromBitmap(resized);
        using var data    = image.Encode(SKEncodedImageFormat.Png, 100);
        return data.ToArray();
    }
}
