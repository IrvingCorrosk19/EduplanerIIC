# Análisis de reclasificación de asistencias a 2T desde 2026-06-08

**Proyecto:** `C:\Proyectos\EduplanerIIC\SchoolManager`  
**Documento base:** `PLAN_CORRECCION_MODULO_ASISTENCIA.md`  
**Base de datos:** Render Producción  
**Alcance:** Solo análisis. No se aplicó backfill, no se modificó `attendance`, no se modificó `trimester`, no se modificó código, no se crearon migraciones.

---

## 1. Pregunta ejecutiva

¿Es correcto asumir que toda asistencia con fecha mayor o igual a `2026-06-08` pertenece al Segundo Trimestre (`2T`)?

**Respuesta:** **No de forma global. Solo parcialmente.**

La evidencia indica:

- `2026-06-08` a `2026-06-12`: período formalmente dentro de `1T`, con operación académica mixta (`1T` y `2T` coexistiendo en actividades/notas).
- `2026-06-15` a `2026-06-19`: período fuera del calendario trimestral formal, pero con fuerte evidencia operativa de `2T`.
- `2026-06-20` a `2026-06-22`: no hay asistencia, aunque sí hay actividades/notas `2T`.
- `2026-06-23`: inicio formal configurado de `2T`, pero no hay asistencia ese día en producción.

Recomendación principal:

```text
No asumir todo desde 2026-06-08 como 2T.
Evaluar reclasificación solo para 2026-06-15 a 2026-06-19, y únicamente con aprobación institucional.
```

---

## 2. Calendario formal configurado

Consulta ejecutada:

```sql
SELECT
    id,
    school_id,
    name,
    start_date::date AS start_date,
    end_date::date AS end_date,
    is_active,
    created_at
FROM trimester
ORDER BY start_date;
```

Resultado:

| Trimestre | Inicio | Fin | Activo | Creado |
|---|---:|---:|---:|---:|
| `1T` | 2026-03-01 | 2026-06-12 | false | 2026-03-25 |
| `2T` | 2026-06-23 | 2026-09-12 | true | 2026-03-25 |
| `3T` | 2026-09-22 | 2026-12-19 | true | 2026-03-25 |

Año académico:

| Año | Inicio | Fin | Activo |
|---|---:|---:|---:|
| 2026 | 2026-01-01 | 2026-12-31 | true |

Conclusión:

El sistema formalmente considera:

```text
1T: hasta 2026-06-12
2T: desde 2026-06-23
```

No existe en la configuración formal una fecha `2026-06-08` como inicio de `2T`.

---

## 3. Evidencia documental / configuración

Búsqueda en el repositorio:

```text
2026-06-08
2026/06/08
06-08
08-06
8 de junio
8 junio
junio 8
06/08/2026
08/06/2026
```

Resultado relevante:

- No se encontró documentación académica que declare `2026-06-08` como inicio de `2T`.
- Solo apareció una fecha en un documento no relacionado al calendario de asistencia: `Docs/ANALISIS_CARNET_INSTITUCIONAL_UI.md`.

Conclusión:

No hay evidencia documental interna suficiente para afirmar que `2T` inició oficialmente el `2026-06-08`.

---

## 4. Asistencia por fecha del 2026-06-08 al 2026-06-23

Consulta:

```sql
SELECT
    a.date,
    COUNT(*) AS total,
    COUNT(DISTINCT teacher_id) AS teachers,
    COUNT(DISTINCT group_id) AS groups,
    COUNT(DISTINCT grade_id) AS grades,
    COUNT(DISTINCT student_id) AS students,
    COUNT(*) FILTER (WHERE status='present') AS present,
    COUNT(*) FILTER (WHERE status='absent') AS absent,
    COUNT(*) FILTER (WHERE status='late') AS late,
    COUNT(*) FILTER (WHERE status='fuga') AS fuga,
    COUNT(*) FILTER (WHERE status='excusa') AS excusa
FROM attendance a
WHERE a.date BETWEEN DATE '2026-06-08' AND DATE '2026-06-23'
GROUP BY a.date
ORDER BY a.date;
```

Resultado:

