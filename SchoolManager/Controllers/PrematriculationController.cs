using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using SchoolManager.Dtos;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using SchoolManager.Interfaces;

namespace SchoolManager.Controllers;

[Authorize]
public class PrematriculationController : Controller
{
    private readonly IPrematriculationService _prematriculationService;
    private readonly IPrematriculationPeriodService _periodService;
    private readonly ICurrentUserService _currentUserService;
    private readonly IStudentService _studentService;
    private readonly IGradeLevelService _gradeLevelService;
    private readonly SchoolDbContext _context;
    private readonly ILogger<PrematriculationController> _logger;

    public PrematriculationController(
        IPrematriculationService prematriculationService,
        IPrematriculationPeriodService periodService,
        ICurrentUserService currentUserService,
        IStudentService studentService,
        IGradeLevelService gradeLevelService,
        SchoolDbContext context,
        ILogger<PrematriculationController> logger)
    {
        _prematriculationService = prematriculationService;
        _periodService = periodService;
        _currentUserService = currentUserService;
        _studentService = studentService;
        _gradeLevelService = gradeLevelService;
        _context = context;
        _logger = logger;
    }

    // Vista para estudiantes/acudientes: ver prematrículas del estudiante
    [Authorize(Roles = "acudiente,parent,student,estudiante")]
    public async Task<IActionResult> MyPrematriculations()
    {
        var currentUser = await _currentUserService.GetCurrentUserAsync();
        if (currentUser == null)
            return Unauthorized();

        // Si el usuario es estudiante, buscar prematrículas donde él es el estudiante
        // Si es acudiente, buscar prematrículas donde él es el padre
        var userRole = currentUser.Role?.ToLower() ?? "";
        List<PrematriculationDto> prematriculations;
        
        if (userRole == "student" || userRole == "estudiante")
        {
            // El usuario actual es estudiante, buscar sus propias prematrículas
            prematriculations = await _prematriculationService.GetByStudentAsync(currentUser.Id);
        }
        else
        {
            // El usuario es acudiente/padre, buscar prematrículas de sus hijos
            prematriculations = await _prematriculationService.GetByParentAsync(currentUser.Id);
        }
        
        return View(prematriculations);
    }

    // Vista para estudiantes/acudientes: crear nueva prematrícula
    [Authorize(Roles = "acudiente,parent,student,estudiante")]
    public async Task<IActionResult> Create()
    {
        var currentUser = await _currentUserService.GetCurrentUserAsync();
        if (currentUser?.SchoolId == null)
            return Unauthorized();

        // Verificar si hay un período activo
        var activePeriod = await _periodService.GetActivePeriodAsync(currentUser.SchoolId.Value);
        if (activePeriod == null)
        {
            TempData["ErrorMessage"] = "El período de prematrícula no está disponible";
            return RedirectToAction(nameof(MyPrematriculations));
        }

        ViewBag.ActivePeriod = activePeriod;
        
        var userRole = currentUser.Role?.ToLower() ?? "";
        var currentUserId = await _currentUserService.GetCurrentUserIdAsync();
        ViewBag.CurrentUserId = currentUserId;
        ViewBag.IsStudentUser = (userRole == "student" || userRole == "estudiante");
        
        // Si el usuario es estudiante, solo puede prematricularse a sí mismo
        if (userRole == "student" || userRole == "estudiante")
        {
            ViewBag.Students = new[] { new { Id = currentUser.Id, Name = $"{currentUser.Name} {currentUser.LastName}" } };
        }
        else
        {
            // Si es acudiente, obtener estudiantes asociados (hijos)
            if (currentUserId.HasValue && currentUser.SchoolId.HasValue)
            {
                // Obtener estudiantes de la tabla Students que tengan este usuario como padre
                var studentsFromStudentsTable = await _context.Students
                    .Where(s => s.ParentId == currentUserId.Value)
                    .Select(s => new { s.Id, s.Name })
                    .ToListAsync();
                
                // También buscar en Users estudiantes de la misma escuela
                // (esto es un fallback si no están en la tabla Students)
                var studentsFromUsers = await _context.Users
                    .Where(u => (u.Role.ToLower() == "student" || u.Role.ToLower() == "estudiante")
                        && u.SchoolId == currentUser.SchoolId.Value)
                    .Select(u => new { Id = u.Id, Name = $"{u.Name} {u.LastName}" })
                    .ToListAsync();
                
                // Si hay estudiantes en la tabla Students con ParentId, usarlos
                // Si no, usar todos los estudiantes de la escuela (mejorar con relación Parent-Student)
                ViewBag.Students = studentsFromStudentsTable.Any() ? studentsFromStudentsTable : studentsFromUsers;
            }
        }
        
        // Obtener grados disponibles
        var grades = await _gradeLevelService.GetAllAsync();
        ViewBag.Grades = grades;

        return View();
    }

