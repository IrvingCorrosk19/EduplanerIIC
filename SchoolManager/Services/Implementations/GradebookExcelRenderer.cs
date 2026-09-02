using System.Drawing;
using OfficeOpenXml;
using OfficeOpenXml.Style;
using SchoolManager.Dtos;
using SchoolManager.Services.Helpers;

namespace SchoolManager.Services.Implementations;

/// <summary>
/// Genera el .xlsx del registro a partir del modelo canónico. Valores oficiales del servidor, sin fórmulas de recálculo.
/// </summary>
public static class GradebookExcelRenderer
{
    private static readonly Color ColorPrimary = Color.FromArgb(37, 99, 235);
    private static readonly Color ColorPrimaryDark = Color.FromArgb(30, 64, 175);
    private static readonly Color ColorHeaderText = Color.White;
    private static readonly Color ColorBorder = Color.FromArgb(203, 213, 225);
    private static readonly Color ColorAltRow = Color.FromArgb(248, 250, 252);
    private static readonly Color ColorMetaFill = Color.FromArgb(241, 245, 249);
    private static readonly Color ColorApproved = Color.FromArgb(21, 128, 61);
    private static readonly Color ColorFailed = Color.FromArgb(185, 28, 28);
    private static readonly Color ColorMuted = Color.FromArgb(100, 116, 139);

    public static byte[] Generate(GradebookPdfDto model)
    {
        ExcelPackage.License.SetNonCommercialOrganization("EduplanerIIC-SchoolManager");

        using var package = new ExcelPackage();
        var ws = package.Workbook.Worksheets.Add(GradebookExcelLayout.SheetName);

        package.Workbook.Properties.Title = "Registro de Calificaciones";
        package.Workbook.Properties.Author = "Eduplaner";
        package.Workbook.Properties.Company = string.IsNullOrWhiteSpace(model.SchoolName)
            ? "Eduplaner"
            : model.SchoolName;

        var columns = BuildColumns(model);
        var lastCol = Math.Max(columns.Count, 2);
        var headerRow = GradebookExcelLayout.TableHeaderRow;
        var firstDataRow = GradebookExcelLayout.FirstDataRow;
        var lastDataRow = firstDataRow + Math.Max(model.Students.Count, 1) - 1;
        if (model.Students.Count == 0)
            lastDataRow = firstDataRow;

        WriteInstitutionalHeader(ws, model, lastCol);
        WriteTableHeader(ws, columns, headerRow);
        WriteDataRows(ws, model, columns, firstDataRow);

        var usedLastRow = model.Students.Count == 0 ? firstDataRow : firstDataRow + model.Students.Count - 1;
        ApplyTableChrome(ws, columns, headerRow, usedLastRow, lastCol);
        ApplyPrintSettings(ws, model, columns.Count, headerRow, usedLastRow, lastCol);
        TrimUnusedRange(ws, lastCol, usedLastRow);

        ws.Select("A1");
        return package.GetAsByteArray();
    }

    internal static List<GradebookExcelColumn> BuildColumns(GradebookPdfDto model)
    {
        var columns = new List<GradebookExcelColumn>
        {
            new(1, "Estudiante", GradebookExcelColumnKind.Student),
            new(2, "Cédula", GradebookExcelColumnKind.Document)
        };

        var index = 3;
        foreach (var section in model.TypeSections)
        {
            foreach (var activity in section.Activities)
            {
                columns.Add(new(index++, activity.Name, GradebookExcelColumnKind.Activity, section, activity));
            }

            columns.Add(new(index++, $"Prom. {section.ShortLabel}", GradebookExcelColumnKind.TypeAverage, section));
        }

        columns.Add(new(index, "Nota final", GradebookExcelColumnKind.Final));
        return columns;
    }

