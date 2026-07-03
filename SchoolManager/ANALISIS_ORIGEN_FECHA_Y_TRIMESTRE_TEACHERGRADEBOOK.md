# Análisis de origen de fecha y trimestre en TeacherGradebook

**Proyecto:** `C:\Proyectos\EduplanerIIC\SchoolManager`  
**Módulo:** `/TeacherGradebook/Index`  
**Base de datos:** Render Producción  
**Alcance:** Solo auditoría técnica. No se modificó código, no se modificaron datos, no se crearon migraciones, no hubo commit ni push.

---

## 1. Conclusión ejecutiva

El sistema usa una combinación de fuentes:

| Elemento | Origen real | Persistencia |
|---|---|---|
| Trimestre de actividades | Selector manual del docente (`#selTrimester`) | Se guarda en `activities.trimester` y `activities.TrimesterId` |
| Fecha de entrega de actividades | Fecha seleccionada por el docente (`#activityDueDate`) | Se guarda en `activities.due_date` |
| Fecha de creación de actividades | Sistema/servidor (`DateTime.UtcNow` o default BD/auditoría) | Se guarda en `activities.created_at` |
| Trimestre de notas | Heredado desde `Activity` | No existe columna trimester en `student_activity_scores` |
| Fecha de notas | Sistema/servidor (`DateTime.UtcNow` o default BD/auditoría) | Se guarda en `student_activity_scores.created_at` |
| Año académico de notas | Año académico activo al momento de guardar | Se guarda en `student_activity_scores.academic_year_id` |
| Fecha de asistencia | Fecha seleccionada por el docente en pantalla (`#fecha`) | Se guarda en `attendance.date` |
| Fecha de creación de asistencia | Sistema/servidor (`DateTime.UtcNow`) | Se guarda en `attendance.created_at` |
| Trimestre de asistencia | No se guarda | Se infiere por fecha si un reporte lo necesita |
| Año académico de asistencia | No se guarda | Se infiere por fecha si un reporte lo necesita |

Respuesta crítica:

> Si hoy se modifica `2T = 22/06/2026`, una actividad creada hace meses que ya tiene `activities.trimester = '2T'` **sigue siendo 2T**. El sistema no recalcula su trimestre por fecha. La actividad conserva el texto `2T` y su vínculo `TrimesterId`.

Sin embargo, la asistencia sí puede cambiar de clasificación en reportes si esos reportes calculan trimestre por rango de fechas, porque `attendance` no guarda trimestre.

---

## 2. Respuesta rápida por opción

### Opción A — Fecha actual del servidor/sistema

Sí se usa para:

- `activities.created_at`
- `student_activity_scores.created_at`
- `attendance.created_at`
- campos de auditoría (`CreatedAt`, `UpdatedAt`)

### Opción B — Fecha seleccionada por el docente en pantalla

Sí se usa para:

- `activities.due_date` desde `#activityDueDate`
- `attendance.date` desde `#fecha`

### Opción C — Fecha configurada en calendario académico

Se usa para:

- poblar el combo de trimestres;
- validar si un trimestre está activo por `IsActive`;
- buscar `TrimesterId` por código (`1T`, `2T`, `3T`);
- calcular asistencia por trimestre en reportes como `StudentReport`.

No se usa para:

- recalcular automáticamente el trimestre de una actividad ya creada según su `due_date`;
- guardar trimestre en asistencia;
- decidir el trimestre de una nota directamente.

### Opción D — Combinación

Sí. El sistema combina:

- selección manual de trimestre;
- fechas seleccionadas por el docente;
- `DateTime.UtcNow`;
- calendario académico para validación y búsqueda de `TrimesterId`.

---

## 3. TeacherGradebook/Index — origen en la vista

Archivo: `Views/TeacherGradebook/Index.cshtml`

### 3.1 Selector de trimestre

La vista carga trimestres desde `Model.Trimesters`:

```html
<select id="selTrimester" class="form-select">
    @foreach (var t in Model.Trimesters)
    {
        <option value="@t.Name">@t.Name</option>
    }
</select>
```

