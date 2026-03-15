using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SchoolManager.Dtos;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;

namespace SchoolManager.Controllers;

/// <summary>Módulo Club de Padres: listado de estudiantes, estado carnet/plataforma, marcar pagado y activar plataforma.</summary>
[Authorize(Roles = "ClubParentsAdmin")]
[Route("ClubParents")]
public class ClubParentsController : Controller
{
    private readonly IClubParentsPaymentService _service;
    private readonly ICurrentUserService _currentUserService;
    private readonly SchoolDbContext _context;
    private readonly ILogger<ClubParentsController> _logger;

    public ClubParentsController(
        IClubParentsPaymentService service,
        ICurrentUserService currentUserService,
        SchoolDbContext context,
        ILogger<ClubParentsController> logger)
    {
        _service = service;
        _currentUserService = currentUserService;
        _context = context;
        _logger = logger;
    }

    /// <summary>GET /ClubParents/Students — Vista listado de estudiantes con filtros.</summary>
    [HttpGet("Students")]
    public IActionResult Students()
    {
        ViewData["Title"] = "Club de Padres — Estudiantes";
        return View();
    }

    /// <summary>GET /ClubParents/Api/GradesAndGroups — Grados y grupos de la escuela para filtros (sin modificar servicios).</summary>
    [HttpGet("Api/GradesAndGroups")]
    public async Task<IActionResult> GetGradesAndGroups()
    {
        var school = await _currentUserService.GetCurrentUserSchoolAsync();
        if (school == null)
            return Ok(new { grades = Array.Empty<object>(), groups = Array.Empty<object>() });

        var grades = await _context.GradeLevels
            .Where(g => g.SchoolId == school.Id)
            .OrderBy(g => g.Name)
            .Select(g => new { id = g.Id, name = g.Name })
            .ToListAsync();
        var groups = await _context.Groups
            .Where(g => g.SchoolId == school.Id)
            .OrderBy(g => g.Name)
            .Select(g => new { id = g.Id, name = g.Name })
            .ToListAsync();
        return Ok(new { grades, groups });
    }

    /// <summary>GET /ClubParents/Api/Students — Lista estudiantes con filtros opcionales gradeId, groupId.</summary>
    [HttpGet("Api/Students")]
    public async Task<IActionResult> GetStudents([FromQuery] Guid? gradeId, [FromQuery] Guid? groupId)
    {
        try
        {
            var list = await _service.GetStudentsAsync(gradeId, groupId);
            return Ok(new { data = list });
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "[ClubParents] GetStudents error");
            return StatusCode(500, new { message = "Error al obtener la lista de estudiantes." });
        }
    }

    /// <summary>GET /ClubParents/Api/Students/{id} — Estado de carnet y plataforma de un estudiante.</summary>
    [HttpGet("Api/Students/{id:guid}")]
    public async Task<IActionResult> GetStudentStatus(Guid id)
    {
        try
        {
            var status = await _service.GetStudentPaymentStatusAsync(id);
            return Ok(status);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "[ClubParents] GetStudentStatus StudentId={StudentId}", id);
            return StatusCode(500, new { message = "Error al obtener el estado." });
        }
    }

    /// <summary>POST /ClubParents/Carnet/MarkPaid — Marcar carnet como Pagado (Pendiente → Pagado).</summary>
    [HttpPost("Carnet/MarkPaid")]
    public async Task<IActionResult> MarkPaid([FromBody] StudentIdRequest request)
    {
        if (request == null || request.StudentId == Guid.Empty)
            return BadRequest(new { message = "StudentId es requerido." });

        try
        {
            await _service.MarkCarnetAsPaidAsync(request.StudentId);
            return Ok(new { success = true, message = "Carnet marcado como pagado." });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[ClubParents] MarkPaid StudentId={StudentId}", request.StudentId);
            return StatusCode(500, new { message = "Error al registrar el pago." });
        }
    }

    /// <summary>POST /ClubParents/Platform/Activate — Activar plataforma (Pendiente → Activo).</summary>
    [HttpPost("Platform/Activate")]
    public async Task<IActionResult> ActivatePlatform([FromBody] StudentIdRequest request)
    {
        if (request == null || request.StudentId == Guid.Empty)
            return BadRequest(new { message = "StudentId es requerido." });

        try
        {
            await _service.ActivatePlatformAsync(request.StudentId);
            return Ok(new { success = true, message = "Plataforma activada." });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[ClubParents] ActivatePlatform StudentId={StudentId}", request.StudentId);
            return StatusCode(500, new { message = "Error al activar la plataforma." });
        }
    }
}