    private static void WriteInstitutionalHeader(ExcelWorksheet ws, GradebookPdfDto model, int lastCol)
    {
        ws.Cells[1, 1, 1, lastCol].Merge = true;
        ws.Cells[1, 1].Value = "REGISTRO DE CALIFICACIONES";
        ws.Cells[1, 1].Style.Font.Bold = true;
        ws.Cells[1, 1].Style.Font.Size = 16;
        ws.Cells[1, 1].Style.Font.Color.SetColor(ColorPrimaryDark);
        ws.Cells[1, 1].Style.HorizontalAlignment = ExcelHorizontalAlignment.Left;
        ws.Row(1).Height = 24;

        ws.Cells[2, 1, 2, lastCol].Merge = true;
        WriteSafeText(ws.Cells[2, 1], model.SchoolName);
        ws.Cells[2, 1].Style.Font.Bold = true;
        ws.Cells[2, 1].Style.Font.Size = 12;
        ws.Cells[2, 1].Style.Font.Color.SetColor(ColorPrimary);

        var groupValue = string.IsNullOrWhiteSpace(model.GroupName) ? model.GroupLabel : model.GroupName;
        var gradeValue = string.IsNullOrWhiteSpace(model.GradeLevelName) ? model.GroupLabel : model.GradeLevelName;
        var generated = string.IsNullOrWhiteSpace(model.GeneratedAtDisplay)
            ? model.GeneratedAt.ToString("dd/MM/yyyy HH:mm")
            : model.GeneratedAtDisplay;
        var studentCount = model.Students.Count.ToString(System.Globalization.CultureInfo.InvariantCulture);

        if (lastCol >= 4)
        {
            WriteMetaPair(ws, 4, 1, "Docente", model.TeacherName, lastCol);
            WriteMetaPair(ws, 4, 3, "Materia", model.SubjectName, lastCol);
            WriteMetaPair(ws, 5, 1, "Grupo", groupValue, lastCol);
            WriteMetaPair(ws, 5, 3, "Grado", gradeValue, lastCol);
            WriteMetaPair(ws, 6, 1, "Trimestre", model.Trimester, lastCol);
            WriteMetaPair(ws, 6, 3, "Año lectivo", model.AcademicYear, lastCol);
            WriteMetaPair(ws, 7, 1, "Estudiantes", studentCount, lastCol);
            WriteMetaPair(ws, 7, 3, "Generado", generated, lastCol);
        }
        else
        {
            WriteMetaPair(ws, 4, 1, "Docente", model.TeacherName, lastCol);
            WriteMetaPair(ws, 5, 1, "Materia", model.SubjectName, lastCol);
            WriteMetaPair(ws, 6, 1, "Grupo / Grado", $"{groupValue} / {gradeValue}", lastCol);
            WriteMetaPair(ws, 7, 1, "Trimestre / Año / Estudiantes / Generado",
                $"{model.Trimester} · {model.AcademicYear} · {studentCount} · {generated}", lastCol);
        }

        if (model.TypeSections.Count == 0)
        {
            ws.Cells[8, 1, 8, lastCol].Merge = true;
            ws.Cells[8, 1].Value = "Sin actividades registradas en este trimestre.";
            ws.Cells[8, 1].Style.Font.Italic = true;
            ws.Cells[8, 1].Style.Font.Color.SetColor(ColorMuted);
        }
    }

    private static void WriteMetaPair(ExcelWorksheet ws, int row, int labelCol, string label, string? value, int lastCol)
    {
        ws.Cells[row, labelCol].Value = label;
        ws.Cells[row, labelCol].Style.Font.Bold = true;
        ws.Cells[row, labelCol].Style.Font.Color.SetColor(ColorPrimaryDark);
        ws.Cells[row, labelCol].Style.Fill.PatternType = ExcelFillStyle.Solid;
        ws.Cells[row, labelCol].Style.Fill.BackgroundColor.SetColor(ColorMetaFill);

        var valueCol = labelCol + 1;
        if (valueCol > lastCol)
            return;

        WriteSafeText(ws.Cells[row, valueCol], value ?? "");
        ws.Cells[row, valueCol].Style.Fill.PatternType = ExcelFillStyle.Solid;
        ws.Cells[row, valueCol].Style.Fill.BackgroundColor.SetColor(ColorMetaFill);
    }

    private static void WriteTableHeader(ExcelWorksheet ws, List<GradebookExcelColumn> columns, int headerRow)
    {
        foreach (var col in columns)
        {
            var cell = ws.Cells[headerRow, col.Index];
            WriteSafeText(cell, col.Header);
            cell.Style.Font.Bold = true;
            cell.Style.Font.Color.SetColor(ColorHeaderText);
            cell.Style.Fill.PatternType = ExcelFillStyle.Solid;
            cell.Style.Fill.BackgroundColor.SetColor(HeaderColor(col));
            cell.Style.HorizontalAlignment = col.Kind == GradebookExcelColumnKind.Student
                ? ExcelHorizontalAlignment.Left
                : ExcelHorizontalAlignment.Center;
            cell.Style.VerticalAlignment = ExcelVerticalAlignment.Center;
            cell.Style.WrapText = true;
            cell.Style.Border.BorderAround(ExcelBorderStyle.Thin, ColorBorder);
        }

        ws.Row(headerRow).Height = 36;
    }

