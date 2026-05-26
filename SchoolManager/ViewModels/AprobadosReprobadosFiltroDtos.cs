namespace SchoolManager.ViewModels;

/// <summary>
/// Grupo disponible en el filtro (misma lógica que TeacherGradebook: grade_level + nombre de grupo).
/// </summary>
public class AprobadosReprobadosGrupoFiltroDto
{
    public Guid GroupId { get; set; }
    public Guid GradeLevelId { get; set; }
    public string Nombre { get; set; } = "";
    public string? GradoGrupo { get; set; }
}

internal sealed class AprobadosReprobadosAsignacionRow
{
    public Guid SubjectId { get; init; }
    public string SubjectName { get; init; } = "";
    public Guid GroupId { get; init; }
    public string GroupName { get; init; } = "";
    public Guid GradeLevelId { get; init; }
    public string GradeLevelName { get; init; } = "";
    public string? GroupGrade { get; init; }
}
