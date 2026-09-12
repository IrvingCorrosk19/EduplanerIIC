using Microsoft.EntityFrameworkCore;
using SchoolManager.Dtos;
using SchoolManager.Models;
using SchoolManager.Services.Implementations;
using SchoolManager.Services.Interfaces;

namespace SchoolManager.Tests;

public class AttendanceServiceUpsertTests
{
    private static readonly Guid SchoolId = Guid.Parse("6e42399f-6f17-4585-b92e-fa4fff02cb65");
    private static readonly Guid StudentId = Guid.NewGuid();
    private static readonly Guid TeacherId = Guid.NewGuid();
    private static readonly Guid SubjectId = Guid.NewGuid();
    private static readonly Guid GroupId = Guid.NewGuid();
    private static readonly Guid GradeId = Guid.NewGuid();
    private static readonly Guid YearId = Guid.NewGuid();
    private static readonly Guid T1Id = Guid.NewGuid();
    private static readonly DateOnly Date = new(2026, 6, 11);

    private static SchoolDbContext CreateContext()
    {
        var options = new DbContextOptionsBuilder<SchoolDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        var ctx = new SchoolDbContext(options);
        ctx.AcademicYears.Add(new AcademicYear
        {
            Id = YearId,
            SchoolId = SchoolId,
            Name = "2026",
            IsActive = true,
            StartDate = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
            EndDate = new DateTime(2026, 12, 31, 0, 0, 0, DateTimeKind.Utc),
            CreatedAt = DateTime.UtcNow
        });
        ctx.Trimesters.Add(new Trimester
        {
            Id = T1Id,
            SchoolId = SchoolId,
            AcademicYearId = YearId,
            Name = "1T",
            Order = 1,
            StartDate = new DateTime(2026, 3, 1, 0, 0, 0, DateTimeKind.Utc),
            EndDate = new DateTime(2026, 6, 12, 0, 0, 0, DateTimeKind.Utc),
            CreatedAt = DateTime.UtcNow
        });
        ctx.SaveChanges();
        return ctx;
    }

    private static AttendanceService CreateService(SchoolDbContext ctx) =>
        new(ctx, new StubCurrentUser());

    private static AttendanceSaveDto Dto(string status) => new()
    {
        StudentId = StudentId,
        TeacherId = TeacherId,
        SubjectId = SubjectId,
        GroupId = GroupId,
        GradeId = GradeId,
        Date = Date,
        Status = status
    };

    [Fact]
    public async Task TwoSavesSameAttendance_DoNotCreateDuplicates()
    {
        await using var ctx = CreateContext();
        var service = CreateService(ctx);

        await service.SaveAttendancesAsync([Dto("absent")]);
        await service.SaveAttendancesAsync([Dto("absent")]);

        var rows = ctx.Attendances.Where(a =>
            a.StudentId == StudentId && a.SubjectId == SubjectId && a.Date == Date).ToList();
        Assert.Single(rows);
        Assert.Equal("absent", rows[0].Status);
        Assert.Equal(T1Id, rows[0].TrimesterId);
    }

    [Fact]
    public async Task ChangingAbsentToPresent_UpdatesExistingRow()
    {
        await using var ctx = CreateContext();
        var service = CreateService(ctx);

        await service.SaveAttendancesAsync([Dto("absent")]);
        var id = ctx.Attendances.Single().Id;

        await service.SaveAttendancesAsync([Dto("present")]);

        var rows = ctx.Attendances.ToList();
        Assert.Single(rows);
        Assert.Equal(id, rows[0].Id);
        Assert.Equal("present", rows[0].Status);
    }

    [Fact]
    public async Task June11_IsAssignedToOfficialFirstTrimester()
    {
        await using var ctx = CreateContext();
        var service = CreateService(ctx);
        await service.SaveAttendancesAsync([Dto("absent")]);
        Assert.Equal(T1Id, ctx.Attendances.Single().TrimesterId);
    }

    private sealed class StubCurrentUser : ICurrentUserService
    {
        private readonly User _user = new()
        {
            Id = Guid.NewGuid(),
            SchoolId = SchoolId,
            Name = "Test",
            LastName = "User"
        };

        public Task<Guid?> GetCurrentUserIdAsync() => Task.FromResult<Guid?>(_user.Id);
        public Task<User?> GetCurrentUserAsync() => Task.FromResult<User?>(_user);
        public Task<bool> IsAuthenticatedAsync() => Task.FromResult(true);
        public Task<string?> GetCurrentUserRoleAsync() => Task.FromResult<string?>("teacher");
        public Task<School?> GetCurrentUserSchoolAsync() =>
            Task.FromResult<School?>(new School { Id = SchoolId, Name = "Test" });
    }
}
