using SchoolManager.Models;

namespace SchoolManager.Services.Helpers;

public sealed record FormatoCarpetasAttendanceTotals(
    int AusenciasT1,
    int TardanzasT1,
    int AusenciasT2,
    int TardanzasT2,
    int AusenciasT3,
    int TardanzasT3,
    int TotalAusencias,
    int TotalTardanzas);

/// <summary>
/// Cálculo único de A/T por trimestre para VistaPrevia, PDF y Excel.
/// </summary>
public static class FormatoCarpetasAttendanceCalculator
{
    private static readonly string[] Trimestres = ["1T", "2T", "3T"];

    public static FormatoCarpetasAttendanceTotals FromBulk(ReportesGrupoBulkData bulk, Guid studentId)
    {
        var a = new int[3];
        var t = new int[3];

        for (var i = 0; i < Trimestres.Length; i++)
        {
            var trimester = bulk.TrimesterEntities.FirstOrDefault(x =>
                string.Equals(x.Name, Trimestres[i], StringComparison.OrdinalIgnoreCase));
            var (ausencias, tardanzas) = ReportesInstitucionalesBulkLoader.ContarAsistencia(
                bulk, studentId, trimester);
            a[i] = ausencias;
            t[i] = tardanzas;
        }

        return new FormatoCarpetasAttendanceTotals(
            a[0], t[0], a[1], t[1], a[2], t[2],
            a[0] + a[1] + a[2],
            t[0] + t[1] + t[2]);
    }
}
