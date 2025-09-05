﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using SchoolManager.Dtos;
using SchoolManager.Interfaces;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;

namespace SchoolManager.Services
{
    public class StudentActivityScoreService : IStudentActivityScoreService
    {
        private readonly SchoolDbContext _context;
        private readonly ITrimesterService _trimesterService;

        public StudentActivityScoreService(SchoolDbContext context, ITrimesterService trimesterService)
        {
            _context = context;
            _trimesterService = trimesterService;
        }

        /* ------------ 1. Guardar / actualizar notas ------------ */
        public async Task SaveAsync(IEnumerable<StudentActivityScoreCreateDto> scores)
        {
            foreach (var dto in scores)
            {
                // Validar trimestre activo
                await _trimesterService.ValidateTrimesterActiveAsync(dto.Trimester);

                var entity = await _context.StudentActivityScores
                    .FirstOrDefaultAsync(s => s.StudentId == dto.StudentId &&
                                              s.ActivityId == dto.ActivityId);

                if (entity is null)
                {
                    _context.StudentActivityScores.Add(new StudentActivityScore
                    {
                        Id = Guid.NewGuid(),
                        StudentId = dto.StudentId,
                        ActivityId = dto.ActivityId,
                        Score = dto.Score,
                        CreatedAt = DateTime.UtcNow
                    });
                }
                else
                {
                    entity.Score = dto.Score;
                }
            }
            await _context.SaveChangesAsync();
        }

        /* ------------ 2. Libro de calificaciones pivotado ------------ */
        public async Task<GradeBookDto> GetGradeBookAsync(Guid teacherId, Guid groupId, string trimesterCode)
        {
            /* 2.1 Cabeceras: actividades del docente en ese grupo y trimestre */
            var headers = await _context.Activities
                .Where(a => a.TeacherId == teacherId &&
                            a.GroupId == groupId &&
                            a.Trimester == trimesterCode)
                .OrderBy(a => a.CreatedAt)
                .Select(a => new ActivityHeaderDto
                {
                    Id = a.Id,
                    Name = a.Name,
                    Type = a.Type,
                    Date = a.CreatedAt,
                    DueDate = a.DueDate,
                    HasPdf = a.PdfUrl != null,
                    PdfUrl = a.PdfUrl
                })
                .ToListAsync();

            // Ajustar el tipo de fecha y valor por defecto después de traer los datos a memoria
            foreach (var h in headers)
            {
                h.Date = h.Date.HasValue
                    ? h.Date.Value.ToUniversalTime()
                    : DateTime.UtcNow;
            }

            var activityIds = headers.Select(h => h.Id).ToList();

            /* 2.2 Estudiantes asignados a ese grupo (StudentAssignments) */
            var studentIds = await _context.StudentAssignments
                .Where(sa => sa.GroupId == groupId)
                .Select(sa => sa.StudentId)
                .Distinct()
                .ToListAsync();

            var students = await _context.Students
                .Where(s => studentIds.Contains(s.Id))
                .Select(s => new { s.Id, s.Name })
                .ToListAsync();

            /* 2.3 Notas existentes */
            var scores = await _context.StudentActivityScores
                .Where(s => activityIds.Contains(s.ActivityId))
                .ToListAsync();

            /* 2.4 Pivotar alumnos × actividades */
            var rows = students.Select(stu =>
            {
                var dict = new Dictionary<Guid, decimal?>();
                foreach (var hdr in headers)
                {
                    var score = scores.FirstOrDefault(x =>
                        x.StudentId == stu.Id && x.ActivityId == hdr.Id);
                    dict[hdr.Id] = score?.Score;
                }

                return new StudentGradeRowDto
                {
                    StudentId = stu.Id,
                    StudentName = stu.Name,
                    ScoresByActivity = dict
                };
            });

            return new GradeBookDto { Activities = headers, Rows = rows };
        }

