# Reportes institucionales — Análisis final de entrega

Fecha: 2026-05-24  
Compilación: `dotnet build` — **correcta**

---

## Confirmaciones obligatorias

| Criterio | Estado |
|----------|--------|
| No se modificó la base de datos | ✓ |
| No se crearon tablas / vistas / SP / triggers | ✓ |
| Lógica académica existente preservada | ✓ |
| 4 reportes con vista web + impresión + PDF | ✓ |
| Excel oficial (.xls/.xlsx) mantenido | ✓ |

---

## HabitosActitudesReport

### Archivos modificados o creados

- `Controllers/InformesInstitucionalesControllers.cs` — `Index`, `VistaPrevia`, `ExportarPdf`
- `Services/Interfaces/IReportesInstitucionalesService.cs` — `ObtenerHabitosActitudesReporteAsync`
- `Services/Implementations/ReportesInstitucionalesService.cs`
- `ViewModels/ReportesInstitucionalesViewModels.cs` — `HabitosActitudesReportViewModel`
- `Views/HabitosActitudesReport/Index.cshtml`, `VistaPrevia.cshtml`
- `wwwroot/css/reporte-habitos-actitudes.css`

### Cambios

- Pantalla de filtros (trimestre, grado, grupo).
- Documento imprimible con 12 columnas de hábitos, leyenda S/X/R, pie de firmas.
- PDF vía Puppeteer capturando `VistaPrevia`.

### Evidencia PDF

Generar: **Descargar PDF** en `/HabitosActitudesReport/Index` o imprimir desde vista previa → “Guardar como PDF”. Orientación: **horizontal**.

---

## ExpresionesArtisticas

### Archivos

- `Views/CalificacionesInforme/ExpresionesArtisticas.cshtml`
- `Views/CalificacionesInforme/VistaPreviaExpresionesArtisticas.cshtml`
- `wwwroot/css/reporte-calificaciones-exp.css`
- `ObtenerCalificacionesExpresionesArtisticasReporteAsync` + `ExportarPdfExpresionesArtisticas`

### Cambios

- 12 columnas: Educ. Artística / Educ. Musical × 3 trimestres + PROMEDIO FINAL.
- Encabezados verticales (`writing-mode: vertical-rl`).
- Excel `.xls` con plantilla NPOI (sin cambio de lógica de notas).

### Evidencia PDF

`/CalificacionesInforme/ExpresionesArtisticas` → **Descargar PDF** → `Calificaciones_Expresiones_Artisticas.pdf`

---

## Tecnologia

### Archivos

- `Views/CalificacionesInforme/Tecnologia.cshtml`
- `Views/CalificacionesInforme/VistaPreviaTecnologia.cshtml`
- `wwwroot/css/reporte-calificaciones-tecnologia.css`
- `REPORTE_TECNOLOGIA_ANALISIS.md` (análisis detallado previo)

### Cambios

- 15 columnas oficiales (CONTABILIDAD/COMERCIO, HOGAR, INDUSTRIALES por trimestre).
- Vista previa + PDF + Excel `.xls`.

### Evidencia PDF

`/CalificacionesInforme/Tecnologia` → **Descargar PDF**

---

## FormatoCarpetas

### Archivos

- `Views/FormatoCarpetasReport/Index.cshtml`, `VistaPrevia.cshtml`
- `wwwroot/css/reporte-formato-carpetas.css`
- `ObtenerFormatoCarpetasReporteAsync` + `ExportarPdf`

### Cambios

- Encabezado doble fila (trimestres, A/T, Prom. Final).
- Datos: nota por trimestre, ausencias/tardanzas, totales (misma lógica que Excel NPOI).

### Evidencia PDF

`/FormatoCarpetasReport/Index` → **Descargar PDF**

---

## Infraestructura común añadida

| Componente | Descripción |
|------------|-------------|
| `IInformeInstitucionalHtmlPdfService` | Contrato PDF HTML |
| `InformeInstitucionalHtmlPdfService` | Puppeteer + cookies de sesión |
| `reporte-institucional-base.css` | Estilos e `@media print` |
| `Program.cs` | Registro DI del servicio PDF |

---

## Pruebas recomendadas

1. **Profesor:** solo ve grupos/materias asignados; exportar PDF debe fallar si manipula GUID ajeno.
2. **Director/Admin:** todos los grupos de la escuela.
3. **Grupo vacío:** tabla con filas numeradas vacías.
4. **Notas nulas:** celdas en blanco; promedio solo con valores.
5. **Navegadores:** Chrome/Edge para PDF Puppeteer (Chromium embebido o Chrome instalado).

---

## Nota sobre evidencia visual

Las capturas PDF dependen del entorno (logo de escuela, Chromium disponible). Si Puppeteer no encuentra Chrome en el servidor, instalar Chrome o definir `PUPPETEER_EXECUTABLE_PATH`.
