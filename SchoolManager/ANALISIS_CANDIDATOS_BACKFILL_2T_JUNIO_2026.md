# Análisis de candidatos a backfill 2T — junio 2026

**Proyecto:** `C:\Proyectos\EduplanerIIC\SchoolManager`  
**Base de datos:** Render Producción  
**Documento base:** `ANALISIS_RECLASIFICACION_ASISTENCIA_2T_DESDE_20260608.md`  
**Alcance:** Solo identificación. No se ejecutó `UPDATE`, no se hizo backfill, no se crearon migraciones, no se modificó código.

---

## 1. Resumen ejecutivo

Rango analizado exclusivamente:

```text
2026-06-15 a 2026-06-19
```

Total de asistencias candidatas:

```text
6,426
```

Clasificación propuesta:

| Confianza | Criterio | Registros |
|---|---|---:|
| Alta | Existe actividad `2T` relacionada y nota `2T` del mismo estudiante en el mismo contexto académico | 3,761 |
| Media | Existe actividad `2T` relacionada, pero no nota `2T` del mismo estudiante en el rango | 908 |
| Baja | No se encontró actividad `2T` relacionada con el mismo docente/grupo/grado en el rango | 1,757 |

Conclusión:

```text
Sí puede plantearse un backfill seguro solo para Alta Confianza, pero no debe ejecutarse todavía.
```

El backfill seguro debe limitarse inicialmente a los **3,761 registros de Alta Confianza** y requiere aprobación institucional previa.

---

## 2. Definición técnica de clasificación

### Tabla base

```sql
SELECT *
FROM attendance
WHERE date BETWEEN DATE '2026-06-15' AND DATE '2026-06-19';
```

### Alta confianza

Una asistencia es **Alta Confianza** si cumple:

1. Existe una actividad `2T` con:
   - mismo `teacher_id`
   - mismo `group_id`
   - mismo `grade_level_id`
   - creada o con vencimiento entre `2026-06-15` y `2026-06-19`
2. Existe al menos una nota `StudentActivityScore` del mismo estudiante asociada a una actividad `2T` con:
   - mismo `teacher_id`
   - mismo `group_id`
   - mismo `grade_level_id`
   - nota creada entre `2026-06-15` y `2026-06-19`

### Media confianza

Una asistencia es **Media Confianza** si:

1. Existe actividad `2T` relacionada con el mismo docente/grupo/grado en el rango.
2. No existe nota `2T` del mismo estudiante en ese contexto durante el rango.

### Baja confianza

Una asistencia es **Baja Confianza** si:

1. No existe actividad `2T` relacionada con el mismo docente/grupo/grado en el rango.

Importante:

La baja confianza **no significa que el registro sea inválido**. Significa que no hay evidencia suficiente en `Activities` / `StudentActivityScores` para reclasificarlo automáticamente.

---

## 3. Consulta exacta de clasificación

Esta consulta clasifica todos los candidatos:

```sql
WITH target AS (
    SELECT a.*
    FROM attendance a
    WHERE a.date BETWEEN DATE '2026-06-15' AND DATE '2026-06-19'
),
classified AS (
    SELECT
        t.id,
        t.date,
        t.student_id,
        t.teacher_id,
        t.group_id,
        t.grade_id,
        t.status,
        EXISTS (
            SELECT 1
            FROM activities act
            WHERE act.trimester = '2T'
              AND act.teacher_id = t.teacher_id
              AND act.group_id = t.group_id
              AND act.grade_level_id = t.grade_id
              AND (
                    act.created_at::date BETWEEN DATE '2026-06-15' AND DATE '2026-06-19'
                 OR act.due_date::date BETWEEN DATE '2026-06-15' AND DATE '2026-06-19'
              )
        ) AS has_related_2t_activity,
        EXISTS (
            SELECT 1
            FROM student_activity_scores sc
            JOIN activities act ON act.id = sc.activity_id
            WHERE sc.student_id = t.student_id
              AND act.trimester = '2T'
              AND act.teacher_id = t.teacher_id
              AND act.group_id = t.group_id
              AND act.grade_level_id = t.grade_id
              AND sc.created_at::date BETWEEN DATE '2026-06-15' AND DATE '2026-06-19'
        ) AS has_related_2t_score
    FROM target t
),
final AS (
    SELECT
        *,
        CASE
            WHEN has_related_2t_activity AND has_related_2t_score THEN 'alta'
            WHEN has_related_2t_activity THEN 'media'
            ELSE 'baja'
        END AS confidence
    FROM classified
)
SELECT
    confidence,
    COUNT(*) AS attendance_rows,
    COUNT(DISTINCT teacher_id) AS teachers,
    COUNT(DISTINCT student_id) AS students,
    COUNT(DISTINCT group_id) AS groups,
    COUNT(DISTINCT grade_id) AS grades,
    MIN(date) AS min_date,
    MAX(date) AS max_date
FROM final
GROUP BY confidence
ORDER BY CASE confidence WHEN 'alta' THEN 1 WHEN 'media' THEN 2 ELSE 3 END;
```

