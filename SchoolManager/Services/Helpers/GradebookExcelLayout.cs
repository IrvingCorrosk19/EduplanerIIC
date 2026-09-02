namespace SchoolManager.Services.Helpers;

public static class GradebookExcelLayout
{
    public const string SheetName = "Registro de Calificaciones";
    public const string NumberFormat = "0.0";
    public const string TextFormat = "@";
    public const string XlsxContentType =
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

    public const decimal PassingGrade = 3.0m;

    public const int TitleRow = 1;
    public const int SchoolRow = 2;
    public const int MetaStartRow = 4;
    public const int TableHeaderRow = 9;
    public const int FirstDataRow = 10;
    public const int FrozenIdentityColumns = 2;

    public const int FewActivityFitToWidthLimit = 12;
}
