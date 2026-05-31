using Microsoft.EntityFrameworkCore;
using OfficeOpenXml;
using OfficeOpenXml.Style;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using SchoolManager.ViewModels;
using System.Drawing;

namespace SchoolManager.Services.Implementations;

public class ReportesInstitucionalesService : IReportesInstitucionalesService
{
    private readonly SchoolDbContext _context;
    private readonly IAprobadosReprobadosService _aprobadosReprobadosService;

    private static readonly string[] ColumnasHabitos =
    {
        "Responsabilidad", "Puntualidad", "Honradez", "Conciencia cívica", "Org. Del Trabajo",
        "Autodominio y confianza en sí mismo", "Iniciativa", "Cooperación",
        "Respeto a la propiedad ajena", "Modales", "Orden y Aseo", "Empleo en tiempo libre"
    };

    public ReportesInstitucionalesService(
        SchoolDbContext context,
        IAprobadosReprobadosService aprobadosReprobadosService)
    {
        _context = context;
        _aprobadosReprobadosService = aprobadosReprobadosService;
    }

    public async Task<List<InformeEstudianteFilaDto>> ObtenerEstudiantesGrupoAsync(
        Guid groupId, Guid gradeLevelId, Guid? teacherScopeId, Guid? materiaId = null)
    {
        await ValidarAsignacionAsync(groupId, gradeLevelId, teacherScopeId, materiaId);

        var estudiantes = await _context.StudentAssignments
            .Where(sa => sa.GroupId == groupId && sa.GradeId == gradeLevelId && sa.IsActive)
            .Join(_context.Users,
                sa => sa.StudentId,
                u => u.Id,
                (sa, u) => new { u.Id, u.Name, u.LastName })
            .OrderBy(x => x.LastName).ThenBy(x => x.Name)
            .ToListAsync();

        return estudiantes.Select((e, i) => new InformeEstudianteFilaDto
        {
            Numero = i + 1,
            StudentId = e.Id,
            Nombre = $"{e.Name} {e.LastName}".Trim()
        }).ToList();
    }

    public async Task<byte[]> ExportarHabitosActitudesExcelAsync(
        Guid schoolId,
        string trimestre,
        string nivelEducativo,
        Guid groupId,
        Guid gradeLevelId,
        Guid? teacherScopeId,
        string profesorNombre)
    {
        var school = await _context.Schools.FindAsync(schoolId)
            ?? throw new Exception("Escuela no encontrada");
        var grupo = await _context.Groups.FindAsync(groupId)
            ?? throw new Exception("Grupo no encontrado");
        var gradeLevel = await _context.GradeLevels.FindAsync(gradeLevelId);

        await ValidarAsignacionAsync(groupId, gradeLevelId, teacherScopeId, null);

        var estudiantes = await ObtenerEstudiantesGrupoAsync(groupId, gradeLevelId, teacherScopeId);
        var trimestreLabel = AprobadosReprobadosFiltroValores.EsTodos(trimestre) ? "I" : trimestre;

        using var package = new ExcelPackage();
        var ws = package.Workbook.Worksheets.Add("Hábitos y Actitudes");

        ws.Cells[1, 1].Value = "MINISTERIO DE EDUCACIÓN";
        ws.Cells[2, 1].Value = "DIRECCIÓN REGIONAL DE SAN MIGUELITO";
        ws.Cells[3, 1].Value = school.Name.ToUpperInvariant();
        ws.Cells[4, 1].Value = $"AÑO LECTIVO {DateTime.UtcNow.Year}";
        ws.Cells[6, 1].Value = "HÁBITOS Y ACTITUDES";
        ws.Cells[6, 8].Value = $"Trimestre: {trimestreLabel}";
        ws.Cells[7, 1].Value = $"Profesor(a) Consejero(a): {profesorNombre}";
        ws.Cells[7, 8].Value = $"Grupo: {gradeLevel?.Name} {grupo.Name}";
        ws.Cells[8, 1].Value = "OBSERVACIONES: S = satisfecho, X = no satisfecho, R = regular";

        var headerRow = 10;
        ws.Cells[headerRow, 1].Value = "N°";
        ws.Cells[headerRow, 2].Value = "NOMBRE DEL ESTUDIANTE";
        for (var i = 0; i < ColumnasHabitos.Length; i++)
            ws.Cells[headerRow, 3 + i].Value = ColumnasHabitos[i];

        var row = headerRow + 1;
        foreach (var est in estudiantes)
        {
            ws.Cells[row, 1].Value = est.Numero;
            ws.Cells[row, 2].Value = est.Nombre;
            row++;
        }

        AplicarEstiloEncabezado(ws, headerRow, 2 + ColumnasHabitos.Length);
        ws.Cells[ws.Dimension.Address].AutoFitColumns(8, 40);

        return package.GetAsByteArray();
    }

