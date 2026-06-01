# Análisis general — Reportes institucionales Eduplaner

Fecha: 2026-05-24  
Carpeta de referencia: `Reportes/`

## Inventario de plantillas

| Archivo | Tipo | Filas × Cols | Uso |
|---------|------|--------------|-----|
| `Calificaciones de Tecnología.xls` | Excel 97 (.xls) | 85 × 15 | Informe trimestral tecnología (3 áreas × 3 trimestres) |
| `Calificaciones de Exp. Artística.xls` | .xls | 88 × 12 | Informe Educ. Artística + Educ. Musical |
| `Formato para las Carpetas.xls` | .xls | 54 × 14 | Premedia: notas trimestre, A/T, totales |
| `cuadro de Habitos y Actitudes 10° A.M.-P.M.docx` | Word | — | Referencia hábitos (12 columnas) |
| `Habitos_Actitudes_1T.xlsx` | Excel | 49 × 14 | Ejemplo exportado desde sistema |

No hay PDF de referencia en la carpeta; el PDF se genera con **Puppeteer** capturando la misma HTML de vista previa (sin reemplazar QuestPDF usado en otros módulos).

---

## Mapeo oficial → implementación

| Reporte | Ruta app | Plantilla | Controlador | Vista filtros | Vista documento | Servicio datos | Excel | PDF |
|---------|----------|-----------|-------------|---------------|-----------------|----------------|-------|-----|
| Hábitos y Actitudes | `/HabitosActitudesReport/Index` | docx / xlsx | `HabitosActitudesReportController` | `Views/HabitosActitudesReport/Index.cshtml` | `VistaPrevia.cshtml` | `ObtenerHabitosActitudesReporteAsync` | EPPlus `.xlsx` | Puppeteer |
| Expresiones Artísticas | `/CalificacionesInforme/ExpresionesArtisticas` | Exp. Artística.xls | `CalificacionesInformeController` | `ExpresionesArtisticas.cshtml` | `VistaPreviaExpresionesArtisticas.cshtml` | `ObtenerCalificacionesExpresionesArtisticasReporteAsync` | NPOI `.xls` | Puppeteer |
| Tecnología | `/CalificacionesInforme/Tecnologia` | Tecnología.xls | `CalificacionesInformeController` | `Tecnologia.cshtml` | `VistaPreviaTecnologia.cshtml` | `ObtenerCalificacionesTecnologiaReporteAsync` | NPOI `.xls` | Puppeteer |
| Formato Carpetas | `/FormatoCarpetasReport/Index` | Carpetas.xls | `FormatoCarpetasReportController` | `Index.cshtml` | `VistaPrevia.cshtml` | `ObtenerFormatoCarpetasReporteAsync` | NPOI `.xls` | Puppeteer |

---

## Estado por reporte (antes → después)

### 1. Hábitos y Actitudes

| Aspecto | Antes | Después |
|---------|-------|---------|
| UI | Solo `_InformeInstitucionalFiltros` + descarga Excel | `Index` dedicado + vista previa + PDF |
| Diseño | Excel generado en código | HTML `#printArea` alineado a plantilla (14 cols hábitos, S/X/R leyenda) |
| Datos | Estudiantes reales; celdas hábitos vacías (sin BD hábitos) | Igual (correcto por alcance actual) |

### 2. Expresiones Artísticas

| Aspecto | Antes | Después |
|---------|-------|---------|
| UI | Solo filtros compartidos + Excel | Vista previa 12 columnas + PDF |
| Diseño | NPOI rellena `.xls` | HTML con encabezados verticales + mismo Excel |

### 3. Tecnología

| Aspecto | Antes | Después |
|---------|-------|---------|
| UI | Parcial (solo Tecnología custom) | Completo: imprimir + PDF + Excel |
| Diseño | 15 columnas, vertical headers | Replicado en CSS landscape |

### 4. Formato Carpetas

| Aspecto | Antes | Después |
|---------|-------|---------|
| UI | Solo Excel | Vista previa doble encabezado + PDF |
| Diseño | NPOI `.xls` | HTML 14 columnas (notas + A/T) |

---

## Motor PDF

- **Servicio:** `InformeInstitucionalHtmlPdfService` (PuppeteerSharp).
- **Flujo:** `ExportarPdf` → URL absoluta de `VistaPrevia` con cookies de sesión → `page.PdfAsync` landscape.
- **QuestPDF** no se sustituye; sigue en Aprobados/Reprobados, carnets, etc.

---

## CSS compartido

| Archivo | Reportes |
|---------|----------|
| `wwwroot/css/reporte-institucional-base.css` | Base: `#printArea`, logo, bordes, `.vertical-header` |
| `reporte-habitos-actitudes.css` | Hábitos |
| `reporte-calificaciones-tecnologia.css` | Tecnología |
| `reporte-calificaciones-exp.css` | Expresiones Artísticas |
| `reporte-formato-carpetas.css` | Carpetas |

---

## Seguridad y datos

- Filtros: `AprobadosReprobados/ObtenerNivelesFiltro`, `ObtenerGruposFiltro`, `ObtenerMateriasFiltro` con `teacherScopeId`.
- Exportación: `ValidarAsignacionAsync` en `ReportesInstitucionalesService`.
- **Base de datos:** sin DDL, sin tablas nuevas, sin cambios de esquema.

---

## Diferencias conocidas vs Excel

1. **Logo:** plantillas `.xls` no traen imagen embebida; se usa `School.LogoUrl`.
2. **Nombre instituto:** dinámico (`school.Name`) vs texto fijo “IPT San Miguelito” en plantilla.
3. **Hábitos S/X/R:** sin tabla de evaluación en BD → celdas vacías para llenado manual (como Excel vacío).
4. **Filas en blanco:** se rellenan hasta 40–75 filas según plantilla para conservar formato impreso.
