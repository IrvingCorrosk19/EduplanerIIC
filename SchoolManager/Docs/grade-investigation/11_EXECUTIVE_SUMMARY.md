# 11 — Resumen ejecutivo

**Caso:** Mayte Mojica (7H) — Matemáticas — Trimestre 1T  
**Síntoma:** Profesor ve **4.3**, Consejera **4.5**, Portal padres **4.4**  
**Fecha:** 2026-07-05  
**Modo:** Análisis forense — sin cambios de código ni de datos

---

## Conclusión en una frase

Los tres roles calculan la “nota final” con **fórmulas diferentes** sobre los **mismos 13 scores** de producción; solo el flujo del profesor (pestaña Registrar Notas) aplica el algoritmo oficial con truncamiento (**4.3**).

---

## Valor correcto según regla de negocio

| Concepto | Valor |
|----------|-------|
| Nota final oficial (truncamiento) | **4.3** |
| Almacenado en BD como nota final | **No existe** — solo scores por actividad |

---

## Tabla de hallazgos

| Rol | Valor mostrado | ¿Correcto? | Causa |
|-----|----------------|------------|-------|
| Profesor (Registrar Notas) | 4.3 | **Sí** | JS `calcAverages`: trunc por tipo → mean → trunc |
| Consejera (Consejería) | 4.5 | **No** | `AVG` plano de 13 actividades (4.538… → trunc 4.5) |
| Portal padres (StudentReport) | 4.4 | **No** | Promedio por tipo sin trunc + `ToString("0.0")` redondea 4.366… → 4.4 |

---

## Evidencia de base de datos (producción, solo lectura)

- Estudiante: `ec1b5711-58c1-4f16-ad54-0144349ea243`
- Materia Matemáticas: `d4a4e493-dfec-4b8d-812a-dee0338e4ab6`
- 13 calificaciones en 1T; columna `score` tipo `numeric(2,1)`
- Promedios por tipo: apreciación 4.833…, ejercicios 4.333…, examen 4.0
- Promedio plano 13 scores: 4.5384615385

---

## Causa raíz

1. **No hay Single Source of Truth** para la nota final trimestral.
2. **`GradebookFinalGradeCalculator`** existe y es correcto, pero **no es usado** por Consejería ni Portal.
3. **Consejería** usa promedio aritmético de todas las actividades (ignora regla por tipos).
4. **Portal** aplica **redondeo** (`ToString("0.0")`, `toFixed(1)`) prohibido por política del sistema.

---

## Punto exacto de divergencia

| Transición | Archivo / método |
|------------|------------------|
| 4.3 → 4.5 | `StudentActivityScoreService.GetCounselorGroupSubjectAveragesForTrimesterAsync` |
| 4.3 → 4.4 | `Views/StudentReport/Index.cshtml` — `ToString("0.0")` sobre 4.366666… |

---

## Motores de cálculo identificados (mínimo 4)

1. JavaScript `calcAverages()` — TeacherGradebook (correcto)
2. `GetCounselorGroupSubjectAveragesForTrimesterAsync` — AVG plano (incorrecto)
3. Razor/JS en StudentReport — round (incorrecto)
4. `GradebookFinalGradeCalculator` — PDF e informes (correcto, no universal)

---

## Recomendación principal

Centralizar en un **`IGradeFinalCalculationService`** basado en `GradebookFinalGradeCalculator` y hacer que **todos** los módulos (Profesor, Consejera, Padres, Estudiante, PDF, informes) consuman ese servicio. Prohibir redondeo en CI.

---

## Entregables de esta investigación

| Documento | Contenido |
|-----------|-----------|
| `01_CASE_DESCRIPTION.md` | Descripción del caso |
| `02_DATABASE_ANALYSIS.md` | Evidencia BD producción |
| `03_TEACHER_FLOW.md` | Flujo profesor |
| `04_COUNSELOR_FLOW.md` | Flujo consejera |
| `05_PARENT_FLOW.md` | Flujo portal padres |
| `06_SQL_COMPARISON.md` | Comparación consultas |
| `07_CALCULATION_TRACE.md` | Trazabilidad completa |
| `08_ROUNDING_ANALYSIS.md` | Redondeo vs truncamiento |
| `09_ROOT_CAUSE_ANALYSIS.md` | Causa raíz |
| `10_ARCHITECTURE_RECOMMENDATION.md` | Propuesta técnica |
| `11_EXECUTIVE_SUMMARY.md` | Este resumen |

---

## Restricciones respetadas

- ✅ Solo consultas SELECT en producción
- ✅ Sin modificaciones de código
- ✅ Sin commits, PRs ni push
- ✅ Sin UPDATE/DELETE/INSERT

---

## Próximo paso sugerido (fuera de alcance de este análisis)

Implementar servicio unificado y migrar Consejería + StudentReport como prioridad P0, validando con el caso Mayte Mojica (expectativa: **4.3** en los tres roles).
