using SchoolManager.ViewModels;

namespace SchoolManager.Services.Interfaces
{
    /// <summary>
    /// Servicio para generar reportes de aprobados y reprobados
    /// </summary>
    public interface IAprobadosReprobadosService
    {
        /// <summary>
        /// Genera el reporte de aprobados y reprobados por grado
        /// </summary>
        Task<AprobadosReprobadosReportViewModel> GenerarReporteAsync(
            Guid schoolId, 
            string trimestre, 
            string nivelEducativo,
            string? gradoEspecifico = null,
            string? grupoEspecifico = null,
            Guid? especialidadId = null,
            Guid? areaId = null,
            Guid? materiaId = null,
            Guid? teacherScopeId = null);

        /// <summary>
        /// Obtiene los trimestres disponibles para una escuela
        /// </summary>
        Task<List<string>> ObtenerTrimestresDisponiblesAsync(Guid schoolId);

        /// <summary>
        /// Obtiene los niveles educativos disponibles
        /// </summary>
        Task<List<string>> ObtenerNivelesEducativosAsync(Guid? teacherScopeId = null);

        /// <summary>
        /// Grados disponibles para un nivel (Premedia/Media), opcionalmente acotados al docente.
        /// </summary>
        Task<List<string>> ObtenerGradosPorNivelAsync(string nivelEducativo, Guid? teacherScopeId = null);
        
        /// <summary>
        /// Obtiene las especialidades disponibles
        /// </summary>
        Task<List<(Guid Id, string Nombre)>> ObtenerEspecialidadesAsync(Guid schoolId, Guid? teacherScopeId = null, string? nivelEducativo = null);
        
        /// <summary>
        /// Obtiene las áreas disponibles
        /// </summary>
        Task<List<(Guid Id, string Nombre)>> ObtenerAreasAsync(Guid? teacherScopeId = null, string? nivelEducativo = null);
        
        /// <summary>
        /// Obtiene las materias disponibles
        /// </summary>
        Task<List<(Guid Id, string Nombre)>> ObtenerMateriasAsync(Guid schoolId, Guid? areaId = null, Guid? especialidadId = null, Guid? teacherScopeId = null, string? nivelEducativo = null);

        /// <summary>
        /// Exportar el reporte a PDF. Si logoBytes no es null, se usa en lugar de descargar por URL.
        /// </summary>
        Task<byte[]> ExportarAPdfAsync(AprobadosReprobadosReportViewModel reporte, byte[]? logoBytes = null);

        /// <summary>
        /// Exportar el reporte a Excel
        /// </summary>
        Task<byte[]> ExportarAExcelAsync(AprobadosReprobadosReportViewModel reporte);

        /// <summary>
        /// Prepara datos para que el reporte muestre filas: asocia actividades al 3T y asigna grados a grupos (solo Admin/Director).
        /// </summary>
        Task<(bool Success, string Message)> PrepararDatosParaReporteAsync(Guid schoolId);
    }
}

