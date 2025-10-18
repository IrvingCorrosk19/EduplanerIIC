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
        private readonly ILogger<AprobadosReprobadosController> _logger;

        public AprobadosReprobadosController(
            IAprobadosReprobadosService aprobadosReprobadosService,
            ICurrentUserService currentUserService,
            ILogger<AprobadosReprobadosController> logger)
        {
            _aprobadosReprobadosService = aprobadosReprobadosService;
            _currentUserService = currentUserService;
            _logger = logger;
        }

        private Guid GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            return Guid.TryParse(userIdClaim, out var userId) ? userId : Guid.Empty;
        }

        // GET: AprobadosReprobados/Index
        [HttpGet]
        public async Task<IActionResult> Index()
        {
            try
            {
                var currentUser = await _currentUserService.GetCurrentUserAsync();
                if (currentUser?.SchoolId == null)
                {
                    TempData["Error"] = "No se pudo obtener la información de la escuela.";
                    return RedirectToAction("Index", "Home");
                }

                var filtro = new AprobadosReprobadosFiltroViewModel();
                
                // Cargar trimestres y niveles disponibles
                ViewBag.TrimestresDisponibles = await _aprobadosReprobadosService.ObtenerTrimestresDisponiblesAsync(currentUser.SchoolId.Value);
                ViewBag.NivelesDisponibles = await _aprobadosReprobadosService.ObtenerNivelesEducativosAsync();
                
                // Cargar nuevos filtros
                ViewBag.EspecialidadesDisponibles = await _aprobadosReprobadosService.ObtenerEspecialidadesAsync(currentUser.SchoolId.Value);
                ViewBag.AreasDisponibles = await _aprobadosReprobadosService.ObtenerAreasAsync();
                ViewBag.MateriasDisponibles = await _aprobadosReprobadosService.ObtenerMateriasAsync(currentUser.SchoolId.Value);
                
                ViewBag.CurrentUser = currentUser;

                return View(filtro);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error cargando página de reportes");
                TempData["Error"] = "Error al cargar la página.";
                return RedirectToAction("Index", "Home");
            }
        }

        // POST: AprobadosReprobados/GenerarReporte
        [HttpPost]
        public async Task<IActionResult> GenerarReporte(AprobadosReprobadosFiltroViewModel filtro)
        {
            try
            {
                var currentUser = await _currentUserService.GetCurrentUserAsync();
                if (currentUser?.SchoolId == null)
                {
                    return Json(new { success = false, message = "No se pudo obtener la información de la escuela" });
                }

                if (!ModelState.IsValid)
                {
                    var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage);
                    return Json(new { success = false, message = $"Datos de filtro inválidos: {string.Join(", ", errors)}" });
                }

                // Validar que se proporcionen los campos requeridos
                if (string.IsNullOrEmpty(filtro.Trimestre) || string.IsNullOrEmpty(filtro.NivelEducativo))
                {
                    return Json(new { success = false, message = "Trimestre y nivel educativo son requeridos" });
                }

                var reporte = await _aprobadosReprobadosService.GenerarReporteAsync(
                    currentUser.SchoolId.Value,
                    filtro.Trimestre,
                    filtro.NivelEducativo,
                    filtro.GradoEspecifico,
                    filtro.GrupoEspecifico,
                    filtro.EspecialidadId,
                    filtro.AreaId,
                    filtro.MateriaId
                );

                // Agregar nombre del profesor coordinador
                reporte.ProfesorCoordinador = $"{currentUser.Name} {currentUser.LastName}";

                return Json(new { success = true, data = reporte });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generando reporte");
                return Json(new { success = false, message = $"Error: {ex.Message}" });
            }
        }

        // GET: AprobadosReprobados/VistaPrevia
        [HttpGet]
        public async Task<IActionResult> VistaPrevia(string trimestre, string nivelEducativo, string? grado = null, string? grupo = null, 
            Guid? especialidadId = null, Guid? areaId = null, Guid? materiaId = null)
        {
            try
            {
                var currentUser = await _currentUserService.GetCurrentUserAsync();
                if (currentUser?.SchoolId == null)
                {
                    TempData["Error"] = "No se pudo obtener la información de la escuela.";
                    return RedirectToAction("Index");
                }

                var reporte = await _aprobadosReprobadosService.GenerarReporteAsync(
                    currentUser.SchoolId.Value,
                    trimestre,
                    nivelEducativo,
                    grado,
                    grupo,
                    especialidadId,
                    areaId,
                    materiaId
                );

                reporte.ProfesorCoordinador = $"{currentUser.Name} {currentUser.LastName}";

                return View(reporte);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generando vista previa");
                TempData["Error"] = "Error al generar el reporte.";
                return RedirectToAction("Index");
            }
        }

        // GET: AprobadosReprobados/ExportarPdf
        [HttpGet]
        public async Task<IActionResult> ExportarPdf(string trimestre, string nivelEducativo, string? grado = null, string? grupo = null,
            Guid? especialidadId = null, Guid? areaId = null, Guid? materiaId = null)
        {
            try
            {
                var currentUser = await _currentUserService.GetCurrentUserAsync();
                if (currentUser?.SchoolId == null)
                {
                    return BadRequest("No se pudo obtener la información de la escuela");
                }

                var reporte = await _aprobadosReprobadosService.GenerarReporteAsync(
                    currentUser.SchoolId.Value,
                    trimestre,
                    nivelEducativo,
                    grado,
                    grupo,
                    especialidadId,
                    areaId,
                    materiaId
                );

                reporte.ProfesorCoordinador = $"{currentUser.Name} {currentUser.LastName}";

                var pdfBytes = await _aprobadosReprobadosService.ExportarAPdfAsync(reporte);

                return File(pdfBytes, "application/pdf", $"Reporte_Aprobados_Reprobados_{trimestre}_{nivelEducativo}.pdf");
            }
            catch (NotImplementedException)
            {
                TempData["Error"] = "La exportación a PDF aún no está disponible. Use la función de imprimir del navegador.";
                return RedirectToAction("VistaPrevia", new { trimestre, nivelEducativo, grado, grupo, especialidadId, areaId, materiaId });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error exportando a PDF");
                TempData["Error"] = "Error al exportar el reporte.";
                return RedirectToAction("Index");
            }
        }

        // GET: AprobadosReprobados/ExportarExcel
        [HttpGet]
        public async Task<IActionResult> ExportarExcel(string trimestre, string nivelEducativo, string? grado = null, string? grupo = null,
            Guid? especialidadId = null, Guid? areaId = null, Guid? materiaId = null)
        {
            try
            {
                var currentUser = await _currentUserService.GetCurrentUserAsync();
                if (currentUser?.SchoolId == null)
                {
                    return BadRequest("No se pudo obtener la información de la escuela");
                }

                var reporte = await _aprobadosReprobadosService.GenerarReporteAsync(
                    currentUser.SchoolId.Value,
                    trimestre,
                    nivelEducativo,
                    grado,
                    grupo,
                    especialidadId,
                    areaId,
                    materiaId
                );

                reporte.ProfesorCoordinador = $"{currentUser.Name} {currentUser.LastName}";

                var excelBytes = await _aprobadosReprobadosService.ExportarAExcelAsync(reporte);

                return File(excelBytes, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", 
                    $"Reporte_Aprobados_Reprobados_{trimestre}_{nivelEducativo}.xlsx");
            }
            catch (NotImplementedException)
            {
                TempData["Error"] = "La exportación a Excel aún no está disponible.";
                return RedirectToAction("Index");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error exportando a Excel");
                TempData["Error"] = "Error al exportar el reporte.";
                return RedirectToAction("Index");
            }
        }

        // GET: AprobadosReprobados/ObtenerEspecialidades
        [HttpGet]
        public async Task<IActionResult> ObtenerEspecialidades()
        {
            try
            {
                var currentUser = await _currentUserService.GetCurrentUserAsync();
                if (currentUser?.SchoolId == null)
                {
                    return Json(new { success = false, message = "No se pudo obtener la información de la escuela" });
                }

                var especialidades = await _aprobadosReprobadosService.ObtenerEspecialidadesAsync(currentUser.SchoolId.Value);
                
                return Json(new { 
                    success = true, 
                    data = especialidades.Select(e => new { id = e.Id, nombre = e.Nombre }) 
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error obteniendo especialidades");
                return Json(new { success = false, message = "Error al obtener especialidades" });
            }
        }

        // GET: AprobadosReprobados/ObtenerAreas
        [HttpGet]
        public async Task<IActionResult> ObtenerAreas()
        {
            try
            {
                var areas = await _aprobadosReprobadosService.ObtenerAreasAsync();
                
                return Json(new { 
                    success = true, 
                    data = areas.Select(a => new { id = a.Id, nombre = a.Nombre }) 
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error obteniendo áreas");
                return Json(new { success = false, message = "Error al obtener áreas" });
            }
        }

        // GET: AprobadosReprobados/ObtenerMaterias
        [HttpGet]
        public async Task<IActionResult> ObtenerMaterias(Guid? areaId = null, Guid? especialidadId = null)
        {
            try
            {
                var currentUser = await _currentUserService.GetCurrentUserAsync();
                if (currentUser?.SchoolId == null)
                {
                    return Json(new { success = false, message = "No se pudo obtener la información de la escuela" });
                }

                var materias = await _aprobadosReprobadosService.ObtenerMateriasAsync(
                    currentUser.SchoolId.Value, 
                    areaId, 
                    especialidadId);
                
                return Json(new { 
                    success = true, 
                    data = materias.Select(m => new { id = m.Id, nombre = m.Nombre }) 
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error obteniendo materias");
                return Json(new { success = false, message = "Error al obtener materias" });
            }
        }
    }
}