| Fecha | Total | Docentes | Grupos | Grados | Estudiantes | Presentes | Ausentes | Tardanzas | Fugas | Excusas |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 2026-06-08 | 1,147 | 13 | 19 | 6 | 774 | 715 | 398 | 26 | 5 | 3 |
| 2026-06-09 | 1,938 | 18 | 23 | 6 | 1,045 | 1,524 | 363 | 12 | 37 | 2 |
| 2026-06-10 | 2,114 | 17 | 23 | 6 | 1,058 | 1,639 | 397 | 40 | 27 | 11 |
| 2026-06-11 | 1,544 | 13 | 19 | 5 | 870 | 1,192 | 310 | 7 | 27 | 8 |
| 2026-06-12 | 1,468 | 15 | 17 | 6 | 722 | 1,015 | 410 | 18 | 24 | 1 |
| 2026-06-15 | 1,636 | 15 | 18 | 6 | 873 | 1,199 | 383 | 31 | 23 | 0 |
| 2026-06-16 | 1,098 | 11 | 16 | 6 | 664 | 659 | 287 | 33 | 43 | 76 |
| 2026-06-17 | 401 | 6 | 7 | 5 | 309 | 295 | 97 | 6 | 3 | 0 |
| 2026-06-18 | 1,580 | 15 | 20 | 6 | 815 | 1,131 | 376 | 31 | 39 | 3 |
| 2026-06-19 | 1,711 | 18 | 22 | 6 | 997 | 1,169 | 473 | 40 | 27 | 2 |

No hay asistencia del `2026-06-20` al `2026-06-23`.

Interpretación:

- Del 8 al 12 hay operación escolar normal, pero esa semana todavía está dentro del `1T` formal.
- Del 15 al 19 también hay operación escolar normal, pero está fuera de todo trimestre configurado.
- La asistencia por sí sola demuestra actividad escolar, pero no demuestra por sí sola que sea `2T`.

---

## 5. Asistencia por ventanas

Consulta:

```sql
WITH windows AS (
    SELECT 'A_1T_formal_2026-06-08_to_06-12' AS window,
           DATE '2026-06-08' AS start_date,
           DATE '2026-06-12' AS end_date
    UNION ALL
    SELECT 'B_gap_2026-06-15_to_06-19',
           DATE '2026-06-15',
           DATE '2026-06-19'
    UNION ALL
    SELECT 'C_pre_2T_2026-06-20_to_06-22',
           DATE '2026-06-20',
           DATE '2026-06-22'
    UNION ALL
    SELECT 'D_2T_formal_2026-06-23',
           DATE '2026-06-23',
           DATE '2026-06-23'
)
SELECT
    w.window,
    COUNT(a.*) AS attendance_rows,
    COUNT(DISTINCT a.teacher_id) AS teachers,
    COUNT(DISTINCT a.group_id) AS groups,
    COUNT(DISTINCT a.student_id) AS students
FROM windows w
LEFT JOIN attendance a
    ON a.date BETWEEN w.start_date AND w.end_date
GROUP BY w.window
ORDER BY w.window;
```

Resultado:

| Ventana | Asistencias | Docentes | Grupos | Estudiantes |
|---|---:|---:|---:|---:|
| `2026-06-08` a `2026-06-12` | 8,211 | 19 | 25 | 1,535 |
| `2026-06-15` a `2026-06-19` | 6,426 | 19 | 24 | 1,362 |
| `2026-06-20` a `2026-06-22` | 0 | 0 | 0 | 0 |
| `2026-06-23` | 0 | 0 | 0 | 0 |

Impacto potencial:

- Si se toma todo desde `2026-06-08` como `2T`, se moverían conceptualmente **14,637 asistencias** del tramo 8–19 de junio hacia `2T`.
- De esas, **8,211** pertenecen a fechas formalmente `1T`.
- Las **6,426** del 15–19 son las que hoy están fuera de trimestre.

---

## 6. Materias posibles en asistencia

Como `attendance` no tiene `subject_id`, solo se puede inferir materia desde asignaciones. Consulta usada:

```sql
WITH possible AS (
    SELECT
        a.id,
        a.date,
        COUNT(DISTINCT sa.subject_id) AS possible_subjects
    FROM attendance a
    LEFT JOIN teacher_assignments ta
        ON ta.teacher_id = a.teacher_id
    LEFT JOIN subject_assignments sa
        ON sa.id = ta.subject_assignment_id
       AND sa.group_id = a.group_id
       AND sa.grade_level_id = a.grade_id
    WHERE a.date BETWEEN DATE '2026-06-08' AND DATE '2026-06-23'
    GROUP BY a.id, a.date
)
SELECT
    date,
    possible_subjects,
    COUNT(*) AS attendance_rows
FROM possible
GROUP BY date, possible_subjects
ORDER BY date, possible_subjects;
```

Resultado resumido:

| Fecha | 1 materia posible | 2 materias posibles | 4 materias posibles |
|---|---:|---:|---:|
| 2026-06-08 | 1,001 | 146 | 0 |
| 2026-06-09 | 1,680 | 258 | 0 |
| 2026-06-10 | 1,868 | 246 | 0 |
| 2026-06-11 | 1,476 | 68 | 0 |
| 2026-06-12 | 1,384 | 66 | 18 |
| 2026-06-15 | 1,458 | 160 | 18 |
| 2026-06-16 | 954 | 144 | 0 |
| 2026-06-17 | 363 | 38 | 0 |
| 2026-06-18 | 1,438 | 124 | 18 |
| 2026-06-19 | 1,627 | 66 | 18 |

Conclusión:

La mayoría de las asistencias puede inferir una sola materia posible, pero una parte relevante sigue siendo ambigua. Esto refuerza que un backfill de `subject_id` no debe hacerse de manera global sin reglas conservadoras.

---

## 7. Actividades académicas 1T/2T en el período

### Actividades creadas por fecha y trimestre

Consulta:

```sql
SELECT
    created_at::date AS created_date,
    COALESCE(trimester,'(null)') AS trimester,
    COUNT(*) AS activities,
    COUNT(DISTINCT teacher_id) AS teachers,
    COUNT(DISTINCT subject_id) AS subjects,
    COUNT(DISTINCT group_id) AS groups
FROM activities
WHERE created_at::date BETWEEN DATE '2026-06-08' AND DATE '2026-06-23'
GROUP BY created_date, COALESCE(trimester,'(null)')
ORDER BY created_date, trimester;
```

Resultado:

| Fecha creación | Trimestre actividad | Actividades | Docentes | Materias | Grupos |
|---|---|---:|---:|---:|---:|
| 2026-06-08 | 1T | 73 | 4 | 5 | 4 |
| 2026-06-09 | 1T | 3 | 1 | 1 | 1 |
| 2026-06-09 | 2T | 17 | 3 | 3 | 6 |
| 2026-06-10 | 1T | 64 | 1 | 1 | 3 |
| 2026-06-10 | 2T | 28 | 6 | 5 | 8 |
| 2026-06-11 | 2T | 25 | 6 | 7 | 6 |
| 2026-06-12 | 2T | 5 | 2 | 2 | 2 |
| 2026-06-13 | 2T | 2 | 1 | 1 | 2 |
| 2026-06-14 | 2T | 16 | 2 | 3 | 3 |
| 2026-06-15 | 2T | 24 | 6 | 8 | 10 |
| 2026-06-16 | 2T | 74 | 10 | 9 | 14 |
| 2026-06-17 | 2T | 43 | 6 | 10 | 8 |
| 2026-06-18 | 2T | 76 | 7 | 8 | 17 |
| 2026-06-19 | 2T | 134 | 13 | 16 | 19 |
| 2026-06-20 | 2T | 6 | 1 | 2 | 2 |
| 2026-06-21 | 2T | 28 | 3 | 4 | 11 |

### Actividades por ventana

| Ventana | Trimestre | Actividades creadas | Docentes | Materias |
|---|---|---:|---:|---:|
| 2026-06-08 a 2026-06-12 | 1T | 140 | 6 | 7 |
| 2026-06-08 a 2026-06-12 | 2T | 75 | 9 | 10 |
| 2026-06-15 a 2026-06-19 | 2T | 351 | 18 | 22 |
| 2026-06-20 a 2026-06-22 | 2T | 34 | 3 | 5 |
| 2026-06-23 | sin actividades | 0 | 0 | 0 |