Ese valor (`1T`, `2T`, `3T`) viaja al backend como texto.

### 3.2 Fecha de entrega de actividad

La fecha de actividad visible para el docente es:

```html
<input type="date" id="activityDueDate" name="DueDate" class="form-control" required />
```

Al crear/editar actividad:

```javascript
const dueDate = $('#activityDueDate').val();
formData.append('TrimesterCode', trimester);
formData.append('Date', new Date().toISOString());
formData.append('DueDate', dueDate);
formData.append('TeacherId', '@Model.TeacherId');
formData.append('SubjectId', subjectId);
formData.append('GroupId', groupId);
formData.append('GradeLevelId', gradeLevelId);
```

Observación importante:

- `TrimesterCode` viene del selector `#selTrimester`.
- `DueDate` viene del input seleccionado por el docente.
- `Date = new Date().toISOString()` se envía, pero en `ActivityService.CreateAsync` no se usa para persistir una columna `Date`; la entidad `Activity` no tiene `Date`.

### 3.3 Guardar notas

Al guardar notas, el frontend arma:

```javascript
Trimester: trimester
```

y envía a:

```text
POST /TeacherGradebook/GuardarNotasTemp
```

El trimestre de la nota viaja en el DTO, pero se usa para ubicar o crear la `Activity`; no se guarda en `student_activity_scores`.

### 3.4 Guardar asistencia

La fecha de asistencia viene de:

```html
<input type="date" class="form-control" id="fecha" value="@TimeZoneService.GetTodayForDateInput()">
```

Al guardar asistencia:

```javascript
const fecha = $('#fecha').val();
attendances.push({
    studentId: studentId,
    teacherId: teacherId,
    groupId: groupId,
    gradeId: gradeLevelId,
    date: fecha,
    status: status
});
```

No se envía:

- `subjectId`
- `trimester`
- `trimesterId`
- `academicYearId`

---

## 4. TeacherGradebookController

Archivo: `Controllers/TeacherGradebookController.cs`

### 4.1 `Index()`

El controller:

1. Obtiene el `teacherId` desde claims.
2. Carga asignaciones del docente.
3. Construye `SubjectGroupDetails`.
4. Carga trimestres con `_trimesterSvc.GetAllAsync()`.
5. Devuelve `TeacherGradebookViewModel`.

Código relevante:

```csharp
var trimesters = (await _trimesterSvc.GetAllAsync()).ToList();
var firstTrim = trimesters.FirstOrDefault()?.Name ?? "";
var groups = await _groupSvc.GetByTeacherAsync(teacherId, firstTrim);
```

Conclusión:

`Index()` no calcula trimestre actual por fecha. Solo carga el catálogo de trimestres para que el docente elija.

### 4.2 `CreateActivity`

Endpoint:

```text
POST /TeacherGradebook/CreateActivity
```

Recibe `ActivityCreateDto` desde `FormData`.

El controller valida `DueDate`:

```csharp
if (dto.DueDate == default(DateTime))
{
    var dueDateStr = Request.Form["DueDate"].FirstOrDefault();
    if (!string.IsNullOrEmpty(dueDateStr) && DateTime.TryParse(dueDateStr, out DateTime dueDate))
    {
        dto.DueDate = dueDate;
    }
}
```

Luego delega:

```csharp
var result = await _activitySvc.CreateAsync(dto);
```

Conclusión:

El controller no calcula trimestre por fecha. Recibe `TrimesterCode` del cliente y lo pasa al servicio.

### 4.3 `UpdateActivity`

Endpoint:

```text
POST /TeacherGradebook/UpdateActivity
```

Misma lógica:

- recibe `TrimesterCode`;
- recibe `DueDate`;
- delega en `_activitySvc.UpdateAsync(dto)`.

### 4.4 `GuardarNotasTemp`

Endpoint:

```text
POST /TeacherGradebook/GuardarNotasTemp
```

