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
            string? grupoEspecifico = null);

        /// <summary>
        /// Obtiene los trimestres disponibles para una escuela
        /// </summary>
        Task<List<string>> ObtenerTrimestresDisponiblesAsync(Guid schoolId);

        /// <summary>
        /// Obtiene los niveles educativos disponibles
        /// </summary>
        Task<List<string>> ObtenerNivelesEducativosAsync();

        /// <summary>
        /// Exportar el reporte a PDF
        /// </summary>
        Task<byte[]> ExportarAPdfAsync(AprobadosReprobadosReportViewModel reporte);

        /// <summary>
        /// Exportar el reporte a Excel
        /// </summary>
        Task<byte[]> ExportarAExcelAsync(AprobadosReprobadosReportViewModel reporte);
    }
}

