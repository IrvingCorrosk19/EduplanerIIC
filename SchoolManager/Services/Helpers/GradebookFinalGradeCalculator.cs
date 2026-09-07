using System.Globalization;
using SchoolManager.Dtos;
using SchoolManager.Models;

namespace SchoolManager.Services.Helpers;

/// <summary>
/// Nota final trimestral alineada a TeacherGradebook (calcAverages): promedios por tipo, truncamiento y recuperación.
/// </summary>
public static class GradebookFinalGradeCalculator
{
    public static decimal TruncateOneDecimal(decimal value) => Math.Floor(value * 10m) / 10m;

    /// <summary>
    /// Promedio de celdas visibles (null = vacío, 0.0 cuenta). Replica calcAverages de Index.cshtml.
    /// </summary>
    public static decimal TruncatedAverageOrZero(IEnumerable<decimal?> cellValues)
    {
        var values = cellValues
            .Where(v => v.HasValue)
            .Select(v => TruncateOneDecimal(v!.Value))
            .ToList();
        return values.Count > 0 ? TruncateOneDecimal(values.Average()) : 0m;
    }

    public static bool HasAnyScore(IEnumerable<decimal?> cellValues) =>
        cellValues.Any(v => v.HasValue);

    /// <summary>Formatea una nota ya truncada (o la trunca antes de mostrar). Nunca redondea.</summary>
    public static string FormatTruncatedGrade(decimal value)
    {
        var truncated = TruncateOneDecimal(value);
        return truncated.ToString("0.0", CultureInfo.InvariantCulture);
    }

    public static decimal? GetTruncatedTypeAverage(
        IReadOnlyList<Activity> activities,
        IReadOnlyDictionary<Guid, decimal?> scores,
        string typeKey)
    {
        var acts = activities
            .Where(a => NormalizeActivityType(a.Type) == typeKey)
            .ToList();
        if (acts.Count == 0)
            return null;

        var values = acts
            .Select(a => scores.TryGetValue(a.Id, out var v) ? v : null)
            .Where(v => v.HasValue)
            .Select(v => TruncateOneDecimal(v!.Value))
            .ToList();

        return values.Count > 0 ? TruncateOneDecimal(values.Average()) : null;
    }

    public static string NormalizeActivityType(string? type) => (type ?? "").Trim().ToLowerInvariant();

    public static decimal? CalcularNotaFinal(
        IReadOnlyList<Activity> actividadesMateria,
        IReadOnlyDictionary<Guid, decimal?> scores)
    {
        var typeOrder = new[]
        {
            "notas de apreciación",
            "ejercicios diarios",
            "examen final",
            "recuperación"
        };

        var typeAvgs = new Dictionary<string, decimal>();
        var typesWithScores = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var typeKey in typeOrder)
        {
            var acts = actividadesMateria
                .Where(a => NormalizeActivityType(a.Type) == typeKey)
                .ToList();
            if (acts.Count == 0)
                continue;

            var values = acts
                .Select(a => scores.TryGetValue(a.Id, out var v) ? v : null)
                .Where(v => v.HasValue)
                .Select(v => TruncateOneDecimal(v!.Value))
                .ToList();

            if (values.Count > 0)
                typesWithScores.Add(typeKey);

            typeAvgs[typeKey] = values.Count > 0 ? TruncateOneDecimal(values.Average()) : 0m;
        }

        if (typeAvgs.Count == 0)
            return null;

        return ComputeFinalGradeFromTypeAverages(typeAvgs, typesWithScores);
    }

    /// <summary>
    /// Misma nota final que TeacherGradebook/Index (<c>loadNotasCargadas</c> + <c>calcAverages</c>).
    /// Reglas: nunca redondear; truncar a 1 decimal en cada celda, en el promedio por tipo
    /// y en la nota final. Recuperación sustituye el examen. Duplicados tipo+nombre: gana la última.
    /// Ejemplo: promedios de tipo 2.7 y 2.8 → (2.75) → 2.7, no 2.8.
    /// </summary>
    public static decimal? CalcularNotaFinalFromVisibleActivities(
        IEnumerable<ActivityHeaderDto> activities,
        IReadOnlyDictionary<Guid, decimal?> scores)
    {
        var namesByType = new Dictionary<string, List<string>>(StringComparer.Ordinal);
        var cellByTypeName = new Dictionary<(string Type, string Name), double?>();

        foreach (var act in activities)
        {
            var typeKey = NormalizeActivityType(act.Type);
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
            cellByTypeName[(typeKey, act.Name)] = ToIndexCell(raw);
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

        if (typeAvgs.Count == 0)
            return null;

        var typesForFinal = typeAvgs.Keys
            .Where(t => t != "recuperación")
            .ToList();

        if (typeHasScores.Contains("recuperación"))
        {
            typeAvgs["examen final"] = typeAvgs.GetValueOrDefault("recuperación");
            typesForFinal = typesForFinal.Where(t => t != "recuperación").ToList();
        }

        var validAvgs = typesForFinal.Where(t => typeHasScores.Contains(t)).ToList();
        if (validAvgs.Count == 0)
            return null;

        var finalGrade = validAvgs.Sum(t => typeAvgs[t]) / validAvgs.Count;
        return (decimal)TruncateLikeJs(finalGrade);
    }

    /// <summary>Replica <c>Math.floor(value * 10) / 10</c> de Index.cshtml. Nunca redondea.</summary>
    public static double TruncateLikeJs(double value) => Math.Floor(value * 10.0) / 10.0;

    /// <summary>
    /// Misma celda que Index: ToString("0.00") y luego truncar a 1 decimal (GetNotasCargadas).
    /// </summary>
    private static double? ToIndexCell(decimal? score)
    {
        if (!score.HasValue)
            return null;

        var text = score.Value.ToString("0.00", CultureInfo.InvariantCulture);
        if (!double.TryParse(text, NumberStyles.Float, CultureInfo.InvariantCulture, out var n))
            return null;

        return TruncateLikeJs(n);
    }

    public static decimal? ComputeFinalGradeFromTypeAverages(
        Dictionary<string, decimal> typeAvgs,
        HashSet<string> typesWithScores)
    {
        var working = new Dictionary<string, decimal>(typeAvgs);

        if (typesWithScores.Contains("recuperación"))
            working["examen final"] = working.GetValueOrDefault("recuperación", 0m);

        var typesForFinal = working.Keys
            .Where(t => t != "recuperación")
            .Where(t => typesWithScores.Contains(t))
            .ToList();

        if (typesForFinal.Count == 0)
            return null;

        return TruncateOneDecimal(typesForFinal.Average(t => working[t]));
    }
}
