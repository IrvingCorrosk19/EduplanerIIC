# Plan de corrección del módulo de asistencia

**Proyecto:** `C:\Proyectos\EduplanerIIC\SchoolManager`  
**Documento base:** `ANALISIS_FUNCIONAL_Y_TECNICO_ASISTENCIA.md`  
**Base de datos:** Render Producción  
**Alcance:** Solo análisis y planificación. No se modificó código, no se modificaron datos, no se crearon migraciones, no hubo commit ni push.

---

## 1. Diagnóstico ejecutivo

El problema principal no es que el módulo no registre asistencia. Sí registra un volumen operativo importante: **32,297 registros** en producción.

El problema es que el modelo actual guarda asistencia con esta granularidad:

```text
student_id + teacher_id + group_id + grade_id + date + status
```

Pero no guarda explícitamente:

```text
subject_id
trimester_id
academic_year_id
school_id
created_by
updated_by
```

El resultado es un módulo funcional para asistencia general por grupo/docente/fecha, pero débil para un modelo académico completo por materia, período y auditoría.

Importante: los hallazgos previos no deben tratarse automáticamente como errores de datos. Hay que separar:

- datos históricamente válidos;
- datos generados bajo reglas antiguas;
- datos ambiguos por falta de columnas;
- datos probablemente duplicados por comportamiento del guardado actual.

---

## 2. FASE 1 — Qué significa “registro fuera de trimestre”

### Consulta exacta usada en el análisis anterior

La lógica previa fue:

```sql
SELECT COUNT(*) AS outside_any_trimester
FROM attendance a
WHERE NOT EXISTS (
    SELECT 1
    FROM trimester t
    WHERE a.date >= t.start_date::date
      AND a.date <= t.end_date::date
);
```

Esta consulta significa:

> Un registro está “fuera de trimestre” si su `attendance.date` no cae dentro de ningún rango `trimester.start_date` / `trimester.end_date`.

### Mejora aplicada para evitar falsos positivos

Como `attendance.school_id` está vacío en producción, la clasificación correcta debe inferir escuela desde estudiante/docente:

```sql
WITH a AS (
    SELECT
        att.*,
        COALESCE(stu.school_id, tea.school_id) AS inferred_school_id
    FROM attendance att
    LEFT JOIN users stu ON stu.id = att.student_id
    LEFT JOIN users tea ON tea.id = att.teacher_id
),
classified AS (
    SELECT
        a.id,
        a.date,
        a.created_at,
        a.inferred_school_id,
        EXISTS (
            SELECT 1
            FROM trimester t
            WHERE t.school_id = a.inferred_school_id
              AND a.date BETWEEN t.start_date::date AND t.end_date::date
        ) AS in_school_trimester,
        EXISTS (
            SELECT 1
            FROM academic_years y
            WHERE y.school_id = a.inferred_school_id
              AND a.date BETWEEN y.start_date::date AND y.end_date::date
        ) AS in_school_academic_year
    FROM a
)
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE NOT in_school_trimester) AS outside_school_trimester,
    COUNT(*) FILTER (WHERE in_school_academic_year) AS in_school_academic_year,
    COUNT(*) FILTER (WHERE NOT in_school_academic_year) AS outside_school_academic_year
FROM classified;
```

### Evidencia de configuración de calendario

Trimestres configurados:

| Trimestre | Inicio | Fin | Activo | Creado |
|---|---:|---:|---:|---:|
| 1T | 2026-03-01 | 2026-06-12 | No | 2026-03-25 |
| 2T | 2026-06-23 | 2026-09-12 | Sí | 2026-03-25 |
| 3T | 2026-09-22 | 2026-12-19 | Sí | 2026-03-25 |

Año académico:

| Año | Inicio | Fin | Activo |
|---|---:|---:|---:|
| 2026 | 2026-01-01 | 2026-12-31 | Sí |

Resultado:

| Métrica | Valor |
|---|---:|
| Total asistencias | 32,297 |
| Fuera de trimestre de su escuela | 6,426 |
| Dentro del año académico de su escuela | 32,297 |
| Fuera del año académico de su escuela | 0 |

### Interpretación correcta

Los 6,426 registros **no están fuera del año académico**. Están dentro de 2026, pero caen en el hueco entre el fin de 1T y el inicio de 2T:

