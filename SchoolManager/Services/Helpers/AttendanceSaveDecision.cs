using SchoolManager.Models;

namespace SchoolManager.Services.Helpers;

/// <summary>
/// Identidad funcional de un registro de asistencia:
/// estudiante + materia + grupo + grado + fecha.
/// </summary>
public static class AttendanceSaveDecision
{
    public static IReadOnlyList<Attendance> SelectExisting(
        IEnumerable<Attendance> candidates,
        Guid studentId,
        Guid subjectId,
        Guid groupId,
        Guid gradeId,
        DateOnly date)
    {
        return candidates
            .Where(a =>
                a.StudentId == studentId
                && a.SubjectId == subjectId
                && a.GroupId == groupId
                && a.GradeId == gradeId
                && a.Date == date)
            .OrderByDescending(a => a.UpdatedAt ?? a.CreatedAt)
            .ToList();
    }

    public static bool ShouldInsert(IReadOnlyList<Attendance> existing) => existing.Count == 0;
}
