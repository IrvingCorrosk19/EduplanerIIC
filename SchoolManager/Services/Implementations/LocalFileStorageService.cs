using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Logging;
using SchoolManager.Services.Interfaces;
using SkiaSharp;

namespace SchoolManager.Services.Implementations;

/// <summary>
/// Almacenamiento local de fotos de usuario (Infrastructure).
/// Preparado para reemplazo por AzureBlobStorageService sin cambiar contrato.
/// </summary>
public sealed class LocalFileStorageService : IFileStorageService
{
    /// <summary>Límite del archivo guardado (comprimido si hace falta).</summary>
    private const int MaxFileSizeBytes = 2 * 1024 * 1024; // 2 MB

    /// <summary>Máximo que se acepta en la subida antes de procesar (evita abusos).</summary>
    private const int MaxIncomingUploadBytes = 12 * 1024 * 1024; // 12 MB

    private const int CompressMaxInitialSide = 2048;
    private static readonly HashSet<string> AllowedMimeTypes = new(StringComparer.OrdinalIgnoreCase)
    {
        "image/jpeg",
        "image/png"
    };

    private static readonly string[] AllowedExtensions = { ".jpg", ".jpeg", ".png" };

    private readonly IWebHostEnvironment _env;
    private readonly ILogger<LocalFileStorageService> _logger;
    private readonly string _basePath;

    public LocalFileStorageService(IWebHostEnvironment env, ILogger<LocalFileStorageService> logger)
    {
        _env = env;
        _logger = logger;
        _basePath = Path.Combine(_env.WebRootPath ?? _env.ContentRootPath, "uploads", "users");
    }

    public async Task<string> SaveUserPhotoAsync(IFormFile file, Guid userId)
    {
        if (file == null || file.Length == 0)
        {
            _logger.LogWarning("[FileStorage] Intento de guardar archivo vacío para UserId={UserId}", userId);
            throw new ArgumentException("El archivo no puede estar vacío.", nameof(file));
        }

        ValidateMimeType(file.ContentType, file.FileName);
        if (file.Length > MaxIncomingUploadBytes)
        {
            throw new InvalidOperationException(
                $"La imagen supera el máximo de subida ({MaxIncomingUploadBytes / (1024 * 1024)} MB). " +
                "Redúzcala o use otra foto.");
        }

        await using var uploadMs = new MemoryStream((int)Math.Min(file.Length, MaxIncomingUploadBytes));
        await file.CopyToAsync(uploadMs);
        var rawBytes = uploadMs.ToArray();

        string safeFileName;
        byte[] bytesToWrite;

        if (rawBytes.Length <= MaxFileSizeBytes)
        {
            bytesToWrite = rawBytes;
            safeFileName = $"{userId:N}_{Guid.NewGuid():N}{GetExtensionFromMime(file.ContentType)}";
        }
        else
        {
            bytesToWrite = CompressImageToMaxBytes(rawBytes, MaxFileSizeBytes);
            safeFileName = $"{userId:N}_{Guid.NewGuid():N}.jpg";
            _logger.LogInformation(
                "[FileStorage] Foto comprimida UserId={UserId} {OriginalKb:F0} KB → {FinalKb:F0} KB",
                userId, rawBytes.Length / 1024.0, bytesToWrite.Length / 1024.0);
        }

        if (bytesToWrite.Length > MaxFileSizeBytes)
        {
            throw new InvalidOperationException(
                "No se pudo reducir la imagen por debajo de 2 MB. Pruebe con otra foto o menor resolución.");
        }

        var fullPath = Path.GetFullPath(Path.Combine(_basePath, safeFileName));

        if (!fullPath.StartsWith(Path.GetFullPath(_basePath), StringComparison.OrdinalIgnoreCase))
        {
            _logger.LogError("[FileStorage] Path traversal detectado: {Path}", fullPath);
            throw new InvalidOperationException("Ruta de archivo no permitida.");
        }

        Directory.CreateDirectory(_basePath);

        await File.WriteAllBytesAsync(fullPath, bytesToWrite);

        var relativePath = $"/uploads/users/{safeFileName}";
        _logger.LogInformation("[FileStorage] Foto guardada UserId={UserId} Path={Path}", userId, relativePath);
        return relativePath;
    }

    private static byte[] CompressImageToMaxBytes(byte[] source, int maxBytes)
    {
        var decoded = SKBitmap.Decode(source);
        if (decoded == null || decoded.Width < 1 || decoded.Height < 1)
        {
            throw new InvalidOperationException(
                "No se pudo leer la imagen. Use un JPEG o PNG válido.");
        }

        var bmp = DownscaleToMaxSide(decoded, CompressMaxInitialSide);
        try
        {
            while (true)
            {
                for (var quality = 88; quality >= 28; quality -= 10)
                {
                    var jpeg = EncodeJpeg(bmp, quality);
                    if (jpeg.Length <= maxBytes)
                        return jpeg;
                }

                var nw = Math.Max(400, (int)(bmp.Width * 0.75f));
                var nh = Math.Max(400, (int)(bmp.Height * 0.75f));
                if (nw >= bmp.Width && nh >= bmp.Height)
                {
                    nw = Math.Max(200, bmp.Width * 9 / 10);
                    nh = Math.Max(200, bmp.Height * 9 / 10);
                }

                if (nw < 200 || nh < 200)
                {
                    throw new InvalidOperationException(
                        "No se pudo comprimir la imagen lo suficiente para cumplir 2 MB.");
                }

                var next = bmp.Resize(new SKImageInfo(nw, nh), SKFilterQuality.Medium);
                if (next == null)
                {
                    throw new InvalidOperationException(
                        "No se pudo redimensionar la imagen. Pruebe con otro archivo.");
                }

                bmp.Dispose();
                bmp = next;
            }
        }
        finally
        {
            bmp.Dispose();
        }
    }

