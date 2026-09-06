using QuestPDF.Fluent;
using QuestPDF.Infrastructure;
using SchoolManager.Dtos;
using SchoolManager.Services.Helpers;
using SchoolManager.Services.Implementations;

namespace SchoolManager.Tests;

public class GradebookPdfRendererTests
{
    public GradebookPdfRendererTests()
    {
        QuestPDF.Settings.License = LicenseType.Community;
    }

    [Fact]
    public void Generate_ZeroActivities_DoesNotThrow()
    {
        var model = GradebookPdfFixtures.SanMiguelitoCivica9G(exerciseCount: 0);
        model.TypeSections.Clear();
        var pdf = GradebookPdfRenderer.Generate(model, null);
        Assert.True(pdf.Length > 100);
        Assert.Single(Images(model));
    }

    [Fact]
    public void Generate_OneActivity_DoesNotThrow()
    {
        var model = GradebookPdfFixtures.SanMiguelitoCivica9G(exerciseCount: 1);
        model.TypeSections = model.TypeSections.Where(s => s.TypeKey == "ejercicios diarios").ToList();
        model.TypeSections[0].Activities = model.TypeSections[0].Activities.Take(1).ToList();
        var pdf = GradebookPdfRenderer.Generate(model, null);
        Assert.True(pdf.Length > 100);
    }

    [Fact]
    public void Generate_AtSafeChunkLimit_SingleBlockPerTypeWithExercisesOnly()
    {
        var n = GradebookPdfLayout.SafeActivityChunkSize;
        var model = GradebookPdfFixtures.SanMiguelitoCivica9G(exerciseCount: n);
        model.TypeSections = model.TypeSections.Where(s => s.TypeKey == "ejercicios diarios").ToList();
        var blocks = GradebookPdfLayout.BuildBlocks(model.TypeSections);
        Assert.Single(blocks);
        Assert.True(GradebookPdfRenderer.Generate(model, null).Length > 100);
    }

    [Fact]
    public void Generate_OneMoreThanLimit_CreatesSecondBlock()
    {
        var n = GradebookPdfLayout.SafeActivityChunkSize + 1;
        var model = GradebookPdfFixtures.SanMiguelitoCivica9G(exerciseCount: n);
        model.TypeSections = model.TypeSections.Where(s => s.TypeKey == "ejercicios diarios").ToList();
        var blocks = GradebookPdfLayout.BuildBlocks(model.TypeSections);
        Assert.Equal(2, blocks.Count);
        Assert.True(blocks[0].Activities.Count + blocks[1].Activities.Count == n);
        Assert.True(GradebookPdfRenderer.Generate(model, null).Length > 100);
    }

    [Fact]
    public void Generate_15And30Activities_PaginatesHorizontally()
    {
        foreach (var count in new[] { 15, 30 })
        {
            var model = GradebookPdfFixtures.SanMiguelitoCivica9G(exerciseCount: count);
            var blocks = GradebookPdfLayout.BuildBlocks(model.TypeSections);
            Assert.True(blocks.Count >= 2, $"count={count}");
            var pdf = GradebookPdfRenderer.Generate(model, null);
            var images = Images(model);
            Assert.True(pdf.Length > 100);
            Assert.True(images.Count >= blocks.Count);
        }
    }

    [Fact]
    public void Generate_ManyStudents_PaginatesVerticallyWithoutOverflow()
    {
        var model = GradebookPdfFixtures.SanMiguelitoCivica9G(exerciseCount: 4, studentCount: 40);
        var images = Images(model);
        Assert.True(images.Count >= 1);
        Assert.True(GradebookPdfRenderer.Generate(model, null).Length > 100);
    }

    [Fact]
    public void Generate_LongNamesAndDocuments_DoesNotThrow()
    {
        var model = GradebookPdfFixtures.SanMiguelitoCivica9G(exerciseCount: 3, studentCount: 8);
        model.Students[0].Name = "Alvarado Palacios, Amado Enrique de la Cruz y González";
        model.Students[0].DocumentId = "PE-8-123-456-789-000";
        Assert.True(GradebookPdfRenderer.Generate(model, null).Length > 100);
    }

