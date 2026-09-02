using SchoolManager.Services.Helpers;

namespace SchoolManager.Tests;

public class GradebookFinalGradeCalculatorTests
{
    [Fact]
    public void Truncate_4_59_Is_4_5_NeverRoundedTo_4_6()
    {
        Assert.Equal(4.5m, GradebookFinalGradeCalculator.TruncateOneDecimal(4.59m));
        Assert.NotEqual(4.6m, GradebookFinalGradeCalculator.TruncateOneDecimal(4.59m));
        Assert.Equal("4.5", GradebookFinalGradeCalculator.FormatTruncatedGrade(4.59m));
    }

    [Fact]
    public void EmptyCells_AreNotZero_ZeroIsCounted()
    {
        var cells = new decimal?[] { 4.0m, null, 0.0m };
        Assert.True(GradebookFinalGradeCalculator.HasAnyScore(cells));
        Assert.Equal(2.0m, GradebookFinalGradeCalculator.TruncatedAverageOrZero(cells));

        var allEmpty = new decimal?[] { null, null };
        Assert.False(GradebookFinalGradeCalculator.HasAnyScore(allEmpty));
        Assert.Equal(0.0m, GradebookFinalGradeCalculator.TruncatedAverageOrZero(allEmpty));
    }

    [Fact]
    public void TypeAverages_AndFinal_MatchCalcAveragesJavaScriptRules()
    {
        var aprec = new decimal?[] { 4.8m, 4.9m, 4.7m };
        var ejerc = new decimal?[] { 4.3m, 4.4m };
        var exam = new decimal?[] { 4.0m };
        var recup = new decimal?[] { 3.5m };

        var typeAvgs = new Dictionary<string, decimal>
        {
            ["notas de apreciación"] = GradebookFinalGradeCalculator.TruncatedAverageOrZero(aprec),
            ["ejercicios diarios"] = GradebookFinalGradeCalculator.TruncatedAverageOrZero(ejerc),
            ["examen final"] = GradebookFinalGradeCalculator.TruncatedAverageOrZero(exam),
            ["recuperación"] = GradebookFinalGradeCalculator.TruncatedAverageOrZero(recup)
        };

        Assert.Equal(4.8m, typeAvgs["notas de apreciación"]);
        Assert.Equal(4.3m, typeAvgs["ejercicios diarios"]);
        Assert.Equal(4.0m, typeAvgs["examen final"]);
        Assert.Equal(3.5m, typeAvgs["recuperación"]);

        var withRecovery = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            "notas de apreciación", "ejercicios diarios", "examen final", "recuperación"
        };
        var final = GradebookFinalGradeCalculator.ComputeFinalGradeFromTypeAverages(typeAvgs, withRecovery);
        // examen reemplazado por 3.5; promedio (4.8+4.3+3.5)/3 = 4.2 truncado
        Assert.Equal(4.2m, final);
    }

    [Fact]
    public void RecoveryWithoutExamScores_DoesNotInjectExamIntoFinal_LikeIndexJs()
    {
        var typeAvgs = new Dictionary<string, decimal>
        {
            ["notas de apreciación"] = 4.0m,
            ["examen final"] = 0m,
            ["recuperación"] = 3.0m
        };
        var typesWithScores = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            "notas de apreciación", "recuperación"
        };

        var final = GradebookFinalGradeCalculator.ComputeFinalGradeFromTypeAverages(typeAvgs, typesWithScores);
        Assert.Equal(4.0m, final);
    }
}
