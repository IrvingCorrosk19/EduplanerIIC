using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Logging;
using SchoolManager.Services.Interfaces;

namespace SchoolManager.Services.Implementations;

/// <summary>
/// Almacenamiento local de fotos de usuario (Infrastructure).
/// Preparado para reemplazo por AzureBlobStorageService sin cambiar contrato.
/// </summary>
public sealed class LocalFileStorageService : IFileStorageService
{
    private const int MaxFileSizeBytes = 2 * 1024 * 1024; // 2 MB
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
        ValidateFileSize(file.Length);

        var safeFileName = $"{userId:N}_{Guid.NewGuid():N}{GetExtensionFromMime(file.ContentType)}";
        var fullPath = Path.GetFullPath(Path.Combine(_basePath, safeFileName));

        if (!fullPath.StartsWith(Path.GetFullPath(_basePath), StringComparison.OrdinalIgnoreCase))
        {
            _logger.LogError("[FileStorage] Path traversal detectado: {Path}", fullPath);
            throw new InvalidOperationException("Ruta de archivo no permitida.");
        }

        Directory.CreateDirectory(_basePath);

        await using (var stream = new FileStream(fullPath, FileMode.CreateNew, FileAccess.Write, FileShare.None))
        {
            await file.CopyToAsync(stream);
        }

        var relativePath = $"/uploads/users/{safeFileName}";
        _logger.LogInformation("[FileStorage] Foto guardada UserId={UserId} Path={Path}", userId, relativePath);
        return relativePath;
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

    private static void ValidateFileSize(long length)
    {
        if (length > MaxFileSizeBytes)
        {
            throw new InvalidOperationException(
                $"El archivo no puede superar 2 MB. Tamaño recibido: {length / 1024.0:F1} KB.");
        }
    }

    private static string GetExtensionFromMime(string contentType)
    {
        var mime = contentType?.Split(';').FirstOrDefault()?.Trim();
        return string.Equals(mime, "image/png", StringComparison.OrdinalIgnoreCase) ? ".png" : ".jpg";
    }
}
