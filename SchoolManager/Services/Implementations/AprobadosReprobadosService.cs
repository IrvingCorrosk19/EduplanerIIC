using Microsoft.EntityFrameworkCore;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using SchoolManager.ViewModels;

namespace SchoolManager.Services.Implementations
{
    public class AprobadosReprobadosService : IAprobadosReprobadosService
    {
        private readonly SchoolDbContext _context;
        private readonly ILogger<AprobadosReprobadosService> _logger;
        private readonly IHttpClientFactory _httpClientFactory;
        private const decimal NotaMinimaAprobacion = 3.0m;

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
            Guid materiaId,
            Guid groupId,
            Guid gradeLevelId,
            Guid? teacherScopeId = null)
        {
            var asignacion = await ValidarAsignacionFiltroAsync(schoolId, materiaId, groupId, gradeLevelId, teacherScopeId);

            var school = await _context.Schools.FindAsync(schoolId)
                ?? throw new Exception("Escuela no encontrada");

            var trimesterId = await _context.Trimesters
                .Where(t => t.SchoolId == schoolId && t.Name == trimestre)
                .Select(t => (Guid?)t.Id)
                .FirstOrDefaultAsync();

            var grupo = await _context.Groups.FindAsync(groupId)
                ?? throw new Exception("Grupo no encontrado");

            var gradoDisplay = !string.IsNullOrWhiteSpace(grupo.Grade)
                ? grupo.Grade.Trim()
                : $"{asignacion.GradeLevelName}°";

            var stats = await CalcularEstadisticasGrupoAsync(
                groupId, trimestre, trimesterId, materiaId, teacherScopeId);

            var estadisticas = new List<GradoEstadisticaDto>
            {
                new()
                {
                    Grado = gradoDisplay,
                    Grupo = grupo.Name ?? "",
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
                }
            };

            var etiquetaFiltro = $"{asignacion.SubjectName} — {asignacion.GradeLevelName} {asignacion.GroupName}";

            return new AprobadosReprobadosReportViewModel
            {
                InstitutoNombre = school.Name,
                LogoUrl = school.LogoUrl ?? "",
                ProfesorCoordinador = "",
                Trimestre = trimestre,
                AnoLectivo = DateTime.UtcNow.Year.ToString(),
                NivelEducativo = etiquetaFiltro,
                FechaGeneracion = DateTime.UtcNow,
                Estadisticas = estadisticas,
                TotalesGenerales = CalcularTotalesGenerales(estadisticas),
                TrimestresDisponibles = await ObtenerTrimestresDisponiblesAsync(schoolId)
            };
        }

        public async Task<List<string>> ObtenerTrimestresDisponiblesAsync(Guid schoolId)
        {
            return await _context.Trimesters
                .Where(t => t.SchoolId == schoolId)
                .OrderBy(t => t.Order)
                .Select(t => t.Name)
                .ToListAsync();
        }

        public async Task<List<(Guid Id, string Nombre)>> ObtenerMateriasFiltroAsync(Guid schoolId, Guid? teacherScopeId = null)
        {
            var rows = await CargarAsignacionesAsync(schoolId, teacherScopeId);
            return rows
                .GroupBy(r => r.SubjectId)
                .Select(g => (g.Key, g.First().SubjectName))
                .OrderBy(x => x.Item2)
                .ToList();
        }

        public async Task<List<AprobadosReprobadosGrupoFiltroDto>> ObtenerGruposFiltroAsync(
            Guid schoolId, Guid materiaId, Guid? teacherScopeId = null)
        {
            var rows = await CargarAsignacionesAsync(schoolId, teacherScopeId);
            return rows
                .Where(r => r.SubjectId == materiaId)
                .GroupBy(r => new { r.GroupId, r.GradeLevelId })
                .Select(g =>
                {
                    var first = g.First();
                    return new AprobadosReprobadosGrupoFiltroDto
                    {
                        GroupId = first.GroupId,
                        GradeLevelId = first.GradeLevelId,
                        Nombre = $"{first.GradeLevelName} {first.GroupName}",
                        GradoGrupo = first.GroupGrade
                    };
                })
                .OrderBy(g => g.Nombre)
                .ToList();
        }

