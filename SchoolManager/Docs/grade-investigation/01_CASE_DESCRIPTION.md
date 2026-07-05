# 01 — Descripción del caso

**Fecha del análisis:** 2026-07-05  
**Modo:** Solo investigación (sin cambios de código ni de datos)  
**Proyecto:** SchoolManager (`EduplanerIIC`)

---

## Caso reportado

| Campo | Valor |
|-------|-------|
| Estudiante | Mayte Mojica (registrada como **Mayte N. Mojica G.**) |
| Cédula | 8-1152-86 |
| Grado / Grupo | **7H** (Grado 7, Grupo H) |
| Materia | **Matemáticas** |
| Trimestre analizado | **1T** (único trimestre con calificaciones en BD al momento del análisis) |

## Inconsistencia observada

| Rol | Valor mostrado |
|-----|----------------|
| Profesor (TeacherGradebook) | **4.3** |
| Consejera (tab Consejería) | **4.5** |
| Madre de familia / Portal (StudentReport) | **4.4** |

Los tres roles deberían mostrar **exactamente el mismo valor** según la regla funcional oficial del sistema.

---

## Regla funcional oficial

> **Siempre truncar.** Nunca redondear.

Ejemplos válidos:

| Valor interno | Debe mostrarse |
|---------------|----------------|
| 4.39 | 4.3 |
| 4.35 | 4.3 |
| 4.399999 | 4.3 |
| 4.366666… | 4.3 |

Prohibido: `Math.Round`, `MidpointRounding`, `decimal.Round`, `ToString("F1")`, `toFixed(1)` cuando implique redondeo, etc.

---

## Alcance de la investigación

1. Trazar el flujo completo de la nota desde PostgreSQL hasta la pantalla para **Profesor**, **Consejera** y **Portal de padres/estudiante**.
2. Identificar el valor exacto almacenado en BD.
3. Determinar en qué capa (servicio, mapper, vista, JS) la nota diverge.
4. Documentar la causa raíz y proponer arquitectura unificada (sin implementar).

---

## Identificadores de producción (solo lectura)

| Entidad | UUID |
|---------|------|
| Estudiante (`users.id`) | `ec1b5711-58c1-4f16-ad54-0144349ea243` |
| Materia Matemáticas (`subjects.id`) | `d4a4e493-dfec-4b8d-812a-dee0338e4ab6` |
| Grupo H | `groups.name = 'H'` |
| Grado 7 | `grade_levels.name = '7'` |

---

## Hipótesis inicial (confirmada en fases posteriores)

Existen **tres motores de cálculo distintos** para la misma nota final trimestral:

1. **Profesor:** promedio por tipo de actividad → truncar cada tipo → promedio de tipos → truncar (algoritmo oficial en JS y en `GradebookFinalGradeCalculator`).
2. **Consejera:** promedio plano de **todas** las actividades de la materia (sin agrupar por tipo).
3. **Portal padres:** promedio por tipo **sin truncar** → promedio de tipos → **redondeo** con `ToString("0.0")` / `toFixed(1)`.

Esta hipótesis explica numéricamente los valores 4.3, 4.5 y 4.4 con los datos reales de producción.
