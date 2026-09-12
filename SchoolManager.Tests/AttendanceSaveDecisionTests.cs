using SchoolManager.Models;
using SchoolManager.Services.Helpers;

namespace SchoolManager.Tests;

public class AttendanceSaveDecisionTests
{
    private static readonly Guid Student = Guid.NewGuid();
    private static readonly Guid Subject = Guid.NewGuid();
    private static readonly Guid OtherSubject = Guid.NewGuid();
    private static readonly Guid Group = Guid.NewGuid();
    private static readonly Guid Grade = Guid.NewGuid();
    private static readonly DateOnly Date = new(2026, 7, 9);

    private static Attendance Row(Guid? subjectId = null, string status = "absent", DateTime? updatedAt = null) => new()
    {
        Id = Guid.NewGuid(),
        StudentId = Student,
        SubjectId = subjectId ?? Subject,
        GroupId = Group,
        GradeId = Grade,
        Date = Date,
        Status = status,
        CreatedAt = DateTime.UtcNow.AddHours(-2),
        UpdatedAt = updatedAt
    };

    [Fact]
    public void SecondSaveSameIdentity_DoesNotInsert()
    {
        var first = Row();
        var existing = AttendanceSaveDecision.SelectExisting(
            [first], Student, Subject, Group, Grade, Date);

        Assert.False(AttendanceSaveDecision.ShouldInsert(existing));
        Assert.Single(existing);
        Assert.Equal(first.Id, existing[0].Id);
    }

    [Fact]
    public void ChangingAbsentToPresent_UpdatesCanonicalRecord()
    {
        var first = Row(status: "absent");
        var existing = AttendanceSaveDecision.SelectExisting(
            [first], Student, Subject, Group, Grade, Date);
        Assert.False(AttendanceSaveDecision.ShouldInsert(existing));

        existing[0].Status = "present";
        Assert.Equal("present", first.Status);
        Assert.Single(AttendanceSaveDecision.SelectExisting(
            [first], Student, Subject, Group, Grade, Date));
    }

    [Fact]
    public void OtherSubject_IsADifferentRecord()
    {
        var civica = Row(Subject);
        var religion = Row(OtherSubject);
        var forCivica = AttendanceSaveDecision.SelectExisting(
            [civica, religion], Student, Subject, Group, Grade, Date);

        Assert.Single(forCivica);
        Assert.Equal(civica.Id, forCivica[0].Id);
        Assert.True(AttendanceSaveDecision.ShouldInsert(
            AttendanceSaveDecision.SelectExisting([], Student, Subject, Group, Grade, Date)));
    }

    [Fact]
    public void HistoricalSubjectResolver_AssignsOnlyWhenUnique()
    {
        var teacher = Guid.NewGuid();
        var assignments = new[]
        {
            new AttendanceHistoricalSubjectResolver.TeacherGroupGradeSubject(teacher, Group, Grade, Subject),
            new AttendanceHistoricalSubjectResolver.TeacherGroupGradeSubject(teacher, Group, Grade, OtherSubject)
        };

        Assert.Null(AttendanceHistoricalSubjectResolver.ResolveUnambiguousSubject(
            teacher, Group, Grade, assignments));
        Assert.Equal(Subject, AttendanceHistoricalSubjectResolver.ResolveUnambiguousSubject(
            teacher, Group, Grade, assignments.Take(1)));
    }
}
