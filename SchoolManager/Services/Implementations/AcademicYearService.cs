using Microsoft.EntityFrameworkCore;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using Npgsql;

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
        try
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
        catch (Npgsql.PostgresException ex) when (ex.SqlState == "42P01") // Table does not exist
        {
            // La tabla academic_years aún no existe, retornar null (compatibilidad hacia atrás)
            return null;
        }
        catch (Microsoft.EntityFrameworkCore.DbUpdateException ex) when (ex.InnerException is Npgsql.PostgresException pgEx && pgEx.SqlState == "42P01")
        {
            // La tabla academic_years aún no existe, retornar null (compatibilidad hacia atrás)
            return null;
        }
    }

    public async Task<AcademicYear?> GetAcademicYearByIdAsync(Guid id)
    {
        try
        {
            return await _context.AcademicYears
                .Include(ay => ay.School)
                .FirstOrDefaultAsync(ay => ay.Id == id);
        }
        catch (PostgresException ex) when (ex.SqlState == "42P01")
        {
            return null;
        }
        catch (Microsoft.EntityFrameworkCore.DbUpdateException ex) when (ex.InnerException is PostgresException pgEx && pgEx.SqlState == "42P01")
        {
            return null;
        }
    }

    public async Task<List<AcademicYear>> GetAllBySchoolAsync(Guid schoolId)
    {
        try
        {
            return await _context.AcademicYears
                .Where(ay => ay.SchoolId == schoolId)
                .OrderByDescending(ay => ay.StartDate)
                .ToListAsync();
        }
        catch (PostgresException ex) when (ex.SqlState == "42P01")
        {
            return new List<AcademicYear>();
        }
        catch (Microsoft.EntityFrameworkCore.DbUpdateException ex) when (ex.InnerException is PostgresException pgEx && pgEx.SqlState == "42P01")
        {
            return new List<AcademicYear>();
        }
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

