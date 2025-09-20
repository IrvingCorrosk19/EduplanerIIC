using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using SchoolManager.Dtos;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;

namespace SchoolManager.Services
{
    public class OrientationReportService : IOrientationReportService
    {
        private readonly SchoolDbContext _context;

        public OrientationReportService(SchoolDbContext context)
        {
            _context = context;
        }

        public async Task<List<OrientationReport>> GetAllAsync() =>
            await _context.OrientationReports.ToListAsync();

        public async Task<OrientationReport?> GetByIdAsync(Guid? id)
        {
            if (!id.HasValue)
                return null;
            
            return await _context.OrientationReports.FindAsync(id.Value);
        }

        public async Task CreateAsync(OrientationReport report)
        {
            report.CreatedAt = DateTime.UtcNow;
            _context.OrientationReports.Add(report);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(OrientationReport report)
        {
            report.UpdatedAt = DateTime.UtcNow;
            _context.OrientationReports.Update(report);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(Guid id)
        {
            var report = await _context.OrientationReports.FindAsync(id);
            if (report != null)
            {
                _context.OrientationReports.Remove(report);
                await _context.SaveChangesAsync();
            }
        }

        public async Task<List<OrientationReport>> GetByStudentAsync(Guid studentId)
        {
            return await _context.OrientationReports
                .Where(r => r.StudentId == studentId)
                .ToListAsync();
        }

        public async Task<List<OrientationReport>> GetFilteredAsync(DateTime? fechaInicio, DateTime? fechaFin, Guid? gradoId, Guid? groupId = null, Guid? studentId = null)
        {
            Console.WriteLine($"🔍 [ORIENTACION-SERVICE] Filtros: grado={gradoId}, grupo={groupId}, estudiante={studentId}, fechas={fechaInicio} a {fechaFin}");
            
            var query = _context.OrientationReports
                .Include(r => r.Student)
                .Include(r => r.Teacher)
                .Include(r => r.Group)
                .Include(r => r.GradeLevel)
                .AsQueryable();

            // Filtros obligatorios
            if (gradoId.HasValue)
            {
                query = query.Where(r => r.GradeLevelId == gradoId);
                Console.WriteLine($"🎯 [ORIENTACION-SERVICE] Filtro grado: {gradoId}");
            }

            // Filtros opcionales
            if (groupId.HasValue)
            {
                query = query.Where(r => r.GroupId == groupId);
                Console.WriteLine($"👥 [ORIENTACION-SERVICE] Filtro grupo: {groupId}");
            }

            if (studentId.HasValue)
            {
                query = query.Where(r => r.StudentId == studentId);
                Console.WriteLine($"👤 [ORIENTACION-SERVICE] Filtro estudiante: {studentId}");
            }

            // Filtros de fecha usando created_at - convertir de zona horaria local a UTC
            if (fechaInicio.HasValue)
            {
                // Inicio del día en hora local, convertir a UTC
                var localStart = fechaInicio.Value.Date; // 2025-09-19 00:00:00 (local)
                var utcStart = TimeZoneInfo.ConvertTimeToUtc(localStart, TimeZoneInfo.Local);
                query = query.Where(r => r.CreatedAt >= utcStart);
                Console.WriteLine($"📅 [ORIENTACION-SERVICE] Filtro inicio: {localStart:yyyy-MM-dd HH:mm:ss} (local) -> {utcStart:yyyy-MM-dd HH:mm:ss} (UTC)");
            }

            if (fechaFin.HasValue)
            {
                // Final del día en hora local, convertir a UTC
                var localEnd = fechaFin.Value.Date.AddDays(1).AddTicks(-1); // 2025-09-19 23:59:59 (local)
                var utcEnd = TimeZoneInfo.ConvertTimeToUtc(localEnd, TimeZoneInfo.Local);
                query = query.Where(r => r.CreatedAt <= utcEnd);
                Console.WriteLine($"📅 [ORIENTACION-SERVICE] Filtro fin: {localEnd:yyyy-MM-dd HH:mm:ss} (local) -> {utcEnd:yyyy-MM-dd HH:mm:ss} (UTC)");
            }

            var result = await query
                .OrderByDescending(r => r.CreatedAt)
                .ThenByDescending(r => r.Date)
                .ToListAsync();
                
            Console.WriteLine($"✅ [ORIENTACION-SERVICE] Resultado final: {result.Count} registros encontrados");
            
            // Mostrar detalles de los registros encontrados para debugging
            foreach (var record in result)
            {
                Console.WriteLine($"📄 [ORIENTACION-SERVICE] Registro: ID={record.Id}, CreatedAt={record.CreatedAt:yyyy-MM-dd HH:mm:ss}, Date={record.Date:yyyy-MM-dd HH:mm:ss}, Estudiante={record.Student?.Name} {record.Student?.LastName}");
            }
            
            return result;
        }

        public async Task<List<OrientationReportDto>> GetByStudentDtoAsync(Guid studentId, string trimester = null)
        {
            var query = _context.OrientationReports
                .Include(r => r.Teacher)
                .Where(r => r.StudentId == studentId)
                .AsQueryable();

            if (!string.IsNullOrEmpty(trimester))
            {
                var trimesterInfo = await _context.Trimesters
                    .FirstOrDefaultAsync(t => t.Name == trimester);

                if (trimesterInfo != null)
                {
                    var startDate = trimesterInfo.StartDate.ToUniversalTime();
                    var endDate = trimesterInfo.EndDate.ToUniversalTime();
                    query = query.Where(r => r.Date >= startDate && r.Date <= endDate);
                }
            }

            var reports = await query
                .OrderByDescending(r => r.Date)
                .ThenByDescending(r => r.CreatedAt)
                .ToListAsync();

            return reports.Select(r => new OrientationReportDto
            {
                Type = r.ReportType,
                Category = r.Category,
                Status = r.Status,
                Description = r.Description,
                Date = r.Date,
                Documents = r.Documents,
                Teacher = r.Teacher != null ? $"{r.Teacher.Name} {r.Teacher.LastName}" : null
            }).ToList();
        }
    }
}
