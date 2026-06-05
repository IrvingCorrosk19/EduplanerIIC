using Microsoft.EntityFrameworkCore;
using NPOI.HSSF.UserModel;
using OfficeOpenXml;
using OfficeOpenXml.Style;
using SchoolManager.Models;
using SchoolManager.Services.Interfaces;
using SchoolManager.ViewModels;
using System.Drawing;
using System.Text.RegularExpressions;

namespace SchoolManager.Services.Implementations;

public class ReportesInstitucionalesService : IReportesInstitucionalesService
{
    private const int FilaDatosCalificaciones0 = 9;
    private const int MaxFilasEstudiantesCalificaciones = 75;
    private const int FilaDatosCarpetas0 = 12;
    private const int MaxFilasEstudiantesCarpetas = 40;

    private readonly SchoolDbContext _context;
    private readonly IAprobadosReprobadosService _aprobadosReprobadosService;
    private readonly IWebHostEnvironment _environment;

    private static readonly string[] ColumnasHabitos =
    {
        "Responsabilidad", "Puntualidad", "Honradez", "Conciencia cívica", "Org. Del Trabajo",
        "Autodominio y confianza en sí mismo", "Iniciativa", "Cooperación",
        "Respeto a la propiedad ajena", "Modales", "Orden y Aseo", "Empleo en tiempo libre"
    };

    public ReportesInstitucionalesService(
        SchoolDbContext context,
        IAprobadosReprobadosService aprobadosReprobadosService,
        IWebHostEnvironment environment)
    {
        _context = context;
        _aprobadosReprobadosService = aprobadosReprobadosService;
        _environment = environment;
    }

    private string ReportesDir => Path.Combine(_environment.ContentRootPath, "Reportes");

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
        var trimestreLabel = FormatearEtiquetaTrimestre(trimestre);
        var etiquetaGrupo = FormatearEtiquetaGrupoInforme(gradeLevel?.Name, grupo.Name, grupo.Grade);
        var anio = DateTime.UtcNow.Year;

        using var package = new ExcelPackage();
        var ws = package.Workbook.Worksheets.Add("Hábitos y Actitudes");
        var ultimaCol = 2 + ColumnasHabitos.Length;

        ws.Cells[1, 1, 1, ultimaCol].Merge = true;
        ws.Cells[1, 1].Value = "MINISTERIO DE EDUCACIÓN";
        ws.Cells[2, 1, 2, ultimaCol].Merge = true;
        ws.Cells[2, 1].Value = "DIRECCIÓN REGIONAL DE SAN MIGUELITO";
        ws.Cells[3, 1, 3, ultimaCol].Merge = true;
        ws.Cells[3, 1].Value = school.Name.ToUpperInvariant();
        ws.Cells[4, 1, 4, ultimaCol].Merge = true;
        ws.Cells[4, 1].Value = $"AÑO LECTIVO {anio}";

        ws.Cells[6, 1, 6, ultimaCol - 2].Merge = true;
        ws.Cells[6, 1].Value = "HÁBITOS Y ACTITUDES";
        ws.Cells[6, ultimaCol - 1, 6, ultimaCol].Merge = true;
        ws.Cells[6, ultimaCol - 1].Value = trimestreLabel;

        ws.Cells[7, 1, 7, 6].Merge = true;
        ws.Cells[7, 1].Value = $"Profesor(a) Consejero(a): {profesorNombre}";
        ws.Cells[7, 7, 7, ultimaCol].Merge = true;
        ws.Cells[7, 7].Value = $"Grupo: {etiquetaGrupo}";

        ws.Cells[8, 1, 8, ultimaCol].Merge = true;
        ws.Cells[8, 1].Value = "OBSERVACIONES: S = satisfecho, X = no satisfecho, R = regular";

        const int headerRow = 10;
        ws.Cells[headerRow, 1].Value = "N°";
        ws.Cells[headerRow, 2].Value = "NOMBRE DEL ESTUDIANTE";
        for (var i = 0; i < ColumnasHabitos.Length; i++)
            ws.Cells[headerRow, 3 + i].Value = ColumnasHabitos[i];

