# Reporte Calificaciones de Tecnología — Análisis e implementación

Fecha: 2026-05-24  
Ruta: `/CalificacionesInforme/Tecnologia`  
Plantilla de referencia: `Reportes/Calificaciones de Tecnología.xls`  
*(En disco el archivo oficial está en formato `.xls`; es equivalente al `.xlsx` citado en el requerimiento.)*

---

## 1. Análisis de la plantilla Excel

### Encabezado institucional

| Fila Excel | Contenido | Alineación |
|------------|-----------|------------|
| 2 | Ministerio de Educación | Centrado (celda fusionada ancho completo) |
| 3 | Instituto / nombre de la escuela | Centrado |
| 4 | Informe de Calificaciones-20XX | Centrado |
| 7 | Consejero (a): ___ \| ASIGNATURA: TECNOLOGIA \| GRUPO: ___ | Izquierda / centro / derecha |

- **Logo:** la plantilla `.xls` no incluye imagen embebida legible por script; en la vista HTML se coloca el **logo de la escuela** (`School.LogoUrl`) a la **izquierda**, como en otros reportes institucionales del sistema.
- **Altura fila encabezados de tabla (fila 9):** ~100 pt (1999 unidades Excel) → replicado en CSS como `105pt`.
- **Altura filas de datos:** ~15 pt (300 unidades).

### Tabla — 15 columnas (índices 0–14)

| Col | Encabezado | Tipo |
|-----|------------|------|
| 0 | N° | Horizontal |
| 1 | NOMBRE DE LOS ESTUDIANTES | Horizontal, ancho ~6× el de nota |
| 2–4 | Área 1, 2, 3 (trim. I) | Texto vertical |
| 5 | I- TRIMESTRE | Etiqueta vertical (sin nota) |
| 6–8 | Área 1, 2, 3 (trim. II) | Texto vertical |
| 9 | II- TRIMESTRE | Etiqueta vertical |
| 10–12 | Área 1, 2, 3 (trim. III) | Texto vertical |
| 13 | III- TRIMESTRE | Etiqueta vertical |
| 14 | PROMEDIO FINAL | Texto vertical |

**Áreas por grado (lógica existente, sin cambios):**

- Grado 9: CONTABILIDAD, EDUC. HOGAR, ART. INDUSTRIALES  
- Otros: COMERCIO, EDUC. HOGAR, ART. INDUSTRIALES  

**Anchos relativos (unidades Excel):** N° 1353, Nombre 8777, cada nota ~1097 → proporción replicada en CSS (`table-layout: fixed`).

### Texto vertical

En el `.xls` analizado, la orientación se logra con **columnas estrechas + fila de encabezado muy alta**. En HTML se usa:

```css
writing-mode: vertical-rl;
transform: rotate(180deg);
```

para igualar la lectura de abajo hacia arriba como en Excel.

---

## 2. Implementación anterior vs actual

| Aspecto | Antes | Ahora |
|---------|-------|-------|
| Vista `Tecnologia` | `_InformeInstitucionalFiltros.cshtml` (solo descarga Excel) | `Views/CalificacionesInforme/Tecnologia.cshtml` (filtros + vista previa + Excel) |
| Vista previa / impresión | No existía | `Views/CalificacionesInforme/VistaPrevia.cshtml` con `#printArea` |
| CSS | Bootstrap genérico | `wwwroot/css/reporte-calificaciones-tecnologia.css` (blanco/negro, bordes Excel) |
| Datos | Solo en export NPOI | `ObtenerCalificacionesTecnologiaReporteAsync` (misma lógica de notas) |
| Export Excel | Se mantiene | Plantilla `.xls` + NPOI (sin cambios de lógica académica) |

### Qué se conservó (sin tocar)

- Filtros vía `AprobadosReprobados/ObtenerNivelesFiltro` y `ObtenerGruposFiltro`.
- Seguridad docente: `ValidarAsignacionAsync` + `GetTeacherScopeId`.
- Cálculo de notas: `ObtenerNotaFinalMateriaTrimestreAsync` / libro de calificaciones.
- Exportación `.xls` con plantilla oficial.

---

## 3. Archivos modificados o creados

| Archivo | Acción |
|---------|--------|
| `Controllers/InformesInstitucionalesControllers.cs` | `Tecnologia()` dedicado; nueva acción `VistaPrevia` |
| `Services/Interfaces/IReportesInstitucionalesService.cs` | `ObtenerCalificacionesTecnologiaReporteAsync` |
| `Services/Implementations/ReportesInstitucionalesService.cs` | Implementación del ViewModel + etiquetas trimestre |
| `ViewModels/ReportesInstitucionalesViewModels.cs` | `CalificacionesTecnologiaReportViewModel`, `CalificacionesTecnologiaFilaViewModel` |
| `Views/CalificacionesInforme/Tecnologia.cshtml` | **Nuevo** — pantalla de filtros |
| `Views/CalificacionesInforme/VistaPrevia.cshtml` | **Nuevo** — documento imprimible |
| `wwwroot/css/reporte-calificaciones-tecnologia.css` | **Nuevo** — estilos oficiales e `@media print` landscape |

---

## 4. Flujo de uso

1. `/CalificacionesInforme/Tecnologia` — elegir grado y grupo.  
2. **Ver reporte** → abre `VistaPrevia` en nueva pestaña (`#printArea`).  
3. **Imprimir** o **Guardar como PDF** del navegador (orientación horizontal).  
4. **Descargar Excel (.xls)** — misma plantilla binaria que antes.

---

## 5. Validaciones previstas

| Caso | Comportamiento |
|------|----------------|
| Profesor con estudiantes | Lista + notas por trimestre y promedio |
| Profesor sin estudiantes en el grupo | Tabla con filas vacías numeradas (plantilla) |
| Grupo vacío | Solo filas de relleno hasta 75 |
| Notas nulas | Celda en blanco |
| Promedio | Promedio de todas las notas con valor |
| Docente no asignado | `UnauthorizedAccessException` → mensaje en pantalla filtros |
| Impresión | `@page { size: landscape }`, oculta toolbar `.no-print` |
| PDF | Mismo HTML; sin motor PDF nuevo |

---

## 6. Base de datos

**Confirmación:**

- No se crearon tablas, vistas, procedimientos, funciones, triggers ni índices.
- No se alteró ninguna columna ni migración.
- Solo capa presentación + método de lectura que reutiliza consultas EF existentes.

---

## 7. Evidencia visual / impresión / PDF

La verificación final debe hacerse en el navegador del usuario:

1. Generar vista previa con un grupo real.  
2. Comparar lado a lado con `Reportes/Calificaciones de Tecnología.xls`.  
3. Imprimir → vista previa horizontal.  
4. “Guardar como PDF” y revisar bordes y encabezados verticales.

*Nota: la evidencia en capturas depende del entorno local; este documento registra la especificación medida del `.xls` y la correspondencia implementada en CSS/HTML.*

---

## 8. Compilación

```text
dotnet clean
dotnet restore
dotnet build
```

Resultado esperado: **Build succeeded** (sin errores introducidos por este cambio).
