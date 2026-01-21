namespace SchoolManager.Dtos;

public class ScanResultDto
{
    public bool Allowed { get; set; }
    public string Message { get; set; } = null!;
    public string StudentName { get; set; } = null!;
    public string Grade { get; set; } = null!;
    public string Group { get; set; } = null!;
}