    private static void WriteDataRows(
        ExcelWorksheet ws,
        GradebookPdfDto model,
        List<GradebookExcelColumn> columns,
        int firstDataRow)
    {
        if (model.Students.Count == 0)
        {
            ws.Cells[firstDataRow, 1, firstDataRow, columns.Count].Merge = true;
            ws.Cells[firstDataRow, 1].Value = "No hay estudiantes cargados.";
            ws.Cells[firstDataRow, 1].Style.Font.Color.SetColor(ColorMuted);
            ws.Cells[firstDataRow, 1].Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
            return;
        }

        for (var i = 0; i < model.Students.Count; i++)
        {
            var student = model.Students[i];
            var row = firstDataRow + i;
            var alt = i % 2 == 1;

            foreach (var col in columns)
            {
                var cell = ws.Cells[row, col.Index];
                cell.Style.Border.BorderAround(ExcelBorderStyle.Thin, ColorBorder);
                cell.Style.VerticalAlignment = ExcelVerticalAlignment.Center;
                if (alt)
                {
                    cell.Style.Fill.PatternType = ExcelFillStyle.Solid;
                    cell.Style.Fill.BackgroundColor.SetColor(ColorAltRow);
                }

                switch (col.Kind)
                {
                    case GradebookExcelColumnKind.Student:
                        WriteSafeText(cell, student.Name);
                        cell.Style.HorizontalAlignment = ExcelHorizontalAlignment.Left;
                        cell.Style.WrapText = true;
                        break;
                    case GradebookExcelColumnKind.Document:
                        WriteSafeText(cell, student.DocumentId);
                        cell.Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
                        break;
                    case GradebookExcelColumnKind.Activity:
                        WriteScore(cell, GradebookVisibleActivitySelector.ResolveScore(col.Activity!, student.ScoresByActivityId));
                        break;
                    case GradebookExcelColumnKind.TypeAverage:
                        student.TypeAverages.TryGetValue(col.Section!.TypeKey, out var avg);
                        WriteGradeNumber(cell, avg);
                        cell.Style.Font.Bold = true;
                        cell.Style.Font.Color.SetColor(ColorPrimary);
                        break;
                    case GradebookExcelColumnKind.Final:
                        WriteGradeNumber(cell, student.FinalGrade);
                        cell.Style.Font.Bold = true;
                        ApplyFinalColor(cell, student.FinalGrade);
                        break;
                }
            }

            ws.Row(row).Height = student.Name.Length > 42 ? 32 : 18;
        }
    }

    private static void ApplyTableChrome(
        ExcelWorksheet ws,
        List<GradebookExcelColumn> columns,
        int headerRow,
        int lastDataRow,
        int lastCol)
    {
        ws.Column(1).Width = 32;
        ws.Column(2).Width = 16;
        foreach (var col in columns.Skip(2))
        {
            ws.Column(col.Index).Width = col.Kind == GradebookExcelColumnKind.Activity
                ? 13
                : col.Kind == GradebookExcelColumnKind.Final ? 12 : 11;
        }

        ws.View.FreezePanes(headerRow + 1, GradebookExcelLayout.FrozenIdentityColumns + 1);
        ws.Cells[headerRow, 1, lastDataRow, lastCol].AutoFilter = true;

        var finalCol = columns.First(c => c.Kind == GradebookExcelColumnKind.Final).Index;
        if (lastDataRow >= GradebookExcelLayout.FirstDataRow)
        {
            var range = ws.Cells[GradebookExcelLayout.FirstDataRow, finalCol, lastDataRow, finalCol];
            var pass = range.ConditionalFormatting.AddGreaterThanOrEqual();
            pass.Formula = GradebookExcelLayout.PassingGrade.ToString(System.Globalization.CultureInfo.InvariantCulture);
            pass.Style.Font.Color.SetColor(ColorApproved);

            var fail = range.ConditionalFormatting.AddBetween();
            fail.Formula = "0.1";
            fail.Formula2 = "2.9";
            fail.Style.Font.Color.SetColor(ColorFailed);
        }
    }

