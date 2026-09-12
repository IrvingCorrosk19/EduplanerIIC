using Microsoft.EntityFrameworkCore;
using SchoolManager.Dtos;
using SchoolManager.Models;
using SchoolManager.ViewModels;

namespace SchoolManager.Services.Helpers;

/// <summary>
/// Carga masiva read-only para informes institucionales (elimina N+1 por estudiante/celda).
/// </summary>
public sealed class ReportesGrupoBulkData
{
    public List<InformeEstudianteFilaDto> Estudiantes { get; init; } = new();
    public Dictionary<string, Guid> TrimesterNameToId { get; init; } = new(StringComparer.OrdinalIgnoreCase);
    public List<ReportesActivityRow> Activities { get; init; } = new();
    public Dictionary<(Guid StudentId, Guid ActivityId), decimal?> Scores { get; init; } = new();
    public Dictionary<(Guid StudentId, Guid TrimesterId), (int Ausencias, int Tardanzas)> Attendance { get; init; } = new();
    public IReadOnlyList<Trimester> TrimesterEntities { get; init; } = Array.Empty<Trimester>();
    public Guid? SubjectId { get; init; }
    public Guid? AcademicYearId { get; init; }
}

public sealed class ReportesActivityRow
{
    public Guid Id { get; init; }
    public string Name { get; init; } = "";
    public string Type { get; init; } = "";
    public string? Trimester { get; init; }
    public Guid? TrimesterId { get; init; }
    public Guid? SubjectId { get; init; }
    public Guid? TeacherId { get; init; }
    public Guid? SchoolId { get; init; }
    public DateTime? CreatedAt { get; init; }
    public string SubjectName { get; init; } = "";
}

public static class ReportesInstitucionalesBulkLoader
{
    public static async Task<ReportesGrupoBulkData> LoadAsync(
        SchoolDbContext context,
        Guid schoolId,
        Guid groupId,
        Guid gradeLevelId,
        Guid? subjectId = null)
    {
        var estudiantesRaw = await context.StudentAssignments
            .AsNoTracking()
            .Where(sa => sa.GroupId == groupId && sa.GradeId == gradeLevelId && sa.IsActive)
            .Join(context.Users.AsNoTracking(),
                sa => sa.StudentId,
                u => u.Id,
                (sa, u) => new { u.Id, u.Name, u.LastName })
            .OrderBy(x => x.LastName).ThenBy(x => x.Name)
            .ToListAsync();

        var estudiantes = estudiantesRaw.Select((e, i) => new InformeEstudianteFilaDto
        {
            Numero = i + 1,
            StudentId = e.Id,
            Nombre = FormatearApellidoNombre(e.LastName, e.Name)
        }).ToList();

        var studentIds = estudiantes.Select(e => e.StudentId).ToList();

        var trimesterEntities = await context.Trimesters
            .AsNoTracking()
            .Where(t => t.SchoolId == schoolId)
            .ToListAsync();

        var trimesterNameToId = trimesterEntities
            .GroupBy(t => t.Name, StringComparer.OrdinalIgnoreCase)
            .ToDictionary(g => g.Key, g => g.First().Id, StringComparer.OrdinalIgnoreCase);

        var trimesterIds = trimesterEntities.Select(t => t.Id).ToList();
        var trimesterNames = trimesterEntities.Select(t => t.Name).Where(n => n != null).Cast<string>().ToList();

        var activities = await context.Activities
            .AsNoTracking()
            .Where(a =>
                a.GroupId == groupId &&
                a.GradeLevelId == gradeLevelId &&
                (a.SchoolId == schoolId || a.SchoolId == null) &&
                (trimesterNames.Contains(a.Trimester!) ||
                 (a.TrimesterId.HasValue && trimesterIds.Contains(a.TrimesterId.Value))))
            .Select(a => new ReportesActivityRow
            {
                Id = a.Id,
                Name = a.Name,
                Type = a.Type,
                Trimester = a.Trimester,
                TrimesterId = a.TrimesterId,
                SubjectId = a.SubjectId,
                TeacherId = a.TeacherId,
                SchoolId = a.SchoolId,
                CreatedAt = a.CreatedAt,
                SubjectName = a.Subject!.Name
            })
            .ToListAsync();

        var activityIds = activities.Select(a => a.Id).ToList();

        var scores = activityIds.Count == 0 || studentIds.Count == 0
            ? new Dictionary<(Guid, Guid), decimal?>()
            : (await context.StudentActivityScores
                .AsNoTracking()
                .Where(s => studentIds.Contains(s.StudentId) && activityIds.Contains(s.ActivityId))
                .Select(s => new { s.StudentId, s.ActivityId, s.Score })
                .ToListAsync())
                .ToDictionary(s => (s.StudentId, s.ActivityId), s => s.Score);

        var activeYear = await context.AcademicYears.AsNoTracking()
            .Where(y => y.SchoolId == schoolId && y.IsActive)
            .OrderByDescending(y => y.StartDate)
            .FirstOrDefaultAsync();

        var officialTrimesters = AttendanceOfficialCalendar.OfficialForSchoolYear(
            trimesterEntities, schoolId, activeYear?.Id).ToList();

        var attendance = await LoadAttendanceAsync(
            context, schoolId, groupId, gradeLevelId, subjectId, studentIds, officialTrimesters, activeYear?.Id);

        return new ReportesGrupoBulkData
        {
            Estudiantes = estudiantes,
            TrimesterNameToId = trimesterNameToId,
            Activities = activities,
            Scores = scores,
            Attendance = attendance,
            TrimesterEntities = officialTrimesters.Count > 0 ? officialTrimesters : trimesterEntities,
            SubjectId = subjectId,
            AcademicYearId = activeYear?.Id
        };
    }