    [Fact]
    public void Generate_WithAndWithoutLogo_AndRecovery()
    {
        var without = GradebookPdfFixtures.SanMiguelitoCivica9G(exerciseCount: 3, withRecovery: false);
        var with = GradebookPdfFixtures.SanMiguelitoCivica9G(exerciseCount: 3, withRecovery: true);
        Assert.DoesNotContain(without.TypeSections, s => s.TypeKey == "recuperación");
        Assert.Contains(with.TypeSections, s => s.TypeKey == "recuperación");

        var tinyPng = Convert.FromBase64String(
            "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==");

        Assert.True(GradebookPdfRenderer.Generate(without, null).Length > 100);
        Assert.True(GradebookPdfRenderer.Generate(with, tinyPng).Length > 100);
    }

    [Fact]
    public void EachActivityAppearsOnce_AndIdentityColumnsAreInEveryBlock()
    {
        var model = GradebookPdfFixtures.SanMiguelitoCivica9G(exerciseCount: 30);
        var blocks = GradebookPdfLayout.BuildBlocks(model.TypeSections);
        var ids = blocks.SelectMany(b => b.Activities).Select(a => a.Id).ToList();
        Assert.Equal(ids.Count, ids.Distinct().Count());
        Assert.Equal(model.TypeSections.Sum(s => s.Activities.Count), ids.Count);

        foreach (var block in blocks)
        {
            Assert.True(block.Activities.Count <= GradebookPdfLayout.SafeActivityChunkSize);
            Assert.False(string.IsNullOrWhiteSpace(block.BlockTitle));
        }

        Assert.True(GradebookPdfLayout.ColName > 100);
        Assert.True(GradebookPdfLayout.ColDocument > 50);
    }

    [Fact]
    public void MinFont_IsAtLeast8_AndNoScaleApiInRendererSource()
    {
        Assert.True(GradebookPdfRenderer.MinFontSize >= 8f);
        var rendererPath = Path.Combine(
            FindRepoRoot(),
            "SchoolManager",
            "Services",
            "Implementations",
            "GradebookPdfRenderer.cs");
        var source = File.ReadAllText(rendererPath);
        Assert.DoesNotContain(".Scale(", source);
        Assert.DoesNotContain("14f / totalCols", source);
    }

    [Fact]
    public void Generate_WritesCorrectedArtifactPdfAndPageImages()
    {
        var model = GradebookPdfFixtures.SanMiguelitoCivica9G(exerciseCount: 18, studentCount: 12, withRecovery: true);
        var pdf = GradebookPdfRenderer.Generate(model, null);
        var dir = Path.Combine(FindRepoRoot(), "artifacts", "gradebook-pdf");
        Directory.CreateDirectory(dir);
        var pdfPath = Path.Combine(dir, "Registro_Calificaciones_1T_corregido.pdf");
        File.WriteAllBytes(pdfPath, pdf);
        var pdfText = System.Text.Encoding.ASCII.GetString(pdf);
        Assert.Contains("/MediaBox [0 0 1008 612]", pdfText);

        var images = Images(model);
        var page = 1;
        foreach (var img in images)
        {
            File.WriteAllBytes(Path.Combine(dir, $"pagina_{page:00}.png"), img);
            page++;
        }

        File.WriteAllText(
            Path.Combine(dir, "README.txt"),
            "Fixture representativo IPT San Miguelito / Gertrudis Kirton Winter / Cívica / 9 G / 1T. " +
            "No es un dump de producción; replica el escenario descrito en la corrección.");

        Assert.True(File.Exists(pdfPath));
        Assert.True(images.Count >= 1);
        Assert.True(page - 1 == images.Count);
    }

    private static IReadOnlyList<byte[]> Images(GradebookPdfDto model) =>
        GradebookPdfRenderer.BuildDocument(model, null).GenerateImages().ToList();

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
