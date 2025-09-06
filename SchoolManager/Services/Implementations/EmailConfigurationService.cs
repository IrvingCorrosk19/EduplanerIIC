using Microsoft.EntityFrameworkCore;
using SchoolManager.Dtos;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using System.Net.Mail;
using System.Net;

namespace SchoolManager.Services.Implementations
{
    public class EmailConfigurationService : IEmailConfigurationService
    {
        private readonly SchoolDbContext _context;

        public EmailConfigurationService(SchoolDbContext context)
        {
            _context = context;
        }

        public async Task<List<EmailConfigurationDto>> GetAllAsync()
        {
            var configurations = await _context.EmailConfigurations
                .Include(ec => ec.School)
                .OrderBy(ec => ec.School.Name)
                .ThenBy(ec => ec.CreatedAt)
                .ToListAsync();

            return configurations.Select(MapToDto).ToList();
        }

        public async Task<EmailConfigurationDto?> GetByIdAsync(Guid id)
        {
            var configuration = await _context.EmailConfigurations
                .Include(ec => ec.School)
                .FirstOrDefaultAsync(ec => ec.Id == id);

            return configuration != null ? MapToDto(configuration) : null;
        }

        public async Task<EmailConfigurationDto?> GetBySchoolIdAsync(Guid schoolId)
        {
            var configuration = await _context.EmailConfigurations
                .Include(ec => ec.School)
                .FirstOrDefaultAsync(ec => ec.SchoolId == schoolId);

            return configuration != null ? MapToDto(configuration) : null;
        }

        public async Task<EmailConfigurationDto?> GetActiveBySchoolIdAsync(Guid schoolId)
        {
            var configuration = await _context.EmailConfigurations
                .Include(ec => ec.School)
                .FirstOrDefaultAsync(ec => ec.SchoolId == schoolId && ec.IsActive);

            return configuration != null ? MapToDto(configuration) : null;
        }

        public async Task<EmailConfigurationDto> CreateAsync(EmailConfigurationCreateDto createDto)
        {
            var configuration = new EmailConfiguration
            {
                Id = Guid.NewGuid(),
                SchoolId = createDto.SchoolId,
                SmtpServer = createDto.SmtpServer,
                SmtpPort = createDto.SmtpPort,
                SmtpUsername = createDto.SmtpUsername,
                SmtpPassword = createDto.SmtpPassword,
                SmtpUseSsl = createDto.SmtpUseSsl,
                SmtpUseTls = createDto.SmtpUseTls,
                FromEmail = createDto.FromEmail,
                FromName = createDto.FromName,
                IsActive = createDto.IsActive,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _context.EmailConfigurations.Add(configuration);
            await _context.SaveChangesAsync();

            return await GetByIdAsync(configuration.Id) ?? throw new InvalidOperationException("Error al crear la configuración de email");
        }

        public async Task<EmailConfigurationDto> UpdateAsync(EmailConfigurationUpdateDto updateDto)
        {
            var configuration = await _context.EmailConfigurations
                .FirstOrDefaultAsync(ec => ec.Id == updateDto.Id);

            if (configuration == null)
                throw new ArgumentException("Configuración de email no encontrada");

            configuration.SmtpServer = updateDto.SmtpServer;
            configuration.SmtpPort = updateDto.SmtpPort;
            configuration.SmtpUsername = updateDto.SmtpUsername;
            configuration.SmtpPassword = updateDto.SmtpPassword;
            configuration.SmtpUseSsl = updateDto.SmtpUseSsl;
            configuration.SmtpUseTls = updateDto.SmtpUseTls;
            configuration.FromEmail = updateDto.FromEmail;
            configuration.FromName = updateDto.FromName;
            configuration.IsActive = updateDto.IsActive;
            configuration.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            return await GetByIdAsync(configuration.Id) ?? throw new InvalidOperationException("Error al actualizar la configuración de email");
        }

        public async Task<bool> DeleteAsync(Guid id)
        {
            var configuration = await _context.EmailConfigurations
                .FirstOrDefaultAsync(ec => ec.Id == id);

            if (configuration == null)
                return false;

            _context.EmailConfigurations.Remove(configuration);
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<bool> TestConnectionAsync(Guid id)
        {
            var configuration = await _context.EmailConfigurations
                .FirstOrDefaultAsync(ec => ec.Id == id);

            if (configuration == null)
                return false;

            return await TestSmtpConnection(configuration);
        }

        public async Task<bool> TestConnectionBySchoolIdAsync(Guid schoolId)
        {
            var configuration = await _context.EmailConfigurations
                .FirstOrDefaultAsync(ec => ec.SchoolId == schoolId && ec.IsActive);

            if (configuration == null)
                return false;

            return await TestSmtpConnection(configuration);
        }

        private async Task<bool> TestSmtpConnection(EmailConfiguration configuration)
        {
            try
            {
                using var client = new SmtpClient(configuration.SmtpServer, configuration.SmtpPort);
                client.EnableSsl = configuration.SmtpUseSsl;
                client.UseDefaultCredentials = false;
                client.Credentials = new NetworkCredential(configuration.SmtpUsername, configuration.SmtpPassword);

                // Crear un mensaje de prueba
                using var message = new MailMessage();
                message.From = new MailAddress(configuration.FromEmail, configuration.FromName);
                message.To.Add(configuration.FromEmail); // Enviar a sí mismo para prueba
                message.Subject = "Prueba de configuración SMTP";
                message.Body = "Esta es una prueba de configuración SMTP. Si recibes este mensaje, la configuración es correcta.";
                message.IsBodyHtml = false;

                await client.SendMailAsync(message);
                return true;
            }
            catch
            {
                return false;
            }
        }

        private static EmailConfigurationDto MapToDto(EmailConfiguration configuration)
        {
            return new EmailConfigurationDto
            {
                Id = configuration.Id,
                SchoolId = configuration.SchoolId,
                SmtpServer = configuration.SmtpServer,
                SmtpPort = configuration.SmtpPort,
                SmtpUsername = configuration.SmtpUsername,
                SmtpPassword = configuration.SmtpPassword,
                SmtpUseSsl = configuration.SmtpUseSsl,
                SmtpUseTls = configuration.SmtpUseTls,
                FromEmail = configuration.FromEmail,
                FromName = configuration.FromName,
                IsActive = configuration.IsActive,
                CreatedAt = configuration.CreatedAt,
                UpdatedAt = configuration.UpdatedAt
            };
        }
    }
}
