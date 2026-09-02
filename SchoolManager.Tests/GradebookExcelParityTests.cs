using OfficeOpenXml;
using SchoolManager.Services.Helpers;
using SchoolManager.Services.Implementations;

namespace SchoolManager.Tests;

public class GradebookExcelParityTests
{
    public GradebookExcelParityTests()
    {
        ExcelPackage.License.SetNonCommercialOrganization("EduplanerIIC-SchoolManager");
    }

    [Fact]
    public void Excel_MatchesCanonicalModel_SameActivitiesOrderStudentsAveragesAndFinals()
    {
        var model = GradebookPdfFixtures.SanMiguelitoCivica9G(exerciseCount: 8, studentCount: 5, withRecovery: true);
        var columns = GradebookExcelRenderer.BuildColumns(model);
        using var package = new ExcelPackage(new MemoryStream(GradebookExcelRenderer.Generate(model)));
        var ws = package.Workbook.Worksheets[GradebookExcelLayout.SheetName];

        var activityHeaders = columns.Where(c => c.Kind == GradebookExcelColumnKind.Activity).ToList();
        var expectedActivities = model.TypeSections.SelectMany(s => s.Activities).ToList();
        Assert.Equal(expectedActivities.Select(a => a.Name), activityHeaders.Select(c => c.Activity!.Name));
        Assert.Equal(expectedActivities.Count, expectedActivities.Select(a => a.Id).Distinct().Count());

        Assert.Equal(
            new[] { "notas de apreciación", "ejercicios diarios", "examen final", "recuperación" },
            model.TypeSections.Select(s => s.TypeKey).ToArray());

        Assert.Equal(5, model.Students.Count);
        Assert.Equal(
            new[]
            {
                "Abadía, Yosuan",
                "Agrazal, Stephany",
                "Alvarado P., Amado E.",
                "Amagara M., Xavier A.",
                "Arauaz, Ruth"
            },
            model.Students.Select(s => s.Name).ToArray());

        for (var i = 0; i < model.Students.Count; i++)
        {
            var student = model.Students[i];
            var row = GradebookExcelLayout.FirstDataRow + i;
            Assert.Equal(student.Name, ws.Cells[row, 1].Text.TrimStart('\''));
            Assert.Equal(student.DocumentId, ws.Cells[row, 2].Text.TrimStart('\''));

            foreach (var col in activityHeaders)
            {
                var expected = GradebookVisibleActivitySelector.ResolveScore(col.Activity!, student.ScoresByActivityId);
                var cell = ws.Cells[row, col.Index];
                if (!expected.HasValue)
                    Assert.Null(cell.Value);
                else
                    Assert.Equal((double)expected.Value, Assert.IsType<double>(cell.Value));
            }

            foreach (var col in columns.Where(c => c.Kind == GradebookExcelColumnKind.TypeAverage))
            {
                student.TypeAverages.TryGetValue(col.Section!.TypeKey, out var avg);
                Assert.Equal((double)avg, Assert.IsType<double>(ws.Cells[row, col.Index].Value));
            }

            var finalCol = columns.First(c => c.Kind == GradebookExcelColumnKind.Final).Index;
            Assert.Equal((double)student.FinalGrade, Assert.IsType<double>(ws.Cells[row, finalCol].Value));
        }
    }

    [Fact]
    public void ExcelColumns_MatchSelectorUsedByPdf()
    {
        var headers = GradebookPdfFixtures.NamedActivities("notas de apreciación", "Oral", 2)
            .Concat(GradebookPdfFixtures.NamedActivities("ejercicios diarios", "Taller", 2))
            .Concat(GradebookPdfFixtures.NamedActivities("tarea", "Legado", 1))
            .ToList();
        headers.Add(new SchoolManager.Dtos.ActivityHeaderDto
        {
            Id = Guid.NewGuid(),
            Name = "Oral 1",
            Type = "notas de apreciación"
        });

        var sections = GradebookVisibleActivitySelector.SelectVisibleColumns(headers);
        var model = GradebookPdfFixtures.SanMiguelitoCivica9G(studentCount: 1);
        model.TypeSections = sections.ToList();
        var columns = GradebookExcelRenderer.BuildColumns(model);
        Assert.Equal(sections.SelectMany(s => s.Activities).Select(a => a.Name),
            columns.Where(c => c.Kind == GradebookExcelColumnKind.Activity).Select(c => c.Header));
        Assert.DoesNotContain(columns, c => c.Header.Contains("Legado"));
        Assert.Equal(2, columns.Count(c => c.Kind == GradebookExcelColumnKind.Activity && c.Section!.TypeKey == "notas de apreciación"));
    }

    [Fact]
    public void IndexJavascript_UsesSameTypeOrderAndDedupContract()
    {
        var index = File.ReadAllText(Path.Combine(FindRepoRoot(), "SchoolManager", "Views", "TeacherGradebook", "Index.cshtml"));
        Assert.Contains("['notas de apreciación', 'ejercicios diarios', 'examen final', 'recuperación']", index);
        Assert.Contains("if (!activities[tipo].some(a => a.name === nota.actividad))", index);
        Assert.Contains("const tipo = nota.tipo.toLowerCase();", index);
    }

    [Fact]
    public void RecoveryRule_MatchesCalculatorUsedByPdfAndWeb()
    {
        var model = GradebookPdfFixtures.SanMiguelitoCivica9G(exerciseCount: 2, studentCount: 1, withRecovery: true);
        var without = GradebookFinalGradeCalculator.ComputeFinalGradeFromTypeAverages(
            new Dictionary<string, decimal>(model.Students[0].TypeAverages),
            new HashSet<string>(model.Students[0].TypeAverages.Keys, StringComparer.OrdinalIgnoreCase));
        Assert.Equal(model.Students[0].FinalGrade, without);
        using var package = new ExcelPackage(new MemoryStream(GradebookExcelRenderer.Generate(model)));
        var finalCol = GradebookExcelRenderer.BuildColumns(model).First(c => c.Kind == GradebookExcelColumnKind.Final).Index;
        Assert.Equal((double)model.Students[0].FinalGrade,
            (double)package.Workbook.Worksheets[GradebookExcelLayout.SheetName].Cells[GradebookExcelLayout.FirstDataRow, finalCol].Value!);
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
