namespace SchoolManager.Dtos;

public class GradebookPdfDto
{
    public string SchoolName { get; set; } = "";
    public string? LogoUrl { get; set; }
    public string TeacherName { get; set; } = "";
    public string SubjectName { get; set; } = "";
    public string GroupLabel { get; set; } = "";
    public string GradeLevelName { get; set; } = "";
    public string GroupName { get; set; } = "";
    public string Trimester { get; set; } = "";
    public string AcademicYear { get; set; } = "";
    public DateTime GeneratedAt { get; set; }

    /// <summary>
    /// Fecha/hora de generación en la zona de presentación de la aplicación (no UTC crudo).
    /// </summary>
    public string GeneratedAtDisplay { get; set; } = "";

    public List<GradebookPdfTypeSectionDto> TypeSections { get; set; } = new();
    public List<GradebookPdfStudentRowDto> Students { get; set; } = new();
}

public class GradebookPdfTypeSectionDto
{
    public string TypeKey { get; set; } = "";
    public string TypeLabel { get; set; } = "";
    public string ShortLabel { get; set; } = "";
    public List<GradebookPdfActivityColDto> Activities { get; set; } = new();
}

public class GradebookPdfActivityColDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = "";
    public string? DueDateDisplay { get; set; }

    /// <summary>
    /// Ids con el mismo tipo+nombre (el primero es <see cref="Id"/>).
    /// Permite resolver la nota como en la vista cuando hay duplicados.
    /// </summary>
    public List<Guid> AliasIds { get; set; } = new();
}

public class GradebookPdfStudentRowDto
{
    public int Number { get; set; }
    public string Name { get; set; } = "";
    public string DocumentId { get; set; } = "";
    public Dictionary<Guid, decimal?> ScoresByActivityId { get; set; } = new();
    public Dictionary<string, decimal> TypeAverages { get; set; } = new();
    public decimal FinalGrade { get; set; }
}
