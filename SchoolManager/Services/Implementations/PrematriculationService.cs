using Microsoft.EntityFrameworkCore;
using SchoolManager.Dtos;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using SchoolManager.ViewModels;

namespace SchoolManager.Services.Implementations;

public class PrematriculationService : IPrematriculationService
{
    private readonly SchoolDbContext _context;
    private readonly ILogger<PrematriculationService> _logger;
    private readonly IEmailService? _emailService;
    private readonly IMessagingService? _messagingService;
    private const decimal NOTA_MINIMA_APROBACION = 3.0m;

    public PrematriculationService(
        SchoolDbContext context,
        ILogger<PrematriculationService> logger,
        IEmailService? emailService = null,
        IMessagingService? messagingService = null)
    {
        _context = context;
        _logger = logger;
        _emailService = emailService;
        _messagingService = messagingService;
    }

    public async Task<Prematriculation?> GetByIdAsync(Guid id)
    {
        return await _context.Prematriculations
            .Include(p => p.Student)
            .Include(p => p.Parent)
            .Include(p => p.Grade)
            .Include(p => p.Group)
            .Include(p => p.PrematriculationPeriod)
            .Include(p => p.Payments)
            .FirstOrDefaultAsync(p => p.Id == id);
    }

    public async Task<Prematriculation?> GetByCodeAsync(string code)
    {
        return await _context.Prematriculations
            .Include(p => p.Student)
            .Include(p => p.Parent)
            .Include(p => p.Grade)
            .Include(p => p.Group)
            .Include(p => p.PrematriculationPeriod)
            .Include(p => p.Payments)
            .FirstOrDefaultAsync(p => p.PrematriculationCode == code);
    }

    public async Task<List<PrematriculationDto>> GetByStudentAsync(Guid studentId)
    {
        return await _context.Prematriculations
            .Where(p => p.StudentId == studentId)
            .Include(p => p.Grade)
            .Include(p => p.Group)
            .Include(p => p.Parent)
            .Include(p => p.Payments)
            .OrderByDescending(p => p.CreatedAt)
            .Select(p => new PrematriculationDto
            {
                Id = p.Id,
                SchoolId = p.SchoolId,
                StudentId = p.StudentId,
                StudentName = $"{p.Student.Name} {p.Student.LastName}",
                StudentDocumentId = p.Student.DocumentId ?? "",
                ParentId = p.ParentId,
                ParentName = p.Parent != null ? $"{p.Parent.Name} {p.Parent.LastName}" : null,
                GradeId = p.GradeId,
                GradeName = p.Grade != null ? p.Grade.Name : null,
                GroupId = p.GroupId,
                GroupName = p.Group != null ? p.Group.Name : null,
                PrematriculationPeriodId = p.PrematriculationPeriodId,
                Status = p.Status,
                FailedSubjectsCount = p.FailedSubjectsCount,
                AcademicConditionValid = p.AcademicConditionValid,
                RejectionReason = p.RejectionReason,
                PrematriculationCode = p.PrematriculationCode,
                CreatedAt = p.CreatedAt,
                PaymentDate = p.PaymentDate,
                MatriculationDate = p.MatriculationDate,
                Payments = p.Payments.Select(pay => new PaymentDto
                {
                    Id = pay.Id,
                    Amount = pay.Amount,
                    ReceiptNumber = pay.ReceiptNumber,
                    PaymentStatus = pay.PaymentStatus,
                    PaymentDate = pay.PaymentDate,
                    CreatedAt = pay.CreatedAt
                }).ToList()
            })
            .ToListAsync();
    }

    public async Task<List<PrematriculationDto>> GetByParentAsync(Guid parentId)
    {
        return await _context.Prematriculations
            .Where(p => p.ParentId == parentId)
            .Include(p => p.Student)
            .Include(p => p.Grade)
            .Include(p => p.Group)
            .Include(p => p.Payments)
            .OrderByDescending(p => p.CreatedAt)
            .Select(p => new PrematriculationDto
            {
                Id = p.Id,
                SchoolId = p.SchoolId,
                StudentId = p.StudentId,
                StudentName = $"{p.Student.Name} {p.Student.LastName}",
                StudentDocumentId = p.Student.DocumentId ?? "",
                GradeId = p.GradeId,
                GradeName = p.Grade != null ? p.Grade.Name : null,
                GroupId = p.GroupId,
                GroupName = p.Group != null ? p.Group.Name : null,
                PrematriculationPeriodId = p.PrematriculationPeriodId,
                Status = p.Status,
                FailedSubjectsCount = p.FailedSubjectsCount,
                AcademicConditionValid = p.AcademicConditionValid,
                PrematriculationCode = p.PrematriculationCode,
                CreatedAt = p.CreatedAt,
                PaymentDate = p.PaymentDate,
                MatriculationDate = p.MatriculationDate
            })
            .ToListAsync();
    }

