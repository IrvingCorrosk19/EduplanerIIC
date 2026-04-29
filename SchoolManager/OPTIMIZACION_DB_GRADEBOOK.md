# Optimización: Consejería → Promedios por matería (`/TeacherGradebook/Index`)

Documento generado a partir del análisis previo (`ANALISIS_TEACHER_GRADEBOOK.md`), diagnóstico en PostgreSQL (Render) y cambios aplicados en código.

**Fecha:** 28 de abril de 2026.

---

## 1. Índices actuales (`pg_indexes`, `public`)

### `activities`

| Índice | Columnas (resumen) |
|--------|---------------------|
| `activities_pkey` | `id` (PK) |
| `IX_activities_ActivityTypeId` | `"ActivityTypeId"` |
| `IX_activities_TrimesterId` | `"TrimesterId"` |
| `IX_activities_school_id` | `school_id` |
| `IX_activities_subject_id` | `subject_id` |
| **`idx_activities_group`** | **`group_id`** |
| `idx_activities_teacher` | `teacher_id` |
| `idx_activities_trimester` | `trimester` |
| `idx_activities_unique_lookup` | `name`, `type`, `subject_id`, `group_id`, `teacher_id`, `trimester` |
| **`idx_activities_group_grade`** *(añadido en esta optimización)* | **`group_id`, `grade_level_id`** |

### `student_activity_scores`

| Índice | Columnas (resumen) |
|--------|---------------------|
| `student_activity_scores_pkey` | `id` (PK) |
| **`idx_scores_activity`** | **`activity_id`** *(ya existía)* |
| **`idx_scores_student`** | **`student_id`** *(ya existía)* |
| `uq_scores` | `(student_id, activity_id)` único |
| `ix_student_activity_scores_academic_year_id` | `academic_year_id` |
| `ix_student_activity_scores_student_academic_year` | `(student_id, academic_year_id)` |

**Conclusión:** `idx_scores_activity` e `idx_scores_student` ya cubrían el join habitual `scores → activities`; **no** se duplicaron índices equivalentes.

---

## 2. Problemas detectados en `EXPLAIN ANALYZE`

Consulta de referencia (promedios por estudiante y materia en un grupo/grado):

```sql
SELECT s.student_id, a.subject_id, AVG(s.score)
FROM student_activity_scores s
JOIN activities a ON s.activity_id = a.id
WHERE a.group_id = '<GROUP_UUID>'
  AND a.grade_level_id = '<GRADE_UUID>'
GROUP BY s.student_id, a.subject_id;
```

### Antes de `idx_activities_group_grade`

- **`activities`:** `Bitmap Index Scan` sobre **`idx_activities_group`** (`group_id`).
- **Filtrado tardío:** `Filter: (grade_level_id = '…')` con **filas descartadas por filtro** después del bitmap heap scan (grado no forma parte del índice usado).
- **`student_activity_scores`:** `Index Scan` sobre **`idx_scores_activity`** por `activity_id` (óptimo para el nested loop).

### Después de `idx_activities_group_grade`

- **`activities`:** `Bitmap Index Scan` sobre **`idx_activities_group_grade`** con **`Index Cond` conjunta** `(group_id, grade_level_id)`.
- **Sin filtro posterior por grado** sobre el heap para ese predicado: las filas ya llegan acotadas por ambas columnas.
- **`student_activity_scores`:** mismo uso de **`idx_scores_activity`**.

### Comparativa orientativa (mismo dataset de prueba en Render)

| Métrica | Antes | Después |
|--------|-------|---------|
| Execution Time | ~1.36 ms | ~1.40 ms |
| Plan | Bitmap heap + **rows removed by filter** (grado) | Bitmap heap **sin** `Rows Removed by Filter` para grado |
| Heap blocks `activities` (exact) | 11 | 7 |

En volúmenes mayores, reducir recheck/filter sobre `grade_level_id` suele ser donde se nota más el beneficio; en el volumen medido el tiempo total ya era bajo.

---

## 3. Índices propuestos / aplicados

