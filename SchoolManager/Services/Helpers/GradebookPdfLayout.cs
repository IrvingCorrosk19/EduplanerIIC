using SchoolManager.Dtos;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;

namespace SchoolManager.Services.Helpers;

/// <summary>
/// Medidas de página legal vertical: 8.5 pulgadas de ancho × 14 de alto (hoja larga).
/// </summary>
public static class GradebookPdfLayout
{
    public const float MinFontSize = 8f;
    public const float BodyFontSize = 8f;
    public const float HeaderTitleFontSize = 13f;
    public const float WatermarkFontSize = 28f;

    public const float MarginHorizontal = 20f;
    public const float MarginVertical = 16f;

    /// <summary>Legal vertical: el lado largo (14") es la altura.</summary>
    public static readonly PageSize PageSize = new(8.5f, 14f, Unit.Inch);
    public static float PageWidth => PageSize.Width;
    public static float PageHeight => PageSize.Height;
    public static float ContentWidth => PageWidth - (2f * MarginHorizontal);

    public const float ColNumber = 22f;
    public const float ColName = 148f;
    public const float ColDocument = 74f;
    public const float ColActivity = 40f;
    public const float ColAverage = 46f;
    public const float ColFinal = 50f;

    public static float IdentityWidth => ColNumber + ColName + ColDocument;

    /// <summary>
    /// Máximo de columnas de actividad que caben junto a identidad y, opcionalmente, promedio y nota final.
    /// </summary>
    public static int MaxActivityColumns(bool includeAverage, bool includeFinal)
    {
        var remaining = ContentWidth - IdentityWidth;
        if (includeAverage)
            remaining -= ColAverage;
        if (includeFinal)
            remaining -= ColFinal;

        var count = (int)Math.Floor(remaining / ColActivity);
        return Math.Max(1, count);
    }

    /// <summary>
    /// Tamaño de bloque uniforme: siempre deja hueco para Promedio + Nota final (peor caso de ancho).
    /// Evita overflow al pintar el último subbloque de la última sección.
    /// </summary>
    public static int SafeActivityChunkSize => MaxActivityColumns(includeAverage: true, includeFinal: true);

    public static IReadOnlyList<GradebookPdfTableBlock> BuildBlocks(
        IReadOnlyList<GradebookPdfTypeSectionDto> sections)
    {
        var chunkSize = SafeActivityChunkSize;
        var blocks = new List<GradebookPdfTableBlock>();

        for (var sectionIndex = 0; sectionIndex < sections.Count; sectionIndex++)
        {
            var section = sections[sectionIndex];
            var isLastType = sectionIndex == sections.Count - 1;
            var chunks = Chunk(section.Activities, chunkSize);
            if (chunks.Count == 0)
                continue;

            for (var i = 0; i < chunks.Count; i++)
            {
                var isLastChunkOfType = i == chunks.Count - 1;
                blocks.Add(new GradebookPdfTableBlock
                {
                    TypeKey = section.TypeKey,
                    TypeLabel = section.TypeLabel,
                    ShortLabel = section.ShortLabel,
                    TypeBlockIndex = i + 1,
                    TypeBlockCount = chunks.Count,
                    ShowTypeAverage = isLastChunkOfType,
                    ShowFinalGrade = isLastType && isLastChunkOfType,
                    Activities = chunks[i]
                });
            }
        }

        return blocks;
    }

    public static IReadOnlyList<IReadOnlyList<GradebookPdfActivityColDto>> Chunk(
        IReadOnlyList<GradebookPdfActivityColDto> activities,
        int size)
    {
        if (activities.Count == 0)
            return Array.Empty<IReadOnlyList<GradebookPdfActivityColDto>>();

        var result = new List<IReadOnlyList<GradebookPdfActivityColDto>>();
        for (var i = 0; i < activities.Count; i += size)
            result.Add(activities.Skip(i).Take(size).ToList());
        return result;
    }
}

public sealed class GradebookPdfTableBlock
{
    public string TypeKey { get; init; } = "";
    public string TypeLabel { get; init; } = "";
    public string ShortLabel { get; init; } = "";
    public int TypeBlockIndex { get; init; }
    public int TypeBlockCount { get; init; }
    public bool ShowTypeAverage { get; init; }
    public bool ShowFinalGrade { get; init; }
    public IReadOnlyList<GradebookPdfActivityColDto> Activities { get; init; } =
        Array.Empty<GradebookPdfActivityColDto>();

    public string BlockTitle =>
        TypeBlockCount > 1
            ? $"{TypeLabel} — Bloque {TypeBlockIndex} de {TypeBlockCount}"
            : TypeLabel;

    public string AverageCaption =>
        TypeBlockCount > 1 && ShowTypeAverage
            ? $"Prom. {ShortLabel} (completo)"
            : $"Prom. {ShortLabel}";
}
