# Análisis técnico: `/TeacherGradebook/Index` — visibilidad de notas entre consejeros del mismo grupo

**Alcance:** diagnóstico de causa raíz únicamente (sin cambios de código ni propuesta de solución).  
**Base de datos:** PostgreSQL en Render, validada mediante `psql` con la cadena `ConnectionStrings:DefaultConnection` de `appsettings.json`.  
**Fecha del análisis:** 28 de abril de 2026.

---

## 1. Causa raíz exacta

El módulo **filtra de forma explícita todas las actividades y notas por el campo `activities.teacher_id` igual al identificador del docente en sesión** (expuesto al front como `TeacherId` / `Model.TeacherId`). Esa decisión recorre la cadena **servicio → consultas EF → vista**, de modo que **un usuario solo ve filas cuya actividad está “titularizada” a su propio `teacher_id`**. Las notas de otros profesores o consejeros existen en la misma `group_id`, pero **quedan fuera del conjunto de actividades consultado**, por lo que no aparecen columnas ni puntuaciones asociadas.

No es un fallo de “join incorrecto” con `subject_assignments` en la lectura del libro: la tabla `activities` **no modela `subject_assignment_id`**; relaciona `subject_id`, `group_id`, `grade_level_id` y **`teacher_id`** directamente. El problema es el **criterio de filtrado por docente**, coherente en todo el stack pero **incompatible con el requisito de visibilidad por grupo** para consejería compartida.

---

## 2. Consultas y filtros identificados (código)

### 2.1 `ActivityService.GetByTeacherGroupTrimesterAsync`

Filtra actividades con:

- `a.TeacherId == teacherId`  
- más `GroupId`, `Trimester`, `SubjectId`, `GradeLevelId`, `SchoolId`, `TrimesterId`.

**Ubicación:** `Services/Implementations/ActivityService.cs` (consulta sobre `_context.Activities`).

### 2.2 `StudentActivityScoreService.GetNotasPorFiltroAsync`

Filtra notas con:

- `sa.Activity.TeacherId == notes.TeacherId`  
- más `SubjectId`, `GroupId`, `GradeLevelId`, `Trimester`.

**Ubicación:** `Services/Implementations/StudentActivityScoreService.cs`.

### 2.3 `StudentActivityScoreService.GetGradeBookAsync`

Cabeceras del libro con:

- `a.TeacherId == teacherId`  
- más `GroupId`, `Trimester`, `SubjectId`, `GradeLevelId`.

**Ubicación:** mismo archivo.

### 2.4 `StudentActivityScoreService.GetPromediosFinalesAsync`

Incluye:

- `x.TeacherId == notes.TeacherId` en el filtro de notas agregadas.

**Ubicación:** mismo archivo.

### 2.5 `TeacherGradebookController`

- **`GetNotasCargadas`:** llama a `GetByTeacherGroupTrimesterAsync(notes.TeacherId, …)` y `GetNotasPorFiltroAsync(notes)`; el DTO exige `TeacherId` y `GroupId`.
- **`GradeBookJson`:** llama a `GetGradeBookAsync(teacherId, …)` con `teacherId = GetTeacherId()` (usuario actual).
- **`Index`:** inyecta `TeacherId = teacherId` en el `TeacherGradebookViewModel` (usuario actual).

**Ubicación:** `Controllers/TeacherGradebookController.cs`.

### 2.6 Vista `Views/TeacherGradebook/Index.cshtml`

El cliente usa **`const teacherId = '@Model.TeacherId'`** y lo envía en llamadas a `GetNotasCargadas`, payloads JSON y formularios (`TeacherId`). Es decir, **siempre el docente logueado**, no un agregado por grupo.

---

## 3. Evidencia desde base de datos (Render)

Conexión validada contra el host configurado en `appsettings.json` (instancia Render Oregon). Columnas relevantes en `activities`: **`teacher_id`**, **`created_by`** (auditoría). La columna **`created_by_user_id` no existe** en el esquema mapeado por EF; el equivalente es **`created_by`**.

### 3.1 Actividades repartidas entre muchos docentes

`SELECT teacher_id, COUNT(*) FROM activities WHERE teacher_id IS NOT NULL GROUP BY teacher_id` muestra **múltiples UUID de docente** con conteos elevados (decenas/cientos de filas cada uno), confirmando que **las actividades están segmentadas por `teacher_id`**.

### 3.2 Un mismo grupo con varios docentes en `activities`

```text
group_id                             | distinct_teachers
-------------------------------------+------------------
f3ecb2b9-68d9-4737-8cb1-277758ac7d1a | 8
784e9e5b-d65f-4c8d-bc0b-7853729c123b | 7
...
```