Por cada fila enviada desde la vista:

```csharp
registros.Add(new StudentActivityScoreCreateDto
{
    StudentId = studentId,
    ActivityName = nota.Actividad,
    Type = nota.Tipo,
    Score = score,
    SubjectId = subjectId,
    GradeLevelId = gradeLevelId,
    GroupId = groupId,
    TeacherId = teacherId,
    Trimester = alumno.Trimester
});
```

Luego:

```csharp
await _scoreSvc.SaveBulkFromNotasAsync(registros);
```

Conclusión:

El trimestre de la nota proviene de la selección del docente (`alumno.Trimester`) y se usa para localizar o crear la actividad correspondiente.

### 4.5 `SaveAttendances`

Endpoint:

```text
POST /TeacherGradebook/SaveAttendances
```

Solo delega:

```csharp
await _attendanceService.SaveAttendancesAsync(attendances);
```

No resuelve trimestre ni año académico.

---

## 5. ActivityService — actividades

Archivo: `Services/Implementations/ActivityService.cs`

### 5.1 Creación

`CreateAsync(ActivityCreateDto dto)`:

1. Valida que el trimestre seleccionado esté activo:

```csharp
await _trimesterService.ValidateTrimesterActiveAsync(dto.TrimesterCode);
```

2. Busca el trimestre por nombre y escuela:

```csharp
var trimestre = await _context.Trimesters
    .FirstOrDefaultAsync(t => t.Name == dto.TrimesterCode && t.SchoolId == currentUserSchool.Id);
```

3. Persiste:

```csharp
var activity = new Activity
{
    Id = Guid.NewGuid(),
    Name = dto.Name,
    Type = dto.Type,
    Trimester = dto.TrimesterCode,
    TrimesterId = trimestre.Id,
    TeacherId = dto.TeacherId,
    SubjectId = dto.SubjectId,
    GroupId = dto.GroupId,
    GradeLevelId = dto.GradeLevelId,
    SchoolId = currentUserSchool.Id,
    DueDate = dto.DueDate.ToUniversalTime()
};
```

4. Auditoría:

```csharp
await AuditHelper.SetAuditFieldsForCreateAsync(activity, _currentUserService);
```

### 5.2 Actualización

`UpdateAsync(ActivityUpdateDto dto)`:

```csharp
activity.Trimester = dto.TrimesterCode;
activity.TrimesterId = trimestre.Id;
activity.DueDate = dto.DueDate.ToUniversalTime();
```

Conclusión:

La actividad guarda el trimestre como decisión explícita del formulario, no como cálculo por fecha. También guarda `TrimesterId`.

### 5.3 Consulta de actividades

`GetByTeacherGroupTrimesterAsync` filtra por:

```csharp
a.TeacherId == teacherId
a.GroupId == groupId
a.Trimester == trimesterCode
a.SchoolId == currentUserSchool.Id
a.TrimesterId == trimestre.Id
a.SubjectId == subjectId
a.GradeLevelId == gradeLevelId
```

Conclusión:

El sistema no usa `due_date` para decidir si una actividad pertenece al trimestre. Usa `activities.trimester` y `activities.TrimesterId`.

---

## 6. Activity entity y base de datos

Entidad: `Models/Activity.cs`

Campos relevantes:

```text
SchoolId
SubjectId
TeacherId
GroupId
Name
Type
Trimester
CreatedAt
DueDate
GradeLevelId
TrimesterId
CreatedBy
UpdatedAt
UpdatedBy
```

Mapeo EF:

```text
activities.trimester
activities."TrimesterId"
activities.created_at
activities.due_date
```

No existe `academic_year_id` en `activities`.

---

## 7. StudentActivityScores — notas

Entidad: `Models/StudentActivityScore.cs`

Campos relevantes:

```text
StudentId
ActivityId
Score
CreatedAt
AcademicYearId
SchoolId
CreatedBy
UpdatedBy
```

No tiene:

```text
trimester
trimester_id
subject_id
teacher_id
group_id
grade_id
```