    private static async Task<Dictionary<(Guid, Guid), (int, int)>> LoadAttendanceAsync(
        SchoolDbContext context,
        Guid schoolId,
        Guid groupId,
        Guid gradeLevelId,
        Guid? subjectId,
        List<Guid> studentIds,
        List<Trimester> officialTrimesters,
        Guid? academicYearId)
    {
        if (studentIds.Count == 0 || officialTrimesters.Count == 0
            || !subjectId.HasValue || subjectId.Value == Guid.Empty)
            return new Dictionary<(Guid, Guid), (int, int)>();

        var registros = await context.Attendances
            .AsNoTracking()
            .Where(a =>
                a.SubjectId == subjectId
                && a.GroupId == groupId
                && a.GradeId == gradeLevelId
                && (a.SchoolId == null || a.SchoolId == schoolId)
                && a.StudentId.HasValue
                && studentIds.Contains(a.StudentId.Value)
                && (academicYearId == null
                    || a.AcademicYearId == null
                    || a.AcademicYearId == academicYearId))
            .Select(a => new AttendanceSubjectAggregator.AttendanceDayRow
            {
                StudentId = a.StudentId!.Value,
                SchoolId = a.SchoolId,
                GroupId = a.GroupId,
                GradeId = a.GradeId,
                SubjectId = a.SubjectId,
                AcademicYearId = a.AcademicYearId,
                Date = a.Date,
                Status = a.Status
            })
            .ToListAsync();

        var aggregated = AttendanceSubjectAggregator.AggregateByOfficialTrimester(
            registros, officialTrimesters, subjectId.Value, schoolId, groupId, gradeLevelId, academicYearId);

        foreach (var studentId in studentIds)
        {
            foreach (var trim in officialTrimesters)
            {
                if (!aggregated.ContainsKey((studentId, trim.Id)))
                    aggregated[(studentId, trim.Id)] = (0, 0);
            }
        }

        return aggregated;
    }

