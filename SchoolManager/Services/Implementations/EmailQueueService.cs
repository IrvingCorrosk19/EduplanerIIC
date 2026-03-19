using System.Security.Claims;
using Microsoft.EntityFrameworkCore;
using SchoolManager.Constants;
using SchoolManager.Models;
using SchoolManager.Repositories.Interfaces;
using SchoolManager.Services.Interfaces;

namespace SchoolManager.Services.Implementations;

public class EmailQueueService : IEmailQueueService
{
    private const string Subject = "Acceso a la plataforma";
    private readonly SchoolDbContext _db;
    private readonly IEmailQueueRepository _repository;
    private readonly IEmailApiConfigurationService _emailApiConfig;
    private readonly ILogger<EmailQueueService> _logger;

    public EmailQueueService(
        SchoolDbContext db,
        IEmailQueueRepository repository,
        IEmailApiConfigurationService emailApiConfig,
        ILogger<EmailQueueService> logger)
    {
        _db = db;
        _repository = repository;
        _emailApiConfig = emailApiConfig;
        _logger = logger;
    }

    public async Task EnqueueUsersAsync(List<Guid> userIds, ClaimsPrincipal currentUser)
    {
        if (userIds == null || userIds.Count == 0) return;

        var callerIdClaim = currentUser.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (!Guid.TryParse(callerIdClaim, out var callerUserId))
        {
            _logger.LogWarning("EnqueueUsersAsync: sin NameIdentifier en ClaimsPrincipal.");
            return;
        }

        var caller = await _db.Users.IgnoreQueryFilters()
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.Id == callerUserId);
        if (caller == null) return;

        var role = (caller.Role ?? string.Empty).ToLowerInvariant();
        if (role != "superadmin" && role != "admin")
        {
            _logger.LogWarning("EnqueueUsersAsync: rol no autorizado {Role}", caller.Role);
            return;
        }

        var isSuperAdmin = role == "superadmin";
        var callerSchoolId = caller.SchoolId;

        var apiCfg = await _emailApiConfig.GetActiveAsync();
        if (apiCfg == null || string.IsNullOrWhiteSpace(apiCfg.ApiKey))
        {
            _logger.LogWarning("EnqueueUsersAsync: no hay EmailApiConfiguration activa con API key.");
            return;
        }

        var fromName = string.IsNullOrWhiteSpace(apiCfg.FromName) ? "SchoolManager" : apiCfg.FromName.Trim();
        var distinctIds = userIds.Distinct().ToList();

        var users = await _db.Users.IgnoreQueryFilters()
            .Where(u => distinctIds.Contains(u.Id))
            .ToListAsync();

        var queueItems = new List<EmailQueue>();
        var now = DateTime.UtcNow;

        foreach (var user in users)
        {
            if (!isSuperAdmin && (callerSchoolId == null || user.SchoolId != callerSchoolId.Value))
                continue;

            if (string.IsNullOrWhiteSpace(user.Email))
            {
                user.PasswordEmailStatus = PasswordEmailStatusValues.Failed;
                user.PasswordEmailSentAt = now;
                user.UpdatedAt = now;
                continue;
            }

            var plainPassword = DefaultTemporaryPassword.Value;
            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(plainPassword);
            user.PasswordEmailStatus = PasswordEmailStatusValues.Pending;
            user.UpdatedAt = now;

            var body = BuildEmailHtml(user.Email, plainPassword, fromName);
            queueItems.Add(new EmailQueue
            {
                Id = Guid.NewGuid(),
                UserId = user.Id,
                Email = user.Email,
                Subject = Subject,
                Body = body,
                Status = EmailQueueStatus.Pending,
                Attempts = 0,
                MaxAttempts = 3,
                CreatedAt = now
            });
        }

        await _db.SaveChangesAsync();
        _repository.AddRange(queueItems);
        await _repository.SaveChangesAsync();
        _logger.LogInformation("EnqueueUsersAsync: {Count} correos encolados.", queueItems.Count);
    }

    private static string BuildEmailHtml(string email, string tempPassword, string fromName)
    {
        var e = System.Net.WebUtility.HtmlEncode(email);
        var p = System.Net.WebUtility.HtmlEncode(tempPassword);
        var fn = System.Net.WebUtility.HtmlEncode(fromName);
        const string platformUrl = "https://eduplaner.net/";
        return $@"
<div style=""font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; max-width: 520px; margin: 0 auto; color: #333; line-height: 1.5;"">
  <div style=""background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%); color: #fff; padding: 24px 28px; border-radius: 12px 12px 0 0; text-align: center;"">
    <h1 style=""margin: 0; font-size: 22px; font-weight: 600;"">Acceso a la plataforma</h1>
    <p style=""margin: 8px 0 0; font-size: 14px; opacity: 0.95;"">Sistema de Gestión Educativa</p>
  </div>
  <div style=""padding: 28px; background: #fff; border: 1px solid #e2e8f0; border-top: none; border-radius: 0 0 12px 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.05);"">
    <p style=""margin: 0 0 20px; font-size: 16px;"">Hola,</p>
    <p style=""margin: 0 0 20px; font-size: 15px; color: #475569;"">Se ha actualizado tu acceso. Utiliza los siguientes datos para iniciar sesión:</p>
    <div style=""background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px; margin: 24px 0;"">
      <table style=""width: 100%; border-collapse: collapse;"">
        <tr><td style=""padding: 8px 0; font-size: 13px; color: #64748b;"">Usuario</td></tr>
        <tr><td style=""padding: 0 0 12px; font-size: 16px; font-weight: 600; color: #1e293b;"">{e}</td></tr>
        <tr><td style=""padding: 8px 0; font-size: 13px; color: #64748b;"">Contraseña temporal</td></tr>
        <tr><td style=""padding: 0; font-size: 16px; font-weight: 600; color: #1e293b; letter-spacing: 1px;"">{p}</td></tr>
      </table>
    </div>
    <p style=""margin: 0 0 20px; font-size: 15px; color: #475569;"">Accede a la plataforma en el siguiente enlace:</p>
    <p style=""margin: 0 0 24px;"">
      <a href=""{platformUrl}"" style=""display: inline-block; background: #2563eb; color: #fff !important; text-decoration: none; padding: 12px 24px; border-radius: 8px; font-weight: 600; font-size: 15px;"">Ir a Eduplaner</a>
    </p>
    <p style=""margin: 0; font-size: 14px; color: #64748b; border-top: 1px solid #e2e8f0; padding-top: 20px;"">Por seguridad, te recomendamos cambiar tu contraseña después del primer acceso.</p>
  </div>
  <p style=""margin: 20px 0 0; font-size: 13px; color: #94a3b8; text-align: center;"">Saludos,<br/><strong style=""color: #64748b;"">{fn}</strong></p>
</div>";
    }
}
