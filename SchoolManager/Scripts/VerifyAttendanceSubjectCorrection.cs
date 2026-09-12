using Microsoft.EntityFrameworkCore;
using SchoolManager.Models;
using SchoolManager.Services.Helpers;

namespace SchoolManager.Scripts;

public static class VerifyAttendanceSubjectCorrection
{
    public static async Task RunAsync(SchoolDbContext context)
    {
        var schoolId = Guid.Parse("6e42399f-6f17-4585-b92e-fa4fff02cb65");
        var subjectId = Guid.Parse("6592de4d-b8de-4478-b4dd-ca50cb6eede8");
        var groupId = Guid.Parse("4a5980a9-3852-4a5c-96af-8bc627042318");
        var gradeId = Guid.Parse("9811c9ae-8e25-441c-b7f6-41e2e7cabdef");
        var studentId = Guid.Parse("9b69aeb2-f238-47bc-b650-69accb740d49");

        var subjectName = await context.Subjects.AsNoTracking()
            .Where(s => s.Id == subjectId)
            .Select(s => s.Name)
            .FirstOrDefaultAsync();

        var studentName = await context.Users.AsNoTracking()
            .Where(u => u.Id == studentId)
            .Select(u => u.LastName + ", " + u.Name)
            .FirstOrDefaultAsync();

        var year = await context.AcademicYears.AsNoTracking()
            .Where(y => y.SchoolId == schoolId && y.IsActive)
            .OrderByDescending(y => y.StartDate)
            .FirstOrDefaultAsync();

        var trimesters = await context.Trimesters.AsNoTracking()
            .Where(t => t.SchoolId == schoolId)
            .ToListAsync();
        var official = AttendanceOfficialCalendar.OfficialForSchoolYear(
            trimesters, schoolId, year?.Id).ToList();

        var rows = await context.Attendances.AsNoTracking()
            .Where(a =>
                a.StudentId == studentId
                && a.GroupId == groupId
                && a.GradeId == gradeId
                && (a.SchoolId == null || a.SchoolId == schoolId))
            .Select(a => new AttendanceSubjectAggregator.AttendanceDayRow
            {
                StudentId = a.StudentId!.Value,
                SchoolId = a.SchoolId,
                GroupId = a.GroupId,
                GradeId = a.GradeId,
                SubjectId = a.SubjectId,
                AcademicYearId = a.AcademicYearId,
                Date = a.Date,
                Status = a.Status
            })
            .ToListAsync();

        var civica = AttendanceSubjectAggregator.AggregateByOfficialTrimester(
            rows, official, subjectId, schoolId, groupId, gradeId, year?.Id);
        var totals = FormatoCarpetasAttendanceCalculator.FromBulk(new ReportesGrupoBulkData
        {
            Attendance = civica,
            TrimesterEntities = official
        }, studentId);

        var civicaDates = rows
            .Where(r => r.SubjectId == subjectId && r.Status.Equals("absent", StringComparison.OrdinalIgnoreCase))
            .Select(r => r.Date)
            .Distinct()
            .OrderBy(d => d)
            .ToList();

        var otherSubjectAbsences = await context.Attendances.AsNoTracking()
            .Where(a =>
                a.StudentId == studentId
                && a.GroupId == groupId
                && a.GradeId == gradeId
                && a.Status != null
                && a.Status.ToLower() == "absent"
                && a.SubjectId != null
                && a.SubjectId != subjectId)
            .Join(context.Subjects.AsNoTracking(), a => a.SubjectId, s => s.Id, (a, s) => s.Name)
            .Distinct()
            .ToListAsync();

        var unresolved = 0;
        var duplicateGroups = 0;
        try
        {
            unresolved = await context.Database
                .SqlQueryRaw<int>("SELECT COUNT(*)::int AS \"Value\" FROM attendance_unresolved_subject_inventory_20260912")
                .SingleAsync();
            duplicateGroups = await context.Database
                .SqlQueryRaw<int>("SELECT COUNT(*)::int AS \"Value\" FROM attendance_duplicate_identity_inventory_20260912")
                .SingleAsync();
        }
        catch (Exception ex)
        {
            Console.WriteLine("Inventario histórico no disponible aún: " + ex.Message);
        }

        var withSubject = await context.Attendances.CountAsync(a => a.SubjectId != null);
        var withoutSubject = await context.Attendances.CountAsync(a => a.SubjectId == null);

        var ambiguousTeachers = await context.Database.SqlQueryRaw<int>("""
            SELECT COUNT(*)::int AS "Value"
            FROM (
                SELECT ta.teacher_id, sa.group_id, sa.grade_level_id
                FROM teacher_assignments ta
                INNER JOIN subject_assignments sa ON sa.id = ta.subject_assignment_id
                GROUP BY ta.teacher_id, sa.group_id, sa.grade_level_id
                HAVING COUNT(DISTINCT sa.subject_id) > 1
            ) x
            """).SingleAsync();

        var unresolvedNoTeacher = await context.Attendances.CountAsync(a =>
            a.SubjectId == null && a.TeacherId == null);

        Console.WriteLine("VERIFY_STUDENT=" + studentName);
        Console.WriteLine("VERIFY_SUBJECT=" + subjectName);
        Console.WriteLine($"VERIFY_CIVICA_DATES={string.Join(",", civicaDates.Select(d => d.ToString("yyyy-MM-dd")))}");
        Console.WriteLine($"VERIFY_A1={totals.AusenciasT1}");
        Console.WriteLine($"VERIFY_A2={totals.AusenciasT2}");
        Console.WriteLine($"VERIFY_A3={totals.AusenciasT3}");
        Console.WriteLine($"VERIFY_TOTAL={totals.TotalAusencias}");
        Console.WriteLine($"VERIFY_TOTAL_EQ_SUM={totals.TotalAusencias == totals.AusenciasT1 + totals.AusenciasT2 + totals.AusenciasT3}");
        Console.WriteLine("VERIFY_OTHER_SUBJECTS=" + string.Join("|", otherSubjectAbsences));
        Console.WriteLine($"VERIFY_ROWS_WITH_SUBJECT={withSubject}");
        Console.WriteLine($"VERIFY_ROWS_WITHOUT_SUBJECT={withoutSubject}");
        Console.WriteLine($"VERIFY_UNRESOLVED={unresolved}");
        Console.WriteLine($"VERIFY_DUP_GROUPS={duplicateGroups}");
        Console.WriteLine($"VERIFY_AMBIGUOUS_TEACHER_SCOPES={ambiguousTeachers}");
        Console.WriteLine($"VERIFY_UNRESOLVED_NO_TEACHER={unresolvedNoTeacher}");

        var unresolvedWithAmbiguousTeacher = await context.Database.SqlQueryRaw<int>("""
            SELECT COUNT(*)::int AS "Value"
            FROM attendance a
            INNER JOIN (
                SELECT ta.teacher_id, sa.group_id, sa.grade_level_id
                FROM teacher_assignments ta
                INNER JOIN subject_assignments sa ON sa.id = ta.subject_assignment_id
                GROUP BY ta.teacher_id, sa.group_id, sa.grade_level_id
                HAVING COUNT(DISTINCT sa.subject_id) > 1
            ) u ON a.teacher_id = u.teacher_id
               AND a.group_id = u.group_id
               AND a.grade_id = u.grade_level_id
            WHERE a.subject_id IS NULL
            """).SingleAsync();
        Console.WriteLine($"VERIFY_UNRESOLVED_AMBIGUOUS={unresolvedWithAmbiguousTeacher}");
        Console.WriteLine($"VERIFY_UNRESOLVED_NO_ASSIGNMENT={withoutSubject - unresolvedWithAmbiguousTeacher}");
    }
}
