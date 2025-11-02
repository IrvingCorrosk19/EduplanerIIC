using SchoolManager.Dtos;

namespace SchoolManager.Services.Interfaces
{
    public interface IEmailService
    {
        Task<bool> SendDisciplineReportEmailAsync(Guid studentId, Guid disciplineReportId, string customMessage = "");
        Task<bool> SendOrientationReportEmailAsync(Guid studentId, Guid orientationReportId, string customMessage = "");
        Task<bool> SendMatriculationConfirmationEmailAsync(Guid prematriculationId);
        Task<bool> SendEmailWithAttachmentsAsync(string toEmail, string subject, string body, List<string> attachmentPaths, EmailConfigurationDto emailConfig);
    }
}
