using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using SchoolManager.Dtos;
using SchoolManager.Interfaces;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using SchoolManager.Services.Implementations;
using SchoolManager.Services.Helpers;

namespace SchoolManager.Services
{
    public class StudentActivityScoreService : IStudentActivityScoreService
    {
        private readonly SchoolDbContext _context;
        private readonly ITrimesterService _trimesterService;
        private readonly ICurrentUserService _currentUserService;
        private readonly IAcademicYearService _academicYearService;
        private readonly IDocumentStorageService _documentStorage;
        private readonly IActivityService _activityService;

        public StudentActivityScoreService(
            SchoolDbContext context,
            ITrimesterService trimesterService,
            ICurrentUserService currentUserService,
            IAcademicYearService academicYearService,
            IDocumentStorageService documentStorage,
            IActivityService activityService)
        {
            _context = context;
            _trimesterService = trimesterService;
            _currentUserService = currentUserService;
            _academicYearService = academicYearService;
            _documentStorage = documentStorage;
            _activityService = activityService;
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
                    // MEJORADO: Obtener año académico activo para la nueva nota
                    var currentUserSchool = await _currentUserService.GetCurrentUserSchoolAsync();
                    var activeAcademicYear = currentUserSchool != null
                        ? await _academicYearService.GetActiveAcademicYearAsync(currentUserSchool.Id)
                        : null;

                    var newScore = new StudentActivityScore
                    {
                        Id = Guid.NewGuid(),
                        StudentId = dto.StudentId,
                        ActivityId = dto.ActivityId,
                        Score = dto.Score,
                        AcademicYearId = activeAcademicYear?.Id // Asignar año académico si existe
                    };
                    
                    // Configurar campos de auditoría y SchoolId
                    await AuditHelper.SetAuditFieldsForCreateAsync(newScore, _currentUserService);
                    await AuditHelper.SetSchoolIdAsync(newScore, _currentUserService);
                    
                    _context.StudentActivityScores.Add(newScore);
                }
                else
                {
                    entity.Score = dto.Score;
                    // Configurar campos de auditoría para actualización
                    await AuditHelper.SetAuditFieldsForUpdateAsync(entity, _currentUserService);
                }
            }
            await _context.SaveChangesAsync();
        }

        /* ------------ 2. Libro de calificaciones pivotado ------------ */
        public async Task<GradeBookDto> GetGradeBookAsync(Guid teacherId, Guid groupId, string trimesterCode, Guid subjectId, Guid gradeLevelId)
        {
            if (subjectId == Guid.Empty || gradeLevelId == Guid.Empty)
                return new GradeBookDto { Activities = new List<ActivityHeaderDto>(), Rows = new List<StudentGradeRowDto>() };

            /* 2.1 Cabeceras: actividades del docente en ese grupo, trimestre, materia y grado */
            var headers = await _context.Activities
                .Where(a => a.TeacherId == teacherId &&
                            a.GroupId == groupId &&
                            a.Trimester == trimesterCode &&
                            a.SubjectId == subjectId &&
                            a.GradeLevelId == gradeLevelId)
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
                h.PdfUrl = _documentStorage.ToPublicDownloadUrl(h.PdfUrl);
            }

            var activityIds = headers.Select(h => h.Id).ToList();

            /* 2.2 Estudiantes asignados a ese grupo/grado (User.Id, igual que StudentActivityScore) */
            var studentIds = await _context.StudentAssignments
                .Where(sa => sa.GroupId == groupId && sa.GradeId == gradeLevelId && sa.IsActive)
                .Select(sa => sa.StudentId)
                .Distinct()
                .ToListAsync();

            var students = await _context.Users
                .Where(u => studentIds.Contains(u.Id))
                .Select(u => new { u.Id, u.Name, u.LastName })
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
                    StudentName = $"{stu.LastName}, {stu.Name}".Trim(' ', ','),
                    ScoresByActivity = dict
                };
            });

            return new GradeBookDto { Activities = headers, Rows = rows };
        }

        public async Task SaveBulkFromNotasAsync(List<StudentActivityScoreCreateDto> registros)
        {
            if (registros == null || registros.Count == 0)
                return;

            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var currentUserSchool = await _currentUserService.GetCurrentUserSchoolAsync();
                if (currentUserSchool == null)
                {
                    throw new InvalidOperationException("No se pudo determinar la escuela del usuario actual.");
                }

                static (Guid TeacherId, Guid SubjectId, Guid GroupId, Guid GradeLevelId, string Trimester, string Name, string Type) ActivityKey(
                    StudentActivityScoreCreateDto dto) =>
                    (dto.TeacherId, dto.SubjectId, dto.GroupId, dto.GradeLevelId, dto.Trimester ?? "",
                        dto.ActivityName ?? "", dto.Type ?? "");

                static (Guid TeacherId, Guid SubjectId, Guid GroupId, Guid GradeLevelId, string Trimester, string Name, string Type) ActivityKeyEntity(Activity a) =>
                    (a.TeacherId ?? Guid.Empty, a.SubjectId ?? Guid.Empty, a.GroupId ?? Guid.Empty, a.GradeLevelId ?? Guid.Empty,
                        a.Trimester ?? "", a.Name, a.Type);

                foreach (var trimCode in registros.Select(r => r.Trimester).Distinct())
                {
                    await _trimesterService.ValidateTrimesterActiveAsync(trimCode);
                }

                var trimesterIdByCode = new Dictionary<string, Guid>(StringComparer.Ordinal);
                foreach (var trimCode in registros.Select(r => r.Trimester).Distinct())
                {
                    var trimesterRow = await _context.Trimesters
                        .FirstOrDefaultAsync(t =>
                            t.Name == trimCode && t.SchoolId == currentUserSchool.Id);
                    if (trimesterRow == null)
                    {
                        throw new InvalidOperationException(
                            $"No se encontró el trimestre '{trimCode}' para la escuela actual.");
                    }

                    trimesterIdByCode[trimCode] = trimesterRow.Id;
                }

                var scopes = registros
                    .Select(r => (r.TeacherId, r.SubjectId, r.GroupId, r.GradeLevelId, r.Trimester))
                    .Distinct()
                    .ToList();

                var allActivities = new List<Activity>();
                foreach (var scope in scopes)
                {
                    var batch = await _context.Activities
                        .Where(a =>
                            a.TeacherId == scope.TeacherId &&
                            a.SubjectId == scope.SubjectId &&
                            a.GroupId == scope.GroupId &&
                            a.GradeLevelId == scope.GradeLevelId &&
                            a.Trimester == scope.Trimester)
                        .ToListAsync();
                    allActivities.AddRange(batch);
                }

                var activityByKey = allActivities
                    .GroupBy(ActivityKeyEntity)
                    .ToDictionary(g => g.Key, g => g.First());

                var activeAcademicYear = await _academicYearService.GetActiveAcademicYearAsync(currentUserSchool.Id);

                foreach (var dto in registros)
                {
                    var key = ActivityKey(dto);
                    if (!activityByKey.TryGetValue(key, out var activity))
                    {
                        var trimesterId = trimesterIdByCode[dto.Trimester];
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
                            TrimesterId = trimesterId,
                            SchoolId = currentUserSchool.Id,
                            CreatedAt = DateTime.UtcNow
                        };

                        await AuditHelper.SetAuditFieldsForCreateAsync(activity, _currentUserService);
                        _context.Activities.Add(activity);
                        activityByKey[key] = activity;
                    }
                    else if (activity.SchoolId == null || activity.TrimesterId == null)
                    {
                        if (activity.SchoolId == null)
                            activity.SchoolId = currentUserSchool.Id;
                        if (activity.TrimesterId == null)
                            activity.TrimesterId = trimesterIdByCode[dto.Trimester];
                        await AuditHelper.SetAuditFieldsForUpdateAsync(activity, _currentUserService);
                    }
                }

                var activityIds = activityByKey.Values.Select(a => a.Id).Distinct().ToList();
                var studentIds = registros.Select(r => r.StudentId).Distinct().ToList();

                var existingScores = await _context.StudentActivityScores
                    .Where(s => activityIds.Contains(s.ActivityId) && studentIds.Contains(s.StudentId))
                    .ToListAsync();

                var scoreByStudentActivity = existingScores.ToDictionary(s => (s.StudentId, s.ActivityId));

                foreach (var dto in registros)
                {
                    var activity = activityByKey[ActivityKey(dto)];
                    var pair = (dto.StudentId, activity.Id);

                    if (!scoreByStudentActivity.TryGetValue(pair, out var row))
                    {
                        row = new StudentActivityScore
                        {
                            Id = Guid.NewGuid(),
                            StudentId = dto.StudentId,
                            ActivityId = activity.Id,
                            Score = dto.Score,
                            AcademicYearId = activeAcademicYear?.Id,
                            CreatedAt = DateTime.UtcNow
                        };
                        _context.StudentActivityScores.Add(row);
                        scoreByStudentActivity[pair] = row;
                    }
                    else
                    {
                        row.Score = dto.Score;
                    }
                }

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
            if (notes.SubjectId == Guid.Empty || notes.GradeLevelId == Guid.Empty)
                return new List<StudentNotaDto>();

            // Obtener las notas existentes con información del estudiante
            var notas = await _context.StudentActivityScores
                .AsNoTracking()
                .Include(sa => sa.Activity)
                .Include(sa => sa.Student)
                .Where(sa =>
                    sa.Activity.TeacherId == notes.TeacherId &&
                    sa.Activity.SubjectId == notes.SubjectId &&
                    sa.Activity.GroupId == notes.GroupId &&
                    sa.Activity.GradeLevelId == notes.GradeLevelId &&
                    sa.Activity.Trimester == notes.Trimester)
                .ToListAsync();

            // Obtener información de los estudiantes
            var studentIds = notas.Select(n => n.StudentId).Distinct().ToList();
            var estudiantes = await _context.Users
                .Where(u => studentIds.Contains(u.Id))
                .Select(u => new { u.Id, u.Name, u.LastName, u.DocumentId })
                .ToListAsync();

            // Agrupar las notas por estudiante
            var resultado = notas
                .GroupBy(n => n.StudentId)
                .Select(g => {
                    var estudiante = estudiantes.FirstOrDefault(e => e.Id == g.Key);
                    var nombre = estudiante != null ? 
                        $"{(estudiante.Name ?? "").Trim()} {(estudiante.LastName ?? "").Trim()}".Trim() : 
                        "(Sin nombre)";
                    if (string.IsNullOrWhiteSpace(nombre)) nombre = "(Sin nombre)";
                    
                    return new StudentNotaDto
                    {
                        StudentId = g.Key.ToString(),
                        StudentFullName = nombre,
                        DocumentId = estudiante?.DocumentId ?? "",
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
                    };
                })
                .ToList();

            return resultado;
        }

        public async Task<IReadOnlyList<CounselorSubjectAverageDto>> GetCounselorGroupSubjectAveragesForTrimesterAsync(
            Guid groupId,
            Guid gradeLevelId,
            string trimester,
            IReadOnlyCollection<Guid> subjectIds)
        {
            if (subjectIds == null || subjectIds.Count == 0 || string.IsNullOrEmpty(trimester))
                return Array.Empty<CounselorSubjectAverageDto>();

            var subjectSet = subjectIds as HashSet<Guid> ?? subjectIds.ToHashSet();

            var activities = await _context.Activities.AsNoTracking()
                .Where(a => a.GroupId == groupId
                    && a.GradeLevelId == gradeLevelId
                    && a.Trimester == trimester
                    && a.SubjectId != null
                    && subjectSet.Contains(a.SubjectId.Value))
                .Select(a => new { a.Id, SubjectId = a.SubjectId!.Value, a.Type })
                .ToListAsync();

            if (activities.Count == 0)
                return Array.Empty<CounselorSubjectAverageDto>();

            var activityIds = activities.Select(a => a.Id).ToList();

            var scores = await _context.StudentActivityScores.AsNoTracking()
                .Where(s => activityIds.Contains(s.ActivityId) && s.Score.HasValue)
                .Select(s => new { s.StudentId, s.ActivityId, s.Score })
                .ToListAsync();

            if (scores.Count == 0)
                return Array.Empty<CounselorSubjectAverageDto>();

            var activitiesBySubject = activities
                .GroupBy(a => a.SubjectId)
                .ToDictionary(g => g.Key, g => g.ToList());

            var studentIds = scores.Select(s => s.StudentId).Distinct();

            var results = new List<CounselorSubjectAverageDto>();

            foreach (var studentId in studentIds)
            {
                foreach (var subjectId in subjectSet)
                {
                    if (!activitiesBySubject.TryGetValue(subjectId, out var subjectActivities))
                        continue;

                    var acts = subjectActivities
                        .Select(a => new Activity { Id = a.Id, Type = a.Type })
                        .ToList();

                    var scoreDict = acts.ToDictionary(
                        a => a.Id,
                        a => scores.FirstOrDefault(s => s.StudentId == studentId && s.ActivityId == a.Id)?.Score);

                    var final = GradebookFinalGradeCalculator.CalcularNotaFinal(acts, scoreDict);
                    if (!final.HasValue)
                        continue;

                    results.Add(new CounselorSubjectAverageDto
                    {
                        StudentId = studentId,
                        SubjectId = subjectId,
                        AverageScore = (double)final.Value
                    });
                }
            }

            return results;
        }

        public async Task<List<PromedioFinalDto>> GetPromediosFinalesAsync(GetNotesDto notes)
        {
            if (notes.SubjectId == Guid.Empty || notes.GradeLevelId == Guid.Empty)
                return new List<PromedioFinalDto>();

            var students = await _context.StudentAssignments
                .Where(sa => sa.GroupId == notes.GroupId && sa.GradeId == notes.GradeLevelId)
                .Join(_context.Users,
                    sa => sa.StudentId,
                    u => u.Id,
                    (sa, u) => new { u.Id, u.Name, u.LastName, u.DocumentId })
                .OrderBy(s => s.LastName)
                .ThenBy(s => s.Name)
                .ToListAsync();

            var school = await _currentUserService.GetCurrentUserSchoolAsync();
            var trimestres = new List<string> { "1T", "2T", "3T" };
            var headersByTrim = new Dictionary<string, List<ActivityHeaderDto>>(StringComparer.Ordinal);
            var notasFiltroByTrim = new Dictionary<string, List<StudentNotaDto>>(StringComparer.Ordinal);

            foreach (var trimestre in trimestres)
            {
                if (!string.IsNullOrEmpty(notes.Trimester) && notes.Trimester != trimestre)
                {
                    headersByTrim[trimestre] = new List<ActivityHeaderDto>();
                    notasFiltroByTrim[trimestre] = new List<StudentNotaDto>();
                    continue;
                }

                if (school == null)
                {
                    headersByTrim[trimestre] = new List<ActivityHeaderDto>();
                    notasFiltroByTrim[trimestre] = new List<StudentNotaDto>();
                    continue;
                }

                // Misma consulta de actividades que GetNotasCargadas / TeacherGradebook/Index.
                headersByTrim[trimestre] = (await _activityService.GetByTeacherGroupTrimesterAsync(
                    notes.TeacherId, notes.GroupId, trimestre, notes.SubjectId, notes.GradeLevelId))
                    .ToList();

                // Mismo set de notas que Index: match por tipo+nombre (FirstOrDefault), no por ActivityId.
                notasFiltroByTrim[trimestre] = await GetNotasPorFiltroAsync(new GetNotesDto
                {
                    TeacherId = notes.TeacherId,
                    SubjectId = notes.SubjectId,
                    GroupId = notes.GroupId,
                    GradeLevelId = notes.GradeLevelId,
                    Trimester = trimestre
                });
            }

            var promedios = new List<PromedioFinalDto>();
            foreach (var student in students)
            {
                foreach (var trimestre in trimestres)
                {
                    var headers = headersByTrim[trimestre];
                    var alumno = notasFiltroByTrim[trimestre]
                        .FirstOrDefault(n => n.StudentId == student.Id.ToString());
                    var notasAlumno = alumno?.Notas ?? new List<NotaDetalleDto>();
                    var celdasIndex = TeacherGradebookIndexCalculator.BuildNotasPorActividad(headers, notasAlumno);

                    var scoreDict = new Dictionary<Guid, decimal?>();
                    foreach (var celda in celdasIndex)
                    {
                        decimal? score = null;
                        if (!string.IsNullOrEmpty(celda.Nota)
                            && decimal.TryParse(celda.Nota, NumberStyles.Number, CultureInfo.InvariantCulture, out var parsed))
                            score = parsed;
                        scoreDict[celda.Id] = score;
                    }

                    var actsTrimestre = headers
                        .Select(a => new Activity { Id = a.Id, Type = a.Type })
                        .ToList();

                    var notaFinal = headers.Count > 0
                        ? TeacherGradebookIndexCalculator.CalcularNotaFinal(celdasIndex)
                        : null;

                    var promedioNotasApreciacion = GradebookFinalGradeCalculator.GetTruncatedTypeAverage(
                        actsTrimestre, scoreDict, "notas de apreciación");
                    var promedioEjerciciosDiarios = GradebookFinalGradeCalculator.GetTruncatedTypeAverage(
                        actsTrimestre, scoreDict, "ejercicios diarios");

                    var promedioExamenFinal = GradebookFinalGradeCalculator.GetTruncatedTypeAverage(
                        actsTrimestre, scoreDict, "examen final");
                    var promedioRecuperacion = GradebookFinalGradeCalculator.GetTruncatedTypeAverage(
                        actsTrimestre, scoreDict, "recuperación");
                    if (promedioRecuperacion.HasValue)
                        promedioExamenFinal = promedioRecuperacion;

                    var nombre = $"{(student.LastName ?? "").Trim()}, {(student.Name ?? "").Trim()}".Trim();
                    if (string.IsNullOrWhiteSpace(nombre) || nombre == ",") nombre = "(Sin nombre)";

                    promedios.Add(new PromedioFinalDto
                    {
                        StudentId = student.Id.ToString(),
                        StudentFullName = nombre,
                        DocumentId = student.DocumentId ?? "",
                        Trimester = trimestre,
                        PromedioTareas = promedioNotasApreciacion,
                        PromedioParciales = promedioEjerciciosDiarios,
                        PromedioExamenes = promedioExamenFinal,
                        NotaFinal = notaFinal,
                        Estado = notaFinal.HasValue ? (notaFinal.Value >= 3.0m ? "Aprobado" : "Reprobado") : "Sin calificar"
                    });
                }
            }

            return promedios;
        }
    }
}