```text
1T termina: 2026-06-12
2T inicia: 2026-06-23
Registros fuera de trimestre: 2026-06-15 a 2026-06-19
```

Distribución exacta:

| Fecha | Registros | Docentes | Grupos | Estudiantes |
|---|---:|---:|---:|---:|
| 2026-06-15 | 1,636 | 15 | 18 | 873 |
| 2026-06-16 | 1,098 | 11 | 16 | 664 |
| 2026-06-17 | 401 | 6 | 7 | 309 |
| 2026-06-18 | 1,580 | 15 | 20 | 815 |
| 2026-06-19 | 1,711 | 18 | 22 | 997 |

### Conclusión de FASE 1

“Fuera de trimestre” significa **fuera del calendario trimestral configurado**, no necesariamente dato inválido.

En este caso específico, la evidencia apunta a una **brecha de calendario académico** entre 1T y 2T. Es posible que sean clases, recuperaciones, cierres, evaluaciones, transición de trimestre o asistencia tomada durante días válidos institucionalmente no cubiertos por `trimester`.

No deben corregirse ni eliminarse automáticamente.

---

## 3. FASE 2 — Validación de los 6,426 registros

### Clasificación propuesta

| Clasificación | Cantidad | Evidencia | Decisión |
|---|---:|---|---|
| Dentro de año académico 2026 | 6,426 | Todos caen entre 2026-01-01 y 2026-12-31 | Preservar |
| Fuera de rango trimestral | 6,426 | Fechas 2026-06-15 a 2026-06-19 | No asumir error |
| Antes de crear trimestres | 0 | Trimestres creados 2026-03-25; registros creados 2026-06-15 a 2026-06-20 | No aplica |
| De otra escuela | Sin evidencia | Escuela se infiere por estudiante/docente; calendario único encontrado | Validar si luego hay multiescuela |
| Pre-implementación lógica actual | No evidente | `created_at` posterior a creación de trimestres | No clasificar así |

### Diagnóstico

Estos registros son **académicamente válidos en el año escolar**, pero **no atribuibles a un trimestre configurado**. La inconsistencia está más en el calendario o en el modelo que exige trimestre sin guardar `trimester_id`, no necesariamente en los registros.

### Riesgo si se corrigen mal

Asignar estos registros automáticamente a 1T o 2T puede falsear estadísticas:

- Si se asignan a 1T: se extiende un trimestre ya cerrado.
- Si se asignan a 2T: se contabiliza asistencia antes del inicio formal del 2T.
- Si se eliminan: se pierde asistencia real registrada por docentes.

### Recomendación para estos registros

Preservarlos como históricos. Si se agrega `trimester_id`, permitir `NULL` para históricos fuera de trimestre, o clasificarlos como `Periodo no asignado` / `Intertrimestre` en reportes.

---

## 4. FASE 3 — Análisis de duplicados

### Consulta base usada

```sql
SELECT
    student_id,
    teacher_id,
    group_id,
    grade_id,
    date,
    COUNT(*)
FROM attendance
GROUP BY student_id, teacher_id, group_id, grade_id, date
HAVING COUNT(*) > 1;
```

Resultado anterior:

| Métrica | Valor |
|---|---:|
| Claves duplicadas | 5,830 |
| Filas involucradas | 14,643 |

### Validación para evitar falsos positivos

La clave anterior no incluye `subject_id` porque la tabla no lo tiene. Por eso hay que preguntar:

> ¿Estos duplicados son realmente repetidos, o representan distintas materias/sesiones del mismo docente, grupo, estudiante y fecha?

### Evidencia por cantidad de repeticiones y estados

| Repeticiones por clave | Estados distintos | Claves | Filas |
|---:|---:|---:|---:|
| 2 | 1 | 4,632 | 9,264 |
| 2 | 2 | 118 | 236 |
| 3 | 1 | 779 | 2,337 |
| 3 | 2 | 33 | 99 |
| 4 | 1 | 60 | 240 |
| 4 | 2 | 14 | 56 |
| 5 | 1 | 36 | 180 |
| 5 | 2 | 21 | 105 |
| 5 | 3 | 2 | 10 |
| 10 | 1 | 26 | 260 |
| 10 | 2 | 8 | 80 |
| 11 | 1 | 25 | 275 |
| 11 | 2 | 9 | 99 |
| 16 | 1 | 23 | 368 |
| 16 | 2 | 11 | 176 |
| 26 | 1 | 31 | 806 |
| 26 | 2 | 2 | 52 |

