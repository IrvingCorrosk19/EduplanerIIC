# 08 — Análisis de redondeo vs truncamiento

## Regla oficial del sistema

> Siempre truncar. Nunca redondear.

Implementación canónica (existente pero no universal):

```csharp
// Services/Helpers/GradebookFinalGradeCalculator.cs
public static decimal TruncateOneDecimal(decimal value) 
    => Math.Floor(value * 10m) / 10m;
```

```javascript
// Views/TeacherGradebook/Index.cshtml
Math.floor(value * 10) / 10
```

---

## Inventario de mecanismos de redondeo en el codebase

### Violaciones directas de la regla (calificaciones)

| Ubicación | Mecanismo | Efecto | Usado en flujo del caso |
|-----------|-----------|--------|-------------------------|
| `Views/StudentReport/Index.cshtml` | `ToString("0.0")` | Redondeo bancario | **Sí — Portal 4.4** |
| `Views/StudentReport/Index.cshtml` | `toFixed(1)` en JS | Redondeo | **Sí — AJAX portal** |
| `StudentActivityScoreService.GetPromediosFinalesAsync` | Sin truncar + display con `formatGradeDisplay` parcial | Inconsistencia interna docente | No en caso 4.3 |
| `ReportesInstitucionalesService.cs` ~520, ~626 | `Math.Round(..., 1)` | Redondeo | Informes (no UI del caso) |

### Truncamiento correcto (parcial)

| Ubicación | Mecanismo | Usado en flujo del caso |
|-----------|-----------|-------------------------|
| `GradebookFinalGradeCalculator.cs` | `Math.Floor * 10 / 10` | PDF/reportes, no UI consejera/portal |
| `TeacherGradebook/Index.cshtml` `calcAverages` | `Math.floor` | **Sí — Profesor 4.3** |
| `TeacherGradebook/Index.cshtml` `formatGradeDisplay` | trunc + toFixed | Profesor y Consejera display |
| `TeacherGradebookPdfService.cs` | `TruncateOneDecimal` | PDF export |

### Algoritmo incorrecto (no es redondeo, es fórmula distinta)

| Ubicación | Problema |
|-----------|----------|
| `GetCounselorGroupSubjectAveragesForTrimesterAsync` | AVG plano — ignora tipos de actividad |
| `StudentReport/Index.cshtml` Razor | Promedio por tipo sin truncar intermedio |

---

## Demostración numérica — caso Mayte 1T

### Valor que debería mostrarse (regla oficial)

```
Tipo apreciación: TRUNC(29/6) = TRUNC(4.8333…) = 4.8
Tipo ejercicios:  TRUNC(26/6) = TRUNC(4.3333…) = 4.3
Tipo examen:      4.0
Final: TRUNC((4.8+4.3+4.0)/3) = TRUNC(4.3666…) = 4.3
```

**Valor correcto único: 4.3**

### Lo que hace cada rol

| Rol | Operación prohibida / incorrecta | Resultado |
|-----|----------------------------------|-----------|
| Profesor | Ninguna en algoritmo grid | **4.3** ✓ |
| Consejera | AVG(13) en lugar de algoritmo por tipos | **4.5** ✗ |
| Portal | `ToString("0.0")` redondea 4.3666… | **4.4** ✗ |

### Tabla de conversión — valor 4.366666…

| Método | Resultado |
|--------|-----------|
| TRUNC (oficial) | **4.3** |
| ROUND / ToString("0.0") | **4.4** |
| AVG plano 13 scores → TRUNC | **4.5** |

Esta tabla explica **exactamente** los tres valores reportados desde **un mismo dato fuente**.

---

## `toFixed(1)` — ¿redondea o trunca?

En JavaScript, `toFixed(1)` **redondea** (IEEE 754 half-up):

```javascript
(4.366666666666667).toFixed(1)  // "4.4"  ← redondeo
```

En TeacherGradebook, `formatGradeDisplay` aplica **primero** truncamiento:

```javascript
truncateToOneDecimal(4.366666).toFixed(1)  // "4.3"  ← correcto
```

En StudentReport, se usa `toFixed(1)` **sin truncar antes** → violación.

---

## `ToString("0.0")` en C#

```csharp
((decimal)4.3666666666666666666666666667).ToString("0.0")  // "4.4"
```

`"0.0"` usa redondeo del runtime .NET, no truncamiento.

---

## Documentación previa en el repo

El archivo `ANALISIS_TRUNCAMIENTO_NOTAS.md` (2026-05-24) ya documentaba inconsistencias similares en TeacherGradebook (Resumen vs grid). Este análisis **extiende** el hallazgo a **tres roles** con evidencia de producción.

---

## Resumen de cumplimiento de regla

| Módulo | ¿Trunca? | ¿Redondea? | ¿Algoritmo correcto? |
|--------|----------|------------|----------------------|
| Profesor — Registrar Notas | Sí | No | **Sí** |
| Profesor — Resumen API | No | Parcial en UI | **No** |
| Consejera | Solo display | No en display | **No** (fórmula) |
| Portal StudentReport | No | **Sí** | **No** (fórmula + round) |
| PDF / GradebookFinalGradeCalculator | Sí | No | **Sí** |
| Reportes institucionales | Mixto | Math.Round en algunos paths | Parcial |