    public async Task<byte[]> ExportarCalificacionesInformeExcelAsync(
        InformeCalificacionesTipo tipo,
        Guid schoolId,
        string nivelEducativo,
        Guid groupId,
        Guid gradeLevelId,
        Guid? teacherScopeId,
        string consejeroNombre)
    {
        var school = await _context.Schools.FindAsync(schoolId)
            ?? throw new Exception("Escuela no encontrada");
        var grupo = await _context.Groups.FindAsync(groupId)
            ?? throw new Exception("Grupo no encontrado");
        var gradeLevel = await _context.GradeLevels.FindAsync(gradeLevelId);

        await ValidarAsignacionAsync(groupId, gradeLevelId, teacherScopeId, null);

        var estudiantes = await ObtenerEstudiantesGrupoAsync(groupId, gradeLevelId, teacherScopeId);
        var trimestres = await _aprobadosReprobadosService.ObtenerTrimestresDisponiblesAsync(schoolId);
        var columnas = ObtenerColumnasCalificaciones(tipo, gradeLevel?.Name);

        using var package = new ExcelPackage();
        var ws = package.Workbook.Worksheets.Add("Informe");

        ws.Cells[1, 1].Value = "MINISTERIO DE EDUCACIÓN";
        ws.Cells[2, 1].Value = school.Name.ToUpperInvariant();
        ws.Cells[3, 1].Value = $"Informe de Calificaciones-{DateTime.UtcNow.Year}";
        ws.Cells[5, 1].Value = $"Consejero(a): {consejeroNombre}";
        ws.Cells[5, 4].Value = tipo == InformeCalificacionesTipo.ExpresionesArtisticas
            ? "ASIGNATURA: EXPRESIONES ARTÍSTICAS"
            : "ASIGNATURA: TECNOLOGÍA";
        ws.Cells[5, 8].Value = $"GRUPO: {gradeLevel?.Name} {grupo.Name}";

        var col = 1;
        ws.Cells[7, col++].Value = "N°";
        ws.Cells[7, col++].Value = "NOMBRE DE LOS ESTUDIANTES";
        foreach (var t in trimestres)
        {
            ws.Cells[7, col].Value = $"{t} TRIMESTRE";
            ws.Cells[7, col, 7, col + columnas.Count - 1].Merge = true;
            foreach (var c in columnas)
                ws.Cells[8, col++].Value = c.Nombre;
        }
        ws.Cells[7, col].Value = "PROMEDIO FINAL";
        ws.Cells[7, col, 8, col].Merge = true;

        var promediosFinales = new List<decimal?>();
        var row = 9;
        foreach (var est in estudiantes)
        {
            col = 1;
            ws.Cells[row, col++].Value = est.Numero;
            ws.Cells[row, col++].Value = est.Nombre;

            var notasEstudiante = new List<decimal>();
            foreach (var t in trimestres)
            {
                foreach (var c in columnas)
                {
                    var nota = await ObtenerPromedioMateriaTrimestreAsync(
                        est.StudentId, groupId, schoolId, t, c.PalabrasClave);
                    ws.Cells[row, col++].Value = nota.HasValue ? Math.Round(nota.Value, 1) : (object)"";
                    if (nota.HasValue) notasEstudiante.Add(nota.Value);
                }
            }

            var final = notasEstudiante.Count > 0 ? Math.Round(notasEstudiante.Average(), 1) : (decimal?)null;
            ws.Cells[row, col].Value = final.HasValue ? final.Value : "";
            promediosFinales.Add(final);
            row++;
        }

        AplicarEstiloEncabezado(ws, 7, col);
        ws.Cells[ws.Dimension.Address].AutoFitColumns(8, 35);

        return package.GetAsByteArray();
    }

