using SchoolManager.Dtos;

namespace SchoolManager.Services.Interfaces;

/// <summary>
/// Fuente canónica de solo lectura del registro de calificaciones
/// (vista / PDF / Excel). No escribe en base de datos.
/// </summary>
public interface ITeacherGradebookRegistroService
{
    Task<GradebookPdfDto> GetRegistroAsync(
        Guid teacherId,
        Guid groupId,
        string trimester,
        Guid subjectId,
        Guid gradeLevelId);
}
