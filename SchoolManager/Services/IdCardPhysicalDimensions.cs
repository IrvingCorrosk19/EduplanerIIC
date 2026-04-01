namespace SchoolManager.Services;

/// <summary>
/// Carnet tipo CR (~55 mm × 85 mm en vertical). Misma base para vista HTML, captura PDF y render Skia.
/// </summary>
public static class IdCardPhysicalDimensions
{
    public const float LongMm = 85f;
    public const float ShortMm = 55f;
    public const float RenderDpi = 300f;

    public static int LandscapeWidthPx => (int)(LongMm / 25.4f * RenderDpi);
    public static int LandscapeHeightPx => (int)(ShortMm / 25.4f * RenderDpi);
    public static int PortraitWidthPx => LandscapeHeightPx;
    public static int PortraitHeightPx => LandscapeWidthPx;
}
