using OfficeOpenXml;
using SchoolManager.Dtos;
using SchoolManager.Services.Helpers;
using SchoolManager.Services.Implementations;

namespace SchoolManager.Tests;

public class GradebookExcelRendererTests
{
    public GradebookExcelRendererTests()
    {
        ExcelPackage.License.SetNonCommercialOrganization("EduplanerIIC-SchoolManager");
    }

    [Fact]
    public void Generate_OpensAsSingleValidWorksheet()
    {
        var model = GradebookPdfFixtures.SanMiguelitoCivica9G();
        using var package = Open(model);
        Assert.Single(package.Workbook.Worksheets);
        Assert.Equal(GradebookExcelLayout.SheetName, package.Workbook.Worksheets[GradebookExcelLayout.SheetName].Name);
        Assert.DoesNotContain(package.Workbook.Worksheets, w => string.IsNullOrWhiteSpace(w.Name));
        var ws = package.Workbook.Worksheets[GradebookExcelLayout.SheetName];
        Assert.NotNull(ws.Dimension);
        Assert.Equal(GradebookExcelRenderer.BuildColumns(model).Count, ws.Dimension.End.Column);
    }

    [Fact]
    public void Generate_HasInstitutionalHeadersAndTableHeaders()
    {
        var model = GradebookPdfFixtures.SanMiguelitoCivica9G();
        using var package = Open(model);
        var ws = package.Workbook.Worksheets[GradebookExcelLayout.SheetName];
        Assert.Equal("REGISTRO DE CALIFICACIONES", ws.Cells[1, 1].Text);
        Assert.Contains("San Miguelito", ws.Cells[2, 1].Text, StringComparison.OrdinalIgnoreCase);
        Assert.Equal("Estudiante", Header(ws, 1));
        Assert.Equal("Cédula", Header(ws, 2));
        Assert.Equal("Nota final", FindHeader(ws, "Nota final"));
        Assert.Contains("Docente", ConcatUsed(ws));
        Assert.Contains("Materia", ConcatUsed(ws));
        Assert.Contains("Grupo", ConcatUsed(ws));
        Assert.Contains("Grado", ConcatUsed(ws));
        Assert.Contains("Trimestre", ConcatUsed(ws));
        Assert.Contains("Año lectivo", ConcatUsed(ws));
        Assert.Contains("Estudiantes", ConcatUsed(ws));
        Assert.Contains("Generado", ConcatUsed(ws));
        Assert.Contains("01/09/2026 16:00", ConcatUsed(ws));
    }

    [Fact]
    public void Generate_WritesNumericGrades_AndKeepsCedulaAsText()
    {
        var model = GradebookPdfFixtures.SanMiguelitoCivica9G();
        using var package = Open(model);
        var ws = package.Workbook.Worksheets[GradebookExcelLayout.SheetName];
        var row = GradebookExcelLayout.FirstDataRow;
        Assert.Equal("Abadía, Yosuan", ws.Cells[row, 1].Text.TrimStart('\''));
        Assert.Equal(GradebookExcelLayout.TextFormat, ws.Cells[row, 2].Style.Numberformat.Format);
        Assert.Equal("8-123-001", ws.Cells[row, 2].Text.TrimStart('\''));
        Assert.False(decimal.TryParse(ws.Cells[row, 2].Text, out _));

        var scoreCell = ws.Cells[row, 3];
        Assert.IsType<double>(scoreCell.Value);
        Assert.Equal(GradebookExcelLayout.NumberFormat, scoreCell.Style.Numberformat.Format);
        Assert.True(string.IsNullOrEmpty(scoreCell.Formula));
    }

    [Fact]
    public void Generate_DistinguishesEmptyFromZero()
    {
        var model = GradebookPdfFixtures.SanMiguelitoCivica9G();
        using var package = Open(model);
        var ws = package.Workbook.Worksheets[GradebookExcelLayout.SheetName];
        var columns = GradebookExcelRenderer.BuildColumns(model);
        var emptyCol = columns.First(c =>
            c.Kind == GradebookExcelColumnKind.Activity &&
            c.Section!.TypeKey == "ejercicios diarios" &&
            c.Activity!.Name == "Ejercicio 1");
        var zeroCol = columns.First(c =>
            c.Kind == GradebookExcelColumnKind.Activity &&
            c.Section!.TypeKey == "notas de apreciación" &&
            c.Activity!.Name == "Aprec 2");

        var alvaradoRow = GradebookExcelLayout.FirstDataRow + 2;
        var arauazRow = GradebookExcelLayout.FirstDataRow + 4;
        Assert.Null(ws.Cells[alvaradoRow, emptyCol.Index].Value);
        Assert.Equal(0d, Assert.IsType<double>(ws.Cells[arauazRow, zeroCol.Index].Value));
        Assert.Equal(GradebookExcelLayout.NumberFormat, ws.Cells[arauazRow, zeroCol.Index].Style.Numberformat.Format);
    }

