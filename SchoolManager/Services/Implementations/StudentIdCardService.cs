using System.Data;
using Microsoft.EntityFrameworkCore;
using SchoolManager.Dtos;
using SchoolManager.Helpers;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using SchoolManager.Services.Security;

namespace SchoolManager.Services.Implementations;

public class StudentIdCardService : IStudentIdCardService
{
    private readonly SchoolDbContext _context;
    private readonly ILogger<StudentIdCardService> _logger;
    private readonly IQrSignatureService _qrSignatureService;

    /// <summary>
    /// Vida del token QR. Constante pública para que PdfService use el mismo valor.
    /// Un carnet se emite por 1 año; el token dura 6 meses para forzar renovación semestral.
    /// </summary>
    public const int QrTokenValidityMonths = 6;

    /// <summary>Valores permitidos para ScanType. Protege contra inyección de datos en scan_logs.</summary>
    private static readonly HashSet<string> AllowedScanTypes =
        new(StringComparer.OrdinalIgnoreCase) { "entry", "exit", "event", "cafeteria" };

    public StudentIdCardService(
        SchoolDbContext context,
        ILogger<StudentIdCardService> logger,
        IQrSignatureService qrSignatureService)
    {
        _context = context;
        _logger = logger;
        _qrSignatureService = qrSignatureService;
    }

    // ──────────────────────────────────────────────────────────────────────────
    // GetCurrentCardAsync — solo lectura, nunca modifica estado
    // ──────────────────────────────────────────────────────────────────────────

    public async Task<StudentIdCardDto?> GetCurrentCardAsync(Guid studentId)
    {
        var student = await _context.Users
            .Include(x => x.StudentAssignments.Where(a => a.IsActive))
                .ThenInclude(x => x.Grade)
            .Include(x => x.StudentAssignments.Where(a => a.IsActive))
                .ThenInclude(x => x.Group)
            .Include(x => x.StudentAssignments.Where(a => a.IsActive))
                .ThenInclude(x => x.Shift)
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == studentId &&
                (x.Role == "student" || x.Role == "estudiante"));

        if (student == null) return null;

        var assignment = student.StudentAssignments.FirstOrDefault(x => x.IsActive);
        if (assignment == null) return null;

