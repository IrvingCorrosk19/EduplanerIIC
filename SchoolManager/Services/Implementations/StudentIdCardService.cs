using Microsoft.EntityFrameworkCore;
using SchoolManager.Dtos;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using SchoolManager.Services.Security;

namespace SchoolManager.Services.Implementations;

public class StudentIdCardService : IStudentIdCardService
{
    private readonly SchoolDbContext _context;
    private readonly ILogger<StudentIdCardService> _logger;
    private readonly IQrSignatureService _qrSignatureService;

    public StudentIdCardService(SchoolDbContext context, ILogger<StudentIdCardService> logger, IQrSignatureService qrSignatureService)
    {
        _context = context;
        _logger = logger;
        _qrSignatureService = qrSignatureService;
    }

    /// <summary>Genera un número de carnet único (evita duplicados con carnets revocados en la misma fecha).</summary>
    private static string GenerateUniqueCardNumber(Guid studentId)
    {
        return $"SM-{DateTime.UtcNow:yyyyMMdd}-{studentId.ToString("N")[..8].ToUpper()}-{Guid.NewGuid().ToString("N")[..6].ToUpper()}";
    }

    public async Task<StudentIdCardDto> GenerateAsync(Guid studentId, Guid createdBy)
    {
        _logger.LogInformation("[StudentIdCard] GenerateAsync inicio StudentId={StudentId} CreatedBy={CreatedBy}", studentId, createdBy);

        var student = await _context.Users
            .Include(x => x.StudentAssignments)
                .ThenInclude(x => x.Grade)
            .Include(x => x.StudentAssignments)
                .ThenInclude(x => x.Group)
            .Include(x => x.StudentAssignments)
                .ThenInclude(x => x.Shift)
            .FirstOrDefaultAsync(x => x.Id == studentId && (x.Role == "student" || x.Role == "estudiante"));

        if (student == null)
        {
            _logger.LogWarning("[StudentIdCard] GenerateAsync estudiante no encontrado StudentId={StudentId}", studentId);
            throw new Exception("Estudiante no encontrado");
        }

        var activeAssignment = student.StudentAssignments.FirstOrDefault(x => x.IsActive);
        if (activeAssignment == null)
        {
            _logger.LogWarning("[StudentIdCard] GenerateAsync estudiante sin asignación activa StudentId={StudentId}", studentId);
            throw new Exception("Estudiante sin asignación activa");
        }

        // Verificar si ya tiene un carnet activo
        var existingCard = await _context.StudentIdCards
            .FirstOrDefaultAsync(x => x.StudentId == studentId && x.Status == "active");

        if (existingCard != null)
        {
            _logger.LogInformation("[StudentIdCard] Revocando carnet anterior Id={CardId} CardNumber={CardNumber}", existingCard.Id, existingCard.CardNumber);
            existingCard.Status = "revoked";
            _context.StudentIdCards.Update(existingCard);
        }

        // Revocar tokens anteriores
        var existingTokens = await _context.StudentQrTokens
            .Where(x => x.StudentId == studentId && !x.IsRevoked && (x.ExpiresAt == null || x.ExpiresAt > DateTime.UtcNow))
            .ToListAsync();

        foreach (var existingToken in existingTokens)
        {
            existingToken.IsRevoked = true;
        }

        var cardNumber = GenerateUniqueCardNumber(studentId);
        _logger.LogInformation("[StudentIdCard] Nuevo carnet CardNumber={CardNumber} StudentId={StudentId}", cardNumber, studentId);

        var card = new StudentIdCard
        {
            StudentId = studentId,
            CardNumber = cardNumber,
            ExpiresAt = DateTime.UtcNow.AddYears(1),
            Status = "active"
        };

        var newToken = new StudentQrToken
        {
            StudentId = studentId,
            Token = Guid.NewGuid().ToString(),
            ExpiresAt = DateTime.UtcNow.AddHours(12)
        };

        _context.StudentIdCards.Add(card);
        _context.StudentQrTokens.Add(newToken);
        
        if (existingTokens.Any())
        {
            _context.StudentQrTokens.UpdateRange(existingTokens);
        }
        
        await _context.SaveChangesAsync();
        _logger.LogInformation("[StudentIdCard] GenerateAsync OK StudentId={StudentId} CardNumber={CardNumber}", studentId, cardNumber);

        return new StudentIdCardDto
        {
            StudentId = studentId,
            CardNumber = cardNumber,
            FullName = $"{student.Name} {student.LastName}",
            Grade = activeAssignment.Grade.Name,
            Group = activeAssignment.Group.Name,
            Shift = activeAssignment.Shift?.Name ?? "N/A",
            QrToken = newToken.Token,
            PhotoUrl = student.PhotoUrl
        };
    }

