using Microsoft.EntityFrameworkCore;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using SchoolManager.Dtos;
using SchoolManager.Interfaces;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using System.Globalization;

namespace SchoolManager.Services.Implementations;

public class TeacherGradebookPdfService : ITeacherGradebookPdfService
{
    private const string PdfColorPrimary = "#2563eb";
    private const string PdfColorPrimaryDark = "#1e40af";
    private const string PdfColorApproved = "#15803d";
    private const string PdfColorFailed = "#b91c1c";
    private const string PdfColorMuted = "#64748b";

    private static readonly string[] TypeOrder =
    {
        "notas de apreciación",
        "ejercicios diarios",
        "examen final",
        "recuperación"
    };

    private readonly SchoolDbContext _context;
    private readonly IStudentActivityScoreService _scoreService;
    private readonly IStudentService _studentService;
    private readonly ICurrentUserService _currentUserService;
    private readonly ISuperAdminService _superAdminService;

    public TeacherGradebookPdfService(
        SchoolDbContext context,
        IStudentActivityScoreService scoreService,
        IStudentService studentService,
        ICurrentUserService currentUserService,
        ISuperAdminService superAdminService)
    {
        _context = context;
        _scoreService = scoreService;
        _studentService = studentService;
        _currentUserService = currentUserService;
        _superAdminService = superAdminService;
    }