        private async Task<AprobadosReprobadosAsignacionRow> ValidarAsignacionFiltroAsync(
            Guid schoolId,
            Guid materiaId,
            Guid groupId,
            Guid gradeLevelId,
            Guid? teacherScopeId)
        {
            var rows = await CargarAsignacionesAsync(schoolId, teacherScopeId);
            var match = rows.FirstOrDefault(r =>
                r.SubjectId == materiaId &&
                r.GroupId == groupId &&
                r.GradeLevelId == gradeLevelId);

            if (match == null)
                throw new UnauthorizedAccessException("La combinación materia/grupo no está disponible para este usuario.");

            return match;
        }

        /// <summary>
        /// Misma fuente que TeacherGradebook/Index: teacher_assignments → subject_assignments.
        /// Admin/director: todas las asignaciones de la escuela.
        /// </summary>
        private async Task<List<AprobadosReprobadosAsignacionRow>> CargarAsignacionesAsync(Guid schoolId, Guid? teacherScopeId)
        {
            if (teacherScopeId.HasValue)
            {
                return await _context.TeacherAssignments
                    .Where(ta => ta.TeacherId == teacherScopeId.Value)
                    .Select(ta => new AprobadosReprobadosAsignacionRow
                    {
                        SubjectId = ta.SubjectAssignment.SubjectId,
                        SubjectName = ta.SubjectAssignment.Subject!.Name,
                        GroupId = ta.SubjectAssignment.GroupId,
                        GroupName = ta.SubjectAssignment.Group!.Name,
                        GradeLevelId = ta.SubjectAssignment.GradeLevelId,
                        GradeLevelName = ta.SubjectAssignment.GradeLevel!.Name,
                        GroupGrade = ta.SubjectAssignment.Group.Grade
                    })
                    .ToListAsync();
            }

            var rows = await _context.SubjectAssignments
                .Where(sa => sa.SchoolId == schoolId || sa.Group!.SchoolId == schoolId)
                .Select(sa => new AprobadosReprobadosAsignacionRow
                {
                    SubjectId = sa.SubjectId,
                    SubjectName = sa.Subject.Name,
                    GroupId = sa.GroupId,
                    GroupName = sa.Group.Name,
                    GradeLevelId = sa.GradeLevelId,
                    GradeLevelName = sa.GradeLevel.Name,
                    GroupGrade = sa.Group.Grade
                })
                .ToListAsync();

            return rows
                .GroupBy(r => new { r.SubjectId, r.GroupId, r.GradeLevelId })
                .Select(g => g.First())
                .ToList();
        }