Resultado:

| Confianza | Asistencias | Docentes | Estudiantes | Grupos | Grados | Fecha mínima | Fecha máxima |
|---|---:|---:|---:|---:|---:|---:|---:|
| Alta | 3,761 | 12 | 1,122 | 21 | 6 | 2026-06-15 | 2026-06-19 |
| Media | 908 | 7 | 388 | 10 | 6 | 2026-06-15 | 2026-06-19 |
| Baja | 1,757 | 10 | 521 | 14 | 5 | 2026-06-15 | 2026-06-19 |

---

## 4. Validaciones generales del rango

### Cantidad exacta de asistencias

```text
6,426
```

### Dimensiones afectadas

| Dimensión | Cantidad |
|---|---:|
| Profesores afectados | 19 |
| Estudiantes afectados | 1,362 |
| Grupos afectados | 24 |
| Grados afectados | 6 |
| Fechas afectadas | 5 |

### Conteos por fecha

| Fecha | Asistencias | Docentes | Estudiantes | Grupos | Grados |
|---|---:|---:|---:|---:|---:|
| 2026-06-15 | 1,636 | 15 | 873 | 18 | 6 |
| 2026-06-16 | 1,098 | 11 | 664 | 16 | 6 |
| 2026-06-17 | 401 | 6 | 309 | 7 | 5 |
| 2026-06-18 | 1,580 | 15 | 815 | 20 | 6 |
| 2026-06-19 | 1,711 | 18 | 997 | 22 | 6 |

---

## 5. Clasificación por fecha

| Fecha | Confianza | Registros | Docentes | Grupos | Estudiantes |
|---|---|---:|---:|---:|---:|
| 2026-06-15 | Alta | 766 | 9 | 13 | 539 |
| 2026-06-15 | Media | 271 | 4 | 6 | 162 |
| 2026-06-15 | Baja | 599 | 7 | 9 | 425 |
| 2026-06-16 | Alta | 715 | 5 | 10 | 419 |
| 2026-06-16 | Media | 304 | 5 | 5 | 166 |
| 2026-06-16 | Baja | 79 | 3 | 4 | 79 |
| 2026-06-17 | Alta | 363 | 5 | 6 | 290 |
| 2026-06-17 | Baja | 38 | 1 | 1 | 19 |
| 2026-06-18 | Alta | 894 | 10 | 13 | 498 |
| 2026-06-18 | Media | 161 | 3 | 4 | 109 |
| 2026-06-18 | Baja | 525 | 7 | 11 | 308 |
| 2026-06-19 | Alta | 1,023 | 12 | 18 | 707 |
| 2026-06-19 | Media | 172 | 3 | 5 | 131 |
| 2026-06-19 | Baja | 516 | 6 | 12 | 432 |

---

## 6. Estados de asistencia por clasificación

| Confianza | Presentes | Ausentes | Tardanzas | Fugas | Excusas |
|---|---:|---:|---:|---:|---:|
| Alta | 2,722 | 884 | 56 | 66 | 33 |
| Media | 543 | 243 | 39 | 37 | 46 |
| Baja | 1,188 | 489 | 46 | 32 | 2 |

---

## 7. Profesores afectados

### Todos los profesores del rango