Esos datos se obtienen por relación:

```text
student_activity_scores.activity_id -> activities.id
```

### 7.1 Guardado de notas

En `SaveBulkFromNotasAsync`:

1. Valida trimestre activo:

```csharp
await _trimesterService.ValidateTrimesterActiveAsync(trimCode);
```

2. Busca `TrimesterId` por código:

```csharp
trimesterIdByCode[trimCode] = trimesterRow.Id;
```

3. Si la actividad no existe, la crea con:

```csharp
Trimester = dto.Trimester,
TrimesterId = trimesterId,
CreatedAt = DateTime.UtcNow
```

4. Crea la nota con:

```csharp
AcademicYearId = activeAcademicYear?.Id,
CreatedAt = DateTime.UtcNow
```

Conclusión:

La nota no recalcula trimestre por fecha. La nota pertenece al trimestre de su actividad.

### 7.2 Año académico de notas

El año académico sí se guarda en la nota:

```csharp
var activeAcademicYear = await _academicYearService.GetActiveAcademicYearAsync(currentUserSchool.Id);
AcademicYearId = activeAcademicYear?.Id
```

Conclusión:

`academic_year_id` de notas viene del año académico activo al momento de guardar, no de una fecha seleccionada por el docente.

---

## 8. Attendance — asistencia

Entidad: `Models/Attendance.cs`

Campos relevantes:

```text
StudentId
TeacherId
GroupId
GradeId
Date
Status
CreatedAt
SchoolId
CreatedBy
UpdatedBy
UpdatedAt
```

No tiene:

```text
subject_id
trimester_id
academic_year_id
```

### 8.1 Guardado desde TeacherGradebook

En la vista:

```javascript
date: fecha
```

En `AttendanceService.SaveAttendancesAsync`:

```csharp
Date = dto.Date,
CreatedAt = DateTime.UtcNow
```

Conclusión:

- `attendance.date` viene de la pantalla.
- `attendance.created_at` viene del sistema.
- No se guarda trimestre.
- No se guarda año académico.
- No se usa calendario para clasificar la asistencia al guardar.

### 8.2 Consulta de asistencia por fecha

```csharp
Where(a => a.GroupId == groupId && a.GradeId == gradeId && a.Date == date)
```

No filtra por:

- materia;
- trimestre;
- año académico;
- docente.

---

## 9. TrimesterService y calendario académico

### 9.1 `GetAllAsync`

Carga trimestres por escuela y los devuelve ordenados. También puede desactivar trimestres vencidos:

```csharp
if (t.IsActive && t.EndDate < now)
{
    t.IsActive = false;
}
```

### 9.2 `ValidateTrimesterActiveAsync`

Valida:

```csharp
var trimestre = await _context.Trimesters
    .FirstOrDefaultAsync(t => t.Name == trimesterName && t.SchoolId == currentUserSchool.Id);

if (!trimestre.IsActive)
    throw ...
```

No valida:

- si `DueDate` está dentro del rango del trimestre;
- si la fecha actual está dentro del rango;
- si una nota/asistencia pertenece por fecha al trimestre.

### 9.3 `EditarFechasTrimestreAsync`

Permite modificar `StartDate` y `EndDate` del trimestre:

```csharp
trimestre.StartDate = dto.StartDate.ToUniversalTime();
trimestre.EndDate = dto.EndDate.ToUniversalTime();
```

No actualiza actividades ni notas relacionadas.

---

## 10. Pregunta crítica

### Si hoy modifico `2T = 22/06/2026`, pero una actividad fue creada hace meses, ¿la actividad sigue siendo 2T?

**Sí.**

La actividad sigue siendo `2T` porque almacena:

```text
activities.trimester = '2T'
activities."TrimesterId" = id del trimestre 2T
```

Cambiar `trimester.start_date` no cambia `activities.trimester` ni `activities."TrimesterId"`.

### ¿El sistema vuelve a calcular el trimestre usando las fechas actuales?

Para actividades y notas: **No**.