        private async Task<(int Total, int Aprobados, decimal PorcentajeAprobados,
            int Reprobados, decimal PorcentajeReprobados,
            int ReprobadosHastaLaFecha, decimal PorcentajeReprobadosHastaLaFecha,
            int SinCalificaciones, decimal PorcentajeSinCalificaciones,
            int Retirados, decimal PorcentajeRetirados)>
            CalcularEstadisticasGrupoAsync(
                Guid grupoId,
                string trimestre,
                Guid? trimesterId,
                Guid materiaId,
                Guid? teacherScopeId = null)
        {
            var estudiantesDelGrupo = await _context.StudentAssignments
                .Where(sa => sa.GroupId == grupoId && sa.IsActive)
                .Select(sa => sa.StudentId)
                .Distinct()
                .ToListAsync();

            var total = estudiantesDelGrupo.Count;
            if (total == 0)
                return (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

            var usuariosConStatus = await _context.Users
                .Where(u => estudiantesDelGrupo.Contains(u.Id))
                .Select(u => new { u.Id, u.Status })
                .ToListAsync();

            var setRetirados = usuariosConStatus
                .Where(u => string.Equals(u.Status, "inactive", StringComparison.OrdinalIgnoreCase) ||
                            string.Equals(u.Status, "retirado", StringComparison.OrdinalIgnoreCase))
                .Select(u => u.Id)
                .ToHashSet();

            var queryScores = _context.StudentActivityScores
                .Include(sas => sas.Activity)
                .Where(sas => estudiantesDelGrupo.Contains(sas.StudentId) &&
                    (trimesterId.HasValue
                        ? (sas.Activity!.TrimesterId == trimesterId || sas.Activity!.Trimester == trimestre)
                        : sas.Activity!.Trimester == trimestre) &&
                    sas.Activity!.SubjectId == materiaId);

            if (teacherScopeId.HasValue)
            {
                var puedeMateria = await _context.TeacherAssignments.AnyAsync(ta =>
                    ta.TeacherId == teacherScopeId.Value &&
                    ta.SubjectAssignment.GroupId == grupoId &&
                    ta.SubjectAssignment.SubjectId == materiaId);
                if (!puedeMateria)
                    return (total, 0, 0, 0, 0, 0, 0, total, 100m, 0, 0);
            }

            var todasCalificaciones = await queryScores.ToListAsync();

            int aprobados = 0, reprobados = 0, reprobadosHastaLaFecha = 0, sinCalificaciones = 0, retirados = 0;
            var calificacionesPorEstudiante = todasCalificaciones
                .GroupBy(c => c.StudentId)
                .ToDictionary(g => g.Key, g => g.ToList());

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

                var promedioMateria = calificaciones.Average(c => c.Score ?? 0);
                if (promedioMateria >= NotaMinimaAprobacion)
                    aprobados++;
                else
                {
                    reprobadosHastaLaFecha++;
                    reprobados++;
                }
            }

            return (
                total,
                aprobados,
                total > 0 ? aprobados * 100m / total : 0,
                reprobados,
                total > 0 ? reprobados * 100m / total : 0,
                reprobadosHastaLaFecha,
                total > 0 ? reprobadosHastaLaFecha * 100m / total : 0,
                sinCalificaciones,
                total > 0 ? sinCalificaciones * 100m / total : 0,
                retirados,
                total > 0 ? retirados * 100m / total : 0);
        }

        private static TotalesGeneralesDto CalcularTotalesGenerales(List<GradoEstadisticaDto> estadisticas)
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

        #region PDF institucional – solo capa visual (read-only, sin lógica de negocio)

