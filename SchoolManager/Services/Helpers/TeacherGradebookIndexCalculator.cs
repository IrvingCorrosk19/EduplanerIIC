using System.Globalization;
using SchoolManager.Dtos;

namespace SchoolManager.Services.Helpers;

/// <summary>
/// Única fuente funcional de la nota final de <c>/TeacherGradebook/Index</c>
/// (<c>GetNotasCargadas</c> + <c>loadNotasCargadas</c> + <c>calcAverages</c>).
/// FormatoCarpetasReport y GetPromediosFinales deben usar este cálculo, no uno paralelo.
/// </summary>
public static class TeacherGradebookIndexCalculator
{
    /// <summary>
    /// Replica el bucle de <c>TeacherGradebookController.GetNotasCargadas</c>:
    /// por cada actividad visible, la nota es <c>FirstOrDefault</c> por tipo+nombre
    /// (no por ActivityId). El JS luego pisa la celda lógica; como el payload
    /// reutiliza esa primera coincidencia, gana la primera nota del filtro.
    /// </summary>
    public static List<TeacherGradebookIndexCeldaDto> BuildNotasPorActividad(
        IEnumerable<ActivityHeaderDto> activities,
        IReadOnlyList<NotaDetalleDto> notasAlumno)
    {
        var actividadesPorTipo = activities
            .GroupBy(a => a.Type.ToLower())
            .ToDictionary(g => g.Key, g => g.ToList());

        var notasPorActividad = new List<TeacherGradebookIndexCeldaDto>();
        foreach (var tipo in actividadesPorTipo.Keys)
        {
            foreach (var act in actividadesPorTipo[tipo])
            {
                var nota = notasAlumno.FirstOrDefault(n =>
                    n.Tipo.ToLower() == tipo && n.Actividad == act.Name);
                notasPorActividad.Add(new TeacherGradebookIndexCeldaDto
                {
                    Tipo = tipo,
                    Actividad = act.Name,
                    Nota = nota != null ? nota.Nota : null,
                    Id = act.Id,
                    PdfUrl = act.PdfUrl,
                    DueDate = act.DueDate
                });
            }
        }

        return notasPorActividad;
    }

    public static decimal? CalcularNotaFinal(
        IEnumerable<ActivityHeaderDto> activities,
        IReadOnlyList<NotaDetalleDto> notasAlumno) =>
        CalcularNotaFinal(BuildNotasPorActividad(activities, notasAlumno));

    /// <summary>
    /// Replica <c>loadNotasCargadas</c> (última celda lógica gana, vacío borra)
    /// y <c>calcAverages</c> (truncar a 1 decimal, nunca redondear; recuperación).
    /// </summary>
    public static decimal? CalcularNotaFinal(IEnumerable<TeacherGradebookIndexCeldaDto> celdas)
    {
        var namesByType = new Dictionary<string, List<string>>(StringComparer.Ordinal);
        var cellByTypeName = new Dictionary<(string Type, string Name), double?>();

        foreach (var celda in celdas)
        {
            var tipo = celda.Tipo.ToLower();
            if (!GradebookVisibleActivitySelector.ViewTypeOrder.Contains(tipo, StringComparer.Ordinal))
                continue;

            if (!namesByType.TryGetValue(tipo, out var names))
            {
                names = new List<string>();
                namesByType[tipo] = names;
            }

            if (!names.Contains(celda.Actividad, StringComparer.Ordinal))
                names.Add(celda.Actividad);

            // JS: nota.nota ? truncateToOneDecimal(nota.nota) : ''
            cellByTypeName[(tipo, celda.Actividad)] = ParseIndexCell(celda.Nota);
        }

        if (namesByType.Count == 0)
            return null;

        var typeAvgs = new Dictionary<string, double>(StringComparer.Ordinal);
        var typeHasScores = new HashSet<string>(StringComparer.Ordinal);

        foreach (var typeKey in GradebookVisibleActivitySelector.ViewTypeOrder)
        {
            if (!namesByType.TryGetValue(typeKey, out var names) || names.Count == 0)
                continue;

            var valid = names
                .Select(n => cellByTypeName.GetValueOrDefault((typeKey, n)))
                .Where(v => v.HasValue)
                .Select(v => v!.Value)
                .ToList();

            if (valid.Count > 0)
                typeHasScores.Add(typeKey);

            var avg = valid.Count > 0 ? valid.Sum() / valid.Count : 0.0;
            typeAvgs[typeKey] = TruncateLikeJs(avg);
        }

        var typesForFinal = typeAvgs.Keys.ToList();
        if (typeHasScores.Contains("recuperación"))
        {
            typeAvgs["examen final"] = typeAvgs.GetValueOrDefault("recuperación");
            typesForFinal = typesForFinal.Where(t => t != "recuperación").ToList();
        }

        var validAvgs = typesForFinal.Where(t => typeHasScores.Contains(t)).ToList();
        if (validAvgs.Count == 0)
            return null;

        var finalGrade = validAvgs.Sum(t => typeAvgs[t]) / validAvgs.Count;
        var truncated = TruncateLikeJs(finalGrade);
        return GradebookFinalGradeCalculator.TruncateOneDecimal((decimal)truncated);
    }

    /// <summary>Replica <c>Math.floor(value * 10) / 10</c> de Index.cshtml. Nunca redondea.</summary>
    public static double TruncateLikeJs(double value) => Math.Floor(value * 10.0) / 10.0;

    private static double? ParseIndexCell(string? nota)
    {
        if (string.IsNullOrEmpty(nota))
            return null;

        if (!double.TryParse(nota, NumberStyles.Float, CultureInfo.InvariantCulture, out var n)
            && !double.TryParse(nota, NumberStyles.Float, CultureInfo.CurrentCulture, out n))
        {
            return null;
        }

        if (double.IsNaN(n))
            return null;

        return TruncateLikeJs(n);
    }
}

public sealed class TeacherGradebookIndexCeldaDto
{
    public string Tipo { get; init; } = "";
    public string Actividad { get; init; } = "";
    public string? Nota { get; init; }
    public Guid Id { get; init; }
    public string? PdfUrl { get; init; }
    public DateTime? DueDate { get; init; }
}