        public async Task SaveBulkFromNotasAsync(List<StudentActivityScoreCreateDto> registros)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                foreach (var dto in registros)
                {
                    // Validar trimestre activo antes de procesar
                    await _trimesterService.ValidateTrimesterActiveAsync(dto.Trimester);

                    // Buscar o crear la actividad por nombre, docente, grupo, trimestre y grado
                    var activity = await _context.Activities
                        .FirstOrDefaultAsync(a =>
                            a.Name == dto.ActivityName &&
                            a.TeacherId == dto.TeacherId &&
                            a.Trimester == dto.Trimester &&
                            a.SubjectId == dto.SubjectId &&
                            a.GroupId == dto.GroupId &&
                            a.GradeLevelId == dto.GradeLevelId &&
                            a.Type == dto.Type);

                    // Si no existe, la creamos
                    if (activity == null)
                    {
                        activity = new Activity
                        {
                            Id = Guid.NewGuid(),
                            Name = dto.ActivityName,
                            Type = dto.Type,
                            TeacherId = dto.TeacherId,
                            SubjectId = dto.SubjectId,
                            GroupId = dto.GroupId,
                            GradeLevelId = dto.GradeLevelId,
                            Trimester = dto.Trimester,
                            CreatedAt = DateTime.UtcNow
                        };

                        _context.Activities.Add(activity);
                        await _context.SaveChangesAsync();
                    }

                    // Verificamos si ya hay nota para ese alumno y esa actividad
                    var existing = await _context.StudentActivityScores
                        .FirstOrDefaultAsync(s =>
                            s.StudentId == dto.StudentId &&
                            s.ActivityId == activity.Id);

                    if (existing == null)
                    {
                        // Si no existe, lo añadimos (incluso si la nota es nula)
                        _context.StudentActivityScores.Add(new StudentActivityScore
                        {
                            Id = Guid.NewGuid(),
                            StudentId = dto.StudentId,
                            ActivityId = activity.Id,
                            Score = dto.Score, // Puede ser nulo
                            CreatedAt = DateTime.UtcNow
                        });
                    }
                    else
                    {
                        // Si ya existe, actualizamos la nota (puede ser nula)
                        existing.Score = dto.Score;
                    }
                }

