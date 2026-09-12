using SchoolManager.Dtos;
using SchoolManager.Services.Helpers;

namespace SchoolManager.Tests;

public class FormatoCarpetasGradebookUnchangedTests
{
    [Fact]
    public void AttendanceFix_DoesNotChangeGradebookFinalCalculation()
    {
        var activities = new List<ActivityHeaderDto>
        {
            new() { Id = Guid.NewGuid(), Name = "Oral 1", Type = "notas de apreciación" },
            new() { Id = Guid.NewGuid(), Name = "Taller 1", Type = "ejercicios diarios" },
            new() { Id = Guid.NewGuid(), Name = "Examen 1", Type = "examen final" }
        };
        var notas = new List<NotaDetalleDto>
        {
            new() { Tipo = "notas de apreciación", Actividad = "Oral 1", Nota = "4.20" },
            new() { Tipo = "ejercicios diarios", Actividad = "Taller 1", Nota = "3.80" },
            new() { Tipo = "examen final", Actividad = "Examen 1", Nota = "4.00" }
        };

        var expected = TeacherGradebookIndexCalculator.CalcularNotaFinal(activities, notas);
        Assert.NotNull(expected);
        Assert.Equal(expected, TeacherGradebookIndexCalculator.CalcularNotaFinal(activities, notas));
        Assert.Equal(
            GradebookFinalGradeCalculator.CalcularNotaFinalFromVisibleActivities(
                activities,
                activities.ToDictionary(
                    a => a.Id,
                    a => notas.First(n =>
                        n.Actividad == a.Name &&
                        n.Tipo.Equals(a.Type, StringComparison.OrdinalIgnoreCase)).Nota is { } raw
                        && decimal.TryParse(raw, System.Globalization.NumberStyles.Any,
                            System.Globalization.CultureInfo.InvariantCulture, out var v)
                        ? (decimal?)v
                        : null)),
            expected);
    }
}
