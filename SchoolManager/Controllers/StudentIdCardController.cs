using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SchoolManager.Dtos;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using System.Security.Claims;

namespace SchoolManager.Controllers;

[Authorize(Roles = "Admin,admin,SuperAdmin,superadmin,Director,director")]
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

    [HttpGet("ui/generate/{studentId}")]
    public async Task<IActionResult> GenerateView(Guid studentId)
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userIdClaim == null || !Guid.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized("Usuario no autenticado");
        }

        try
        {
            var dto = await _service.GenerateAsync(studentId, userId);
            return View("Generate", dto);
        }
        catch (Exception ex)
        {
            TempData["Error"] = ex.Message;
            return RedirectToAction("Index");
        }
    }

    [HttpGet("ui/scan")]
    public IActionResult Scan() => View();

    [HttpGet("ui/print/{studentId}")]
    public async Task<IActionResult> Print(Guid studentId)
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userIdClaim == null || !Guid.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized("Usuario no autenticado");
        }

        try
        {
            var pdf = await _pdfService.GenerateCardPdfAsync(studentId, userId);
            return File(pdf, "application/pdf", $"carnet-{studentId}.pdf");
        }
        catch (Exception ex)
        {
            TempData["Error"] = ex.Message;
            return RedirectToAction("Index");
        }
    }

    [HttpPost("api/generate/{studentId}")]
    public async Task<IActionResult> GenerateApi(Guid studentId)
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (userIdClaim == null || !Guid.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized("Usuario no autenticado");
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

    [AllowAnonymous]
    [HttpPost("api/scan")]
    public async Task<IActionResult> ScanApi([FromBody] ScanRequestDto dto)
    {
        if (dto == null || string.IsNullOrWhiteSpace(dto.Token))
        {
            return BadRequest(new { message = "Token es requerido" });
        }

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

    [HttpGet("api/list-json")]
    public async Task<IActionResult> ListJson()
    {
        var currentUser = await _currentUserService.GetCurrentUserAsync();
        var schoolId = currentUser?.SchoolId;

        _logger.LogInformation("[StudentIdCard/ListJson] Usuario={UserId} Nombre={Name} SchoolId={SchoolId}",
            currentUser?.Id, currentUser != null ? $"{currentUser.Name} {currentUser.LastName}" : "null", schoolId);

        var query = _context.Users
            .Where(u => u.Role != null && (u.Role.ToLower() == "student" || u.Role.ToLower() == "estudiante"));

        if (schoolId.HasValue)
            query = query.Where(u => u.SchoolId == schoolId.Value);

        var students = await query
            .Include(u => u.StudentAssignments.Where(sa => sa.IsActive))
                .ThenInclude(sa => sa.Grade)
            .Include(u => u.StudentAssignments.Where(sa => sa.IsActive))
                .ThenInclude(sa => sa.Group)
            .Select(u => new
            {
                id = u.Id,
                fullName = $"{u.Name} {u.LastName}",
                grade = u.StudentAssignments.FirstOrDefault(sa => sa.IsActive) != null
                    ? u.StudentAssignments.FirstOrDefault(sa => sa.IsActive)!.Grade.Name
                    : "Sin asignar",
                group = u.StudentAssignments.FirstOrDefault(sa => sa.IsActive) != null
                    ? u.StudentAssignments.FirstOrDefault(sa => sa.IsActive)!.Group.Name
                    : "Sin asignar"
            })
            .ToListAsync();

        _logger.LogInformation("[StudentIdCard/ListJson] Retornando {Count} estudiantes para SchoolId={SchoolId}", students.Count, schoolId);
        return Json(new { data = students });
    }
}
