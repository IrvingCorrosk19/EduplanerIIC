using System.Globalization;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using SchoolManager.Dtos;
using SchoolManager.Services.Helpers;

namespace SchoolManager.Services.Implementations;

/// <summary>
/// Composición QuestPDF del registro de calificaciones. Sin Scale. Fuente mínima 8 pt.
/// Cada bloque de tipo (o subbloque) es un <c>Page</c> template con paginación vertical de alumnos.
/// </summary>
public static class GradebookPdfRenderer
{
    private const string ColorPrimary = "#2563eb";
    private const string ColorPrimaryDark = "#1e40af";
    private const string ColorApproved = "#15803d";
    private const string ColorFailed = "#b91c1c";
    private const string ColorMuted = "#64748b";

    public const float MinFontSize = GradebookPdfLayout.MinFontSize;

    public static byte[] Generate(GradebookPdfDto model, byte[]? logoBytes)
    {
        QuestPDF.Settings.License = LicenseType.Community;
        return BuildDocument(model, logoBytes).GeneratePdf();
    }

    public static IDocument BuildDocument(GradebookPdfDto model, byte[]? logoBytes)
    {
        QuestPDF.Settings.License = LicenseType.Community;
        var blocks = GradebookPdfLayout.BuildBlocks(model.TypeSections);

        return Document.Create(container =>
        {
            if (blocks.Count == 0)
            {
                container.Page(page => ConfigurePage(page, model, logoBytes, emptyBlock: true, block: null));
                return;
            }

            foreach (var block in blocks)
                container.Page(page => ConfigurePage(page, model, logoBytes, emptyBlock: false, block: block));
        });
    }

    private static void ConfigurePage(
        PageDescriptor page,
        GradebookPdfDto model,
        byte[]? logoBytes,
        bool emptyBlock,
        GradebookPdfTableBlock? block)
    {
        page.Size(PageSizes.A4.Landscape());
        page.MarginHorizontal(GradebookPdfLayout.MarginHorizontal);
        page.MarginVertical(GradebookPdfLayout.MarginVertical);
        page.DefaultTextStyle(x => x
            .FontSize(GradebookPdfLayout.BodyFontSize)
            .FontFamily("Arial")
            .FontColor(Colors.Grey.Darken3));

        page.Background().AlignCenter().AlignMiddle()
            .Text(model.SchoolName)
            .FontSize(GradebookPdfLayout.WatermarkFontSize)
            .FontColor("#f1f5f9");

        page.Header().Element(c => BuildHeader(c, model, logoBytes, block));

        page.Content().PaddingTop(6).Element(c =>
        {
            if (emptyBlock || block == null)
            {
                var message = model.Students.Count == 0
                    ? "No hay estudiantes ni actividades para este registro."
                    : "No hay actividades registradas en este trimestre.";
                c.PaddingVertical(40).AlignCenter()
                    .Text(message)
                    .FontSize(11).FontColor(ColorMuted);
                return;
            }

            BuildTable(c, model, block);
        });

        page.Footer().Element(c => BuildFooter(c, model, block));
    }