Para asistencia en reportes que calculan por fecha: **Sí puede cambiar la clasificación**, porque `attendance` no guarda trimestre. Si un reporte usa:

```text
attendance.date BETWEEN trimester.start_date AND trimester.end_date
```

entonces cambiar fechas de `trimester` afecta la interpretación histórica de la asistencia.

---

## 11. Evidencia en producción

Todas las consultas fueron `SELECT`.

### 11.1 Columnas reales

Consulta:

```sql
SELECT 'activities' AS table_name, column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema='public'
  AND table_name='activities'
  AND column_name IN ('created_at','due_date','trimester','TrimesterId','academic_year_id','school_id')
UNION ALL
SELECT 'student_activity_scores', column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema='public'
  AND table_name='student_activity_scores'
  AND column_name IN ('created_at','activity_id','academic_year_id','school_id')
UNION ALL
SELECT 'attendance', column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema='public'
  AND table_name='attendance'
  AND column_name IN ('date','created_at','school_id','teacher_id','student_id','group_id','grade_id','trimester','academic_year_id')
ORDER BY table_name, column_name;
```

Resultado resumido:

| Tabla | Columnas relevantes |
|---|---|
| `activities` | `created_at`, `due_date`, `school_id`, `trimester`, `"TrimesterId"` |
| `student_activity_scores` | `activity_id`, `created_at`, `academic_year_id`, `school_id` |
| `attendance` | `date`, `created_at`, `teacher_id`, `student_id`, `group_id`, `grade_id`, `school_id` |

No existen en `attendance`:

```text
trimester
trimester_id
academic_year_id
subject_id
```

### 11.2 Resumen de actividades por trimestre textual

| Trimestre | Actividades | Mínima creación | Mínima due_date | Máxima due_date |
|---|---:|---:|---:|---:|
| 1T | 5,395 | 2026-03-31 | 0026-03-16 | 2026-12-05 |
| 2T | 497 | 2026-06-07 | 0026-06-16 | 2026-12-06 |
| 3T | 34 | 2025-11-13 | 2025-10-03 | 2025-12-15 |

Observación:

Hay fechas anómalas de año `0026` en `due_date`; esto confirma que `due_date` no determina automáticamente el trimestre.

### 11.3 Ejemplos de actividades `2T` antes del inicio formal configurado

El calendario formal indica `2T` desde `2026-06-23`, pero existen actividades `2T` creadas el `2026-06-07` y con `due_date` antes del `2026-06-23`.

Ejemplos:

| Actividad | Trimestre | Inicio formal 2T | Creada | Due date | Materia | Docente | Grupo | Grado |
|---|---|---:|---:|---:|---|---|---|---|
| GUIA DE TRABAJO II TRIMESTRE | 2T | 2026-06-23 | 2026-06-07 | 2026-06-10 | LÓGICA / FILOSOFÍA | Enrique Aizprua | A1 | 12 |
| GUIA DE TRABAJO II TRIMESTRE | 2T | 2026-06-23 | 2026-06-07 | 2026-06-09 | LÓGICA / FILOSOFÍA | Enrique Aizprua | E1 | 12 |
| Examen firmado y corregido | 2T | 2026-06-23 | 2026-06-07 | 2026-06-17 | GEOGRAFÍA | GERTRUDIS KIRTON WINTER | H | 7 |
| Vocabulario Ilustrado | 2T | 2026-06-23 | 2026-06-07 | 2026-06-17 | GEOGRAFÍA | GERTRUDIS KIRTON WINTER | H | 7 |

Interpretación:

La actividad es `2T` porque el docente/sistema la guardó como `2T`, no porque su `due_date` caiga dentro del rango formal del 2T.

### 11.4 Resumen de notas por trimestre heredado de actividad

| Trimestre de actividad | Notas | Con año académico | Mínima fecha nota | Máxima fecha nota |
|---|---:|---:|---:|---:|
| 1T | 84,271 | 84,271 | 2026-03-31 | 2026-06-10 |
| 2T | 6,634 | 6,634 | 2026-06-09 | 2026-06-21 |

