using System.Security.Claims;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using SchoolManager.Constants;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;

namespace SchoolManager.Services.Implementations;

public static class PasswordEmailStatusValues
{
    public const string Pending = "Pending";
    public const string Sent = "Sent";
    public const string Failed = "Failed";
}

public class BulkPasswordEmailService : IBulkPasswordEmailService
{
    private const string Subject = "Acceso a la plataforma";
    private readonly SchoolDbContext _db;
    private readonly IEmailService _emailService;
    private readonly IEmailApiConfigurationService _emailApiConfigurationService;
    private readonly ILogger<BulkPasswordEmailService> _logger;

    public BulkPasswordEmailService(
        SchoolDbContext db,
        IEmailService emailService,
        IEmailApiConfigurationService emailApiConfigurationService,
        ILogger<BulkPasswordEmailService> logger)
    {
        _db = db;
        _emailService = emailService;
        _emailApiConfigurationService = emailApiConfigurationService;
        _logger = logger;
    }

    public async Task<BulkPasswordEmailResult> SendPasswordsAsync(
        IReadOnlyList<Guid> userIds,
        ClaimsPrincipal currentUser,
        CancellationToken cancellationToken = default)
    {
        var list = new List<BulkPasswordEmailItemResult>();
        if (userIds == null || userIds.Count == 0)
            return new BulkPasswordEmailResult { Items = list };

        var callerIdClaim = currentUser.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (!Guid.TryParse(callerIdClaim, out var callerUserId))
        {
            _logger.LogWarning("SendPasswordsAsync: sin NameIdentifier en ClaimsPrincipal.");
            return new BulkPasswordEmailResult { Items = list };
        }

        var caller = await _db.Users.IgnoreQueryFilters()
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.Id == callerUserId, cancellationToken);

        if (caller == null)
            return new BulkPasswordEmailResult { Items = list };

        var role = (caller.Role ?? string.Empty).ToLowerInvariant();
        // Director u otros: el controlador ya restringe; defensa en profundidad
        if (role != "superadmin" && role != "admin")
        {
            _logger.LogWarning("SendPasswordsAsync: rol no autorizado {Role}", caller.Role);
            foreach (var id in userIds.Distinct())
                list.Add(new BulkPasswordEmailItemResult { UserId = id, Success = false, Message = "No autorizado." });
            return new BulkPasswordEmailResult { Items = list };
        }

        var isSuperAdmin = role == "superadmin";
        var callerSchoolId = caller.SchoolId;

        var apiCfg = await _emailApiConfigurationService.GetActiveAsync(cancellationToken);
        if (apiCfg == null || string.IsNullOrWhiteSpace(apiCfg.ApiKey))
        {
            foreach (var id in userIds.Distinct())
                list.Add(new BulkPasswordEmailItemResult
                {
                    UserId = id,
                    Success = false,
                    Message = "Configure EmailApiConfiguration activa con API key."
                });
            return new BulkPasswordEmailResult { Items = list };
        }

        var fromName = string.IsNullOrWhiteSpace(apiCfg.FromName) ? "SchoolManager" : apiCfg.FromName.Trim();
        var distinctIds = userIds.Distinct().ToList();

        foreach (var userId in distinctIds)
        {
            var item = new BulkPasswordEmailItemResult { UserId = userId };
            list.Add(item);

            var user = await _db.Users.IgnoreQueryFilters()
                .FirstOrDefaultAsync(u => u.Id == userId, cancellationToken);

            if (user == null)
            {
                item.Success = false;
                item.Message = "Usuario no encontrado.";
                continue;
            }

            if (!isSuperAdmin)
            {
                if (!callerSchoolId.HasValue || user.SchoolId != callerSchoolId.Value)
                {
                    item.Success = false;
                    item.Message = "No autorizado (otra escuela).";
                    continue;
                }
            }

            if (string.IsNullOrWhiteSpace(user.Email))
            {
                user.PasswordEmailStatus = PasswordEmailStatusValues.Failed;
                user.PasswordEmailSentAt = DateTime.UtcNow;
                user.UpdatedAt = DateTime.UtcNow;
                await _db.SaveChangesAsync(cancellationToken);
                item.Success = false;
                item.Message = "Sin correo electrónico.";
                continue;
            }

            var oldHash = user.PasswordHash;
            var plainPassword = DefaultTemporaryPassword.Value;
            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(plainPassword);
            user.PasswordEmailStatus = PasswordEmailStatusValues.Pending;
            user.UpdatedAt = DateTime.UtcNow;

            try
            {
                await _db.SaveChangesAsync(cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error guardando nuevo hash usuario {UserId}", userId);
                item.Success = false;
                item.Message = "Error al guardar contraseña.";
                continue;
            }

            var html = BuildEmailHtml(user.Email, plainPassword, fromName);
            var (ok, err) = await _emailService.SendEmailAsync(user.Email, Subject, html, cancellationToken);
            var now = DateTime.UtcNow;

            if (ok)
            {
                user.PasswordEmailStatus = PasswordEmailStatusValues.Sent;
                user.PasswordEmailSentAt = now;
                user.UpdatedAt = now;
                item.Success = true;
                _logger.LogInformation("Contraseña temporal enviada por correo UserId={UserId}", userId);
            }
            else
            {
                // Revertir hash: el usuario no recibió la nueva contraseña
                user.PasswordHash = oldHash;
                user.PasswordEmailStatus = PasswordEmailStatusValues.Failed;
                user.PasswordEmailSentAt = now;
                user.UpdatedAt = now;
                item.Success = false;
                item.Message = err;
                _logger.LogWarning("Fallo envío correo UserId={UserId}: {Err}", userId, err);
            }

            await _db.SaveChangesAsync(cancellationToken);
        }

        return new BulkPasswordEmailResult { Items = list };
    }

    private static string BuildEmailHtml(string email, string tempPassword, string fromName)
    {
        var e = System.Net.WebUtility.HtmlEncode(email);
        var p = System.Net.WebUtility.HtmlEncode(tempPassword);
        var fn = System.Net.WebUtility.HtmlEncode(fromName);
        return $@"<p>Hola,</p>
<p>Se ha actualizado su acceso a la plataforma.</p>
<p><strong>Usuario:</strong> {e}<br/>
<strong>Contraseña temporal:</strong> {p}</p>
<p>Por seguridad, le recomendamos iniciar sesión y cambiar su contraseña.</p>
<p>Saludos,<br/>{fn}</p>";
    }

}
