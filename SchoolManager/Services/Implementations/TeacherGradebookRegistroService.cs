using Microsoft.EntityFrameworkCore;
using SchoolManager.Dtos;
using SchoolManager.Interfaces;
using SchoolManager.Models;
using SchoolManager.Services.Helpers;
using SchoolManager.Services.Interfaces;

namespace SchoolManager.Services.Implementations;

/// <summary>
/// Construye el modelo canónico del gradebook. Solo lectura: no inserta, actualiza ni elimina.
/// </summary>
public class TeacherGradebookRegistroService : ITeacherGradebookRegistroService
{
    private readonly SchoolDbContext _context;
    private readonly IActivityService _activityService;
    private readonly IStudentService _studentService;
    private readonly ICurrentUserService _currentUserService;
    private readonly IAcademicYearService _academicYearService;
    private readonly ITimeZoneService _timeZoneService;

    public TeacherGradebookRegistroService(
        SchoolDbContext context,
        IActivityService activityService,
        IStudentService studentService,
        ICurrentUserService currentUserService,
        IAcademicYearService academicYearService,
        ITimeZoneService timeZoneService)
    {
        _context = context;
        _activityService = activityService;
        _studentService = studentService;
        _currentUserService = currentUserService;
        _academicYearService = academicYearService;
        _timeZoneService = timeZoneService;
    }