### 11.5 Ejemplos de notas `2T`

Las notas no tienen columna `trimester`; se muestra el trimestre desde la actividad:

| Score created | Academic year | Actividad | Trimestre actividad | Activity created | Materia | Docente | Grupo | Grado |
|---:|---|---|---|---:|---|---|---|---|
| 2026-06-09 | 2026 | Separador decorado | 2T | 2026-06-09 | NOCIONES DE COMERCIO | TAYNA SALAZAR | O | 8 |
| 2026-06-09 | 2026 | Separador decorado | 2T | 2026-06-09 | NOCIONES DE COMERCIO | TAYNA SALAZAR | O | 8 |

Interpretación:

La nota conserva el trimestre a través de `activity_id -> activities.trimester`.

### 11.6 Resumen de asistencia

| Métrica | Valor |
|---|---:|
| Total asistencias | 32,297 |
| Con `school_id` | 0 |
| Mínima fecha de asistencia (`date`) | 2026-03-02 |
| Máxima fecha de asistencia (`date`) | 2026-09-10 |
| Mínima creación (`created_at`) | 2026-03-31 |
| Máxima creación (`created_at`) | 2026-06-20 |

Comparación:

```text
attendance.date       = fecha académica seleccionada en pantalla
attendance.created_at = momento del sistema al guardar
```

En el rango 15–19 de junio:

| Métrica | Conteo |
|---|---:|
| Asistencias con `date` 2026-06-15 a 2026-06-19 | 6,426 |
| Asistencias creadas (`created_at`) 2026-06-15 a 2026-06-19 | 7,885 |

Esto demuestra que `date` y `created_at` no son equivalentes.

---

## 12. Trazabilidad completa

### 12.1 Crear actividad

```text
Docente
 ↓
TeacherGradebook/Index
 ↓
Selecciona:
  - trimestre (#selTrimester)
  - materia/grado/grupo (#selGroup)
  - fecha de entrega (#activityDueDate)
 ↓
JS envía FormData:
  - TrimesterCode = valor seleccionado
  - DueDate = fecha seleccionada
  - Date = new Date().toISOString() (no persistido en Activity)
 ↓
TeacherGradebookController.CreateActivity
 ↓
ActivityService.CreateAsync
 ↓
ValidateTrimesterActiveAsync(TrimesterCode)
 ↓
Busca Trimester por Name + SchoolId
 ↓
Guarda:
  - activities.trimester = TrimesterCode
  - activities.TrimesterId = trimester.Id
  - activities.due_date = DueDate
  - activities.created_at = sistema/auditoría/default
  - activities.school_id = escuela actual
```

### 12.2 Guardar notas

```text
Docente edita notas
 ↓
TeacherGradebook/Index
 ↓
JS usa:
  - trimester = #selTrimester
  - activity name/type
  - subject/group/grade/teacher
 ↓
POST /TeacherGradebook/GuardarNotasTemp
 ↓
TeacherGradebookController.GuardarNotasTemp
 ↓
StudentActivityScoreService.SaveBulkFromNotasAsync
 ↓
Valida trimestre activo por código
 ↓
Busca o crea Activity con:
  - Trimester = dto.Trimester
  - TrimesterId = id del trimestre
 ↓
Crea/actualiza StudentActivityScore con:
  - activity_id
  - score
  - academic_year_id = año académico activo
  - created_at = DateTime.UtcNow
```

### 12.3 Guardar asistencia

```text
Docente
 ↓
TeacherGradebook/Index
 ↓
Selecciona:
  - fecha (#fecha)
  - materia/grado/grupo (#filtroGradoAsistencia)
  - estado por estudiante
 ↓
JS envía:
  - studentId
  - teacherId
  - groupId
  - gradeId
  - date = fecha seleccionada
  - status
 ↓
TeacherGradebookController.SaveAttendances
 ↓
AttendanceService.SaveAttendancesAsync
 ↓
Guarda:
  - attendance.date = dto.Date
  - attendance.created_at = DateTime.UtcNow
  - attendance.teacher_id
  - attendance.student_id
  - attendance.group_id
  - attendance.grade_id
  - attendance.status
```

