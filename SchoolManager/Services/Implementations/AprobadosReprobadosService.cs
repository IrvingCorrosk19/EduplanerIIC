using Microsoft.EntityFrameworkCore;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using SchoolManager.ViewModels;
using System.Text;

namespace SchoolManager.Services.Implementations
{
    public class AprobadosReprobadosService : IAprobadosReprobadosService
    {
        private readonly SchoolDbContext _context;
        private readonly ILogger<AprobadosReprobadosService> _logger;
        private const decimal NOTA_MINIMA_APROBACION = 71m;

        public AprobadosReprobadosService(
            SchoolDbContext context,
            ILogger<AprobadosReprobadosService> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<AprobadosReprobadosReportViewModel> GenerarReporteAsync(
            Guid schoolId,
            string trimestre,
            string nivelEducativo,
            string? gradoEspecifico = null,
            string? grupoEspecifico = null)
        {
            try
            {
                _logger.LogInformation("📊 Generando reporte de aprobados/reprobados - School: {SchoolId}, Trimestre: {Trimestre}, Nivel: {Nivel}",
                    schoolId, trimestre, nivelEducativo);

                // Obtener información de la escuela
                var school = await _context.Schools.FindAsync(schoolId);
                if (school == null)
                    throw new Exception("Escuela no encontrada");

                // Determinar los grados según el nivel educativo
                var grados = ObtenerGradosPorNivel(nivelEducativo);

                // Obtener estadísticas por grado y grupo
                var estadisticas = new List<GradoEstadisticaDto>();

                foreach (var grado in grados)
                {
                    // Filtrar por grado específico si se proporciona
                    if (!string.IsNullOrEmpty(gradoEspecifico) && grado != gradoEspecifico)
                        continue;

                    // Obtener grupos para este grado
                    var gruposQuery = _context.Groups
                        .Where(g => g.SchoolId == schoolId && g.Grade == grado);

                    if (!string.IsNullOrEmpty(grupoEspecifico))
                    {
                        gruposQuery = gruposQuery.Where(g => g.Name == grupoEspecifico);
                    }

                    var grupos = await gruposQuery.ToListAsync();

                    foreach (var grupo in grupos)
                    {
                        var stats = await CalcularEstadisticasGrupoAsync(grupo.Id, trimestre);
                        
                        estadisticas.Add(new GradoEstadisticaDto
                        {
                            Grado = grado,
                            Grupo = grupo.Name,
                            TotalEstudiantes = stats.Total,
                            Aprobados = stats.Aprobados,
                            PorcentajeAprobados = stats.PorcentajeAprobados,
                            Reprobados = stats.Reprobados,
                            PorcentajeReprobados = stats.PorcentajeReprobados,
                            ReprobadosHastaLaFecha = stats.ReprobadosHastaLaFecha,
                            PorcentajeReprobadosHastaLaFecha = stats.PorcentajeReprobadosHastaLaFecha,
                            SinCalificaciones = stats.SinCalificaciones,
                            PorcentajeSinCalificaciones = stats.PorcentajeSinCalificaciones,
                            Retirados = stats.Retirados,
                            PorcentajeRetirados = stats.PorcentajeRetirados
                        });
                    }
                }

                // Calcular totales generales
                var totales = CalcularTotalesGenerales(estadisticas);

                // Obtener año lectivo actual
                var anoLectivo = DateTime.Now.Year.ToString();

                var reporte = new AprobadosReprobadosReportViewModel
                {
                    InstitutoNombre = school.Name,
                    LogoUrl = school.LogoUrl ?? "",
                    ProfesorCoordinador = "", // Se llenará desde el controlador con el usuario actual
                    Trimestre = trimestre,
                    AnoLectivo = anoLectivo,
                    NivelEducativo = nivelEducativo,
                    FechaGeneracion = DateTime.Now,
                    Estadisticas = estadisticas.OrderBy(e => e.Grado).ThenBy(e => e.Grupo).ToList(),
                    TotalesGenerales = totales,
                    TrimestresDisponibles = await ObtenerTrimestresDisponiblesAsync(schoolId),
                    NivelesDisponibles = await ObtenerNivelesEducativosAsync()
                };

                _logger.LogInformation("✅ Reporte generado exitosamente con {Count} grupos", estadisticas.Count);
                return reporte;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "❌ Error generando reporte de aprobados/reprobados");
                throw;
            }
        }

