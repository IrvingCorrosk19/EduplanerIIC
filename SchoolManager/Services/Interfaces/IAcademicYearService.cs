using SchoolManager.Models;

namespace SchoolManager.Services.Interfaces;

public interface IAcademicYearService
{
    Task<AcademicYear?> GetActiveAcademicYearAsync(Guid? schoolId = null);
    Task<AcademicYear?> GetAcademicYearByIdAsync(Guid id);
    Task<List<AcademicYear>> GetAllBySchoolAsync(Guid schoolId);
    Task<AcademicYear> CreateAsync(AcademicYear academicYear);
    Task<AcademicYear> UpdateAsync(AcademicYear academicYear);
}