No guarda:

```text
subject_id
trimester_id
academic_year_id
school_id
created_by
updated_by
```

---

## 13. Qué pasa si cambia el calendario después

### Actividades

No se recalculan.

Si una actividad fue creada como:

```text
activities.trimester = '2T'
activities.TrimesterId = id_2T
```

seguirá siendo `2T` aunque cambien:

```text
trimester.start_date
trimester.end_date
```

### Notas

No tienen trimestre propio. Siguen el trimestre de su `Activity`.

Si la actividad sigue siendo `2T`, la nota sigue apareciendo como `2T` en consultas que unen con `activities`.

### Asistencia

Sí puede cambiar su clasificación en reportes basados en fechas, porque no guarda trimestre.

Ejemplo:

```text
attendance.date = 2026-06-15
```

Si `2T.start_date` cambia de `2026-06-23` a `2026-06-15`, ese mismo registro empezaría a contarse como 2T en reportes que usen rango de calendario.

---

## 14. Respuestas finales

### 1. ¿El trimestre viene del calendario?

Para actividades/notas: parcialmente. El docente selecciona `1T/2T/3T`, y el sistema usa el calendario para buscar el `TrimesterId` y validar `IsActive`, pero no calcula el trimestre por fecha.

Para asistencia: no se guarda trimestre; si un reporte lo necesita, puede inferirlo por calendario.

### 2. ¿El trimestre viene de una selección manual?

Sí para actividades y notas en `TeacherGradebook`.

### 3. ¿La fecha viene del sistema?

Sí para `created_at` de actividades, notas y asistencias.

### 4. ¿La fecha viene de la pantalla?

Sí para:

- `activities.due_date`
- `attendance.date`

### 5. ¿Cambiar el calendario afecta registros históricos?

Depende:

- Actividades: no cambia su `trimester` guardado.
- Notas: no cambia su trimestre heredado si la actividad no cambia.
- Asistencia: sí puede cambiar su clasificación por reportes si se calcula por rango de fechas.

### 6. ¿Las actividades conservan su trimestre original?

Sí. Guardan `activities.trimester` y `activities.TrimesterId`.

### 7. ¿Las notas conservan su trimestre original?

Indirectamente sí, porque conservan `activity_id` y la actividad conserva su trimestre.

### 8. ¿La asistencia conserva su trimestre original?

No. La asistencia no tiene trimestre original persistido.

### 9. ¿El problema actual parece ser de calendario o de asistencia?

Es una combinación, pero el problema estructural principal está en asistencia:

- El calendario tiene una brecha formal entre 1T y 2T.
- Actividades/notas pueden operar como 2T fuera del rango formal porque su trimestre es selección manual.
- Asistencia no guarda trimestre, así que queda dependiente de rangos de calendario para reportes.

Conclusión:

```text
El problema no es que las actividades/notas “pierdan” trimestre al cambiar calendario.
El problema es que asistencia no conserva trimestre/año/materia y se interpreta por fecha.
```

---

## 15. Recomendación técnica

Sin implementar todavía:

1. No cambiar reglas de actividades/notas sin revisar el impacto.
2. No asumir que `due_date` determina trimestre.
3. Para asistencia futura, guardar explícitamente:
   - `subject_id`
   - `trimester_id`
   - `academic_year_id`
   - `school_id`
4. Mantener compatibilidad con históricos sin trimestre.
5. Si se cambia calendario, validar reportes de asistencia, no tanto actividades/notas.

---

## 16. Confirmación de alcance

Este análisis:

- No modificó código.
- No modificó datos.
- No creó migraciones.
- No ejecutó `UPDATE`.
- No hizo commit.
- No hizo push.
- Solo usó consultas `SELECT` y lectura de código.

