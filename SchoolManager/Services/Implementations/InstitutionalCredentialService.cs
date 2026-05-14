using System.Data;
using Microsoft.EntityFrameworkCore;
using SchoolManager.Dtos;
using SchoolManager.Helpers;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using SchoolManager.Services.Security;

namespace SchoolManager.Services.Implementations;

public class InstitutionalCredentialService : IInstitutionalCredentialService
{
    public const int QrTokenValidityMonths = 6;

    private readonly SchoolDbContext _context;
    private readonly ILogger<InstitutionalCredentialService> _logger;
    private readonly IQrSignatureService _qrSignatureService;

    public InstitutionalCredentialService(
        SchoolDbContext context,
        ILogger<InstitutionalCredentialService> logger,
        IQrSignatureService qrSignatureService)
    {
        _context = context;
        _logger = logger;
        _qrSignatureService = qrSignatureService;
    }

    public async Task<InstitutionalCredentialCardDto?> GetCurrentCardAsync(Guid userId)
    {
        var row = await StaffInstitutionalRoleFilter.WhereIsInstitutionalStaff(_context.Users.AsNoTracking())
            .Where(u => u.Id == userId)
            .Select(u => new
            {
                u.Name,
                u.LastName,
                u.PhotoUrl,
                u.Role,
                u.SchoolId,
                JobTitle = _context.Set<StaffInstitutionalProfile>()
                    .Where(p => p.UserId == u.Id)
                    .Select(p => p.JobTitle)
                    .FirstOrDefault(),
                Department = _context.Set<StaffInstitutionalProfile>()
                    .Where(p => p.UserId == u.Id)
                    .Select(p => p.Department)
                    .FirstOrDefault()
            })
            .FirstOrDefaultAsync();

        if (row == null || !row.SchoolId.HasValue)
            return null;

        var card = await _context.Set<InstitutionalCredentialCard>()
            .AsNoTracking()
            .Where(c => c.UserId == userId && c.Status == "active")
            .Select(c => new { c.CardNumber })
            .FirstOrDefaultAsync();

        if (card == null)
            return null;

        var token = await _context.Set<StaffQrToken>()
            .AsNoTracking()
            .Where(t => t.UserId == userId && !t.IsRevoked &&
                (t.ExpiresAt == null || t.ExpiresAt > DateTime.UtcNow))
            .Select(t => new { t.Token })
            .FirstOrDefaultAsync();

        if (token == null)
            return null;

        var pngBytes = QrHelper.GenerateQrPng(token.Token, _qrSignatureService);
        var qrImageDataUrl = "data:image/png;base64," + Convert.ToBase64String(pngBytes);

        return new InstitutionalCredentialCardDto
        {
            UserId = userId,
            CardNumber = card.CardNumber,
            FullName = $"{row.Name} {row.LastName}",
            RoleDisplay = StaffInstitutionalRoleFilter.FormatRoleDisplay(row.Role),
            JobTitle = string.IsNullOrWhiteSpace(row.JobTitle) ? "—" : row.JobTitle!,
            Department = string.IsNullOrWhiteSpace(row.Department) ? "—" : row.Department!,
            QrToken = token.Token,
            QrImageDataUrl = qrImageDataUrl,
            PhotoUrl = row.PhotoUrl
        };
    }

    public async Task<InstitutionalCredentialCardDto> GenerateAsync(Guid userId, Guid createdBy)
    {
        _logger.LogInformation(
            "[InstitutionalCredential] GenerateAsync UserId={UserId} CreatedBy={CreatedBy}",
            userId, createdBy);

        using var transaction = await _context.Database.BeginTransactionAsync(IsolationLevel.Serializable);
        try
        {
            var user = await StaffInstitutionalRoleFilter.WhereIsInstitutionalStaff(_context.Users)
                .FirstOrDefaultAsync(u => u.Id == userId);

            if (user == null)
            {
                _logger.LogWarning("[InstitutionalCredential] Usuario no elegible UserId={UserId}", userId);
                throw new InvalidOperationException("Usuario no encontrado o no es personal institucional.");
            }

            if (!user.SchoolId.HasValue)
            {
                _logger.LogWarning("[InstitutionalCredential] Sin escuela UserId={UserId}", userId);
                throw new InvalidOperationException("El usuario debe tener una escuela asignada.");
            }

            var profile = await _context.Set<StaffInstitutionalProfile>()
                .AsNoTracking()
                .FirstOrDefaultAsync(p => p.UserId == userId);

            var existingCards = await _context.Set<InstitutionalCredentialCard>()
                .Where(c => c.UserId == userId && c.Status == "active")
                .ToListAsync();
            foreach (var ec in existingCards)
                ec.Status = "revoked";

            var existingTokens = await _context.Set<StaffQrToken>()
                .Where(t => t.UserId == userId && !t.IsRevoked)
                .ToListAsync();
            foreach (var et in existingTokens)
                et.IsRevoked = true;

            var cardNumber = InstitutionalCardNumberHelper.Generate(userId);
            var card = new InstitutionalCredentialCard
            {
                UserId = userId,
                CardNumber = cardNumber,
                ExpiresAt = DateTime.UtcNow.AddYears(1),
                Status = "active"
            };

            var newToken = new StaffQrToken
            {
                UserId = userId,
                Token = Guid.NewGuid().ToString("N"),
                ExpiresAt = DateTime.UtcNow.AddMonths(QrTokenValidityMonths),
                IsRevoked = false
            };

            _context.Set<InstitutionalCredentialCard>().Add(card);
            _context.Set<StaffQrToken>().Add(newToken);

            await _context.SaveChangesAsync();
            await transaction.CommitAsync();

            var pngBytes = QrHelper.GenerateQrPng(newToken.Token, _qrSignatureService);
            var qrImageDataUrl = "data:image/png;base64," + Convert.ToBase64String(pngBytes);

            return new InstitutionalCredentialCardDto
            {
                UserId = userId,
                CardNumber = cardNumber,
                FullName = $"{user.Name} {user.LastName}",
                RoleDisplay = StaffInstitutionalRoleFilter.FormatRoleDisplay(user.Role),
                JobTitle = string.IsNullOrWhiteSpace(profile?.JobTitle) ? "—" : profile!.JobTitle!,
                Department = string.IsNullOrWhiteSpace(profile?.Department) ? "—" : profile!.Department!,
                QrToken = newToken.Token,
                QrImageDataUrl = qrImageDataUrl,
                PhotoUrl = user.PhotoUrl
            };
        }
        catch
        {
            await transaction.RollbackAsync();
            throw;
        }
    }
}
