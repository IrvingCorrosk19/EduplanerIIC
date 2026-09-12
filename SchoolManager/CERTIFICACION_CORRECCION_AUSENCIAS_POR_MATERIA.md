# Certificación: corrección de ausencias por materia (Formato Carpetas)

**Fecha:** 12 de septiembre de 2026  
**Reporte:** `/FormatoCarpetasReport/VistaPrevia` (también PDF y Excel)  
**Migración:** `20260912160021_AddAttendanceSubjectId`

---

## Causa raíz

1. La tabla `attendance` no tenía `subject_id`. El reporte de Cívica sumaba ausencias de Religión, Español, Historia, Educación Artística y cualquier otro docente del grupo.
2. `LoadAttendanceAsync` usaba `Count()` de filas, no fechas distintas.
3. `SaveAttendancesAsync` siempre insertaba. Guardar el mismo día otra vez duplicaba la fila.
4. `ResolveInstitutionalTrimesterFallbackAsync` asignaba 2T desde el 8 de junio, aunque 1T oficial termina el 12 de junio. El 11 de junio quedaba en 2T.

---

## Regla funcional aplicada

- **A** = ausencias de la materia seleccionada.
- **T** = tardanzas de la materia seleccionada.
- Una fecha se cuenta una sola vez por estudiante y materia.
- Re-guardar el mismo estudiante, materia, grupo, grado y fecha actualiza; no inserta.
- El Total es la suma de 1T + 2T + 3T de esa materia.
- La fecha se clasifica con `StartDate`/`EndDate` oficiales. Si cae en un hueco, no se asigna a ningún trimestre.

---

## Archivos modificados

### Modelo y persistencia

- `Models/Attendance.cs`
- `Models/Subject.cs`
- `Models/SchoolDbContext.cs`
- `Dtos/AttendanceSaveDto.cs`
- `Migrations/20260912160021_AddAttendanceSubjectId.cs`
- `Migrations/20260912160021_AddAttendanceSubjectId.Designer.cs`
- `Migrations/SchoolDbContextModelSnapshot.cs`

### Guardado y calendario

- `Services/Implementations/AttendanceService.cs`
- `Services/Interfaces/IAttendanceService.cs`
- `Services/Helpers/AttendanceOfficialCalendar.cs`
- `Services/Helpers/AttendanceSaveDecision.cs`
- `Services/Helpers/AttendanceHistoricalSubjectResolver.cs`
- `Controllers/TeacherGradebookController.cs`
- `Controllers/TeacherGradebookDuplicateController.cs`
- `Views/TeacherGradebook/Index.cshtml`
- `Views/TeacherGradebookDuplicate/Index.cshtml`
- `Views/OrientationReport/Index.cshtml`
- `Program.cs` (`CommandTimeout` 600 s para la migración; flag `--verify-attendance-subject`)

### Reporte (cálculo único)

- `Services/Helpers/ReportesInstitucionalesBulkLoader.cs`
- `Services/Helpers/AttendanceSubjectAggregator.cs`
- `Services/Helpers/FormatoCarpetasAttendanceCalculator.cs`
- `Services/Implementations/ReportesInstitucionalesService.cs`

### Pruebas y evidencia

- `SchoolManager.Tests/AttendanceOfficialCalendarTests.cs`
- `SchoolManager.Tests/AttendanceSubjectAggregatorTests.cs`
- `SchoolManager.Tests/AttendanceSaveDecisionTests.cs`
- `SchoolManager.Tests/AttendanceServiceUpsertTests.cs`
- `SchoolManager.Tests/FormatoCarpetasGradebookUnchangedTests.cs`
- `SchoolManager.Tests/SchoolManager.Tests.csproj`
- `Scripts/VerifyAttendanceSubjectCorrection.cs`
- `INVENTARIO_ASISTENCIA_HISTORICA_AMBIGUA.md`

---

## Migración creada

`20260912160021_AddAttendanceSubjectId`

1. Columna nullable `attendance.subject_id`.
2. FK `attendance_subject_id_fkey` → `subjects(id)` (`ON DELETE RESTRICT`).
3. Índices no únicos: `IX_Attendance_SubjectId` y `IX_Attendance_Student_Subject_Group_Grade_Date`.
4. Respaldo `attendance_subject_backfill_20260912`.
5. Backfill automático solo cuando el docente tiene **una** materia en ese grupo y grado.
6. Inventarios `attendance_unresolved_subject_inventory_20260912` y `attendance_duplicate_identity_inventory_20260912`.

No se creó índice `UNIQUE`: hay 14,354 identidades históricas duplicadas y la migración fallaría.

---

## Regla de upsert

Identidad funcional: **estudiante + materia + grupo + grado + fecha**.

- Si existe una o más filas: se actualiza el estado, docente, materia y el trimestre oficial de la fecha. No se inserta otra fila.
- Si no existe: se crea.
- El trimestre guardado sale de `AttendanceOfficialCalendar` (rangos oficiales). Hueco → `TrimesterId` nulo.

---

## Tratamiento de registros históricos

