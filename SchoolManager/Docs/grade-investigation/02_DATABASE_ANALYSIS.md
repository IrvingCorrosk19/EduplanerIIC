# 02 — Análisis de base de datos (producción, solo lectura)

**Conexión:** PostgreSQL en Render (`schoolmanagement_xqks`)  
**Restricción:** Solo consultas `SELECT`. Sin INSERT/UPDATE/DELETE.

---

## Tipo de dato de la columna `score`

```sql
SELECT column_name, data_type, numeric_precision, numeric_scale
FROM information_schema.columns
WHERE table_name = 'student_activity_scores' AND column_name = 'score';
```

| column_name | data_type | numeric_precision | numeric_scale |
|-------------|-----------|-------------------|---------------|
| score | **numeric** | 2 | **1** |

**Conclusión:** Las notas se almacenan como `numeric(2,1)` — máximo un decimal en BD. No hay `float`, `double` ni `real` en esta columna. **No hay pérdida de precisión adicional** más allá del decimal ya persistido.

---

## Estudiante y matrícula

```sql
SELECT u.id, u.name, u.last_name, u.document_id, g.name AS grupo, gl.name AS grado
FROM users u
JOIN student_assignments sa ON sa.student_id = u.id AND sa.is_active = true
JOIN groups g ON g.id = sa.group_id
JOIN grade_levels gl ON gl.id = sa.grade_id
WHERE u.name ILIKE '%Mayte%' AND u.last_name ILIKE '%Mojica%';
```

| id | name | last_name | document_id | grupo | grado |
|----|------|-----------|-------------|-------|-------|
| ec1b5711-58c1-4f16-ad54-0144349ea243 | Mayte N. | Mojica G. | 8-1152-86 | H | 7 |

---

## Materia

| id | name |
|----|------|
| d4a4e493-dfec-4b8d-812a-dee0338e4ab6 | MATEMÁTICAS |

---

## Calificaciones individuales — Matemáticas 1T, 7H

Total: **13 registros** (6 apreciación + 6 ejercicios + 1 examen).

| Tipo | Actividad (resumida) | score |
|------|----------------------|-------|
| notas de apreciación | Taller N 1… | 5.0 |
| notas de apreciación | Taller N 2… | 5.0 |
| notas de apreciación | Taller N 3… | 5.0 |
| notas de apreciación | Taller N 4… | 5.0 |
| notas de apreciación | Taller N 5… | 4.5 |
| notas de apreciación | Taller N 6… | 4.5 |
| ejercicios diarios | suma y resta… | 5.0 |
| ejercicios diarios | multiplicación… | 4.0 |
| ejercicios diarios | potenciación… | 4.2 |
| ejercicios diarios | radicación… | 4.0 |
| ejercicios diarios | recta numérica… | 3.8 |
| ejercicios diarios | plano cartesiano… | 5.0 |
| examen final | examen trimestral | 4.0 |

**Suma total:** 59.0 sobre 13 actividades.

---

## Agregaciones SQL (evidencia numérica)

### Por tipo de actividad (trimestre 1T)

| type | n | sum | avg_raw | TRUNC(avg, 1) |
|------|---|-----|---------|---------------|
| notas de apreciación | 6 | 29.0 | 4.8333333333 | **4.8** |
| ejercicios diarios | 6 | 26.0 | 4.3333333333 | **4.3** |
| examen final | 1 | 4.0 | 4.0000000000 | **4.0** |

### Promedio plano (todas las actividades — algoritmo consejera)

| trimester | n | avg_raw | TRUNC(avg, 1) |
|-----------|---|---------|---------------|
| 1T | 13 | **4.5384615385** | **4.5** |

### Nota final según algoritmo oficial (truncar tipos, luego promediar tipos, truncar)

```
Paso 1 — Promedios por tipo truncados:
  Apreciación: TRUNC(4.8333…) = 4.8
  Ejercicios:  TRUNC(4.3333…) = 4.3
  Examen:      4.0

Paso 2 — Promedio de los 3 tipos:
  (4.8 + 4.3 + 4.0) / 3 = 4.366666…

Paso 3 — Truncar resultado final:
  TRUNC(4.366666…) = 4.3  ← coincide con PROFESOR
```

### Nota final según algoritmo portal (sin truncar tipos, redondear al mostrar)

```
Promedios por tipo sin truncar:
  4.8333…, 4.3333…, 4.0

Promedio final = 4.366666…

ToString("0.0") / toFixed(1) con redondeo estándar → 4.4  ← coincide con PADRES
```

---

## Verificaciones adicionales

| Pregunta | Resultado |
|----------|-----------|
| ¿Hay duplicados de score para la misma actividad? | No detectados en el conjunto analizado (13 filas = 13 actividades distintas) |
| ¿Hay trimestres 2T/3T con datos? | No para este estudiante/materia al momento del análisis |
| ¿Recuperación reemplaza examen? | No hay actividad tipo `recuperación` en 1T para este caso |
| ¿Pérdida float/double? | No — columna es `numeric(2,1)` |

---

## Valor “oficial” en BD

La BD **no almacena una nota final trimestral calculada**. Solo almacena **notas por actividad** (`student_activity_scores.score`). Toda nota final es **derivada en aplicación** mediante lógica que **varía por módulo**.

El valor exacto almacenado por actividad es el mostrado en la tabla anterior (un decimal). La inconsistencia **no proviene de la BD** sino de **cálculos y formateo en capas superiores**.