    private static void BuildHeader(
        IContainer container,
        GradebookPdfDto model,
        byte[]? logoBytes,
        GradebookPdfTableBlock? block)
    {
        var hasLogo = logoBytes is { Length: > 0 };
        container.Column(col =>
        {
            col.Item().Row(row =>
            {
                if (hasLogo)
                {
                    try
                    {
                        row.ConstantItem(42).Height(42).Image(logoBytes!);
                    }
                    catch
                    {
                        hasLogo = false;
                    }
                }

                row.RelativeItem().PaddingLeft(hasLogo ? 10 : 0).Column(c =>
                {
                    c.Item().Text("REGISTRO DE CALIFICACIONES")
                        .FontSize(GradebookPdfLayout.HeaderTitleFontSize).Bold().FontColor(ColorPrimary);
                    c.Item().PaddingTop(1).Text(model.SchoolName)
                        .FontSize(9).SemiBold().FontColor(ColorPrimaryDark);
                    if (block != null)
                    {
                        c.Item().PaddingTop(2).Text(block.BlockTitle)
                            .FontSize(9).Bold().FontColor(ColorPrimary);
                    }
                });

                row.ConstantItem(150).AlignRight().Column(c =>
                {
                    c.Item().Text($"Trimestre: {model.Trimester}").FontSize(8).Bold();
                    if (!string.IsNullOrWhiteSpace(model.AcademicYear))
                        c.Item().Text($"Año lectivo {model.AcademicYear}").FontSize(8).FontColor(ColorMuted);
                    var generated = string.IsNullOrWhiteSpace(model.GeneratedAtDisplay)
                        ? model.GeneratedAt.ToString("dd/MM/yyyy HH:mm")
                        : model.GeneratedAtDisplay;
                    c.Item().PaddingTop(2).Text(generated)
                        .FontSize(7).FontColor(ColorMuted);
                });
            });

            col.Item().PaddingVertical(5).LineHorizontal(1f).LineColor(ColorPrimary);

            col.Item().Background(Colors.Grey.Lighten4).Padding(6).Row(r =>
            {
                InfoCell(r.RelativeItem(), "Docente", model.TeacherName);
                InfoCell(r.RelativeItem(), "Materia", model.SubjectName);
                InfoCell(r.RelativeItem(), "Grupo", model.GroupLabel);
                InfoCell(r.RelativeItem(), "Estudiantes", model.Students.Count.ToString(CultureInfo.InvariantCulture));
            });

            if (model.TypeSections.Count > 0)
            {
                col.Item().PaddingTop(3).Text(text =>
                {
                    text.Span("Leyenda: ").FontSize(7).FontColor(ColorMuted);
                    foreach (var section in model.TypeSections)
                    {
                        text.Span($"{section.ShortLabel}={section.TypeLabel}; ")
                            .FontSize(7).FontColor(ColorPrimaryDark);
                    }
                    text.Span("Aprobado >= 3.0. ").FontSize(7).FontColor(ColorApproved);
                    if (model.TypeSections.Any(s => s.Activities.Count > GradebookPdfLayout.SafeActivityChunkSize))
                    {
                        text.Span("Prom. con (completo) = promedio de todo el tipo, no solo del bloque.")
                            .FontSize(7).FontColor(ColorMuted);
                    }
                });
            }
        });
    }

    private static void InfoCell(IContainer container, string label, string value)
    {
        container.Column(c =>
        {
            c.Item().Text(label).FontSize(6).FontColor(ColorMuted);
            c.Item().Text(value).FontSize(8).Bold();
        });
    }

    private static void BuildTable(IContainer container, GradebookPdfDto model, GradebookPdfTableBlock block)
    {
        var fontSize = GradebookPdfLayout.BodyFontSize;
        var headerColor = SectionHeaderColor(block.TypeKey);

        container.Table(table =>
        {
            table.ColumnsDefinition(def =>
            {
                def.ConstantColumn(GradebookPdfLayout.ColNumber);
                def.ConstantColumn(GradebookPdfLayout.ColName);
                def.ConstantColumn(GradebookPdfLayout.ColDocument);
                foreach (var _ in block.Activities)
                    def.ConstantColumn(GradebookPdfLayout.ColActivity);
                if (block.ShowTypeAverage)
                    def.ConstantColumn(GradebookPdfLayout.ColAverage);
                if (block.ShowFinalGrade)
                    def.ConstantColumn(GradebookPdfLayout.ColFinal);
            });

            table.Header(header =>
            {
                HeaderCell(header.Cell(), ColorPrimaryDark, "#", fontSize);
                HeaderCell(header.Cell(), ColorPrimaryDark, "Nombre", fontSize, alignLeft: true);
                HeaderCell(header.Cell(), ColorPrimaryDark, "Cédula", fontSize, alignLeft: true);

                var actIndexOffset = 1;
                if (block.TypeBlockIndex > 1)
                    actIndexOffset += (block.TypeBlockIndex - 1) * GradebookPdfLayout.SafeActivityChunkSize;

                var localIndex = 0;
                foreach (var act in block.Activities)
                {
                    var n = actIndexOffset + localIndex;
                    HeaderCell(
                        header.Cell(),
                        headerColor,
                        $"{block.ShortLabel}{n}\n{act.Name}",
                        fontSize);
                    localIndex++;
                }

                if (block.ShowTypeAverage)
                    HeaderCell(header.Cell(), ColorPrimary, block.AverageCaption, fontSize);

                if (block.ShowFinalGrade)
                    HeaderCell(header.Cell(), ColorPrimaryDark, "Nota\nfinal", fontSize);
            });

            var rowIndex = 0;
            foreach (var student in model.Students)
            {
                var bg = rowIndex % 2 == 0 ? Colors.White : Colors.Grey.Lighten5;
                rowIndex++;

                BodyCell(table, bg, student.Number.ToString(CultureInfo.InvariantCulture), fontSize, center: true);
                BodyCell(table, bg, string.IsNullOrWhiteSpace(student.Name) ? "-" : student.Name, fontSize, alignLeft: true);
                BodyCell(table, bg, string.IsNullOrWhiteSpace(student.DocumentId) ? "-" : student.DocumentId, fontSize, alignLeft: true);

                foreach (var act in block.Activities)
                {
                    var score = GradebookVisibleActivitySelector.ResolveScore(act, student.ScoresByActivityId);
                    var display = score.HasValue
                        ? GradebookFinalGradeCalculator.FormatTruncatedGrade(score.Value)
                        : "-";
                    BodyCell(table, bg, display, fontSize, center: true);
                }

                if (block.ShowTypeAverage)
                {
                    student.TypeAverages.TryGetValue(block.TypeKey, out var typeAvg);
                    BodyCell(
                        table,
                        bg,
                        GradebookFinalGradeCalculator.FormatTruncatedGrade(typeAvg),
                        fontSize,
                        center: true,
                        color: ColorPrimary,
                        semiBold: true);
                }

                if (block.ShowFinalGrade)
                {
                    var finalColor = student.FinalGrade >= 3.0m && student.FinalGrade > 0
                        ? ColorApproved
                        : student.FinalGrade > 0 ? ColorFailed : ColorMuted;

                    BodyCell(
                        table,
                        bg,
                        GradebookFinalGradeCalculator.FormatTruncatedGrade(student.FinalGrade),
                        fontSize + 1,
                        center: true,
                        color: finalColor,
                        bold: true);
                }
            }
        });
    }