        var card = await _context.StudentIdCards
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.StudentId == studentId && x.Status == "active");

        if (card == null) return null;

        var token = await _context.StudentQrTokens
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.StudentId == studentId && !x.IsRevoked &&
                (x.ExpiresAt == null || x.ExpiresAt > DateTime.UtcNow));

        // Generar QR como data URI en el servidor para evitar dependencias de CDN en la vista
        string? qrImageDataUrl = null;
        if (token != null)
        {
            var pngBytes = QrHelper.GenerateQrPng(token.Token, _qrSignatureService);
            qrImageDataUrl = "data:image/png;base64," + Convert.ToBase64String(pngBytes);
        }

        return new StudentIdCardDto
        {
            StudentId = studentId,
            CardNumber = card.CardNumber,
            FullName = $"{student.Name} {student.LastName}",
            Grade = assignment.Grade?.Name ?? "",
            Group = assignment.Group?.Name ?? "",
            Shift = assignment.Shift?.Name ?? "N/A",
            QrToken = token?.Token ?? "",
            QrImageDataUrl = qrImageDataUrl,
            PhotoUrl = student.PhotoUrl
        };
    }

    // ──────────────────────────────────────────────────────────────────────────
    // GenerateAsync — crea nuevo carnet revocando el anterior
    // ──────────────────────────────────────────────────────────────────────────

    public async Task<StudentIdCardDto> GenerateAsync(Guid studentId, Guid createdBy)
    {
        _logger.LogInformation(
            "[StudentIdCard] GenerateAsync inicio StudentId={StudentId} CreatedBy={CreatedBy}",
            studentId, createdBy);

        // CRÍTICO-2: Transacción serializable — previene race condition con generaciones concurrentes
        using var transaction = await _context.Database.BeginTransactionAsync(IsolationLevel.Serializable);
        try
        {
            var student = await _context.Users
                .Include(x => x.StudentAssignments.Where(a => a.IsActive))
                    .ThenInclude(x => x.Grade)
                .Include(x => x.StudentAssignments.Where(a => a.IsActive))
                    .ThenInclude(x => x.Group)
                .Include(x => x.StudentAssignments.Where(a => a.IsActive))
                    .ThenInclude(x => x.Shift)
                .FirstOrDefaultAsync(x => x.Id == studentId &&
                    (x.Role == "student" || x.Role == "estudiante"));

            if (student == null)
            {
                _logger.LogWarning(
                    "[StudentIdCard] GenerateAsync estudiante no encontrado StudentId={StudentId}", studentId);
                throw new Exception("Estudiante no encontrado");
            }

            // PAY-GATE dentro de la transacción serializable — atomic check + write
            var payment = await _context.StudentPaymentAccesses
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.StudentId == studentId);

            if (payment == null || payment.CarnetStatus != "Pagado")
            {
                _logger.LogWarning(
                    "[StudentIdCard] GenerateAsync denegado: CarnetStatus={Status} StudentId={StudentId}",
                    payment?.CarnetStatus ?? "sin registro", studentId);
                throw new Exception("El estudiante no ha pagado el carnet.");
            }

            var activeAssignment = student.StudentAssignments.FirstOrDefault(x => x.IsActive);
            if (activeAssignment == null)
            {
                _logger.LogWarning(
                    "[StudentIdCard] GenerateAsync estudiante sin asignación activa StudentId={StudentId}", studentId);
                throw new Exception("Estudiante sin asignación activa");
            }

            // Revocar TODOS los carnets activos (cubre duplicados de race conditions previas)
            var existingCards = await _context.StudentIdCards
                .Where(x => x.StudentId == studentId && x.Status == "active")
                .ToListAsync();

            foreach (var ec in existingCards)
            {
                _logger.LogInformation(
                    "[StudentIdCard] Revocando carnet anterior Id={CardId} CardNumber={CardNumber}",
                    ec.Id, ec.CardNumber);
                ec.Status = "revoked";
            }

            // Revocar TODOS los tokens QR activos
            var existingTokens = await _context.StudentQrTokens
                .Where(x => x.StudentId == studentId && !x.IsRevoked)
                .ToListAsync();

            foreach (var et in existingTokens)
                et.IsRevoked = true;

            // LÓGICA-5 fix: usar CardNumberHelper centralizado (no más código duplicado)
            var cardNumber = CardNumberHelper.Generate(studentId);
            _logger.LogInformation(
                "[StudentIdCard] Nuevo carnet CardNumber={CardNumber} StudentId={StudentId}",
                cardNumber, studentId);

            var card = new StudentIdCard
            {
                StudentId = studentId,
                CardNumber = cardNumber,
                ExpiresAt = DateTime.UtcNow.AddYears(1),
                Status = "active"
            };

            // LÓGICA-6 fix: formato GUID sin guiones ("N") — consistente con PdfService
            // LÓGICA-3 fix: usar constante QrTokenValidityMonths (6 meses, igual que PdfService)
            var newToken = new StudentQrToken
            {
                StudentId = studentId,
                Token = Guid.NewGuid().ToString("N"),
                ExpiresAt = DateTime.UtcNow.AddMonths(QrTokenValidityMonths)
            };

            _context.StudentIdCards.Add(card);
            _context.StudentQrTokens.Add(newToken);

            await _context.SaveChangesAsync();
            await transaction.CommitAsync();

            _logger.LogInformation(
                "[StudentIdCard] GenerateAsync OK StudentId={StudentId} CardNumber={CardNumber}",
                studentId, cardNumber);

            // Generar QR como data URI en el servidor para evitar dependencias de CDN en la vista
            var pngBytes = QrHelper.GenerateQrPng(newToken.Token, _qrSignatureService);
            var qrImageDataUrl = "data:image/png;base64," + Convert.ToBase64String(pngBytes);

            return new StudentIdCardDto
            {
                StudentId = studentId,
                CardNumber = cardNumber,
                FullName = $"{student.Name} {student.LastName}",
                Grade = activeAssignment.Grade?.Name ?? "",
                Group = activeAssignment.Group?.Name ?? "",
                Shift = activeAssignment.Shift?.Name ?? "N/A",
                QrToken = newToken.Token,
                QrImageDataUrl = qrImageDataUrl,
                PhotoUrl = student.PhotoUrl
            };
        }
        catch
        {
            await transaction.RollbackAsync();
            throw;
        }
    }

    // ──────────────────────────────────────────────────────────────────────────
    // ScanAsync — valida QR y devuelve datos del estudiante
    // ──────────────────────────────────────────────────────────────────────────

    public async Task<ScanResultDto> ScanAsync(ScanRequestDto request)
    {
        // SEG-3: Normalizar ScanType — rechazar valores no permitidos
        var scanType = AllowedScanTypes.Contains(request.ScanType ?? "") ? request.ScanType : "entry";

        var tokenToLookup = request.Token;

        // Token firmado: validar firma HMAC antes de buscar en BD
        if (request.Token.Contains("|"))
        {
            if (!_qrSignatureService.ValidateSignedToken(request.Token))
            {
                await SaveScanLogAsync(null, scanType, "denied", request.ScannedBy);
                return DeniedResult("QR inválido o expirado");
            }
            tokenToLookup = _qrSignatureService.ExtractTokenFromSigned(request.Token) ?? request.Token;
        }

        // SCALE-1: Cargar solo datos esenciales; asignaciones en query separada
        var tokenRecord = await _context.StudentQrTokens
            .Include(x => x.Student)
                .ThenInclude(x => x.SchoolNavigation)
            .FirstOrDefaultAsync(x =>
                x.Token == tokenToLookup &&
                !x.IsRevoked &&
                (x.ExpiresAt == null || x.ExpiresAt > DateTime.UtcNow));

        if (tokenRecord == null)
        {
            await SaveScanLogAsync(null, scanType, "denied", request.ScannedBy);
            return DeniedResult("QR inválido o expirado");
        }

        // BUG-1: Verificar que el estudiante no fue eliminado (FK sin cascade delete)
        if (tokenRecord.Student == null)
        {
            _logger.LogWarning(
                "[StudentIdCard] ScanAsync token sin estudiante asociado TokenId={TokenId}", tokenRecord.Id);
            await SaveScanLogAsync(tokenRecord.StudentId, scanType, "denied", request.ScannedBy);
            return DeniedResult("Estudiante no encontrado");
        }

        // SCALE-1: Query separada y filtrada para obtener solo la asignación activa con Grade/Group
        var assignment = await _context.StudentAssignments
            .Include(a => a.Grade)
            .Include(a => a.Group)
            .AsNoTracking()
            .FirstOrDefaultAsync(a => a.StudentId == tokenRecord.StudentId && a.IsActive);

        if (assignment == null)
        {
            await SaveScanLogAsync(tokenRecord.StudentId, scanType, "denied", request.ScannedBy);
            return new ScanResultDto
            {
                Allowed = false,
                Message = "Estudiante sin asignación activa",
                StudentName = $"{tokenRecord.Student.Name} {tokenRecord.Student.LastName}",
                Grade = "N/A",
                Group = "N/A",
                DisciplineCount = 0,
                AllowedToEnterSchool = false
            };
        }

        // Cargar carnet activo
        var card = await _context.StudentIdCards
            .AsNoTracking()
            .Where(c => c.StudentId == tokenRecord.StudentId && c.Status == "active")
            .FirstOrDefaultAsync();

        // LÓGICA-2 fix: verificar que el carnet no esté vencido por fecha
        var cardExpired = card?.ExpiresAt.HasValue == true && card.ExpiresAt < DateTime.UtcNow;

        // LÓGICA-1 fix: calcular AllowedToEnterSchool ANTES de guardar el ScanLog
        // El ScanLog debe reflejar la decisión operativa real, no solo la validez del token
        var allowedToEnterSchool =
            tokenRecord.Student.Status == "active"
            && card != null
            && card.Status == "active"
            && !cardExpired;

        // LÓGICA-1 fix: ScanLog.Result refleja allowedToEnterSchool (no "allowed" siempre que el token sea válido)
        await SaveScanLogAsync(
            tokenRecord.StudentId,
            scanType,
            allowedToEnterSchool ? "allowed" : "denied",
            request.ScannedBy);

        // SCALE-3: Count de disciplina (requiere índice en discipline_reports.student_id)
        var disciplineCount = await _context.DisciplineReports
            .AsNoTracking()
            .Where(r => r.StudentId == tokenRecord.StudentId)
            .CountAsync();

        // CRÍTICO-1 fix: usar AuthenticatedRole del JWT, NUNCA el rol de ScannedBy en el body
        // AuthenticatedRole es poblado por el controller desde ClaimTypes.Role tras pasar por
        // la autenticación (Cookie o ApiBearerTokenMiddleware para la APK)
        var role = (request.AuthenticatedRole ?? "").Trim().ToLowerInvariant();
        var canSeeSensitiveData = role is "inspector" or "teacher" or "docente" or "admin" or "superadmin";

        // LÓGICA-7 fix: Allowed = AllowedToEnterSchool (decisión operativa real)
        return new ScanResultDto
        {
            Allowed = allowedToEnterSchool,
            Message = allowedToEnterSchool ? "Acceso permitido" : "Acceso denegado",
            StudentName = $"{tokenRecord.Student.Name} {tokenRecord.Student.LastName}",
            Grade = assignment.Grade?.Name ?? "N/A",
            Group = assignment.Group?.Name ?? "N/A",
            StudentId = tokenRecord.StudentId,
            DisciplineCount = disciplineCount,
            StudentPhotoUrl = tokenRecord.Student.PhotoUrl,
            SchoolName = tokenRecord.Student.SchoolNavigation?.Name,
            // SEG-1 fix: DocumentId (cédula del menor) solo visible para roles autorizados
            StudentCode = canSeeSensitiveData ? tokenRecord.Student.DocumentId : null,
            EmergencyContactName = canSeeSensitiveData ? tokenRecord.Student.EmergencyContactName : null,
            EmergencyContactPhone = canSeeSensitiveData ? tokenRecord.Student.EmergencyContactPhone : null,
            Allergies = canSeeSensitiveData ? tokenRecord.Student.Allergies : null,
            CardNumber = card?.CardNumber,
            // LÓGICA-2 fix: exponer "expired" cuando el carnet está vencido por fecha
            CardStatus = cardExpired ? "expired" : card?.Status,
            CardIssuedDate = card?.IssuedAt,
            AllowedToEnterSchool = allowedToEnterSchool
        };
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Helpers privados
    // ──────────────────────────────────────────────────────────────────────────

    private static ScanResultDto DeniedResult(string message) => new()
    {
        Allowed = false,
        Message = message,
        StudentName = "N/A",
        Grade = "N/A",
        Group = "N/A",
        DisciplineCount = 0,
        AllowedToEnterSchool = false
    };

    /// <summary>
    /// Guarda el ScanLog con manejo de error aislado.
    /// Un fallo de log nunca debe bloquear la respuesta al escáner.
    /// </summary>
    private async Task SaveScanLogAsync(Guid? studentId, string scanType, string result, Guid scannedBy)
    {
        try
        {
            _context.ScanLogs.Add(new ScanLog
            {
                StudentId = studentId,
                ScanType = scanType,
                Result = result,
                ScannedBy = scannedBy
            });
            await _context.SaveChangesAsync();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex,
                "[StudentIdCard] Error guardando ScanLog StudentId={StudentId} Result={Result}",
                studentId, result);
            // No re-lanzar: el scan fue procesado, el log es secundario
        }
    }
}
