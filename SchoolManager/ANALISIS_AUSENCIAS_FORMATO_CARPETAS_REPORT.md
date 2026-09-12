# Análisis técnico y funcional: ausencias y tardanzas en FormatoCarpetasReport

**Fecha:** 12 de septiembre de 2026  
**Alcance:** solo lectura. No se modificó código, datos ni estructura de la base.  
**URL analizada:**  
`/FormatoCarpetasReport/VistaPrevia?nivelEducativo=9811c9ae-8e25-441c-b7f6-41e2e7cabdef&materiaId=6592de4d-b8de-4478-b4dd-ca50cb6eede8&groupId=4a5980a9-3852-4a5c-96af-8bc627042318&gradeLevelId=9811c9ae-8e25-441c-b7f6-41e2e7cabdef`

**Contexto resuelto:** grupo **G**, grado **9**, materia **CÍVICA**, año lectivo **2026**, escuela `6e42399f-6f17-4585-b92e-fa4fff02cb65`.

---

## 1. Resumen ejecutivo

El reporte **no recalcula ausencias en la vista ni en JavaScript**. Vista previa, PDF y Excel usan el mismo servicio.

**A** = recuento de filas `attendance.status = 'absent'`.  
**T** = recuento de filas `attendance.status = 'late'`.  
**Total** = A1T + A2T + A3T (y lo mismo para T). No es un total distinto ni “hasta el trimestre actual”.

El valor **14** del caso visible (1T=5, 2T=9) pertenece a **Agrazal, Stephany** (`9b69aeb2-f238-47bc-b650-69accb740d49`).  
`5 + 9 = 14` es aritméticamente correcto, pero **los 9 del 2T no son 9 días**: son **9 filas** de solo **3 fechas**. En días reales el total sería **8**, no 14.

Causa raíz confirmada (no hipótesis):

1. `ReportesInstitucionalesBulkLoader.LoadAttendanceAsync` hace `Count()` de **todas las filas**, sin `Distinct` por fecha, sin filtrar `materiaId` ni `teacherId`.
2. `AttendanceService.SaveAttendancesAsync` **siempre inserta** filas nuevas (no hay upsert). El mismo docente puede guardar dos veces el mismo día.
3. La tabla `attendance` **no tiene `subject_id`**. Varios docentes del mismo grupo (Cívica, Religión, Historia, Educación Artística, Español, etc.) generan cada uno su propia fila. El reporte de Cívica suma todas.

No hay JOIN que multiplique filas. Los acumuladores `totalA`/`totalT` sí se reinician por estudiante. `fuga` y `excusa` no se mezclan con A/T.

---

## 2. Comportamiento observado

En la tabla del reporte aparecen columnas:

| Trimestre notas | 1T A | 1T T | 2T A | 2T T | 3T A | 3T T | Total A | Total T |
|---|---|---|---|---|---|---|---|---|
| (notas aparte) | ausencias 1T | tardanzas 1T | ausencias 2T | tardanzas 2T | ausencias 3T | tardanzas 3T | suma A | suma T |

Caso visible: **5, 0 / 9, 0 / 0, 0 / Total 14, 0**.

Ese patrón coincide exactamente con la consulta que replica el algoritmo actual para Agrazal, Stephany.

La vista pinta `@f.AusenciasT1` … `@f.TotalAusencias` sin transformación.

---

## 3. Comportamiento funcional esperado

El informe se titula “Calificaciones, Ausencias y Tardanzas” y se filtra por **materia**. Las notas sí se acotan a Cívica. La asistencia, en cambio, se trata como si fuera un único registro diario del grupo.

Interpretaciones posibles (el código no documenta cuál es la oficial):

