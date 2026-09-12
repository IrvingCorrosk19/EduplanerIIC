using SchoolManager.Models;

namespace SchoolManager.Services.Helpers;

/// <summary>
/// Clasifica una fecha con el calendario oficial de trimestres (StartDate/EndDate).
/// Sin rangos hardcodeados. Si la fecha cae en un hueco, no pertenece a ningún trimestre.
/// </summary>
public static class AttendanceOfficialCalendar
{
    public static Trimester? ResolveOfficialTrimester(DateOnly date, IEnumerable<Trimester> officialTrimesters)
    {
        var matches = officialTrimesters
            .Where(t =>
            {
                var start = DateOnly.FromDateTime(t.StartDate);
                var end = DateOnly.FromDateTime(t.EndDate);
                return date >= start && date <= end;
            })
            .OrderBy(t => t.Order)
            .ThenBy(t => t.StartDate)
            .ToList();

        return matches.Count == 0 ? null : matches[0];
    }

    public static IReadOnlyList<Trimester> OfficialForSchoolYear(
        IEnumerable<Trimester> schoolTrimesters,
        Guid schoolId,
        Guid? academicYearId)
    {
        return schoolTrimesters
            .Where(t => t.SchoolId == schoolId)
            .Where(t =>
                !academicYearId.HasValue
                || t.AcademicYearId == academicYearId
                || t.AcademicYearId == null)
            .ToList();
    }
}