Interpretación:

- Del 8 al 12 hay mezcla real: actividades `1T` y `2T`.
- Del 15 al 19, todas las actividades creadas en el rango son `2T`.
- Hay actividades `2T` incluso antes del 8: el primer lote observado fue creado el `2026-06-07`.

---

## 8. Actividades con fecha de entrega 2T en el período

Consulta:

```sql
SELECT
    due_date::date AS due_date,
    COALESCE(trimester,'(null)') AS trimester,
    COUNT(*) AS activities,
    COUNT(DISTINCT teacher_id) AS teachers,
    COUNT(DISTINCT subject_id) AS subjects,
    COUNT(DISTINCT group_id) AS groups
FROM activities
WHERE due_date::date BETWEEN DATE '2026-06-08' AND DATE '2026-06-23'
GROUP BY due_date::date, COALESCE(trimester,'(null)')
ORDER BY due_date, trimester;
```

Resultado relevante:

| Fecha entrega | 1T | 2T |
|---|---:|---:|
| 2026-06-08 | 1 | 1 |
| 2026-06-09 | 4 | 15 |
| 2026-06-10 | 1 | 19 |
| 2026-06-11 | 2 | 10 |
| 2026-06-12 | 4 | 7 |
| 2026-06-15 | 0 | 30 |
| 2026-06-16 | 0 | 43 |
| 2026-06-17 | 0 | 18 |
| 2026-06-18 | 0 | 43 |
| 2026-06-19 | 0 | 50 |
| 2026-06-22 | 0 | 7 |
| 2026-06-23 | 0 | 6 |

Interpretación:

- Desde el 8 hay al menos una actividad `2T` con entrega ese día.
- Del 15 al 23 todas las actividades con entrega en ese rango son `2T`.

---

## 9. Notas (`StudentActivityScores`) asociadas a actividades 1T/2T

Consulta:

```sql
SELECT
    s.created_at::date AS score_created_date,
    COALESCE(a.trimester,'(activity null)') AS activity_trimester,
    COUNT(*) AS scores,
    COUNT(DISTINCT s.student_id) AS students,
    COUNT(DISTINCT a.teacher_id) AS teachers,
    COUNT(DISTINCT a.subject_id) AS subjects,
    COUNT(DISTINCT a.group_id) AS groups
FROM student_activity_scores s
JOIN activities a ON a.id = s.activity_id
WHERE s.created_at::date BETWEEN DATE '2026-06-08' AND DATE '2026-06-23'
GROUP BY s.created_at::date, COALESCE(a.trimester,'(activity null)')
ORDER BY score_created_date, activity_trimester;
```

Resultado:

| Fecha nota | Trimestre actividad | Notas | Estudiantes | Docentes | Materias | Grupos |
|---|---|---:|---:|---:|---:|---:|
| 2026-06-08 | 1T | 516 | 90 | 6 | 7 | 5 |
| 2026-06-09 | 1T | 88 | 40 | 3 | 3 | 3 |
| 2026-06-09 | 2T | 238 | 168 | 3 | 3 | 5 |
| 2026-06-10 | 1T | 1,216 | 114 | 1 | 1 | 3 |
| 2026-06-10 | 2T | 444 | 237 | 4 | 3 | 6 |
| 2026-06-11 | 2T | 194 | 128 | 4 | 4 | 3 |
| 2026-06-12 | 2T | 68 | 34 | 1 | 1 | 1 |
| 2026-06-14 | 2T | 202 | 106 | 2 | 3 | 3 |
| 2026-06-15 | 2T | 344 | 233 | 6 | 6 | 8 |
| 2026-06-16 | 2T | 1,200 | 635 | 7 | 7 | 11 |
| 2026-06-17 | 2T | 378 | 193 | 4 | 6 | 7 |
| 2026-06-18 | 2T | 1,178 | 580 | 8 | 9 | 14 |
| 2026-06-19 | 2T | 1,823 | 702 | 11 | 14 | 17 |
| 2026-06-20 | 2T | 97 | 58 | 1 | 2 | 2 |
| 2026-06-21 | 2T | 468 | 427 | 3 | 4 | 10 |