                // Guardamos todos los cambios a la base de datos
                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                // Manejamos el error
                Console.WriteLine("❌ Error guardando notas en bloque:");
                Console.WriteLine($"Mensaje: {ex.Message}");
                Console.WriteLine($"StackTrace: {ex.StackTrace}");
                throw new Exception($"Error al guardar las notas: {ex.Message}", ex);
            }
        }

        public async Task<List<StudentNotaDto>> GetNotasPorFiltroAsync(GetNotesDto notes)
        {
            // Obtener las notas existentes
            var notas = await _context.StudentActivityScores
                .Include(sa => sa.Activity)
                .Include(sa => sa.Student)
                .Where(sa =>
                    sa.Activity.TeacherId == notes.TeacherId &&
                    sa.Activity.SubjectId == notes.SubjectId &&
                    sa.Activity.GroupId == notes.GroupId &&
                    sa.Activity.GradeLevelId == notes.GradeLevelId &&
                    sa.Activity.Trimester == notes.Trimester)
                .ToListAsync();

            // Agrupar las notas por estudiante
            var resultado = notas
                .GroupBy(n => n.StudentId)
                .Select(g => new StudentNotaDto
                {
                    StudentId = g.Key.ToString(),
                    TeacherId = notes.TeacherId.ToString(),
                    SubjectId = notes.SubjectId.ToString(),
                    GroupId = notes.GroupId.ToString(),
                    GradeLevelId = notes.GradeLevelId.ToString(),
                    Trimester = notes.Trimester,
                    Notas = g.Select(n => new NotaDetalleDto
                    {
                        Tipo = n.Activity.Type,
                        Actividad = n.Activity.Name,
                        Nota = n.Score.HasValue ? n.Score.Value.ToString("0.00") : "",
                        DueDate = n.Activity.DueDate
                    }).ToList()
                })
                .ToList();

            return resultado;
        }

        public async Task<List<PromedioFinalDto>> GetPromediosFinalesAsync(GetNotesDto notes)
        {
            // 1. Obtener todos los estudiantes del grupo y grado usando solo User y StudentAssignment
            var students = await _context.StudentAssignments
                .Where(sa => sa.GroupId == notes.GroupId && sa.GradeId == notes.GradeLevelId)
                .Join(_context.Users,
                    sa => sa.StudentId,
                    u => u.Id,
                    (sa, u) => new { u.Id, u.Name, u.LastName })
                .ToListAsync();

            // 2. Obtener todas las notas del grupo, materia, grado y docente
            var notasPorTrimestre = await _context.StudentActivityScores
                .Join(_context.Activities,
                    score => score.ActivityId,
                    activity => activity.Id,
                    (score, activity) => new
                    {
                        StudentId = score.StudentId,
                        Score = score.Score,
                        Trimester = activity.Trimester,
                        ActivityType = activity.Type,
                        SubjectId = activity.SubjectId,
                        GroupId = activity.GroupId,
                        GradeLevelId = activity.GradeLevelId,
                        TeacherId = activity.TeacherId
                    })
                .Where(x => x.SubjectId == notes.SubjectId &&
                           x.GroupId == notes.GroupId &&
                           x.GradeLevelId == notes.GradeLevelId &&
                           x.TeacherId == notes.TeacherId
                           && (string.IsNullOrEmpty(notes.Trimester) || x.Trimester == notes.Trimester))
                .ToListAsync();

            // 3. Usar siempre los tres trimestres estándar
            var trimestres = new List<string> { "1T", "2T", "3T" };

            // 4. Construir la lista de promedios por estudiante y trimestre
            var promedios = new List<PromedioFinalDto>();
            foreach (var student in students)
            {
                foreach (var trimestre in trimestres)
                {
                    var notasEstudianteTrimestre = notasPorTrimestre
                        .Where(x => x.StudentId == student.Id && x.Trimester == trimestre)
                        .ToList();

                    var notasValidas = notasEstudianteTrimestre.Where(x => x.Score.HasValue).ToList();

                    // Siempre armar el nombre correctamente
                    var nombre = $"{(student.Name ?? "").Trim()} {(student.LastName ?? "").Trim()}".Trim();
                    if (string.IsNullOrWhiteSpace(nombre)) nombre = "(Sin nombre)";

                    promedios.Add(new PromedioFinalDto
                    {
                        StudentId = student.Id.ToString(),
                        StudentFullName = nombre,
                        Trimester = trimestre,
                        PromedioTareas = notasEstudianteTrimestre.Where(x => x.ActivityType.ToLower() == "tarea" && x.Score.HasValue)
                            .Any() ? notasEstudianteTrimestre.Where(x => x.ActivityType.ToLower() == "tarea" && x.Score.HasValue).Average(x => x.Score.Value) : null,
                        PromedioParciales = notasEstudianteTrimestre.Where(x => x.ActivityType.ToLower() == "parcial" && x.Score.HasValue)
                            .Any() ? notasEstudianteTrimestre.Where(x => x.ActivityType.ToLower() == "parcial" && x.Score.HasValue).Average(x => x.Score.Value) : null,
                        PromedioExamenes = notasEstudianteTrimestre.Where(x => x.ActivityType.ToLower() == "examen" && x.Score.HasValue)
                            .Any() ? notasEstudianteTrimestre.Where(x => x.ActivityType.ToLower() == "examen" && x.Score.HasValue).Average(x => x.Score.Value) : null,
                        NotaFinal = notasValidas.Any() ? notasValidas.Average(x => x.Score.Value) : null,
                        Estado = notasValidas.Any() ? (notasValidas.Average(x => x.Score.Value) >= 3.0m ? "Aprobado" : "Reprobado") : "Sin calificar"
                    });
                }
            }

            return promedios;
        }
    }
}