        var filaFin = headerRow + Math.Max(estudiantes.Count, 35);
        for (var i = 0; i < estudiantes.Count; i++)
        {
            var est = estudiantes[i];
            var row = headerRow + 1 + i;
            ws.Cells[row, 1].Value = est.Numero;
            ws.Cells[row, 2].Value = est.Nombre;
        }

        AplicarEstiloCuadroOficial(ws, 1, filaFin, ultimaCol, headerRow);
        ws.Column(1).Width = 5;
        ws.Column(2).Width = 38;
        for (var c = 3; c <= ultimaCol; c++)
            ws.Column(c).Width = 11;

        var filaPie = filaFin + 2;
        ws.Cells[filaPie, 1, filaPie, 6].Merge = true;
        ws.Cells[filaPie, 1].Value = "Profesor(a): _________________________";
        ws.Cells[filaPie, 7, filaPie, ultimaCol].Merge = true;
        ws.Cells[filaPie, 7].Value = "Consejero(a): _________________________";
        ws.Cells[filaPie + 1, 1, filaPie + 1, 4].Merge = true;
        ws.Cells[filaPie + 1, 1].Value = $"Grupo: {etiquetaGrupo}";
        ws.Cells[filaPie + 1, 5, filaPie + 1, ultimaCol].Merge = true;
        ws.Cells[filaPie + 1, 5].Value = "Jornada: _________________________";

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
        var etiquetaGrupo = FormatearEtiquetaGrupoInforme(gradeLevel?.Name, grupo.Name, grupo.Grade);
        var anio = DateTime.UtcNow.Year;

        var nombreParcial = tipo == InformeCalificacionesTipo.ExpresionesArtisticas
            ? "Exp"
            : "Tecnolog";
        var ruta = ReportePlantillaNpoiHelper.ResolverPlantilla(ReportesDir, nombreParcial);
        var workbook = ReportePlantillaNpoiHelper.CargarPlantilla(ruta);
        var sheet = workbook.GetSheetAt(0);

        ReportePlantillaNpoiHelper.EstablecerTexto(sheet, 2, 0, school.Name.ToUpperInvariant());
        ReportePlantillaNpoiHelper.EstablecerTexto(sheet, 3, 0, $"Informe de Calificaciones-{anio}");

        if (tipo == InformeCalificacionesTipo.Tecnologia)
        {
            ReportePlantillaNpoiHelper.EstablecerTexto(sheet, 6, 0, $"Consejero (a): {consejeroNombre}");
            ReportePlantillaNpoiHelper.EstablecerTexto(sheet, 6, 11, $"GRUPO: {etiquetaGrupo}");
        }
        else
        {
            ReportePlantillaNpoiHelper.EstablecerTexto(sheet, 5, 0, $"CONSEJERO (A): {consejeroNombre}");
            ReportePlantillaNpoiHelper.EstablecerTexto(sheet, 5, 10, $"GRADO: {etiquetaGrupo}");
        }

        var ultimaCol = tipo == InformeCalificacionesTipo.Tecnologia ? 14 : 11;
        ReportePlantillaNpoiHelper.LimpiarRangoDatos(
            sheet, FilaDatosCalificaciones0, FilaDatosCalificaciones0 + MaxFilasEstudiantesCalificaciones - 1,
            0, ultimaCol);

        var bloquesColumnas = tipo == InformeCalificacionesTipo.Tecnologia
            ? new[] { new[] { 2, 3, 4 }, new[] { 6, 7, 8 }, new[] { 10, 11, 12 } }
            : new[] { new[] { 2, 3 }, new[] { 5, 6 }, new[] { 8, 9 } };
        var colPromedio = tipo == InformeCalificacionesTipo.Tecnologia ? 14 : 11;

