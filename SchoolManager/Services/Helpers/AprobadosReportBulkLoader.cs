using Microsoft.EntityFrameworkCore;
using SchoolManager.Models;
using SchoolManager.Services.Helpers;
using SchoolManager.ViewModels;

namespace SchoolManager.Services.Helpers;

public sealed class AprobadosAsignacionKey : IEquatable<AprobadosAsignacionKey>
{
    public Guid SubjectId { get; init; }
    public Guid GroupId { get; init; }
    public Guid GradeLevelId { get; init; }

    public bool Equals(AprobadosAsignacionKey? other) =>
        other != null &&
        SubjectId == other.SubjectId &&
        GroupId == other.GroupId &&
        GradeLevelId == other.GradeLevelId;

    public override bool Equals(object? obj) => obj is AprobadosAsignacionKey k && Equals(k);

    public override int GetHashCode() => HashCode.Combine(SubjectId, GroupId, GradeLevelId);
}

public sealed class AprobadosReportBulkData
{
    public Dictionary<(Guid GroupId, Guid GradeLevelId), List<Guid>> EstudiantesPorGrupo { get; init; } = new();
    public HashSet<Guid> EstudiantesRetirados { get; init; } = new();
    public Dictionary<AprobadosAsignacionKey, List<ReportesActivityRow>> ActividadesPorAsignacion { get; init; } = new();
    public Dictionary<(Guid StudentId, Guid ActivityId), decimal?> Scores { get; init; } = new();
    public Dictionary<AprobadosAsignacionKey, Guid?> TeacherIdPorAsignacion { get; init; } = new();
    public HashSet<AprobadosAsignacionKey> AsignacionesDocentePermitidas { get; init; } = new();
}

