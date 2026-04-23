namespace SchoolManager.Helpers;

/// <summary>
/// URL del endpoint que sirve la foto de usuario (Cloudinary, disco o imagen por defecto como el logo de escuela).
/// </summary>
public static class UserPhotoLinks
{
    public static string Href(string? photoUrlStored) =>
        "/File/GetUserPhoto?photoUrl=" + Uri.EscapeDataString(photoUrlStored ?? string.Empty);

    /// <summary>
    /// Foto para vista previa del carnet (HTML/Puppeteer): añade el query <c>carnetEdge</c> para que GetUserPhoto redirija a una variante Cloudinary de mayor borde,
    /// manteniendo el mismo marco CSS en la vista.
    /// </summary>
    /// <param name="photoUrlStored">URL almacenada (Cloudinary u otra admitida por GetUserPhoto).</param>
    /// <param name="edgePx">Borde máximo del cuadrado entregado (120–800). Por defecto ~3.6× el marco de 100px del carnet.</param>
    public static string HrefForCarnetPreview(string? photoUrlStored, int edgePx = 360) =>
        "/File/GetUserPhoto?photoUrl=" + Uri.EscapeDataString(photoUrlStored ?? string.Empty)
        + "&carnetEdge=" + edgePx.ToString(System.Globalization.CultureInfo.InvariantCulture);

    /// <summary>
    /// Miniatura para tablas/listados: <c>variant=thumb</c> en GetUserPhoto → redirección Cloudinary con transformación liviana.
    /// Si la URL no es Cloudinary, el servidor ignora la variante y sirve el recurso como siempre (fallback).
    /// </summary>
    public static string HrefListThumbnail(string? photoUrlStored) =>
        "/File/GetUserPhoto?photoUrl=" + Uri.EscapeDataString(photoUrlStored ?? string.Empty) + "&variant=thumb";
}
