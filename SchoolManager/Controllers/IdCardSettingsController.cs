using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;

namespace SchoolManager.Controllers;

[Authorize(Roles = "SuperAdmin,superadmin,Admin,admin,Director,director")]
[Route("id-card/settings")]
public class IdCardSettingsController : Controller
{
    private readonly SchoolDbContext _context;
    private readonly ICurrentUserService _currentUserService;

    public IdCardSettingsController(SchoolDbContext context, ICurrentUserService currentUserService)
    {
        _context = context;
        _currentUserService = currentUserService;
    }

    [HttpGet("")]
    public async Task<IActionResult> Index()
    {
        // No mostrar en esta página errores de otras secciones (ej. "Estudiante no encontrado" de Carnet)
        TempData.Remove("Error");

        var school = await _currentUserService.GetCurrentUserSchoolAsync();
        if (school == null)
        {
            TempData["IdCardSettings.Error"] = "No se pudo determinar la escuela del usuario actual.";
            return RedirectToAction("Index", "Home");
        }

        var settings = await _context.Set<SchoolIdCardSetting>()
            .FirstOrDefaultAsync(x => x.SchoolId == school.Id);

        settings ??= new SchoolIdCardSetting 
        { 
            SchoolId = school.Id,
            TemplateKey = "default_v1",
            PageWidthMm = 54,
            PageHeightMm = 86,
            BackgroundColor = "#FFFFFF",
            PrimaryColor = "#0D6EFD",
            TextColor = "#111111",
            ShowQr = true,
            ShowPhoto = false
        };

        return View(settings);
    }

    [HttpPost("save")]
    public async Task<IActionResult> Save(SchoolIdCardSetting model)
    {
        var school = await _currentUserService.GetCurrentUserSchoolAsync();
        if (school == null)
        {
            TempData["IdCardSettings.Error"] = "No se pudo determinar la escuela del usuario actual.";
            return RedirectToAction("Index");
        }

        model.SchoolId = school.Id;

        var existing = await _context.Set<SchoolIdCardSetting>()
            .FirstOrDefaultAsync(x => x.SchoolId == school.Id);

        if (existing == null)
        {
            model.Id = Guid.NewGuid();
            model.CreatedAt = DateTime.UtcNow;
            model.UpdatedAt = DateTime.UtcNow;
            _context.Add(model);
        }
        else
        {
            existing.TemplateKey = model.TemplateKey;
            existing.PageWidthMm = model.PageWidthMm;
            existing.PageHeightMm = model.PageHeightMm;
            existing.BleedMm = model.BleedMm;
            existing.BackgroundColor = model.BackgroundColor;
            existing.PrimaryColor = model.PrimaryColor;
            existing.TextColor = model.TextColor;
            existing.ShowQr = model.ShowQr;
            existing.ShowPhoto = model.ShowPhoto;
            existing.UpdatedAt = DateTime.UtcNow;
            _context.Update(existing);
        }

        await _context.SaveChangesAsync();
        TempData["Success"] = "Configuración guardada exitosamente.";

        return RedirectToAction("Index");
    }
}
