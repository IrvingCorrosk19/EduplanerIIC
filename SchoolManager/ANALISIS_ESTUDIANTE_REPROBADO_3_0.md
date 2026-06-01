# Análisis forense: estudiante con nota aparente 3.0 marcado como REPROBADO

**Fecha del análisis:** 2026-05-24  
**Módulo:** `/TeacherGradebook/Index`  
**Modo:** Solo lectura (código + PostgreSQL producción Render).  
**Restricciones respetadas:** Sin cambios de código, sin DML, sin commit/push.

---

## Resumen ejecutivo

El sistema define **aprobación con nota final ≥ 3.0** en escala **1.0–5.0**. El comportamiento reportado (**se ve 3.0 y figura Reprobado**) es **coherente con la regla** cuando la nota real almacenada/calculada es **inferior a 3.0** (por ejemplo **2.9667**), pero la columna **Promedio Final** del tab **Resumen Final** la muestra como **"3.0"** porque usa **`Number.toFixed(1)`**, que **redondea** visualmente, mientras el estado usa la comparación **`promedioFinal >= 3.0`** sobre el valor **sin redondear**.

**Caso principal validado en BD (docente Robert Wright, Ciencias Naturales, grupo Ñ, 1T):**  
**Eliany P Olea T** (`document_id`: `8-1126-176`) — nota calculada **2.9667**, pantalla **3.0**, estado **Reprobado**.

---

## FASE 1 — Docente analizado

| Campo | Valor |
|--------|--------|
| **Email** | `robertwright68@gmail.com` |
| **Id** | `ee458ad2-90a1-4da7-b3d4-a12bc04ee7c3` |
| **Nombre** | ROBERTO WRIGHT |
| **Rol** | `teacher` |
| **Estado** | `active` |
| **Escuela** | Instituto Profesional y Técnico San Miguelito (`6e42399f-6f17-4585-b92e-fa4fff02cb65`) |

### Asignaciones (`teacher_assignments` → `subject_assignments`)

| Materia | Grupo | Grado (nivel) | `subject_id` | `group_id` | `grade_level_id` |
|---------|-------|---------------|--------------|------------|------------------|
| CIENCIAS NATURALES | Ñ | 8 | `7690f5e6-3f4b-4484-8078-36a0d2e07140` | `db896653-6baa-4650-b519-0e8fddbac988` | `7769dfbc-1ce6-4584-b581-0345943b1192` |
| CIENCIAS NATURALES | O | 8 | `7690f5e6-3f4b-4484-8078-36a0d2e07140` | `73785a72-dc5e-499e-958f-3d470e2696f3` | `7769dfbc-1ce6-4584-b581-0345943b1192` |
| CIENCIAS NATURALES INTEGRADAS | E2 | 10 | `912c1488-e852-4a4a-8dac-a7bf08692eb9` | `5f06bf0b-12ac-487d-9fea-09ec571336a6` | `c3180447-1afd-4ba8-9ebb-4de5bc9eb5c3` |

No se encontraron filas en `user_groups` / `user_subjects` para este docente; el alcance operativo del libro de calificaciones proviene de **`teacher_assignments`**.

---

## FASE 2 — Estudiante afectado (caso reproducible en BD)

El reporte no incluía nombre explícito del estudiante. En los datos del docente se identificó el patrón **display 3.0 + Reprobado** de forma inequívoca en:

| Campo | Valor |
|--------|--------|
| **Id** | `1e021123-9e7d-4d63-a81c-42c5d67d5a47` |
| **Nombre completo** | **Olea T, Eliany P** |
| **Documento** | `8-1126-176` |
| **Grupo** | Ñ |
| **Grado** | 8 (`7769dfbc-1ce6-4584-b581-0345943b1192`) |
| **Materia** | CIENCIAS NATURALES |
| **Profesor** | ROBERTO WRIGHT (`robertwright68@gmail.com`) |
| **Trimestre** | `1T` |

### Otros estudiantes del mismo docente con el mismo patrón (misma lógica)

| Estudiante | Grupo | Trimestre | Nota real | Muestra `toFixed(1)` | Estado |
|------------|-------|-----------|-----------|----------------------|--------|
| Dogirama C., Wilberto | O | 1T | 2.9822 | **3.0** | Reprobado |
| Olea T, Eliany P | Ñ | 1T | 2.9667 | **3.0** | Reprobado |
| Rodriguez G, Emanel D | Ñ | 1T | 2.9481 | 2.9 | Reprobado |
| Consuegra M., Lisbeyka | O | 1T | 2.9311 | 2.9 | Reprobado |

---

## FASE 3 — Trazabilidad de la nota

### 3.1 Base de datos (notas almacenadas — Eliany, 1T, Ciencias Naturales)