| Docente | Asistencias | Grupos | Estudiantes |
|---|---:|---:|---:|
| GERTRUDIS KIRTON WINTER | 736 | 7 | 330 |
| Fabio Alexander Ortíz Yee | 638 | 10 | 344 |
| Jessica Singh | 633 | 6 | 210 |
| MARIA ELENA LLORENTE ORTEGA | 590 | 8 | 408 |
| Ronaldo Barría Trujillo | 555 | 7 | 332 |
| DORIS CABALLERO | 519 | 5 | 140 |
| ELISETH CASTRO | 480 | 6 | 146 |
| JACQUELINE MARTINEZ | 415 | 5 | 173 |
| GLADYS DIAZ DE ZAMBRANO | 382 | 3 | 115 |
| HAZAEL CERRUD | 298 | 6 | 106 |
| NORIS QUINTERO | 268 | 6 | 196 |
| YULISSA MAIDETH LÓPEZ FERNÁNDEZ | 186 | 3 | 54 |
| LUIS MORALES | 170 | 2 | 68 |
| FRANCISCO CORTES | 148 | 1 | 44 |
| Julio J. Magallón L. | 113 | 2 | 37 |
| Enrique Aizprua | 78 | 3 | 78 |
| IRASEMA ATENCIO | 76 | 1 | 38 |
| GUILLERMO MORALES | 73 | 1 | 37 |
| Nayi Stephany Campbell Ortiz | 68 | 2 | 68 |

### Alta confianza por docente

| Docente | Registros | Fechas | Grupos | Estudiantes |
|---|---:|---:|---:|---:|
| MARIA ELENA LLORENTE ORTEGA | 590 | 5 | 8 | 408 |
| Fabio Alexander Ortíz Yee | 574 | 4 | 8 | 312 |
| Ronaldo Barría Trujillo | 555 | 5 | 7 | 332 |
| ELISETH CASTRO | 427 | 5 | 5 | 111 |
| GERTRUDIS KIRTON WINTER | 426 | 4 | 4 | 192 |
| JACQUELINE MARTINEZ | 415 | 3 | 5 | 173 |
| GLADYS DIAZ DE ZAMBRANO | 382 | 4 | 3 | 115 |
| NORIS QUINTERO | 137 | 2 | 3 | 99 |
| HAZAEL CERRUD | 87 | 3 | 1 | 29 |
| IRASEMA ATENCIO | 76 | 2 | 1 | 38 |
| GUILLERMO MORALES | 54 | 3 | 1 | 18 |
| Enrique Aizprua | 38 | 1 | 2 | 38 |

### Media confianza por docente

| Docente | Registros | Fechas | Grupos | Estudiantes |
|---|---:|---:|---:|---:|
| DORIS CABALLERO | 303 | 3 | 3 | 77 |
| GERTRUDIS KIRTON WINTER | 242 | 2 | 3 | 104 |
| FRANCISCO CORTES | 148 | 4 | 1 | 44 |
| NORIS QUINTERO | 103 | 2 | 2 | 69 |
| ELISETH CASTRO | 53 | 2 | 1 | 35 |
| Enrique Aizprua | 40 | 1 | 1 | 40 |
| GUILLERMO MORALES | 19 | 1 | 1 | 19 |

### Baja confianza por docente

| Docente | Registros | Fechas | Grupos | Estudiantes |
|---|---:|---:|---:|---:|
| Jessica Singh | 633 | 3 | 6 | 210 |
| DORIS CABALLERO | 216 | 3 | 2 | 63 |
| HAZAEL CERRUD | 211 | 4 | 5 | 77 |
| YULISSA MAIDETH LÓPEZ FERNÁNDEZ | 186 | 4 | 3 | 54 |
| LUIS MORALES | 170 | 2 | 2 | 68 |
| Julio J. Magallón L. | 113 | 3 | 2 | 37 |
| GERTRUDIS KIRTON WINTER | 68 | 1 | 1 | 34 |
| Nayi Stephany Campbell Ortiz | 68 | 1 | 2 | 68 |
| Fabio Alexander Ortíz Yee | 64 | 2 | 2 | 32 |
| NORIS QUINTERO | 28 | 1 | 1 | 28 |

