using Microsoft.EntityFrameworkCore;
using SchoolManager.Dtos;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;

namespace SchoolManager.Services.Implementations;

/// <summary>Implementación del servicio Club de Padres. No modifica StudentIdCardService, PaymentService ni AuthService.</summary>
public class ClubParentsPaymentService : IClubParentsPaymentService
{
    private readonly SchoolDbContext _context;
    private readonly ICurrentUserService _currentUserService;
    private readonly ILogger<ClubParentsPaymentService> _logger;

    private const string CarnetPendiente = "Pendiente";
    private const string CarnetPagado = "Pagado";
    private const string PlatformPendiente = "Pendiente";
    private const string PlatformActivo = "Activo";

    public ClubParentsPaymentService(
        SchoolDbContext context,
        ICurrentUserService currentUserService,
        ILogger<ClubParentsPaymentService> logger)
    {
        _context = context;
        _currentUserService = currentUserService;
        _logger = logger;
    }

    /// <inheritdoc />
    public async Task<IReadOnlyList<ClubParentsStudentDto>> GetStudentsAsync(Guid? gradeId = null, Guid? groupId = null)
    {
        var school = await _currentUserService.GetCurrentUserSchoolAsync();
        if (school == null)
        {
            _logger.LogWarning("[ClubParents] GetStudentsAsync: usuario sin escuela.");
            return Array.Empty<ClubParentsStudentDto>();
        }

        var query = _context.Users
            .Where(u => (u.Role == "student" || u.Role == "estudiante") && u.SchoolId == school.Id);

        if (gradeId.HasValue || groupId.HasValue)
        {
            query = query.Where(u => u.StudentAssignments.Any(sa =>
                sa.IsActive
                && (!gradeId.HasValue || sa.GradeId == gradeId.Value)
                && (!groupId.HasValue || sa.GroupId == groupId.Value)));
        }

        var users = await query
            .Include(u => u.StudentAssignments.Where(sa => sa.IsActive))
                .ThenInclude(sa => sa.Grade)
            .Include(u => u.StudentAssignments.Where(sa => sa.IsActive))
                .ThenInclude(sa => sa.Group)
            .ToListAsync();

        var studentIds = users.Select(u => u.Id).ToList();
        var accessByStudent = await _context.StudentPaymentAccesses
            .Where(a => a.SchoolId == school.Id && studentIds.Contains(a.StudentId))
            .ToDictionaryAsync(a => a.StudentId, a => a);

        var result = new List<ClubParentsStudentDto>();
        foreach (var u in users)
        {
            var active = u.StudentAssignments.FirstOrDefault(sa => sa.IsActive);
            var access = accessByStudent.GetValueOrDefault(u.Id);
            result.Add(new ClubParentsStudentDto
            {
                Id = u.Id,
                FullName = $"{u.Name} {u.LastName}",
                Grade = active?.Grade?.Name ?? "Sin asignar",
                Group = active?.Group?.Name ?? "Sin asignar",
                CarnetStatus = access?.CarnetStatus ?? CarnetPendiente,
                PlatformAccessStatus = access?.PlatformAccessStatus ?? PlatformPendiente
            });
        }

        return result.OrderBy(x => x.FullName).ToList();
    }

    /// <inheritdoc />
    public async Task<StudentPaymentStatusDto> GetStudentPaymentStatusAsync(Guid studentId)
    {
        var school = await _currentUserService.GetCurrentUserSchoolAsync();
        if (school == null)
            return new StudentPaymentStatusDto { StudentId = studentId, CarnetStatus = CarnetPendiente, PlatformAccessStatus = PlatformPendiente };

        var access = await _context.StudentPaymentAccesses
            .FirstOrDefaultAsync(a => a.StudentId == studentId && a.SchoolId == school.Id);

        if (access == null)
            return new StudentPaymentStatusDto
            {
                StudentId = studentId,
                CarnetStatus = CarnetPendiente,
                PlatformAccessStatus = PlatformPendiente
            };

        return new StudentPaymentStatusDto
        {
            StudentId = studentId,
            CarnetStatus = access.CarnetStatus,
            PlatformAccessStatus = access.PlatformAccessStatus,
            CarnetStatusUpdatedAt = access.CarnetStatusUpdatedAt,
            PlatformStatusUpdatedAt = access.PlatformStatusUpdatedAt
        };
    }

