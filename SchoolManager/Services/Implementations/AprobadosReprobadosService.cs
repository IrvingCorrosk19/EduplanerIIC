using Microsoft.EntityFrameworkCore;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
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
        private readonly IHttpClientFactory _httpClientFactory;
        private const decimal NOTA_MINIMA_APROBACION = 3.0m; // Escala 0-5, nota mínima para aprobar es 3.0

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

                // Resolver trimestre por nombre para filtrar por TrimesterId (actividades del 3T, etc.)
                var trimesterId = await _context.Trimesters
                    .Where(t => t.SchoolId == schoolId && t.Name == trimestre)
                    .Select(t => (Guid?)t.Id)
                    .FirstOrDefaultAsync();

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
                        var stats = await CalcularEstadisticasGrupoAsync(grupo.Id, trimestre, trimesterId, materiaId, areaId, especialidadId);
                        
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
            CalcularEstadisticasGrupoAsync(Guid grupoId, string trimestre, Guid? trimesterId, Guid? materiaId = null, Guid? areaId = null, Guid? especialidadId = null)
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
            QuestPDF.Settings.License = LicenseType.Community;
            byte[]? logoBytes = null;
            if (!string.IsNullOrWhiteSpace(reporte.LogoUrl) && (reporte.LogoUrl.StartsWith("http://", StringComparison.OrdinalIgnoreCase) || reporte.LogoUrl.StartsWith("https://", StringComparison.OrdinalIgnoreCase)))
            {
                try
                {
                    var http = _httpClientFactory.CreateClient();
                    logoBytes = await http.GetByteArrayAsync(reporte.LogoUrl);
                }
                catch { /* logo opcional */ }
            }

            var doc = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Size(PageSizes.A4);
                    page.Margin(1.5f, Unit.Centimetre);
                    page.PageColor(Colors.White);
                    page.DefaultTextStyle(x => x.FontSize(9));

                    page.Header().Element(c => ComposeHeader(c, reporte, logoBytes));
                    page.Content().Element(c => ComposeContent(c, reporte));
                    page.Footer().Element(c => ComposeFooter(c, reporte));
                });
            });
            return doc.GeneratePdf();
        }

        private static void ComposeHeader(IContainer container, AprobadosReprobadosReportViewModel reporte, byte[]? logoBytes)
        {
            container.Column(col =>
            {
                col.Item().PaddingBottom(8).Row(r =>
                {
                    if (logoBytes != null)
                        r.ConstantItem(50).Height(50).Image(logoBytes);
                    r.RelativeItem().AlignCenter().Column(c =>
                    {
                        c.Item().Text(reporte.InstitutoNombre).FontSize(14).Bold().FontColor(Colors.Blue.Darken2);
                        c.Item().Text("CUADRO DE APROBADOS Y REPROBADOS POR GRADO DEL TRIMESTRE").FontSize(11).SemiBold();
                    });
                });
                col.Item().PaddingBottom(4).Text($"Profesor(a) Coordinador(a): {reporte.ProfesorCoordinador}").FontSize(10);
                col.Item().Text($"Trimestre: {reporte.Trimestre} | Año Lectivo: {reporte.AnoLectivo} | Nivel: {reporte.NivelEducativo}").FontSize(10);
                col.Item().PaddingBottom(6).LineHorizontal(1).LineColor(Colors.Blue.Darken2);
            });
        }

        private static void ComposeContent(IContainer container, AprobadosReprobadosReportViewModel reporte)
        {
            container.Column(col =>
            {
                var stats = reporte.Estadisticas ?? new List<GradoEstadisticaDto>();
                var totales = reporte.TotalesGenerales ?? new TotalesGeneralesDto();

                if (stats.Count == 0)
                {
                    col.Item().PaddingTop(20).AlignCenter().Text("No hay datos para los filtros seleccionados.").FontSize(10).FontColor(Colors.Grey.Darken1);
                    return;
                }

                col.Item().Table(table =>
                {
                    table.ColumnsDefinition(def =>
                    {
                        def.ConstantColumn(32);  // Grado
                        def.ConstantColumn(32); // Grupo
                        def.ConstantColumn(38); // Total
                        def.ConstantColumn(28); // Aprob T
                        def.ConstantColumn(24); // Aprob %
                        def.ConstantColumn(28); // Rep T
                        def.ConstantColumn(24); // Rep %
                        def.ConstantColumn(32); // Rep hasta T
                        def.ConstantColumn(24); // %
                        def.ConstantColumn(32); // Sin calif T
                        def.ConstantColumn(24); // %
                        def.ConstantColumn(28); // Ret T
                        def.ConstantColumn(24); // %
                    });
                    table.Header(header =>
                    {
                        header.Cell().Background(Colors.Grey.Lighten3).AlignCenter().Text("Grado").FontSize(8).Bold();
                        header.Cell().Background(Colors.Grey.Lighten3).AlignCenter().Text("Grupo").FontSize(8).Bold();
                        header.Cell().Background(Colors.Grey.Lighten3).AlignCenter().Text("Total").FontSize(8).Bold();
                        header.Cell().Background(Colors.Grey.Lighten3).AlignCenter().Text("Aprob.T").FontSize(7).Bold();
                        header.Cell().Background(Colors.Grey.Lighten3).AlignCenter().Text("Aprob.%").FontSize(7).Bold();
                        header.Cell().Background(Colors.Grey.Lighten3).AlignCenter().Text("Rep.T").FontSize(7).Bold();
                        header.Cell().Background(Colors.Grey.Lighten3).AlignCenter().Text("Rep.%").FontSize(7).Bold();
                        header.Cell().Background(Colors.Grey.Lighten3).AlignCenter().Text("Rep.H.T").FontSize(7).Bold();
                        header.Cell().Background(Colors.Grey.Lighten3).AlignCenter().Text("Rep.H.%").FontSize(7).Bold();
                        header.Cell().Background(Colors.Grey.Lighten3).AlignCenter().Text("SinC.T").FontSize(7).Bold();
                        header.Cell().Background(Colors.Grey.Lighten3).AlignCenter().Text("SinC.%").FontSize(7).Bold();
                        header.Cell().Background(Colors.Grey.Lighten3).AlignCenter().Text("Ret.T").FontSize(7).Bold();
                        header.Cell().Background(Colors.Grey.Lighten3).AlignCenter().Text("Ret.%").FontSize(7).Bold();
                    });
                    foreach (var e in stats)
                    {
                        table.Cell().AlignCenter().Text(e.Grado).FontSize(8);
                        table.Cell().AlignCenter().Text(e.Grupo).FontSize(8);
                        table.Cell().AlignCenter().Text(e.TotalEstudiantes.ToString()).FontSize(8);
                        table.Cell().AlignCenter().Text(e.Aprobados.ToString()).FontSize(8).FontColor(Colors.Green.Darken2);
                        table.Cell().AlignCenter().Text($"{e.PorcentajeAprobados:F2}%").FontSize(8);
                        table.Cell().AlignCenter().Text(e.Reprobados.ToString()).FontSize(8).FontColor(Colors.Red.Darken2);
                        table.Cell().AlignCenter().Text($"{e.PorcentajeReprobados:F2}%").FontSize(8);
                        table.Cell().AlignCenter().Text(e.ReprobadosHastaLaFecha.ToString()).FontSize(8);
                        table.Cell().AlignCenter().Text($"{e.PorcentajeReprobadosHastaLaFecha:F2}%").FontSize(8);
                        table.Cell().AlignCenter().Text(e.SinCalificaciones.ToString()).FontSize(8);
                        table.Cell().AlignCenter().Text($"{e.PorcentajeSinCalificaciones:F2}%").FontSize(8);
                        table.Cell().AlignCenter().Text(e.Retirados.ToString()).FontSize(8);
                        table.Cell().AlignCenter().Text($"{e.PorcentajeRetirados:F2}%").FontSize(8);
                    }
                    table.Cell().ColumnSpan(2).Background(Colors.Blue.Lighten4).AlignCenter().Text("TOTALES").FontSize(9).Bold();
                    table.Cell().Background(Colors.Blue.Lighten4).AlignCenter().Text(totales.TotalEstudiantes.ToString()).FontSize(9).Bold();
                    table.Cell().Background(Colors.Blue.Lighten4).AlignCenter().Text(totales.TotalAprobados.ToString()).FontSize(9).Bold().FontColor(Colors.Green.Darken2);
                    table.Cell().Background(Colors.Blue.Lighten4).AlignCenter().Text($"{totales.PorcentajeAprobados:F2}%").FontSize(9).Bold();
                    table.Cell().Background(Colors.Blue.Lighten4).AlignCenter().Text(totales.TotalReprobados.ToString()).FontSize(9).Bold().FontColor(Colors.Red.Darken2);
                    table.Cell().Background(Colors.Blue.Lighten4).AlignCenter().Text($"{totales.PorcentajeReprobados:F2}%").FontSize(9).Bold();
                    table.Cell().Background(Colors.Blue.Lighten4).AlignCenter().Text(totales.TotalReprobadosHastaLaFecha.ToString()).FontSize(9).Bold();
                    table.Cell().Background(Colors.Blue.Lighten4).AlignCenter().Text($"{totales.PorcentajeReprobadosHastaLaFecha:F2}%").FontSize(9).Bold();
                    table.Cell().Background(Colors.Blue.Lighten4).AlignCenter().Text(totales.TotalSinCalificaciones.ToString()).FontSize(9).Bold();
                    table.Cell().Background(Colors.Blue.Lighten4).AlignCenter().Text($"{totales.PorcentajeSinCalificaciones:F2}%").FontSize(9).Bold();
                    table.Cell().Background(Colors.Blue.Lighten4).AlignCenter().Text(totales.TotalRetirados.ToString()).FontSize(9).Bold();
                    table.Cell().Background(Colors.Blue.Lighten4).AlignCenter().Text($"{totales.PorcentajeRetirados:F2}%").FontSize(9).Bold();
                });
            });
        }

        private static void ComposeFooter(IContainer container, AprobadosReprobadosReportViewModel reporte)
        {
            container.Row(r =>
            {
                r.RelativeItem().AlignLeft().Text(x => { x.Span("Fecha de generación: "); x.Span(reporte.FechaGeneracion.ToString("dd/MM/yyyy HH:mm")).FontColor(Colors.Grey.Darken1).FontSize(8); });
                r.RelativeItem().AlignCenter().DefaultTextStyle(x => x.FontSize(9)).Text(text => text.CurrentPageNumber().Format(n => $"Pág. {n}"));
                r.RelativeItem().AlignRight().DefaultTextStyle(x => x.FontSize(9)).Text(text => text.TotalPages().Format(n => $"de {n}"));
            });
        }

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

