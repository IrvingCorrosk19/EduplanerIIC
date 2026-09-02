using System.Globalization;
using SchoolManager.Dtos;

namespace SchoolManager.Services.Helpers;

/// <summary>
/// Replica la regla de columnas de <c>Index.cshtml</c>:
/// tipos fijos de la vista, orden de <c>refreshTable</c>, y deduplicación
/// <c>tipo.toLowerCase() + name ===</c> conservando la primera aparición
/// (actividades ya ordenadas por <c>CreatedAt</c>, igual que GetNotasCargadas).
/// </summary>
public static class GradebookVisibleActivitySelector
{
    /// <summary>
    /// Mismos tipos y orden que <c>activeTypes</c> en Index.cshtml (~L1852 y ~L2184).
    /// Cualquier otro Type (tarea, parcial, legado) se descarta, como en la UI.
    /// </summary>
    public static readonly string[] ViewTypeOrder =
    {
        "notas de apreciación",
        "ejercicios diarios",
        "examen final",
        "recuperación"
    };

    public static string NormalizeType(string? type) =>
        GradebookFinalGradeCalculator.NormalizeActivityType(type);

    public static bool IsViewAdmittedType(string? type)
    {
        var key = NormalizeType(type);
        return ViewTypeOrder.Contains(key, StringComparer.Ordinal);
    }

    /// <summary>
    /// Clave lógica idéntica a JS: tipo en minúsculas + nombre exacto (===, sin trim del nombre).
    /// </summary>
    public static string LogicalColumnKey(string? type, string? name) =>
        NormalizeType(type) + "\n" + (name ?? "");

    public static IReadOnlyList<GradebookPdfTypeSectionDto> SelectVisibleColumns(
        IEnumerable<ActivityHeaderDto> activities)
    {
        var logical = SelectLogicalActivities(activities);
        var sections = new List<GradebookPdfTypeSectionDto>();

        foreach (var typeKey in ViewTypeOrder)
        {
            var acts = logical.Where(a => a.TypeKey == typeKey).ToList();
            if (acts.Count == 0)
                continue;

            sections.Add(new GradebookPdfTypeSectionDto
            {
                TypeKey = typeKey,
                TypeLabel = CultureInfo.CurrentCulture.TextInfo.ToTitleCase(typeKey),
                ShortLabel = TypeShortLabel(typeKey),
                Activities = acts.Select(ToColumn).ToList()
            });
        }

        return sections;
    }

    public static IReadOnlyList<GradebookLogicalActivity> SelectLogicalActivities(
        IEnumerable<ActivityHeaderDto> activities)
    {
        var buckets = new Dictionary<string, GradebookLogicalActivity>(StringComparer.Ordinal);
        var order = new List<string>();

        foreach (var act in activities)
        {
            var typeKey = NormalizeType(act.Type);
            if (!ViewTypeOrder.Contains(typeKey, StringComparer.Ordinal))
                continue;

            var key = LogicalColumnKey(act.Type, act.Name);
            if (buckets.TryGetValue(key, out var existing))
            {
                existing.AliasIds.Add(act.Id);
                continue;
            }

            buckets[key] = new GradebookLogicalActivity
            {
                Id = act.Id,
                Name = act.Name,
                TypeKey = typeKey,
                DueDate = act.DueDate,
                AliasIds = new List<Guid> { act.Id }
            };
            order.Add(key);
        }

        return order.Select(k => buckets[k]).ToList();
    }

    public static decimal? ResolveScore(
        GradebookPdfActivityColDto column,
        IReadOnlyDictionary<Guid, decimal?> scoresByActivityId)
    {
        foreach (var id in EnumerateScoreLookupIds(column))
        {
            if (scoresByActivityId.TryGetValue(id, out var value) && value.HasValue)
                return value;
        }

        return null;
    }

    public static string TypeShortLabel(string typeKey) => typeKey switch
    {
        "notas de apreciación" => "Aprec.",
        "ejercicios diarios" => "Ejerc.",
        "examen final" => "Examen",
        "recuperación" => "Recup.",
        _ => typeKey.Length > 10 ? typeKey[..10] : typeKey
    };

    private static IEnumerable<Guid> EnumerateScoreLookupIds(GradebookPdfActivityColDto column)
    {
        yield return column.Id;
        if (column.AliasIds == null)
            yield break;
        foreach (var id in column.AliasIds)
        {
            if (id != column.Id)
                yield return id;
        }
    }

    private static GradebookPdfActivityColDto ToColumn(GradebookLogicalActivity act) =>
        new()
        {
            Id = act.Id,
            Name = act.Name,
            DueDateDisplay = act.DueDate?.ToString("dd/MM/yyyy"),
            AliasIds = act.AliasIds.ToList()
        };
}

public sealed class GradebookLogicalActivity
{
    public Guid Id { get; init; }
    public string Name { get; init; } = "";
    public string TypeKey { get; init; } = "";
    public DateTime? DueDate { get; init; }
    public List<Guid> AliasIds { get; init; } = new();
}
