namespace SchoolManager.Services.Interfaces;

/// <summary>
/// Descarga bytes por HTTPS con caché en memoria (y disco opcional) para la misma URL.
/// Pensado para logos y fotos remotas en generación de PDF; no altera el origen.
/// </summary>
public interface IHttpBytesDownloadCache
{
    /// <param name="absoluteUrl">URL absoluta https.</param>
    /// <param name="maxBytes">Si el cuerpo supera este tamaño, se descarta y no se cachea.</param>
    Task<byte[]?> GetOrDownloadAsync(string absoluteUrl, int maxBytes, TimeSpan timeout, CancellationToken cancellationToken = default);
}
