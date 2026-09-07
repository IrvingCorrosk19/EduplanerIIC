using System.Globalization;
using SchoolManager.Dtos;
using SchoolManager.Services.Helpers;
using SchoolManager.ViewModels;

namespace SchoolManager.Tests;

public class TeacherGradebookIndexCalculatorTests
{
    [Fact]
    public void TypeAverages_2_7_And_2_8_TruncateTo_2_7_NotRoundedTo_2_8()
    {
        // Caso real: promedio de tipos 2.7 y 2.8 = 2.75. Index trunca a 2.7; ToString("0.0") redondearía a 2.8.
        Assert.Equal("2.8", 2.75m.ToString("0.0", CultureInfo.InvariantCulture));
        Assert.Equal("2.7", GradebookFinalGradeCalculator.FormatTruncatedGrade(2.75m));

        var aprec = Guid.NewGuid();
        var ejerc = Guid.NewGuid();
        var activities = new List<ActivityHeaderDto>
        {
            new() { Id = aprec, Name = "Oral 1", Type = "notas de apreciación" },
            new() { Id = ejerc, Name = "Taller 1", Type = "ejercicios diarios" }
        };
        var notas = new List<NotaDetalleDto>
        {
            new() { Tipo = "notas de apreciación", Actividad = "Oral 1", Nota = "2.70" },
            new() { Tipo = "ejercicios diarios", Actividad = "Taller 1", Nota = "2.80" }
        };

        var final = TeacherGradebookIndexCalculator.CalcularNotaFinal(activities, notas);
        Assert.Equal(2.7m, final);
        Assert.Equal("2.7", FormatoCarpetasFilaViewModel.FormatearNota(final));
    }

    [Fact]
    public void FirstNameMatch_NotLastActivityId_ProducesIndexGrade_NotCarpetasOldGrade()
    {
        // Index (GetNotasCargadas): FirstOrDefault por tipo+nombre.
        // Carpetas antiguo: última nota por ActivityId. Eso daba 2.8 cuando Index daba 2.7.
        var first = Guid.Parse("00000000-0000-0000-0000-000000000001");
        var last = Guid.Parse("00000000-0000-0000-0000-000000000002");
        var aprec = Guid.NewGuid();

        var activities = new List<ActivityHeaderDto>
        {
            new() { Id = first, Name = "Taller 1", Type = "ejercicios diarios" },
            new() { Id = last, Name = "Taller 1", Type = "ejercicios diarios" },
            new() { Id = aprec, Name = "Oral 1", Type = "notas de apreciación" }
        };

        var notasFiltro = new List<NotaDetalleDto>
        {
            new() { Tipo = "ejercicios diarios", Actividad = "Taller 1", Nota = "2.70" },
            new() { Tipo = "ejercicios diarios", Actividad = "Taller 1", Nota = "2.90" },
            new() { Tipo = "notas de apreciación", Actividad = "Oral 1", Nota = "2.70" }
        };

        var indexFinal = TeacherGradebookIndexCalculator.CalcularNotaFinal(activities, notasFiltro);
        Assert.Equal(2.7m, indexFinal);

        var scoresByIdLastWins = new Dictionary<Guid, decimal?>
        {
            [first] = 2.70m,
            [last] = 2.90m,
            [aprec] = 2.70m
        };
        var oldLastWins = LastWinsByActivityId(activities, scoresByIdLastWins);
        Assert.Equal(2.8m, oldLastWins);
        Assert.NotEqual(oldLastWins, indexFinal);
    }

    [Fact]
    public void GetNotasCargadasPayload_And_GetPromediosFinales_ShareTheSameFinal()
    {
        var activities = new List<ActivityHeaderDto>
        {
            new() { Id = Guid.NewGuid(), Name = "A1", Type = "Notas de apreciación" },
            new() { Id = Guid.NewGuid(), Name = "E1", Type = "Ejercicios diarios" },
            new() { Id = Guid.NewGuid(), Name = "X1", Type = "Examen Final" }
        };
        var notas = new List<NotaDetalleDto>
        {
            new() { Tipo = "Notas de apreciación", Actividad = "A1", Nota = "3.45" },
            new() { Tipo = "Ejercicios diarios", Actividad = "E1", Nota = "3.49" },
            new() { Tipo = "Examen Final", Actividad = "X1", Nota = "3.40" }
        };

        var payload = TeacherGradebookIndexCalculator.BuildNotasPorActividad(activities, notas);
        var fromIndexGrid = TeacherGradebookIndexCalculator.CalcularNotaFinal(payload);
        var fromCarpetas = TeacherGradebookIndexCalculator.CalcularNotaFinal(activities, notas);

        Assert.Equal(fromIndexGrid, fromCarpetas);
        Assert.Equal(3.4m, fromCarpetas);
        Assert.Equal("3.4", FormatoCarpetasFilaViewModel.FormatearNota(fromCarpetas));
    }

