using SchoolManager.Dtos;

namespace SchoolManager.Services.Interfaces;

public interface IStudentIdCardService
{
    Task<StudentIdCardDto> GenerateAsync(Guid studentId, Guid createdBy);
    Task<ScanResultDto> ScanAsync(ScanRequestDto request);
}
