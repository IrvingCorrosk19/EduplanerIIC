# 06 — Comparación SQL / EF por módulo

## Tabla comparativa de consultas

| Aspecto | Profesor | Consejera | Portal padres |
|---------|----------|-----------|---------------|
| **Tabla principal** | `student_activity_scores` | `student_activity_scores` | `student_activity_scores` |
| **JOIN** | activities, users (students) | activities | activities |
| **Filtro StudentId** | No (todos del grupo) | No (todos del grupo) | **Sí** (un estudiante) |
| **Filtro TeacherId** | **Sí** | No | No |
| **Filtro Subject/Group/Grade/Trimester** | Sí | Sí (group, grade, trimester) | Sí (trimester) |
| **GROUP BY** | No en query; agrupa en JS por tipo | `(StudentId, SubjectId)` | Dedup por actividad en servicio |
| **Agregación SQL** | Ninguna (scores crudos) | `AVG(Score)` plano | Ninguna (scores crudos) |
| **CAST / ROUND / TRUNC en SQL** | No | No | No |
| **Cálculo final** | Cliente JS | Servidor C# + JS display | Vista Razor + JS |

---

## SQL equivalente — Profesor (GetNotasPorFiltroAsync)

```sql
SELECT sas.student_id, a.type, a.name, sas.score
FROM student_activity_scores sas
JOIN activities a ON a.id = sas.activity_id
WHERE a.teacher_id = :teacherId
  AND a.subject_id = :subjectId
  AND a.group_id = :groupId
  AND a.grade_level_id = :gradeLevelId
  AND a.trimester = :trimester;
```

**Sin agregación.** El promedio final se calcula en JavaScript.

---

## SQL equivalente — Consejera (GetCounselorGroupSubjectAveragesForTrimesterAsync)

```sql
SELECT sas.student_id,
       a.subject_id,
       AVG(sas.score::float) AS average_score
FROM student_activity_scores sas
JOIN activities a ON a.id = sas.activity_id
WHERE a.group_id = :groupId
  AND a.grade_level_id = :gradeLevelId
  AND a.trimester = :trimester
  AND a.subject_id = ANY(:subjectIds)
  AND sas.score IS NOT NULL
GROUP BY sas.student_id, a.subject_id;
```

**Diferencias clave:**

- `AVG` sobre **todas** las filas (13 actividades para Mayte)
- Cast implícito a `double` en LINQ: `(double)x.Score!.Value`
- **No** `GROUP BY a.type`
- **No** `TRUNC` ni `ROUND` en SQL

---

## SQL equivalente — Portal (StudentReportService)

```sql
SELECT a.subject_id, s.name AS subject, a.type, a.name AS activity,
       sas.score, sas.created_at
FROM student_activity_scores sas
JOIN activities a ON a.id = sas.activity_id
JOIN subjects s ON s.id = a.subject_id
WHERE sas.student_id = :studentId
  AND a.trimester = :trimester
ORDER BY sas.created_at;
```

Post-procesamiento en C#:

```csharp
.GroupBy(x => new { x.ActivityId, x.SubjectId, x.TeacherId, x.Name })
.Select(g => g.OrderByDescending(x => x.CreatedAt).First())
```

Agregación en **Razor/JS**, no en SQL.

---

## Resultados numéricos — Mayte Mojica, Matemáticas 1T

Ejecutado en producción (solo lectura):

### Por tipo (referencia algoritmo docente)

```sql
SELECT a.type, COUNT(*) n, SUM(sas.score) sum,
       ROUND(AVG(sas.score)::numeric, 10) avg_raw,
       TRUNC(AVG(sas.score)::numeric, 1) trunc_avg
FROM student_activity_scores sas
JOIN activities a ON a.id = sas.activity_id
-- filtros: student ec1b5711..., subject d4a4e493..., group H, grade 7, trimester 1T
GROUP BY a.type;
```

| type | n | avg_raw | trunc_avg |
|------|---|---------|-----------|
| notas de apreciación | 6 | 4.8333333333 | 4.8 |
| ejercicios diarios | 6 | 4.3333333333 | 4.3 |
| examen final | 1 | 4.0000000000 | 4.0 |

### Promedio plano (referencia algoritmo consejera)

```sql
SELECT COUNT(*) n, ROUND(AVG(sas.score)::numeric, 10) avg_raw,
       TRUNC(AVG(sas.score)::numeric, 1) trunc_flat
-- mismos filtros
```

| n | avg_raw | trunc_flat |
|---|---------|------------|
| 13 | 4.5384615385 | 4.5 |

### Nota final derivada (no en SQL)

| Algoritmo | Fórmula | Resultado raw | Mostrado |
|-----------|---------|---------------|----------|
| Profesor | TRUNC(mean(TRUNC(tipo)))) | 4.366666… | 4.3 |
| Consejera | TRUNC(AVG(todos)) | 4.538461… | 4.5 |
| Portal | ROUND(mean(tipo sin trunc)) | 4.366666… | 4.4 |

---

## COALESCE / NULL

| Módulo | Manejo de NULL |
|--------|----------------|
| Profesor JS | Ignora celdas vacías; incluye 0.0 si está ingresado |
| Consejera | `.Where(x => x.Score.HasValue)` antes de AVG |
| Portal | `.Where(g => g.Value.HasValue)` antes de agrupar |

---

## Conclusión SQL

Las tres consultas leen la **misma tabla fuente** pero:

1. **Profesor** no agrega en SQL — agrega en JS con lógica por tipo.
2. **Consejera** agrega con **AVG plano incorrecto** para la regla de negocio.
3. **Portal** no agrega en SQL — agrega en vista con **redondeo**.

Ningún módulo persiste ni consulta una columna `nota_final_trimestral`. No hay **Single Source of Truth** en BD ni en un servicio compartido consumido por los tres.