Promedios por tipo (solo `score IS NOT NULL`):

| Tipo | Cantidad | Promedio |
|------|----------|----------|
| notas de apreciación | 8 | **2.90** |
| ejercicios diarios | 5 | **3.20** |
| examen final | 1 | **2.80** |

**Nota final (misma fórmula que el backend):**  
`(2.90 + 3.20 + 2.80) / 3 = **2.966666…**`

### 3.2 Servicio — `GetPromediosFinalesAsync`

**Archivo:** `Services/Implementations/StudentActivityScoreService.cs`  
**Método:** `GetPromediosFinalesAsync` (aprox. líneas 401–494)

- Promedia por tipo (`notas de apreciación`, `ejercicios diarios`, `examen final`).
- **Nota final** = promedio aritmético de los tipos que tienen valor (`Average()`), **sin truncar**.
- **No incluye** actividades tipo `recuperación`.
- **Estado en DTO:** `notaFinal.Value >= 3.0m ? "Aprobado" : "Reprobado"`.

Para Eliany: `NotaFinal = 2.9667…`, `Estado = "Reprobado"`.

### 3.3 Controlador

**Archivo:** `Controllers/TeacherGradebookController.cs`  
**Método:** `GetPromediosFinales` (aprox. líneas 528–548)  
Devuelve JSON `{ success, data }` con lista de `PromedioFinalDto` (incluye `NotaFinal` y `Estado` por trimestre).

### 3.4 Vista — tab Resumen Final

**Archivo:** `Views/TeacherGradebook/Index.cshtml`

Dos cargadores al tab **Resumen**:

1. **`loadPromediosFinales()`** (aprox. 2324–2382) — al cambiar grupo en libro / click en tab.
2. **`loadPromediosFinalesResumen()`** (aprox. 4260–4334) — al usar `#selGroupResumen`.

Ambos calculan en el cliente:

```javascript
promedioFinal = promedio de trimestres con nota > 0
estado = promedioFinal >= 3.0 ? 'Aprobado' : 'Reprobado'
// Visualización:
promedioFinal.toFixed(1)  // REDONDEA → 2.9667 se muestra como "3.0"
```

### 3.5 Vista — libro de calificaciones (grid principal)

**Función:** `calcAverages()` (aprox. 2168–2222)

- Promedio por tipo con **`Math.floor(avg * 10) / 10`** (truncamiento).
- Nota final = promedio de tipos > 0, luego **truncada** igual.
- Columna `.final-grade` muestra **`truncFinalGrade.toFixed(1)`**.

Para Eliany en el **mismo trimestre**, la nota en el grid sería **2.9** (truncada), **no 3.0**.  
La discrepancia **3.0 en pantalla / Reprobado** aparece sobre todo en el **tab Resumen**, no en la columna final truncada del libro.

### Tabla resumen trazabilidad (Eliany, 1T)

| Etapa | Valor | ¿Aprobado? |
|-------|-------|------------|
| Notas en BD | Aprec. 2.9, Ejerc. 3.2, Examen 2.8 | — |
| Calculada (servicio / SQL) | **2.9667** | No (< 3.0) |
| Enviada al cliente (`NotaFinal`) | **2.9667** | DTO: Reprobado |
| Mostrada (Resumen, `toFixed(1)`) | **"3.0"** | — |
| Estado mostrado (Resumen) | **Reprobado** | Coherente con valor real |

---

## FASE 4 — Regla oficial de aprobación

| Ubicación | Regla exacta |
|-----------|----------------|
| `StudentActivityScoreService.GetPromediosFinalesAsync` ~488 | `notaFinal.Value >= 3.0m` → Aprobado |
| `Views/TeacherGradebook/Index.cshtml` ~1802, 2368, 4305 | `promedio >= 3.0` o `truncPromedio >= 3.0` |
| `Views/TeacherGradebook/Index.cshtml` `calcAverages` colores ~4458 | `average >= 3.0` |
| `AprobadosReprobadosService` | `NotaMinimaAprobacion = 3.0m` (constante) |
| `ReportesInstitucionalesService` / `TeacherGradebookPdfService` | Truncamiento + promedios por tipo; umbral implícito 3.0 en informes relacionados |

**Conclusión:** La regla oficial es **`>= 3.0`** (no `> 3.0`, no 3.5, no 4.0) sobre escala **1.0–5.0**.

No existe en el proyecto una regla distinta tipo “solo aprueba con 3.5” para TeacherGradebook.

---

## FASE 5 — Escala de calificación

| Aspecto | Evidencia |
|---------|-----------|
| **Escala** | **1.0 – 5.0** (`validateScore`: `Math.max(1.0, Math.min(5.0, score))` en `Index.cshtml` ~1761–1763) |
| **Mínima captura** | 1.0 |
| **Máxima** | 5.0 |
| **Aprobatoria** | **3.0 inclusive** (`>= 3.0`) |

