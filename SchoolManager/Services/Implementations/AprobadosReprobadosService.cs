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
        private const decimal NOTA_MINIMA_APROBACION = 3.0m; // Escala 0-5, nota mínima para aprobar es 3.0

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
            string? grupoEspecifico = null,
            Guid? especialidadId = null,
            Guid? areaId = null,
            Guid? materiaId = null)
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

                    if (!grupos.Any())
                    {
                        _logger.LogWarning("No se encontraron grupos para el grado {Grado} en la escuela {SchoolId}", grado, schoolId);
                        continue;
                    }

                    foreach (var grupo in grupos)
                    {
                        var stats = await CalcularEstadisticasGrupoAsync(grupo.Id, trimestre, materiaId, areaId, especialidadId);
                        
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

                if (!estadisticas.Any())
                {
                    _logger.LogWarning("No se encontraron estadísticas para los filtros aplicados - School: {SchoolId}, Trimestre: {Trimestre}, Nivel: {Nivel}", 
                        schoolId, trimestre, nivelEducativo);
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
            CalcularEstadisticasGrupoAsync(Guid grupoId, string trimestre, Guid? materiaId = null, Guid? areaId = null, Guid? especialidadId = null)
        {
            _logger.LogInformation("Calculando estadísticas para grupo {GrupoId}, trimestre {Trimestre}", grupoId, trimestre);
            
            // Obtener todos los estudiantes del grupo
            var estudiantesDelGrupo = await _context.StudentAssignments
                .Where(sa => sa.GroupId == grupoId)
                .Select(sa => sa.StudentId)
                .Distinct()
                .ToListAsync();

            int total = estudiantesDelGrupo.Count;
            _logger.LogInformation("Total de estudiantes en el grupo: {Total}", total);
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
                var calificacionesQuery = _context.StudentActivityScores
                    .Include(sas => sas.Activity)
                        .ThenInclude(a => a!.Subject)
                            .ThenInclude(s => s!.Area)
                    .Where(sas => sas.StudentId == estudianteId && 
                                  sas.Activity!.Trimester == trimestre);
                
                // Aplicar filtro por materia si está especificado
                if (materiaId.HasValue)
                {
                    calificacionesQuery = calificacionesQuery.Where(sas => sas.Activity!.SubjectId == materiaId.Value);
                }
                
                // Aplicar filtro por área si está especificado
                if (areaId.HasValue)
                {
                    calificacionesQuery = calificacionesQuery.Where(sas => sas.Activity!.Subject!.AreaId == areaId.Value);
                }
                
                // Aplicar filtro por especialidad si está especificado
                if (especialidadId.HasValue)
                {
                    calificacionesQuery = calificacionesQuery
                        .Join(_context.SubjectAssignments,
                            sas => sas.Activity!.SubjectId,
                            sa => sa.SubjectId,
                            (sas, sa) => new { sas, sa })
                        .Where(x => x.sa.SpecialtyId == especialidadId.Value)
                        .Select(x => x.sas);
                }
                
                var calificaciones = await calificacionesQuery.ToListAsync();

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

            _logger.LogInformation("Estadísticas calculadas - Total: {Total}, Aprobados: {Aprobados}, Reprobados: {Reprobados}, Sin Calificaciones: {SinCalificaciones}, Retirados: {Retirados}", 
                total, aprobados, reprobados, sinCalificaciones, retirados);

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
                // Obtener trimestres que tienen actividades asociadas
                var trimestres = await _context.Activities
                    .Where(a => a.SchoolId == schoolId && a.Trimester != null)
                    .Select(a => a.Trimester!)
                    .Distinct()
                    .OrderBy(t => t)
                    .ToListAsync();

                _logger.LogInformation("Trimestres disponibles para escuela {SchoolId}: {Trimestres}", 
                    schoolId, string.Join(", ", trimestres));

                return trimestres;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error obteniendo trimestres para escuela {SchoolId}", schoolId);
                return new List<string>();
            }
        }

        public async Task<List<string>> ObtenerNivelesEducativosAsync()
        {
            return await Task.FromResult(new List<string> { "Premedia", "Media" });
        }

        public async Task<List<(Guid Id, string Nombre)>> ObtenerEspecialidadesAsync(Guid schoolId)
        {
            try
            {
                var especialidades = await _context.Specialties
                    .Where(s => s.SchoolId == schoolId || s.SchoolId == null)
                    .OrderBy(s => s.Name)
                    .Select(s => new { s.Id, s.Name })
                    .ToListAsync();

                return especialidades.Select(e => (e.Id, e.Name)).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error obteniendo especialidades");
                return new List<(Guid, string)>();
            }
        }

        public async Task<List<(Guid Id, string Nombre)>> ObtenerAreasAsync()
        {
            try
            {
                var areas = await _context.Areas
                    .Where(a => a.IsActive)
                    .OrderBy(a => a.DisplayOrder)
                    .ThenBy(a => a.Name)
                    .Select(a => new { a.Id, a.Name })
                    .ToListAsync();

                return areas.Select(a => (a.Id, a.Name)).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error obteniendo áreas");
                return new List<(Guid, string)>();
            }
        }

        public async Task<List<(Guid Id, string Nombre)>> ObtenerMateriasAsync(Guid schoolId, Guid? areaId = null, Guid? especialidadId = null)
        {
            try
            {
                var query = _context.Subjects
                    .Where(s => s.SchoolId == schoolId && s.Status == true);

                // Filtrar por área si se especifica
                if (areaId.HasValue)
                {
                    query = query.Where(s => s.AreaId == areaId.Value);
                }

                // Filtrar por especialidad si se especifica
                if (especialidadId.HasValue)
                {
                    var materiasDeEspecialidad = _context.SubjectAssignments
                        .Where(sa => sa.SpecialtyId == especialidadId.Value)
                        .Select(sa => sa.SubjectId)
                        .Distinct();

                    query = query.Where(s => materiasDeEspecialidad.Contains(s.Id));
                }

                var materias = await query
                    .OrderBy(s => s.Name)
                    .Select(s => new { s.Id, s.Name })
                    .ToListAsync();

                return materias.Select(m => (m.Id, m.Name)).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error obteniendo materias");
                return new List<(Guid, string)>();
            }
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