    /// <inheritdoc />
    public async Task MarkCarnetAsPaidAsync(Guid studentId)
    {
        var userId = await _currentUserService.GetCurrentUserIdAsync();
        var school = await _currentUserService.GetCurrentUserSchoolAsync();
        if (school == null)
            throw new InvalidOperationException("Usuario sin escuela asignada.");

        var student = await _context.Users
            .FirstOrDefaultAsync(u => u.Id == studentId && u.SchoolId == school.Id && (u.Role == "student" || u.Role == "estudiante"));
        if (student == null)
            throw new InvalidOperationException("Estudiante no encontrado o no pertenece a su escuela.");

        var access = await _context.StudentPaymentAccesses
            .FirstOrDefaultAsync(a => a.StudentId == studentId && a.SchoolId == school.Id);

        if (access == null)
        {
            access = new StudentPaymentAccess
            {
                StudentId = studentId,
                SchoolId = school.Id,
                CarnetStatus = CarnetPendiente,
                PlatformAccessStatus = PlatformPendiente,
                CreatedAt = DateTime.UtcNow
            };
            _context.StudentPaymentAccesses.Add(access);
        }

        if (access.CarnetStatus != CarnetPendiente)
            throw new InvalidOperationException($"Solo se puede marcar como Pagado desde estado Pendiente. Estado actual: {access.CarnetStatus}.");

        var now = DateTime.UtcNow;
        access.CarnetStatus = CarnetPagado;
        access.CarnetStatusUpdatedAt = now;
        access.CarnetUpdatedByUserId = userId;
        access.UpdatedAt = now;

        await _context.SaveChangesAsync();
        _logger.LogInformation("[ClubParents] Carnet marcado como Pagado StudentId={StudentId} por UserId={UserId}", studentId, userId);
    }

    /// <inheritdoc />
    public async Task ActivatePlatformAsync(Guid studentId)
    {
        var userId = await _currentUserService.GetCurrentUserIdAsync();
        var school = await _currentUserService.GetCurrentUserSchoolAsync();
        if (school == null)
            throw new InvalidOperationException("Usuario sin escuela asignada.");

        var student = await _context.Users
            .FirstOrDefaultAsync(u => u.Id == studentId && u.SchoolId == school.Id && (u.Role == "student" || u.Role == "estudiante"));
        if (student == null)
            throw new InvalidOperationException("Estudiante no encontrado o no pertenece a su escuela.");

        var access = await _context.StudentPaymentAccesses
            .FirstOrDefaultAsync(a => a.StudentId == studentId && a.SchoolId == school.Id);

        if (access == null)
        {
            access = new StudentPaymentAccess
            {
                StudentId = studentId,
                SchoolId = school.Id,
                CarnetStatus = CarnetPendiente,
                PlatformAccessStatus = PlatformPendiente,
                CreatedAt = DateTime.UtcNow
            };
            _context.StudentPaymentAccesses.Add(access);
        }

        if (access.PlatformAccessStatus != PlatformPendiente)
            throw new InvalidOperationException($"Solo se puede activar plataforma desde estado Pendiente. Estado actual: {access.PlatformAccessStatus}.");

        var now = DateTime.UtcNow;
        access.PlatformAccessStatus = PlatformActivo;
        access.PlatformStatusUpdatedAt = now;
        access.PlatformUpdatedByUserId = userId;
        access.UpdatedAt = now;

        await _context.SaveChangesAsync();
        _logger.LogInformation("[ClubParents] Plataforma activada StudentId={StudentId} por UserId={UserId}", studentId, userId);
    }
}
