namespace SchoolManager.Dtos;

public class ScanResultDto
{
    public bool Allowed { get; set; }
    public string Message { get; set; } = null!;
    public string StudentName { get; set; } = null!;
    public string Grade { get; set; } = null!;
    public string Group { get; set; } = null!;
    /// <summary>ID del estudiante cuando Allowed es true. Necesario para el módulo de disciplina.</summary>
    public Guid? StudentId { get; set; }
    /// <summary>Cantidad de reportes disciplinarios del estudiante. Solo tiene sentido cuando Allowed es true.</summary>
    public int DisciplineCount { get; set; }
    /// <summary>URL de la foto del estudiante (relativa o absoluta). Para tarjeta digital.</summary>
    public string? StudentPhotoUrl { get; set; }
    /// <summary>Nombre de la institución. Para tarjeta digital.</summary>
    public string? SchoolName { get; set; }
    /// <summary>Código o documento del estudiante. Para tarjeta digital.</summary>
    public string? StudentCode { get; set; }
}