---

## 8. Cruce con actividades 2T

Actividades `2T` relacionadas en el rango por docente/materia:

| Docente | Materia | Actividades | Grupos | Grados |
|---|---|---:|---:|---:|
| NORIS QUINTERO | EDUCACIÓN ARTISTICAS | 46 | 8 | 2 |
| MARIA ELENA LLORENTE ORTEGA | ARTES INDUSTRIALES | 31 | 8 | 2 |
| Ronaldo Barría Trujillo | HISTORIA | 29 | 8 | 2 |
| GERTRUDIS KIRTON WINTER | GEOGRAFÍA | 28 | 8 | 1 |
| GERTRUDIS KIRTON WINTER | CÍVICA | 24 | 4 | 1 |
| Enrique Aizprua | RELIGIÓN, MORAL Y VALORES | 24 | 7 | 1 |
| Fabio Alexander Ortíz Yee | HISTORIA | 22 | 4 | 1 |
| GLADYS DIAZ DE ZAMBRANO | CIENCIAS NATURALES | 17 | 3 | 1 |
| TAYNA SALAZAR | NOCIONES DE COMERCIO | 15 | 8 | 1 |
| Ronaldo Barría Trujillo | CÍVICA | 13 | 5 | 2 |
| Fabio Alexander Ortíz Yee | CÍVICA | 13 | 6 | 1 |
| ELISETH CASTRO | QUÍMICA | 12 | 4 | 2 |
| TAYNA SALAZAR | CONTABILIDAD | 12 | 6 | 1 |
| JACQUELINE MARTINEZ | MATEMÁTICAS | 12 | 6 | 1 |
| GUILLERMO MORALES | GESTIÓN EMPRESARIAL | 10 | 1 | 1 |
| GUILLERMO MORALES | TALLER III (COMUNICACIONES) | 10 | 1 | 1 |

Observación:

Esta tabla evidencia actividad académica `2T` real dentro del rango, pero no prueba por sí sola la relación estudiante por estudiante. Por eso la alta confianza exige además cruce con notas del estudiante.

---

## 9. Cruce con notas 2T

Notas `2T` existentes en el rango por docente/materia:

| Docente | Materia | Notas | Estudiantes | Grupos |
|---|---|---:|---:|---:|
| MARIA ELENA LLORENTE ORTEGA | ARTES INDUSTRIALES | 548 | 443 | 8 |
| Ronaldo Barría Trujillo | HISTORIA | 536 | 268 | 7 |
| NORIS QUINTERO | EDUCACIÓN ARTISTICAS | 425 | 129 | 4 |
| GERTRUDIS KIRTON WINTER | CÍVICA | 420 | 140 | 4 |
| Fabio Alexander Ortíz Yee | HISTORIA | 386 | 140 | 4 |
| GLADYS DIAZ DE ZAMBRANO | CIENCIAS NATURALES | 345 | 115 | 3 |
| Enrique Aizprua | RELIGIÓN, MORAL Y VALORES | 342 | 190 | 5 |
| GERTRUDIS KIRTON WINTER | GEOGRAFÍA | 278 | 139 | 4 |
| Ronaldo Barría Trujillo | CÍVICA | 218 | 218 | 5 |
| JACQUELINE MARTINEZ | MATEMÁTICAS | 211 | 210 | 6 |
| Fabio Alexander Ortíz Yee | CÍVICA | 178 | 178 | 6 |
| TAYNA SALAZAR | NOCIONES DE COMERCIO | 148 | 148 | 5 |
| TAYNA SALAZAR | CONTABILIDAD | 138 | 69 | 2 |
| GUILLERMO MORALES | GESTIÓN EMPRESARIAL | 90 | 18 | 1 |
| GUILLERMO MORALES | TALLER III (COMUNICACIONES) | 90 | 18 | 1 |

Observación:

La presencia de notas `2T` del mismo estudiante en el mismo contexto académico es la evidencia más fuerte para reclasificación.

---

## 10. Materias asociadas en alta confianza

Materia derivada desde las notas `2T` asociadas:

| Materia | Asistencias alta confianza | Filas con materia ambigua |
|---|---:|---:|
| CÍVICA | 941 | 346 |
| CIENCIAS NATURALES | 753 | 0 |
| ARTES INDUSTRIALES | 590 | 0 |
| MATEMÁTICAS | 502 | 0 |
| HISTORIA | 322 | 0 |
| EDUCACIÓN ARTISTICAS | 137 | 0 |
| GEOGRAFÍA DE PANAMÁ | 114 | 0 |
| GEOGRAFÍA | 100 | 0 |
| HISTORIA DE PANAMÁ | 78 | 0 |
| RELIGIÓN, MORAL Y VALORES | 76 | 0 |
| QUÍMICA | 56 | 0 |
| GESTIÓN EMPRESARIAL | 54 | 54 |
| ÉTICA, MORAL Y VALORES | 19 | 0 |
| LÓGICA / FILOSOFÍA | 19 | 0 |
| ESPAÑOL | 3 | 0 |

Nota:

Incluso dentro de alta confianza, algunas filas pueden tener más de una materia relacionada por el mismo estudiante/contexto. Esto no impide asignar `trimester_id=2T`, pero sí aconseja no usar este análisis para backfill automático de `subject_id` sin una regla adicional.

---

## 11. Listas exactas de candidatos

Por volumen, no se pegan 6,426 UUIDs en el Markdown. Las listas exactas y reproducibles son las siguientes consultas `SELECT`. Devuelven cada `attendance.id` que sería afectado por cada categoría.

### 11.1 Candidatos Alta Confianza

```sql
WITH target AS (
    SELECT a.*
    FROM attendance a
    WHERE a.date BETWEEN DATE '2026-06-15' AND DATE '2026-06-19'
),
classified AS (
    SELECT
        t.*,
        EXISTS (
            SELECT 1
            FROM activities act
            WHERE act.trimester = '2T'
              AND act.teacher_id = t.teacher_id
              AND act.group_id = t.group_id
              AND act.grade_level_id = t.grade_id
              AND (
                    act.created_at::date BETWEEN DATE '2026-06-15' AND DATE '2026-06-19'
                 OR act.due_date::date BETWEEN DATE '2026-06-15' AND DATE '2026-06-19'
              )
        ) AS has_related_2t_activity,
        EXISTS (
            SELECT 1
            FROM student_activity_scores sc
            JOIN activities act ON act.id = sc.activity_id
            WHERE sc.student_id = t.student_id
              AND act.trimester = '2T'
              AND act.teacher_id = t.teacher_id
              AND act.group_id = t.group_id
              AND act.grade_level_id = t.grade_id
              AND sc.created_at::date BETWEEN DATE '2026-06-15' AND DATE '2026-06-19'
        ) AS has_related_2t_score
    FROM target t
)
SELECT
    id AS attendance_id,
    date,
    student_id,
    teacher_id,
    group_id,
    grade_id,
    status
FROM classified
WHERE has_related_2t_activity = true
  AND has_related_2t_score = true
ORDER BY date, teacher_id, group_id, grade_id, student_id, id;
```

Resultado esperado:

```text
3,761 registros
```

### 11.2 Candidatos Media Confianza

```sql
WITH target AS (
    SELECT a.*
    FROM attendance a
    WHERE a.date BETWEEN DATE '2026-06-15' AND DATE '2026-06-19'
),
classified AS (
    SELECT
        t.*,
        EXISTS (
            SELECT 1
            FROM activities act
            WHERE act.trimester = '2T'
              AND act.teacher_id = t.teacher_id
              AND act.group_id = t.group_id
              AND act.grade_level_id = t.grade_id
              AND (
                    act.created_at::date BETWEEN DATE '2026-06-15' AND DATE '2026-06-19'
                 OR act.due_date::date BETWEEN DATE '2026-06-15' AND DATE '2026-06-19'
              )
        ) AS has_related_2t_activity,
        EXISTS (
            SELECT 1
            FROM student_activity_scores sc
            JOIN activities act ON act.id = sc.activity_id
            WHERE sc.student_id = t.student_id
              AND act.trimester = '2T'
              AND act.teacher_id = t.teacher_id
              AND act.group_id = t.group_id
              AND act.grade_level_id = t.grade_id
              AND sc.created_at::date BETWEEN DATE '2026-06-15' AND DATE '2026-06-19'
        ) AS has_related_2t_score
    FROM target t
)
SELECT
    id AS attendance_id,
    date,
    student_id,
    teacher_id,
    group_id,
    grade_id,
    status
FROM classified
WHERE has_related_2t_activity = true
  AND has_related_2t_score = false
ORDER BY date, teacher_id, group_id, grade_id, student_id, id;
```

