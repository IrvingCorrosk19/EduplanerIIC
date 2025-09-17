using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SchoolManager.Dtos;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using System.Net.Mail;
using System.Net;

namespace SchoolManager.Services.Implementations
{
    public class EmailService : IEmailService
    {
        private readonly SchoolDbContext _context;
        private readonly IEmailConfigurationService _emailConfigService;
        private readonly ILogger<EmailService> _logger;

        public EmailService(
            SchoolDbContext context, 
            IEmailConfigurationService emailConfigService,
            ILogger<EmailService> logger)
        {
            _context = context;
            _emailConfigService = emailConfigService;
            _logger = logger;
        }

        public async Task<bool> SendDisciplineReportEmailAsync(Guid studentId, Guid disciplineReportId, string customMessage = "")
        {
            try
            {
                // Obtener datos del estudiante
                var student = await _context.Users
                    .Where(u => u.Id == studentId)
                    .Select(u => new { u.Email, u.Name, u.LastName })
                    .FirstOrDefaultAsync();

                if (student == null)
                {
                    _logger.LogWarning("Estudiante no encontrado: {StudentId}", studentId);
                    return false;
                }

                if (string.IsNullOrEmpty(student.Email))
                {
                    _logger.LogWarning("Estudiante no tiene email configurado: {StudentId}", studentId);
                    return false;
                }

                // Obtener datos del reporte disciplinario
                var disciplineReport = await _context.DisciplineReports
                    .Include(dr => dr.Teacher)
                    .Include(dr => dr.Subject)
                    .Include(dr => dr.Group)
                    .Include(dr => dr.GradeLevel)
                    .FirstOrDefaultAsync(dr => dr.Id == disciplineReportId);

                if (disciplineReport == null)
                {
                    _logger.LogWarning("Reporte disciplinario no encontrado: {DisciplineReportId}", disciplineReportId);
                    return false;
                }

                // Obtener configuración de email de la escuela
                var schoolId = disciplineReport.Teacher?.SchoolId;
                if (!schoolId.HasValue)
                {
                    _logger.LogWarning("No se pudo obtener SchoolId del profesor");
                    return false;
                }

                var emailConfig = await _emailConfigService.GetActiveBySchoolIdAsync(schoolId.Value);
                if (emailConfig == null)
                {
                    _logger.LogWarning("No hay configuración de email activa para la escuela: {SchoolId}", schoolId);
                    return false;
                }

                // Preparar archivos adjuntos
                var attachmentPaths = new List<string>();
                if (!string.IsNullOrEmpty(disciplineReport.Documents))
                {
                    try
                    {
                        var documents = System.Text.Json.JsonSerializer.Deserialize<List<object>>(disciplineReport.Documents);
                        if (documents != null)
                        {
                            foreach (var doc in documents)
                            {
                                var docDict = System.Text.Json.JsonSerializer.Deserialize<Dictionary<string, object>>(doc.ToString());
                                if (docDict != null && docDict.ContainsKey("savedName"))
                                {
                                    var savedName = docDict["savedName"].ToString();
                                    var filePath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "discipline", savedName);
                                    if (File.Exists(filePath))
                                    {
                                        attachmentPaths.Add(filePath);
                                    }
                                }
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Error al procesar documentos adjuntos");
                    }
                }

                // Crear contenido del email
                var studentName = $"{student.Name} {student.LastName}";
                var teacherName = disciplineReport.Teacher != null ? 
                    $"{disciplineReport.Teacher.Name} {disciplineReport.Teacher.LastName}" : "Profesor";
                var subjectName = disciplineReport.Subject?.Name ?? "Materia";
                var groupName = disciplineReport.Group?.Name ?? "Grupo";
                var gradeName = disciplineReport.GradeLevel?.Name ?? "Grado";

                var subject = $"Reporte Disciplinario - {subjectName}";
                var body = $@"
<html>
<head>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .header {{ background-color: #f8f9fa; padding: 20px; border-radius: 5px; margin-bottom: 20px; }}
        .content {{ padding: 20px; }}
        .footer {{ background-color: #e9ecef; padding: 15px; border-radius: 5px; margin-top: 20px; font-size: 12px; }}
        .highlight {{ background-color: #fff3cd; padding: 10px; border-radius: 5px; margin: 10px 0; }}
    </style>
</head>
<body>
    <div class='header'>
        <h2>📋 Reporte Disciplinario</h2>
        <p><strong>Estudiante:</strong> {studentName}</p>
        <p><strong>Fecha:</strong> {disciplineReport.Date:dd/MM/yyyy}</p>
        <p><strong>Hora:</strong> {disciplineReport.Date:HH:mm}</p>
    </div>
    
    <div class='content'>
        <h3>Detalles del Reporte</h3>
        <p><strong>Materia:</strong> {subjectName}</p>
        <p><strong>Grado:</strong> {gradeName}</p>
        <p><strong>Grupo:</strong> {groupName}</p>
        <p><strong>Tipo:</strong> {disciplineReport.ReportType}</p>
        <p><strong>Categoría:</strong> {disciplineReport.Category ?? "No especificada"}</p>
        <p><strong>Estado:</strong> {disciplineReport.Status}</p>
        
        <div class='highlight'>
            <h4>Descripción:</h4>
            <p>{disciplineReport.Description ?? "Sin descripción"}</p>
        </div>
        
        {(attachmentPaths.Any() ? "<p><strong>📎 Documentos adjuntos:</strong> Se incluyen archivos de evidencia relacionados con este reporte.</p>" : "")}
        
        {(string.IsNullOrEmpty(customMessage) ? "" : $"<div class='highlight'><h4>Mensaje adicional del profesor:</h4><p>{customMessage}</p></div>")}
        
        <p><strong>Reportado por:</strong> {teacherName}</p>
    </div>
    
    <div class='footer'>
        <p>Este es un mensaje automático del sistema EduPlanner.</p>
        <p>Por favor, mantenga este correo para sus registros.</p>
    </div>
</body>
</html>";

                // Enviar email
                return await SendEmailWithAttachmentsAsync(student.Email, subject, body, attachmentPaths, emailConfig);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al enviar email de reporte disciplinario");
                return false;
            }
        }

        public async Task<bool> SendOrientationReportEmailAsync(Guid studentId, Guid orientationReportId, string customMessage = "")
        {
            try
            {
                // Obtener datos del estudiante
                var student = await _context.Users
                    .Where(u => u.Id == studentId)
                    .Select(u => new { u.Email, u.Name, u.LastName })
                    .FirstOrDefaultAsync();

                if (student == null)
                {
                    _logger.LogWarning("Estudiante no encontrado: {StudentId}", studentId);
                    return false;
                }

                if (string.IsNullOrEmpty(student.Email))
                {
                    _logger.LogWarning("Estudiante no tiene email configurado: {StudentId}", studentId);
                    return false;
                }

                // Obtener datos del reporte de orientación
                var orientationReport = await _context.OrientationReports
                    .Include(or => or.Teacher)
                    .Include(or => or.Subject)
                    .Include(or => or.Group)
                    .Include(or => or.GradeLevel)
                    .FirstOrDefaultAsync(or => or.Id == orientationReportId);

                if (orientationReport == null)
                {
                    _logger.LogWarning("Reporte de orientación no encontrado: {OrientationReportId}", orientationReportId);
                    return false;
                }

                // Obtener configuración de email de la escuela
                var schoolId = orientationReport.Teacher?.SchoolId;
                if (!schoolId.HasValue)
                {
                    _logger.LogWarning("No se pudo obtener SchoolId del profesor");
                    return false;
                }

                var emailConfig = await _emailConfigService.GetActiveBySchoolIdAsync(schoolId.Value);
                if (emailConfig == null)
                {
                    _logger.LogWarning("No hay configuración de email activa para la escuela: {SchoolId}", schoolId);
                    return false;
                }

                // Preparar archivos adjuntos
                var attachmentPaths = new List<string>();
                if (!string.IsNullOrEmpty(orientationReport.Documents))
                {
                    try
                    {
                        var documents = System.Text.Json.JsonSerializer.Deserialize<List<object>>(orientationReport.Documents);
                        if (documents != null)
                        {
                            foreach (var doc in documents)
                            {
                                var docDict = System.Text.Json.JsonSerializer.Deserialize<Dictionary<string, object>>(doc.ToString());
                                if (docDict != null && docDict.ContainsKey("savedName"))
                                {
                                    var savedName = docDict["savedName"].ToString();
                                    var filePath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "orientation", savedName);
                                    if (File.Exists(filePath))
                                    {
                                        attachmentPaths.Add(filePath);
                                    }
                                }
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Error al procesar documentos adjuntos");
                    }
                }

                // Crear contenido del email
                var studentName = $"{student.Name} {student.LastName}";
                var teacherName = orientationReport.Teacher != null ? 
                    $"{orientationReport.Teacher.Name} {orientationReport.Teacher.LastName}" : "Profesor";
                var subjectName = orientationReport.Subject?.Name ?? "Materia";
                var groupName = orientationReport.Group?.Name ?? "Grupo";
                var gradeName = orientationReport.GradeLevel?.Name ?? "Grado";

                var subject = $"Reporte de Orientación - {subjectName}";
                var body = $@"
<html>
<head>
    <style>
        body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
        .header {{ background-color: #f8f9fa; padding: 20px; border-radius: 5px; margin-bottom: 20px; }}
        .content {{ padding: 20px; }}
        .footer {{ background-color: #e9ecef; padding: 15px; border-radius: 5px; margin-top: 20px; font-size: 12px; }}
        .highlight {{ background-color: #fff3cd; padding: 10px; border-radius: 5px; margin: 10px 0; }}
    </style>
</head>
<body>
    <div class='header'>
        <h2>📋 Reporte de Orientación</h2>
        <p><strong>Estudiante:</strong> {studentName}</p>
        <p><strong>Fecha:</strong> {orientationReport.Date:dd/MM/yyyy}</p>
        <p><strong>Hora:</strong> {orientationReport.Date:HH:mm}</p>
    </div>
    
    <div class='content'>
        <h3>Detalles del Reporte</h3>
        <p><strong>Materia:</strong> {subjectName}</p>
        <p><strong>Grado:</strong> {gradeName}</p>
        <p><strong>Grupo:</strong> {groupName}</p>
        <p><strong>Tipo:</strong> {orientationReport.ReportType}</p>
        <p><strong>Categoría:</strong> {orientationReport.Category ?? "No especificada"}</p>
        <p><strong>Estado:</strong> {orientationReport.Status}</p>
        
        <div class='highlight'>
            <h4>Descripción:</h4>
            <p>{orientationReport.Description ?? "Sin descripción"}</p>
        </div>
        
        {(attachmentPaths.Any() ? "<p><strong>📎 Documentos adjuntos:</strong> Se incluyen archivos de evidencia relacionados con este reporte.</p>" : "")}
        
        {(string.IsNullOrEmpty(customMessage) ? "" : $"<div class='highlight'><h4>Mensaje adicional del profesor:</h4><p>{customMessage}</p></div>")}
        
        <p><strong>Reportado por:</strong> {teacherName}</p>
    </div>
    
    <div class='footer'>
        <p>Este es un mensaje automático del sistema EduPlanner.</p>
        <p>Por favor, mantenga este correo para sus registros.</p>
    </div>
</body>
</html>";

                // Enviar email
                return await SendEmailWithAttachmentsAsync(student.Email, subject, body, attachmentPaths, emailConfig);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al enviar email de reporte de orientación");
                return false;
            }
        }

        public async Task<bool> SendEmailWithAttachmentsAsync(string toEmail, string subject, string body, List<string> attachmentPaths, EmailConfigurationDto emailConfig)
        {
            try
            {
                _logger.LogInformation("Iniciando envío de email a: {ToEmail}", toEmail);

                // Limpiar credenciales de espacios ocultos
                var cleanUsername = emailConfig.SmtpUsername?.Trim() ?? string.Empty;
                var cleanPassword = emailConfig.SmtpPassword?.Trim() ?? string.Empty;

                using var client = new SmtpClient(emailConfig.SmtpServer, emailConfig.SmtpPort);
                
                // Configurar SSL/TLS
                bool enableSsl = emailConfig.SmtpUseSsl;
                if (emailConfig.SmtpServer.ToLower().Contains("gmail") && emailConfig.SmtpPort == 587)
                {
                    enableSsl = true;
                }
                
                client.EnableSsl = enableSsl;
                client.UseDefaultCredentials = false;
                client.Credentials = new NetworkCredential(cleanUsername, cleanPassword);
                client.DeliveryMethod = SmtpDeliveryMethod.Network;

                // Crear mensaje
                using var message = new MailMessage();
                message.From = new MailAddress(emailConfig.FromEmail, emailConfig.FromName);
                message.To.Add(toEmail);
                message.Subject = subject;
                message.Body = body;
                message.IsBodyHtml = true;

                // Agregar archivos adjuntos
                foreach (var attachmentPath in attachmentPaths)
                {
                    if (File.Exists(attachmentPath))
                    {
                        var fileName = Path.GetFileName(attachmentPath);
                        var attachment = new Attachment(attachmentPath);
                        attachment.Name = fileName;
                        message.Attachments.Add(attachment);
                        _logger.LogInformation("Archivo adjunto agregado: {FileName}", fileName);
                    }
                }

                _logger.LogInformation("Enviando email desde {FromEmail} a {ToEmail} con {AttachmentCount} archivos adjuntos", 
                    emailConfig.FromEmail, toEmail, message.Attachments.Count);

                await client.SendMailAsync(message);
                _logger.LogInformation("Email enviado exitosamente");
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al enviar email con adjuntos: {ErrorMessage}", ex.Message);
                return false;
            }
        }
    }
}
