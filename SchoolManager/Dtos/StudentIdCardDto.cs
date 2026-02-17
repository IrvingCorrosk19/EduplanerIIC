namespace SchoolManager.Dtos;

public class StudentIdCardDto
{
    public Guid StudentId { get; set; }
    public string CardNumber { get; set; } = null!;
    public string FullName { get; set; } = null!;
    public string Grade { get; set; } = null!;
    public string Group { get; set; } = null!;
    public string Shift { get; set; } = null!;
    public string QrToken { get; set; } = null!;
    /// <summary>URL o path de la foto del estudiante (para vista y PDF).</summary>
    public string? PhotoUrl { get; set; }
}
