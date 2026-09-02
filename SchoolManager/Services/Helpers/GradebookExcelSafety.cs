namespace SchoolManager.Services.Helpers;

/// <summary>
/// Evita que texto de usuario o base de datos se interprete como fórmula de Excel.
/// </summary>
public static class GradebookExcelSafety
{
    public static bool NeedsFormulaGuard(string? value)
    {
        if (string.IsNullOrEmpty(value))
            return false;

        var trimmed = value.TrimStart();
        if (trimmed.Length == 0)
            return false;

        var first = trimmed[0];
        return first is '=' or '+' or '-' or '@';
    }

    public static string AsSafeExcelText(string? value)
    {
        var text = value ?? string.Empty;
        return NeedsFormulaGuard(text) ? "'" + text : text;
    }
}