    public async Task<List<PrematriculationDto>> GetByGroupAsync(Guid groupId)
    {
        return await _context.Prematriculations
            .Where(p => p.GroupId == groupId && (p.Status == "Prematriculado" || p.Status == "Matriculado"))
            .Include(p => p.Student)
            .Include(p => p.Grade)
            .Include(p => p.Group)
            .OrderBy(p => p.Student.Name)
            .Select(p => new PrematriculationDto
            {
                Id = p.Id,
                StudentId = p.StudentId,
                StudentName = $"{p.Student.Name} {p.Student.LastName}",
                StudentDocumentId = p.Student.DocumentId ?? "",
                Status = p.Status,
                PrematriculationCode = p.PrematriculationCode
            })
            .ToListAsync();
    }

    public async Task<List<PrematriculationDto>> GetByPeriodAsync(Guid periodId)
    {
        return await _context.Prematriculations
            .Where(p => p.PrematriculationPeriodId == periodId)
            .Include(p => p.Student)
            .Include(p => p.Grade)
            .Include(p => p.Group)
            .Include(p => p.Parent)
            .OrderByDescending(p => p.CreatedAt)
            .Select(p => new PrematriculationDto
            {
                Id = p.Id,
                StudentId = p.StudentId,
                StudentName = $"{p.Student.Name} {p.Student.LastName}",
                Status = p.Status,
                PrematriculationCode = p.PrematriculationCode,
                CreatedAt = p.CreatedAt
            })
            .ToListAsync();
    }

    public async Task<List<AvailableGroupsDto>> GetAvailableGroupsAsync(Guid schoolId, Guid? gradeId)
    {
        var query = _context.Groups.Where(g => g.SchoolId == schoolId);
        
        if (gradeId.HasValue)
        {
            // Filtrar por grado si se especifica
            query = query.Where(g => _context.SubjectAssignments
                .Any(sa => sa.GroupId == g.Id && sa.GradeLevelId == gradeId.Value));
        }

        var groups = await query
            .Include(g => g.StudentAssignments)
            .ToListAsync();

        var result = new List<AvailableGroupsDto>();

        foreach (var group in groups)
        {
            // Usar los StudentAssignments ya cargados en memoria en lugar de hacer consultas adicionales
            var currentStudents = group.StudentAssignments?.Count ?? 0;

            var availableSpots = (group.MaxCapacity ?? int.MaxValue) - currentStudents;
            
            result.Add(new AvailableGroupsDto
            {
                GroupId = group.Id,
                GroupName = group.Name,
                GradeName = group.Grade,
                Shift = group.Shift, // Incluir jornada del grupo
                CurrentStudents = currentStudents,
                MaxCapacity = group.MaxCapacity,
                AvailableSpots = Math.Max(0, availableSpots),
                IsAvailable = availableSpots > 0
            });
        }

        return result.OrderBy(g => g.GroupName).ToList();
    }

    public async Task<int> GetFailedSubjectsCountAsync(Guid studentId)
    {
        // Obtener todas las calificaciones del estudiante
        var scores = await _context.StudentActivityScores
            .Include(s => s.Activity)
            .Where(s => s.StudentId == studentId && s.Activity != null)
            .ToListAsync();

        if (!scores.Any())
            return 0;

        // Agrupar por materia y calcular promedio
        var materias = scores
            .Where(s => s.Activity!.SubjectId.HasValue)
            .GroupBy(s => s.Activity!.SubjectId!.Value)
            .Select(g => new
            {
                SubjectId = g.Key,
                PromedioMateria = g.Average(s => (decimal)(s.Score ?? 0))
            })
            .ToList();

        // Contar materias reprobadas (promedio < 3.0)
        return materias.Count(m => m.PromedioMateria < NOTA_MINIMA_APROBACION);
    }