        private const string PdfColorInstitutional = "#1f4e79";
        private const string PdfColorTotalRow = "#1a3a52";
        private const string PdfColorAprobacionFuerte = "#153a5e";
        private const string PdfColorAprobados = "#2e7d32";
        private const string PdfColorReprobados = "#c62828";
        private const float PdfMarginCm = 1.5f;
        private const float PdfLogoHeightPt = 60f;
        private const float PdfHeaderLinePt = 2f;

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
            if (string.IsNullOrWhiteSpace(logoUrl) ||
                (!logoUrl.StartsWith("http://", StringComparison.OrdinalIgnoreCase) &&
                 !logoUrl.StartsWith("https://", StringComparison.OrdinalIgnoreCase)))
                return null;
            try { return await _httpClientFactory.CreateClient().GetByteArrayAsync(logoUrl); }
            catch { return null; }
        }

        private static bool IsValidImageBytes(byte[] bytes)
        {
            if (bytes == null || bytes.Length < 4) return false;
            if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) return true;
            if (bytes[0] == 0xFF && bytes[1] == 0xD8) return true;
            if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) return true;
            return false;
        }

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

        private static void BuildInfoBlock(IContainer container, AprobadosReprobadosReportViewModel reporte)
        {
            container.PaddingBottom(12).Background(Colors.Grey.Lighten4).Padding(10).Row(r =>
            {
                r.RelativeItem().Column(c => { c.Item().Text("Coordinador").FontSize(7).FontColor(Colors.Grey.Darken1); c.Item().Text(reporte.ProfesorCoordinador).FontSize(9).Bold(); });
                r.RelativeItem().Column(c => { c.Item().Text("Trimestre").FontSize(7).FontColor(Colors.Grey.Darken1); c.Item().Text(reporte.Trimestre).FontSize(9); });
                r.RelativeItem().Column(c => { c.Item().Text("Año lectivo").FontSize(7).FontColor(Colors.Grey.Darken1); c.Item().Text(reporte.AnoLectivo).FontSize(9); });
                r.RelativeItem().Column(c => { c.Item().Text("Asignación").FontSize(7).FontColor(Colors.Grey.Darken1); c.Item().Text(reporte.NivelEducativo).FontSize(9); });
                r.RelativeItem().Column(c => { c.Item().Text("Fecha de generación").FontSize(7).FontColor(Colors.Grey.Darken1); c.Item().Text(reporte.FechaGeneracion.ToString("dd/MM/yyyy HH:mm")).FontSize(9); });
            });
        }

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
                foreach (var e in stats)
                {
                    table.Cell().PaddingVertical(6).PaddingHorizontal(6).AlignLeft().Text(e.Grado).FontSize(9);
                    table.Cell().PaddingVertical(6).PaddingHorizontal(6).AlignLeft().Text(e.Grupo).FontSize(9);
                    table.Cell().PaddingVertical(6).PaddingHorizontal(4).AlignCenter().Text(e.TotalEstudiantes.ToString()).FontSize(9);
                    table.Cell().PaddingVertical(6).PaddingHorizontal(4).AlignCenter().Text(e.Aprobados.ToString()).FontSize(9).FontColor(PdfColorAprobados);
                    table.Cell().PaddingVertical(6).PaddingHorizontal(4).AlignCenter().Text(e.Reprobados.ToString()).FontSize(9).FontColor(PdfColorReprobados);
                    table.Cell().PaddingVertical(6).PaddingHorizontal(4).AlignCenter().Text(e.ReprobadosHastaLaFecha.ToString()).FontSize(9);
                    table.Cell().PaddingVertical(6).PaddingHorizontal(4).AlignCenter().Text(e.SinCalificaciones.ToString()).FontSize(9).FontColor(Colors.Grey.Darken1);
                    table.Cell().PaddingVertical(6).PaddingHorizontal(4).AlignCenter().Text(e.Retirados.ToString()).FontSize(9);
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

        private static void BuildFooter(IContainer container, AprobadosReprobadosReportViewModel reporte)
        {
            var codigoValidacion = $"REP-APR-{reporte.FechaGeneracion:yyyy}-{reporte.Trimestre}-{reporte.FechaGeneracion:HHmm}";
            container.PaddingTop(8).BorderTop(1f).BorderColor(Colors.Grey.Lighten2).Row(r =>
            {
                r.RelativeItem().AlignLeft().DefaultTextStyle(x => x.FontSize(8).FontColor(Colors.Grey.Darken1))
                    .Text($"Sistema: SchoolManager · {reporte.FechaGeneracion:dd/MM/yyyy HH:mm} · Cód. validación: {codigoValidacion}");
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

        public Task<byte[]> ExportarAExcelAsync(AprobadosReprobadosReportViewModel reporte)
        {
            throw new NotImplementedException("Exportación a Excel pendiente de implementación");
        }

        public async Task<(bool Success, string Message)> PrepararDatosParaReporteAsync(Guid schoolId)
        {
            try
            {
                var trimester3T = await _context.Trimesters
                    .FirstOrDefaultAsync(t => t.SchoolId == schoolId && t.Name == "3T");
                if (trimester3T == null)
                    return (false, "No existe el trimestre 3T para esta escuela. Cree primero el trimestre en la configuración.");

                var activities = await _context.Activities.Where(a => a.SchoolId == schoolId).ToListAsync();
                foreach (var a in activities)
                {
                    a.Trimester = "3T";
                    a.TrimesterId = trimester3T.Id;
                }

                await _context.SaveChangesAsync();
                return (true, $"Datos preparados: {activities.Count} actividades asociadas al 3T.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error preparando datos para reporte aprobados/reprobados");
                return (false, $"Error: {ex.Message}");
            }
        }
    }
}