    private static void HeaderCell(
        IContainer cell,
        string background,
        string text,
        float fontSize,
        bool alignLeft = false)
    {
        var painted = cell.Background(background).Padding(2);
        var aligned = alignLeft ? painted.AlignLeft() : painted.AlignCenter();
        aligned.Text(text).FontSize(fontSize).Bold().FontColor(Colors.White);
    }

    private static void BodyCell(
        TableDescriptor table,
        string background,
        string text,
        float fontSize,
        bool center = false,
        bool alignLeft = false,
        string? color = null,
        bool bold = false,
        bool semiBold = false)
    {
        var cell = table.Cell().Background(background).Padding(2);
        IContainer positioned = center ? cell.AlignCenter() : alignLeft ? cell.AlignLeft() : cell;
        var span = positioned.Text(text).FontSize(fontSize);
        if (!string.IsNullOrEmpty(color))
            span.FontColor(color);
        if (bold)
            span.Bold();
        else if (semiBold)
            span.SemiBold();
    }

    private static void BuildFooter(IContainer container, GradebookPdfDto model, GradebookPdfTableBlock? block)
    {
        var code = $"GB-{model.GeneratedAt:yyyyMMdd}-{model.Trimester}-{model.GeneratedAt:HHmm}";
        var blockPart = block == null ? "" : $" · {block.BlockTitle}";
        container.PaddingTop(6).BorderTop(0.5f).BorderColor(Colors.Grey.Lighten2).Row(r =>
        {
            r.RelativeItem().Text($"SchoolManager · {model.SubjectName} · {model.GroupLabel}{blockPart} · Cód. {code}")
                .FontSize(7).FontColor(ColorMuted);
            r.RelativeItem().AlignRight().Text(t =>
            {
                t.Span("Página ").FontSize(7).FontColor(ColorMuted);
                t.CurrentPageNumber().FontSize(7).FontColor(ColorMuted);
                t.Span(" de ").FontSize(7).FontColor(ColorMuted);
                t.TotalPages().FontSize(7).FontColor(ColorMuted);
            });
        });
    }

    private static string SectionHeaderColor(string typeKey) => typeKey switch
    {
        "notas de apreciación" => "#3b82f6",
        "ejercicios diarios" => "#2563eb",
        "examen final" => "#1d4ed8",
        "recuperación" => "#1e3a8a",
        _ => ColorPrimary
    };
}