    public async Task<Prematriculation> CreatePrematriculationAsync(PrematriculationCreateDto dto, Guid? parentId)
    {
        // Obtener el período de prematrícula activo
        var period = await _context.PrematriculationPeriods
            .FirstOrDefaultAsync(p => p.Id == dto.PrematriculationPeriodId);

        if (period == null)
            throw new Exception("Período de prematrícula no encontrado");

        // Verificar que el período esté activo
        var now = DateTime.UtcNow;
        if (!period.IsActive || period.StartDate > now || period.EndDate < now)
            throw new Exception("El período de prematrícula no está disponible");

        // Obtener información del estudiante y su escuela
        var student = await _context.Users
            .Include(u => u.SchoolNavigation)
            .FirstOrDefaultAsync(u => u.Id == dto.StudentId);

        if (student == null)
            throw new Exception("Estudiante no encontrado");

        var schoolId = student.SchoolId ?? throw new Exception("Estudiante no tiene escuela asignada");

        // Verificar que el estudiante pertenezca a la escuela del período
        if (period.SchoolId != schoolId)
            throw new Exception("El estudiante no pertenece a la escuela del período");

        // Validar condición académica
        var failedSubjects = await GetFailedSubjectsCountAsync(dto.StudentId);
        var academicConditionValid = failedSubjects <= 3;

        if (!academicConditionValid)
        {
            throw new Exception("El estudiante no puede participar en la prematrícula por exceder el límite de materias reprobadas");
        }

        // Generar código de prematrícula
        var prematriculationCode = await GeneratePrematriculationCodeAsync();

        // Crear la prematrícula
        var prematriculation = new Prematriculation
        {
            Id = Guid.NewGuid(),
            SchoolId = schoolId,
            StudentId = dto.StudentId,
            ParentId = parentId,
            GradeId = dto.GradeId,
            GroupId = dto.GroupId,
            PrematriculationPeriodId = dto.PrematriculationPeriodId,
            Status = "Pendiente",
            FailedSubjectsCount = failedSubjects,
            AcademicConditionValid = academicConditionValid,
            PrematriculationCode = prematriculationCode,
            CreatedAt = DateTime.UtcNow
        };

        // Si se especificó un grupo, verificar cupo
        if (dto.GroupId.HasValue)
        {
            var hasCapacity = await CheckGroupCapacityAsync(dto.GroupId.Value);
            if (!hasCapacity)
                throw new Exception("El grupo seleccionado no tiene cupos disponibles");
        }

        _context.Prematriculations.Add(prematriculation);
        await _context.SaveChangesAsync();

        // Si está habilitada la asignación automática, asignar grupo después de crear
        if (period.AutoAssignByShift && !dto.GroupId.HasValue && dto.GradeId.HasValue)
        {
            try
            {
                var assignedGroup = await AutoAssignGroupAsync(prematriculation.Id);
                if (assignedGroup.GroupId.HasValue)
                {
                    prematriculation.GroupId = assignedGroup.GroupId;
                    _context.Prematriculations.Update(prematriculation);
                    await _context.SaveChangesAsync();
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "No se pudo asignar grupo automáticamente para prematrícula {PrematriculationId}", prematriculation.Id);
            }
        }

        // Actualizar estado a Prematriculado si todo está bien
        if (prematriculation.Status == "Pendiente")
        {
            prematriculation.Status = "Prematriculado";
            _context.Prematriculations.Update(prematriculation);
            await _context.SaveChangesAsync();
        }

        _logger.LogInformation("Prematrícula creada: {PrematriculationId} para estudiante {StudentId}", 
            prematriculation.Id, dto.StudentId);

        return prematriculation;
    }