Por ventana:

| Ventana | Trimestre actividad | Notas | Estudiantes | Docentes | Materias |
|---|---|---:|---:|---:|---:|
| 2026-06-08 a 2026-06-12 | 1T | 1,820 | 243 | 10 | 9 |
| 2026-06-08 a 2026-06-12 | 2T | 944 | 426 | 6 | 5 |
| 2026-06-15 a 2026-06-19 | 2T | 4,923 | 1,364 | 15 | 19 |
| 2026-06-20 a 2026-06-22 | 2T | 565 | 485 | 3 | 5 |
| 2026-06-23 | sin notas | 0 | 0 | 0 | 0 |

Interpretación:

- El 8 de junio no hay notas `2T`; las notas de ese día son `1T`.
- Desde el 9 de junio ya hay notas `2T`.
- Entre el 15 y 19, toda la evidencia de notas del rango apunta a `2T`.

---

## 10. Primera evidencia 2T

Consultas:

```sql
SELECT
    MIN(created_at::date) FILTER (WHERE trimester='2T') AS first_2t_activity_created,
    MIN(due_date::date) FILTER (WHERE trimester='2T') AS first_2t_activity_due
FROM activities;

SELECT MIN(s.created_at::date) AS first_2t_score_created
FROM student_activity_scores s
JOIN activities a ON a.id = s.activity_id
WHERE a.trimester='2T';
```

Resultado:

| Señal | Primera fecha |
|---|---:|
| Primera actividad creada como `2T` | 2026-06-07 |
| Primera nota asociada a actividad `2T` | 2026-06-09 |

Nota: se detectó al menos una actividad con `due_date` anómalo año `0026`; no se usa como evidencia para la recomendación.

---

## 11. Evaluación de escenarios

### Escenario A — Mantener fechas actuales

```text
1T: hasta 2026-06-12
2T: desde 2026-06-23
```

Resultado:

- Las asistencias del 8 al 12 quedan en `1T`.
- Las asistencias del 15 al 19 quedan intertrimestre.
- No se altera el calendario formal.
- Se preserva la configuración actual.

Ventajas:

- Menor riesgo.
- No reinterpreta datos históricos.
- No afecta reportes 1T existentes.

Desventajas:

- Los 6,426 registros del 15 al 19 siguen sin trimestre.
- Los reportes de asistencia 2T no incluirían una semana con actividad escolar y evidencia académica `2T`.

Evaluación:

Seguro, pero incompleto.

---

### Escenario B — Cambiar inicio real de 2T a 2026-06-08

Resultado:

- Toda asistencia desde el 8 al 12 pasaría de estar formalmente en `1T` a ser `2T`.
- 8,211 registros de asistencia cambiarían de interpretación.
- El calendario formal quedaría alineado con parte de la actividad académica 2T temprana, pero rompería la evidencia 1T aún existente del 8 al 12.

Riesgos:

- Mezcla cierre de 1T con inicio de 2T.
- El 8 de junio tiene notas `1T` y actividades `1T`.
- Del 8 al 12 hay 1,820 notas `1T` y 140 actividades `1T` creadas.
- Podría alterar reportes de 1T.
- Puede afectar StudentReport si calcula asistencia por rango de trimestre.

Evaluación:

No recomendado sin decisión institucional explícita.

---

### Escenario C — Mantener trimestre configurado, pero backfill histórico de `attendance.trimester_id` desde 2026-06-08

Resultado:

- `attendance` diría `2T` desde 2026-06-08.
- `trimester.start_date` seguiría indicando `2026-06-23`.

Riesgos:

- Inconsistencia semántica fuerte: el registro apunta a un trimestre cuya fecha formal no contiene la asistencia.
- Los reportes basados en `trimester_id` y los basados en fechas darían resultados distintos.
- Difícil de explicar y auditar.

Evaluación:

No recomendado.

---