La mayoría de duplicados repite el mismo estado, lo que sugiere re-guardados. Sin embargo, no se puede descartar que algunos representen múltiples sesiones sin columna de sesión/materia.

### Evidencia de materias posibles en duplicados

Inferencia usada:

```text
attendance.teacher_id
  -> teacher_assignments.teacher_id
  -> subject_assignments.id
  -> subject_assignments.group_id + grade_level_id
  -> subjects.id
```

Distribución:

| Materias posibles por clave duplicada | Claves | Filas |
|---:|---:|---:|
| 1 | 5,508 | 13,817 |
| 2 | 254 | 622 |
| 4 | 68 | 204 |

### Interpretación

- **5,508 claves duplicadas** tienen una sola materia inferible; estas son altamente sospechosas de duplicado real.
- **322 claves duplicadas** tienen múltiples materias posibles; estas podrían representar distintas materias, sesiones o una ambigüedad de asignación docente.
- Aun en las claves con una sola materia posible, podría existir más de una sesión el mismo día, pero el modelo no tiene `session_id`, `time_slot_id` ni hora de clase para demostrarlo.

### Causa técnica probable

`AttendanceService.SaveAttendancesAsync` siempre inserta registros nuevos:

```text
_context.Attendances.Add(attendance)
```

No busca si ya existe una asistencia para la misma combinación de:

```text
student_id + teacher_id + group_id + grade_id + date
```

No hace upsert. No tiene restricción única. Esto permite duplicación por guardar varias veces la misma pantalla.

### Conclusión de FASE 3

No todos los 5,830 duplicados deben tratarse igual.

Clasificación recomendada:

| Tipo | Acción futura |
---|---|
| Duplicados con una sola materia inferible y mismo estado | Candidatos fuertes a consolidación, pero solo tras revisión/aprobación. |
| Duplicados con estados distintos | Preservar para auditoría hasta definir regla de precedencia. |
| Duplicados con múltiples materias posibles | No consolidar automáticamente. Pueden representar sesiones/materias distintas. |
| Duplicados de 10, 11, 16, 26 repeticiones | Revisar como posible bug de guardado repetido. |

---

## 5. FASE 4 — Modelo académico ideal

### Pregunta central

¿La asistencia debe registrarse por?

```text
Profesor
+ Materia
+ Grupo
+ Estudiante
+ Fecha
+ Trimestre
+ Año académico
```

### Respuesta recomendada

Sí, para una institución educativa con calificaciones por materia, reportes trimestrales y docentes por asignatura, la asistencia debe estar asociada explícitamente a:

```text
school_id
academic_year_id
trimester_id
teacher_id
subject_id
group_id
grade_id
student_id
date
status
created_by
updated_by
```

### Alternativa más robusta

Si se quiere soportar educación nocturna, bloques, clases dobles o múltiples sesiones en un día, el modelo ideal no debería depender solo de `date`. Debería incluir una entidad o campo adicional:

```text
class_session_id
```

o al menos:

```text
time_slot_id
shift_id
session_number
```

Modelo recomendado a mediano plazo:

```text
ClassSession
 ├── school_id
 ├── academic_year_id
 ├── trimester_id
 ├── teacher_id
 ├── subject_id
 ├── group_id
 ├── grade_id
 ├── date
 ├── time_slot_id / session_number
 └── attendance_records[]

Attendance
 ├── class_session_id
 ├── student_id
 ├── status
 ├── created_by
 ├── updated_by
 └── timestamps
```

### Decisión pragmática

Para una corrección segura y gradual, no es obligatorio crear `ClassSession` de inmediato. El primer paso puede ser enriquecer `attendance` con `subject_id`, `trimester_id`, `academic_year_id` y auditoría. Pero si la institución necesita asistencia por hora/bloque, `ClassSession` es el diseño más correcto.

---

## 6. FASE 5 — Compatibilidad e impacto

### Impacto de agregar `subject_id`

#### Beneficios

- Permite asistencia por materia real.
- Evita inferencias ambiguas por `teacher_assignments`.
- Permite responder “asistencia de Juan en Matemáticas durante 2T”.
- Mejora reportes por docente/materia.

#### Riesgos

- Históricos existentes no tienen materia.
- Backfill automático puede equivocarse en registros con múltiples materias posibles.
- Requiere modificar `AttendanceSaveDto`, JS de `TeacherGradebook`, `AttendanceService`, consultas y reportes.