| Interpretación | Qué debería contar | Agrazal esperado |
|---|---|---|
| Días de ausencia del grupo | 1 fila por estudiante + fecha + estado | 1T=5, 2T=3, Total=8 |
| Ausencias solo de Cívica (docente Kirton) | Filas o días de ese docente | 1T=0 días, 2T=3 días (o 6 filas si se cuentan periodos) |
| Periodos/clases (todas las materias) | 1 fila por docente/día, sin duplicar el mismo clic | Menos que 14; 2T bajaría de 9 a 5 (3 días × docentes únicos, sin doble insert) |

El valor mostrado (5 / 9 / 14) **no coincide** con ninguna de las tres si se eliminan duplicados del mismo docente el mismo día.

No existe horario, periodo ni hora en `attendance`. Cada fila es “un guardado de lista” de un docente en una fecha.

---

## 4. Recorrido completo de los datos

```
URL VistaPrevia
  → FormatoCarpetasReportController.VistaPrevia
       valida usuario/escuela; nivelEducativo y materiaId no vacíos
  → IReportesInstitucionalesService.ObtenerFormatoCarpetasReporteAsync
       notas: CargarNotasFinalesGradebookAsync (sí filtra materia)
       asistencia: GetBulkAsync → ReportesInstitucionalesBulkLoader.LoadAsync
            → LoadAttendanceAsync (NO filtra materia)
            → ContarAsistencia(bulk, studentId, trimesterEntity)
       Total: totalA += ausencias; totalT += tardanzas  (por estudiante)
  → Views/FormatoCarpetasReport/VistaPrevia.cshtml
       imprime los enteros del ViewModel

PDF: misma acción de servicio + Razor de VistaPrevia + HTML→PDF
Excel: ExportarFormatoCarpetasExcelAsync → el mismo ContarAsistencia
```

`nivelEducativo` **no se usa** dentro de `ObtenerFormatoCarpetasReporteAsync` para filtrar asistencia ni estudiantes. El listado sale de `groupId` + `gradeLevelId`.

Origen de los registros: pestaña Asistencia de `/TeacherGradebook/Index` → `POST /TeacherGradebook/SaveAttendances` → `AttendanceService.SaveAttendancesAsync` (insert puro).

---

## 5. Archivos, clases y métodos involucrados

| Capa | Archivo | Qué hace |
|---|---|---|
| Controlador | `Controllers/InformesInstitucionalesControllers.cs` — `FormatoCarpetasReportController.VistaPrevia` (~L683) | Recibe filtros, llama al servicio, `return View(model)` |
| Controlador | misma clase, `ExportarPdf` / `ExportarExcel` | Mismo cálculo de asistencia |
| Filtros UI | `Views/FormatoCarpetasReport/Index.cshtml` | `nivelEducativo` = id de grado; `gradeLevelId` sale del combo de grupo |
| Servicio | `Services/Implementations/ReportesInstitucionalesService.cs` — `ObtenerFormatoCarpetasReporteAsync` (~L460–L536) | Arma filas; suma A/T |
| Carga | `Services/Helpers/ReportesInstitucionalesBulkLoader.cs` — `LoadAsync`, `LoadAttendanceAsync` (~L121–L178), `ContarAsistencia` (~L251) | Consulta y agrega asistencia |
| Persistencia | `Services/Implementations/AttendanceService.cs` — `SaveAttendancesAsync` (~L145), `ResolveAcademicScopeAsync`, `ResolveInstitutionalTrimesterFallbackAsync` (~L269) | Inserta filas; asigna trimestre |
| Modelo | `Models/Attendance.cs` | Sin `SubjectId`, sin periodo |
| Vista | `Views/FormatoCarpetasReport/VistaPrevia.cshtml` ~L83–L86 | Solo muestra enteros |
| ViewModel | `ViewModels/ReportesInstitucionalesViewModels.cs` — `FormatoCarpetasFilaViewModel` | `AusenciasT1..T3`, `TotalAusencias`, T equivalentes |
| JS gradebook | `Views/TeacherGradebook/Index.cshtml` ~L3209–L3273 | Envía lista completa y vuelve a insertar |

---

## 6. Algoritmo actual

### 6.1 Carga (`LoadAttendanceAsync`)