    private static SKBitmap DownscaleToMaxSide(SKBitmap decoded, int maxSide)
    {
        if (decoded.Width <= maxSide && decoded.Height <= maxSide)
            return decoded;

        var scale = maxSide / (float)Math.Max(decoded.Width, decoded.Height);
        var w = Math.Max(1, (int)(decoded.Width * scale));
        var h = Math.Max(1, (int)(decoded.Height * scale));
        var resized = decoded.Resize(new SKImageInfo(w, h), SKFilterQuality.Medium);
        if (resized == null)
        {
            decoded.Dispose();
            throw new InvalidOperationException("No se pudo redimensionar la imagen.");
        }

        decoded.Dispose();
        return resized;
    }

    private static byte[] EncodeJpeg(SKBitmap bitmap, int quality)
    {
        using var image = SKImage.FromBitmap(bitmap);
        using var data = image.Encode(SKEncodedImageFormat.Jpeg, quality);
        if (data == null)
            throw new InvalidOperationException("No se pudo codificar la imagen como JPEG.");
        return data.ToArray();
    }

    public Task DeleteUserPhotoAsync(string? photoUrl)
    {
        if (string.IsNullOrWhiteSpace(photoUrl))
            return Task.CompletedTask;

        try
        {
            var fileName = Path.GetFileName(photoUrl.Trim());
            if (string.IsNullOrEmpty(fileName) || fileName.IndexOfAny(Path.GetInvalidFileNameChars()) >= 0)
            {
                _logger.LogWarning("[FileStorage] Nombre de archivo inválido para eliminar: {Url}", photoUrl);
                return Task.CompletedTask;
            }

            var fullPath = Path.GetFullPath(Path.Combine(_basePath, fileName));
            if (!fullPath.StartsWith(Path.GetFullPath(_basePath), StringComparison.OrdinalIgnoreCase))
            {
                _logger.LogWarning("[FileStorage] Path traversal al eliminar: {Path}", fullPath);
                return Task.CompletedTask;
            }

            if (File.Exists(fullPath))
            {
                File.Delete(fullPath);
                _logger.LogInformation("[FileStorage] Foto eliminada: {Path}", fullPath);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[FileStorage] Error eliminando foto: {Url}", photoUrl);
        }

        return Task.CompletedTask;
    }

    public Task<byte[]?> GetUserPhotoBytesAsync(string? photoUrl)
    {
        if (string.IsNullOrWhiteSpace(photoUrl))
            return Task.FromResult<byte[]?>(null);

        try
        {
            var fileName = Path.GetFileName(photoUrl.Trim().TrimStart('/').Replace("uploads/users/", ""));
            if (string.IsNullOrEmpty(fileName) || fileName.IndexOfAny(Path.GetInvalidFileNameChars()) >= 0)
                return Task.FromResult<byte[]?>(null);

            var fullPath = Path.GetFullPath(Path.Combine(_basePath, fileName));
            if (!fullPath.StartsWith(Path.GetFullPath(_basePath), StringComparison.OrdinalIgnoreCase))
                return Task.FromResult<byte[]?>(null);

            if (!File.Exists(fullPath))
                return Task.FromResult<byte[]?>(null);

            var bytes = File.ReadAllBytes(fullPath);
            return Task.FromResult<byte[]?>(bytes);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[FileStorage] Error leyendo foto: {Url}", photoUrl);
            return Task.FromResult<byte[]?>(null);
        }
    }

    private static void ValidateMimeType(string? contentType, string? fileName)
    {
        var mime = contentType?.Split(';').FirstOrDefault()?.Trim();
        if (string.IsNullOrEmpty(mime) || !AllowedMimeTypes.Contains(mime))
        {
            throw new InvalidOperationException(
                "Solo se permiten imágenes JPEG o PNG. Tipo recibido: " + (mime ?? "desconocido"));
        }

        var ext = Path.GetExtension(fileName ?? "");
        if (string.IsNullOrEmpty(ext) || !AllowedExtensions.Contains(ext, StringComparer.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException("Extensión de archivo no permitida. Use .jpg o .png.");
        }
    }

    private static string GetExtensionFromMime(string contentType)
    {
        var mime = contentType?.Split(';').FirstOrDefault()?.Trim();
        return string.Equals(mime, "image/png", StringComparison.OrdinalIgnoreCase) ? ".png" : ".jpg";
    }
}
