namespace SchoolManager.Services.Helpers;

/// <summary>
/// Asocia asistencia histórica a una materia solo cuando la asignación es inequívoca.
/// </summary>
public static class AttendanceHistoricalSubjectResolver
{
    public sealed record TeacherGroupGradeSubject(
        Guid TeacherId,
        Guid GroupId,
        Guid GradeId,
        Guid SubjectId);

    public static Guid? ResolveUnambiguousSubject(
        Guid teacherId,
        Guid groupId,
        Guid gradeId,
        IEnumerable<TeacherGroupGradeSubject> assignments)
    {
        var subjects = assignments
            .Where(a =>
                a.TeacherId == teacherId
                && a.GroupId == groupId
                && a.GradeId == gradeId)
            .Select(a => a.SubjectId)
            .Distinct()
            .ToList();

        return subjects.Count == 1 ? subjects[0] : null;
    }
}
