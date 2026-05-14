using SchoolManager.Dtos;

namespace SchoolManager.Services.Interfaces;
public interface IInstitutionalCredentialService
{
    Task<InstitutionalCredentialCardDto?> GetCurrentCardAsync(Guid userId);

    Task<InstitutionalCredentialCardDto> GenerateAsync(Guid userId, Guid createdBy);
}
