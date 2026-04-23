using System.Text.RegularExpressions;

namespace SchoolManager.Helpers;

/// <summary>
/// Inserta una cadena de transformación Cloudinary (recorte cuadrado + calidad) en URLs <c>res.cloudinary.com/.../image/upload/...</c>
/// para que el navegador/Puppeteer decodifique más píxeles que el marco CSS del carnet, sin cambiar el layout.
/// </summary>
public static partial class CloudinaryCarnetDeliveryUrl
{
    private const string UploadMarker = "/image/upload/";

    /// <summary>
    /// Devuelve una URL de entrega con recorte <c>fill</c> y borde máximo <paramref name="edgePx"/> (p. ej. 360 para ~3.6× un marco de 100px).
    /// Si no es Cloudinary o no se reconoce el patrón, devuelve <paramref name="originalUrl"/> sin cambios.
    /// </summary>
    public static string WithCarnetFaceCrop(string? originalUrl, int edgePx)
    {
        if (string.IsNullOrWhiteSpace(originalUrl))
            return originalUrl ?? string.Empty;

        var url = originalUrl.Trim();
        if (!url.Contains("res.cloudinary.com", StringComparison.OrdinalIgnoreCase))
            return url;

        edgePx = Math.Clamp(edgePx, 120, 800);

        var markerIdx = url.IndexOf(UploadMarker, StringComparison.OrdinalIgnoreCase);
        if (markerIdx < 0)
            return url;

        var prefix = url[..(markerIdx + UploadMarker.Length)];
        var tail = url[(markerIdx + UploadMarker.Length)..];

        var qIdx = tail.IndexOf('?', StringComparison.Ordinal);
        string query = "";
        if (qIdx >= 0)
        {
            query = tail[qIdx..];
            tail = tail[..qIdx];
        }

        var segments = tail.Split('/', StringSplitOptions.RemoveEmptyEntries).ToList();
        var writeIdx = 0;
        for (var i = 0; i < segments.Count; i++)
        {
            if (LooksLikeCloudinaryTransformation(segments[i]))
                continue;
            writeIdx = i;
            break;
        }

        var retained = string.Join("/", segments.Skip(writeIdx));
        if (string.IsNullOrEmpty(retained))
            return url;

        var chain = $"w_{edgePx},h_{edgePx},c_fill,g_auto,q_auto:good,f_auto";
        return prefix + chain + "/" + retained + query;
    }

    private static bool LooksLikeCloudinaryTransformation(string segment)
    {
        if (string.IsNullOrEmpty(segment))
            return false;
        if (VersionSegment().IsMatch(segment))
            return false;
        if (segment.Contains(',', StringComparison.Ordinal))
            return true;

        return segment.StartsWith("w_", StringComparison.OrdinalIgnoreCase)
               || segment.StartsWith("h_", StringComparison.OrdinalIgnoreCase)
               || segment.StartsWith("c_", StringComparison.OrdinalIgnoreCase)
               || segment.StartsWith("q_", StringComparison.OrdinalIgnoreCase)
               || segment.StartsWith("f_", StringComparison.OrdinalIgnoreCase)
               || segment.StartsWith("g_", StringComparison.OrdinalIgnoreCase)
               || segment.StartsWith("e_", StringComparison.OrdinalIgnoreCase)
               || segment.StartsWith("b_", StringComparison.OrdinalIgnoreCase)
               || segment.StartsWith("a_", StringComparison.OrdinalIgnoreCase)
               || segment.StartsWith("fl_", StringComparison.OrdinalIgnoreCase)
               || segment.StartsWith("dpr_", StringComparison.OrdinalIgnoreCase)
               || segment.StartsWith("t_", StringComparison.OrdinalIgnoreCase)
               || segment.StartsWith("x_", StringComparison.OrdinalIgnoreCase)
               || segment.StartsWith("y_", StringComparison.OrdinalIgnoreCase)
               || segment.StartsWith("r_", StringComparison.OrdinalIgnoreCase)
               || segment.StartsWith("o_", StringComparison.OrdinalIgnoreCase)
               || segment.StartsWith("l_", StringComparison.OrdinalIgnoreCase)
               || segment.StartsWith("ar_", StringComparison.OrdinalIgnoreCase)
               || segment.StartsWith("so_", StringComparison.OrdinalIgnoreCase);
    }

    [GeneratedRegex(@"^v\d+$", RegexOptions.IgnoreCase | RegexOptions.CultureInvariant)]
    private static partial Regex VersionSegment();
}