---

## FASE 6 — Redondeos y truncamiento

| Capa | Mecanismo | Efecto en 2.9667 |
|------|-----------|------------------|
| **BD** | `decimal`/`numeric` sin redondeo de presentación | 2.966666… |
| **Servicio `GetPromediosFinales`** | Sin truncar | 2.9667 → Reprobado |
| **Libro `calcAverages`** | `Math.floor(x*10)/10` | **2.9** mostrado |
| **Resumen `toFixed(1)`** | Redondeo IEEE al décimo | **3.0** mostrado |
| **Decisión Aprobado/Reprobado (Resumen)** | Valor bruto `>= 3.0` | **Reprobado** |

**Diferencia crítica:** El usuario **ve 3.0** por **redondeo de presentación**; el sistema **decide** con **2.9667 < 3.0**.

Casos adicionales del mismo docente: **2.9822** → muestra **3.0**, estado **Reprobado**.

---

## FASE 7 — Promedios (actividades → trimestre → anual)

### Por trimestre (backend = Resumen API)

1. Promedio de todas las notas del tipo **notas de apreciación** (con `score` no nulo).
2. Promedio de **ejercicios diarios**.
3. Promedio de **examen final**.
4. **Nota final trimestral** = promedio de los tres promedios anteriores que existan.

**No se promedian actividades sueltas en la nota final**; se promedian **tipos**, luego se promedian **esos promedios**.

### Libro de calificaciones (frontend)

- Misma idea por tipo, pero **trunca cada promedio de tipo** y la **nota final**.
- Si hay **recuperación** > 0, sustituye el promedio de **examen final** (líneas 2194–2202). El backend de `GetPromediosFinales` **no aplica** recuperación.

### Promedio anual (Resumen)

- Promedio de trimestres con nota **> 0** (1T, 2T, 3T).
- `updateResumenTable()` usa **truncamiento** en el promedio anual (`truncateToOneDecimal`).
- `loadPromediosFinales` / `loadPromediosFinalesResumen` usan **sin truncar** para el promedio anual pero **`toFixed(1)`** para mostrar.

Para Eliany en **1T** el problema no depende del promedio anual: basta un trimestre con **2.9667** en columna de trimestre redondeada a 3.0 o en columna **Promedio Final** si solo hay un trimestre cargado.

---

## FASE 8 — Dónde se construye Reprobado / Aprobado

| UI | Archivo | Función / zona | Condición |
|----|---------|----------------|-----------|
| Tab **Resumen Final** — columna Estado | `Index.cshtml` | `loadPromediosFinales` ~2366–2380 | `promedioFinal >= 3.0` |
| Tab **Resumen** (selector propio) | `Index.cshtml` | `loadPromediosFinalesResumen` ~4305, 4323 | Igual + clase `text-danger` |
| Resumen local (sin API) | `Index.cshtml` | `updateResumenTable` ~1799–1814 | `truncPromedio >= 3.0` |
| Backend DTO (no siempre pintado en UI) | `StudentActivityScoreService.cs` ~488 | `notaFinal >= 3.0m` |
| Libro — colores promedio | `Index.cshtml` ~4458, 4471 | `>= 3.0` verde, si no rojo |

**Badges:** En Resumen se usa texto **"Reprobado"** con clase Bootstrap `text-danger`, no badge `bg-danger` en esa tabla.

---

## FASE 9 — Consultas SQL de validación (solo SELECT)

### Docente

```sql
SELECT id, email, role, school_id, name, last_name, status
FROM users
WHERE LOWER(email) = 'robertwright68@gmail.com';
```

### Asignaciones del docente

```sql
SELECT sub.name AS materia, g.name AS grupo, gl.name AS grado_nivel,
       sa.subject_id, sa.group_id, sa.grade_level_id
FROM teacher_assignments ta
JOIN subject_assignments sa ON sa.id = ta.subject_assignment_id
JOIN subjects sub ON sub.id = sa.subject_id
JOIN groups g ON g.id = sa.group_id
JOIN grade_levels gl ON gl.id = sa.grade_level_id
WHERE ta.teacher_id = 'ee458ad2-90a1-4da7-b3d4-a12bc04ee7c3';
```

### Estudiante y notas (Eliany)

```sql
SELECT u.id, u.last_name, u.name, u.document_id
FROM users u
WHERE u.id = '1e021123-9e7d-4d63-a81c-42c5d67d5a47';

SELECT a.type, a.trimester, a.name, sas.score
FROM student_activity_scores sas
JOIN activities a ON a.id = sas.activity_id
WHERE sas.student_id = '1e021123-9e7d-4d63-a81c-42c5d67d5a47'
  AND a.teacher_id = 'ee458ad2-90a1-4da7-b3d4-a12bc04ee7c3'
  AND a.subject_id = '7690f5e6-3f4b-4484-8078-36a0d2e07140'
  AND a.trimester = '1T'
ORDER BY a.type, a.name;
```