- Se asociaron **73,261** filas con materia inequívoca.
- Quedaron **3,387** filas con `subject_id` nulo. Todas pertenecen a **67** ámbitos docente+grupo+grado con más de una materia.
- No se asignó materia arbitraria.
- No se borró ningún duplicado histórico.
- El reporte no usa esas filas nulas hasta que se asocien de forma inequívoca.

Detalle: `INVENTARIO_ASISTENCIA_HISTORICA_AMBIGUA.md`.

---

## Consultas de verificación

```sql
-- Filas asociadas vs pendientes
SELECT
    COUNT(*) FILTER (WHERE subject_id IS NOT NULL) AS con_materia,
    COUNT(*) FILTER (WHERE subject_id IS NULL) AS sin_materia
FROM attendance;

-- Duplicados de la identidad funcional
SELECT COUNT(*) FROM attendance_duplicate_identity_inventory_20260912;

-- Caso Agrazal / Cívica: fechas distintas de la materia
SELECT DISTINCT date, status
FROM attendance
WHERE student_id = '9b69aeb2-f238-47bc-b650-69accb740d49'
  AND subject_id = '6592de4d-b8de-4478-b4dd-ca50cb6eede8'
  AND group_id = '4a5980a9-3852-4a5c-96af-8bc627042318'
  AND grade_id = '9811c9ae-8e25-441c-b7f6-41e2e7cabdef'
  AND status ILIKE 'absent'
ORDER BY date;
```

El recuento por trimestre **no** usa el `trimester_id` histórico. Usa `AttendanceOfficialCalendar` + `AttendanceSubjectAggregator`.

Comando: `dotnet run -- --verify-attendance-subject`

---

## Resultados antes y después

### Antes (algoritmo anterior, todas las materias, Count de filas)

| Estudiante | 1T | 2T | 3T | Total |
|---|---|---|---|---|
| Agrazal, Stephany | 5 | 9 | 0 | 14 |

Esos 5 de 1T eran Religión, Español e Historia. Los 9 de 2T eran 3 fechas con filas duplicadas de Cívica y Educación Artística.

### Después (Cívica, fechas distintas, calendario oficial)

Fechas Cívica: **2026-06-11**, **2026-06-18**, **2026-07-09**.

| Fecha | Calendario oficial | Cuenta |
|---|---|---|
| 11 jun 2026 | 1T (1 mar–12 jun) | sí |
| 18 jun 2026 | hueco 13–20 jun | no |
| 9 jul 2026 | 2T (21 jun–20 sep) | sí |

| Estudiante | Materia | 1T | 2T | 3T | Total |
|---|---|---|---|---|---|
| Agrazal, Stephany | CÍVICA | **1** | **1** | **0** | **2** |

Otras materias de Agrazal en el mismo grupo (Educación Artística, Español, Historia, Religión) **no** entran en Cívica.

No se fijaron valores a mano. Salieron del agregador.

---

## Evidencia Agrazal, Stephany

- Estudiante: `9b69aeb2-f238-47bc-b650-69accb740d49`
- Materia: CÍVICA `6592de4d-b8de-4478-b4dd-ca50cb6eede8`
- Grupo G `4a5980a9-3852-4a5c-96af-8bc627042318`
- Grado 9 `9811c9ae-8e25-441c-b7f6-41e2e7cabdef`
- Escuela `6e42399f-6f17-4585-b92e-fa4fff02cb65`

`VERIFY_A1=1 VERIFY_A2=1 VERIFY_A3=0 VERIFY_TOTAL=2 VERIFY_TOTAL_EQ_SUM=True`

---

## Pruebas ejecutadas

`dotnet test SchoolManager.Tests` → **94 passed**, 0 failed.

Cubren:

- Una ausencia de otra materia no aparece en Cívica.
- Dos guardados de la misma asistencia no generan duplicados.
- Cambiar ausente a presente actualiza el registro.
- Una fecha se cuenta una sola vez.
- El 11 de junio de 2026 pertenece a 1T; el 18 de junio (hueco) no se asigna.
- No se mezclan escuela, año, grupo ni grado.
- VistaPrevia, PDF y Excel usan `FormatoCarpetasAttendanceCalculator` sobre el mismo bulk.
- Total = 1T + 2T + 3T.
- El cálculo de calificaciones del gradebook no cambia.

---

## Consistencia web / PDF / Excel

- VistaPrevia y PDF llaman `ObtenerFormatoCarpetasReporteAsync`.
- Excel llama `ExportarFormatoCarpetasExcelAsync`.
- Ambos cargan el mismo `GetBulkAsync(..., materiaId)` y aplican `FormatoCarpetasAttendanceCalculator.FromBulk`.
- El cache de bulk incluye `subjectId`.

---

## Riesgos pendientes

1. **3,387 filas históricas** sin materia porque el docente tiene más de una asignación en ese grupo/grado. No aparecen en ningún reporte por materia hasta que se asocien con una regla inequívoca o revisión manual.
2. **14,354 identidades duplicadas**. No se borraron. El reporte no las infla porque cuenta fechas. La deduplicación espera confirmación.
3. Fechas en hueco oficial (p. ej. 13–20 jun 2026) no suman en 1T ni 2T.

---

## Confirmación

El reporte de Cívica ya no incluye ausencias de otras materias.  
Agrazal / Cívica: **1T = 1, 2T = 1, 3T = 0, Total = 2**.
