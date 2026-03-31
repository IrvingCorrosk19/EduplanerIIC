namespace SchoolManager.Services.Interfaces;

public interface IStudentIdCardHtmlCaptureService
{
    Task<byte[]> GenerateFromUrl(string url);
}