    public async Task<Prematriculation> AutoAssignGroupAsync(Guid prematriculationId)
    {
        var prematriculation = await _context.Prematriculations
            .Include(p => p.Grade)
            .Include(p => p.PrematriculationPeriod)
            .Include(p => p.Student)
            .FirstOrDefaultAsync(p => p.Id == prematriculationId);

        if (prematriculation == null || !prematriculation.GradeId.HasValue)
            throw new Exception("Prematrícula o grado no válido");

        // Obtener grupos disponibles para el grado
        var availableGroups = await GetAvailableGroupsAsync(
            prematriculation.SchoolId, 
            prematriculation.GradeId);

        // Filtrar solo los que tienen cupos
        var groupsWithCapacity = availableGroups
            .Where(g => g.IsAvailable)
            .ToList();

        if (!groupsWithCapacity.Any())
            throw new Exception("No hay grupos disponibles con cupos para asignar");

        // Si el período tiene asignación automática por jornada y el estudiante tiene jornada
        var period = prematriculation.PrematriculationPeriod;
        var studentShift = prematriculation.Student?.Shift;

        if (period.AutoAssignByShift && !string.IsNullOrEmpty(studentShift))
        {
            // Obtener grupos con la misma jornada directamente de la base de datos
            var groupsWithSameShiftIds = await _context.Groups
                .Where(g => g.SchoolId == prematriculation.SchoolId && 
                           !string.IsNullOrEmpty(g.Shift) &&
                           g.Shift.ToLower() == studentShift.ToLower())
                .Select(g => g.Id)
                .ToListAsync();

            // Filtrar grupos disponibles que tienen la misma jornada
            var groupsWithSameShift = groupsWithCapacity
                .Where(g => groupsWithSameShiftIds.Contains(g.GroupId))
                .OrderBy(g => g.CurrentStudents)
                .ToList();

            if (groupsWithSameShift.Any())
            {
                var assignedGroupSameShift = groupsWithSameShift.First();
                prematriculation.GroupId = assignedGroupSameShift.GroupId;
                prematriculation.UpdatedAt = DateTime.UtcNow;

                _context.Prematriculations.Update(prematriculation);
                await _context.SaveChangesAsync();

                _logger.LogInformation("Grupo {GroupId} (jornada {Shift}) asignado automáticamente a prematrícula {PrematriculationId} manteniendo la jornada del estudiante", 
                    assignedGroupSameShift.GroupId, studentShift, prematriculationId);

                return prematriculation;
            }
            else
            {
                _logger.LogWarning("No hay grupos disponibles con la jornada {Shift} del estudiante, se asignará cualquier grupo disponible", 
                    studentShift);
            }
        }

        // Si no hay grupos con la misma jornada o no se requiere asignación por jornada,
        // asignar el grupo con menos estudiantes
        var assignedGroupAny = groupsWithCapacity
            .OrderBy(g => g.CurrentStudents)
            .First();
        
        prematriculation.GroupId = assignedGroupAny.GroupId;
        prematriculation.UpdatedAt = DateTime.UtcNow;

        _context.Prematriculations.Update(prematriculation);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Grupo {GroupId} asignado automáticamente a prematrícula {PrematriculationId}", 
            assignedGroupAny.GroupId, prematriculationId);