    [HttpPost]
    [Authorize(Roles = "acudiente,parent,student,estudiante")]
    public async Task<IActionResult> Create(PrematriculationCreateDto dto)
    {
        if (!ModelState.IsValid)
            return View(dto);

        var currentUser = await _currentUserService.GetCurrentUserAsync();
        if (currentUser == null)
            return Unauthorized();

        try
        {
            // Validar que el período esté activo
            var activePeriod = await _periodService.GetActivePeriodAsync(currentUser.SchoolId!.Value);
            if (activePeriod == null)
            {
                ModelState.AddModelError("", "El período de prematrícula no está disponible");
                return View(dto);
            }

            dto.PrematriculationPeriodId = activePeriod.Id;

            // Validar condición académica
            var isValid = await _prematriculationService.ValidateAcademicConditionAsync(dto.StudentId);
            if (!isValid)
            {
                var failedCount = await _prematriculationService.GetFailedSubjectsCountAsync(dto.StudentId);
                ModelState.AddModelError("", 
                    $"El estudiante no puede participar en la prematrícula por exceder el límite de materias reprobadas ({failedCount} materias reprobadas)");
                return View(dto);
            }

            // Si el usuario es estudiante y se prematricula a sí mismo, ParentId será null
            // Si es acudiente prematriculando a su hijo, usar currentUser.Id como parentId
            var userRole = currentUser.Role?.ToLower() ?? "";
            Guid? parentId = null;
            
            // Si el estudiante se prematricula a sí mismo (mismo ID), no hay parentId
            if (dto.StudentId == currentUser.Id)
            {
                // El estudiante se prematricula a sí mismo, ParentId es null
                parentId = null;
            }
            else if (userRole == "parent" || userRole == "acudiente")
            {
                // Es acudiente prematriculando a su hijo
                parentId = currentUser.Id;
            }
            
            var prematriculation = await _prematriculationService.CreatePrematriculationAsync(dto, parentId);
            
            TempData["SuccessMessage"] = $"Prematrícula creada exitosamente. Código: {prematriculation.PrematriculationCode}";
            return RedirectToAction(nameof(MyPrematriculations));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al crear prematrícula");
            ModelState.AddModelError("", "Error al crear la prematrícula: " + ex.Message);
            return View(dto);
        }
    }

    // Obtener grupos disponibles para un grado (AJAX)
    [HttpGet]
    [Authorize(Roles = "acudiente,parent,student,estudiante,admin,superadmin")]
    public async Task<IActionResult> GetAvailableGroups(Guid? gradeId)
    {
        var currentUser = await _currentUserService.GetCurrentUserAsync();
        if (currentUser?.SchoolId == null)
            return Unauthorized();

        var groups = await _prematriculationService.GetAvailableGroupsAsync(currentUser.SchoolId.Value, gradeId);
        return Json(groups);
    }

    // Vista para administradores: ver todas las prematrículas
    [Authorize(Roles = "admin,superadmin")]
    public async Task<IActionResult> Index()
    {
        var currentUser = await _currentUserService.GetCurrentUserAsync();
        if (currentUser?.SchoolId == null)
            return Unauthorized();

        var activePeriod = await _periodService.GetActivePeriodAsync(currentUser.SchoolId.Value);
        if (activePeriod == null)
        {
            TempData["InfoMessage"] = "No hay un período de prematrícula activo";
            return View(new List<PrematriculationDto>());
        }

        var prematriculations = await _prematriculationService.GetByPeriodAsync(activePeriod.Id);
        return View(prematriculations);
    }

    // Vista para administradores: confirmar matrícula
    [HttpPost]
    [Authorize(Roles = "admin,superadmin")]
    public async Task<IActionResult> ConfirmMatriculation(Guid id)
    {
        try
        {
            await _prematriculationService.ConfirmMatriculationAsync(id);
            TempData["SuccessMessage"] = "Matrícula confirmada exitosamente";
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al confirmar matrícula");
            TempData["ErrorMessage"] = "Error al confirmar la matrícula: " + ex.Message;
        }

        return RedirectToAction(nameof(Index));
    }

    // Vista para docentes: ver estudiantes prematriculados/matriculados por grupo
    [Authorize(Roles = "teacher,admin,superadmin")]
    public async Task<IActionResult> ByGroup(Guid groupId)
    {
        var prematriculations = await _prematriculationService.GetByGroupAsync(groupId);
        return View(prematriculations);
    }

    // Comprobante de matrícula (PDF/Vista imprimible)
    [Authorize]
    public async Task<IActionResult> Certificate(Guid id)
    {
        var prematriculation = await _prematriculationService.GetByIdAsync(id);
        if (prematriculation == null)
            return NotFound();

        // Verificar que el usuario tenga acceso (acudiente, estudiante o admin)
        var currentUser = await _currentUserService.GetCurrentUserAsync();
        if (currentUser == null)
            return Unauthorized();

        var userRole = currentUser.Role?.ToLower() ?? "";
        var isAuthorized = userRole == "admin" || userRole == "superadmin" ||
                          prematriculation.StudentId == currentUser.Id ||
                          prematriculation.ParentId == currentUser.Id;

        if (!isAuthorized)
            return Forbid();

        // Solo mostrar si está matriculado
        if (prematriculation.Status != "Matriculado")
        {
            TempData["ErrorMessage"] = "Solo se puede generar el comprobante de matrícula para estudiantes matriculados";
            return RedirectToAction(nameof(Details), new { id });
        }

        return View(prematriculation);
    }

    // Detalles de una prematrícula
    public async Task<IActionResult> Details(Guid id)
    {
        var prematriculation = await _prematriculationService.GetByIdAsync(id);
        if (prematriculation == null)
            return NotFound();

        var dto = new PrematriculationDto
        {
            Id = prematriculation.Id,
            StudentId = prematriculation.StudentId,
            StudentName = $"{prematriculation.Student.Name} {prematriculation.Student.LastName}",
            StudentDocumentId = prematriculation.Student.DocumentId ?? "",
            Status = prematriculation.Status,
            PrematriculationCode = prematriculation.PrematriculationCode,
            FailedSubjectsCount = prematriculation.FailedSubjectsCount,
            AcademicConditionValid = prematriculation.AcademicConditionValid,
            CreatedAt = prematriculation.CreatedAt,
            PaymentDate = prematriculation.PaymentDate,
            MatriculationDate = prematriculation.MatriculationDate
        };

        return View(dto);
    }
}