Filtros de la consulta EF:

- `GroupId == groupId`
- `StudentId` ∈ estudiantes activos del grupo+grado
- `TrimesterId` ∈ trimestres de la escuela **o** (sin `TrimesterId` y fecha entre el min/max de todos esos trimestres)

**No filtra:** `materiaId`, `teacherId`, `gradeId`, `schoolId`, año lectivo activo.

Luego, por cada trimestre y cada estudiante:

```
ausencias = registros.Count(status == "absent")
tardanzas = registros.Count(status == "late")
```

No hay `GroupBy(Date)`. Un día con 4 filas suma 4.

### 6.2 Pintado (`ObtenerFormatoCarpetasReporteAsync`)

Por estudiante, `totalA = 0` y `totalT = 0` (sí se reinician).  
Para `"1T"`, `"2T"`, `"3T"`: `FirstOrDefault` del trimestre por nombre y `ContarAsistencia`.  
`totalA += ausencias`.

### 6.3 Alta de datos (`SaveAttendancesAsync`)

```csharp
var attendance = new Attendance { Id = Guid.NewGuid(), ... };
_context.Attendances.Add(attendance);
```

No busca fila existente por estudiante+fecha+grupo+docente. Cada clic en “Guardar” crea filas nuevas.

Índice único en `attendance`: solo `id`. No hay unique `(student_id, date, teacher_id)`.

### 6.4 Qué no cuenta

`present`, `fuga`, `excusa` no entran en A ni T.

---

## 7. Tabla comparativa por estudiante

Estudiantes auditados (activos en 9° G):

| # | Estudiante | StudentId |
|---|---|---|
| 1 | Agrazal, Stephany (caso 14) | `9b69aeb2-f238-47bc-b650-69accb740d49` |
| 2 | Campbell G, Paola C | `8af9a9ce-ea5a-4550-8f77-ad17202f4498` |
| 3 | Ortega N, Daylis M | `64e62d8f-9edf-4eba-89a5-f7aa4d474112` |

Año lectivo de todos los registros: **2026** (`f7ccb57f-fa3e-4d9f-973b-552030c9852d`).  
Grupo y grado de sus ausencias: G / `9811c9ae-...`.  
3T: 0 en los tres.

| Estudiante | Almacenado (filas absent) | Calculado reporte (filas) | Días distintos | Total mostrado | Total si A=días | Diferencia |
|---|---|---|---|---|---|---|
| Agrazal | 1T: 5 filas / 5 días; 2T: 9 filas / 3 días | 5 + 9 + 0 | 8 | **14** | **8** | **+6** |
| Campbell | 1T: 8 filas / 7 días; 2T: 5 filas / 2 días | 8 + 5 + 0 | 9 | **13** | **9** | **+4** |
| Ortega | 1T: 9 filas / 9 días; 2T: 5 filas / 2 días | 9 + 5 + 0 | 11 | **14** | **11** | **+3** |

Tardanzas: 0 en los tres (no hay mezcla A/T).

### 7.1 Agrazal, 2T: de dónde salen los 9

| Fecha | Trimestre oficial por calendario | Trimestre guardado | Docentes | Filas |
|---|---|---|---|---|
| 2026-06-11 | **1T** (1 mar–12 jun) | **2T** | Kirton (Cívica) × 2 | 2 |
| 2026-06-18 | Hueco 13–20 jun | **2T** | Kirton × 2 + Quintero (Ed. Artística) × 2 | 4 |
| 2026-07-09 | 2T (21 jun–20 sep) | 2T | Kirton × 2 + Quintero × 1 | 3 |
| | | | **Suma** | **9** |

Días reales 2T (aunque se acepte el `TrimesterId` guardado): **3**.  
Si Cívica fuera la única materia: 1T = **0** (ninguna fila de Kirton en 1T); 2T = **3 días** / 6 filas duplicadas.

### 7.2 Agrazal, 1T: los 5 sí son 5 días, pero de otras materias