#### Compatibilidad

Debe ser nullable inicialmente:

```text
subject_id NULL
```

No se debe imponer `NOT NULL` hasta que el sistema nuevo esté estable y el histórico esté clasificado.

### Impacto de agregar `trimester_id`

#### Beneficios

- Reportes por trimestre no dependen de rangos de fecha cambiantes.
- Permite preservar la interpretación del trimestre al momento de registrar.
- Evita que cambios en calendario alteren reportes históricos.

#### Riesgos

- Los 6,426 registros de intertrimestre no tienen trimestre natural.
- Requiere regla para días fuera de trimestre.

#### Compatibilidad

Debe ser nullable inicialmente. Los registros fuera de trimestre deben quedar con `trimester_id = NULL` o una clasificación explícita de período especial si se decide crearla.

### Impacto de agregar `academic_year_id`

#### Beneficios

- Filtrado anual robusto.
- Facilita promoción, reportes institucionales, cierres anuales.
- Evita mezclar años cuando existan datos históricos.

#### Riesgos

- Si existen registros sin año académico configurado en otros entornos, backfill podría quedar incompleto.

#### Compatibilidad

En producción actual parece seguro inferir 2026 para los 32,297 registros, pero aun así debe planearse como nullable inicialmente y backfill controlado.

### Impacto por módulo

| Módulo | Impacto |
|---|---|
| `TeacherGradebook` | Alto. Debe enviar `subjectId`; guardar/upsert por materia; consultar por fecha+materia. |
| `StudentReport` | Medio. Puede mejorar asistencia por trimestre/materia; debe soportar históricos sin `subject_id`. |
| Report Cards | Medio/Alto si se decide mostrar asistencia por materia o período. |
| `AttendanceController` | Medio. CRUD genérico está incompleto y debería protegerse o rediseñarse. |
| Reportes institucionales | Medio. Podrán segmentar por materia/docente/trimestre/año. |
| Promoción | Bajo/Medio. Solo impacta si asistencia entra como criterio de promoción. |
| Educación nocturna | Alto beneficio, pero falta sesión/horario para exactitud completa. |

---

## 7. FASE 6 — Estrategias de migración

### Plan A — Corrección mínima segura

Agregar columnas nullable y corregir el guardado futuro.

#### Cambios conceptuales

- Agregar a `attendance`:
  - `subject_id NULL`
  - `trimester_id NULL`
  - `academic_year_id NULL`
- Modificar `AttendanceSaveDto` para recibir `SubjectId`.
- Modificar JS de `TeacherGradebook` para enviar `subjectId`.
- `SaveAttendancesAsync` debe:
  - resolver `academic_year_id` por escuela/fecha;
  - resolver `trimester_id` por escuela/fecha si existe;
  - hacer upsert por clave nueva;
  - llenar `school_id`, `created_by`, `updated_by`.
- No tocar históricos, salvo dejarlos compatibles.

#### Riesgo

Bajo.

#### Complejidad

Media.

#### Impacto

Alto para registros nuevos; bajo sobre históricos.

#### Tiempo estimado

1 a 2 días de implementación + pruebas.

#### Ventaja

Evita dañar histórico. Mejora el sistema hacia adelante.

#### Desventaja

Los reportes históricos por materia seguirán incompletos.

---

### Plan B — Corrección con backfill conservador

Aplicar Plan A y además poblar históricos solo cuando la inferencia sea segura.

#### Backfill permitido conceptualmente

- `academic_year_id`: asignar si fecha cae inequívocamente dentro de un año académico.
- `trimester_id`: asignar si fecha cae inequívocamente dentro de un trimestre.
- `subject_id`: asignar solo si existe exactamente una materia posible para:

```text
teacher_id + group_id + grade_id
```

#### Registros que NO se deben tocar automáticamente

- Los 6,426 registros fuera de trimestre.
- Duplicados con estados distintos.
- Duplicados con múltiples materias posibles.
- Registros con más de una asignación docente/materia posible.

#### Riesgo

Medio.

#### Complejidad

Media/Alta.

#### Impacto

Mejora históricos sin forzar decisiones ambiguas.

#### Tiempo estimado

3 a 5 días incluyendo scripts de validación, backup, revisión y pruebas.

#### Ventaja

Permite reportes históricos más útiles.

