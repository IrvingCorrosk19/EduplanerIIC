using SchoolManager.Models;
using SchoolManager.Services.Helpers;

namespace SchoolManager.Tests;

public class AttendanceOfficialCalendarTests
{
    private static readonly Guid SchoolId = Guid.Parse("6e42399f-6f17-4585-b92e-fa4fff02cb65");
    private static readonly Guid T1 = Guid.Parse("54d2db96-495a-4db2-96e4-04415f9ae267");
    private static readonly Guid T2 = Guid.Parse("7038b0cd-1111-2222-3333-04415f9ae267");
    private static readonly Guid T3 = Guid.Parse("a4724128-1111-2222-3333-04415f9ae267");

    public static List<Trimester> Official2026() =>
    [
        new()
        {
            Id = T1, Name = "1T", SchoolId = SchoolId, Order = 1,
            StartDate = new DateTime(2026, 3, 1, 0, 0, 0, DateTimeKind.Utc),
            EndDate = new DateTime(2026, 6, 12, 0, 0, 0, DateTimeKind.Utc)
        },
        new()
        {
            Id = T2, Name = "2T", SchoolId = SchoolId, Order = 2,
            StartDate = new DateTime(2026, 6, 21, 0, 0, 0, DateTimeKind.Utc),
            EndDate = new DateTime(2026, 9, 20, 0, 0, 0, DateTimeKind.Utc)
        },
        new()
        {
            Id = T3, Name = "3T", SchoolId = SchoolId, Order = 3,
            StartDate = new DateTime(2026, 9, 22, 0, 0, 0, DateTimeKind.Utc),
            EndDate = new DateTime(2026, 12, 19, 0, 0, 0, DateTimeKind.Utc)
        }
    ];

    [Theory]
    [InlineData(2026, 6, 11, "1T")]
    [InlineData(2026, 6, 12, "1T")]
    [InlineData(2026, 6, 21, "2T")]
    [InlineData(2026, 7, 9, "2T")]
    [InlineData(2026, 9, 22, "3T")]
    public void OfficialRange_AssignsConfiguredTrimester(int y, int m, int d, string expected)
    {
        var trim = AttendanceOfficialCalendar.ResolveOfficialTrimester(new DateOnly(y, m, d), Official2026());
        Assert.NotNull(trim);
        Assert.Equal(expected, trim!.Name);
    }

    [Theory]
    [InlineData(2026, 6, 13)]
    [InlineData(2026, 6, 18)]
    [InlineData(2026, 6, 20)]
    [InlineData(2026, 9, 21)]
    public void GapBetweenOfficialRanges_IsNotAssigned(int y, int m, int d)
    {
        var trim = AttendanceOfficialCalendar.ResolveOfficialTrimester(new DateOnly(y, m, d), Official2026());
        Assert.Null(trim);
    }

    [Fact]
    public void June11_IsNotSecondTrimester_EvenIfLegacyFallbackUsedJune8()
    {
        var june11 = AttendanceOfficialCalendar.ResolveOfficialTrimester(new DateOnly(2026, 6, 11), Official2026());
        Assert.Equal("1T", june11!.Name);
        Assert.NotEqual("2T", june11.Name);
    }
}