    public static decimal? CalcularNotaFinal(
        ReportesGrupoBulkData bulk,
        Guid studentId,
        string trimestre,
        IEnumerable<string> palabrasClave)
    {
        bulk.TrimesterNameToId.TryGetValue(trimestre, out var trimesterId);

        var actividadesMateria = bulk.Activities
            .Where(a =>
                ActivityEnTrimestre(a, trimestre, trimesterId) &&
                PalabrasClaveCoinciden(a.SubjectName, palabrasClave))
            .ToList();

        if (actividadesMateria.Count == 0)
            return null;

        var scoreDict = actividadesMateria.ToDictionary(
            a => a.Id,
            a => bulk.Scores.TryGetValue((studentId, a.Id), out var s) ? s : (decimal?)null);

        var acts = actividadesMateria.Select(a => new Activity
        {
            Id = a.Id,
            Type = a.Type
        }).ToList();

        return GradebookFinalGradeCalculator.CalcularNotaFinal(acts, scoreDict);
    }

    /// <summary>
    /// Nota trimestral idéntica a TeacherGradebook/Index (registro de notas):
    /// materia exacta, docente, trimestre+escuela del gradebook, columnas visibles y truncamiento.
    /// </summary>
    public static decimal? CalcularNotaFinalComoGradebook(
        ReportesGrupoBulkData bulk,
        Guid studentId,
        string trimestre,
        Guid subjectId,
        Guid schoolId,
        Guid? teacherId)
    {
        if (!bulk.TrimesterNameToId.TryGetValue(trimestre, out var trimesterId) || trimesterId == Guid.Empty)
            return null;

        var actividades = bulk.Activities
            .Where(a =>
                a.SubjectId == subjectId &&
                (!teacherId.HasValue || a.TeacherId == teacherId.Value) &&
                GradebookActivityScope.MatchesTenantAndTrimester(
                    a.SchoolId, a.TrimesterId, a.Trimester, schoolId, trimesterId, trimestre))
            .OrderBy(a => a.CreatedAt)
            .ToList();

        if (actividades.Count == 0)
            return null;

        var headers = actividades.Select(a => new ActivityHeaderDto
        {
            Id = a.Id,
            Name = a.Name,
            Type = a.Type
        }).ToList();

        var scoreDict = new Dictionary<Guid, decimal?>();
        foreach (var a in actividades)
            scoreDict[a.Id] = bulk.Scores.TryGetValue((studentId, a.Id), out var s) ? s : null;

        return GradebookFinalGradeCalculator.CalcularNotaFinalFromVisibleActivities(headers, scoreDict);
    }

    public static (int Ausencias, int Tardanzas) ContarAsistencia(
        ReportesGrupoBulkData bulk,
        Guid studentId,
        Trimester? trimester)
    {
        if (trimester == null)
            return (0, 0);

        return bulk.Attendance.TryGetValue((studentId, trimester.Id), out var v)
            ? v
            : (0, 0);
    }

    private static bool ActivityEnTrimestre(ReportesActivityRow a, string trimestre, Guid trimesterId)
    {
        if (string.Equals(a.Trimester, trimestre, StringComparison.OrdinalIgnoreCase))
            return true;
        return trimesterId != Guid.Empty && a.TrimesterId.HasValue && a.TrimesterId.Value == trimesterId;
    }

    private static bool PalabrasClaveCoinciden(string subjectName, IEnumerable<string> palabrasClave) =>
        palabrasClave.Any(p => subjectName.Contains(p, StringComparison.OrdinalIgnoreCase));

    /// <summary>Mismo formato que TeacherGradebook: "Apellido, Nombre".</summary>
    private static string FormatearApellidoNombre(string? lastName, string? name)
    {
        var apellido = (lastName ?? "").Trim();
        var nombre = (name ?? "").Trim();
        if (string.IsNullOrEmpty(apellido))
            return nombre;
        if (string.IsNullOrEmpty(nombre))
            return apellido;
        return $"{apellido}, {nombre}";
    }
}
