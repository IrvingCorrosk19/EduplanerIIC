# 09 — Análisis de causa raíz

## Declaración de causa raíz

La inconsistencia **4.3 / 4.5 / 4.4** para Mayte Mojica en Matemáticas 1T **no es un error de datos en PostgreSQL**. Es el resultado de **tres implementaciones independientes** del concepto “nota final trimestral”, ninguna de las cuales es consumida de forma unificada por Profesor, Consejera y Portal de padres.

---

## Evidencia

### 1. Base de datos consistente

- 13 scores almacenados como `numeric(2,1)`
- Suma = 59.0, promedio plano = 4.5384615385
- **No existe columna de nota final** precalculada

### 2. Tres resultados reproducibles matemáticamente

| Rol | Algoritmo | Valor interno | Pantalla |
|-----|-----------|---------------|----------|
| Profesor | TRUNC por tipo → mean → TRUNC | 4.366666… | **4.3** |
| Consejera | AVG(13 scores) → TRUNC display | 4.538461… | **4.5** |
| Portal | mean por tipo sin TRUNC → ROUND | 4.366666… | **4.4** |

Cada valor reportado por el usuario coincide **exactamente** con el cálculo derivado de los mismos datos de producción.

---

## Causas contribuyentes (orden de impacto)

### CAUSA A — Ausencia de Single Source of Truth (crítica)

**Qué:** No hay un servicio único `IGradeCalculationService` (o equivalente) invocado por todos los consumidores.

**Dónde:** Arquitectura general del módulo académico.

**Impacto:** Cualquier cambio de regla debe replicarse en 4+ lugares; ya divergieron.

---

### CAUSA B — Algoritmo plano en Consejería (crítica para delta +0.2)

**Qué:** `GetCounselorGroupSubjectAveragesForTrimesterAsync` calcula `AVG(todos los scores)` ignorando la ponderación por tipo de actividad.

**Dónde:**
- `Services/Implementations/StudentActivityScoreService.cs` líneas ~367–398
- Consumido por `TeacherGradebookController.GetCounselorGroupAverages`

**Por qué produce 4.5:** 59/13 = 4.538… → truncado a 4.5.

**Violación de regla:** Además de fórmula incorrecta, no sigue el algoritmo oficial por tipos.

---

### CAUSA C — Redondeo en Portal de padres (crítica para delta +0.1)

**Qué:** `StudentReport/Index.cshtml` usa `ToString("0.0")` y `toFixed(1)` sin truncar previamente.

**Dónde:**
- Razor ~344, ~353, ~372, ~384
- JavaScript ~696, ~705, ~719+

**Por qué produce 4.4:** 4.366666… redondeado = 4.4; truncado sería 4.3.

**Violación de regla:** Redondeo explícitamente prohibido por política del sistema.

---

### CAUSA D — Lógica duplicada en capa de presentación (alta)

**Qué:** El cálculo de nota final vive en:
- JavaScript del TeacherGradebook
- C# del servicio de consejería
- Razor/JS del StudentReport

**Impacto:** Imposible garantizar paridad sin refactor.

---

### CAUSA E — Helper oficial no adoptado universalmente (alta)

**Qué:** `GradebookFinalGradeCalculator` implementa correctamente truncamiento + recuperación, pero solo lo usan:
- PDF del gradebook
- Reportes institucionales / aprobados-reprobados (parcial)

**No lo usan:** Consejería, StudentReport, GetPromediosFinalesAsync.

---

### CAUSA F — Deuda técnica documentada previamente (media)

**Qué:** `ANALISIS_TRUNCAMIENTO_NOTAS.md` (2026-05-24) ya identificó redondeo vs truncamiento dentro del propio TeacherGradebook (tab Resumen).

**Impacto:** El problema era conocido parcialmente pero no se extendió a corrección cross-módulo.

---

## Árbol de causas

```
Síntoma: 4.3 ≠ 4.5 ≠ 4.4
    │
    ├─► No hay nota final en BD
    │       └─► Cada módulo calcula en runtime
    │
    ├─► No hay servicio único de cálculo
    │       ├─► Consejera: AVG plano (CAUSA B)
    │       ├─► Portal: Razor + ROUND (CAUSA C)
    │       └─► Profesor: JS trunc (correcto pero aislado)
    │
    └─► GradebookFinalGradeCalculator no es obligatorio (CAUSA E)
```

---

## Componente responsable principal (para remediación)

| Prioridad | Componente | Acción requerida (futura, fuera de este análisis) |
|-----------|------------|---------------------------------------------------|
| P0 | Nuevo o refactor de servicio central | Unificar algoritmo |
| P0 | `GetCounselorGroupSubjectAveragesForTrimesterAsync` | Reemplazar AVG plano por `GradebookFinalGradeCalculator` |
| P0 | `Views/StudentReport/Index.cshtml` | Eliminar `ToString("0.0")` / `toFixed`; usar trunc |
| P1 | `GetPromediosFinalesAsync` | Alinear con calculator |
| P1 | Mover cálculo JS de `calcAverages` al servidor | Una sola fuente |

---

## Lo que NO es la causa raíz

| Descartado | Evidencia |
|------------|-----------|
| Datos corruptos en BD | Scores consistentes, tipo numeric(2,1) |
| Float/double precision loss | Columna es numeric |
| Diferentes trimestres | Solo 1T con datos |
| Diferentes materias | Misma subject_id verificada |
| Duplicados de score | 13 actividades = 13 filas |
| Cache / CDN | Cálculo es server-side + JS local |

---

## Conclusión

**Causa raíz:** Violación del principio **Single Source of Truth** para el cálculo de nota final trimestral, combinada con (1) algoritmo de promedio plano en consejería y (2) redondeo en portal de padres, mientras el profesor aplica correctamente el algoritmo por tipos con truncamiento solo en el cliente del gradebook.

**Valor correcto según regla oficial:** **4.3**