### Nota final y estado (réplica backend)

```sql
WITH tipo AS (
  SELECT lower(a.type) AS tipo, AVG(sas.score) AS promedio
  FROM student_activity_scores sas
  JOIN activities a ON a.id = sas.activity_id
  WHERE sas.student_id = '1e021123-9e7d-4d63-a81c-42c5d67d5a47'
    AND a.teacher_id = 'ee458ad2-90a1-4da7-b3d4-a12bc04ee7c3'
    AND a.subject_id = '7690f5e6-3f4b-4484-8078-36a0d2e07140'
    AND a.group_id = 'db896653-6baa-4650-b519-0e8fddbac988'
    AND a.grade_level_id = '7769dfbc-1ce6-4584-b581-0345943b1192'
    AND a.trimester = '1T'
    AND sas.score IS NOT NULL
    AND lower(a.type) IN ('notas de apreciación', 'ejercicios diarios', 'examen final')
  GROUP BY lower(a.type)
)
SELECT
  ROUND(AVG(promedio)::numeric, 4) AS nota_final_real,
  ROUND(AVG(promedio)::numeric, 1) AS muestra_tofixed1,
  CASE WHEN AVG(promedio) >= 3.0 THEN 'Aprobado' ELSE 'Reprobado' END AS estado
FROM tipo;
```

**Resultado esperado:** `nota_final_real = 2.9667`, `muestra_tofixed1 = 3.0`, `estado = Reprobado`.

### Casos límite del docente (script auxiliar)

Archivo de apoyo (solo lectura): `Scripts/forensic_robertwright_gradebook.sql`

---

## FASE 10 — Documento final consolidado

### Profesor analizado

**robertwright68@gmail.com** — ROBERTO WRIGHT, `teacher`, IPT San Miguelito.

### Estudiante afectado (caso principal)

**Olea T, Eliany P** (`8-1126-176`) — CIENCIAS NATURALES, grupo **Ñ**, grado **8**, trimestre **1T**.

### Nota mostrada

**3.0** en tab **Resumen Final** (columna Promedio Final o trimestre vía `toFixed(1)`).

### Nota almacenada / calculada

**2.966666…** (promedio de promedios por tipo: 2.9, 3.2, 2.8).

### Regla de aprobación encontrada

**Nota final ≥ 3.0** (escala 1.0–5.0).

### Archivo y método donde se decide

| Prioridad | Archivo | Método / función | Línea aprox. |
|-----------|---------|------------------|------------|
| Servicio | `StudentActivityScoreService.cs` | `GetPromediosFinalesAsync` | 488 |
| Vista (Resumen) | `Views/TeacherGradebook/Index.cshtml` | `loadPromediosFinales` / `loadPromediosFinalesResumen` | 2368, 4305 |

### Evidencia encontrada

1. SQL en producción confirma **2.9667 < 3.0**.
2. Misma consulta con `ROUND(..., 1) = 3.0`.
3. Código de Resumen usa **`toFixed(1)`** para mostrar y **`>= 3.0`** sin redondear para estado.
4. El libro principal **trunca** a **2.9**; el Resumen **redondea** a **3.0** → inconsistencia visual entre tabs.
5. `GetPromediosFinales` **no** alinea con `calcAverages` (sin truncar, sin recuperación).

### Causa raíz

> **La vista del tab Resumen Final muestra la nota con `toFixed(1)` (redondeo a 3.0), pero el estado Aprobado/Reprobado se calcula con el valor numérico real (2.9667), que es menor que 3.0. El sistema marca correctamente Reprobado según la regla `>= 3.0`; el problema es de presentación (y, secundariamente, de inconsistencia entre truncamiento en el libro y redondeo en el resumen / falta de truncamiento en el servicio).**

No se trata de umbral 3.5, ni de trimestre equivocado, ni de error lógico invertido en la comparación.

### Recomendaciones (solo documentales — sin implementar)

Para alinear comportamiento en una futuera corrección (fuera de este análisis):

1. Usar **truncamiento a un decimal** (`Math.floor`) también al **mostrar** en Resumen, igual que `calcAverages`.
2. Unificar **servicio** con lógica de `ReportesInstitucionalesService.CalcularNotaFinalLibroCalificaciones` (truncar + recuperación).
3. Mostrar nota con más decimales o tooltip con valor exacto cuando esté en zona 2.95–3.04.

---

*Fin del análisis forense. No se realizaron cambios en código ni base de datos.*
