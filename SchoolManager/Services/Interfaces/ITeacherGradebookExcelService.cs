namespace SchoolManager.Services.Interfaces;

public interface ITeacherGradebookExcelService
{
    Task<(byte[] Content, string FileName)> GenerateRegistroExcelAsync(
        Guid teacherId,
        Guid groupId,
        string trimester,
        Guid subjectId,
        Guid gradeLevelId);
}
