using SchoolManager.Dtos;
using SchoolManager.Services.Helpers;
using SchoolManager.Services.Implementations;

namespace SchoolManager.Tests;

public class GradebookPdfLayoutTests
{
    [Fact]
    public void PageSize_IsLegalPortrait()
    {
        Assert.True(GradebookPdfLayout.PageHeight > GradebookPdfLayout.PageWidth);
        Assert.Equal(8.5f * 72f, GradebookPdfLayout.PageWidth, 2);
        Assert.Equal(14f * 72f, GradebookPdfLayout.PageHeight, 2);
    }

    [Fact]
    public void MinFontSize_IsAtLeast8()
    {
        Assert.True(GradebookPdfLayout.MinFontSize >= 8f);
        Assert.True(GradebookPdfLayout.BodyFontSize >= 8f);
        Assert.Equal(GradebookPdfLayout.BodyFontSize, GradebookPdfRenderer.MinFontSize);
    }

    [Fact]
    public void SafeChunkSize_FitsIdentityAverageAndFinal()
    {
        var chunk = GradebookPdfLayout.SafeActivityChunkSize;
        Assert.True(chunk >= 1);
        var used = GradebookPdfLayout.IdentityWidth
            + chunk * GradebookPdfLayout.ColActivity
            + GradebookPdfLayout.ColAverage
            + GradebookPdfLayout.ColFinal;
        Assert.True(used <= GradebookPdfLayout.ContentWidth + 0.01f);
    }

    [Fact]
    public void BuildBlocks_SplitsByType_ThenSubBlocks_RepeatsAverageOnlyOnLastChunk()
    {
        var exercises = Enumerable.Range(1, 30)
            .Select(i => new GradebookPdfActivityColDto { Id = Guid.NewGuid(), Name = $"E{i}" })
            .ToList();

        var sections = new List<GradebookPdfTypeSectionDto>
        {
            new()
            {
                TypeKey = "notas de apreciación",
                TypeLabel = "Notas De Apreciación",
                ShortLabel = "Aprec.",
                Activities = new List<GradebookPdfActivityColDto>
                {
                    new() { Id = Guid.NewGuid(), Name = "A1" }
                }
            },
            new()
            {
                TypeKey = "ejercicios diarios",
                TypeLabel = "Ejercicios Diarios",
                ShortLabel = "Ejerc.",
                Activities = exercises
            },
            new()
            {
                TypeKey = "examen final",
                TypeLabel = "Examen Final",
                ShortLabel = "Examen",
                Activities = new List<GradebookPdfActivityColDto>
                {
                    new() { Id = Guid.NewGuid(), Name = "Examen" }
                }
            }
        };

        var blocks = GradebookPdfLayout.BuildBlocks(sections);
        Assert.True(blocks.Count >= 4);

        var exerciseBlocks = blocks.Where(b => b.TypeKey == "ejercicios diarios").ToList();
        Assert.True(exerciseBlocks.Count >= 2);
        Assert.All(exerciseBlocks.Take(exerciseBlocks.Count - 1), b => Assert.False(b.ShowTypeAverage));
        Assert.True(exerciseBlocks[^1].ShowTypeAverage);
        Assert.Contains("completo", exerciseBlocks[^1].AverageCaption, StringComparison.OrdinalIgnoreCase);

        Assert.False(exerciseBlocks[^1].ShowFinalGrade);
        Assert.True(blocks[^1].ShowFinalGrade);

        var activityIds = blocks.SelectMany(b => b.Activities).Select(a => a.Id).ToList();
        Assert.Equal(activityIds.Count, activityIds.Distinct().Count());
        Assert.Equal(32, activityIds.Count);
    }

    [Theory]
    [InlineData(0, 0)]
    [InlineData(1, 1)]
    [InlineData(15, -1)]
    [InlineData(30, -1)]
    public void Chunk_CoversAllActivities(int count, int expectedChunks)
    {
        var size = GradebookPdfLayout.SafeActivityChunkSize;
        var acts = Enumerable.Range(1, count)
            .Select(i => new GradebookPdfActivityColDto { Id = Guid.NewGuid(), Name = $"A{i}" })
            .ToList();
        var chunks = GradebookPdfLayout.Chunk(acts, size);
        var expected = expectedChunks >= 0
            ? expectedChunks
            : count == 0 ? 0 : (int)Math.Ceiling(count / (double)size);
        Assert.Equal(expected, chunks.Count);
        Assert.Equal(count, chunks.Sum(c => c.Count));
    }
}