#### Desventaja

Requiere revisar consultas de backfill con mucho cuidado y mantener trazabilidad.

---

### Plan C — Rediseño académico completo con sesiones de clase

Crear entidad `ClassSession` y convertir asistencia en registros por sesión.

#### Modelo conceptual

```text
class_sessions
 ├── id
 ├── school_id
 ├── academic_year_id
 ├── trimester_id
 ├── teacher_id
 ├── subject_id
 ├── group_id
 ├── grade_id
 ├── date
 ├── time_slot_id / session_number
 └── created_by

attendance
 ├── class_session_id
 ├── student_id
 ├── status
 └── audit fields
```

#### Riesgo

Alto.

#### Complejidad

Alta.

#### Impacto

Máximo: soporta asistencia por clase, materia, horario, docente y educación nocturna.

#### Tiempo estimado

1 a 3 semanas según UI, reportes y migración histórica.

#### Ventaja

Modelo académicamente más correcto.

#### Desventaja

Mayor cambio estructural; requiere más pruebas y adaptación de reportes.

---

## 8. Recomendación final

### 1. ¿Debe corregirse?

Sí. Debe corregirse el modelo para registros nuevos. El sistema actual no cumple plenamente una trazabilidad académica por materia/trimestre/año.

### 2. ¿Qué debe corregirse?

Obligatorio:

- guardar `subject_id` en asistencia nueva;
- guardar o resolver `academic_year_id`;
- guardar o resolver `trimester_id` cuando la fecha caiga en un trimestre;
- llenar `school_id`;
- llenar `created_by` y `updated_by`;
- convertir guardado masivo en upsert, no inserción ciega;
- evitar duplicados futuros con índice/clave lógica;
- ajustar consultas de `GetAttendancesByDate`, historial y estadísticas para considerar materia.

### 3. ¿Qué NO debe corregirse automáticamente?

No corregir automáticamente:

- los 6,426 registros del 15 al 19 de junio;
- duplicados históricos con múltiples materias posibles;
- duplicados con estados distintos sin regla institucional;
- históricos fuera de trimestre;
- registros donde la materia no pueda inferirse de forma única.

### 4. ¿Qué datos históricos deben preservarse?

Todos. Especialmente:

- asistencias de junio 15-19;
- duplicados actuales;
- estados distintos en una misma clave;
- registros sin `created_by`/`school_id`.

El histórico debe preservarse porque puede representar comportamiento legítimo, transición de calendario o limitaciones del sistema anterior.

### 5. ¿Qué cambios son obligatorios?

- Cambios de modelo con columnas nullable.
- Guardado futuro con materia/año/trimestre.
- Upsert para evitar duplicados futuros.
- Auditoría real.
- Seguridad de endpoints de asistencia.
- Consultas compatibles con históricos `NULL`.

### 6. ¿Qué cambios son opcionales?

- Backfill conservador de históricos.
- Crear período especial “Intertrimestre”.
- Rediseñar hacia `ClassSession`.
- Incorporar `time_slot_id`, `shift_id` o sesión para educación nocturna.
- Panel de revisión de duplicados históricos.

### 7. Estrategia más segura

La estrategia más segura es **Plan A primero**, seguido opcionalmente de un **Plan B conservador**.

Orden recomendado:

```text
1. Backup completo.
2. Agregar columnas nullable.
3. Corregir TeacherGradebook para guardar subject_id y auditoría.
4. Implementar upsert.
5. Mantener históricos intactos.
6. Activar reportes compatibles con NULL.
7. Ejecutar análisis post-implementación.
8. Solo después, considerar backfill conservador.
```

No se recomienda empezar con Plan C salvo que la institución confirme que necesita asistencia por bloque/horario/sesión como requisito inmediato.

---

## 9. Reglas de compatibilidad para una futura implementación

Toda implementación debe cumplir:

1. No borrar asistencia histórica.
2. No fusionar duplicados sin aprobación explícita.
3. No asignar `subject_id` si hay más de una materia posible.
4. No asignar `trimester_id` a fechas fuera de rango sin decisión institucional.
5. Permitir `NULL` en columnas nuevas durante transición.
6. Reportes deben distinguir:
   - asistencia con materia;
   - asistencia sin materia;
   - asistencia en trimestre;
   - asistencia fuera de trimestre;
   - asistencia con año académico;
   - asistencia histórica incompleta.

