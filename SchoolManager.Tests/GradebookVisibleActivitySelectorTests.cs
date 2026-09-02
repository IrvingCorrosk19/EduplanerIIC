using SchoolManager.Dtos;
using SchoolManager.Services.Helpers;

namespace SchoolManager.Tests;

public class GradebookVisibleActivitySelectorTests
{
    [Fact]
    public void SelectVisibleColumns_KeepsViewTypes_Order_And_DedupsByTypeAndExactName()
    {
        var firstA = Guid.Parse("00000000-0000-0000-0000-000000000001");
        var dupA = Guid.Parse("00000000-0000-0000-0000-000000000099");
        var tarea = Guid.Parse("00000000-0000-0000-0000-000000000050");

        var input = new List<ActivityHeaderDto>
        {
            new() { Id = firstA, Name = "Oral 1", Type = "Notas de apreciación" },
            new() { Id = Guid.NewGuid(), Name = "Taller 1", Type = "Ejercicios diarios" },
            new() { Id = dupA, Name = "Oral 1", Type = "Notas de apreciación" },
            new() { Id = Guid.NewGuid(), Name = "Examen", Type = "Examen Final" },
            new() { Id = tarea, Name = "Tarea legado", Type = "tarea" },
            new() { Id = Guid.NewGuid(), Name = "Recuperación", Type = "Recuperación" }
        };

        var sections = GradebookVisibleActivitySelector.SelectVisibleColumns(input);

        Assert.Equal(new[]
        {
            "notas de apreciación",
            "ejercicios diarios",
            "examen final",
            "recuperación"
        }, sections.Select(s => s.TypeKey).ToArray());

        var aprec = sections[0].Activities;
        Assert.Single(aprec);
        Assert.Equal(firstA, aprec[0].Id);
        Assert.Contains(dupA, aprec[0].AliasIds);
        Assert.DoesNotContain(sections.SelectMany(s => s.Activities), a => a.Id == tarea);
    }

    [Fact]
    public void Dedup_IsCaseSensitiveOnName_LikeJavaScriptStrictEquality()
    {
        var input = new List<ActivityHeaderDto>
        {
            new() { Id = Guid.NewGuid(), Name = "Oral 1", Type = "Notas de apreciación" },
            new() { Id = Guid.NewGuid(), Name = "oral 1", Type = "Notas de apreciación" }
        };

        var cols = GradebookVisibleActivitySelector.SelectVisibleColumns(input)[0].Activities;
        Assert.Equal(2, cols.Count);
    }

    [Fact]
    public void ResolveScore_PrefersKeptId_ThenAliasWithValue()
    {
        var kept = Guid.NewGuid();
        var alias = Guid.NewGuid();
        var col = new GradebookPdfActivityColDto
        {
            Id = kept,
            Name = "Oral 1",
            AliasIds = new List<Guid> { kept, alias }
        };

        var onlyAlias = new Dictionary<Guid, decimal?> { [alias] = 4.5m };
        Assert.Equal(4.5m, GradebookVisibleActivitySelector.ResolveScore(col, onlyAlias));

        var both = new Dictionary<Guid, decimal?> { [kept] = 3.0m, [alias] = 4.5m };
        Assert.Equal(3.0m, GradebookVisibleActivitySelector.ResolveScore(col, both));

        var empty = new Dictionary<Guid, decimal?> { [kept] = null };
        Assert.Null(GradebookVisibleActivitySelector.ResolveScore(col, empty));
    }

    [Fact]
    public void RejectsTypesNotShownOnIndex()
    {
        Assert.False(GradebookVisibleActivitySelector.IsViewAdmittedType("tarea"));
        Assert.False(GradebookVisibleActivitySelector.IsViewAdmittedType("parcial"));
        Assert.True(GradebookVisibleActivitySelector.IsViewAdmittedType("Ejercicios diarios"));
    }
}