Resultado esperado:

```text
908 registros
```

### 11.3 Candidatos Baja Confianza

```sql
WITH target AS (
    SELECT a.*
    FROM attendance a
    WHERE a.date BETWEEN DATE '2026-06-15' AND DATE '2026-06-19'
),
classified AS (
    SELECT
        t.*,
        EXISTS (
            SELECT 1
            FROM activities act
            WHERE act.trimester = '2T'
              AND act.teacher_id = t.teacher_id
              AND act.group_id = t.group_id
              AND act.grade_level_id = t.grade_id
              AND (
                    act.created_at::date BETWEEN DATE '2026-06-15' AND DATE '2026-06-19'
                 OR act.due_date::date BETWEEN DATE '2026-06-15' AND DATE '2026-06-19'
              )
        ) AS has_related_2t_activity
    FROM target t
)
SELECT
    id AS attendance_id,
    date,
    student_id,
    teacher_id,
    group_id,
    grade_id,
    status
FROM classified
WHERE has_related_2t_activity = false
ORDER BY date, teacher_id, group_id, grade_id, student_id, id;
```

Resultado esperado:

```text
1,757 registros
```

---

## 12. Recomendación

### ¿Puede hacerse un backfill seguro para Alta Confianza?

**Sí, con alcance limitado y después de aprobación.**

Los **3,761 registros de Alta Confianza** tienen evidencia fuerte de operación `2T` porque:

- están dentro del rango candidato `2026-06-15` a `2026-06-19`;
- existe actividad `2T` relacionada por docente/grupo/grado;
- existe nota `2T` del mismo estudiante dentro del mismo contexto académico;
- el rango ya había sido identificado como semana operativa `2T` en el análisis previo.

### Qué backfill sería razonable en una fase futura

Solo después de migración aprobada y backup:

```text
attendance.academic_year_id = 2026
attendance.trimester_id = 2T
```

Para:

```text
Alta Confianza: 3,761 registros
```

### Qué NO debe hacerse todavía

No aplicar backfill automático a:

- Media Confianza (`908`) sin revisión adicional.
- Baja Confianza (`1,757`) sin evidencia académica adicional.
- `subject_id`, incluso en alta confianza, porque algunas filas tienen más de una materia relacionada.
- Fechas `2026-06-08` a `2026-06-12`.
- Fechas posteriores al `2026-06-19`.

### Recomendación final

```text
Backfill 2T para Alta Confianza: viable y relativamente seguro, pero pendiente de aprobación.
Backfill 2T para Media Confianza: posible, pero requiere validación docente/institucional adicional.
Backfill 2T para Baja Confianza: no recomendado con la evidencia actual.
```

---

## 13. Plan seguro si se aprueba

No ejecutar todavía.

1. Realizar backup completo de producción.
2. Crear migración aprobada para `academic_year_id` y `trimester_id` nullable.
3. Ejecutar primero consulta `SELECT` de Alta Confianza y guardar evidencia.
4. Aplicar backfill solo a esos `attendance.id`.
5. Recontar:

```sql
SELECT COUNT(*)
FROM attendance
WHERE date BETWEEN DATE '2026-06-15' AND DATE '2026-06-19'
  AND trimester_id = '<2T_ID>';
```

6. No tocar media/baja hasta revisión.

---

## 14. Confirmación de alcance

Este documento:

- No ejecutó `UPDATE`.
- No creó scripts de modificación.
- No creó migraciones.
- No modificó datos.
- No modificó código.
- Solo identifica candidatos y proporciona consultas `SELECT` para reproducir las listas exactas.