        return prematriculation;
    }

    public async Task<bool> ValidateAcademicConditionAsync(Guid studentId)
    {
        var failedSubjects = await GetFailedSubjectsCountAsync(studentId);
        return failedSubjects <= 3;
    }

    public async Task<Prematriculation> ConfirmMatriculationAsync(Guid prematriculationId)
    {
        var prematriculation = await _context.Prematriculations
            .Include(p => p.Payments)
            .Include(p => p.Student)
            .Include(p => p.Grade)
            .Include(p => p.Group)
            .Include(p => p.PrematriculationPeriod)
            .FirstOrDefaultAsync(p => p.Id == prematriculationId);

        if (prematriculation == null)
            throw new Exception("Prematrícula no encontrada");

        // Validar que el estado permita la confirmación de matrícula
        if (prematriculation.Status == "Matriculado")
            throw new Exception("La matrícula ya está confirmada");

        if (prematriculation.Status == "Rechazado")
            throw new Exception("No se puede confirmar una prematrícula rechazada");

        if (prematriculation.Status == "Cancelado")
            throw new Exception("No se puede confirmar una prematrícula cancelada");

        // ASIGNACIÓN AUTOMÁTICA DE GRADO Y GRUPO si no están asignados

        // Función helper para extraer número del grado (ej: "5°" -> 5)
        int? ExtractGradeNumber(string? gradeName)
        {
            if (string.IsNullOrEmpty(gradeName))
                return null;
            
            var match = System.Text.RegularExpressions.Regex.Match(gradeName, @"(\d+)");
            if (match.Success && int.TryParse(match.Value, out int gradeNum))
                return gradeNum;
            
            return null;
        }

        // Asignar grado automáticamente si no está asignado
        if (!prematriculation.GradeId.HasValue)
        {
            // Obtener el grado actual del estudiante
            var currentGrade = await _context.StudentAssignments
                .Where(sa => sa.StudentId == prematriculation.StudentId)
                .OrderByDescending(sa => sa.CreatedAt)
                .Include(sa => sa.Grade)
                .Select(sa => sa.Grade)
                .FirstOrDefaultAsync();

            if (currentGrade != null)
            {
                var currentGradeNum = ExtractGradeNumber(currentGrade.Name);
                var allGrades = await _context.GradeLevels.ToListAsync();

                if (currentGradeNum.HasValue)
                {
                    // Buscar el siguiente nivel o el mismo (repetir)
                    var nextGrade = allGrades.FirstOrDefault(g =>
                    {
                        var gradeNum = ExtractGradeNumber(g.Name);
                        return gradeNum.HasValue && gradeNum.Value == currentGradeNum.Value + 1; // Siguiente
                    });

                    if (nextGrade != null)
                    {
                        prematriculation.GradeId = nextGrade.Id;
                        _logger.LogInformation("Grado {GradeName} asignado automáticamente al estudiante {StudentId} (siguiente nivel desde {CurrentGrade})",
                            nextGrade.Name, prematriculation.StudentId, currentGrade.Name);
                    }
                    else
                    {
                        // Si no hay siguiente nivel, asignar el mismo (repetir)
                        prematriculation.GradeId = currentGrade.Id;
                        _logger.LogInformation("Grado {GradeName} asignado automáticamente al estudiante {StudentId} (repetir mismo grado)",
                            currentGrade.Name, prematriculation.StudentId);
                    }
                }
                else
                {
                    // Si no se puede extraer el número, usar el primer grado disponible
                    var firstGrade = allGrades.FirstOrDefault();
                    if (firstGrade != null)
                    {
                        prematriculation.GradeId = firstGrade.Id;
                        _logger.LogWarning("No se pudo determinar el siguiente grado para {StudentId}, se asignó el primer grado disponible {GradeName}",
                            prematriculation.StudentId, firstGrade.Name);
                    }
                }
            }
            else
            {
                // Si no tiene grado actual (estudiante nuevo), usar el primer grado disponible
                var allGrades = await _context.GradeLevels.ToListAsync();
                var firstGrade = allGrades.OrderBy(g =>
                {
                    var num = ExtractGradeNumber(g.Name);
                    return num ?? int.MaxValue; // Ordenar por número, los que no tienen número al final
                }).FirstOrDefault();

                if (firstGrade != null)
                {
                    prematriculation.GradeId = firstGrade.Id;
                    _logger.LogInformation("Grado {GradeName} asignado automáticamente al estudiante nuevo {StudentId}",
                        firstGrade.Name, prematriculation.StudentId);
                }
            }

            if (prematriculation.GradeId.HasValue)
            {
                prematriculation.UpdatedAt = DateTime.UtcNow;
                _context.Prematriculations.Update(prematriculation);
                await _context.SaveChangesAsync();
            }
        }

        // Validar que tenga grado asignado (después de intentar asignar automáticamente)
        if (!prematriculation.GradeId.HasValue)
            throw new Exception("No se puede confirmar la matrícula sin un grado asignado. No se pudo asignar un grado automáticamente.");

        // Asignar grupo automáticamente si no está asignado
        if (!prematriculation.GroupId.HasValue && prematriculation.GradeId.HasValue)
        {
            try
            {
                await AutoAssignGroupAsync(prematriculationId);
                
                // Recargar la prematrícula para obtener el grupo asignado
                prematriculation = await _context.Prematriculations
                    .Include(p => p.Payments)
                    .Include(p => p.Student)
                    .Include(p => p.Grade)
                    .Include(p => p.Group)
                    .Include(p => p.PrematriculationPeriod)
                    .FirstOrDefaultAsync(p => p.Id == prematriculationId);
                
                _logger.LogInformation("Grupo asignado automáticamente a la prematrícula {PrematriculationId}",
                    prematriculationId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al asignar grupo automáticamente para prematrícula {PrematriculationId}",
                    prematriculationId);
                throw new Exception($"No se puede confirmar la matrícula. No se pudo asignar un grupo automáticamente: {ex.Message}");
            }
        }

        // Validar que tenga grupo asignado (después de intentar asignar automáticamente)
        if (!prematriculation.GroupId.HasValue)
            throw new Exception("No se puede confirmar la matrícula sin un grupo asignado. No se pudo asignar un grupo automáticamente.");

        // Validar condición académica NUEVAMENTE antes de confirmar la matrícula
        // (las notas pueden haber cambiado desde la creación de la prematrícula)
        var failedSubjects = await GetFailedSubjectsCountAsync(prematriculation.StudentId);
        var academicConditionValid = failedSubjects <= 3;

        if (!academicConditionValid)
        {
            // Actualizar el registro de la prematrícula con la condición académica actualizada
            prematriculation.FailedSubjectsCount = failedSubjects;
            prematriculation.AcademicConditionValid = false;
            prematriculation.Status = "Rechazado";
            prematriculation.RejectionReason = $"El estudiante excede el límite de materias reprobadas ({failedSubjects} materias reprobadas, máximo permitido: 3)";
            prematriculation.UpdatedAt = DateTime.UtcNow;
            _context.Prematriculations.Update(prematriculation);
            await _context.SaveChangesAsync();

            throw new Exception($"No se puede confirmar la matrícula. El estudiante tiene {failedSubjects} materias reprobadas (máximo permitido: 3).");
        }

        // Actualizar el conteo de materias reprobadas en caso de que haya cambiado
        prematriculation.FailedSubjectsCount = failedSubjects;
        prematriculation.AcademicConditionValid = academicConditionValid;

        // Verificar que tenga un pago confirmado
        var hasConfirmedPayment = prematriculation.Payments.Any(p => p.PaymentStatus == "Confirmado");

        if (!hasConfirmedPayment)
            throw new Exception("No se puede confirmar la matrícula sin un pago confirmado");

        // Validar que el grupo tenga cupos disponibles
        var hasCapacity = await CheckGroupCapacityAsync(prematriculation.GroupId.Value);
        if (!hasCapacity)
        {
            // Revisar si hay cupos considerando prematrículas reservadas
            var group = await _context.Groups
                .Include(g => g.StudentAssignments)
                .FirstOrDefaultAsync(g => g.Id == prematriculation.GroupId.Value);

            if (group != null)
            {
                var currentStudents = group.StudentAssignments?.Count ?? 0;
                
                // Contar prematrículas que reservan cupos (excluyendo la actual si no está matriculada)
                var reservedSpots = await _context.Prematriculations
                    .CountAsync(p => p.GroupId == prematriculation.GroupId.Value
                        && p.Id != prematriculationId
                        && (p.Status == "Prematriculado" || p.Status == "Pagado" || p.Status == "Matriculado"));

                var totalOccupied = currentStudents + reservedSpots;
                var maxCapacity = group.MaxCapacity ?? int.MaxValue;
                var availableSpots = maxCapacity - totalOccupied;

                if (availableSpots <= 0)
                    throw new Exception("El grupo no tiene cupos disponibles para matricular al estudiante");
            }
        }

        // Actualizar estado a Matriculado
        prematriculation.Status = "Matriculado";
        prematriculation.MatriculationDate = DateTime.UtcNow;
        prematriculation.UpdatedAt = DateTime.UtcNow;

        // Crear o actualizar la asignación del estudiante al grupo
        if (prematriculation.GroupId.HasValue && prematriculation.GradeId.HasValue)
        {
            var existingAssignment = await _context.StudentAssignments
                .FirstOrDefaultAsync(sa => sa.StudentId == prematriculation.StudentId 
                    && sa.GroupId == prematriculation.GroupId.Value);

            if (existingAssignment == null)
            {
                var assignment = new StudentAssignment
                {
                    Id = Guid.NewGuid(),
                    StudentId = prematriculation.StudentId,
                    GradeId = prematriculation.GradeId.Value,
                    GroupId = prematriculation.GroupId.Value,
                    CreatedAt = DateTime.UtcNow
                };
                _context.StudentAssignments.Add(assignment);
            }
        }

        _context.Prematriculations.Update(prematriculation);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Matrícula confirmada para prematrícula {PrematriculationId}", prematriculationId);

        // Enviar email de confirmación al acudiente
        if (_emailService != null)
        {
            try
            {
                var emailSent = await _emailService.SendMatriculationConfirmationEmailAsync(prematriculationId);
                if (emailSent)
                {
                    _logger.LogInformation("Email de confirmación de matrícula enviado exitosamente para prematrícula {PrematriculationId}", prematriculationId);
                }
                else
                {
                    _logger.LogWarning("No se pudo enviar email de confirmación de matrícula para prematrícula {PrematriculationId}", prematriculationId);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al enviar email de confirmación de matrícula para prematrícula {PrematriculationId}", prematriculationId);
                // No lanzar excepción para que la matrícula se complete aunque falle el email
            }
        }

        // Enviar notificación en plataforma al acudiente o estudiante
        if (_messagingService != null && prematriculation != null)
        {
            try
            {
                // Obtener el usuario destinatario (acudiente o estudiante)
                Guid? recipientId = null;
                if (prematriculation.ParentId.HasValue)
                {
                    recipientId = prematriculation.ParentId.Value;
                }
                else if (prematriculation.StudentId != Guid.Empty)
                {
                    recipientId = prematriculation.StudentId;
                }

                // Obtener el ID del administrador del sistema o de la escuela como remitente
                var adminUser = await _context.Users
                    .Where(u => (u.Role.ToLower() == "admin" || u.Role.ToLower() == "superadmin") 
                        && u.SchoolId == prematriculation.SchoolId)
                    .FirstOrDefaultAsync();

                if (recipientId.HasValue && adminUser != null)
                {
                    var studentName = prematriculation.Student != null ? 
                        $"{prematriculation.Student.Name} {prematriculation.Student.LastName}" : "Estudiante";
                    var prematriculationCode = prematriculation.PrematriculationCode ?? "N/A";

                    var messageModel = new SchoolManager.ViewModels.SendMessageViewModel
                    {
                        RecipientType = "Individual",
                        RecipientId = recipientId,
                        Subject = $"✅ Matrícula Confirmada - {studentName}",
                        Content = $@"
<h3>🎓 Confirmación de Matrícula</h3>
<p>Estimado/a acudiente/estudiante,</p>
<p>Nos complace informarle que la matrícula de <strong>{studentName}</strong> ha sido confirmada exitosamente.</p>

<h4>📋 Información de la Matrícula:</h4>
<ul>
    <li><strong>Código de Prematrícula:</strong> {prematriculationCode}</li>
    <li><strong>Estudiante:</strong> {studentName}</li>
    <li><strong>Grado:</strong> {prematriculation.Grade?.Name ?? "No asignado"}</li>
    <li><strong>Grupo:</strong> {prematriculation.Group?.Name ?? "No asignado"}</li>
    <li><strong>Fecha de Matrícula:</strong> {prematriculation.MatriculationDate?.ToString("dd/MM/yyyy HH:mm") ?? DateTime.UtcNow.ToString("dd/MM/yyyy HH:mm")}</li>
</ul>

<p>Puede consultar más detalles y descargar el comprobante de matrícula desde la plataforma.</p>

<p><strong>¡Bienvenido al nuevo año académico!</strong></p>
"
                    };

                    var notificationSent = await _messagingService.SendMessageAsync(messageModel, adminUser.Id);
                    if (notificationSent)
                    {
                        _logger.LogInformation("Notificación en plataforma enviada exitosamente para prematrícula {PrematriculationId}", prematriculationId);
                    }
                    else
                    {
                        _logger.LogWarning("No se pudo enviar notificación en plataforma para prematrícula {PrematriculationId}", prematriculationId);
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al enviar notificación en plataforma para prematrícula {PrematriculationId}", prematriculationId);
                // No lanzar excepción para que la matrícula se complete aunque falle la notificación
            }
        }

        return prematriculation;
    }

    public async Task<bool> CheckGroupCapacityAsync(Guid groupId)
    {
        var group = await _context.Groups.FindAsync(groupId);
        if (group == null)
            return false;

        var currentStudents = await _context.StudentAssignments
            .CountAsync(sa => sa.GroupId == groupId);

        var maxCapacity = group.MaxCapacity ?? int.MaxValue;
        return currentStudents < maxCapacity;
    }

    public async Task<string> GeneratePrematriculationCodeAsync()
    {
        string code;
        bool isUnique = false;
        
        do
        {
            // Generar código: PRE-YYYYMMDD-HHMMSS-RANDOM
            var now = DateTime.UtcNow;
            var random = new Random().Next(1000, 9999);
            code = $"PRE-{now:yyyyMMdd}-{now:HHmmss}-{random}";
            
            isUnique = !await _context.Prematriculations
                .AnyAsync(p => p.PrematriculationCode == code);
        } while (!isUnique);

        return code;
    }
}