public static class AprobadosReportBulkLoader
{
    internal static async Task<AprobadosReportBulkData> LoadAsync(
        SchoolDbContext context,
        IReadOnlyList<AprobadosReprobadosAsignacionRow> asignaciones,
        IReadOnlyList<string> trimestresNombres,
        IReadOnlyList<Guid> trimesterIds,
        Guid? teacherScopeId)
    {
        var grupoGradePairs = asignaciones
            .Select(a => (a.GroupId, a.GradeLevelId))
            .Distinct()
            .ToList();

        var groupIds = grupoGradePairs.Select(p => p.GroupId).Distinct().ToList();

        var estudiantesPorGrupo = new Dictionary<(Guid, Guid), List<Guid>>();
        if (groupIds.Count > 0)
        {
            var rows = await context.StudentAssignments
                .AsNoTracking()
                .Where(sa => groupIds.Contains(sa.GroupId) && sa.IsActive)
                .Select(sa => new { sa.GroupId, sa.GradeId, sa.StudentId })
                .ToListAsync();

            foreach (var pair in grupoGradePairs)
            {
                estudiantesPorGrupo[pair] = rows
                    .Where(r => r.GroupId == pair.GroupId && r.GradeId == pair.GradeLevelId)
                    .Select(r => r.StudentId)
                    .Distinct()
                    .ToList();
            }
        }

        var allStudentIds = estudiantesPorGrupo.Values.SelectMany(x => x).Distinct().ToList();

        var retirados = allStudentIds.Count == 0
            ? new HashSet<Guid>()
            : (await context.Users
                .AsNoTracking()
                .Where(u => allStudentIds.Contains(u.Id))
                .Select(u => new { u.Id, u.Status })
                .ToListAsync())
                .Where(u => string.Equals(u.Status, "inactive", StringComparison.OrdinalIgnoreCase) ||
                            string.Equals(u.Status, "retirado", StringComparison.OrdinalIgnoreCase))
                .Select(u => u.Id)
                .ToHashSet();

        var subjectIds = asignaciones.Select(a => a.SubjectId).Distinct().ToList();

        var activitiesRaw = await context.Activities
            .AsNoTracking()
            .Where(a =>
                groupIds.Contains(a.GroupId!.Value) &&
                subjectIds.Contains(a.SubjectId!.Value) &&
                (trimestresNombres.Contains(a.Trimester!) ||
                 (a.TrimesterId.HasValue && trimesterIds.Contains(a.TrimesterId.Value))))
            .Select(a => new
            {
                a.Id,
                a.Type,
                a.Trimester,
                a.TrimesterId,
                a.SubjectId,
                SubjectName = a.Subject!.Name,
                a.GroupId,
                a.GradeLevelId,
                a.TeacherId
            })
            .ToListAsync();

        var actividadesPorAsignacion = new Dictionary<AprobadosAsignacionKey, List<ReportesActivityRow>>();
        foreach (var a in asignaciones)
        {
            var key = new AprobadosAsignacionKey
            {
                SubjectId = a.SubjectId,
                GroupId = a.GroupId,
                GradeLevelId = a.GradeLevelId
            };

            var teacherId = teacherScopeId;
            if (!teacherId.HasValue)
            {
                teacherId = activitiesRaw
                    .Where(x => x.GroupId == a.GroupId && x.GradeLevelId == a.GradeLevelId && x.SubjectId == a.SubjectId)
                    .Select(x => x.TeacherId)
                    .FirstOrDefault();
            }

            var acts = activitiesRaw
                .Where(x =>
                    x.GroupId == a.GroupId &&
                    x.GradeLevelId == a.GradeLevelId &&
                    x.SubjectId == a.SubjectId &&
                    (!teacherId.HasValue || x.TeacherId == teacherId))
                .Select(x => new ReportesActivityRow
                {
                    Id = x.Id,
                    Type = x.Type,
                    Trimester = x.Trimester,
                    TrimesterId = x.TrimesterId,
                    SubjectId = x.SubjectId,
                    SubjectName = x.SubjectName
                })
                .ToList();

            actividadesPorAsignacion[key] = acts;
        }

        var activityIds = activitiesRaw.Select(x => x.Id).Distinct().ToList();
        var scores = activityIds.Count == 0 || allStudentIds.Count == 0
            ? new Dictionary<(Guid, Guid), decimal?>()
            : (await context.StudentActivityScores
                .AsNoTracking()
                .Where(s => allStudentIds.Contains(s.StudentId) && activityIds.Contains(s.ActivityId))
                .Select(s => new { s.StudentId, s.ActivityId, s.Score })
                .ToListAsync())
                .ToDictionary(s => (s.StudentId, s.ActivityId), s => s.Score);

        var permitidas = new HashSet<AprobadosAsignacionKey>();
        if (teacherScopeId.HasValue)
        {
            var allowed = await context.TeacherAssignments
                .AsNoTracking()
                .Where(ta =>
                    ta.TeacherId == teacherScopeId.Value &&
                    groupIds.Contains(ta.SubjectAssignment.GroupId))
                .Select(ta => new
                {
                    ta.SubjectAssignment.SubjectId,
                    ta.SubjectAssignment.GroupId,
                    ta.SubjectAssignment.GradeLevelId
                })
                .ToListAsync();

            foreach (var x in allowed)
            {
                permitidas.Add(new AprobadosAsignacionKey
                {
                    SubjectId = x.SubjectId,
                    GroupId = x.GroupId,
                    GradeLevelId = x.GradeLevelId
                });
            }
        }

        var teacherPorAsignacion = new Dictionary<AprobadosAsignacionKey, Guid?>();
        foreach (var a in asignaciones)
        {
            var key = new AprobadosAsignacionKey
            {
                SubjectId = a.SubjectId,
                GroupId = a.GroupId,
                GradeLevelId = a.GradeLevelId
            };
            teacherPorAsignacion[key] = teacherScopeId ?? activitiesRaw
                .Where(x => x.GroupId == a.GroupId && x.GradeLevelId == a.GradeLevelId && x.SubjectId == a.SubjectId)
                .Select(x => x.TeacherId)
                .FirstOrDefault();
        }

        return new AprobadosReportBulkData
        {
            EstudiantesPorGrupo = estudiantesPorGrupo,
            EstudiantesRetirados = retirados,
            ActividadesPorAsignacion = actividadesPorAsignacion,
            Scores = scores,
            TeacherIdPorAsignacion = teacherPorAsignacion,
            AsignacionesDocentePermitidas = permitidas
        };
    }