Fechas: 6 mar (Atencio/Religión), 12 mar (Eysseric/Español), 17 abr (Atencio), 20 abr (Atencio), 21 abr (Ortíz/Historia).  
Ninguna es Cívica.

---

## 8. Evidencia de consultas (solo lectura)

Conexión: PostgreSQL de la aplicación, transacción `readonly`. Sin `INSERT`/`UPDATE`/`DELETE`.

### 8.1 Contexto

- `groups` + `grade_levels` + `subjects` con los GUID de la URL → G, grado 9, CÍVICA.
- 3 trimestres de la escuela, un solo año 2026: 1T `54d2db96-...` (inactivo, 1 mar–12 jun), 2T `7038b0cd-...` (21 jun–20 sep), 3T `a4724128-...`.
- 38 estudiantes activos en group+grade.

### 8.2 Réplica del algoritmo del reporte

`COUNT(*)` de `absent`/`late` por estudiante y `trimester_id` (misma regla que `LoadAttendanceAsync`) reproduce 5/9/14 para Agrazal.

### 8.3 COUNT vs COUNT(DISTINCT date)

```sql
-- grupo G, ausentes
COUNT(*) FILTER (WHERE status ILIKE 'absent')
COUNT(DISTINCT date) FILTER (WHERE status ILIKE 'absent')
```

Agrazal: **14 filas / 8 días**.  
No hay JOIN: `COUNT(*)` crudo de `attendance` para Agrazal+grupo+absent = **14**.

### 8.4 Duplicados mismo día

Agrazal 2026-06-18: 4 ids, 2 docentes.  
Mismo estudiante+fecha+docente+status: Kirton 11 jun, 18 jun y 9 jul = **2 inserts cada uno**. Prueba de `SaveAttendancesAsync` sin upsert.

### 8.5 Contaminación entre materias

9 `teacher_id` distintos con asistencia en el grupo.  
14 asignaciones docentes en 9° G. Cívica = Kirton `3f1d46b6-4849-4ae1-8535-930e8ed0f8b7`.  
`attendance` **no tiene columna `subject_id`**.

### 8.6 Año lectivo

Un único `academic_years` 2026, activo. No hay mezcla de años en estos registros.

### 8.7 Fechas fuera del calendario oficial del trimestre

1140 filas del grupo con `date` fuera de `[start_date, end_date]` del `trimester_id` guardado. Rango observado: **8–19 jun 2026**. Coherente con el fallback `fecha >= 2026-06-08 → 2T` en `ResolveInstitutionalTrimesterFallbackAsync`.

### 8.8 Dos `grade_id` en el mismo `group_id`

`9811c9ae-...` (2476 filas) y `eb42cd8b-...` (1558 filas).  
`LoadAttendanceAsync` no filtra `grade_id`. En los tres estudiantes auditados las ausencias sí tienen el grado 9.

---

## 9. Causa raíz confirmada

**El reporte cuenta filas de `attendance`, no días, no la materia del filtro, y esas filas se duplican al guardar.**

Referencias:

| Qué | Dónde |
|---|---|
| `Count` de todas las filas `absent`/`late` | `ReportesInstitucionalesBulkLoader.LoadAttendanceAsync`, líneas 168–171 |
| Filtro solo por grupo + alumnos + trimestre | mismas líneas 135–142; **no aparece** `materiaId` ni `TeacherId` |
| Suma 1T+2T+3T al Total | `ReportesInstitucionalesService.ObtenerFormatoCarpetasReporteAsync`, líneas 493–514 |
| Insert siempre nuevo | `AttendanceService.SaveAttendancesAsync`, líneas 150–167 |
| Sin materia en el modelo | `Models/Attendance.cs`; `information_schema` de `attendance` |
| Vista no recalcula | `VistaPrevia.cshtml` 83–86 |

Dato que lo demuestra: Agrazal 2T = 9 filas / 3 fechas; el reporte muestra 9. El 14 es 5+9.

---

## 10. Causas secundarias

