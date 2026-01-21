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
}