    [Fact]
    public void EmptyLastPayloadCell_ClearsLogicalColumn_LikeIndexJs()
    {
        var first = Guid.NewGuid();
        var last = Guid.NewGuid();
        var activities = new List<ActivityHeaderDto>
        {
            new() { Id = first, Name = "Oral 1", Type = "notas de apreciación" },
            new() { Id = last, Name = "Oral 1", Type = "notas de apreciación" }
        };

        var payload = new List<TeacherGradebookIndexCeldaDto>
        {
            new() { Tipo = "notas de apreciación", Actividad = "Oral 1", Nota = "4.00", Id = first },
            new() { Tipo = "notas de apreciación", Actividad = "Oral 1", Nota = "", Id = last }
        };

        Assert.Null(TeacherGradebookIndexCalculator.CalcularNotaFinal(payload));
    }

    [Fact]
    public void RecoveryReplacesExam_AndIsExcludedFromFinalMix()
    {
        var activities = new List<ActivityHeaderDto>
        {
            new() { Id = Guid.NewGuid(), Name = "A", Type = "notas de apreciación" },
            new() { Id = Guid.NewGuid(), Name = "E", Type = "ejercicios diarios" },
            new() { Id = Guid.NewGuid(), Name = "X", Type = "examen final" },
            new() { Id = Guid.NewGuid(), Name = "R", Type = "recuperación" }
        };
        var notas = new List<NotaDetalleDto>
        {
            new() { Tipo = "notas de apreciación", Actividad = "A", Nota = "4.80" },
            new() { Tipo = "ejercicios diarios", Actividad = "E", Nota = "4.30" },
            new() { Tipo = "examen final", Actividad = "X", Nota = "4.00" },
            new() { Tipo = "recuperación", Actividad = "R", Nota = "3.50" }
        };

        // (4.8 + 4.3 + 3.5) / 3 = 4.2 truncado
        Assert.Equal(4.2m, TeacherGradebookIndexCalculator.CalcularNotaFinal(activities, notas));
    }

    [Fact]
    public void FormatoCarpetasExport_UsesTruncation_NeverRound()
    {
        Assert.Equal("2.7", FormatoCarpetasFilaViewModel.FormatearNota(2.75m));
        Assert.Equal("2.7", FormatoCarpetasFilaViewModel.FormatearNota(2.79m));
        Assert.Equal("2.8", FormatoCarpetasFilaViewModel.FormatearNota(2.80m));
        Assert.Equal(2.7m, GradebookFinalGradeCalculator.TruncateOneDecimal(2.75m));
        Assert.Equal(2.7, (double)GradebookFinalGradeCalculator.TruncateOneDecimal(2.75m));
    }

    [Fact]
    public void TruncateLikeJs_2_75_Is_2_7()
    {
        Assert.Equal(2.7, TeacherGradebookIndexCalculator.TruncateLikeJs(2.75));
        Assert.NotEqual(2.8, TeacherGradebookIndexCalculator.TruncateLikeJs(2.75));
    }

    /// <summary>
    /// Algoritmo previo de Carpetas: última nota por ActivityId (CreatedAt).
    /// </summary>
    private static decimal? LastWinsByActivityId(
        IReadOnlyList<ActivityHeaderDto> activities,
        IReadOnlyDictionary<Guid, decimal?> scores)
    {
        var namesByType = new Dictionary<string, List<string>>(StringComparer.Ordinal);
        var cellByTypeName = new Dictionary<(string, string), decimal?>();

        foreach (var act in activities)
        {
            var typeKey = GradebookFinalGradeCalculator.NormalizeActivityType(act.Type);
            if (!GradebookVisibleActivitySelector.ViewTypeOrder.Contains(typeKey, StringComparer.Ordinal))
                continue;

            if (!namesByType.TryGetValue(typeKey, out var names))
            {
                names = new List<string>();
                namesByType[typeKey] = names;
            }

            if (!names.Contains(act.Name, StringComparer.Ordinal))
                names.Add(act.Name);

            scores.TryGetValue(act.Id, out var raw);
            cellByTypeName[(typeKey, act.Name)] = raw.HasValue
                ? GradebookFinalGradeCalculator.TruncateOneDecimal(raw.Value)
                : null;
        }

        var typeAvgs = new Dictionary<string, decimal>(StringComparer.Ordinal);
        var typeHasScores = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var typeKey in GradebookVisibleActivitySelector.ViewTypeOrder)
        {
            if (!namesByType.TryGetValue(typeKey, out var names) || names.Count == 0)
                continue;
            var valid = names.Select(n => cellByTypeName.GetValueOrDefault((typeKey, n)))
                .Where(v => v.HasValue).Select(v => v!.Value).ToList();
            if (valid.Count > 0)
                typeHasScores.Add(typeKey);
            typeAvgs[typeKey] = valid.Count > 0
                ? GradebookFinalGradeCalculator.TruncateOneDecimal(valid.Average())
                : 0m;
        }

        return GradebookFinalGradeCalculator.ComputeFinalGradeFromTypeAverages(typeAvgs, typeHasScores);
    }
}
