using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SchoolManager.Services.Interfaces;

namespace SchoolManager.Controllers;

[Authorize]
public class FileController : Controller
{
    private readonly ISuperAdminService _superAdminService;
    private readonly ILogger<FileController> _logger;

    public FileController(ISuperAdminService superAdminService, ILogger<FileController> logger)
    {
        _superAdminService = superAdminService;
        _logger = logger;
    }

    [HttpGet]
    public async Task<IActionResult> GetSchoolLogo(string logoUrl)
    {
        if (string.IsNullOrEmpty(logoUrl))
        {
            // Retornar logo por defecto si no hay logoUrl
            var defaultLogoPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "images", "logoIPT.jpg");
            if (System.IO.File.Exists(defaultLogoPath))
            {
                var defaultBytes = await System.IO.File.ReadAllBytesAsync(defaultLogoPath);
                return File(defaultBytes, "image/jpeg");
            }
            return NotFound();
        }

        try
        {
            var bytes = await _superAdminService.GetLogoAsync(logoUrl);
            if (bytes == null)
            {
                // Fallback a logo por defecto
                var defaultLogoPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "images", "logoIPT.jpg");
                if (System.IO.File.Exists(defaultLogoPath))
                {
                    var defaultBytes = await System.IO.File.ReadAllBytesAsync(defaultLogoPath);
                    return File(defaultBytes, "image/jpeg");
                }
                return NotFound();
            }

            return File(bytes, "image/jpeg");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error obteniendo logo de escuela: {logoUrl}", logoUrl);
            
            // Fallback a logo por defecto en caso de error
            try
            {
                var defaultLogoPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "images", "logoIPT.jpg");
                if (System.IO.File.Exists(defaultLogoPath))
                {
                    var defaultBytes = await System.IO.File.ReadAllBytesAsync(defaultLogoPath);
                    return File(defaultBytes, "image/jpeg");
                }
            }
            catch (Exception fallbackEx)
            {
                _logger.LogError(fallbackEx, "Error obteniendo logo por defecto");
            }
            
            return NotFound();
        }
    }

    [HttpGet]
    public async Task<IActionResult> GetUserAvatar(string avatarUrl)
    {
        if (string.IsNullOrEmpty(avatarUrl))
        {
            return NotFound();
        }

        try
        {
            var bytes = await _superAdminService.GetAvatarAsync(avatarUrl);
            if (bytes == null)
            {
                return NotFound();
            }

            return File(bytes, "image/jpeg");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error obteniendo avatar de usuario: {avatarUrl}", avatarUrl);
            return NotFound();
        }
    }

    [HttpGet]
    public IActionResult DownloadTemplate(string fileName)
    {
        if (string.IsNullOrEmpty(fileName))
        {
            return NotFound();
        }

        try
        {
            var filePath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "descargables", fileName);
            
            if (!System.IO.File.Exists(filePath))
            {
                return NotFound();
            }

            var fileBytes = System.IO.File.ReadAllBytes(filePath);
            var contentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            
            return File(fileBytes, contentType, fileName);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error descargando plantilla: {fileName}", fileName);
            return NotFound();
        }
    }
} 