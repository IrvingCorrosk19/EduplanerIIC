namespace SchoolManager.Dtos;

public class ScanRequestDto
{
    public string Token { get; set; } = null!;
    public Guid ScannedBy { get; set; }
    public string ScanType { get; set; } = "entry";
}
