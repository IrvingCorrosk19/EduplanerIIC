using SchoolManager.Models;
using Microsoft.EntityFrameworkCore;
using SchoolManager.Dtos;
using SchoolManager.Services.Interfaces;

namespace SchoolManager.Services.Implementations
{
public class AttendanceService : IAttendanceService
{
    private readonly SchoolDbContext _context;
    private readonly ICurrentUserService _currentUserService;

    public AttendanceService(SchoolDbContext context, ICurrentUserService currentUserService)
    {
        _context = context;
        _currentUserService = currentUserService;
    }

    public async Task<List<Attendance>> GetAllAsync() =>
        await _context.Attendances.ToListAsync();

    public async Task<Attendance?> GetByIdAsync(Guid id) =>
        await _context.Attendances.FindAsync(id);

    public async Task CreateAsync(Attendance attendance)
    {
        // Configurar campos de auditoría y SchoolId
        await AuditHelper.SetAuditFieldsForCreateAsync(attendance, _currentUserService);
        await AuditHelper.SetSchoolIdAsync(attendance, _currentUserService);
        
        _context.Attendances.Add(attendance);
        await _context.SaveChangesAsync();
    }

    public async Task UpdateAsync(Attendance attendance)
    {
        // Configurar campos de auditoría para actualización
        await AuditHelper.SetAuditFieldsForUpdateAsync(attendance, _currentUserService);
        
        _context.Attendances.Update(attendance);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAsync(Guid id)
    {
        var attendance = await _context.Attendances.FindAsync(id);
        if (attendance != null)
        {
            _context.Attendances.Remove(attendance);
            await _context.SaveChangesAsync();
        }
    }

    public async Task<List<Attendance>> GetByStudentAsync(Guid studentId)
    {
        return await _context.Attendances
            .Where(a => a.StudentId == studentId)
            .ToListAsync();
    }

    public async Task<List<Attendance>> GetHistorialAsync(Guid groupId, Guid gradeId, DateOnly? fechaInicio, DateOnly? fechaFin, Guid? studentId = null)
    {
        var query = _context.Attendances
            .Where(a => a.GroupId == groupId && a.GradeId == gradeId);

        if (fechaInicio.HasValue && fechaFin.HasValue)
            query = query.Where(a => a.Date >= fechaInicio.Value && a.Date <= fechaFin.Value);
        // Si no hay fechas, no se filtra por fecha

        if (studentId.HasValue && studentId.Value != Guid.Empty)
        {
            query = query.Where(a => a.StudentId == studentId);
        }

        return await query
            .Include(a => a.Student)
            .Include(a => a.Group)
            .Include(a => a.Grade)
            .OrderBy(a => a.Date)
            .ThenBy(a => a.Student.Name)
            .ToListAsync();
    }

    public async Task<EstadisticasAsistenciaDto> GetEstadisticasAsync(Guid groupId, Guid gradeId, string trimestre, string? fechaInicioStr, string? fechaFinStr)
    {
        DateOnly? fechaInicioOnly = null;
        DateOnly? fechaFinOnly = null;
        
        // Convertir fechas string a DateOnly de forma segura
        if (!string.IsNullOrEmpty(fechaInicioStr) && DateTime.TryParse(fechaInicioStr, out DateTime fechaInicio))
        {
            fechaInicioOnly = DateOnly.FromDateTime(fechaInicio);
        }
        
        if (!string.IsNullOrEmpty(fechaFinStr) && DateTime.TryParse(fechaFinStr, out DateTime fechaFin))
        {
            fechaFinOnly = DateOnly.FromDateTime(fechaFin);
        }

        var query = _context.Attendances
            .Include(a => a.Student)
            .Where(a => a.GroupId == groupId
                && a.GradeId == gradeId
                && a.Status != null);
        
        // Aplicar filtros de fecha solo si están presentes
        if (fechaInicioOnly.HasValue)
        {
            query = query.Where(a => a.Date >= fechaInicioOnly.Value);
        }
        
        if (fechaFinOnly.HasValue)
        {
            query = query.Where(a => a.Date <= fechaFinOnly.Value);
        }
        
        var asistencias = await query.ToListAsync();

        var total = asistencias.Count;
        var totalPresentes = asistencias.Count(a => a.Status == "present");
        var totalAusentes = asistencias.Count(a => a.Status == "absent");
        var totalTardanzas = asistencias.Count(a => a.Status == "late");
        var totalFugas = asistencias.Count(a => a.Status == "fuga");
        var totalExcusas = asistencias.Count(a => a.Status == "excusa");

        decimal porcAsistencia = total > 0 ? Math.Round((decimal)totalPresentes * 100 / total, 1) : 0;
        decimal porcAusencias = total > 0 ? Math.Round((decimal)totalAusentes * 100 / total, 1) : 0;
        decimal porcTardanzas = total > 0 ? Math.Round((decimal)totalTardanzas * 100 / total, 1) : 0;
        decimal porcFugas = total > 0 ? Math.Round((decimal)totalFugas * 100 / total, 1) : 0;
        decimal porcExcusas = total > 0 ? Math.Round((decimal)totalExcusas * 100 / total, 1) : 0;

        var porEstudiante = asistencias
            .GroupBy(a => new { Name = a.Student?.Name, DocumentId = a.Student?.DocumentId })
            .Select(g => new EstadisticaEstudianteDto
            {
                Estudiante = g.Key.Name ?? "-",
                DocumentId = g.Key.DocumentId ?? "",
                Presentes = g.Count(a => a.Status == "present"),
                Ausentes = g.Count(a => a.Status == "absent"),
                Tardanzas = g.Count(a => a.Status == "late"),
                PorcentajeAsistencia = g.Count() > 0 ? Math.Round((decimal)g.Count(a => a.Status == "present") * 100 / g.Count(), 1) : 0
            })
            .OrderBy(e => e.Estudiante)
            .ToList();

        return new EstadisticasAsistenciaDto
        {
            TotalRegistros = total,
            TotalPresentes = totalPresentes,
            TotalAusentes = totalAusentes,
            TotalTardanzas = totalTardanzas,
            TotalFugas = totalFugas,
            TotalExcusas = totalExcusas,
            PorcentajeAsistencia = porcAsistencia,
            PorcentajeAusencias = porcAusencias,
            PorcentajeTardanzas = porcTardanzas,
            PorcentajeFugas = porcFugas,
            PorcentajeExcusas = porcExcusas,
            PorEstudiante = porEstudiante
        };
    }

    public async Task SaveAttendancesAsync(List<AttendanceSaveDto> attendances)
    {
        if (attendances == null || attendances.Count == 0)
            throw new ArgumentException("No se recibieron asistencias.");

        using var transaction = await _context.Database.BeginTransactionAsync();
        try
        {
            // Agrupar por fecha, grupo, grado y profesor para procesar en lotes
            var groupedAttendances = attendances.GroupBy(a => new { 
                a.Date, 
                a.GroupId, 
                a.GradeId, 
                a.TeacherId 
            });

            foreach (var group in groupedAttendances)
            {
                var key = group.Key;
                
                Console.WriteLine($"[ATTENDANCE-SERVICE] Procesando asistencias para fecha: {key.Date}, grupo: {key.GroupId}, grado: {key.GradeId}, profesor: {key.TeacherId}");
                
                // 1. ELIMINAR registros existentes para esa fecha, grupo, grado y profesor
                var existingAttendances = await _context.Attendances
                    .Where(a => a.Date == key.Date 
                             && a.GroupId == key.GroupId 
                             && a.GradeId == key.GradeId 
                             && a.TeacherId == key.TeacherId)
                    .ToListAsync();
                
                if (existingAttendances.Any())
                {
                    Console.WriteLine($"[ATTENDANCE-SERVICE] Eliminando {existingAttendances.Count} registros existentes");
                    _context.Attendances.RemoveRange(existingAttendances);
                }
                
                // 2. CREAR nuevos registros
                foreach (var dto in group)
                {
                    var attendance = new Attendance
                    {
                        Id = Guid.NewGuid(),
                        StudentId = dto.StudentId,
                        TeacherId = dto.TeacherId,
                        GroupId = dto.GroupId,
                        GradeId = dto.GradeId,
                        Date = dto.Date,
                        Status = dto.Status,
                        CreatedAt = DateTime.UtcNow
                    };
                    
                    // Configurar campos de auditoría y SchoolId
                    await AuditHelper.SetAuditFieldsForCreateAsync(attendance, _currentUserService);
                    await AuditHelper.SetSchoolIdAsync(attendance, _currentUserService);
                    
                    _context.Attendances.Add(attendance);
                }
                
                Console.WriteLine($"[ATTENDANCE-SERVICE] Creando {group.Count()} nuevos registros");
            }
            
            await _context.SaveChangesAsync();
            await transaction.CommitAsync();
            
            Console.WriteLine($"[ATTENDANCE-SERVICE] Asistencias guardadas exitosamente sin duplicados");
        }
        catch (Exception ex)
        {
            await transaction.RollbackAsync();
            Console.WriteLine($"[ATTENDANCE-SERVICE] Error al guardar asistencias: {ex.Message}");
            throw;
        }
    }

    public async Task<List<AttendanceResponseDto>> GetAttendancesByDateAsync(Guid groupId, Guid gradeId, DateOnly date)
    {
        return await _context.Attendances
            .Where(a => a.GroupId == groupId && a.GradeId == gradeId && a.Date == date)
            .Include(a => a.Student)
            .Select(a => new AttendanceResponseDto
            {
                StudentId = a.StudentId ?? Guid.Empty,
                StudentName = a.Student != null ? $"{a.Student.Name} {a.Student.LastName}" : "",
                Status = a.Status,
                Date = a.Date
            })
            .ToListAsync();
    }

    public async Task<List<object>> GetHistorialAsistenciaAsync(HistorialAsistenciaFiltroDto filtro)
    {
        if (filtro == null || filtro.GroupId == Guid.Empty || filtro.GradeId == Guid.Empty)
            throw new ArgumentException("Faltan datos para la consulta.");

        var studentId = string.IsNullOrEmpty(filtro.StudentId) ? (Guid?)null : Guid.Parse(filtro.StudentId);
        
        // Convertir fechas string a DateOnly de forma segura
        DateOnly? fechaInicio = null;
        DateOnly? fechaFin = null;
        
        if (!string.IsNullOrEmpty(filtro.FechaInicio) && DateTime.TryParse(filtro.FechaInicio, out DateTime fechaInicioDateTime))
        {
            fechaInicio = DateOnly.FromDateTime(fechaInicioDateTime);
        }
        
        if (!string.IsNullOrEmpty(filtro.FechaFin) && DateTime.TryParse(filtro.FechaFin, out DateTime fechaFinDateTime))
        {
            fechaFin = DateOnly.FromDateTime(fechaFinDateTime);
        }
        
        var lista = await GetHistorialAsync(
            filtro.GroupId,
            filtro.GradeId,
            fechaInicio,
            fechaFin,
            studentId
        );

        var resultado = lista.Select(a => new {
            estudiante = a.Student?.Name,
            documentId = a.Student?.DocumentId,
            fecha = a.Date.ToString("yyyy-MM-dd"),
            estado = a.Status,
            grupo = a.Group?.Name,
            grado = a.Grade?.Name
        }).ToList<object>();

        return resultado;
    }
}
}
