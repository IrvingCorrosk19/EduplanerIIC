using SchoolManager.Services.Helpers;
using SchoolManager.Services.Interfaces;

namespace SchoolManager.Services.Implementations;

public class TeacherGradebookExcelService : ITeacherGradebookExcelService
{
    private readonly ITeacherGradebookRegistroService _registro;

    public TeacherGradebookExcelService(ITeacherGradebookRegistroService registro)
    {
        _registro = registro;
    }

    public async Task<(byte[] Content, string FileName)> GenerateRegistroExcelAsync(
        Guid teacherId,
        Guid groupId,
        string trimester,
        Guid subjectId,
        Guid gradeLevelId)
    {
        var model = await _registro.GetRegistroAsync(teacherId, groupId, trimester, subjectId, gradeLevelId);
        var content = GradebookExcelRenderer.Generate(model);
        var fileName = GradebookExportFileName.BuildXlsx(model.Trimester, model.GroupLabel, model.SubjectName);
        return (content, fileName);
    }
}