---

## 10. Plan técnico detallado sugerido (sin ejecutar)

### Paso 1 — Preparación

- Backup completo de Render.
- Congelar cambios relacionados a asistencia.
- Revisar trimestres con dirección académica.
- Confirmar si 15–19 junio son días lectivos, intertrimestre o cierre.

### Paso 2 — Migración estructural nullable

Columnas propuestas:

```text
attendance.subject_id uuid NULL
attendance.trimester_id uuid NULL
attendance.academic_year_id uuid NULL
```

FK propuestas:

```text
subject_id -> subjects.id
trimester_id -> trimester.id
academic_year_id -> academic_years.id
```

Índices propuestos:

```text
IX_attendance_subject_id
IX_attendance_trimester_id
IX_attendance_academic_year_id
IX_attendance_date
IX_attendance_lookup_new
```

Clave lógica futura:

```text
school_id + academic_year_id + trimester_id + teacher_id + subject_id + group_id + grade_id + student_id + date
```

Nota: si se decide soportar múltiples sesiones por día, esta clave debe incluir `session_number` o `time_slot_id`.

### Paso 3 — Cambios de flujo futuro

`TeacherGradebook/Index`:

- conservar `subjectId` del combo;
- enviarlo a `SaveAttendances`;
- consultar asistencia por `subjectId + groupId + gradeId + date`.

`AttendanceSaveDto`:

- agregar `SubjectId`.

`AttendanceService.SaveAttendancesAsync`:

- validar usuario actual;
- ignorar `TeacherId` enviado por cliente o verificar que coincida con usuario autenticado;
- resolver `SchoolId`;
- resolver `AcademicYearId`;
- resolver `TrimesterId` si aplica;
- upsert por clave académica;
- poblar auditoría.

### Paso 4 — Reportes

`StudentReport`:

- mantener asistencia histórica por fecha.
- si `subject_id` existe, permitir vista por materia.
- si `trimester_id` es `NULL`, clasificar como “sin trimestre asignado”.

Reportes institucionales:

- agregar filtros por materia solo para registros con `subject_id`.
- incluir aviso si hay registros históricos sin materia.

### Paso 5 — Backfill opcional

Solo después de validar reportes nuevos.

Reglas:

- `academic_year_id`: asignar si hay única coincidencia por escuela/fecha.
- `trimester_id`: asignar si hay única coincidencia por escuela/fecha.
- `subject_id`: asignar si hay única materia inferible.
- no tocar registros ambiguos.

### Paso 6 — Validación post-cambio

Consultas esperadas:

```sql
SELECT COUNT(*) FROM attendance WHERE subject_id IS NULL;
SELECT COUNT(*) FROM attendance WHERE academic_year_id IS NULL;
SELECT COUNT(*) FROM attendance WHERE trimester_id IS NULL;
SELECT student_id, teacher_id, subject_id, group_id, grade_id, date, COUNT(*)
FROM attendance
GROUP BY student_id, teacher_id, subject_id, group_id, grade_id, date
HAVING COUNT(*) > 1;
```

Validaciones funcionales:

- Guardar asistencia dos veces no duplica.
- Cambiar estado actualiza.
- Materia A y Materia B del mismo grupo no se mezclan.
- Históricos sin materia siguen visibles.
- StudentReport no rompe.
- Estadísticas trimestrales distinguen fuera de trimestre.

---

## 11. Decisión requerida antes de implementar

Antes de tocar código, se necesita aprobación sobre:

1. ¿Los días 2026-06-15 a 2026-06-19 deben considerarse intertrimestre, 1T, 2T o período especial?
2. ¿La institución necesita asistencia por materia o solo asistencia general diaria?
3. ¿La educación nocturna requiere asistencia por bloque/hora?
4. ¿Se autoriza backfill histórico conservador?
5. ¿Se debe crear un panel/reporte para revisar duplicados antes de cualquier consolidación?

---

## 12. Recomendación aprobable

Recomiendo aprobar una primera implementación con alcance:

```text
Plan A: columnas nullable + guardado futuro correcto + upsert + auditoría real
```

Y dejar para una fase posterior:

```text
Plan B: backfill histórico conservador
Plan C: sesiones de clase / bloques horarios
```

Esta estrategia corrige el problema hacia adelante sin arriesgar pérdida o reinterpretación incorrecta de los 32,297 registros existentes.

