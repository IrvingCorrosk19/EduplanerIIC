using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;
using SchoolManager.Dtos;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using System.Security.Claims;

namespace SchoolManager.Controllers;

[Authorize(Roles = "SuperAdmin,superadmin")]
[Route("StudentIdCard")]
public class StudentIdCardController : Controller
{
    private readonly IStudentIdCardService _service;
    private readonly IStudentIdCardPdfService _pdfService;
    private readonly SchoolDbContext _context;
    private readonly ICurrentUserService _currentUserService;
    private readonly ILogger<StudentIdCardController> _logger;

    public StudentIdCardController(
        IStudentIdCardService service,
        IStudentIdCardPdfService pdfService,
        SchoolDbContext context,
        ICurrentUserService currentUserService,
        ILogger<StudentIdCardController> logger)
    {
        _service = service;
        _pdfService = pdfService;
        _context = context;
        _currentUserService = currentUserService;
        _logger = logger;
    }

    [HttpGet("ui")]
    public IActionResult Index() => View();

    /// <summary>
    /// BUG-2 fix: el GET solo lee y muestra el carnet actual — NO genera ni modifica estado.
    /// La generación ocurre exclusivamente vía POST a /api/generate/{studentId}.
    /// </summary>
    [HttpGet("ui/generate/{studentId}")]
    public async Task<IActionResult> GenerateView(Guid studentId)
    {
        var school = await _currentUserService.GetCurrentUserSchoolAsync();
        ViewBag.SchoolName = school?.Name ?? "SchoolManager";
        ViewBag.SchoolLogoUrl = school?.LogoUrl;
        ViewBag.StudentId = studentId;
        ViewBag.BackgroundImageUrl = "/uploads/idcards/backgrounds/default.png";

        // Configuración del carnet para vista previa (orientación, mostrar QR/foto)
        var cardSettings = school != null
            ? await _context.Set<SchoolIdCardSetting>().AsNoTracking().IgnoreQueryFilters()
                .FirstOrDefaultAsync(x => x.SchoolId == school.Id)
            : null;
        ViewBag.IdCardOrientation = cardSettings?.Orientation ?? "Vertical";
        ViewBag.IdCardShowQr = cardSettings?.ShowQr ?? true;
        ViewBag.IdCardShowPhoto = cardSettings?.ShowPhoto ?? true;
        // Colores de configuración para que la vista previa web refleje los ajustes reales del carnet
        ViewBag.IdCardPrimaryColor = cardSettings?.PrimaryColor ?? "#0D6EFD";
        ViewBag.IdCardBackgroundColor = cardSettings?.BackgroundColor ?? "#FFFFFF";
        ViewBag.IdCardTextColor = cardSettings?.TextColor ?? "#111111";

        // GetCurrentCardAsync nunca revoca ni crea; es idempotente y seguro en GET
        var dto = await _service.GetCurrentCardAsync(studentId);
        return View("Generate", dto); // dto puede ser null → vista muestra estado "sin carnet"
    }

    [HttpGet("ui/scan")]
    public IActionResult Scan() => View();

    [HttpGet("ui/print/{studentId}")]
    public async Task<IActionResult> Print(Guid studentId)
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userIdClaim == null || !Guid.TryParse(userIdClaim, out var userId))
            return Unauthorized("Usuario no autenticado");

        try
        {
            var pdf = await _pdfService.GenerateCardPdfAsync(studentId, userId);
            return File(pdf, "application/pdf", $"carnet-{studentId}.pdf");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex,
                "[StudentIdCard] Print/PDF error StudentId={StudentId} UserId={UserId}: {Message}",
                studentId, userId, ex.Message);
            TempData["Error"] = ex.Message;
            return RedirectToAction("Index");
        }
    }

    [HttpPost("api/generate/{studentId}")]
    public async Task<IActionResult> GenerateApi(Guid studentId)
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userIdClaim == null || !Guid.TryParse(userIdClaim, out var userId))
            return Unauthorized("Usuario no autenticado");

        try
        {
            var result = await _service.GenerateAsync(studentId, userId);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Endpoint de escaneo QR. AllowAnonymous para compatibilidad con la APK móvil.
    /// CRÍTICO-1 fix: el rol se extrae del JWT autenticado (Cookie o Bearer token de la APK),
    /// NUNCA del cuerpo del request. Así un atacante no puede falsificar su rol.
    /// SEG-2: rate limiting aplicado vía política "ScanApiPolicy" (configurada en Program.cs).
    /// </summary>
    [AllowAnonymous]
    [EnableRateLimiting("ScanApiPolicy")]
    [HttpPost("api/scan")]
    public async Task<IActionResult> ScanApi([FromBody] ScanRequestDto dto)
    {
        if (dto == null || string.IsNullOrWhiteSpace(dto.Token))
            return BadRequest(new { message = "Token es requerido" });

        // CRÍTICO-1 fix: poblar AuthenticatedRole desde el JWT del usuario autenticado.
        // Funciona con Cookie auth (portal web) y Bearer token (ApiBearerTokenMiddleware para APK).
        // Si la petición es anónima, AuthenticatedRole queda null → canSeeSensitiveData = false.
        dto.AuthenticatedRole = User.Identity?.IsAuthenticated == true
            ? User.FindFirst(ClaimTypes.Role)?.Value
            : null;

        try
        {
            var result = await _service.ScanAsync(dto);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// SCALE-4 fix: proyección SQL eficiente — sin doble evaluación de FirstOrDefault.
    /// </summary>
    [HttpGet("api/list-json")]
    public async Task<IActionResult> ListJson()
    {
        var currentUser = await _currentUserService.GetCurrentUserAsync();
        var schoolId = currentUser?.SchoolId;

        _logger.LogInformation(
            "[StudentIdCard/ListJson] Usuario={UserId} Nombre={Name} SchoolId={SchoolId}",
            currentUser?.Id,
            currentUser != null ? $"{currentUser.Name} {currentUser.LastName}" : "null",
            schoolId);

        var query = _context.Users
            .Where(u => u.Role != null && (u.Role.ToLower() == "student" || u.Role.ToLower() == "estudiante"));

        if (schoolId.HasValue)
            query = query.Where(u => u.SchoolId == schoolId.Value);

        // SCALE-4 fix: usar Select anidado para que EF traduzca a subqueries SQL eficientes
        var students = await query
            .Select(u => new
            {
                id = u.Id,
                fullName = $"{u.Name} {u.LastName}",
                grade = u.StudentAssignments
                    .Where(sa => sa.IsActive)
                    .Select(sa => sa.Grade.Name)
                    .FirstOrDefault() ?? "Sin asignar",
                group = u.StudentAssignments
                    .Where(sa => sa.IsActive)
                    .Select(sa => sa.Group.Name)
                    .FirstOrDefault() ?? "Sin asignar"
            })
            .ToListAsync();

        _logger.LogInformation(
            "[StudentIdCard/ListJson] Retornando {Count} estudiantes para SchoolId={SchoolId}",
            students.Count, schoolId);

        return Json(new { data = students });
    }
}
