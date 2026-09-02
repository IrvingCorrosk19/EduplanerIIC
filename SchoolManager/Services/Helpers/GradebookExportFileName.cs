using System.Text;

namespace SchoolManager.Services.Helpers;

public static class GradebookExportFileName
{
    public static string BuildXlsx(string? trimester, string? group, string? subject) =>
        $"Registro_Calificaciones_{SanitizeSegment(trimester)}_{SanitizeSegment(group)}_{SanitizeSegment(subject)}.xlsx";

    public static string SanitizeSegment(string? raw)
    {
        if (string.IsNullOrWhiteSpace(raw))
            return "NA";

        var invalid = Path.GetInvalidFileNameChars();
        var builder = new StringBuilder(raw.Length);
        foreach (var ch in raw.Trim())
        {
            if (char.IsControl(ch) || invalid.Contains(ch) || ch is '/' or '\\' or ':' or '*' or '?' or '"' or '<' or '>' or '|')
            {
                builder.Append('_');
                continue;
            }

            builder.Append(ch);
        }

        var cleaned = builder.ToString().Replace("..", "_", StringComparison.Ordinal).Trim(' ', '.');
        if (cleaned.Length == 0)
            return "NA";
        if (cleaned.Length > 48)
            cleaned = cleaned[..48].Trim(' ', '.');
        return string.IsNullOrWhiteSpace(cleaned) ? "NA" : cleaned;
    }
}