    public async Task<ScanResultDto> ScanAsync(ScanRequestDto request)
    {
        var tokenToLookup = request.Token;
        if (request.Token.Contains("|"))
        {
            if (!_qrSignatureService.ValidateSignedToken(request.Token))
            {
                _context.ScanLogs.Add(new ScanLog
                {
                    StudentId = null,
                    ScanType = request.ScanType,
                    Result = "denied",
                    ScannedBy = request.ScannedBy
                });
                await _context.SaveChangesAsync();
                return new ScanResultDto
                {
                    Allowed = false,
                    Message = "QR inválido o expirado",
                    StudentName = "N/A",
                    Grade = "N/A",
                    Group = "N/A",
                    DisciplineCount = 0
                };
            }
            tokenToLookup = _qrSignatureService.ExtractTokenFromSigned(request.Token) ?? request.Token;
        }

        var token = await _context.StudentQrTokens
            .Include(x => x.Student)
                .ThenInclude(x => x.StudentAssignments)
                    .ThenInclude(x => x.Grade)
            .Include(x => x.Student)
                .ThenInclude(x => x.StudentAssignments)
                    .ThenInclude(x => x.Group)
            .Include(x => x.Student)
                .ThenInclude(x => x.SchoolNavigation)
            .FirstOrDefaultAsync(x => x.Token == tokenToLookup && !x.IsRevoked && (x.ExpiresAt == null || x.ExpiresAt > DateTime.UtcNow));

        if (token == null)
        {
            _context.ScanLogs.Add(new ScanLog
            {
                StudentId = null, // No se conoce el estudiante (token inválido)
                ScanType = request.ScanType,
                Result = "denied",
                ScannedBy = request.ScannedBy
            });
            await _context.SaveChangesAsync();
            
            return new ScanResultDto 
            { 
                Allowed = false, 
                Message = "QR inválido o expirado",
                StudentName = "N/A",
                Grade = "N/A",
                Group = "N/A",
                DisciplineCount = 0
            };
        }

        var assignment = token.Student.StudentAssignments.FirstOrDefault(x => x.IsActive);
        if (assignment == null)
        {
            _context.ScanLogs.Add(new ScanLog
            {
                StudentId = token.StudentId,
                ScanType = request.ScanType,
                Result = "denied",
                ScannedBy = request.ScannedBy
            });
            await _context.SaveChangesAsync();
            
            return new ScanResultDto 
            { 
                Allowed = false, 
                Message = "Estudiante sin asignación activa",
                StudentName = $"{token.Student.Name} {token.Student.LastName}",
                Grade = "N/A",
                Group = "N/A",
                DisciplineCount = 0
            };
        }

        _context.ScanLogs.Add(new ScanLog
        {
            StudentId = token.StudentId,
            ScanType = request.ScanType,
            Result = "allowed",
            ScannedBy = request.ScannedBy
        });

        await _context.SaveChangesAsync();

        var card = await _context.StudentIdCards
            .AsNoTracking()
            .Where(c => c.StudentId == token.StudentId && c.Status == "active")
            .FirstOrDefaultAsync();

        var allowedToEnterSchool =
            token.Student.Status == "active"
            && card != null
            && card.Status == "active"
            && token.Student.StudentAssignments.Any(a => a.IsActive);

        var disciplineCount = await _context.DisciplineReports
            .AsNoTracking()
            .Where(r => r.StudentId == token.StudentId)
            .CountAsync();

        var scannedByUser = await _context.Users
            .AsNoTracking()
            .Where(u => u.Id == request.ScannedBy)
            .Select(u => u.Role)
            .FirstOrDefaultAsync();
        var role = (scannedByUser ?? "").Trim().ToLowerInvariant();
        var canSeeSensitiveData = role is "inspector" or "teacher" or "docente" or "admin" or "superadmin";

        return new ScanResultDto
        {
            Allowed = true,
            Message = "Acceso permitido",
            StudentName = $"{token.Student.Name} {token.Student.LastName}",
            Grade = assignment.Grade.Name,
            Group = assignment.Group.Name,
            StudentId = token.StudentId,
            DisciplineCount = disciplineCount,
            StudentPhotoUrl = token.Student.PhotoUrl,
            SchoolName = token.Student.SchoolNavigation?.Name,
            StudentCode = token.Student.DocumentId,
            EmergencyContactName = canSeeSensitiveData ? token.Student.EmergencyContactName : null,
            EmergencyContactPhone = canSeeSensitiveData ? token.Student.EmergencyContactPhone : null,
            Allergies = canSeeSensitiveData ? token.Student.Allergies : null,
            CardNumber = card?.CardNumber,
            CardStatus = card?.Status,
            CardIssuedDate = card?.IssuedAt,
            AllowedToEnterSchool = allowedToEnterSchool
        };
    }
}
