using Microsoft.EntityFrameworkCore;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;

namespace SchoolManager.Services.Implementations;

public class AcademicYearService : IAcademicYearService
{
    private readonly SchoolDbContext _context;
    private readonly ICurrentUserService _currentUserService;

    public AcademicYearService(SchoolDbContext context, ICurrentUserService currentUserService)
    {
        _context = context;
        _currentUserService = currentUserService;
    }

    public async Task<AcademicYear?> GetActiveAcademicYearAsync(Guid? schoolId = null)
    {
        Guid targetSchoolId;

        if (schoolId.HasValue)
        {
            targetSchoolId = schoolId.Value;
        }
        else
        {
            var currentUserSchool = await _currentUserService.GetCurrentUserSchoolAsync();
            if (currentUserSchool == null)
                return null;
            
            targetSchoolId = currentUserSchool.Id;
        }

        var now = DateTime.UtcNow;
        return await _context.AcademicYears
            .Where(ay => ay.SchoolId == targetSchoolId
                && ay.IsActive
                && ay.StartDate <= now
                && ay.EndDate >= now)
            .OrderByDescending(ay => ay.CreatedAt)
            .FirstOrDefaultAsync();
    }

    public async Task<AcademicYear?> GetAcademicYearByIdAsync(Guid id)
    {
        return await _context.AcademicYears
            .Include(ay => ay.School)
            .FirstOrDefaultAsync(ay => ay.Id == id);
    }

    public async Task<List<AcademicYear>> GetAllBySchoolAsync(Guid schoolId)
    {
        return await _context.AcademicYears
            .Where(ay => ay.SchoolId == schoolId)
            .OrderByDescending(ay => ay.StartDate)
            .ToListAsync();
    }

    public async Task<AcademicYear> CreateAsync(AcademicYear academicYear)
    {
        academicYear.Id = Guid.NewGuid();
        academicYear.CreatedAt = DateTime.UtcNow;

        _context.AcademicYears.Add(academicYear);
        await _context.SaveChangesAsync();

        return academicYear;
    }

    public async Task<AcademicYear> UpdateAsync(AcademicYear academicYear)
    {
        academicYear.UpdatedAt = DateTime.UtcNow;

        _context.AcademicYears.Update(academicYear);
        await _context.SaveChangesAsync();

        return academicYear;
    }
}

