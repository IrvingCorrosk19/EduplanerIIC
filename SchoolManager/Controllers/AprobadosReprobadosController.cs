using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SchoolManager.Services.Interfaces;
using SchoolManager.ViewModels;
using System.Security.Claims;

namespace SchoolManager.Controllers
{
    [Authorize(Roles = "admin,director,teacher")]
    public class AprobadosReprobadosController : Controller
    {
        private readonly IAprobadosReprobadosService _aprobadosReprobadosService;
        private readonly ICurrentUserService _currentUserService;
        private readonly ISuperAdminService _superAdminService;
        private readonly ILogger<AprobadosReprobadosController> _logger;

        public AprobadosReprobadosController(
            IAprobadosReprobadosService aprobadosReprobadosService,
            ICurrentUserService currentUserService,
            ISuperAdminService superAdminService,
            ILogger<AprobadosReprobadosController> logger)
        {
            _aprobadosReprobadosService = aprobadosReprobadosService;
            _currentUserService = currentUserService;
            _superAdminService = superAdminService;
            _logger = logger;
        }

        private static bool IsTeacherRole(string? role) =>
            string.Equals(role, "teacher", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(role, "docente", StringComparison.OrdinalIgnoreCase);

        private static Guid? GetTeacherScopeId(Models.User? user) =>
            user != null && IsTeacherRole(user.Role) ? user.Id : null;

        [HttpGet]
        public async Task<IActionResult> Index()
        {
            try
            {
                var currentUser = await _currentUserService.GetCurrentUserAsync();
                if (currentUser?.SchoolId == null)
                {
                    TempData["Error"] = "No se pudo obtener la informaci?n de la escuela.";
                    return RedirectToAction("Index", "Home");
                }

                ViewBag.TrimestresDisponibles = await _aprobadosReprobadosService.ObtenerTrimestresDisponiblesAsync(currentUser.SchoolId.Value);
                ViewBag.CurrentUser = currentUser;
                ViewBag.EsDocente = GetTeacherScopeId(currentUser).HasValue;

                return View(new AprobadosReprobadosFiltroViewModel());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error cargando p?gina de reportes");
                TempData["Error"] = "Error al cargar la p?gina.";
                return RedirectToAction("Index", "Home");
            }
        }

        [HttpPost]
        public async Task<IActionResult> GenerarReporte(AprobadosReprobadosFiltroViewModel filtro)
        {
            try
            {
                var currentUser = await _currentUserService.GetCurrentUserAsync();
                if (currentUser?.SchoolId == null)
                    return Json(new { success = false, message = "No se pudo obtener la informaci?n de la escuela" });

                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage);
                    return Json(new { success = false, message = string.Join(", ", errors) });
                }

                if (string.IsNullOrEmpty(filtro.Trimestre))
                {
                    return Json(new { success = false, message = "Debe seleccionar un trimestre (o todos los trimestres)" });
                }

                if (string.IsNullOrEmpty(filtro.NivelEducativo))
                {
                    return Json(new { success = false, message = "Debe seleccionar un nivel (grado)" });
                }

                var reporte = await _aprobadosReprobadosService.GenerarReporteAsync(
                    currentUser.SchoolId.Value,
                    filtro.Trimestre,
                    filtro.NivelEducativo,
                    filtro.MateriaId,
                    filtro.GroupId,
                    filtro.GradeLevelId,
                    GetTeacherScopeId(currentUser));

                reporte.ProfesorCoordinador = $"{currentUser.Name} {currentUser.LastName}";
                return Json(new { success = true, data = reporte });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Json(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generando reporte");
                return Json(new { success = false, message = $"Error: {ex.Message}" });
            }
        }