| Índice | Decisión |
|--------|-----------|
| `(group_id, grade_level_id)` en `activities` | **Creado** como `idx_activities_group_grade` con **`CREATE INDEX CONCURRENTLY IF NOT EXISTS`** (operación **no bloqueante** en el sentido habitual de PostgreSQL para escrituras concurrentes). Script repetible: `Scripts/idx_activities_group_grade.sql`. |
| `(activity_id)` en `student_activity_scores` | **Ya existía** (`idx_scores_activity`) → **no crear**. |
| `(student_id)` en `student_activity_scores` | **Ya existía** (`idx_scores_student`) → **no crear**. |

**Restricciones respetadas:** sin `DROP`, sin borrar tablas, sin alterar columnas; solo creación idempotente de un índice adicional.

---

## 4. EXPLAIN antes vs después (extracto)

### Antes

```text
Bitmap Heap Scan on activities a
  Recheck Cond: (group_id = '…'::uuid)
  Filter: (grade_level_id = '…'::uuid)
  Rows Removed by Filter: 23
...
Bitmap Index Scan on idx_activities_group
  Index Cond: (group_id = '…'::uuid)
```

### Después

```text
Bitmap Heap Scan on activities a
  Recheck Cond: ((group_id = '…'::uuid) AND (grade_level_id = '…'::uuid))
  Heap Blocks: exact=7
...
Bitmap Index Scan on idx_activities_group_grade
  Index Cond: ((group_id = '…'::uuid) AND (grade_level_id = '…'::uuid))
```

---

## 5. Impacto en rendimiento y aplicación

### Base de datos

- Lecturas por grupo+grado sobre **`activities`** más alineadas al predicato compuesto.
- Sin duplicar índices redundantes en **`student_activity_scores`**.

### Entity Framework (consejería – `GetCounselorGroupAverages`)

| Antes | Después |
|-------|---------|
| **N+1:** por cada estudiante × cada materia se llamaba `GetNotasPorFiltroAsync`, que además filtraba por **`TeacherId`** (notas solo del docente en sesión). | **Una** consulta agregada (`GetCounselorGroupSubjectAveragesForTrimesterAsync`): join puntual `scores` + `activities`, **sin filtro por docente**, agrupación en memoria por `(student_id, subject_id)`. |
| `Include` + reflexión sobre `subjectAssignments`. | Tipado fuerte `SubjectAssignment`, materias **distintas** por `SubjectId`, sin reflexión. |
| Sin `AsNoTracking` en algunos lecturas. | `AsNoTracking()` en la nueva consulta y en `GetNotasPorFiltroAsync`; `SubjectAssignments` en `GetByGroupAndGradeAsync` con **`AsNoTracking()`** (solo lectura). |

**Archivos tocados (resumen):**

- `Services/Implementations/StudentActivityScoreService.cs` — nuevo método de agregación + `AsNoTracking` en `GetNotasPorFiltroAsync`.
- `Services/Interfaces/IStudentActivityScoreService.cs` — contrato del nuevo método.
- `Dtos/CounselorSubjectAverageDto.cs` — DTO de salida.
- `Controllers/TeacherGradebookController.cs` y `TeacherGradebookDuplicateController.cs` — flujo consejería sin N+1 ni filtro por profesor.
- `Services/Implementations/SubjectAssignmentService.cs` — `AsNoTracking` en `GetByGroupAndGradeAsync`.

---

## 6. Confirmación de no afectación de datos

- No se ejecutaron `DELETE`, `UPDATE` masivos ni `ALTER TABLE`.
- Solo se añadió un **índice nuevo** con **`IF NOT EXISTS`** y **`CONCURRENTLY`** (script reproducible).
- La lógica de negocio de consejería pasa de “solo mi `teacher_id`” a “**todo el grupo / materias asignadas**”, coherente con el análisis funcional previo.

---

## 7. Despliegue recomendado del índice en otros entornos

1. Ejecutar `Scripts/idx_activities_group_grade.sql` en staging y validar con el mismo `EXPLAIN ANALYZE`.
2. En producción, ejecutar en ventana de bajo tráfico si se prefiere supervisión manual (el modo `CONCURRENTLY` ya reduce bloqueos exclusivos fuertes).
3. Monitorizar tamaño del índice y autovacuum habitual; el índice es **solo lectura acelerada**, no cambia filas.

---

*Fin del documento.*