### Escenario D — Regla especial: “Para asistencia, 2T inicia 2026-06-08; para calendario formal inicia 2026-06-23”

Resultado:

- Asistencia y calendario académico usarían reglas distintas.

Riesgos:

- Alto riesgo de confusión en reportes.
- TeacherGradebook, StudentReport y boletines podrían no coincidir.
- Requiere documentar reglas especiales permanentes.
- Aumenta deuda técnica.

Evaluación:

Peligroso y confuso. No recomendado como regla permanente.

---

## 12. Análisis de riesgo solicitado

### 1. ¿Qué pasa si marcamos como 2T registros desde 2026-06-08?

Se reclasifican conceptualmente 14,637 asistencias del 8 al 19 de junio como `2T`.

Problema: 8,211 de esas asistencias caen dentro del rango formal de `1T` y conviven con actividad académica `1T`.

### 2. ¿Afecta reportes de 1T?

Sí. Si se cambia el inicio de 2T a 2026-06-08, el rango 8–12 deja de contar como 1T para asistencia, aunque formalmente hoy pertenece a 1T.

### 3. ¿Afecta reportes de 2T?

Sí. Aumentaría asistencia 2T con:

- 8,211 registros del 8–12.
- 6,426 registros del 15–19.

Esto puede ser correcto solo si la institución confirma esa regla.

### 4. ¿Afecta asistencia anual?

No en conteo anual total. Todos los registros están dentro del año académico 2026. Solo cambia la distribución trimestral.

### 5. ¿Afecta TeacherGradebook?

Potencialmente sí. TeacherGradebook usa actividades/notas por trimestre textual (`1T`, `2T`) y asistencia por fecha/rango. Si asistencia se clasifica distinto a actividades, puede haber diferencias entre pestañas.

### 6. ¿Afecta boletines?

Sí, si el boletín muestra asistencia por trimestre. La asistencia de 8–12 cambiaría de 1T a 2T.

### 7. ¿Afecta StudentReport?

Sí. `StudentReportService` calcula asistencia por trimestre usando fechas `trimester.start_date/end_date`. Si se cambia calendario o backfill de asistencia, el reporte podría cambiar.

### 8. ¿Afecta promoción?

No directamente, salvo que la promoción use asistencia trimestral o anual como criterio. El conteo anual no cambia; cambia la distribución por período.

### 9. ¿Hay riesgo de mezclar cierre de 1T con inicio de 2T?

Sí. Es el mayor riesgo del escenario desde 2026-06-08. Hay evidencia de cierre/actividad 1T del 8 al 12 y evidencia de arranque 2T casi simultánea.

---

## 13. Interpretación por rangos

### 2026-06-08 a 2026-06-12

Clasificación recomendada:

```text
Período mixto / cierre 1T con preparación o inicio académico parcial de 2T.
```

Evidencia:

- Está dentro del `1T` formal.
- Hay 8,211 asistencias.
- Hay 140 actividades `1T`.
- Hay 75 actividades `2T`.
- Hay 1,820 notas `1T`.
- Hay 944 notas `2T`.
- El 8 de junio solo tiene notas `1T`, no notas `2T`.

Recomendación:

No reclasificar automáticamente como `2T`.

### 2026-06-15 a 2026-06-19

Clasificación recomendada:

```text
2T operativo o semana de transición con fuerte evidencia 2T.
```

Evidencia:

- Está fuera del calendario trimestral formal.
- Hay 6,426 asistencias.
- Hay 351 actividades creadas, todas `2T`.
- Hay 4,923 notas, todas asociadas a actividades `2T`.
- Hay actividad escolar normal: 19 docentes, 24 grupos, 1,362 estudiantes.

Recomendación:

Puede considerarse candidata a backfill `2T`, pero solo con aprobación institucional.

### 2026-06-20 a 2026-06-22

Clasificación recomendada:

```text
Actividad académica 2T sin asistencia registrada.
```

Evidencia:

- No hay asistencia.
- Hay 34 actividades `2T`.
- Hay 565 notas `2T`.

Recomendación:

No aplica a backfill de asistencia porque no hay registros de asistencia.

### 2026-06-23