    public async Task<byte[]> ExportarFormatoCarpetasExcelAsync(
        Guid schoolId,
        string nivelEducativo,
        Guid materiaId,
        Guid groupId,
        Guid gradeLevelId,
        Guid? teacherScopeId,
        string consejeroNombre,
        string profesorNombre)
    {
        var school = await _context.Schools.FindAsync(schoolId)
            ?? throw new Exception("Escuela no encontrada");
        var grupo = await _context.Groups.FindAsync(groupId)
            ?? throw new Exception("Grupo no encontrado");
        var gradeLevel = await _context.GradeLevels.FindAsync(gradeLevelId);
        var materia = await _context.Subjects.FindAsync(materiaId)
            ?? throw new Exception("Materia no encontrada");

        await ValidarAsignacionAsync(groupId, gradeLevelId, teacherScopeId, materiaId);

        var estudiantes = await ObtenerEstudiantesGrupoAsync(groupId, gradeLevelId, teacherScopeId, materiaId);
        var trimestres = await _aprobadosReprobadosService.ObtenerTrimestresDisponiblesAsync(schoolId);
        var trimesterEntities = await _context.Trimesters
            .Where(t => t.SchoolId == schoolId && trimestres.Contains(t.Name))
            .ToListAsync();

        using var package = new ExcelPackage();
        var ws = package.Workbook.Worksheets.Add("Premedia");

        ws.Cells[1, 1].Value = "MINISTERIO DE EDUCACIÓN";
        ws.Cells[2, 1].Value = school.Name.ToUpperInvariant();
        ws.Cells[3, 1].Value = "Informe de Calificaciones, Ausencias y Tardanzas";
        ws.Cells[4, 1].Value = $"Año Lectivo {DateTime.UtcNow.Year}";
        ws.Cells[6, 1].Value = $"Consejero(a): {consejeroNombre}";
        ws.Cells[6, 5].Value = $"Profesor(a): {profesorNombre}";
        ws.Cells[8, 1].Value = $"Grupo: {gradeLevel?.Name} {grupo.Name}";
        ws.Cells[8, 5].Value = $"Asignatura: {materia.Name}";

        ws.Cells[10, 1].Value = "N°";
        ws.Cells[10, 2].Value = "Nombre de los Estudiantes";
        ws.Cells[10, 3].Value = "Prom.";
        var col = 4;
        foreach (var t in trimestres)
        {
            ws.Cells[10, col].Value = t;
            ws.Cells[10, col, 10, col + 1].Merge = true;
            ws.Cells[11, col++].Value = "A";
            ws.Cells[11, col++].Value = "T";
        }
        ws.Cells[10, col].Value = "Total";
        ws.Cells[10, col, 10, col + 1].Merge = true;
        ws.Cells[11, col++].Value = "A";
        ws.Cells[11, col].Value = "T";

        var row = 12;
        foreach (var est in estudiantes)
        {
            col = 1;
            ws.Cells[row, col++].Value = est.Numero;
            ws.Cells[row, col++].Value = est.Nombre;

            var promediosTrim = new List<decimal>();
            var totalA = 0;
            var totalT = 0;

            foreach (var t in trimestres)
            {
                var trimesterEntity = trimesterEntities.FirstOrDefault(x => x.Name == t);
                var prom = await ObtenerPromedioMateriaTrimestreAsync(
                    est.StudentId, groupId, schoolId, t, new[] { materia.Name });
                ws.Cells[row, col++].Value = prom.HasValue ? Math.Round(prom.Value, 1) : "";
                if (prom.HasValue) promediosTrim.Add(prom.Value);

                var (ausencias, tardanzas) = await ContarAsistenciaTrimestreAsync(
                    est.StudentId, groupId, trimesterEntity);
                ws.Cells[row, col++].Value = ausencias;
                ws.Cells[row, col++].Value = tardanzas;
                totalA += ausencias;
                totalT += tardanzas;
            }

            ws.Cells[row, 3].Value = promediosTrim.Count > 0
                ? Math.Round(promediosTrim.Average(), 1)
                : "";
            ws.Cells[row, col++].Value = totalA;
            ws.Cells[row, col].Value = totalT;
            row++;
        }

        AplicarEstiloEncabezado(ws, 10, col);
        ws.Cells[ws.Dimension.Address].AutoFitColumns(8, 35);

        return package.GetAsByteArray();
    }

