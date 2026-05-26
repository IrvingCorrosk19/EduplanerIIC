using Microsoft.EntityFrameworkCore;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using SchoolManager.ViewModels;
using System.Text;
using System.Text.RegularExpressions;

namespace SchoolManager.Services.Implementations
{
    public class AprobadosReprobadosService : IAprobadosReprobadosService
    {
        private readonly SchoolDbContext _context;
        private readonly ILogger<AprobadosReprobadosService> _logger;
        private readonly IHttpClientFactory _httpClientFactory;
        private const decimal NOTA_MINIMA_APROBACION = 3.0m; // Escala 0-5, nota mínima para aprobar es 3.0

        private sealed class TeacherReportScope
        {
            public Dictionary<string, HashSet<Guid>> GroupIdsByNivel { get; init; } = new(StringComparer.OrdinalIgnoreCase);
            public Dictionary<string, HashSet<string>> GradesByNivel { get; init; } = new(StringComparer.OrdinalIgnoreCase);
            public Dictionary<string, HashSet<Guid>> SubjectIdsByNivel { get; init; } = new(StringComparer.OrdinalIgnoreCase);
            public Dictionary<string, HashSet<Guid>> SpecialtyIdsByNivel { get; init; } = new(StringComparer.OrdinalIgnoreCase);
            public Dictionary<string, HashSet<Guid>> AreaIdsByNivel { get; init; } = new(StringComparer.OrdinalIgnoreCase);
        }

        public AprobadosReprobadosService(
            SchoolDbContext context,
            ILogger<AprobadosReprobadosService> logger,
            IHttpClientFactory httpClientFactory)
        {
            _context = context;
            _logger = logger;
            _httpClientFactory = httpClientFactory;
        }