Clasificación recomendada:

```text
Inicio formal configurado de 2T.
```

Evidencia:

- `trimester.start_date = 2026-06-23`.
- No hay asistencia ni actividad creada ese día en los datos consultados.

---

## 14. Recomendación final

### ¿Podemos tomar todo desde 2026-06-08 como 2T?

**No.**

### ¿Podemos tomar una parte como 2T?

**Sí, parcialmente.**

El tramo con mejor evidencia para reclasificación a `2T` es:

```text
2026-06-15 a 2026-06-19
```

Pero debe aprobarse institucionalmente porque el calendario formal actual no lo contiene en `2T`.

### Recomendación concreta

1. No cambiar automáticamente `2T` a `2026-06-08`.
2. No reclasificar automáticamente asistencia del `2026-06-08` al `2026-06-12`.
3. Considerar `2026-06-15` al `2026-06-19` como **candidatos a 2T operativo**.
4. Antes de backfill, pedir confirmación institucional:

```text
¿La semana del 15 al 19 de junio debe computarse oficialmente como 2T para asistencia?
```

Si la respuesta institucional es sí, el backfill seguro puede limitarse a esas fechas.

---

## 15. Plan seguro de backfill si aplica

No ejecutar todavía.

### Opción segura recomendada

Backfill limitado:

```text
attendance.date BETWEEN '2026-06-15' AND '2026-06-19'
```

Asignar:

```text
trimester_id = id de 2T
academic_year_id = id de 2026
```

Solo cuando:

- el estudiante/docente pertenece a la escuela del calendario;
- la fecha está dentro del año académico 2026;
- existe decisión institucional documentada.

### No incluir

No incluir automáticamente:

```text
2026-06-08 a 2026-06-12
```

Motivo:

- Sigue dentro de 1T formal.
- Tiene evidencia 1T fuerte.
- Mezcla notas/actividades 1T y 2T.

### Consulta de previsualización recomendada

```sql
SELECT
    a.date,
    COUNT(*) AS attendance_rows,
    COUNT(DISTINCT a.teacher_id) AS teachers,
    COUNT(DISTINCT a.group_id) AS groups,
    COUNT(DISTINCT a.student_id) AS students
FROM attendance a
WHERE a.date BETWEEN DATE '2026-06-15' AND DATE '2026-06-19'
GROUP BY a.date
ORDER BY a.date;
```

### Backfill conceptual, no ejecutado

```sql
-- NO EJECUTAR SIN APROBACIÓN
-- UPDATE attendance
-- SET trimester_id = '<2T_ID>',
--     academic_year_id = '<2026_ID>'
-- WHERE date BETWEEN DATE '2026-06-15' AND DATE '2026-06-19'
--   AND academic_year_id IS NULL
--   AND trimester_id IS NULL;
```

Nota: hoy esas columnas aún no existen según el plan previo. Este backfill solo tendría sentido después de una migración aprobada.

---

## 16. Decisión requerida

Para proceder en una futura fase, se necesita decidir:

1. ¿El 2T institucional inició oficialmente el `2026-06-08`, `2026-06-15` o `2026-06-23`?
2. ¿La semana `2026-06-08` a `2026-06-12` fue cierre de 1T, inicio de 2T o período mixto?
3. ¿La semana `2026-06-15` a `2026-06-19` debe computarse como 2T para asistencia?
4. ¿Se acepta que reportes históricos muestren “período intertrimestre” si no se reclasifica?
5. ¿Debe cambiarse el calendario formal de `trimester`, o solo clasificar asistencia histórica?

---

## 17. Conclusión

La evidencia **no soporta** una regla global:

```text
date >= 2026-06-08 => 2T
```

Sí soporta una hipótesis más limitada:

```text
2026-06-15 a 2026-06-19 probablemente corresponde a 2T operativo o transición 2T.
```

La estrategia más segura es:

```text
Mantener 2026-06-08 a 2026-06-12 como período mixto/no reclasificado.
Solicitar confirmación institucional para 2026-06-15 a 2026-06-19.
Solo si se aprueba, hacer backfill limitado a esa semana después de migración y backup.
```