    [Fact]
    public void Generate_HasAutoFilter_FreezePanes_LandscapeA4()
    {
        var model = GradebookPdfFixtures.SanMiguelitoCivica9G();
        using var package = Open(model);
        var ws = package.Workbook.Worksheets[GradebookExcelLayout.SheetName];
        Assert.NotNull(ws.AutoFilter);
        Assert.NotNull(ws.AutoFilter.Address);
        Assert.Equal(eOrientation.Landscape, ws.PrinterSettings.Orientation);
        Assert.Equal(ePaperSize.A4, ws.PrinterSettings.PaperSize);
        var xml = ws.WorksheetXml.InnerXml;
        Assert.Contains("ySplit", xml, StringComparison.OrdinalIgnoreCase);
        Assert.Contains("xSplit", xml, StringComparison.OrdinalIgnoreCase);
        Assert.Contains("frozen", xml, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void Generate_DoesNotContainFormulaErrors_OrCellFormulas()
    {
        var model = GradebookPdfFixtures.SanMiguelitoCivica9G(exerciseCount: 30, studentCount: 8, withRecovery: true);
        using var package = Open(model);
        var ws = package.Workbook.Worksheets[GradebookExcelLayout.SheetName];
        foreach (var cell in ws.Cells[ws.Dimension.Address])
        {
            Assert.True(string.IsNullOrEmpty(cell.Formula), $"Fórmula inesperada en {cell.Address}: {cell.Formula}");
            Assert.False(cell.Value is ExcelErrorValue, $"Error Excel en {cell.Address}: {cell.Value}");
            var text = cell.Text ?? "";
            Assert.DoesNotContain("#REF!", text);
            Assert.DoesNotContain("#VALUE!", text);
            Assert.DoesNotContain("#DIV/0!", text);
            Assert.DoesNotContain("#NAME?", text);
            Assert.DoesNotContain("#N/A", text);
        }
    }

    [Fact]
    public void Generate_ZeroActivities_OneStudent_ManyStudents_AndThirtyActivities()
    {
        var zero = GradebookPdfFixtures.SanMiguelitoCivica9G(exerciseCount: 0);
        zero.TypeSections.Clear();
        Assert.True(GradebookExcelRenderer.Generate(zero).Length > 100);

        var one = GradebookPdfFixtures.SanMiguelitoCivica9G(studentCount: 1);
        using (var p = Open(one))
            Assert.Equal("Abadía, Yosuan", p.Workbook.Worksheets[GradebookExcelLayout.SheetName].Cells[GradebookExcelLayout.FirstDataRow, 1].Text.TrimStart('\''));

        var many = GradebookPdfFixtures.SanMiguelitoCivica9G(studentCount: 40);
        using (var p = Open(many))
            Assert.Equal(40, CountStudentRows(p.Workbook.Worksheets[GradebookExcelLayout.SheetName]));

        var wide = GradebookPdfFixtures.SanMiguelitoCivica9G(exerciseCount: 30);
        using var widePkg = Open(wide);
        var ws = widePkg.Workbook.Worksheets[GradebookExcelLayout.SheetName];
        var activityHeaders = GradebookExcelRenderer.BuildColumns(wide)
            .Count(c => c.Kind == GradebookExcelColumnKind.Activity);
        Assert.True(activityHeaders >= 30);
        Assert.Equal(100, ws.PrinterSettings.Scale);
        Assert.False(ws.PrinterSettings.FitToPage);
        Assert.True(widePkg.GetAsByteArray().Length > 100);
    }

    [Fact]
    public void Generate_LongNames_DoNotThrow_AndWrap()
    {
        var model = GradebookPdfFixtures.SanMiguelitoCivica9G(studentCount: 8);
        model.Students[0].Name = "Alvarado Palacios, Amado Enrique de la Cruz y González";
        model.Students[0].DocumentId = "PE-8-123-456-789-000";
        using var package = Open(model);
        var ws = package.Workbook.Worksheets[GradebookExcelLayout.SheetName];
        Assert.True(ws.Cells[GradebookExcelLayout.FirstDataRow, 1].Style.WrapText);
        Assert.Contains("Alvarado Palacios", ws.Cells[GradebookExcelLayout.FirstDataRow, 1].Text);
    }

    [Fact]
    public void Generate_FormulaInjection_IsNotExecuted()
    {
        var model = GradebookPdfFixtures.SanMiguelitoCivica9G(exerciseCount: 1, studentCount: 1);
        model.SchoolName = "=1+1";
        model.TeacherName = "+cmd|'/C calc'!A0";
        model.SubjectName = "@SUM(A1)";
        model.GroupName = "-2+2";
        model.Students[0].Name = "=HYPERLINK(\"http://evil\",\"x\")";
        model.Students[0].DocumentId = "+123";
        model.TypeSections[0].Activities[0].Name = "-titulo";

        using var package = Open(model);
        var ws = package.Workbook.Worksheets[GradebookExcelLayout.SheetName];
        foreach (var cell in ws.Cells[ws.Dimension.Address])
        {
            Assert.True(string.IsNullOrEmpty(cell.Formula), cell.Address);
            Assert.False(cell.Value is ExcelErrorValue);
        }

        Assert.StartsWith("'", ws.Cells[2, 1].Text);
        Assert.True(ws.Cells[GradebookExcelLayout.FirstDataRow, 1].Style.QuotePrefix
                    || ws.Cells[GradebookExcelLayout.FirstDataRow, 1].Text.StartsWith('\''));
    }

    [Fact]
    public void Generate_WritesArtifactXlsx()
    {
        var model = GradebookPdfFixtures.SanMiguelitoCivica9G(exerciseCount: 18, studentCount: 12, withRecovery: true);
        var bytes = GradebookExcelRenderer.Generate(model);
        Assert.Equal((byte)'P', bytes[0]);
        Assert.Equal((byte)'K', bytes[1]);

        var dir = Path.Combine(FindRepoRoot(), "artifacts", "gradebook-excel");
        Directory.CreateDirectory(dir);
        var path = Path.Combine(dir, "Registro_Calificaciones_1T_9_G_CIVICA.xlsx");
        File.WriteAllBytes(path, bytes);
        File.WriteAllText(
            Path.Combine(dir, "README.txt"),
            "Fixture IPT San Miguelito / Gertrudis Kirton Winter / Cívica / 9 G / 1T. No es un dump de producción.");

        using var package = new ExcelPackage(new MemoryStream(bytes));
        Assert.Equal(GradebookExcelLayout.SheetName, package.Workbook.Worksheets[GradebookExcelLayout.SheetName].Name);
        Assert.True(File.Exists(path));
    }

    [Fact]
    public void Truncation_IsPreservedAsNumericOneDecimal()
    {
        var model = GradebookPdfFixtures.SanMiguelitoCivica9G(studentCount: 1);
        model.Students[0].TypeAverages["notas de apreciación"] = GradebookFinalGradeCalculator.TruncateOneDecimal(4.59m);
        model.Students[0].FinalGrade = GradebookFinalGradeCalculator.TruncateOneDecimal(4.59m);
        using var package = Open(model);
        var ws = package.Workbook.Worksheets[GradebookExcelLayout.SheetName];
        var finalCol = GradebookExcelRenderer.BuildColumns(model).First(c => c.Kind == GradebookExcelColumnKind.Final).Index;
        var avgCol = GradebookExcelRenderer.BuildColumns(model)
            .First(c => c.Kind == GradebookExcelColumnKind.TypeAverage && c.Section!.TypeKey == "notas de apreciación")
            .Index;
        Assert.Equal(4.5d, Assert.IsType<double>(ws.Cells[GradebookExcelLayout.FirstDataRow, finalCol].Value));
        Assert.Equal(4.5d, Assert.IsType<double>(ws.Cells[GradebookExcelLayout.FirstDataRow, avgCol].Value));
        Assert.NotEqual(4.6d, (double)ws.Cells[GradebookExcelLayout.FirstDataRow, finalCol].Value!);
    }

    private static ExcelPackage Open(GradebookPdfDto model) =>
        new(new MemoryStream(GradebookExcelRenderer.Generate(model)));

    private static string FindHeader(ExcelWorksheet ws, string expected)
    {
        for (var c = 1; c <= 80; c++)
        {
            var text = Header(ws, c);
            if (string.Equals(text, expected, StringComparison.Ordinal))
                return text;
        }

        return "";
    }

    private static string Header(ExcelWorksheet ws, int col) =>
        ws.Cells[GradebookExcelLayout.TableHeaderRow, col].Text.TrimStart('\'');

    private static string ConcatUsed(ExcelWorksheet ws)
    {
        var parts = new List<string>();
        for (var r = 1; r <= GradebookExcelLayout.TableHeaderRow; r++)
        for (var c = 1; c <= Math.Min(6, ws.Dimension.End.Column); c++)
        {
            var t = ws.Cells[r, c].Text;
            if (!string.IsNullOrWhiteSpace(t))
                parts.Add(t);
        }
        return string.Join(" | ", parts);
    }

    private static int CountStudentRows(ExcelWorksheet ws)
    {
        var count = 0;
        var row = GradebookExcelLayout.FirstDataRow;
        while (!string.IsNullOrWhiteSpace(ws.Cells[row, 1].Text))
        {
            count++;
            row++;
        }
        return count;
    }

    private static string FindRepoRoot()
    {
        var dir = new DirectoryInfo(AppContext.BaseDirectory);
        while (dir != null)
        {
            if (File.Exists(Path.Combine(dir.FullName, "SchoolManager.sln")))
                return dir.FullName;
            dir = dir.Parent;
        }

        return Directory.GetCurrentDirectory();
    }
}
