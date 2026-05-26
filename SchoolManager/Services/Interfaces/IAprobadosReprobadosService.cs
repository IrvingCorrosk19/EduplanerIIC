using SchoolManager.ViewModels;

namespace SchoolManager.Services.Interfaces
{
    /// <summary>
    /// Servicio para generar reportes de aprobados y reprobados
    /// </summary>
    public interface IAprobadosReprobadosService
    {
        /// <summary>
        /// Genera el reporte para una asignación docente (trimestre + materia + grupo), alineado con TeacherGradebook.
        /// </summary>
        Task<AprobadosReprobadosReportViewModel> GenerarReporteAsync(
            Guid schoolId,
            string trimestre,
            Guid materiaId,
            Guid groupId,
            Guid gradeLevelId,
            Guid? teacherScopeId = null);

        Task<List<string>> ObtenerTrimestresDisponiblesAsync(Guid schoolId);

        /// <summary>Materias del docente (o de la escuela si es admin/director).</summary>
        Task<List<(Guid Id, string Nombre)>> ObtenerMateriasFiltroAsync(Guid schoolId, Guid? teacherScopeId = null);

        /// <summary>Grupos de la materia seleccionada (grade_level + nombre), como en TeacherGradebook.</summary>
        Task<List<AprobadosReprobadosGrupoFiltroDto>> ObtenerGruposFiltroAsync(
            Guid schoolId,
            Guid materiaId,
            Guid? teacherScopeId = null);

        Task<byte[]> ExportarAPdfAsync(AprobadosReprobadosReportViewModel reporte, byte[]? logoBytes = null);

        Task<byte[]> ExportarAExcelAsync(AprobadosReprobadosReportViewModel reporte);

        Task<(bool Success, string Message)> PrepararDatosParaReporteAsync(Guid schoolId);
    }
}