    private async Task ValidarAsignacionAsync(
        Guid groupId, Guid gradeLevelId, Guid? teacherScopeId, Guid? materiaId)
    {
        if (!teacherScopeId.HasValue) return;

        var query = _context.TeacherAssignments.Where(ta =>
            ta.TeacherId == teacherScopeId.Value &&
            ta.SubjectAssignment.GroupId == groupId &&
            ta.SubjectAssignment.GradeLevelId == gradeLevelId);

        if (materiaId.HasValue && materiaId.Value != Guid.Empty)
            query = query.Where(ta => ta.SubjectAssignment.SubjectId == materiaId.Value);

        if (!await query.AnyAsync())
            throw new UnauthorizedAccessException("La asignación seleccionada no está disponible para este docente.");
    }

    private async Task<decimal?> ObtenerPromedioMateriaTrimestreAsync(
        Guid studentId, Guid groupId, Guid schoolId, string trimestre, IEnumerable<string> palabrasClave)
    {
        var trimesterId = await _context.Trimesters
            .Where(t => t.SchoolId == schoolId && t.Name == trimestre)
            .Select(t => (Guid?)t.Id)
            .FirstOrDefaultAsync();

        var scores = await _context.StudentActivityScores
            .Include(s => s.Activity)
            .ThenInclude(a => a!.Subject)
            .Where(s => s.StudentId == studentId &&
                        s.Activity!.GroupId == groupId &&
                        (s.Activity.Trimester == trimestre ||
                         (trimesterId.HasValue && s.Activity.TrimesterId == trimesterId)))
            .ToListAsync();

        var filtradas = scores
            .Where(s => s.Activity?.Subject != null &&
                        palabrasClave.Any(p =>
                            s.Activity.Subject.Name.Contains(p, StringComparison.OrdinalIgnoreCase)))
            .Select(s => s.Score ?? 0)
            .ToList();

        return filtradas.Count > 0 ? filtradas.Average() : null;
    }

    private async Task<(int Ausencias, int Tardanzas)> ContarAsistenciaTrimestreAsync(
        Guid studentId, Guid groupId, Trimester? trimester)
    {
        if (trimester == null) return (0, 0);

        var start = DateOnly.FromDateTime(trimester.StartDate);
        var end = DateOnly.FromDateTime(trimester.EndDate);

        var registros = await _context.Attendances
            .Where(a => a.StudentId == studentId &&
                        a.GroupId == groupId &&
                        a.Date >= start && a.Date <= end)
            .Select(a => a.Status)
            .ToListAsync();

        return (
            registros.Count(s => string.Equals(s, "absent", StringComparison.OrdinalIgnoreCase)),
            registros.Count(s => string.Equals(s, "late", StringComparison.OrdinalIgnoreCase)));
    }

    private static List<(string Nombre, string[] PalabrasClave)> ObtenerColumnasCalificaciones(
        InformeCalificacionesTipo tipo, string? gradeLevelName)
    {
        if (tipo == InformeCalificacionesTipo.ExpresionesArtisticas)
        {
            return new()
            {
                ("EDUC. ARTÍSTICA", new[] { "ART", "ARTÍST", "ARTIST" }),
                ("EDUC. MUSICAL", new[] { "MUSICAL", "MÚSICA", "MUSICA" })
            };
        }

        var esGrado9 = gradeLevelName?.Contains('9') == true ||
                       string.Equals(gradeLevelName, "9", StringComparison.OrdinalIgnoreCase);
        var col1 = esGrado9
            ? ("CONTABILIDAD", new[] { "CONTABIL" })
            : ("COMERCIO", new[] { "COMERC" });

        return new()
        {
            col1,
            ("EDUC. HOGAR", new[] { "HOGAR" }),
            ("ART. INDUSTRIALES", new[] { "INDUSTRIAL", "INDUST" })
        };
    }

    private static void AplicarEstiloEncabezado(ExcelWorksheet ws, int headerRow, int lastCol)
    {
        using var range = ws.Cells[headerRow, 1, headerRow + 1, lastCol];
        range.Style.Font.Bold = true;
        range.Style.Fill.PatternType = ExcelFillStyle.Solid;
        range.Style.Fill.BackgroundColor.SetColor(Color.FromArgb(31, 78, 121));
        range.Style.Font.Color.SetColor(Color.White);
        range.Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
        range.Style.WrapText = true;
    }
}