1. **`materiaId` ignorado en asistencia.** Las notas de Cívica sí se filtran; A/T no. Un docente de Religión o Historia incrementa el A del informe de Cívica.
2. **`SaveAttendancesAsync` sin upsert.** El mismo docente, mismo día, mismo alumno: 2+ filas (Kirton 11 jun, 18 jun, 9 jul).
3. **Varios docentes el mismo día.** 18 jun: Kirton + Quintero = 4 filas / 1 día.
4. **Clasificación de trimestre por fallback 2026.** Desde el 8 de junio se etiqueta 2T aunque 1T oficial termina el 12 de junio. El 11 jun de Agrazal (aún 1T de calendario) está guardado como 2T. 1140 filas del grupo caen fuera del rango oficial.
5. **`LoadAttendance` no filtra `gradeId` ni `schoolId`.** El grupo G tiene asistencia de dos grados.
6. **Trimestres cargados por escuela, no por año activo.** Hoy hay un solo set 1T/2T/3T; si mañana hay otro año, `FirstOrDefault` por nombre puede apuntar al trimestre incorrecto (`trimesterEntities` en L502–503 del servicio).
7. **`fuga`/`excusa` fuera de A y T.** Correcto si A/T son solo ausencia/tardanza; no explica el 14.
8. **`nivelEducativo` no participa en el cálculo.** Ver sección 12 de filtros.

Descartado:

- Acumulador que no se reinicia entre estudiantes (`totalA`/`totalT` se crean dentro del `foreach`).
- JOIN 1:N que multiplique filas (consulta plana a `attendance`).
- JavaScript que sume de nuevo en VistaPrevia.
- PDF con otra fórmula (reusa el mismo ViewModel).
- Mezcla de A con T en el caso 14.

---

## 11. Determinación del valor 14

**Es matemáticamente correcto como suma de los A trimestrales que el algoritmo produce (5+9).**  
**Es funcionalmente incorrecto como “ausencias del estudiante” si A significa días (esperado 8) o ausencias de Cívica (esperado 0+3 días).**

Los 9 del 2T **ya están inflados**. El Total no inventa un 14 aparte: hereda esos 9.

No es “suma de todos los trimestres en cada columna”: 1T=5 son 5 filas distintas de 1T; 2T=9 son otras 9. No se reutiliza el 5 dentro del 9.

---

## 12. Filtros de la URL y `nivelEducativo` = `gradeLevelId`

En `Views/FormatoCarpetasReport/Index.cshtml`:

- El select `#nivelEducativo` se llena con `ObtenerNivelesFiltro`, cuyo `id` es **`GradeLevelId`** (`AprobadosReprobadosService.ObtenerNivelesFiltroAsync`). La etiqueta del combo es “Grado”.
- El combo de grupo guarda `groupId|gradeLevelId`. Para 9° G ambos GUID coinciden: `9811c9ae-8e25-441c-b7f6-41e2e7cabdef`.

**Eso es correcto por diseño**, no un bug de filtro cruzado. No provoca el 14.

Si la URL se armara con un `gradeLevelId` distinto al grado del combo, el servicio usaría `gradeLevelId` (estudiantes) e ignoraría `nivelEducativo` para asistencia.

---

## 13. Riesgo en otros reportes

| Superficie | ¿Usa `LoadAttendanceAsync` / `ContarAsistencia`? | Riesgo |
|---|---|---|
| FormatoCarpetas Excel | Sí (`ExportarFormatoCarpetasExcelAsync` ~L631) | **El mismo 14** |
| FormatoCarpetas PDF | Sí (mismo ViewModel) | **El mismo 14** |
| Hábitos y Actitudes / Tecnología / Expresiones | No llaman `ContarAsistencia` | No este bug |
| `StudentReportService.BuildHistoricalAttendanceQuery` | Misma idea (filas por `TrimesterId` o fecha) | Si hace `Count()` sin distinct, **mismo tipo de inflación** |
| Estadísticas del gradebook (`GetEstadisticasAsync`) | `Count` de filas por grupo+grado+fechas | Infla porcentajes si hay duplicados |

