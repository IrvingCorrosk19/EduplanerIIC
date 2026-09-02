using SchoolManager.Services.Interfaces;

namespace SchoolManager.Services.Implementations;

public class TeacherGradebookPdfService : ITeacherGradebookPdfService
{
    private readonly ITeacherGradebookRegistroService _registro;
    private readonly ISuperAdminService _superAdminService;

    public TeacherGradebookPdfService(
        ITeacherGradebookRegistroService registro,
        ISuperAdminService superAdminService)
    {
        _registro = registro;
        _superAdminService = superAdminService;
    }

    public async Task<byte[]> GenerateRegistroPdfAsync(
        Guid teacherId,
        Guid groupId,
        string trimester,
        Guid subjectId,
        Guid gradeLevelId,
        byte[]? logoBytes = null)
    {
        var model = await _registro.GetRegistroAsync(teacherId, groupId, trimester, subjectId, gradeLevelId);

        if (logoBytes == null &&
            !string.IsNullOrWhiteSpace(model.LogoUrl) &&
            !model.LogoUrl.StartsWith("http://", StringComparison.OrdinalIgnoreCase) &&
            !model.LogoUrl.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
        {
            try
            {
                logoBytes = await _superAdminService.GetLogoAsync(model.LogoUrl);
            }
            catch
            {
                logoBytes = null;
            }
        }

        return GradebookPdfRenderer.Generate(model, logoBytes);
    }
}