        for (var i = 0; i < estudiantes.Count; i++)
        {
            var est = estudiantes[i];
            var fila = FilaDatosCalificaciones0 + i;
            ReportePlantillaNpoiHelper.EstablecerNumero(sheet, fila, 0, est.Numero);
            ReportePlantillaNpoiHelper.EstablecerTexto(sheet, fila, 1, est.Nombre);

            var notasPorSlot = new decimal?[3][];
            for (var s = 0; s < 3; s++)
                notasPorSlot[s] = new decimal?[columnas.Count];

            foreach (var trimNombre in trimestres)
            {
                var slot = ResolverSlotTrimestreInforme(trimNombre);
                if (!slot.HasValue || slot.Value < 0 || slot.Value >= bloquesColumnas.Length)
                    continue;

                var cols = bloquesColumnas[slot.Value];
                for (var j = 0; j < columnas.Count && j < cols.Length; j++)
                {
                    var nota = await ObtenerNotaFinalMateriaTrimestreAsync(
                        est.StudentId, groupId, gradeLevelId, schoolId, trimNombre, columnas[j].PalabrasClave);
                    ReportePlantillaNpoiHelper.EstablecerNota(sheet, fila, cols[j], nota);
                    notasPorSlot[slot.Value][j] = nota;
                }
            }

            var final = CalcularPromedioFinalInformeCalificaciones(notasPorSlot);
            ReportePlantillaNpoiHelper.EstablecerNota(sheet, fila, colPromedio, final);
        }