(Ejecutado: `COUNT(DISTINCT teacher_id)` agrupado por `group_id`, limitando grupos con más de un docente.)

### 3.3 Misma `group_id`, distintos `teacher_id` en filas concretas

Para `group_id = f3ecb2b9-68d9-4737-8cb1-277758ac7d1a`, una muestra ordenada muestra actividades con **`teacher_id` 3f1d46b6-4849-4ae1-8535-930e8ed0f8b7** y **3ffe9fc7-8b05-4d9e-8cd3-3cc5d8beec70** (y otras materias/trimestres), es decir, **el mismo grupo acumula actividades “de titular” distintos**.

### 3.4 Asignaciones docente–grupo (`teacher_assignments`)

La tabla usa **`teacher_id`**, no `user_id`. Consulta corregida respecto al ejemplo del enunciado:

`SELECT DISTINCT ta.teacher_id, sa.group_id FROM teacher_assignments ta JOIN subject_assignments sa ON ta.subject_assignment_id = sa.id`

Resultado: **el mismo `group_id` aparece asociado a distintos `teacher_id`**, coherente con varios profesores enseñando/materias en el mismo grupo.

### 3.5 Duplicados en `subject_assignments`

`GROUP BY subject_id, group_id, grade_level_id HAVING COUNT(*) > 1` devuelve filas (por ejemplo pares con `count = 2`), indicando **posible duplicación de asignaciones** para la misma terna. Esto puede añadir complejidad operativa, pero **no sustituye al hallazgo principal**: la aplicación ya aísla por **`activities.teacher_id`** antes de cualquier matización por `subject_assignment`.

### 3.6 Auditoría `created_by` vs titular `teacher_id`

`GROUP BY created_by` también muestra distribución por usuario creador; hay filas con `created_by` nulo. Para el comportamiento del libro de calificaciones, **el filtro efectivo en EF es `TeacherId`/`teacher_id`**, no solo auditoría.

---

## 4. Flujo real de datos (base de datos → vista)

1. **Persistencia:** Al crear una actividad (`ActivityService.CreateAsync`), se guarda `TeacherId = dto.TeacherId` (desde el portal, alineado con el docente). Al guardar notas en bloque (`SaveBulkFromNotasAsync`), las actividades se buscan o crean con **clave que incluye `TeacherId`**. El índice único `idx_activities_unique_lookup` incluye **`TeacherId`** junto con nombre, tipo, materia, grupo y trimestre, **reforzando un registro de actividades por docente** incluso para el mismo grupo/materia.

2. **Lectura para la pantalla:** El navegador envía **`TeacherId` = usuario actual**. Los servicios cargan actividades y `student_activity_scores` **solo para actividades cuyo `teacher_id` coincide**.

3. **Resultado en UI:** La tabla solo muestra columnas de actividades “del docente actual” y notas ligadas a esas actividades. **Las actividades/notas con otro `teacher_id` en el mismo grupo no participan en la consulta** y no se muestran.

---

## 5. Qué debería pasar vs qué está pasando

| Aspecto | Comportamiento esperado (requisito de negocio informado) | Comportamiento observado |
|--------|----------------------------------------------------------|---------------------------|
| Alcance de visibilidad | Notas visibles para **todo el grupo de consejería** (u homólogo por grupo), independientemente del docente que las cargó. | Visibilidad **acotada al `teacher_id` del usuario** en todas las rutas de lectura principales del libro. |
| Datos en BD | Existen actividades y notas para **varios `teacher_id`** en la misma `group_id` (validado). | La aplicación **solo consulta un subconjunto** (un docente). |
| UI | Podría depender de selección de contexto de grupo; en la práctica envía siempre el docente en sesión. | **`Model.TeacherId` fijado al usuario actual** en todas las llamadas relevantes. |

---

## 6. Nivel de impacto

**ALTO.** Afecta la funcionalidad central del libro de calificaciones para cualquier escenario donde **varios docentes** (incluidos varios consejeros con acceso al mismo grupo) debieran ver **un mismo conjunto de calificaciones a nivel grupo**. Los datos están en base de datos pero **la capa de aplicación los excluye sistemáticamente** mediante filtros por `TeacherId`.

---

## 7. Notas técnicas complementarias

- **Nombre de columnas SQL:** usar `teacher_id` y `created_by` en tablas EF mapeadas; no `created_by_user_id` ni `subject_assignment_id` en `activities` según el modelo actual.
- **Validación de duplicados en `subject_assignments`:** presente en producción; conviene tenerlo en cuenta en diseño futuro, pero **la causa raíz del síntoma “solo veo mis notas” está acreditada en filtros por `teacher_id`** en servicios y controlador.

---

*Fin del análisis.*