        public async Task<AprobadosReprobadosReportViewModel> GenerarReporteAsync(
            Guid schoolId,
            string trimestre,
            string nivelEducativo,
            string? gradoEspecifico = null,
            string? grupoEspecifico = null,
            Guid? especialidadId = null,
            Guid? areaId = null,
            Guid? materiaId = null,
            Guid? teacherScopeId = null)
        {
            try
            {
                _logger.LogInformation("📊 Generando reporte de aprobados/reprobados - School: {SchoolId}, Trimestre: {Trimestre}, Nivel: {Nivel}, TeacherScope: {TeacherScope}",
                    schoolId, trimestre, nivelEducativo, teacherScopeId);

                TeacherReportScope? teacherScope = null;
                if (teacherScopeId.HasValue)
                {
                    teacherScope = await LoadTeacherReportScopeAsync(teacherScopeId.Value);
                    if (!teacherScope.GroupIdsByNivel.Values.Any(s => s.Count > 0))
                    {
                        _logger.LogWarning("Docente {TeacherId} sin grupos asignados para el reporte", teacherScopeId.Value);
                    }
                }

                // Obtener información de la escuela
                var school = await _context.Schools.FindAsync(schoolId);
                if (school == null)
                    throw new Exception("Escuela no encontrada");

                // Resolver trimestre por nombre para filtrar por TrimesterId (actividades del 3T, etc.)
                var trimesterId = await _context.Trimesters
                    .Where(t => t.SchoolId == schoolId && t.Name == trimestre)
                    .Select(t => (Guid?)t.Id)
                    .FirstOrDefaultAsync();

                // Determinar los grados según el nivel educativo (acotados al docente si aplica)
                var grados = await ObtenerGradosPorNivelAsync(nivelEducativo, teacherScopeId);

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

                    if (teacherScope != null)
                    {
                        if (!teacherScope.GroupIdsByNivel.TryGetValue(nivelEducativo, out var allowedGroupIds) ||
                            allowedGroupIds.Count == 0)
                        {
                            continue;
                        }
                        gruposQuery = gruposQuery.Where(g => allowedGroupIds.Contains(g.Id));
                    }

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
                        var stats = await CalcularEstadisticasGrupoAsync(
                            grupo.Id, trimestre, trimesterId, materiaId, areaId, especialidadId, teacherScopeId);
                        
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

                // Obtener año lectivo actual (usar UTC para consistencia)
                var fechaActual = DateTime.UtcNow;
                var anoLectivo = fechaActual.Year.ToString();

                var reporte = new AprobadosReprobadosReportViewModel
                {
                    InstitutoNombre = school.Name,
                    LogoUrl = school.LogoUrl ?? "",
                    ProfesorCoordinador = "", // Se llenará desde el controlador con el usuario actual
                    Trimestre = trimestre,
                    AnoLectivo = anoLectivo,
                    NivelEducativo = nivelEducativo,
                    FechaGeneracion = fechaActual,
                    Estadisticas = estadisticas.OrderBy(e => e.Grado).ThenBy(e => e.Grupo).ToList(),
                    TotalesGenerales = totales,
                    TrimestresDisponibles = await ObtenerTrimestresDisponiblesAsync(schoolId),
                    NivelesDisponibles = await ObtenerNivelesEducativosAsync(teacherScopeId)
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
            CalcularEstadisticasGrupoAsync(Guid grupoId, string trimestre, Guid? trimesterId, Guid? materiaId = null, Guid? areaId = null, Guid? especialidadId = null, Guid? teacherScopeId = null)
        {
            _logger.LogInformation("Calculando estadísticas para grupo {GrupoId}, trimestre {Trimestre}", grupoId, trimestre);

            var estudiantesDelGrupo = await _context.StudentAssignments
                .Where(sa => sa.GroupId == grupoId && sa.IsActive)
                .Select(sa => sa.StudentId)
                .Distinct()
                .ToListAsync();

            int total = estudiantesDelGrupo.Count;
            if (total == 0)
            {
                return (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
            }

            // Una sola consulta: estados de usuarios (retirados), comparación insensible a mayúsculas
            var usuariosConStatus = await _context.Users
                .Where(u => estudiantesDelGrupo.Contains(u.Id))
                .Select(u => new { u.Id, u.Status })
                .ToListAsync();
            var setRetirados = usuariosConStatus
                .Where(u => string.Equals(u.Status, "inactive", StringComparison.OrdinalIgnoreCase) ||
                            string.Equals(u.Status, "retirado", StringComparison.OrdinalIgnoreCase))
                .Select(u => u.Id)
                .ToHashSet();

            // Una sola consulta: todas las calificaciones del trimestre para estos estudiantes (con Activity)
            var queryScores = _context.StudentActivityScores
                .Include(sas => sas.Activity)
                    .ThenInclude(a => a!.Subject)
                        .ThenInclude(s => s!.Area)
                .Where(sas => estudiantesDelGrupo.Contains(sas.StudentId) &&
                    (trimesterId.HasValue
                        ? (sas.Activity!.TrimesterId == trimesterId || sas.Activity!.Trimester == trimestre)
                        : sas.Activity!.Trimester == trimestre));
            if (teacherScopeId.HasValue)
            {
                var subjectIdsDocenteEnGrupo = await _context.TeacherAssignments
                    .Where(ta => ta.TeacherId == teacherScopeId.Value && ta.SubjectAssignment.GroupId == grupoId)
                    .Select(ta => ta.SubjectAssignment.SubjectId)
                    .Distinct()
                    .ToListAsync();
                if (subjectIdsDocenteEnGrupo.Count == 0)
                {
                    return (total, 0, 0, 0, 0, 0, 0, total, 100m, 0, 0);
                }
                queryScores = queryScores.Where(sas =>
                    sas.Activity!.SubjectId.HasValue && subjectIdsDocenteEnGrupo.Contains(sas.Activity.SubjectId.Value));
            }
            if (materiaId.HasValue)
                queryScores = queryScores.Where(sas => sas.Activity!.SubjectId == materiaId.Value);
            if (areaId.HasValue)
                queryScores = queryScores.Where(sas => sas.Activity!.Subject!.AreaId == areaId.Value);
            if (especialidadId.HasValue)
            {
                var subjectIdsEspecialidad = await _context.SubjectAssignments
                    .Where(sa => sa.SpecialtyId == especialidadId.Value)
                    .Select(sa => sa.SubjectId)
                    .ToListAsync();
                queryScores = queryScores.Where(sas => sas.Activity!.SubjectId.HasValue && subjectIdsEspecialidad.Contains(sas.Activity.SubjectId.Value));
            }
            var todasCalificaciones = await queryScores.ToListAsync();

            int aprobados = 0, reprobados = 0, reprobadosHastaLaFecha = 0, sinCalificaciones = 0, retirados = 0;
            var calificacionesPorEstudiante = todasCalificaciones.GroupBy(c => c.StudentId).ToDictionary(g => g.Key, g => g.ToList());

            foreach (var estudianteId in estudiantesDelGrupo)
            {
                if (setRetirados.Contains(estudianteId))
                {
                    retirados++;
                    continue;
                }
                if (!calificacionesPorEstudiante.TryGetValue(estudianteId, out var calificaciones) || !calificaciones.Any())
                {
                    sinCalificaciones++;
                    continue;
                }
                var materias = calificaciones
                    .GroupBy(c => c.Activity!.SubjectId)
                    .Select(g => new { SubjectId = g.Key, PromedioMateria = g.Average(c => c.Score ?? 0) })
                    .ToList();
                if (!materias.Any())
                {
                    sinCalificaciones++;
                    continue;
                }
                var promedioGeneral = materias.Average(m => m.PromedioMateria);
                var materiasReprobadas = materias.Count(m => m.PromedioMateria < NOTA_MINIMA_APROBACION);
                if (materiasReprobadas > 0)
                {
                    reprobadosHastaLaFecha++;
                    if (materiasReprobadas >= 3) reprobados++;
                }
                else if (promedioGeneral >= NOTA_MINIMA_APROBACION)
                {
                    aprobados++;
                }
            }

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

        private static List<string> GradosCatalogoPorNivel(string nivelEducativo)
        {
            return nivelEducativo.ToLower() switch
            {
                "premedia" => new List<string> { "7°", "8°", "9°" },
                "media" => new List<string> { "10°", "11°", "12°" },
                _ => new List<string>()
            };
        }

        private static int? ExtractGradeNumber(string? name)
        {
            if (string.IsNullOrWhiteSpace(name))
                return null;
            var match = Regex.Match(name, @"(\d+)");
            return match.Success && int.TryParse(match.Value, out var n) ? n : null;
        }

        private static string? ResolverNivelEducativoPorGrupo(string? groupGrade)
        {
            if (string.IsNullOrWhiteSpace(groupGrade))
                return null;
            if (GradosCatalogoPorNivel("premedia").Contains(groupGrade))
                return "Premedia";
            if (GradosCatalogoPorNivel("media").Contains(groupGrade))
                return "Media";
            return null;
        }

        /// <summary>
        /// Premedia del reporte = grupos 7°–9° con nivel académico 7–9 en grade_levels (excluye bachillerato técnico en esos grados).
        /// Media = grupos 10°–12° según la asignación del docente.
        /// </summary>
        private static bool AsignacionCuentaParaNivelReporte(string nivelEducativo, string? groupGrade, string? gradeLevelName)
        {
            var nivelGrupo = ResolverNivelEducativoPorGrupo(groupGrade);
            if (nivelGrupo == null ||
                !string.Equals(nivelGrupo, nivelEducativo, StringComparison.OrdinalIgnoreCase))
            {
                return false;
            }

            if (string.Equals(nivelEducativo, "media", StringComparison.OrdinalIgnoreCase))
                return true;

            var nivelAcademico = ExtractGradeNumber(gradeLevelName);
            return nivelAcademico is >= 7 and <= 9;
        }

        private async Task<TeacherReportScope> LoadTeacherReportScopeAsync(Guid teacherId)
        {
            var rows = await _context.TeacherAssignments
                .Where(ta => ta.TeacherId == teacherId)
                .Select(ta => new
                {
                    GroupId = ta.SubjectAssignment.GroupId,
                    SubjectId = ta.SubjectAssignment.SubjectId,
                    SpecialtyId = ta.SubjectAssignment.SpecialtyId,
                    GroupGrade = ta.SubjectAssignment.Group!.Grade,
                    GradeLevelName = ta.SubjectAssignment.GradeLevel!.Name,
                    AreaId = ta.SubjectAssignment.Subject!.AreaId
                })
                .ToListAsync();

            var scope = new TeacherReportScope();
            foreach (var row in rows)
            {
                var nivel = ResolverNivelEducativoPorGrupo(row.GroupGrade);
                if (nivel == null || !AsignacionCuentaParaNivelReporte(nivel, row.GroupGrade, row.GradeLevelName))
                    continue;

                AddToScope(scope.GroupIdsByNivel, nivel, row.GroupId);
                if (!string.IsNullOrWhiteSpace(row.GroupGrade))
                    AddToScope(scope.GradesByNivel, nivel, row.GroupGrade!);
                AddToScope(scope.SubjectIdsByNivel, nivel, row.SubjectId);
                AddToScope(scope.SpecialtyIdsByNivel, nivel, row.SpecialtyId);
                if (row.AreaId.HasValue)
                    AddToScope(scope.AreaIdsByNivel, nivel, row.AreaId.Value);
            }

            return scope;
        }

        private static void AddToScope<T>(Dictionary<string, HashSet<T>> dict, string nivel, T value)
        {
            if (!dict.TryGetValue(nivel, out var set))
            {
                set = new HashSet<T>();
                dict[nivel] = set;
            }
            set.Add(value);
        }

        public async Task<List<string>> ObtenerGradosPorNivelAsync(string nivelEducativo, Guid? teacherScopeId = null)
        {
            var catalogo = GradosCatalogoPorNivel(nivelEducativo);
            if (!teacherScopeId.HasValue)
                return catalogo;

            var scope = await LoadTeacherReportScopeAsync(teacherScopeId.Value);
            if (!scope.GradesByNivel.TryGetValue(nivelEducativo, out var grades) || grades.Count == 0)
                return new List<string>();

            return catalogo.Where(g => grades.Contains(g)).OrderBy(g => g).ToList();
        }

        public async Task<List<string>> ObtenerTrimestresDisponiblesAsync(Guid schoolId)
        {
            try
            {
                // Usar la tabla trimester de la escuela (1T, 2T, 3T) para que el reporte funcione
                // aunque solo esté activo un trimestre o las actividades usen TrimesterId
                var trimestres = await _context.Trimesters
                    .Where(t => t.SchoolId == schoolId)
                    .OrderBy(t => t.Order)
                    .Select(t => t.Name)
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

        public async Task<List<string>> ObtenerNivelesEducativosAsync(Guid? teacherScopeId = null)
        {
            var niveles = new List<string> { "Premedia", "Media" };
            if (!teacherScopeId.HasValue)
                return niveles;

            var scope = await LoadTeacherReportScopeAsync(teacherScopeId.Value);
            return niveles
                .Where(n => scope.GroupIdsByNivel.TryGetValue(n, out var g) && g.Count > 0)
                .ToList();
        }

        public async Task<List<(Guid Id, string Nombre)>> ObtenerEspecialidadesAsync(Guid schoolId, Guid? teacherScopeId = null, string? nivelEducativo = null)
        {
            try
            {
                var query = _context.Specialties
                    .Where(s => s.SchoolId == schoolId || s.SchoolId == null);

                if (teacherScopeId.HasValue)
                {
                    var scope = await LoadTeacherReportScopeAsync(teacherScopeId.Value);
                    var specialtyIds = ResolveScopeSet(scope.SpecialtyIdsByNivel, nivelEducativo);
                    if (specialtyIds.Count == 0)
                        return new List<(Guid, string)>();
                    query = query.Where(s => specialtyIds.Contains(s.Id));
                }

                var especialidades = await query
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

        public async Task<List<(Guid Id, string Nombre)>> ObtenerAreasAsync(Guid? teacherScopeId = null, string? nivelEducativo = null)
        {
            try
            {
                var query = _context.Areas.Where(a => a.IsActive);

                if (teacherScopeId.HasValue)
                {
                    var scope = await LoadTeacherReportScopeAsync(teacherScopeId.Value);
                    var areaIds = ResolveScopeSet(scope.AreaIdsByNivel, nivelEducativo);
                    if (areaIds.Count == 0)
                        return new List<(Guid, string)>();
                    query = query.Where(a => areaIds.Contains(a.Id));
                }

                var areas = await query
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

        public async Task<List<(Guid Id, string Nombre)>> ObtenerMateriasAsync(Guid schoolId, Guid? areaId = null, Guid? especialidadId = null, Guid? teacherScopeId = null, string? nivelEducativo = null)
        {
            try
            {
                var query = _context.Subjects
                    .Where(s => s.SchoolId == schoolId && s.Status == true);

                if (teacherScopeId.HasValue)
                {
                    var scope = await LoadTeacherReportScopeAsync(teacherScopeId.Value);
                    var subjectIds = ResolveScopeSet(scope.SubjectIdsByNivel, nivelEducativo);
                    if (subjectIds.Count == 0)
                        return new List<(Guid, string)>();
                    query = query.Where(s => subjectIds.Contains(s.Id));
                }

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

        private static HashSet<Guid> ResolveScopeSet(Dictionary<string, HashSet<Guid>> byNivel, string? nivelEducativo)
        {
            if (!string.IsNullOrWhiteSpace(nivelEducativo) &&
                byNivel.TryGetValue(nivelEducativo, out var forNivel))
            {
                return forNivel;
            }

            var union = new HashSet<Guid>();
            foreach (var set in byNivel.Values)
            {
                foreach (var id in set)
                    union.Add(id);
            }
            return union;
        }

        #region PDF institucional – solo capa visual (read-only, sin lógica de negocio)

        private const string PdfColorInstitutional = "#1f4e79";
        private const string PdfColorTotalRow = "#1a3a52";
        private const string PdfColorAprobacionFuerte = "#153a5e";
        private const string PdfColorAprobados = "#2e7d32";
        private const string PdfColorReprobados = "#c62828";
        private const float PdfMarginCm = 1.5f;
        private const float PdfLogoHeightPt = 60f;
        private const float PdfHeaderLinePt = 2f;
        private const float PdfFontSizeTablePt = 11.5f;

        /// <summary>Genera el PDF del reporte. Solo representación visual; no altera estado ni datos. Si logoBytes se pasa, se usa en lugar de descargar por URL.</summary>
        public async Task<byte[]> ExportarAPdfAsync(AprobadosReprobadosReportViewModel reporte, byte[]? logoBytes = null)
        {
            QuestPDF.Settings.License = LicenseType.Community;
            if (logoBytes == null)
                logoBytes = await TryDownloadLogoAsync(reporte.LogoUrl);
            if (logoBytes != null && !IsValidImageBytes(logoBytes))
                logoBytes = null;
            var doc = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Size(PageSizes.A4);
                    page.Margin(PdfMarginCm, Unit.Centimetre);
                    page.PageColor(Colors.White);
                    page.DefaultTextStyle(x => x.FontSize(9).FontFamily("Arial"));
                    page.Header().Element(c => BuildHeader(c, reporte, logoBytes));
                    page.Content().Layers(layers =>
                    {
                        layers.Layer().AlignCenter().AlignMiddle().Text(reporte.InstitutoNombre).FontSize(72).FontColor(Colors.Grey.Lighten2);
                        layers.PrimaryLayer().Element(c => BuildContent(c, reporte));
                    });
                    page.Footer().Element(c => BuildFooter(c, reporte));
                });
            });
            return doc.GeneratePdf();
        }

        private async Task<byte[]?> TryDownloadLogoAsync(string? logoUrl)
        {
            if (string.IsNullOrWhiteSpace(logoUrl) || (!logoUrl.StartsWith("http://", StringComparison.OrdinalIgnoreCase) && !logoUrl.StartsWith("https://", StringComparison.OrdinalIgnoreCase)))
                return null;
            try { return await _httpClientFactory.CreateClient().GetByteArrayAsync(logoUrl); }
            catch { return null; }
        }

        private static bool IsValidImageBytes(byte[] bytes)
        {
            if (bytes == null || bytes.Length < 4) return false;
            // PNG
            if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) return true;
            // JPEG
            if (bytes[0] == 0xFF && bytes[1] == 0xD8) return true;
            // GIF
            if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) return true;
            return false;
        }

        /// <summary>Encabezado institucional: logo arriba izquierda (max 60px), título 22pt, subtítulo 13pt gris, línea 2px, más espacio vertical.</summary>
        private static void BuildHeader(IContainer container, AprobadosReprobadosReportViewModel reporte, byte[]? logoBytes)
        {
            container.Column(col =>
            {
                col.Item().PaddingTop(4).PaddingBottom(14).Row(r =>
                {
                    if (logoBytes != null)
                        r.ConstantItem(PdfLogoHeightPt).Height(PdfLogoHeightPt).Image(logoBytes);
                    r.RelativeItem().PaddingLeft(logoBytes != null ? 12 : 0).AlignLeft().AlignMiddle().Column(c =>
                    {
                        c.Item().PaddingBottom(6).Text(reporte.InstitutoNombre).FontSize(22).Bold().FontColor(PdfColorInstitutional);
                        c.Item().Text("Cuadro de Aprobados y Reprobados por Grado").FontSize(13).FontColor(Colors.Grey.Darken2);
                    });
                });
                col.Item().LineHorizontal(PdfHeaderLinePt).LineColor(PdfColorInstitutional);
                col.Item().PaddingBottom(12);
            });
        }

        /// <summary>Bloque informativo: una fila con coordinador, trimestre, año, nivel, fecha de generación.</summary>
        private static void BuildInfoBlock(IContainer container, AprobadosReprobadosReportViewModel reporte)
        {
            container.PaddingBottom(12).Background(Colors.Grey.Lighten4).Padding(10).Row(r =>
            {
                r.RelativeItem().Column(c => { c.Item().Text("Coordinador").FontSize(7).FontColor(Colors.Grey.Darken1); c.Item().Text(reporte.ProfesorCoordinador).FontSize(9).Bold(); });
                r.RelativeItem().Column(c => { c.Item().Text("Trimestre").FontSize(7).FontColor(Colors.Grey.Darken1); c.Item().Text(reporte.Trimestre).FontSize(9); });
                r.RelativeItem().Column(c => { c.Item().Text("Año lectivo").FontSize(7).FontColor(Colors.Grey.Darken1); c.Item().Text(reporte.AnoLectivo).FontSize(9); });
                r.RelativeItem().Column(c => { c.Item().Text("Nivel").FontSize(7).FontColor(Colors.Grey.Darken1); c.Item().Text(reporte.NivelEducativo).FontSize(9); });
                r.RelativeItem().Column(c => { c.Item().Text("Fecha de generación").FontSize(7).FontColor(Colors.Grey.Darken1); c.Item().Text(reporte.FechaGeneracion.ToString("dd/MM/yyyy HH:mm")).FontSize(9); });
            });
        }

        /// <summary>Resumen ejecutivo: Total estudiantes bloque dominante, % aprobación azul fuerte, números 28-32pt.</summary>
        private static void BuildSummary(IContainer container, TotalesGeneralesDto totales)
        {
            var pctGeneral = totales.TotalEstudiantes > 0 ? Math.Round(totales.TotalAprobados * 100m / totales.TotalEstudiantes, 2) : 0m;
            container.PaddingBottom(16).Row(r =>
            {
                r.RelativeItem(2.2f).Background(Colors.White).Border(0.5f).BorderColor(Colors.Grey.Lighten2).Padding(14).AlignCenter().Column(c =>
                {
                    c.Item().Text("Total estudiantes").FontSize(9).FontColor(Colors.Grey.Darken2);
                    c.Item().PaddingTop(6).Text(totales.TotalEstudiantes.ToString()).FontSize(30).Bold().FontColor(PdfColorInstitutional);
                });
                r.ConstantItem(10);
                r.RelativeItem().Background(Colors.White).Border(0.5f).BorderColor(Colors.Grey.Lighten2).Padding(12).AlignCenter().Column(c =>
                {
                    c.Item().Text("Aprobados").FontSize(8).FontColor(Colors.Grey.Darken2);
                    c.Item().PaddingTop(4).Text(totales.TotalAprobados.ToString()).FontSize(28).Bold().FontColor(PdfColorAprobados);
                });
                r.ConstantItem(10);
                r.RelativeItem().Background(Colors.White).Border(0.5f).BorderColor(Colors.Grey.Lighten2).Padding(12).AlignCenter().Column(c =>
                {
                    c.Item().Text("Reprobados").FontSize(8).FontColor(Colors.Grey.Darken2);
                    c.Item().PaddingTop(4).Text(totales.TotalReprobados.ToString()).FontSize(28).Bold().FontColor(PdfColorReprobados);
                });
                r.ConstantItem(10);
                r.RelativeItem(1.4f).Background(PdfColorAprobacionFuerte).Border(0.5f).BorderColor(Colors.Grey.Lighten1).Padding(14).AlignCenter().Column(c =>
                {
                    c.Item().Text("% Aprobación general").FontSize(9).FontColor(Colors.White);
                    c.Item().PaddingTop(6).Text($"{pctGeneral:F1}%").FontSize(30).Bold().FontColor(Colors.White);
                });
            });
        }

        /// <summary>Tabla principal: encabezados cortos en una línea, solo números, Grado/Grupo a la izquierda, zebra, fila TOTAL con fondo institucional.</summary>
        private static void BuildMainTable(IContainer container, List<GradoEstadisticaDto> stats, TotalesGeneralesDto totales)
        {
            container.Table(table =>
            {
                table.ColumnsDefinition(def =>
                {
                    def.RelativeColumn(0.8f);
                    def.RelativeColumn(0.8f);
                    def.RelativeColumn(1f);
                    def.RelativeColumn(1f);
                    def.RelativeColumn(1f);
                    def.RelativeColumn(1.2f);
                    def.RelativeColumn(1f);
                    def.RelativeColumn(0.9f);
                });
                table.Header(header =>
                {
                    header.Cell().Background(PdfColorInstitutional).PaddingVertical(8).PaddingHorizontal(6).AlignLeft().Text("Grado").FontSize(9).Bold().FontColor(Colors.White);
                    header.Cell().Background(PdfColorInstitutional).PaddingVertical(8).PaddingHorizontal(6).AlignLeft().Text("Grupo").FontSize(9).Bold().FontColor(Colors.White);
                    header.Cell().Background(PdfColorInstitutional).PaddingVertical(8).PaddingHorizontal(4).AlignCenter().Text("Total").FontSize(9).Bold().FontColor(Colors.White);
                    header.Cell().Background(PdfColorInstitutional).PaddingVertical(8).PaddingHorizontal(4).AlignCenter().Text("Aprob.").FontSize(9).Bold().FontColor(Colors.White);
                    header.Cell().Background(PdfColorInstitutional).PaddingVertical(8).PaddingHorizontal(4).AlignCenter().Text("Reprob.").FontSize(9).Bold().FontColor(Colors.White);
                    header.Cell().Background(PdfColorInstitutional).PaddingVertical(8).PaddingHorizontal(4).AlignCenter().Text("Rep.hasta").FontSize(9).Bold().FontColor(Colors.White);
                    header.Cell().Background(PdfColorInstitutional).PaddingVertical(8).PaddingHorizontal(4).AlignCenter().Text("Sin Cal.").FontSize(9).Bold().FontColor(Colors.White);
                    header.Cell().Background(PdfColorInstitutional).PaddingVertical(8).PaddingHorizontal(4).AlignCenter().Text("Retir.").FontSize(9).Bold().FontColor(Colors.White);
                });
                int rowIndex = 0;
                string? lastGrado = null;
                foreach (var e in stats)
                {
                    if (lastGrado != null && lastGrado != e.Grado)
                        _ = table.Cell().ColumnSpan(8).Height(2).Background(Colors.White);
                    lastGrado = e.Grado;
                    var rowBg = rowIndex % 2 == 0 ? Colors.White : Colors.Grey.Lighten4;
                    table.Cell().Background(rowBg).PaddingVertical(6).PaddingHorizontal(6).AlignLeft().Text(e.Grado).FontSize(9);
                    table.Cell().Background(rowBg).PaddingVertical(6).PaddingHorizontal(6).AlignLeft().Text(e.Grupo).FontSize(9);
                    table.Cell().Background(rowBg).PaddingVertical(6).PaddingHorizontal(4).AlignCenter().Text(e.TotalEstudiantes.ToString()).FontSize(9);
                    table.Cell().Background(rowBg).PaddingVertical(6).PaddingHorizontal(4).AlignCenter().Text(e.Aprobados.ToString()).FontSize(9).FontColor(PdfColorAprobados);
                    table.Cell().Background(rowBg).PaddingVertical(6).PaddingHorizontal(4).AlignCenter().Text(e.Reprobados.ToString()).FontSize(9).FontColor(PdfColorReprobados);
                    table.Cell().Background(rowBg).PaddingVertical(6).PaddingHorizontal(4).AlignCenter().Text(e.ReprobadosHastaLaFecha.ToString()).FontSize(9);
                    table.Cell().Background(rowBg).PaddingVertical(6).PaddingHorizontal(4).AlignCenter().Text(e.SinCalificaciones.ToString()).FontSize(9).FontColor(Colors.Grey.Darken1);
                    table.Cell().Background(rowBg).PaddingVertical(6).PaddingHorizontal(4).AlignCenter().Text(e.Retirados.ToString()).FontSize(9);
                    rowIndex++;
                }
                table.Cell().ColumnSpan(2).Background(PdfColorTotalRow).PaddingVertical(8).PaddingHorizontal(6).AlignLeft().Text("TOTALES").FontSize(10).Bold().FontColor(Colors.White);
                table.Cell().Background(PdfColorTotalRow).PaddingVertical(8).PaddingHorizontal(4).AlignCenter().Text(totales.TotalEstudiantes.ToString()).FontSize(10).Bold().FontColor(Colors.White);
                table.Cell().Background(PdfColorTotalRow).PaddingVertical(8).PaddingHorizontal(4).AlignCenter().Text(totales.TotalAprobados.ToString()).FontSize(10).Bold().FontColor("#c8e6c9");
                table.Cell().Background(PdfColorTotalRow).PaddingVertical(8).PaddingHorizontal(4).AlignCenter().Text(totales.TotalReprobados.ToString()).FontSize(10).Bold().FontColor("#ffcdd2");
                table.Cell().Background(PdfColorTotalRow).PaddingVertical(8).PaddingHorizontal(4).AlignCenter().Text(totales.TotalReprobadosHastaLaFecha.ToString()).FontSize(10).Bold().FontColor(Colors.White);
                table.Cell().Background(PdfColorTotalRow).PaddingVertical(8).PaddingHorizontal(4).AlignCenter().Text(totales.TotalSinCalificaciones.ToString()).FontSize(10).Bold().FontColor(Colors.White);
                table.Cell().Background(PdfColorTotalRow).PaddingVertical(8).PaddingHorizontal(4).AlignCenter().Text(totales.TotalRetirados.ToString()).FontSize(10).Bold().FontColor(Colors.White);
            });
        }

        /// <summary>Pie de página auditable: línea separadora sutil, Sistema, fecha completa, Página X de Y, código de validación.</summary>
        private static void BuildFooter(IContainer container, AprobadosReprobadosReportViewModel reporte)
        {
            var codigoValidacion = $"REP-APR-{reporte.FechaGeneracion:yyyy}-{reporte.Trimestre}-{reporte.FechaGeneracion:HHmm}";
            var fechaCompleta = reporte.FechaGeneracion.ToString("dd/MM/yyyy HH:mm");
            container.PaddingTop(8).BorderTop(1f).BorderColor(Colors.Grey.Lighten2).Row(r =>
            {
                r.RelativeItem().AlignLeft().DefaultTextStyle(x => x.FontSize(8).FontColor(Colors.Grey.Darken1))
                    .Text($"Sistema: SchoolManager · {fechaCompleta} · Cód. validación: {codigoValidacion}");
                r.RelativeItem().AlignRight().DefaultTextStyle(x => x.FontSize(8).FontColor(Colors.Grey.Darken1))
                    .Text(t => { t.CurrentPageNumber().Format(n => $"Página {n} de "); t.TotalPages().Format(n => $"{n}"); });
            });
        }

        private static void BuildContent(IContainer container, AprobadosReprobadosReportViewModel reporte)
        {
            var stats = reporte.Estadisticas ?? new List<GradoEstadisticaDto>();
            var totales = reporte.TotalesGenerales ?? new TotalesGeneralesDto();

            container.Column(col =>
            {
                col.Item().Element(c => BuildInfoBlock(c, reporte));
                if (stats.Count == 0)
                {
                    col.Item().PaddingTop(12).AlignCenter().Text("No hay datos para los filtros seleccionados.").FontSize(10).FontColor(Colors.Grey.Darken1);
                    return;
                }
                col.Item().Element(c => BuildSummary(c, totales));
                col.Item().Element(c => BuildMainTable(c, stats, totales));
            });
        }

        #endregion

        public async Task<byte[]> ExportarAExcelAsync(AprobadosReprobadosReportViewModel reporte)
        {
            // TODO: Implementar exportación a Excel usando ClosedXML o EPPlus
            await Task.CompletedTask;
            throw new NotImplementedException("Exportación a Excel pendiente de implementación");
        }

        public async Task<(bool Success, string Message)> PrepararDatosParaReporteAsync(Guid schoolId)
        {
            try
            {
                var trimester3T = await _context.Trimesters
                    .FirstOrDefaultAsync(t => t.SchoolId == schoolId && t.Name == "3T");
                if (trimester3T == null)
                {
                    return (false, "No existe el trimestre 3T para esta escuela. Cree primero el trimestre en la configuración.");
                }

                var activities = await _context.Activities.Where(a => a.SchoolId == schoolId).ToListAsync();
                foreach (var a in activities)
                {
                    a.Trimester = "3T";
                    a.TrimesterId = trimester3T.Id;
                }
                var activitiesUpdated = activities.Count;

                var groupNamesByGrade = new Dictionary<string, string[]>
                {
                    ["7°"] = new[] { "A", "A1", "A2" },
                    ["8°"] = new[] { "B", "C", "C1", "C2" },
                    ["9°"] = new[] { "D", "E", "E1", "E2" },
                    ["10°"] = new[] { "F", "G", "H" },
                    ["11°"] = new[] { "I", "J", "K" },
                    ["12°"] = new[] { "L", "M", "N" }
                };
                int groupsUpdated = 0;
                foreach (var kv in groupNamesByGrade)
                {
                    var groups = await _context.Groups
                        .Where(g => g.SchoolId == schoolId && kv.Value.Contains(g.Name) && (g.Grade == null || g.Grade == ""))
                        .ToListAsync();
                    foreach (var g in groups)
                    {
                        g.Grade = kv.Key;
                        groupsUpdated++;
                    }
                }

                await _context.SaveChangesAsync();
                _logger.LogInformation("PrepararDatosParaReporte: school {SchoolId}, activities actualizadas {A}, grupos actualizados {G}", schoolId, activitiesUpdated, groupsUpdated);
                return (true, $"Datos preparados: {activitiesUpdated} actividades asociadas al 3T y {groupsUpdated} grupos con grado asignado. Genere el reporte con Trimestre 3T y Nivel Media o Premedia.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error preparando datos para reporte aprobados/reprobados");
                return (false, $"Error: {ex.Message}");
            }
        }
    }
}