Cualquier corrección en `LoadAttendanceAsync` cambia VistaPrevia, PDF y Excel de Carpetas a la vez. Corregir el insert en `SaveAttendancesAsync` cambia los datos futuros de todo el módulo de asistencia.

---

## 14. Propuesta de corrección (no implementada)

Decisión de producto (hace falta una):

**A. A = días de ausencia del grupo (recomendado para carpeta institucional)**  
En `LoadAttendanceAsync`, para cada estudiante+trimestre:

- ausencias = número de **fechas distintas** con al menos un `absent`
- tardanzas = fechas distintas con al menos un `late` (y sin contar el mismo día como A y T si se define así)

Opcional: no contar fechas cuyo `date` esté fuera de `[StartDate, EndDate]` del trimestre, o reclasificar.

**B. A = ausencias de la materia del reporte**  
Como no hay `subject_id`, filtrar por el `teacherId` de la asignación Cívica (`ResolverDocenteCarpetasAsync`, ya usado para notas). Seguiría haciendo falta deduplicar por fecha.

**C. Evitar duplicados en origen**  
En `SaveAttendancesAsync`: upsert por `(student_id, date, teacher_id)` o `(student_id, date, group_id, grade_id)`. No borrar histórico en esta fase; solo impedir nuevos duplicados.

**D. No hacer** un parche solo para Agrazal ni cambiar filas históricas sin autorización.

---

## 15. Archivos que probablemente habría que modificar (futuro)

- `SchoolManager/Services/Helpers/ReportesInstitucionalesBulkLoader.cs` — `LoadAttendanceAsync`
- `SchoolManager/Services/Implementations/AttendanceService.cs` — `SaveAttendancesAsync` (upsert)
- Tests nuevos en `SchoolManager.Tests` (deduplicar fecha; no mezclar materias si se elige B)
- Opcional: `StudentReportService` si se unifica la regla de días
- No requiere migración si solo se cambia el `COUNT` a `COUNT DISTINCT date`
- Migración solo si se añade unique constraint o `subject_id` (fuera de esta autorización)

---

## 16. Pruebas necesarias tras una futura corrección

1. Agrazal, Stephany, 9° G Cívica: 1T/2T/Total según la regla acordada (días: 5 / 3 / 8).
2. Campbell y Ortega: misma regla; comparar VistaPrevia, PDF y Excel.
3. Un estudiante sin duplicados (p. ej. Valdespino 1T=9 filas=9 días): no debe cambiar.
4. 3T sigue en 0 hasta que existan registros 3T.
5. Tardanzas: Aripe / Jaramillo (tienen `late`) no deben pasar a A.
6. `fuga`/`excusa` siguen fuera.
7. Guardar asistencia dos veces el mismo día no incrementa A (si hay upsert).
8. Informe de otra materia del mismo grupo: si se elige regla B, A cambia; si A, no.
9. Compilación y suite completa de tests.

---

## 17. Confirmación de no modificación

Durante este análisis:

- No se modificó código de la aplicación.
- No se ejecutó `INSERT`/`UPDATE`/`DELETE`/`TRUNCATE`/`DROP`.
- No se crearon migraciones.
- No se hizo commit ni push.
- Las consultas a PostgreSQL se abrieron con `readonly=True`.
- Este archivo Markdown es el único entregable nuevo.

---

## Anexo: significado de A, T, registro y Total

| Símbolo | Significado en código hoy |
|---|---|
| A | `Count` de filas `status = absent` |
| T | `Count` de filas `status = late` |
| Un registro | Una inserción de lista (docente + alumno + grupo + fecha + estado). No es hora ni periodo de horario. |
| Total | Suma de los A (o T) ya calculados de 1T+2T+3T del **grupo**, todas las materias mezcladas, año 2026 |
| Materia | Filtra notas; **no** filtra A/T |