        private async Task<(int Total, int Aprobados, decimal PorcentajeAprobados, 
            int Reprobados, decimal PorcentajeReprobados,
            int ReprobadosHastaLaFecha, decimal PorcentajeReprobadosHastaLaFecha,
            int SinCalificaciones, decimal PorcentajeSinCalificaciones,
            int Retirados, decimal PorcentajeRetirados)> 
            CalcularEstadisticasGrupoAsync(Guid grupoId, string trimestre)
        {
            // Obtener todos los estudiantes del grupo
            var estudiantesDelGrupo = await _context.StudentAssignments
                .Where(sa => sa.GroupId == grupoId)
                .Select(sa => sa.StudentId)
                .Distinct()
                .ToListAsync();

            int total = estudiantesDelGrupo.Count;
            int aprobados = 0;
            int reprobados = 0;
            int reprobadosHastaLaFecha = 0;
            int sinCalificaciones = 0;
            int retirados = 0;

            foreach (var estudianteId in estudiantesDelGrupo)
            {
                // Verificar si el estudiante está retirado
                var estudiante = await _context.Users.FindAsync(estudianteId);
                if (estudiante?.Status?.ToLower() == "inactive" || estudiante?.Status?.ToLower() == "retirado")
                {
                    retirados++;
                    continue;
                }

                // Obtener calificaciones del estudiante para el trimestre
                var calificaciones = await _context.StudentActivityScores
                    .Include(sas => sas.Activity)
                    .Where(sas => sas.StudentId == estudianteId && 
                                  sas.Activity!.Trimester == trimestre)
                    .ToListAsync();

                if (!calificaciones.Any())
                {
                    sinCalificaciones++;
                    continue;
                }

                // Calcular promedio general del estudiante
                var materias = calificaciones
                    .GroupBy(c => c.Activity!.SubjectId)
                    .Select(g => new
                    {
                        SubjectId = g.Key,
                        PromedioMateria = g.Average(c => c.Score ?? 0)
                    })
                    .ToList();

                if (!materias.Any())
                {
                    sinCalificaciones++;
                    continue;
                }

                var promedioGeneral = materias.Average(m => m.PromedioMateria);

                // Verificar si tiene materias reprobadas
                var materiasReprobadas = materias.Count(m => m.PromedioMateria < NOTA_MINIMA_APROBACION);

                if (materiasReprobadas > 0)
                {
                    reprobadosHastaLaFecha++;
                    
                    // Si reprueba 3 o más materias, está reprobado definitivamente
                    if (materiasReprobadas >= 3)
                    {
                        reprobados++;
                    }
                }
                else if (promedioGeneral >= NOTA_MINIMA_APROBACION)
                {
                    aprobados++;
                }
            }

            // Calcular porcentajes
            decimal porcentajeAprobados = total > 0 ? (aprobados * 100m / total) : 0;
            decimal porcentajeReprobados = total > 0 ? (reprobados * 100m / total) : 0;
            decimal porcentajeReprobadosHastaLaFecha = total > 0 ? (reprobadosHastaLaFecha * 100m / total) : 0;
            decimal porcentajeSinCalificaciones = total > 0 ? (sinCalificaciones * 100m / total) : 0;
            decimal porcentajeRetirados = total > 0 ? (retirados * 100m / total) : 0;

            return (total, aprobados, porcentajeAprobados, 
                    reprobados, porcentajeReprobados,
                    reprobadosHastaLaFecha, porcentajeReprobadosHastaLaFecha,
                    sinCalificaciones, porcentajeSinCalificaciones,
                    retirados, porcentajeRetirados);
        }

        private TotalesGeneralesDto CalcularTotalesGenerales(List<GradoEstadisticaDto> estadisticas)
        {
            var total = estadisticas.Sum(e => e.TotalEstudiantes);
            var aprobados = estadisticas.Sum(e => e.Aprobados);
            var reprobados = estadisticas.Sum(e => e.Reprobados);
            var reprobadosHastaLaFecha = estadisticas.Sum(e => e.ReprobadosHastaLaFecha);
            var sinCalificaciones = estadisticas.Sum(e => e.SinCalificaciones);
            var retirados = estadisticas.Sum(e => e.Retirados);

            return new TotalesGeneralesDto
            {
                TotalEstudiantes = total,
                TotalAprobados = aprobados,
                PorcentajeAprobados = total > 0 ? Math.Round(aprobados * 100m / total, 2) : 0,
                TotalReprobados = reprobados,
                PorcentajeReprobados = total > 0 ? Math.Round(reprobados * 100m / total, 2) : 0,
                TotalReprobadosHastaLaFecha = reprobadosHastaLaFecha,
                PorcentajeReprobadosHastaLaFecha = total > 0 ? Math.Round(reprobadosHastaLaFecha * 100m / total, 2) : 0,
                TotalSinCalificaciones = sinCalificaciones,
                PorcentajeSinCalificaciones = total > 0 ? Math.Round(sinCalificaciones * 100m / total, 2) : 0,
                TotalRetirados = retirados,
                PorcentajeRetirados = total > 0 ? Math.Round(retirados * 100m / total, 2) : 0
            };
        }

        private List<string> ObtenerGradosPorNivel(string nivelEducativo)
        {
            return nivelEducativo.ToLower() switch
            {
                "premedia" => new List<string> { "7°", "8°", "9°" },
                "media" => new List<string> { "10°", "11°", "12°" },
                _ => new List<string>()
            };
        }

        public async Task<List<string>> ObtenerTrimestresDisponiblesAsync(Guid schoolId)
        {
            try
            {
                var trimestres = await _context.Set<Trimester>()
                    .Where(t => t.SchoolId == schoolId)
                    .OrderBy(t => t.Name)
                    .Select(t => t.Name)
                    .Distinct()
                    .ToListAsync();

                return trimestres;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error obteniendo trimestres");
                return new List<string>();
            }
        }

        public async Task<List<string>> ObtenerNivelesEducativosAsync()
        {
            return await Task.FromResult(new List<string> { "Premedia", "Media" });
        }

        public async Task<byte[]> ExportarAPdfAsync(AprobadosReprobadosReportViewModel reporte)
        {
            // TODO: Implementar exportación a PDF usando una librería como iTextSharp o QuestPDF
            await Task.CompletedTask;
            throw new NotImplementedException("Exportación a PDF pendiente de implementación");
        }

        public async Task<byte[]> ExportarAExcelAsync(AprobadosReprobadosReportViewModel reporte)
        {
            // TODO: Implementar exportación a Excel usando ClosedXML o EPPlus
            await Task.CompletedTask;
            throw new NotImplementedException("Exportación a Excel pendiente de implementación");
        }
    }
}

