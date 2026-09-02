using SchoolManager.Models;

namespace SchoolManager.Services.Helpers;

/// <summary>
/// Predicado canónico de actividades visibles en <c>/TeacherGradebook/Index</c>
/// (<see cref="SchoolManager.Services.ActivityService.GetByTeacherGroupTrimesterAsync"/>).
/// Excluye otros colegios, otros TrimesterId, texto de trimestre huérfano y TrimesterId null.
/// </summary>
public static class GradebookActivityScope
{
    public static IQueryable<Activity> VisibleOnTeacherGradebookIndex(
        this IQueryable<Activity> activities,
        Guid teacherId,
        Guid groupId,
        Guid subjectId,
        Guid gradeLevelId,
        Guid schoolId,
        Guid trimesterId,
        string trimesterCode)
    {
        return activities.Where(a =>
            a.TeacherId == teacherId
            && a.GroupId == groupId
            && a.SubjectId == subjectId
            && a.GradeLevelId == gradeLevelId
            && a.SchoolId == schoolId
            && a.TrimesterId == trimesterId
            && a.Trimester == trimesterCode);
    }

    public static bool MatchesTenantAndTrimester(
        Guid? activitySchoolId,
        Guid? activityTrimesterId,
        string? activityTrimesterCode,
        Guid schoolId,
        Guid trimesterId,
        string trimesterCode)
    {
        if (activitySchoolId != schoolId)
            return false;
        if (activityTrimesterId != trimesterId)
            return false;
        return string.Equals(activityTrimesterCode, trimesterCode, StringComparison.Ordinal);
    }
}
