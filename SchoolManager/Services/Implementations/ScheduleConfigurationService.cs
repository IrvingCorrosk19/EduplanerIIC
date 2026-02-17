using Microsoft.EntityFrameworkCore;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;

namespace SchoolManager.Services.Implementations;

public class ScheduleConfigurationService : IScheduleConfigurationService
{
    private readonly SchoolDbContext _context;
    private readonly IShiftService _shiftService;

    public ScheduleConfigurationService(SchoolDbContext context, IShiftService shiftService)
    {
        _context = context;
        _shiftService = shiftService;
    }

    public async Task<SchoolScheduleConfiguration?> GetBySchoolIdAsync(Guid schoolId, CancellationToken cancellationToken = default)
    {
        return await _context.SchoolScheduleConfigurations
            .AsNoTracking()
            .FirstOrDefaultAsync(c => c.SchoolId == schoolId, cancellationToken);
    }

    public async Task<(bool Success, string Message)> SaveAndGenerateBlocksAsync(SchoolScheduleConfiguration model, Guid schoolId, bool forceRegenerate = false, CancellationToken cancellationToken = default)
    {
        if (model.MorningBlockCount < 1 || model.MorningBlockDurationMinutes < 1)
            return (false, "La jornada de mañana debe tener al menos 1 bloque y duración positiva.");

        // Tarde: si pone hora de inicio, duración y cantidad deben ser ambas positivas (o ambas vacías/0 para no usar tarde)
        var hasAfternoonStart = model.AfternoonStartTime.HasValue;
        var afternoonCount = model.AfternoonBlockCount ?? 0;
        var afternoonDuration = model.AfternoonBlockDurationMinutes ?? 0;
        if (hasAfternoonStart && (afternoonCount > 0 || afternoonDuration > 0))
        {
            if (afternoonCount < 1 || afternoonDuration < 1)
                return (false, "Si configura jornada tarde, complete duración (min) y cantidad de bloques con valores mayores a 0.");
        }

        // No solapamientos: si hay tarde, debe empezar después del último bloque de mañana
        var lastMorningEnd = model.MorningStartTime.AddMinutes(model.MorningBlockCount * model.MorningBlockDurationMinutes);
        if (model.AfternoonStartTime.HasValue && model.AfternoonBlockCount.GetValueOrDefault() > 0)
        {
            if (model.AfternoonStartTime.Value < lastMorningEnd)
                return (false, "La jornada de tarde debe comenzar después del último bloque de mañana (sin solapamientos).");
        }

        var slotIds = await _context.TimeSlots
            .Where(t => t.SchoolId == schoolId)
            .Select(t => t.Id)
            .ToListAsync(cancellationToken);

        if (slotIds.Count > 0)
        {
            var hasEntries = await _context.ScheduleEntries
                .AnyAsync(e => slotIds.Contains(e.TimeSlotId), cancellationToken);
            if (hasEntries && !forceRegenerate)
                return (false, "No se puede regenerar la jornada porque ya existen horarios asignados a bloques. Marque «Forzar regeneración» si desea eliminarlos y regenerar (los docentes tendrán que volver a asignar).");
        }

        using var transaction = await _context.Database.BeginTransactionAsync(cancellationToken);
        try
        {
            // Si se fuerza regeneración, eliminar antes todas las entradas de horario de los bloques de esta escuela
            if (slotIds.Count > 0)
            {
                var entriesToRemove = await _context.ScheduleEntries
                    .Where(e => slotIds.Contains(e.TimeSlotId))
                    .ToListAsync(cancellationToken);
                if (entriesToRemove.Count > 0)
                {
                    _context.ScheduleEntries.RemoveRange(entriesToRemove);
                    await _context.SaveChangesAsync(cancellationToken);
                }
            }

            var existing = await _context.SchoolScheduleConfigurations
                .FirstOrDefaultAsync(c => c.SchoolId == schoolId, cancellationToken);

            var now = DateTime.UtcNow;
            if (existing != null)
            {
                existing.MorningStartTime = model.MorningStartTime;
                existing.MorningBlockDurationMinutes = model.MorningBlockDurationMinutes;
                existing.MorningBlockCount = model.MorningBlockCount;
                existing.AfternoonStartTime = model.AfternoonStartTime;
                existing.AfternoonBlockDurationMinutes = model.AfternoonBlockDurationMinutes;
                existing.AfternoonBlockCount = model.AfternoonBlockCount;
                existing.UpdatedAt = now;
            }
            else
            {
                _context.SchoolScheduleConfigurations.Add(new SchoolScheduleConfiguration
                {
                    Id = Guid.NewGuid(),
                    SchoolId = schoolId,
                    MorningStartTime = model.MorningStartTime,
                    MorningBlockDurationMinutes = model.MorningBlockDurationMinutes,
                    MorningBlockCount = model.MorningBlockCount,
                    AfternoonStartTime = model.AfternoonStartTime,
                    AfternoonBlockDurationMinutes = model.AfternoonBlockDurationMinutes,
                    AfternoonBlockCount = model.AfternoonBlockCount,
                    CreatedAt = now,
                    UpdatedAt = now
                });
            }

            await _context.SaveChangesAsync(cancellationToken);

            // Eliminar TimeSlots existentes de esta escuela
            var toRemove = await _context.TimeSlots
                .Where(t => t.SchoolId == schoolId)
                .ToListAsync(cancellationToken);
            _context.TimeSlots.RemoveRange(toRemove);
            await _context.SaveChangesAsync(cancellationToken);

            // Jornadas: obtener o crear Mañana y Tarde para esta escuela (se asignan a los bloques)
            var shiftManana = await _shiftService.GetOrCreateBySchoolAndNameAsync(schoolId, "Mañana");
            Shift? shiftTarde = null;
            if (model.AfternoonStartTime.HasValue && (model.AfternoonBlockCount ?? 0) > 0 && (model.AfternoonBlockDurationMinutes ?? 0) > 0)
                shiftTarde = await _shiftService.GetOrCreateBySchoolAndNameAsync(schoolId, "Tarde");

            // Generar bloques de mañana (con jornada Mañana)
            int displayOrder = 0;
            var start = model.MorningStartTime;
            for (var i = 0; i < model.MorningBlockCount; i++)
            {
                var end = start.AddMinutes(model.MorningBlockDurationMinutes);
                _context.TimeSlots.Add(new TimeSlot
                {
                    Id = Guid.NewGuid(),
                    SchoolId = schoolId,
                    ShiftId = shiftManana.Id,
                    Name = $"Bloque {i + 1}",
                    StartTime = start,
                    EndTime = end,
                    DisplayOrder = displayOrder++,
                    IsActive = true,
                    CreatedAt = now
                });
                start = end;
            }

            // Generar bloques de tarde (con jornada Tarde)
            if (shiftTarde != null && model.AfternoonStartTime.HasValue && (model.AfternoonBlockCount ?? 0) > 0 && (model.AfternoonBlockDurationMinutes ?? 0) > 0)
            {
                var count = model.AfternoonBlockCount!.Value;
                var duration = model.AfternoonBlockDurationMinutes!.Value;
                start = model.AfternoonStartTime.Value;
                for (var i = 0; i < count; i++)
                {
                    var end = start.AddMinutes(duration);
                    _context.TimeSlots.Add(new TimeSlot
                    {
                        Id = Guid.NewGuid(),
                        SchoolId = schoolId,
                        ShiftId = shiftTarde.Id,
                        Name = $"Bloque {displayOrder + 1}",
                        StartTime = start,
                        EndTime = end,
                        DisplayOrder = displayOrder++,
                        IsActive = true,
                        CreatedAt = now
                    });
                    start = end;
                }
            }

            await _context.SaveChangesAsync(cancellationToken);
            await transaction.CommitAsync(cancellationToken);
            return (true, "Configuración guardada y bloques generados correctamente.");
        }
        catch (Exception ex)
        {
            await transaction.RollbackAsync(cancellationToken);
            return (false, "Error al guardar: " + ex.Message);
        }
    }
}
