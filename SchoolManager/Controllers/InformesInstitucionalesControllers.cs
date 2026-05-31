using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using SchoolManager.Services.Interfaces;
using SchoolManager.ViewModels;

namespace SchoolManager.Controllers;

[Authorize(Roles = "admin,director,teacher")]
public class HabitosActitudesReportController : InformeInstitucionalControllerBase
{
    private readonly IReportesInstitucionalesService _reportesService;

    public HabitosActitudesReportController(
        ICurrentUserService currentUserService,
        IAprobadosReprobadosService aprobadosReprobadosService,
        IReportesInstitucionalesService reportesService)
        : base(currentUserService, aprobadosReprobadosService)
    {
        _reportesService = reportesService;
    }

    [HttpGet]
    public async Task<IActionResult> Index()
    {
        ViewBag.TituloInforme = "Cuadro de Hábitos y Actitudes";
        ViewBag.DescripcionInforme = "Plantilla oficial por estudiante. Complete S / X / R en Excel según evaluación del trimestre.";
        return await PrepararVistaFiltrosAsync(requiereMateria: false);
    }

    [HttpGet]
    public async Task<IActionResult> ExportarExcel(
        string trimestre, string nivelEducativo, Guid groupId, Guid gradeLevelId)
    {
        try
        {
            var (user, error) = await ObtenerUsuarioEscuelaAsync();
            if (error != null) return error;

            if (string.IsNullOrWhiteSpace(trimestre) || string.IsNullOrWhiteSpace(nivelEducativo))
                return BadRequest("Trimestre y nivel son requeridos.");

            var bytes = await _reportesService.ExportarHabitosActitudesExcelAsync(
                user!.SchoolId!.Value,
                trimestre,
                nivelEducativo,
                groupId,
                gradeLevelId,
                GetTeacherScopeId(user),
                $"{user.Name} {user.LastName}");

            return File(bytes, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                $"Habitos_Actitudes_{trimestre}.xlsx");
        }
        catch (UnauthorizedAccessException ex)
        {
            TempData["Error"] = ex.Message;
            return RedirectToAction(nameof(Index));
        }
    }
}

[Authorize(Roles = "admin,director,teacher")]
public class CalificacionesInformeController : InformeInstitucionalControllerBase
{
    private readonly IReportesInstitucionalesService _reportesService;

    public CalificacionesInformeController(
        ICurrentUserService currentUserService,
        IAprobadosReprobadosService aprobadosReprobadosService,
        IReportesInstitucionalesService reportesService)
        : base(currentUserService, aprobadosReprobadosService)
    {
        _reportesService = reportesService;
    }

    [HttpGet]
    public Task<IActionResult> ExpresionesArtisticas() =>
        PrepararVistaInformeAsync(InformeCalificacionesTipo.ExpresionesArtisticas,
            "Calificaciones — Expresiones Artísticas",
            "Informe trimestral de Educ. Artística y Educ. Musical por grupo.");

    [HttpGet]
    public Task<IActionResult> Tecnologia() =>
        PrepararVistaInformeAsync(InformeCalificacionesTipo.Tecnologia,
            "Calificaciones — Tecnología",
            "Informe trimestral por áreas de tecnología según grado.");

    [HttpGet]
    public async Task<IActionResult> ExportarExcel(
        string tipo, string nivelEducativo, Guid groupId, Guid gradeLevelId)
    {
        try
        {
            var (user, error) = await ObtenerUsuarioEscuelaAsync();
            if (error != null) return error;

            if (string.IsNullOrWhiteSpace(nivelEducativo))
                return BadRequest("Nivel educativo requerido.");

            var informeTipo = string.Equals(tipo, "tecnologia", StringComparison.OrdinalIgnoreCase)
                ? InformeCalificacionesTipo.Tecnologia
                : InformeCalificacionesTipo.ExpresionesArtisticas;

            var bytes = await _reportesService.ExportarCalificacionesInformeExcelAsync(
                informeTipo,
                user!.SchoolId!.Value,
                nivelEducativo,
                groupId,
                gradeLevelId,
                GetTeacherScopeId(user),
                $"{user.Name} {user.LastName}");

            var nombre = informeTipo == InformeCalificacionesTipo.Tecnologia
                ? "Calificaciones_Tecnologia"
                : "Calificaciones_Expresiones_Artisticas";

            return File(bytes, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                $"{nombre}.xlsx");
        }
        catch (UnauthorizedAccessException ex)
        {
            TempData["Error"] = ex.Message;
            return RedirectToAction(informeTipoRedirect(tipo));
        }
    }

    private static string informeTipoRedirect(string? tipo) =>
        string.Equals(tipo, "tecnologia", StringComparison.OrdinalIgnoreCase)
            ? nameof(Tecnologia)
            : nameof(ExpresionesArtisticas);