        [HttpPost]
        [Authorize(Roles = "Admin,Director,admin,director")]
        public async Task<IActionResult> PrepararDatosParaReporte()
        {
            try
            {
                var currentUser = await _currentUserService.GetCurrentUserAsync();
                if (currentUser?.SchoolId == null)
                    return Json(new { success = false, message = "No se pudo obtener la informaci?n de la escuela." });

                var (success, message) = await _aprobadosReprobadosService.PrepararDatosParaReporteAsync(currentUser.SchoolId.Value);
                return Json(new { success, message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error preparando datos para reporte");
                return Json(new { success = false, message = $"Error: {ex.Message}" });
            }
        }

        [HttpGet]
        public async Task<IActionResult> VistaPrevia(
            string trimestre, string nivelEducativo, Guid materiaId, Guid groupId, Guid gradeLevelId)
        {
            try
            {
                var currentUser = await _currentUserService.GetCurrentUserAsync();
                if (currentUser?.SchoolId == null)
                {
                    TempData["Error"] = "No se pudo obtener la informaci?n de la escuela.";
                    return RedirectToAction("Index");
                }

                var reporte = await _aprobadosReprobadosService.GenerarReporteAsync(
                    currentUser.SchoolId.Value,
                    trimestre,
                    nivelEducativo,
                    materiaId,
                    groupId,
                    gradeLevelId,
                    GetTeacherScopeId(currentUser));

                reporte.ProfesorCoordinador = $"{currentUser.Name} {currentUser.LastName}";
                return View(reporte);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generando vista previa");
                TempData["Error"] = ex.Message;
                return RedirectToAction("Index");
            }
        }

        [HttpGet]
        public async Task<IActionResult> ExportarPdf(
            string trimestre, string nivelEducativo, Guid materiaId, Guid groupId, Guid gradeLevelId)
        {
            try
            {
                var currentUser = await _currentUserService.GetCurrentUserAsync();
                if (currentUser?.SchoolId == null)
                    return BadRequest("No se pudo obtener la informaci?n de la escuela");

                var reporte = await _aprobadosReprobadosService.GenerarReporteAsync(
                    currentUser.SchoolId.Value,
                    trimestre,
                    nivelEducativo,
                    materiaId,
                    groupId,
                    gradeLevelId,
                    GetTeacherScopeId(currentUser));

                reporte.ProfesorCoordinador = $"{currentUser.Name} {currentUser.LastName}";

                byte[]? logoBytes = null;
                if (!string.IsNullOrWhiteSpace(reporte.LogoUrl) &&
                    !reporte.LogoUrl.StartsWith("http://", StringComparison.OrdinalIgnoreCase) &&
                    !reporte.LogoUrl.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
                    logoBytes = await _superAdminService.GetLogoAsync(reporte.LogoUrl);

                var pdfBytes = await _aprobadosReprobadosService.ExportarAPdfAsync(reporte, logoBytes);
                return File(pdfBytes, "application/pdf", $"Reporte_Aprobados_Reprobados_{trimestre}.pdf");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error exportando a PDF");
                TempData["Error"] = "Error al exportar el reporte.";
                return RedirectToAction("Index");
            }
        }

        [HttpGet]
        public async Task<IActionResult> ExportarExcel(
            string trimestre, string nivelEducativo, Guid materiaId, Guid groupId, Guid gradeLevelId)
        {
            try
            {
                var currentUser = await _currentUserService.GetCurrentUserAsync();
                if (currentUser?.SchoolId == null)
                    return BadRequest("No se pudo obtener la informaci?n de la escuela");

                var reporte = await _aprobadosReprobadosService.GenerarReporteAsync(
                    currentUser.SchoolId.Value,
                    trimestre,
                    nivelEducativo,
                    materiaId,
                    groupId,
                    gradeLevelId,
                    GetTeacherScopeId(currentUser));

                reporte.ProfesorCoordinador = $"{currentUser.Name} {currentUser.LastName}";
                var excelBytes = await _aprobadosReprobadosService.ExportarAExcelAsync(reporte);

                return File(excelBytes, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                    $"Reporte_Aprobados_Reprobados_{trimestre}.xlsx");
            }
            catch (NotImplementedException)
            {
                TempData["Error"] = "La exportaci?n a Excel a?n no est? disponible.";
                return RedirectToAction("Index");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error exportando a Excel");
                TempData["Error"] = "Error al exportar el reporte.";
                return RedirectToAction("Index");
            }
        }

        [HttpGet]
        public async Task<IActionResult> ObtenerNivelesFiltro()
        {
            try
            {
                var currentUser = await _currentUserService.GetCurrentUserAsync();
                if (currentUser?.SchoolId == null)
                    return Json(new { success = false, message = "No se pudo obtener la informaci?n de la escuela" });

                var niveles = await _aprobadosReprobadosService.ObtenerNivelesFiltroAsync(
                    currentUser.SchoolId.Value, GetTeacherScopeId(currentUser));

                return Json(new
                {
                    success = true,
                    data = niveles.Select(n => new { id = n.Id, nombre = n.Nombre })
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error obteniendo niveles filtro");
                return Json(new { success = false, message = "Error al obtener niveles" });
            }
        }

        [HttpGet]
        public async Task<IActionResult> ObtenerMateriasFiltro(string? nivelEducativo)
        {
            try
            {
                var currentUser = await _currentUserService.GetCurrentUserAsync();
                if (currentUser?.SchoolId == null)
                    return Json(new { success = false, message = "No se pudo obtener la informaci?n de la escuela" });

                if (string.IsNullOrWhiteSpace(nivelEducativo))
                    return Json(new { success = false, message = "Seleccione primero un grado/nivel" });

                var materias = await _aprobadosReprobadosService.ObtenerMateriasFiltroAsync(
                    currentUser.SchoolId.Value, nivelEducativo, GetTeacherScopeId(currentUser));

                return Json(new { success = true, data = materias.Select(m => new { id = m.Id, nombre = m.Nombre }) });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error obteniendo materias filtro");
                return Json(new { success = false, message = "Error al obtener materias" });
            }
        }

        [HttpGet]
        public async Task<IActionResult> ObtenerGruposFiltro(Guid materiaId, string? nivelEducativo)
        {
            try
            {
                var currentUser = await _currentUserService.GetCurrentUserAsync();
                if (currentUser?.SchoolId == null)
                    return Json(new { success = false, message = "No se pudo obtener la informaci?n de la escuela" });

                if (string.IsNullOrWhiteSpace(nivelEducativo))
                    return Json(new { success = false, message = "Seleccione primero un grado/nivel" });

                var grupos = await _aprobadosReprobadosService.ObtenerGruposFiltroAsync(
                    currentUser.SchoolId.Value, materiaId, nivelEducativo, GetTeacherScopeId(currentUser));

                return Json(new
                {
                    success = true,
                    data = grupos.Select(g => new
                    {
                        subjectId = g.SubjectId,
                        groupId = g.GroupId,
                        gradeLevelId = g.GradeLevelId,
                        nombre = g.Nombre
                    })
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error obteniendo grupos filtro");
                return Json(new { success = false, message = "Error al obtener grupos" });
            }
        }
    }
}
