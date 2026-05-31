using SchoolManager.ViewModels;

namespace SchoolManager.Services.Interfaces
{
    /// <summary>
    /// Servicio para generar reportes de aprobados y reprobados
    /// </summary>
    public interface IAprobadosReprobadosService
    {
        /// <summary>
        /// Genera el reporte para una asignación docente (trimestre + nivel + materia + grupo), alineado con TeacherGradebook.
        /// </summary>
        Task<AprobadosReprobadosReportViewModel> GenerarReporteAsync(
            Guid schoolId,
            string trimestre,
            string nivelEducativo,
            Guid materiaId,
            Guid groupId,
            Guid gradeLevelId,
            Guid? teacherScopeId = null);

        Task<List<string>> ObtenerTrimestresDisponiblesAsync(Guid schoolId);

        /// <summary>Grados/niveles académicos (1°, 2°, …) con asignaciones del usuario.</summary>
        Task<List<AprobadosReprobadosNivelFiltroDto>> ObtenerNivelesFiltroAsync(Guid schoolId, Guid? teacherScopeId = null);

        /// <summary>Materias del docente en el grado seleccionado (o escuela si es admin/director).</summary>
        Task<List<(Guid Id, string Nombre)>> ObtenerMateriasFiltroAsync(
            Guid schoolId, string? nivelGradeLevelId = null, Guid? teacherScopeId = null);

        /// <summary>Grupos de la materia en el grado seleccionado, como en TeacherGradebook.</summary>
        Task<List<AprobadosReprobadosGrupoFiltroDto>> ObtenerGruposFiltroAsync(
            Guid schoolId, Guid materiaId, string? nivelGradeLevelId = null, Guid? teacherScopeId = null);

        Task<byte[]> ExportarAPdfAsync(AprobadosReprobadosReportViewModel reporte, byte[]? logoBytes = null);

        Task<byte[]> ExportarAExcelAsync(AprobadosReprobadosReportViewModel reporte);

        Task<(bool Success, string Message)> PrepararDatosParaReporteAsync(Guid schoolId);
    }
}