    private async Task<IActionResult> PrepararVistaInformeAsync(
        InformeCalificacionesTipo tipo, string titulo, string descripcion)
    {
        ViewBag.InformeTipo = tipo.ToString();
        ViewBag.TipoExport = tipo == InformeCalificacionesTipo.Tecnologia ? "tecnologia" : "expresionesArtisticas";
        ViewBag.TituloInforme = titulo;
        ViewBag.DescripcionInforme = descripcion;
        return await PrepararVistaFiltrosAsync(requiereMateria: false, requiereTrimestre: false);
    }
}

[Authorize(Roles = "admin,director,teacher")]
public class FormatoCarpetasReportController : InformeInstitucionalControllerBase
{
    private readonly IReportesInstitucionalesService _reportesService;

    public FormatoCarpetasReportController(
        ICurrentUserService currentUserService,
        IAprobadosReprobadosService aprobadosReprobadosService,
        IReportesInstitucionalesService reportesService)
        : base(currentUserService, aprobadosReprobadosService)
    {
        _reportesService = reportesService;
    }

    [HttpGet]
    public async Task<IActionResult> Index()
    {
        ViewBag.TituloInforme = "Formato para Carpetas";
        ViewBag.DescripcionInforme = "Premedia: promedios, ausencias (A) y tardanzas (T) por trimestre y materia.";
        return await PrepararVistaFiltrosAsync(requiereMateria: true, requiereTrimestre: false);
    }

    [HttpGet]
    public async Task<IActionResult> ExportarExcel(
        string nivelEducativo, Guid materiaId, Guid groupId, Guid gradeLevelId)
    {
        try
        {
            var (user, error) = await ObtenerUsuarioEscuelaAsync();
            if (error != null) return error;

            if (string.IsNullOrWhiteSpace(nivelEducativo) || materiaId == Guid.Empty)
                return BadRequest("Nivel y materia son requeridos.");

            var bytes = await _reportesService.ExportarFormatoCarpetasExcelAsync(
                user!.SchoolId!.Value,
                nivelEducativo,
                materiaId,
                groupId,
                gradeLevelId,
                GetTeacherScopeId(user),
                $"{user.Name} {user.LastName}",
                $"{user.Name} {user.LastName}");

            return File(bytes, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                "Formato_Carpetas.xlsx");
        }
        catch (UnauthorizedAccessException ex)
        {
            TempData["Error"] = ex.Message;
            return RedirectToAction(nameof(Index));
        }
    }
}

public abstract class InformeInstitucionalControllerBase : Controller
{
    private readonly ICurrentUserService _currentUserService;
    private readonly IAprobadosReprobadosService _aprobadosReprobadosService;

    protected InformeInstitucionalControllerBase(
        ICurrentUserService currentUserService,
        IAprobadosReprobadosService aprobadosReprobadosService)
    {
        _currentUserService = currentUserService;
        _aprobadosReprobadosService = aprobadosReprobadosService;
    }

    protected static Guid? GetTeacherScopeId(Models.User? user) =>
        user != null && (string.Equals(user.Role, "teacher", StringComparison.OrdinalIgnoreCase) ||
                         string.Equals(user.Role, "docente", StringComparison.OrdinalIgnoreCase))
            ? user.Id
            : null;

    protected async Task<(Models.User? user, IActionResult? error)> ObtenerUsuarioEscuelaAsync()
    {
        var user = await _currentUserService.GetCurrentUserAsync();
        if (user?.SchoolId == null)
        {
            TempData["Error"] = "No se pudo obtener la información de la escuela.";
            return (null, RedirectToAction("Index", "Home"));
        }
        return (user, null);
    }

    protected async Task<IActionResult> PrepararVistaFiltrosAsync(
        bool requiereMateria = false,
        bool requiereTrimestre = true)
    {
        var (user, error) = await ObtenerUsuarioEscuelaAsync();
        if (error != null) return error;

        ViewBag.TrimestresDisponibles =
            await _aprobadosReprobadosService.ObtenerTrimestresDisponiblesAsync(user!.SchoolId!.Value);
        ViewBag.EsDocente = GetTeacherScopeId(user).HasValue;
        ViewBag.RequiereMateria = requiereMateria;
        ViewBag.RequiereTrimestre = requiereTrimestre;
        ViewBag.ExportController = ControllerContext.RouteData.Values["controller"]?.ToString();
        ViewBag.ExportAction = "ExportarExcel";

        return View("~/Views/Shared/_InformeInstitucionalFiltros.cshtml",
            new InformeInstitucionalFiltroViewModel());
    }
}
