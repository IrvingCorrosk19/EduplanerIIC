using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SchoolManager.Helpers;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using SchoolManager.ViewModels;

namespace SchoolManager.Controllers;

[Authorize(Roles = "SuperAdmin,superadmin")]
[Route("InstitutionalCredential")]
public class InstitutionalCredentialController : Controller
{
    private readonly IInstitutionalCredentialService _service;
    private readonly IInstitutionalCredentialPdfService _pdfService;
    private readonly IInstitutionalCredentialHtmlCaptureService _htmlCapture;
    private readonly SchoolDbContext _context;
    private readonly ILogger<InstitutionalCredentialController> _logger;

    public InstitutionalCredentialController(
        IInstitutionalCredentialService service,
        IInstitutionalCredentialPdfService pdfService,
        IInstitutionalCredentialHtmlCaptureService htmlCapture,
        SchoolDbContext context,
        ILogger<InstitutionalCredentialController> logger)
    {
        _service = service;
        _pdfService = pdfService;
        _htmlCapture = htmlCapture;
        _context = context;
        _logger = logger;
    }

    [HttpGet("ui")]
    public IActionResult Index() => View();

    [HttpGet("ui/generate/{userId}")]
    public async Task<IActionResult> GenerateView(Guid userId)
    {
        var row = await StaffInstitutionalRoleFilter.WhereIsInstitutionalStaff(_context.Users.AsNoTracking())
            .Where(u => u.Id == userId)
            .Select(u => new { u.SchoolId, u.DocumentId })
            .FirstOrDefaultAsync();

        if (row == null)
        {
            return View("Generate", new InstitutionalCredentialGenerateViewModel
            {
                UserId = userId,
                UserNotFound = true,
                SchoolName = "—"
            });
        }

        if (!row.SchoolId.HasValue)
        {
            return View("Generate", new InstitutionalCredentialGenerateViewModel
            {
                UserId = userId,
                NotEligible = true,
                NotEligibleReason = "El usuario no tiene escuela asignada.",
                SchoolName = "—"
            });
        }

        var schoolId = row.SchoolId.Value;
        var bundle = await _context.Schools.AsNoTracking().IgnoreQueryFilters()
            .Where(s => s.Id == schoolId)
            .Select(s => new
            {
                School = s,
                CardSettings = _context.Set<SchoolIdCardSetting>().AsNoTracking().IgnoreQueryFilters()
                    .Where(x => x.SchoolId == s.Id)
                    .FirstOrDefault()
            })
            .FirstOrDefaultAsync();

        var vm = InstitutionalCredentialGenerateViewModel.ForUser(
            userId,
            bundle?.School,
            bundle?.CardSettings);
        vm.DocumentId = row.DocumentId;
        vm.Card = await _service.GetCurrentCardAsync(userId);
        return View("Generate", vm);
    }

    [HttpGet("ui/print/{userId}")]
    [ResponseCache(NoStore = true, Location = ResponseCacheLocation.None)]
    public async Task<IActionResult> Print(Guid userId)
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userIdClaim == null || !Guid.TryParse(userIdClaim, out var currentUserId))
            return Unauthorized("Usuario no autenticado.");

        var eligible = await StaffInstitutionalRoleFilter.WhereIsInstitutionalStaff(_context.Users.AsNoTracking())
            .AnyAsync(u => u.Id == userId && u.SchoolId != null);
        if (!eligible)
        {
            return new ContentResult
            {
                Content = "Usuario no elegible para credencial institucional.",
                ContentType = "text/plain; charset=utf-8",
                StatusCode = StatusCodes.Status403Forbidden
            };
        }

        try
        {
            var url = $"{Request.Scheme}://{Request.Host}/InstitutionalCredential/ui/generate/{userId}";
            try
            {
                var pdf = await _htmlCapture.GenerateFromUrl(url);
                await MarkCardPrintedAsync(userId);
                return File(pdf, "application/pdf", $"credencial-institucional-{userId:N}.pdf");
            }
            catch (Exception htmlEx)
            {
                _logger.LogWarning(htmlEx,
                    "[InstitutionalCredential] PDF HTML falló; nativo UserId={UserId}", userId);
                var pdf = await _pdfService.GenerateCardPdfAsync(userId, currentUserId);
                await MarkCardPrintedAsync(userId);
                return File(pdf, "application/pdf", $"credencial-institucional-{userId:N}.pdf");
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[InstitutionalCredential] Print error UserId={UserId}", userId);
            return new ContentResult
            {
                Content = "No se pudo generar el PDF: " + ex.Message,
                ContentType = "text/plain; charset=utf-8",
                StatusCode = StatusCodes.Status500InternalServerError
            };
        }
    }

    [HttpPost("api/generate/{userId}")]
    public async Task<IActionResult> GenerateApi(Guid userId)
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userIdClaim == null || !Guid.TryParse(userIdClaim, out var actorId))
            return Unauthorized("Usuario no autenticado");

        try
        {
            var result = await _service.GenerateAsync(userId, actorId);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet("api/list-json")]
    public async Task<IActionResult> ListJson(string? schoolId = null, string? search = null)
    {
        var query = StaffInstitutionalRoleFilter.WhereIsInstitutionalStaff(_context.Users.AsNoTracking())
            .Where(u => u.SchoolId != null);

        if (Guid.TryParse(schoolId, out var sid))
            query = query.Where(u => u.SchoolId == sid);

        if (!string.IsNullOrWhiteSpace(search))
        {
            var p = "%" + search.Trim() + "%";
            query = query.Where(u =>
                EF.Functions.ILike(u.Name, p) ||
                EF.Functions.ILike(u.LastName, p) ||
                (u.Email != null && EF.Functions.ILike(u.Email, p)));
        }

        var rawRows = await query
            .OrderBy(u => u.LastName)
            .ThenBy(u => u.Name)
            .Select(u => new
            {
                u.Id,
                fullName = u.Name + " " + u.LastName,
                u.PhotoUrl,
                u.Role,
                schoolName = u.SchoolNavigation != null ? u.SchoolNavigation.Name : ""
            })
            .Take(500)
            .ToListAsync();

        var rows = rawRows.Select(u => new
        {
            id = u.Id,
            u.fullName,
            photoUrl = u.PhotoUrl,
            role = u.Role,
            roleDisplay = StaffInstitutionalRoleFilter.FormatRoleDisplay(u.Role),
            u.schoolName
        }).ToList();

        return Json(new { data = rows });
    }

    private async Task MarkCardPrintedAsync(Guid userId)
    {
        var cards = await _context.Set<InstitutionalCredentialCard>()
            .Where(c => c.UserId == userId && c.Status == "active")
            .ToListAsync();
        if (cards.Count == 0)
            return;
        var now = DateTime.UtcNow;
        foreach (var c in cards)
        {
            c.IsPrinted = true;
            c.PrintedAt = now;
        }
        await _context.SaveChangesAsync();
    }
}