    public async Task<byte[]> GenerateRegistroPdfAsync(
        Guid teacherId,
        Guid groupId,
        string trimester,
        Guid subjectId,
        Guid gradeLevelId,
        byte[]? logoBytes = null)
    {
        var model = await BuildModelAsync(teacherId, groupId, trimester, subjectId, gradeLevelId);

        if (logoBytes == null &&
            !string.IsNullOrWhiteSpace(model.LogoUrl) &&
            !model.LogoUrl.StartsWith("http://", StringComparison.OrdinalIgnoreCase) &&
            !model.LogoUrl.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
        {
            logoBytes = await _superAdminService.GetLogoAsync(model.LogoUrl);
        }

        QuestPDF.Settings.License = LicenseType.Community;
        return BuildPdf(model, logoBytes);
    }

    private async Task<GradebookPdfDto> BuildModelAsync(
        Guid teacherId,
        Guid groupId,
        string trimester,
        Guid subjectId,
        Guid gradeLevelId)
    {
        var hasAssignment = await _context.TeacherAssignments.AnyAsync(ta =>
            ta.TeacherId == teacherId &&
            ta.SubjectAssignment.GroupId == groupId &&
            ta.SubjectAssignment.SubjectId == subjectId &&
            ta.SubjectAssignment.GradeLevelId == gradeLevelId);

        if (!hasAssignment)
            throw new UnauthorizedAccessException("No tiene asignación para esta materia y grupo.");

        var book = await _scoreService.GetGradeBookAsync(teacherId, groupId, trimester, subjectId, gradeLevelId);
        var students = (await _studentService.GetBySubjectGroupAndGradeAsync(subjectId, groupId, gradeLevelId))
            .OrderBy(s => s.FullName)
            .ToList();

        var teacher = await _context.Users.AsNoTracking().FirstOrDefaultAsync(u => u.Id == teacherId)
            ?? throw new InvalidOperationException("Docente no encontrado.");
        var subject = await _context.Subjects.AsNoTracking().FirstOrDefaultAsync(s => s.Id == subjectId);
        var group = await _context.Groups.AsNoTracking().FirstOrDefaultAsync(g => g.Id == groupId);
        var gradeLevel = await _context.GradeLevels.AsNoTracking().FirstOrDefaultAsync(g => g.Id == gradeLevelId);

        var currentUser = await _currentUserService.GetCurrentUserAsync();
        var school = currentUser?.SchoolId != null
            ? await _context.Schools.AsNoTracking().FirstOrDefaultAsync(s => s.Id == currentUser.SchoolId)
            : null;

        var activitiesByType = book.Activities
            .GroupBy(a => NormalizeType(a.Type))
            .ToDictionary(g => g.Key, g => g.ToList());

        var typeSections = new List<GradebookPdfTypeSectionDto>();
        foreach (var typeKey in TypeOrder)
        {
            if (!activitiesByType.TryGetValue(typeKey, out var acts) || acts.Count == 0)
                continue;

            typeSections.Add(new GradebookPdfTypeSectionDto
            {
                TypeKey = typeKey,
                TypeLabel = CultureInfo.CurrentCulture.TextInfo.ToTitleCase(typeKey),
                ShortLabel = TypeShortLabel(typeKey),
                Activities = acts.Select(a => new GradebookPdfActivityColDto
                {
                    Id = a.Id,
                    Name = a.Name,
                    DueDateDisplay = a.DueDate?.ToString("dd/MM/yyyy")
                }).ToList()
            });
        }

        var studentRows = new List<GradebookPdfStudentRowDto>();
        var bookRows = book.Rows.ToDictionary(r => r.StudentId);

        var index = 1;
        foreach (var stu in students)
        {
            bookRows.TryGetValue(stu.StudentId, out var gradeRow);
            var scores = gradeRow?.ScoresByActivity ?? new Dictionary<Guid, decimal?>();

            var typeAvgs = new Dictionary<string, decimal>();
            foreach (var section in typeSections)
            {
                var values = section.Activities
                    .Select(a => scores.TryGetValue(a.Id, out var v) ? v : null)
                    .Where(v => v.HasValue && v.Value > 0)
                    .Select(v => v!.Value)
                    .ToList();

                var avg = values.Count > 0 ? TruncateOneDecimal(values.Average()) : 0m;
                typeAvgs[section.TypeKey] = avg;
            }

            var finalGrade = ComputeFinalGrade(typeAvgs, typeSections.Select(s => s.TypeKey).ToList());

            studentRows.Add(new GradebookPdfStudentRowDto
            {
                Number = index++,
                Name = stu.FullName,
                DocumentId = stu.DocumentId ?? "",
                ScoresByActivityId = scores.ToDictionary(k => k.Key, k => k.Value),
                TypeAverages = typeAvgs,
                FinalGrade = finalGrade
            });
        }

        return new GradebookPdfDto
        {
            SchoolName = school?.Name ?? "Institución educativa",
            LogoUrl = school?.LogoUrl,
            TeacherName = $"{teacher.Name} {teacher.LastName}".Trim(),
            SubjectName = subject?.Name ?? "Materia",
            GroupLabel = $"{gradeLevel?.Name} {group?.Name}".Trim(),
            Trimester = trimester,
            AcademicYear = DateTime.UtcNow.Year.ToString(),
            GeneratedAt = DateTime.UtcNow,
            TypeSections = typeSections,
            Students = studentRows
        };
    }

    private static byte[] BuildPdf(GradebookPdfDto model, byte[]? logoBytes)
    {
        var activityColumns = model.TypeSections.Sum(s => s.Activities.Count);
        var promColumns = model.TypeSections.Count;
        var totalDataCols = activityColumns + promColumns + 1;

        return Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4.Landscape());
                page.Margin(28);
                page.DefaultTextStyle(x => x.FontSize(8).FontFamily("Arial").FontColor(Colors.Grey.Darken3));
                page.Background().AlignCenter().AlignMiddle()
                    .Text(model.SchoolName)
                    .FontSize(64)
                    .FontColor(Colors.Grey.Lighten3);

                page.Header().Element(c => BuildHeader(c, model, logoBytes));
                page.Content().PaddingTop(8).Element(c => BuildTable(c, model));
                page.Footer().Element(c => BuildFooter(c, model));
            });
        }).GeneratePdf();
    }

    private static void BuildHeader(IContainer container, GradebookPdfDto model, byte[]? logoBytes)
    {
        container.Column(col =>
        {
            col.Item().Row(row =>
            {
                if (logoBytes != null)
                    row.ConstantItem(52).Height(52).Image(logoBytes);

                row.RelativeItem().PaddingLeft(logoBytes != null ? 12 : 0).Column(c =>
                {
                    c.Item().Text("REGISTRO DE CALIFICACIONES")
                        .FontSize(18).Bold().FontColor(PdfColorPrimary);
                    c.Item().PaddingTop(2).Text(model.SchoolName)
                        .FontSize(11).SemiBold().FontColor(PdfColorPrimaryDark);
                });

                row.ConstantItem(180).AlignRight().Column(c =>
                {
                    c.Item().Text($"Trimestre: {model.Trimester}").FontSize(9).Bold();
                    c.Item().Text($"Año lectivo {model.AcademicYear}").FontSize(8).FontColor(PdfColorMuted);
                    c.Item().PaddingTop(4).Text(model.GeneratedAt.ToString("dd/MM/yyyy HH:mm"))
                        .FontSize(7).FontColor(PdfColorMuted);
                });
            });

            col.Item().PaddingVertical(10).LineHorizontal(1.5f).LineColor(PdfColorPrimary);

            col.Item().Background(Colors.Grey.Lighten4).Padding(10).Row(r =>
            {
                InfoCell(r.RelativeItem(), "Docente", model.TeacherName);
                InfoCell(r.RelativeItem(), "Materia", model.SubjectName);
                InfoCell(r.RelativeItem(), "Grupo", model.GroupLabel);
                InfoCell(r.RelativeItem(), "Estudiantes", model.Students.Count.ToString());
            });

            if (model.TypeSections.Count > 0)
            {
                col.Item().PaddingTop(8).Row(r =>
                {
                    r.AutoItem().PaddingRight(6).Text("Leyenda:").FontSize(7).FontColor(PdfColorMuted);
                    foreach (var section in model.TypeSections)
                    {
                        r.AutoItem().PaddingRight(8).Background(PdfColorPrimary).PaddingHorizontal(6).PaddingVertical(2)
                            .Text($"{section.ShortLabel} = {section.TypeLabel}")
                            .FontSize(7).FontColor(Colors.White);
                    }
                    r.AutoItem().PaddingLeft(8).Text("Aprobado ≥ 3.0")
                        .FontSize(7).FontColor(PdfColorApproved);
                });
            }
        });
    }

    private static void InfoCell(IContainer container, string label, string value)
    {
        container.Column(c =>
        {
            c.Item().Text(label).FontSize(7).FontColor(PdfColorMuted);
            c.Item().Text(value).FontSize(9).Bold();
        });
    }

    private static void BuildTable(IContainer container, GradebookPdfDto model)
    {
        if (model.Students.Count == 0)
        {
            container.PaddingVertical(40).AlignCenter()
                .Text("No hay estudiantes ni actividades para este registro.")
                .FontSize(11).FontColor(PdfColorMuted);
            return;
        }

        if (model.TypeSections.Count == 0)
        {
            container.PaddingVertical(40).AlignCenter()
                .Text("No hay actividades registradas en este trimestre.")
                .FontSize(11).FontColor(PdfColorMuted);
            return;
        }

        container.Table(table =>
        {
            table.ColumnsDefinition(def =>
            {
                def.ConstantColumn(22);
                def.RelativeColumn(2.4f);
                def.RelativeColumn(1.1f);
                foreach (var section in model.TypeSections)
                {
                    foreach (var _ in section.Activities)
                        def.ConstantColumn(34);
                    def.ConstantColumn(30);
                }
                def.ConstantColumn(38);
            });

            table.Header(header =>
            {
                header.Cell().ColumnSpan(3).Background(PdfColorPrimaryDark).Padding(4)
                    .AlignMiddle().Text("Estudiante").FontSize(8).Bold().FontColor(Colors.White);

                foreach (var section in model.TypeSections)
                {
                    var span = section.Activities.Count + 1;
                    header.Cell().ColumnSpan((uint)span).Background(PdfColorPrimary).Padding(4)
                        .AlignCenter().Text(section.TypeLabel).FontSize(7).Bold().FontColor(Colors.White);
                }

                header.Cell().Background(PdfColorPrimaryDark).Padding(4)
                    .AlignCenter().Text("Nota\nfinal").FontSize(7).Bold().FontColor(Colors.White);

                header.Cell().Background(Colors.Grey.Lighten2).Padding(3)
                    .Text("#").FontSize(7).Bold();
                header.Cell().Background(Colors.Grey.Lighten2).Padding(3)
                    .Text("Nombre").FontSize(7).Bold();
                header.Cell().Background(Colors.Grey.Lighten2).Padding(3)
                    .Text("Cédula").FontSize(7).Bold();

                foreach (var section in model.TypeSections)
                {
                    foreach (var act in section.Activities)
                    {
                        header.Cell().Background(Colors.Grey.Lighten3).Padding(2)
                            .AlignCenter().Text(act.Name).FontSize(6);
                    }
                    header.Cell().Background(Colors.Grey.Lighten2).Padding(2)
                        .AlignCenter().Text($"Prom.\n{section.ShortLabel}").FontSize(6).Bold();
                }

                header.Cell().Background(Colors.Grey.Lighten2).Padding(2)
                    .AlignCenter().Text("Final").FontSize(7).Bold();
            });

            var rowIndex = 0;
            foreach (var student in model.Students)
            {
                var bg = rowIndex % 2 == 0 ? Colors.White : Colors.Grey.Lighten5;
                rowIndex++;

                table.Cell().Background(bg).Padding(3).AlignCenter().Text(student.Number.ToString()).FontSize(7);
                table.Cell().Background(bg).Padding(3).Text(student.Name).FontSize(7);
                table.Cell().Background(bg).Padding(3).Text(string.IsNullOrWhiteSpace(student.DocumentId) ? "—" : student.DocumentId).FontSize(7);

                foreach (var section in model.TypeSections)
                {
                    foreach (var act in section.Activities)
                    {
                        student.ScoresByActivityId.TryGetValue(act.Id, out var score);
                        var display = score.HasValue && score.Value > 0 ? score.Value.ToString("0.0") : "—";
                        table.Cell().Background(bg).Padding(2).AlignCenter().Text(display).FontSize(7);
                    }

                    student.TypeAverages.TryGetValue(section.TypeKey, out var typeAvg);
                    table.Cell().Background(bg).Padding(2).AlignCenter()
                        .Text(typeAvg.ToString("0.0")).FontSize(7).SemiBold().FontColor(PdfColorPrimary);
                }

                var finalColor = student.FinalGrade >= 3.0m && student.FinalGrade > 0
                    ? PdfColorApproved
                    : student.FinalGrade > 0 ? PdfColorFailed : PdfColorMuted;

                table.Cell().Background(bg).Padding(2).AlignCenter()
                    .Text(student.FinalGrade.ToString("0.0")).FontSize(8).Bold().FontColor(finalColor);
            }
        });
    }

    private static void BuildFooter(IContainer container, GradebookPdfDto model)
    {
        var code = $"GB-{model.GeneratedAt:yyyyMMdd}-{model.Trimester}-{model.GeneratedAt:HHmm}";
        container.PaddingTop(6).BorderTop(0.5f).BorderColor(Colors.Grey.Lighten2).Row(r =>
        {
            r.RelativeItem().Text($"SchoolManager · {model.SubjectName} · {model.GroupLabel} · Cód. {code}")
                .FontSize(7).FontColor(PdfColorMuted);
            r.RelativeItem().AlignRight().Text(t =>
            {
                t.Span("Página ").FontSize(7).FontColor(PdfColorMuted);
                t.CurrentPageNumber().FontSize(7).FontColor(PdfColorMuted);
                t.Span(" de ").FontSize(7).FontColor(PdfColorMuted);
                t.TotalPages().FontSize(7).FontColor(PdfColorMuted);
            });
        });
    }

    private static string NormalizeType(string? type) => (type ?? "").Trim().ToLowerInvariant();

    private static string TypeShortLabel(string typeKey) => typeKey switch
    {
        "notas de apreciación" => "Aprec.",
        "ejercicios diarios" => "Ejerc.",
        "examen final" => "Examen",
        "recuperación" => "Recup.",
        _ => typeKey.Length > 10 ? typeKey[..10] : typeKey
    };

    private static decimal TruncateOneDecimal(decimal value) =>
        Math.Floor(value * 10m) / 10m;

    private static decimal ComputeFinalGrade(Dictionary<string, decimal> typeAvgs, List<string> activeTypeKeys)
    {
        var working = new Dictionary<string, decimal>(typeAvgs);

        if (working.TryGetValue("recuperación", out var recup) && recup > 0)
        {
            working["examen final"] = recup;
        }

        var typesForFinal = activeTypeKeys
            .Where(t => t != "recuperación")
            .Where(t => working.TryGetValue(t, out var v) && v > 0)
            .ToList();

        if (typesForFinal.Count == 0) return 0m;

        var final = typesForFinal.Average(t => working[t]);
        return TruncateOneDecimal(final);
    }
}
