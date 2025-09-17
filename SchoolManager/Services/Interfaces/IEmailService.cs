using SchoolManager.Dtos;

namespace SchoolManager.Services.Interfaces
{
    public interface IEmailService
    {
        Task<bool> SendDisciplineReportEmailAsync(Guid studentId, Guid disciplineReportId, string customMessage = "");
        Task<bool> SendEmailWithAttachmentsAsync(string toEmail, string subject, string body, List<string> attachmentPaths, EmailConfigurationDto emailConfig);
    }
}
