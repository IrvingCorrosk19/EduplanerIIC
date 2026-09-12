using SchoolManager.Models;
using SchoolManager.Services.Helpers;

namespace SchoolManager.Tests;

public class AttendanceSubjectAggregatorTests
{
    private static readonly Guid School = Guid.Parse("6e42399f-6f17-4585-b92e-fa4fff02cb65");
    private static readonly Guid OtherSchool = Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa");
    private static readonly Guid Group = Guid.Parse("4a5980a9-1111-2222-3333-444444444444");
    private static readonly Guid OtherGroup = Guid.Parse("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb");
    private static readonly Guid Grade = Guid.Parse("9811c9ae-1111-2222-3333-444444444444");
    private static readonly Guid OtherGrade = Guid.Parse("cccccccc-cccc-cccc-cccc-cccccccccccc");
    private static readonly Guid Civica = Guid.Parse("6592de4d-1111-2222-3333-444444444444");
    private static readonly Guid Religion = Guid.Parse("dddddddd-dddd-dddd-dddd-dddddddddddd");
    private static readonly Guid Year = Guid.Parse("eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee");
    private static readonly Guid OtherYear = Guid.Parse("ffffffff-ffff-ffff-ffff-ffffffffffff");
    private static readonly Guid Student = Guid.Parse("9b69aeb2-f238-47bc-b650-69accb740d49");

    private static AttendanceSubjectAggregator.AttendanceDayRow Row(
        Guid subjectId, DateOnly date, string status = "absent",
        Guid? schoolId = null, Guid? groupId = null, Guid? gradeId = null,
        Guid? studentId = null, Guid? yearId = null) => new()
    {
        StudentId = studentId ?? Student,
        SubjectId = subjectId,
        Date = date,
        Status = status,
        SchoolId = schoolId ?? School,
        GroupId = groupId ?? Group,
        GradeId = gradeId ?? Grade,
        AcademicYearId = yearId ?? Year
    };

    private static Dictionary<(Guid, Guid), (int, int)> Aggregate(
        IEnumerable<AttendanceSubjectAggregator.AttendanceDayRow> rows) =>
        AttendanceSubjectAggregator.AggregateByOfficialTrimester(
            rows, AttendanceOfficialCalendarTests.Official2026(),
            Civica, School, Group, Grade, Year);

    private static (int A1, int A2, int A3, int Total) Absences(Dictionary<(Guid, Guid), (int, int)> result)
    {
        var official = AttendanceOfficialCalendarTests.Official2026();
        result.TryGetValue((Student, official[0].Id), out var t1);
        result.TryGetValue((Student, official[1].Id), out var t2);
        result.TryGetValue((Student, official[2].Id), out var t3);
        return (t1.Item1, t2.Item1, t3.Item1, t1.Item1 + t2.Item1 + t3.Item1);
    }

    [Fact]
    public void OtherSubjectAbsence_DoesNotAppearInCivica()
    {
        var rows = new[]
        {
            Row(Religion, new DateOnly(2026, 4, 10)),
            Row(Religion, new DateOnly(2026, 5, 8)),
            Row(Civica, new DateOnly(2026, 7, 9))
        };

        var (a1, a2, a3, total) = Absences(Aggregate(rows));
        Assert.Equal(0, a1);
        Assert.Equal(1, a2);
        Assert.Equal(0, a3);
        Assert.Equal(1, total);
    }

    [Fact]
    public void DuplicateRowsSameDate_CountOnce()
    {
        var rows = new[]
        {
            Row(Civica, new DateOnly(2026, 6, 11)),
            Row(Civica, new DateOnly(2026, 6, 11)),
            Row(Civica, new DateOnly(2026, 7, 9)),
            Row(Civica, new DateOnly(2026, 7, 9))
        };

        var (a1, a2, _, total) = Absences(Aggregate(rows));
        Assert.Equal(1, a1);
        Assert.Equal(1, a2);
        Assert.Equal(2, total);
    }

    [Fact]
    public void OfficialCalendar_June11In1T_GapJune18NotCounted_July9In2T()
    {
        var rows = new[]
        {
            Row(Civica, new DateOnly(2026, 6, 11)),
            Row(Civica, new DateOnly(2026, 6, 18)),
            Row(Civica, new DateOnly(2026, 7, 9)),
            Row(Religion, new DateOnly(2026, 4, 10)),
            Row(Religion, new DateOnly(2026, 5, 8))
        };

        var (a1, a2, a3, total) = Absences(Aggregate(rows));
        Assert.Equal(1, a1);
        Assert.Equal(1, a2);
        Assert.Equal(0, a3);
        Assert.Equal(2, total);
    }

    [Fact]
    public void OtherSchoolGroupGradeOrYear_AreExcluded()
    {
        var rows = new[]
        {
            Row(Civica, new DateOnly(2026, 7, 9), schoolId: OtherSchool),
            Row(Civica, new DateOnly(2026, 7, 9), groupId: OtherGroup),
            Row(Civica, new DateOnly(2026, 7, 9), gradeId: OtherGrade),
            Row(Civica, new DateOnly(2026, 7, 9), yearId: OtherYear)
        };

        var (_, a2, _, total) = Absences(Aggregate(rows));
        Assert.Equal(0, a2);
        Assert.Equal(0, total);
    }

    [Fact]
    public void TotalEqualsSumOfTrimesters()
    {
        var rows = new[]
        {
            Row(Civica, new DateOnly(2026, 4, 1)),
            Row(Civica, new DateOnly(2026, 7, 9)),
            Row(Civica, new DateOnly(2026, 10, 5), "late")
        };

        var result = Aggregate(rows);
        var totals = FormatoCarpetasAttendanceCalculator.FromBulk(new ReportesGrupoBulkData
        {
            Attendance = result,
            TrimesterEntities = AttendanceOfficialCalendarTests.Official2026()
        }, Student);

        Assert.Equal(1, totals.AusenciasT1);
        Assert.Equal(1, totals.AusenciasT2);
        Assert.Equal(0, totals.AusenciasT3);
        Assert.Equal(1, totals.TardanzasT3);
        Assert.Equal(totals.AusenciasT1 + totals.AusenciasT2 + totals.AusenciasT3, totals.TotalAusencias);
        Assert.Equal(totals.TardanzasT1 + totals.TardanzasT2 + totals.TardanzasT3, totals.TotalTardanzas);
    }

    [Fact]
    public void PreviewPdfExcel_ShareTheSameCentralizedTotals()
    {
        var rows = new[]
        {
            Row(Civica, new DateOnly(2026, 6, 11)),
            Row(Civica, new DateOnly(2026, 7, 9))
        };
        var bulk = new ReportesGrupoBulkData
        {
            Attendance = Aggregate(rows),
            TrimesterEntities = AttendanceOfficialCalendarTests.Official2026()
        };

        var preview = FormatoCarpetasAttendanceCalculator.FromBulk(bulk, Student);
        var pdf = FormatoCarpetasAttendanceCalculator.FromBulk(bulk, Student);
        var excel = FormatoCarpetasAttendanceCalculator.FromBulk(bulk, Student);

        Assert.Equal(preview, pdf);
        Assert.Equal(preview, excel);
        Assert.Equal(1, preview.AusenciasT1);
        Assert.Equal(1, preview.AusenciasT2);
        Assert.Equal(2, preview.TotalAusencias);
    }
}
