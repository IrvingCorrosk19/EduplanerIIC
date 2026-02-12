using Microsoft.EntityFrameworkCore;
using SchoolManager.Dtos;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;

namespace SchoolManager.Services.Implementations;

public class StudentIdCardService : IStudentIdCardService
{
    private readonly SchoolDbContext _context;

    public StudentIdCardService(SchoolDbContext context)
    {
        _context = context;
    }

    public async Task<StudentIdCardDto> GenerateAsync(Guid studentId, Guid createdBy)
    {
        var student = await _context.Users
            .Include(x => x.StudentAssignments)
                .ThenInclude(x => x.Grade)
            .Include(x => x.StudentAssignments)
                .ThenInclude(x => x.Group)
            .Include(x => x.StudentAssignments)
                .ThenInclude(x => x.Shift)
            .FirstOrDefaultAsync(x => x.Id == studentId && (x.Role == "student" || x.Role == "estudiante"));

        if (student == null)
            throw new Exception("Estudiante no encontrado");

        var activeAssignment = student.StudentAssignments.FirstOrDefault(x => x.IsActive);
        if (activeAssignment == null)
            throw new Exception("Estudiante sin asignación activa");

        // Verificar si ya tiene un carnet activo
        var existingCard = await _context.StudentIdCards
            .FirstOrDefaultAsync(x => x.StudentId == studentId && x.Status == "active");

        if (existingCard != null)
        {
            // Revocar carnet anterior
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

        var cardNumber = $"SM-{DateTime.UtcNow:yyyyMMdd}-{studentId.ToString()[..8].ToUpper()}";

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

        return new StudentIdCardDto
        {
            StudentId = studentId,
            CardNumber = cardNumber,
            FullName = $"{student.Name} {student.LastName}",
            Grade = activeAssignment.Grade.Name,
            Group = activeAssignment.Group.Name,
            Shift = activeAssignment.Shift?.Name ?? "N/A",
            QrToken = newToken.Token
        };
    }

    public async Task<ScanResultDto> ScanAsync(ScanRequestDto request)
    {
        var token = await _context.StudentQrTokens
            .Include(x => x.Student)
                .ThenInclude(x => x.StudentAssignments)
                    .ThenInclude(x => x.Grade)
            .Include(x => x.Student)
                .ThenInclude(x => x.StudentAssignments)
                    .ThenInclude(x => x.Group)
            .FirstOrDefaultAsync(x => x.Token == request.Token && !x.IsRevoked && (x.ExpiresAt == null || x.ExpiresAt > DateTime.UtcNow));

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
                Group = "N/A"
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
                Group = "N/A"
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

        return new ScanResultDto
        {
            Allowed = true,
            Message = "Acceso permitido",
            StudentName = $"{token.Student.Name} {token.Student.LastName}",
            Grade = assignment.Grade.Name,
            Group = assignment.Group.Name
        };
    }
}