    public async Task<GradebookPdfDto> GetRegistroAsync(
        Guid teacherId,
        Guid groupId,
        string trimester,
        Guid subjectId,
        Guid gradeLevelId)
    {
        if (teacherId == Guid.Empty ||
            groupId == Guid.Empty ||
            subjectId == Guid.Empty ||
            gradeLevelId == Guid.Empty ||
            string.IsNullOrWhiteSpace(trimester))
        {
            throw new ArgumentException("Debe indicar trimestre, materia, grupo y grado.");
        }

        var school = await _currentUserService.GetCurrentUserSchoolAsync()
            ?? throw new UnauthorizedAccessException("No se pudo determinar el colegio del usuario actual.");

        var hasAssignment = await _context.TeacherAssignments.AnyAsync(ta =>
            ta.TeacherId == teacherId &&
            ta.SubjectAssignment.GroupId == groupId &&
            ta.SubjectAssignment.SubjectId == subjectId &&
            ta.SubjectAssignment.GradeLevelId == gradeLevelId &&
            (ta.SubjectAssignment.SchoolId == null || ta.SubjectAssignment.SchoolId == school.Id));

        if (!hasAssignment)
            throw new UnauthorizedAccessException("No tiene asignación para esta materia y grupo.");

        var trimesterRow = await _context.Trimesters.AsNoTracking()
            .Include(t => t.AcademicYear)
            .FirstOrDefaultAsync(t => t.Name == trimester && t.SchoolId == school.Id);

        if (trimesterRow == null)
            throw new ArgumentException("El trimestre no pertenece al colegio actual.");

        var activities = (await _activityService.GetByTeacherGroupTrimesterAsync(
                teacherId, groupId, trimester, subjectId, gradeLevelId))
            .ToList();

        var typeSections = GradebookVisibleActivitySelector.SelectVisibleColumns(activities).ToList();

        var students = (await _studentService.GetBySubjectGroupAndGradeAsync(subjectId, groupId, gradeLevelId))
            .OrderBy(s => s.FullName)
            .ToList();

        var studentIds = students.Select(s => s.StudentId).ToList();
        if (studentIds.Count > 0)
        {
            var allowedStudentIds = await _context.Users.AsNoTracking()
                .Where(u => studentIds.Contains(u.Id)
                    && (u.SchoolId == null || u.SchoolId == school.Id))
                .Select(u => u.Id)
                .ToListAsync();
            var allowed = allowedStudentIds.ToHashSet();
            students = students.Where(s => allowed.Contains(s.StudentId)).ToList();
        }

        var teacher = await _context.Users.AsNoTracking().FirstOrDefaultAsync(u => u.Id == teacherId)
            ?? throw new InvalidOperationException("Docente no encontrado.");
        var subject = await _context.Subjects.AsNoTracking().FirstOrDefaultAsync(s => s.Id == subjectId);
        var group = await _context.Groups.AsNoTracking().FirstOrDefaultAsync(g => g.Id == groupId);
        var gradeLevel = await _context.GradeLevels.AsNoTracking().FirstOrDefaultAsync(g => g.Id == gradeLevelId);

        var academicYearName = trimesterRow.AcademicYear?.Name;
        if (string.IsNullOrWhiteSpace(academicYearName))
        {
            var activeYear = await _academicYearService.GetActiveAcademicYearAsync(school.Id);
            academicYearName = activeYear?.Name ?? "";
        }

        var lookupIds = typeSections
            .SelectMany(s => s.Activities)
            .SelectMany(a => (a.AliasIds != null && a.AliasIds.Count > 0 ? a.AliasIds : new List<Guid> { a.Id }))
            .Distinct()
            .ToList();

        var scoresByStudentId = lookupIds.Count == 0
            ? new Dictionary<Guid, Dictionary<Guid, decimal?>>()
            : (await _context.StudentActivityScores
                .AsNoTracking()
                .Where(s => lookupIds.Contains(s.ActivityId)
                    && (s.SchoolId == null || s.SchoolId == school.Id))
                .ToListAsync())
                .GroupBy(s => s.StudentId)
                .ToDictionary(
                    g => g.Key,
                    g => g
                        .GroupBy(x => x.ActivityId)
                        .ToDictionary(x => x.Key, x => x.First().Score));

        var studentRows = new List<GradebookPdfStudentRowDto>();
        var index = 1;
        foreach (var stu in students)
        {
            scoresByStudentId.TryGetValue(stu.StudentId, out var scores);
            scores ??= new Dictionary<Guid, decimal?>();

            var typeAvgs = new Dictionary<string, decimal>();
            var typesWithScores = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

            foreach (var section in typeSections)
            {
                var cells = section.Activities
                    .Select(a => GradebookVisibleActivitySelector.ResolveScore(a, scores))
                    .ToList();

                if (GradebookFinalGradeCalculator.HasAnyScore(cells))
                    typesWithScores.Add(section.TypeKey);

                typeAvgs[section.TypeKey] = GradebookFinalGradeCalculator.TruncatedAverageOrZero(cells);
            }

            var finalNullable = typeSections.Count == 0
                ? null
                : GradebookFinalGradeCalculator.ComputeFinalGradeFromTypeAverages(typeAvgs, typesWithScores);

            studentRows.Add(new GradebookPdfStudentRowDto
            {
                Number = index++,
                Name = stu.FullName,
                DocumentId = stu.DocumentId ?? "",
                ScoresByActivityId = scores.ToDictionary(k => k.Key, k => k.Value),
                TypeAverages = typeAvgs,
                FinalGrade = finalNullable ?? 0m
            });
        }

        var generatedUtc = DateTime.UtcNow;

        return new GradebookPdfDto
        {
            SchoolName = school.Name,
            LogoUrl = school.LogoUrl,
            TeacherName = $"{teacher.Name} {teacher.LastName}".Trim(),
            SubjectName = subject?.Name ?? "Materia",
            GroupLabel = $"{gradeLevel?.Name} {group?.Name}".Trim(),
            GradeLevelName = gradeLevel?.Name ?? "",
            GroupName = group?.Name ?? "",
            Trimester = trimester,
            AcademicYear = academicYearName ?? "",
            GeneratedAt = generatedUtc,
            GeneratedAtDisplay = _timeZoneService.ToLocalDisplayString(generatedUtc, "dd/MM/yyyy HH:mm", ""),
            TypeSections = typeSections,
            Students = studentRows
        };
    }
}