    private static void ApplyPrintSettings(
        ExcelWorksheet ws,
        GradebookPdfDto model,
        int columnCount,
        int headerRow,
        int lastRow,
        int lastCol)
    {
        ws.PrinterSettings.Orientation = eOrientation.Landscape;
        ws.PrinterSettings.PaperSize = ePaperSize.A4;
        ws.PrinterSettings.LeftMargin = 0.45d;
        ws.PrinterSettings.RightMargin = 0.45d;
        ws.PrinterSettings.TopMargin = 0.6d;
        ws.PrinterSettings.BottomMargin = 0.6d;
        ws.PrinterSettings.HeaderMargin = 0.25d;
        ws.PrinterSettings.FooterMargin = 0.25d;
        ws.PrinterSettings.HorizontalCentered = true;
        ws.PrinterSettings.RepeatRows = new ExcelAddress(headerRow, 1, headerRow, lastCol);
        ws.PrinterSettings.PrintArea = ws.Cells[1, 1, lastRow, lastCol];

        var activityCount = model.TypeSections.Sum(s => s.Activities.Count);
        if (activityCount <= GradebookExcelLayout.FewActivityFitToWidthLimit)
        {
            ws.PrinterSettings.FitToPage = true;
            ws.PrinterSettings.FitToWidth = 1;
            ws.PrinterSettings.FitToHeight = 0;
        }
        else
        {
            ws.PrinterSettings.FitToPage = false;
            ws.PrinterSettings.Scale = 100;
        }

        var group = string.IsNullOrWhiteSpace(model.GroupLabel) ? model.GroupName : model.GroupLabel;
        ws.HeaderFooter.OddHeader.LeftAlignedText = GradebookExcelSafety.AsSafeExcelText(model.SchoolName);
        ws.HeaderFooter.OddHeader.CenteredText = GradebookExcelSafety.AsSafeExcelText($"{group} · {model.Trimester}");
        ws.HeaderFooter.OddFooter.LeftAlignedText = GradebookExcelSafety.AsSafeExcelText(model.SubjectName);
        ws.HeaderFooter.OddFooter.RightAlignedText =
            "Página " + ExcelHeaderFooter.PageNumber + " de " + ExcelHeaderFooter.NumberOfPages;

        _ = columnCount;
    }

    private static void TrimUnusedRange(ExcelWorksheet ws, int lastCol, int lastRow)
    {
        if (ws.Dimension == null)
            return;
        if (ws.Dimension.End.Column > lastCol)
            ws.DeleteColumn(lastCol + 1, ws.Dimension.End.Column - lastCol);
        if (ws.Dimension.End.Row > lastRow)
            ws.DeleteRow(lastRow + 1, ws.Dimension.End.Row - lastRow);
    }

    private static Color HeaderColor(GradebookExcelColumn col) => col.Kind switch
    {
        GradebookExcelColumnKind.Student or GradebookExcelColumnKind.Document => ColorPrimaryDark,
        GradebookExcelColumnKind.TypeAverage => Color.FromArgb(29, 78, 216),
        GradebookExcelColumnKind.Final => ColorPrimaryDark,
        GradebookExcelColumnKind.Activity when col.Section?.TypeKey == "notas de apreciación" => ColorPrimaryDark,
        GradebookExcelColumnKind.Activity when col.Section?.TypeKey == "ejercicios diarios" => ColorPrimary,
        GradebookExcelColumnKind.Activity when col.Section?.TypeKey == "examen final" => Color.FromArgb(29, 78, 216),
        GradebookExcelColumnKind.Activity when col.Section?.TypeKey == "recuperación" => Color.FromArgb(67, 56, 202),
        _ => ColorPrimary
    };

    private static void WriteScore(ExcelRange cell, decimal? score)
    {
        if (!score.HasValue)
        {
            cell.Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
            return;
        }

        WriteGradeNumber(cell, score.Value);
    }

    private static void WriteGradeNumber(ExcelRange cell, decimal value)
    {
        cell.Value = (double)value;
        cell.Style.Numberformat.Format = GradebookExcelLayout.NumberFormat;
        cell.Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
    }

    private static void ApplyFinalColor(ExcelRange cell, decimal final)
    {
        if (final >= GradebookExcelLayout.PassingGrade && final > 0)
            cell.Style.Font.Color.SetColor(ColorApproved);
        else if (final > 0)
            cell.Style.Font.Color.SetColor(ColorFailed);
        else
            cell.Style.Font.Color.SetColor(ColorMuted);
    }

    internal static void WriteSafeText(ExcelRange cell, string? value)
    {
        var text = value ?? string.Empty;
        cell.Value = GradebookExcelSafety.AsSafeExcelText(text);
        cell.Style.Numberformat.Format = GradebookExcelLayout.TextFormat;
        if (GradebookExcelSafety.NeedsFormulaGuard(text))
            cell.Style.QuotePrefix = true;
    }
}

internal enum GradebookExcelColumnKind
{
    Student,
    Document,
    Activity,
    TypeAverage,
    Final
}

internal sealed record GradebookExcelColumn(
    int Index,
    string Header,
    GradebookExcelColumnKind Kind,
    GradebookPdfTypeSectionDto? Section = null,
    GradebookPdfActivityColDto? Activity = null);