    internal static (int Total, int Aprobados, decimal PorcentajeAprobados,
        int Reprobados, decimal PorcentajeReprobados,
        int ReprobadosHastaLaFecha, decimal PorcentajeReprobadosHastaLaFecha,
        int SinCalificaciones, decimal PorcentajeSinCalificaciones,
        int Retirados, decimal PorcentajeRetirados)
        CalcularEstadisticas(
            AprobadosReportBulkData bulk,
            AprobadosReprobadosAsignacionRow asignacion,
            IReadOnlyList<string> trimestresNombres,
            Guid? teacherScopeId,
            decimal notaMinimaAprobacion)
    {
        var key = new AprobadosAsignacionKey
        {
            SubjectId = asignacion.SubjectId,
            GroupId = asignacion.GroupId,
            GradeLevelId = asignacion.GradeLevelId
        };

        if (teacherScopeId.HasValue && !bulk.AsignacionesDocentePermitidas.Contains(key))
        {
            if (!bulk.EstudiantesPorGrupo.TryGetValue((asignacion.GroupId, asignacion.GradeLevelId), out var estudiantesSinPermiso))
                estudiantesSinPermiso = new List<Guid>();
            var totalSinPermiso = estudiantesSinPermiso.Count;
            return (totalSinPermiso, 0, 0, 0, 0, 0, 0, totalSinPermiso, 100m, 0, 0);
        }

        if (!bulk.EstudiantesPorGrupo.TryGetValue((asignacion.GroupId, asignacion.GradeLevelId), out var estudiantes))
            estudiantes = new List<Guid>();

        var total = estudiantes.Count;
        if (total == 0)
            return (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

        bulk.ActividadesPorAsignacion.TryGetValue(key, out var actividades);
        actividades ??= new List<ReportesActivityRow>();

        int aprobados = 0, reprobados = 0, sinCalificaciones = 0, retirados = 0;

        foreach (var estudianteId in estudiantes)
        {
            if (bulk.EstudiantesRetirados.Contains(estudianteId))
            {
                retirados++;
                continue;
            }

            var scoreDict = actividades.ToDictionary(
                a => a.Id,
                a => bulk.Scores.TryGetValue((estudianteId, a.Id), out var s) ? s : (decimal?)null);

            var notasFinales = new List<decimal>();
            foreach (var trimestre in trimestresNombres)
            {
                var actsTrimestre = actividades
                    .Where(a => string.Equals(a.Trimester, trimestre, StringComparison.OrdinalIgnoreCase))
                    .Select(a => new Activity { Id = a.Id, Type = a.Type })
                    .ToList();

                if (actsTrimestre.Count == 0)
                    continue;

                var notaFinal = GradebookFinalGradeCalculator.CalcularNotaFinal(actsTrimestre, scoreDict);
                if (notaFinal.HasValue)
                    notasFinales.Add(notaFinal.Value);
            }

            if (notasFinales.Count == 0)
            {
                sinCalificaciones++;
                continue;
            }

            if (notasFinales.Any(n => n < notaMinimaAprobacion))
                reprobados++;
            else
                aprobados++;
        }

        return (
            total,
            aprobados,
            total > 0 ? aprobados * 100m / total : 0,
            reprobados,
            total > 0 ? reprobados * 100m / total : 0,
            reprobados,
            total > 0 ? reprobados * 100m / total : 0,
            sinCalificaciones,
            total > 0 ? sinCalificaciones * 100m / total : 0,
            retirados,
            total > 0 ? retirados * 100m / total : 0);
    }
}
