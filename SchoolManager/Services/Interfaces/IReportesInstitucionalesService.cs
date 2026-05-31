using SchoolManager.ViewModels;

namespace SchoolManager.Services.Interfaces;

public interface IReportesInstitucionalesService
{
    Task<byte[]> ExportarHabitosActitudesExcelAsync(
        Guid schoolId,
        string trimestre,
        string nivelEducativo,
        Guid groupId,
        Guid gradeLevelId,
        Guid? teacherScopeId,
        string profesorNombre);

    Task<byte[]> ExportarCalificacionesInformeExcelAsync(
        InformeCalificacionesTipo tipo,
        Guid schoolId,
        string nivelEducativo,
        Guid groupId,
        Guid gradeLevelId,
        Guid? teacherScopeId,
        string consejeroNombre);

    Task<byte[]> ExportarFormatoCarpetasExcelAsync(
        Guid schoolId,
        string nivelEducativo,
        Guid materiaId,
        Guid groupId,
        Guid gradeLevelId,
        Guid? teacherScopeId,
        string consejeroNombre,
        string profesorNombre);

    Task<List<InformeEstudianteFilaDto>> ObtenerEstudiantesGrupoAsync(
        Guid groupId, Guid gradeLevelId, Guid? teacherScopeId, Guid? materiaId = null);
}
