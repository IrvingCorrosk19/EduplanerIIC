using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;
using SchoolManager.Dtos;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using SchoolManager.ViewModels;
using System.Security.Claims;

namespace SchoolManager.Controllers;

[Authorize(Roles = "SuperAdmin,superadmin")]
[Route("StudentIdCard")]
public class StudentIdCardController : Controller
{
    private readonly IStudentIdCardService _service;
    private readonly IStudentIdCardPdfService _pdfService;
    private readonly IStudentIdCardHtmlCaptureService _htmlCapture;
    private readonly SchoolDbContext _context;
    private readonly ICurrentUserService _currentUserService;
    private readonly ILogger<StudentIdCardController> _logger;

    public StudentIdCardController(
        IStudentIdCardService service,
        IStudentIdCardPdfService pdfService,
        IStudentIdCardHtmlCaptureService htmlCapture,
        SchoolDbContext context,
        ICurrentUserService currentUserService,
        ILogger<StudentIdCardController> logger)
    {
        _service = service;
        _pdfService = pdfService;
        _htmlCapture = htmlCapture;
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
    /// <summary>
    /// Vista previa del carnet: escuela y configuración siempre desde el estudiante (SchoolId del alumno),
    /// no desde la escuela del usuario autenticado (corrige SuperAdmin sin escuela).
    /// </summary>
    [HttpGet("ui/generate/{studentId}")]
    public async Task<IActionResult> GenerateView(Guid studentId)
    {
        // Comparación traducible a SQL (Equals con StringComparison no lo es en EF Core)
        var student = await _context.Users.AsNoTracking()
            .FirstOrDefaultAsync(u => u.Id == studentId &&
                u.Role != null &&
                (u.Role.ToLower() == "student" || u.Role.ToLower() == "estudiante"));

        if (student == null)
        {
            return View("Generate", new StudentIdCardGenerateViewModel
            {
                StudentId = studentId,
                StudentNotFound = true,
                SchoolName = "—"
            });
        }

        // PAY-GATE: solo estudiantes con carnet pagado pueden acceder a la vista
        var hasPaidView = await _context.StudentPaymentAccesses
            .AnyAsync(spa => spa.StudentId == studentId && spa.CarnetStatus == "Pagado");
        if (!hasPaidView)
        {
            _logger.LogWarning(
                "[StudentIdCard] GenerateView denegado: pago pendiente StudentId={StudentId}", studentId);
            return RedirectToAction(nameof(Index));
        }

        School? schoolEntity = null;
        if (student.SchoolId.HasValue)
        {
            schoolEntity = await _context.Schools.AsNoTracking().IgnoreQueryFilters()
                .FirstOrDefaultAsync(s => s.Id == student.SchoolId.Value);
        }

        var cardSettings = student.SchoolId.HasValue
            ? await _context.Set<SchoolIdCardSetting>().AsNoTracking().IgnoreQueryFilters()
                .FirstOrDefaultAsync(x => x.SchoolId == student.SchoolId.Value)
            : null;

        var enabledTemplateFields = student.SchoolId.HasValue
            ? await _context.Set<IdCardTemplateField>().AsNoTracking()
                .CountAsync(x => x.SchoolId == student.SchoolId.Value && x.IsEnabled)
            : 0;

        var vm = StudentIdCardGenerateViewModel.ForStudent(studentId, schoolEntity, cardSettings);
        vm.UsesCustomPdfTemplate = enabledTemplateFields > 0;
        vm.EmergencyContactName = student.EmergencyContactName;
        vm.EmergencyContactPhone = student.EmergencyContactPhone;
        vm.Allergies = student.Allergies;

        // Datos para bloques condicionales del frente (sincronizados con PDF)
        vm.DocumentId = student.DocumentId;
        vm.PolicyNumber = string.IsNullOrWhiteSpace(schoolEntity?.PolicyNumber) ? null : schoolEntity!.PolicyNumber.Trim();
        vm.AcademicYear = student.SchoolId.HasValue
            ? await _context.StudentAssignments
                .Where(a => a.StudentId == studentId && a.IsActive)
                .Select(a => a.AcademicYear == null ? null : a.AcademicYear.Name)
                .FirstOrDefaultAsync()
            : null;

        vm.Card = await _service.GetCurrentCardAsync(studentId);
        return View("Generate", vm);
    }

    [HttpGet("ui/scan")]
    public IActionResult Scan() => View();

    /// <summary>
    /// Descarga del PDF del carnet (frente/reverso según configuración). Errores en texto plano para que fetch en la vista pueda mostrarlos.
    /// </summary>
    [HttpGet("ui/print/{studentId}")]
    [ResponseCache(NoStore = true, Location = ResponseCacheLocation.None)]
    public async Task<IActionResult> Print(Guid studentId)
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userIdClaim == null || !Guid.TryParse(userIdClaim, out var userId))
            return Unauthorized("Usuario no autenticado.");

