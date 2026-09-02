using SchoolManager.Dtos;
using SchoolManager.Models;
using SchoolManager.Services.Helpers;

namespace SchoolManager.Tests;

public class GradebookActivityScopeTests
{
    private static readonly Guid SchoolA = Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa");
    private static readonly Guid SchoolB = Guid.Parse("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb");
    private static readonly Guid TrimCurrent = Guid.Parse("11111111-1111-1111-1111-111111111111");
    private static readonly Guid TrimPrevious = Guid.Parse("22222222-2222-2222-2222-222222222222");
    private static readonly Guid Teacher = Guid.Parse("33333333-3333-3333-3333-333333333333");
    private static readonly Guid Group = Guid.Parse("44444444-4444-4444-4444-444444444444");
    private static readonly Guid Subject = Guid.Parse("55555555-5555-5555-5555-555555555555");
    private static readonly Guid Grade = Guid.Parse("66666666-6666-6666-6666-666666666666");

    [Fact]
    public void Query_ExcludesOtherSchool_OtherTrimesterId_Historical1T_AndNullTrimesterId()
    {
        var visible = new Activity
        {
            Id = Guid.NewGuid(),
            Name = "Visible",
            Type = "Ejercicios diarios",
            TeacherId = Teacher,
            GroupId = Group,
            SubjectId = Subject,
            GradeLevelId = Grade,
            SchoolId = SchoolA,
            TrimesterId = TrimCurrent,
            Trimester = "1T"
        };

        var otherSchool = Clone(visible, a =>
        {
            a.Id = Guid.NewGuid();
            a.Name = "Otro colegio";
            a.SchoolId = SchoolB;
        });

        var otherTrimesterId = Clone(visible, a =>
        {
            a.Id = Guid.NewGuid();
            a.Name = "Otro trimestre id";
            a.TrimesterId = TrimPrevious;
            a.Trimester = "1T";
        });

        var historicalSameText = Clone(visible, a =>
        {
            a.Id = Guid.NewGuid();
            a.Name = "Historico 1T";
            a.TrimesterId = TrimPrevious;
            a.Trimester = "1T";
        });

        var nullTrimester = Clone(visible, a =>
        {
            a.Id = Guid.NewGuid();
            a.Name = "Sin TrimesterId";
            a.TrimesterId = null;
            a.Trimester = "1T";
        });

        var result = new[] { visible, otherSchool, otherTrimesterId, historicalSameText, nullTrimester }
            .AsQueryable()
            .VisibleOnTeacherGradebookIndex(Teacher, Group, Subject, Grade, SchoolA, TrimCurrent, "1T")
            .ToList();

        Assert.Single(result);
        Assert.Equal("Visible", result[0].Name);
    }

    [Theory]
    [InlineData("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", "11111111-1111-1111-1111-111111111111", "1T", true)]
    [InlineData("bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb", "11111111-1111-1111-1111-111111111111", "1T", false)]
    [InlineData("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", "22222222-2222-2222-2222-222222222222", "1T", false)]
    [InlineData("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", null, "1T", false)]
    public void MatchesTenantAndTrimester_RequiresSchoolAndTrimesterId(
        string school,
        string? trimesterId,
        string code,
        bool expected)
    {
        Guid? trim = trimesterId == null ? null : Guid.Parse(trimesterId);
        var ok = GradebookActivityScope.MatchesTenantAndTrimester(
            Guid.Parse(school),
            trim,
            code,
            SchoolA,
            TrimCurrent,
            "1T");
        Assert.Equal(expected, ok);
    }

    private static Activity Clone(Activity source, Action<Activity> mutate)
    {
        var copy = new Activity
        {
            Id = source.Id,
            Name = source.Name,
            Type = source.Type,
            TeacherId = source.TeacherId,
            GroupId = source.GroupId,
            SubjectId = source.SubjectId,
            GradeLevelId = source.GradeLevelId,
            SchoolId = source.SchoolId,
            TrimesterId = source.TrimesterId,
            Trimester = source.Trimester
        };
        mutate(copy);
        return copy;
    }
}
