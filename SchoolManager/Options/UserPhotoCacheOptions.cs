namespace SchoolManager.Options;

/// <summary>
/// Caché de descargas HTTP (p. ej. Cloudinary) para PDFs y lectura de fotos por URL remota.
/// No sustituye Cloudinary; solo evita repetir la misma descarga en memoria/disco temporal.
/// </summary>
public class UserPhotoCacheOptions
{
    public const string SectionName = "UserPhotoCache";

    public bool Enabled { get; set; } = true;

    /// <summary>TTL de entradas en <see cref="Microsoft.Extensions.Caching.Memory.IMemoryCache"/>.</summary>
    public int MemoryEntryTtlSeconds { get; set; } = 600;

    /// <summary>Límite de tamaño por entrada en memoria (bytes descargados mayores no se cachean en RAM).</summary>
    public int MemoryMaxEntryBytes { get; set; } = 5_242_880;

    /// <summary>Límite total aproximado del MemoryCache (suma de tamaños de entradas con <c>SetSize</c>).</summary>
    public long MemoryCacheSizeLimitBytes { get; set; } = 134_217_728;

    public bool DiskCacheEnabled { get; set; } = true;

    /// <summary>Ruta relativa al ContentRoot (no público en wwwroot).</summary>
    public string DiskRelativePath { get; set; } = "cache/http-images";

    public long DiskMaxFileBytes { get; set; } = 4_194_304;
}