        return ReportePlantillaNpoiHelper.EscribirLibro(workbook);
    }

    public async Task<CalificacionesTecnologiaReportViewModel> ObtenerCalificacionesTecnologiaReporteAsync(
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
        var columnas = ObtenerColumnasCalificaciones(InformeCalificacionesTipo.Tecnologia, gradeLevel?.Name);
        var etiquetaGrupo = FormatearEtiquetaGrupoInforme(gradeLevel?.Name, grupo.Name, grupo.Grade);
        var anio = DateTime.UtcNow.Year;

        var filas = new List<CalificacionesTecnologiaFilaViewModel>();
        foreach (var est in estudiantes)
        {
            var notasPorSlot = new decimal?[3][];
            for (var s = 0; s < 3; s++)
                notasPorSlot[s] = new decimal?[columnas.Count];

            foreach (var trimNombre in trimestres)
            {
                var slot = ResolverSlotTrimestreInforme(trimNombre);
                if (!slot.HasValue || slot.Value < 0 || slot.Value > 2)
                    continue;

                for (var j = 0; j < columnas.Count; j++)
                {
                    var nota = await ObtenerNotaFinalMateriaTrimestreAsync(
                        est.StudentId, groupId, gradeLevelId, schoolId, trimNombre, columnas[j].PalabrasClave);
                    notasPorSlot[slot.Value][j] = nota;
                }
            }

            filas.Add(new CalificacionesTecnologiaFilaViewModel
            {
                Numero = est.Numero,
                Nombre = est.Nombre,
                NotaT1Area1 = notasPorSlot[0].ElementAtOrDefault(0),
                NotaT1Area2 = notasPorSlot[0].ElementAtOrDefault(1),
                NotaT1Area3 = notasPorSlot[0].ElementAtOrDefault(2),
                NotaT2Area1 = notasPorSlot[1].ElementAtOrDefault(0),
                NotaT2Area2 = notasPorSlot[1].ElementAtOrDefault(1),
                NotaT2Area3 = notasPorSlot[1].ElementAtOrDefault(2),
                NotaT3Area1 = notasPorSlot[2].ElementAtOrDefault(0),
                NotaT3Area2 = notasPorSlot[2].ElementAtOrDefault(1),
                NotaT3Area3 = notasPorSlot[2].ElementAtOrDefault(2),
                PromedioFinal = CalcularPromedioFinalInformeCalificaciones(notasPorSlot)
            });
        }

        var trimestresEncabezado = new List<string>();
        for (var i = 0; i < 3; i++)
            trimestresEncabezado.Add(FormatearEncabezadoTrimestrePlantilla(trimestres, i));

        return new CalificacionesTecnologiaReportViewModel
        {
            LogoUrl = school.LogoUrl ?? "",
            InstitutoNombre = school.Name.ToUpperInvariant(),
            TituloInforme = $"Informe de Calificaciones-{anio}",
            ConsejeroNombre = consejeroNombre,
            GrupoEtiqueta = etiquetaGrupo,
            Areas = columnas.Select(c => c.Nombre).ToList(),
            TrimestresEncabezado = trimestresEncabezado,
            Filas = filas,
            FilasPlantillaVacias = Math.Max(0, MaxFilasEstudiantesCalificaciones - filas.Count)
        };
    }

    public async Task<HabitosActitudesReportViewModel> ObtenerHabitosActitudesReporteAsync(
        Guid schoolId,
        string trimestre,
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
        var etiquetaGrupo = FormatearEtiquetaGrupoInforme(gradeLevel?.Name, grupo.Name, grupo.Grade);
        var anio = DateTime.UtcNow.Year;
        const int maxFilas = 40;

        return new HabitosActitudesReportViewModel
        {
            LogoUrl = school.LogoUrl ?? "",
            InstitutoNombre = school.Name.ToUpperInvariant(),
            AnioLectivoLinea = $"AÑO LECTIVO {anio}",
            TrimestreLinea = FormatearEtiquetaTrimestre(trimestre),
            ConsejeroNombre = consejeroNombre,
            GrupoEtiqueta = etiquetaGrupo,
            ColumnasHabitos = ColumnasHabitos.ToList(),
            Filas = estudiantes.Select(e => new HabitosActitudesFilaViewModel
            {
                Numero = e.Numero,
                Nombre = e.Nombre
            }).ToList(),
            FilasPlantillaVacias = Math.Max(0, maxFilas - estudiantes.Count)
        };
    }

    public async Task<CalificacionesExpresionesArtisticasReportViewModel> ObtenerCalificacionesExpresionesArtisticasReporteAsync(
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
        var columnas = ObtenerColumnasCalificaciones(InformeCalificacionesTipo.ExpresionesArtisticas, gradeLevel?.Name);
        var etiquetaGrado = FormatearEtiquetaGrupoInforme(gradeLevel?.Name, grupo.Name, grupo.Grade);
        var anio = DateTime.UtcNow.Year;

        var filas = new List<CalificacionesExpresionesArtisticasFilaViewModel>();
        foreach (var est in estudiantes)
        {
            var notas = new decimal?[6];

            foreach (var trimNombre in trimestres)
            {
                var slot = ResolverSlotTrimestreInforme(trimNombre);
                if (!slot.HasValue || slot.Value < 0 || slot.Value > 2)
                    continue;

                for (var j = 0; j < columnas.Count && j < 2; j++)
                {
                    var nota = await ObtenerNotaFinalMateriaTrimestreAsync(
                        est.StudentId, groupId, gradeLevelId, schoolId, trimNombre, columnas[j].PalabrasClave);
                    notas[slot.Value * 2 + j] = nota;
                }
            }

            filas.Add(new CalificacionesExpresionesArtisticasFilaViewModel
            {
                Numero = est.Numero,
                Nombre = est.Nombre,
                NotaT1Artistica = notas[0],
                NotaT1Musical = notas[1],
                NotaT2Artistica = notas[2],
                NotaT2Musical = notas[3],
                NotaT3Artistica = notas[4],
                NotaT3Musical = notas[5],
                PromedioFinal = CalcularPromedioFinalInformeCalificaciones(
                    new[] { SliceNotasTrimestre(notas, 0), SliceNotasTrimestre(notas, 1), SliceNotasTrimestre(notas, 2) })
            });
        }

        var trimestresEncabezado = new List<string>();
        for (var i = 0; i < 3; i++)
            trimestresEncabezado.Add(FormatearEncabezadoTrimestrePlantilla(trimestres, i));

        return new CalificacionesExpresionesArtisticasReportViewModel
        {
            LogoUrl = school.LogoUrl ?? "",
            InstitutoNombre = school.Name.ToUpperInvariant(),
            TituloInforme = $"Informe de Calificaciones-{anio}",
            ConsejeroNombre = consejeroNombre,
            GradoEtiqueta = etiquetaGrado,
            TrimestresEncabezado = trimestresEncabezado,
            Filas = filas,
            FilasPlantillaVacias = Math.Max(0, MaxFilasEstudiantesCalificaciones - filas.Count)
        };
    }

    public async Task<FormatoCarpetasReportViewModel> ObtenerFormatoCarpetasReporteAsync(
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

        var etiquetaGrupo = FormatearEtiquetaGrupoInforme(gradeLevel?.Name, grupo.Name, grupo.Grade);
        var anio = DateTime.UtcNow.Year;
        var filas = new List<FormatoCarpetasFilaViewModel>();

        foreach (var est in estudiantes)
        {
            var promediosTrim = new List<decimal>();
            var totalA = 0;
            var totalT = 0;
            decimal? n1 = null, n2 = null, n3 = null;
            int a1 = 0, t1 = 0, a2 = 0, t2 = 0, a3 = 0, t3 = 0;

            for (var i = 0; i < trimestres.Count && i < 3; i++)
            {
                var trimesterEntity = trimesterEntities.FirstOrDefault(x => x.Name == trimestres[i]);
                var prom = await ObtenerNotaFinalMateriaTrimestreAsync(
                    est.StudentId, groupId, gradeLevelId, schoolId, trimestres[i], new[] { materia.Name });
                var (ausencias, tardanzas) = await ContarAsistenciaTrimestreAsync(
                    est.StudentId, groupId, trimesterEntity);

                if (i == 0) { n1 = prom; a1 = ausencias; t1 = tardanzas; }
                else if (i == 1) { n2 = prom; a2 = ausencias; t2 = tardanzas; }
                else { n3 = prom; a3 = ausencias; t3 = tardanzas; }

                if (prom.HasValue) promediosTrim.Add(prom.Value);
                totalA += ausencias;
                totalT += tardanzas;
            }

            filas.Add(new FormatoCarpetasFilaViewModel
            {
                Numero = est.Numero,
                Nombre = est.Nombre,
                NotaTrim1 = n1,
                NotaTrim2 = n2,
                NotaTrim3 = n3,
                PromedioFinal = promediosTrim.Count > 0 ? Math.Round(promediosTrim.Average(), 1) : null,
                AusenciasT1 = a1,
                TardanzasT1 = t1,
                AusenciasT2 = a2,
                TardanzasT2 = t2,
                AusenciasT3 = a3,
                TardanzasT3 = t3,
                TotalAusencias = totalA,
                TotalTardanzas = totalT
            });
        }

        return new FormatoCarpetasReportViewModel
        {
            LogoUrl = school.LogoUrl ?? "",
            InstitutoNombre = school.Name.ToUpperInvariant(),
            AnioLectivoLinea = $" Año Lectivo {anio}",
            ConsejeroNombre = consejeroNombre,
            ProfesorNombre = profesorNombre,
            GrupoEtiqueta = etiquetaGrupo,
            MateriaNombre = materia.Name,
            TrimestresEncabezado = trimestres.Take(3).ToList(),
            Filas = filas,
            FilasPlantillaVacias = Math.Max(0, MaxFilasEstudiantesCarpetas - filas.Count)
        };
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

        var etiquetaGrupo = FormatearEtiquetaGrupoInforme(gradeLevel?.Name, grupo.Name, grupo.Grade);
        var anio = DateTime.UtcNow.Year;
        var ruta = ReportePlantillaNpoiHelper.ResolverPlantilla(ReportesDir, "Carpetas");
        var workbook = ReportePlantillaNpoiHelper.CargarPlantilla(ruta);
        var sheet = workbook.GetSheetAt(0);

        ReportePlantillaNpoiHelper.EstablecerTexto(sheet, 1, 0, school.Name.ToUpperInvariant());
        ReportePlantillaNpoiHelper.EstablecerTexto(sheet, 2, 0, "Informe de Calificaciones, Ausencias y Tardanzas");
        ReportePlantillaNpoiHelper.EstablecerTexto(sheet, 3, 1, $" Año Lectivo {anio}");
        ReportePlantillaNpoiHelper.EstablecerTexto(sheet, 5, 1, $"Consejero (a): {consejeroNombre}");
        ReportePlantillaNpoiHelper.EstablecerTexto(sheet, 5, 4, $"Profesor (a): {profesorNombre}");
        ReportePlantillaNpoiHelper.EstablecerTexto(sheet, 7, 1, $"Grupo: {etiquetaGrupo}");
        ReportePlantillaNpoiHelper.EstablecerTexto(sheet, 7, 6, $"Asignatura: {materia.Name}");

        ReportePlantillaNpoiHelper.LimpiarRangoDatos(
            sheet, FilaDatosCarpetas0, FilaDatosCarpetas0 + MaxFilasEstudiantesCarpetas - 1,
            0, 13);

        var colsNotaTrim = new[] { 2, 3, 4 };
        var colsAt = new[] { (6, 7), (8, 9), (10, 11) };

        for (var i = 0; i < estudiantes.Count; i++)
        {
            var est = estudiantes[i];
            var fila = FilaDatosCarpetas0 + i;
            ReportePlantillaNpoiHelper.EstablecerNumero(sheet, fila, 0, est.Numero);
            ReportePlantillaNpoiHelper.EstablecerTexto(sheet, fila, 1, est.Nombre);

            var promediosTrim = new List<decimal>();
            var totalA = 0;
            var totalT = 0;

            for (var t = 0; t < trimestres.Count && t < colsNotaTrim.Length; t++)
            {
                var trimesterEntity = trimesterEntities.FirstOrDefault(x => x.Name == trimestres[t]);
                var prom = await ObtenerNotaFinalMateriaTrimestreAsync(
                    est.StudentId, groupId, gradeLevelId, schoolId, trimestres[t], new[] { materia.Name });
                ReportePlantillaNpoiHelper.EstablecerNota(sheet, fila, colsNotaTrim[t], prom);
                if (prom.HasValue)
                    promediosTrim.Add(prom.Value);

                var (ausencias, tardanzas) = await ContarAsistenciaTrimestreAsync(
                    est.StudentId, groupId, trimesterEntity);
                var (colA, colT) = colsAt[t];
                ReportePlantillaNpoiHelper.EstablecerNumero(sheet, fila, colA, ausencias);
                ReportePlantillaNpoiHelper.EstablecerNumero(sheet, fila, colT, tardanzas);
                totalA += ausencias;
                totalT += tardanzas;
            }

            var promFinal = promediosTrim.Count > 0
                ? Math.Round(promediosTrim.Average(), 1)
                : (decimal?)null;
            ReportePlantillaNpoiHelper.EstablecerNota(sheet, fila, 5, promFinal);
            ReportePlantillaNpoiHelper.EstablecerNumero(sheet, fila, 12, totalA);
            ReportePlantillaNpoiHelper.EstablecerNumero(sheet, fila, 13, totalT);
        }

        return ReportePlantillaNpoiHelper.EscribirLibro(workbook);
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

    private async Task<decimal?> ObtenerNotaFinalMateriaTrimestreAsync(
        Guid studentId,
        Guid groupId,
        Guid gradeLevelId,
        Guid schoolId,
        string trimestre,
        IEnumerable<string> palabrasClave)
    {
        var trimesterId = await _context.Trimesters
            .Where(t => t.SchoolId == schoolId && t.Name == trimestre)
            .Select(t => (Guid?)t.Id)
            .FirstOrDefaultAsync();

        var actividades = await _context.Activities
            .AsNoTracking()
            .Include(a => a.Subject)
            .Where(a =>
                a.GroupId == groupId &&
                a.GradeLevelId == gradeLevelId &&
                (a.SchoolId == schoolId || a.SchoolId == null) &&
                (a.Trimester == trimestre ||
                 (trimesterId.HasValue && a.TrimesterId == trimesterId)))
            .ToListAsync();

        var actividadesMateria = actividades
            .Where(a => a.Subject != null &&
                        PalabrasClaveCoinciden(a.Subject.Name, palabrasClave))
            .ToList();

        if (actividadesMateria.Count == 0)
            return null;

        var activityIds = actividadesMateria.Select(a => a.Id).ToList();
        var scores = await _context.StudentActivityScores
            .AsNoTracking()
            .Where(s => s.StudentId == studentId && activityIds.Contains(s.ActivityId))
            .ToDictionaryAsync(s => s.ActivityId, s => s.Score);

        return CalcularNotaFinalLibroCalificaciones(actividadesMateria, scores);
    }

    /// <summary>
    /// Misma lógica que TeacherGradebook (calcAverages): promedios por tipo y nota final con recuperación.
    /// </summary>
    private static decimal? CalcularNotaFinalLibroCalificaciones(
        List<Activity> actividadesMateria,
        Dictionary<Guid, decimal?> scores)
    {
        var typeOrder = new[]
        {
            "notas de apreciación",
            "ejercicios diarios",
            "examen final",
            "recuperación"
        };

        var typeAvgs = new Dictionary<string, decimal>();
        foreach (var typeKey in typeOrder)
        {
            var acts = actividadesMateria
                .Where(a => NormalizeActivityType(a.Type) == typeKey)
                .ToList();
            if (acts.Count == 0)
                continue;

            var values = acts
                .Select(a => scores.TryGetValue(a.Id, out var v) ? v : null)
                .Where(v => v.HasValue && v.Value > 0)
                .Select(v => v!.Value)
                .ToList();

            typeAvgs[typeKey] = values.Count > 0 ? TruncateOneDecimal(values.Average()) : 0m;
        }

        if (typeAvgs.Count == 0)
            return null;

        return ComputeFinalGradeFromTypeAverages(typeAvgs);
    }

    private static decimal ComputeFinalGradeFromTypeAverages(Dictionary<string, decimal> typeAvgs)
    {
        var working = new Dictionary<string, decimal>(typeAvgs);

        if (working.TryGetValue("recuperación", out var recup) && recup > 0)
            working["examen final"] = recup;

        var typesForFinal = working.Keys
            .Where(t => t != "recuperación")
            .Where(t => working[t] > 0)
            .ToList();

        if (typesForFinal.Count == 0)
            return 0m;

        return TruncateOneDecimal(typesForFinal.Average(t => working[t]));
    }

    private static bool PalabrasClaveCoinciden(string subjectName, IEnumerable<string> palabrasClave) =>
        palabrasClave.Any(p => subjectName.Contains(p, StringComparison.OrdinalIgnoreCase));

    private static string NormalizeActivityType(string? type) => (type ?? "").Trim().ToLowerInvariant();

    private static decimal TruncateOneDecimal(decimal value) => Math.Floor(value * 10m) / 10m;

    private static int? ExtractGradeNumber(string? name)
    {
        if (string.IsNullOrWhiteSpace(name))
            return null;
        var match = Regex.Match(name, @"(\d+)");
        return match.Success && int.TryParse(match.Value, out var n) ? n : null;
    }

    private static string FormatearEtiquetaGrupoInforme(string? gradeLevelName, string groupName, string? groupGrade)
    {
        var grado = !string.IsNullOrWhiteSpace(groupGrade)
            ? groupGrade.Trim()
            : ExtractGradeNumber(gradeLevelName) is int n
                ? $"{n}°"
                : gradeLevelName?.Trim() ?? "";

        var nombre = groupName.Trim();
        if (string.IsNullOrEmpty(nombre))
            return grado;

        if (nombre.Contains('-', StringComparison.Ordinal))
            return nombre;

        var gradoCorto = grado.Replace("°", "", StringComparison.Ordinal).Trim();
        return string.IsNullOrEmpty(gradoCorto) ? nombre : $"{gradoCorto}-{nombre}";
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
                        PalabrasClaveCoinciden(s.Activity.Subject.Name, palabrasClave))
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

        var esGrado9 = ExtractGradeNumber(gradeLevelName) == 9;
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

    private static string FormatearEncabezadoTrimestrePlantilla(IReadOnlyList<string> trimestres, int indice)
    {
        if (indice < trimestres.Count)
        {
            var nombre = trimestres[indice].Trim().ToUpperInvariant();
            if (nombre.Contains("TRIMESTRE", StringComparison.OrdinalIgnoreCase))
                return nombre.EndsWith(' ') ? nombre : nombre + " ";
            return indice switch
            {
                0 => "I- TRIMESTRE ",
                1 => "II- TRIMESTRE ",
                2 => "III- TRIMESTRE ",
                _ => $"{nombre} "
            };
        }

        return indice switch
        {
            0 => "I- TRIMESTRE ",
            1 => "II- TRIMESTRE ",
            2 => "III- TRIMESTRE ",
            _ => ""
        };
    }

    /// <summary>
    /// Promedio final: promedio de los promedios trimestrales, usando solo las asignaturas con nota en cada trimestre.
    /// </summary>
    private static decimal? CalcularPromedioFinalInformeCalificaciones(decimal?[][] notasPorSlot)
    {
        var promediosTrimestre = new List<decimal>();
        foreach (var slot in notasPorSlot)
        {
            if (slot == null || slot.Length == 0)
                continue;

            var validas = slot.Where(n => n.HasValue).Select(n => n!.Value).ToList();
            if (validas.Count > 0)
                promediosTrimestre.Add(validas.Average());
        }

        return promediosTrimestre.Count > 0 ? Math.Round(promediosTrimestre.Average(), 1) : null;
    }

    private static decimal?[] SliceNotasTrimestre(decimal?[] notasLineales, int slotTrimestre, int columnasPorTrimestre = 2)
    {
        var start = slotTrimestre * columnasPorTrimestre;
        if (start >= notasLineales.Length)
            return Array.Empty<decimal?>();

        var len = Math.Min(columnasPorTrimestre, notasLineales.Length - start);
        var slice = new decimal?[len];
        Array.Copy(notasLineales, start, slice, 0, len);
        return slice;
    }

    /// <summary>
    /// Columna del informe (0 = I trimestre, 1 = II, 2 = III) según el nombre en BD (p. ej. 1T, 2T).
    /// </summary>
    private static int? ResolverSlotTrimestreInforme(string? trimestre)
    {
        if (string.IsNullOrWhiteSpace(trimestre))
            return null;

        var t = trimestre.Trim().ToUpperInvariant();
        if (t is "1T" or "T1" or "I" or "1" or "PRIMERO" or "1RO" or "1ER")
            return 0;
        if (t is "2T" or "T2" or "II" or "2" or "SEGUNDO" or "2DO")
            return 1;
        if (t is "3T" or "T3" or "III" or "3" or "TERCERO" or "3RO" or "3ER")
            return 2;

        if (!t.Contains("TRIMESTRE", StringComparison.OrdinalIgnoreCase))
            return null;

        if (t.Contains("III", StringComparison.Ordinal) ||
            t.Contains("TERCER", StringComparison.OrdinalIgnoreCase))
            return 2;
        if (t.Contains("II", StringComparison.Ordinal) ||
            t.Contains("SEGUNDO", StringComparison.OrdinalIgnoreCase))
            return 1;
        if (t.Contains('I') || t.Contains("PRIMER", StringComparison.OrdinalIgnoreCase))
            return 0;

        return null;
    }

    private static string FormatearEtiquetaTrimestre(string trimestre)
    {
        if (AprobadosReprobadosFiltroValores.EsTodos(trimestre))
            return "I TRIMESTRE";

        var t = trimestre.Trim().ToUpperInvariant();
        if (t is "I" or "1" or "PRIMERO" or "1RO" or "1ER")
            return "I TRIMESTRE";
        if (t is "II" or "2" or "SEGUNDO" or "2DO" or "2DO")
            return "II TRIMESTRE";
        if (t is "III" or "3" or "TERCERO" or "3RO" or "3ER")
            return "III TRIMESTRE";

        return t.Contains("TRIMESTRE", StringComparison.OrdinalIgnoreCase)
            ? t
            : $"{t} TRIMESTRE";
    }

    private static void AplicarEstiloCuadroOficial(
        ExcelWorksheet ws, int filaInicio, int filaFin, int ultimaCol, int headerRow)
    {
        var titulo = ws.Cells[filaInicio, 1, 4, ultimaCol];
        titulo.Style.Font.Bold = true;
        titulo.Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;

        ws.Cells[6, 1].Style.Font.Bold = true;
        ws.Cells[6, ultimaCol - 1].Style.Font.Bold = true;
        ws.Cells[6, ultimaCol - 1].Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;

        using var encabezado = ws.Cells[headerRow, 1, headerRow, ultimaCol];
        encabezado.Style.Font.Bold = true;
        encabezado.Style.HorizontalAlignment = ExcelHorizontalAlignment.Center;
        encabezado.Style.VerticalAlignment = ExcelVerticalAlignment.Center;
        encabezado.Style.WrapText = true;

        using var cuadro = ws.Cells[filaInicio, 1, filaFin, ultimaCol];
        cuadro.Style.Border.Top.Style = ExcelBorderStyle.Thin;
        cuadro.Style.Border.Bottom.Style = ExcelBorderStyle.Thin;
        cuadro.Style.Border.Left.Style = ExcelBorderStyle.Thin;
        cuadro.Style.Border.Right.Style = ExcelBorderStyle.Thin;
    }
}