        // PAY-GATE: bloquear generación de PDF sin pago confirmado
        var hasPaidPdf = await _context.StudentPaymentAccesses
            .AnyAsync(x => x.StudentId == studentId && x.CarnetStatus == "Pagado");
        if (!hasPaidPdf)
        {
            _logger.LogWarning(
                "[StudentIdCard] Print denegado: pago pendiente StudentId={StudentId}", studentId);
            return new ContentResult
            {
                Content = "Acceso denegado: el estudiante no ha pagado el carnet.",
                ContentType = "text/plain; charset=utf-8",
                StatusCode = StatusCodes.Status403Forbidden
            };
        }

        try
        {
            var url = $"{Request.Scheme}://{Request.Host}/StudentIdCard/ui/generate/{studentId}";
            try
            {
                var pdf = await _htmlCapture.GenerateFromUrl(url);
                return File(pdf, "application/pdf", $"carnet-{studentId:N}.pdf");
            }
            catch (Exception htmlEx)
            {
                // En Linux/Docker (p. ej. Render) a veces faltan .so de Chromium; intentar PDF nativo (Skia/QuestPDF).
                _logger.LogWarning(htmlEx,
                    "[StudentIdCard] PDF vía HTML/Chromium falló; usando generación nativa. StudentId={StudentId}",
                    studentId);
                var pdf = await _pdfService.GenerateCardPdfAsync(studentId, userId);
                return File(pdf, "application/pdf", $"carnet-{studentId:N}.pdf");
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex,
                "[StudentIdCard] Print/PDF error StudentId={StudentId} UserId={UserId}: {Message}",
                studentId, userId, ex.Message);
            return new ContentResult
            {
                Content = "No se pudo generar el PDF: " + ex.Message,
                ContentType = "text/plain; charset=utf-8",
                StatusCode = StatusCodes.Status500InternalServerError
            };
        }
    }

    [HttpPost("api/generate/{studentId}")]
    public async Task<IActionResult> GenerateApi(Guid studentId)
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userIdClaim == null || !Guid.TryParse(userIdClaim, out var userId))
            return Unauthorized("Usuario no autenticado");

        // PAY-GATE doble guard (controller + service) — defensa en profundidad
        var hasPaidGen = await _context.StudentPaymentAccesses
            .AnyAsync(x => x.StudentId == studentId && x.CarnetStatus == "Pagado");
        if (!hasPaidGen)
        {
            _logger.LogWarning(
                "[StudentIdCard] GenerateApi denegado: pago pendiente StudentId={StudentId}", studentId);
            return BadRequest(new { message = "El estudiante no ha pagado el carnet." });
        }

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
    public async Task<IActionResult> ListJson(string? grade = null, string? group = null, string? shift = null)
    {
        var currentUser = await _currentUserService.GetCurrentUserAsync();
        var schoolId = currentUser?.SchoolId;

        // SuperAdmin puede tener SchoolId en su perfil (p. ej. escuela de referencia) pero debe ver
        // todos los estudiantes del sistema para emitir carnets en cualquier institución.
        var isSuperAdmin = currentUser?.Role != null &&
            string.Equals(currentUser.Role, "superadmin", StringComparison.OrdinalIgnoreCase);

        _logger.LogInformation(
            "[StudentIdCard/ListJson] Usuario={UserId} Nombre={Name} SchoolId={SchoolId} IsSuperAdmin={IsSuperAdmin}",
            currentUser?.Id,
            currentUser != null ? $"{currentUser.Name} {currentUser.LastName}" : "null",
            schoolId,
            isSuperAdmin);

        // PAY-GATE: solo estudiantes con CarnetStatus = "Pagado" en StudentPaymentAccess
        var query = _context.Users
            .Where(u => u.Role != null && (u.Role.ToLower() == "student" || u.Role.ToLower() == "estudiante"))
            .Where(u => _context.StudentPaymentAccesses
                .Any(spa => spa.StudentId == u.Id && spa.CarnetStatus == "Pagado"));

        if (schoolId.HasValue && !isSuperAdmin)
            query = query.Where(u => u.SchoolId == schoolId.Value);

        var gradeFilter = string.IsNullOrWhiteSpace(grade) ? null : grade.Trim();
        var groupFilter = string.IsNullOrWhiteSpace(group) ? null : group.Trim();
        var shiftFilter = string.IsNullOrWhiteSpace(shift) ? null : shift.Trim();

        // Filtros por grado/grupo/jornada sobre asignación activa del estudiante.
        if (!string.IsNullOrWhiteSpace(gradeFilter))
        {
            query = query.Where(u => u.StudentAssignments
                .Any(sa => sa.IsActive && sa.Grade != null && sa.Grade.Name == gradeFilter));
        }
        if (!string.IsNullOrWhiteSpace(groupFilter))
        {
            query = query.Where(u => u.StudentAssignments
                .Any(sa => sa.IsActive && sa.Group != null && sa.Group.Name == groupFilter));
        }
        if (!string.IsNullOrWhiteSpace(shiftFilter))
        {
            query = query.Where(u => u.StudentAssignments
                .Any(sa => sa.IsActive && sa.Shift != null && sa.Shift.Name == shiftFilter));
        }

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
                    .FirstOrDefault() ?? "Sin asignar",
                shift = u.StudentAssignments
                    .Where(sa => sa.IsActive)
                    .Select(sa => sa.Shift != null ? sa.Shift.Name : null)
                    .FirstOrDefault() ?? "Sin jornada"
            })
            .ToListAsync();

        _logger.LogInformation(
            "[StudentIdCard/ListJson] Retornando {Count} estudiantes para SchoolId={SchoolId}",
            students.Count, schoolId);

        return Json(new { data = students });
    }

    [HttpGet("api/list-filters")]
    public async Task<IActionResult> ListFilters()
    {
        var currentUser = await _currentUserService.GetCurrentUserAsync();
        var schoolId = currentUser?.SchoolId;
        var isSuperAdmin = currentUser?.Role != null &&
            string.Equals(currentUser.Role, "superadmin", StringComparison.OrdinalIgnoreCase);

        var query = _context.Users
            .Where(u => u.Role != null && (u.Role.ToLower() == "student" || u.Role.ToLower() == "estudiante"))
            .Where(u => _context.StudentPaymentAccesses
                .Any(spa => spa.StudentId == u.Id && spa.CarnetStatus == "Pagado"));

        if (schoolId.HasValue && !isSuperAdmin)
            query = query.Where(u => u.SchoolId == schoolId.Value);

        var data = await query
            .Select(u => new
            {
                grade = u.StudentAssignments
                    .Where(sa => sa.IsActive)
                    .Select(sa => sa.Grade.Name)
                    .FirstOrDefault(),
                group = u.StudentAssignments
                    .Where(sa => sa.IsActive)
                    .Select(sa => sa.Group.Name)
                    .FirstOrDefault(),
                shift = u.StudentAssignments
                    .Where(sa => sa.IsActive)
                    .Select(sa => sa.Shift != null ? sa.Shift.Name : null)
                    .FirstOrDefault()
            })
            .ToListAsync();

        var grades = data.Select(x => x.grade).Where(x => !string.IsNullOrWhiteSpace(x)).Distinct().OrderBy(x => x).ToList();
        var groups = data.Select(x => x.group).Where(x => !string.IsNullOrWhiteSpace(x)).Distinct().OrderBy(x => x).ToList();
        var shifts = data.Select(x => x.shift).Where(x => !string.IsNullOrWhiteSpace(x)).Distinct().OrderBy(x => x).ToList();

        return Json(new { grades, groups, shifts });
    }
}
