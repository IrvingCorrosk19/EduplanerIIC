namespace SchoolManager.Services.Helpers;

/// <summary>
/// Agrega ausencias/tardanzas de una materia: una fecha = un día, clasificada por calendario oficial.
/// </summary>
public static class AttendanceSubjectAggregator
{
    public sealed class AttendanceDayRow
    {
        public Guid StudentId { get; init; }
        public Guid? SchoolId { get; init; }
        public Guid? GroupId { get; init; }
        public Guid? GradeId { get; init; }
        public Guid? SubjectId { get; init; }
        public Guid? AcademicYearId { get; init; }
        public DateOnly Date { get; init; }
        public string Status { get; init; } = "";
    }

    public static Dictionary<(Guid StudentId, Guid TrimesterId), (int Ausencias, int Tardanzas)> AggregateByOfficialTrimester(
        IEnumerable<AttendanceDayRow> rows,
        IReadOnlyList<Models.Trimester> officialTrimesters,
        Guid subjectId,
        Guid schoolId,
        Guid groupId,
        Guid gradeLevelId,
        Guid? academicYearId)
    {
        var filtered = rows.Where(r =>
            r.SubjectId == subjectId
            && r.GroupId == groupId
            && r.GradeId == gradeLevelId
            && (r.SchoolId == null || r.SchoolId == schoolId)
            && (!academicYearId.HasValue
                || r.AcademicYearId == null
                || r.AcademicYearId == academicYearId)).ToList();

        var dayStatus = new Dictionary<(Guid StudentId, DateOnly Date), string>();
        foreach (var row in filtered)
        {
            var key = (row.StudentId, row.Date);
            if (!dayStatus.TryGetValue(key, out var current))
            {
                dayStatus[key] = NormalizeStatus(row.Status);
                continue;
            }

            dayStatus[key] = MergeDayStatus(current, NormalizeStatus(row.Status));
        }

        var result = new Dictionary<(Guid, Guid), (int, int)>();
        foreach (var trim in officialTrimesters)
            foreach (var studentGroup in dayStatus.Keys.Select(k => k.StudentId).Distinct())
                result[(studentGroup, trim.Id)] = (0, 0);

        foreach (var ((studentId, date), status) in dayStatus)
        {
            var trim = AttendanceOfficialCalendar.ResolveOfficialTrimester(date, officialTrimesters);
            if (trim == null)
                continue;

            result.TryGetValue((studentId, trim.Id), out var counts);
            if (string.Equals(status, "absent", StringComparison.OrdinalIgnoreCase))
                counts.Item1++;
            else if (string.Equals(status, "late", StringComparison.OrdinalIgnoreCase))
                counts.Item2++;

            result[(studentId, trim.Id)] = counts;
        }

        return result;
    }

    public static string NormalizeStatus(string? status) => (status ?? "").Trim().ToLowerInvariant();

    /// <summary>Un día: si hay ausencia, es ausencia; si no, tardanza gana sobre presente.</summary>
    public static string MergeDayStatus(string existing, string incoming)
    {
        if (existing == "absent" || incoming == "absent")
            return "absent";
        if (existing == "late" || incoming == "late")
            return "late";
        return incoming.Length > 0 ? incoming : existing;
    }
}
