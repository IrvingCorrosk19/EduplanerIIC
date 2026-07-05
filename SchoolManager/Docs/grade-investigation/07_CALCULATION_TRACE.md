# 07 — Trazabilidad del cálculo (cadena completa)

## Diagrama de flujo — Mayte Mojica, Matemáticas 1T

```
┌─────────────────────────────────────────────────────────────────┐
│ PostgreSQL: student_activity_scores.score (numeric 2,1)         │
│ 13 filas: apreciación(6) + ejercicios(6) + examen(1)            │
│ Suma = 59.0 — Sin nota final almacenada                         │
└────────────────────────────┬────────────────────────────────────┘
                             │
         ┌───────────────────┼───────────────────┐
         ▼                   ▼                   ▼
   PROFESOR              CONSEJERA            PORTAL
         │                   │                   │
   GetNotasCargadas   GetCounselorGroup   GetReportByStudentId
         │              Averages                  │
         │                   │                   │
   13 scores JSON      AVG(13 scores)      13 scores → GradeDto
   sin agregar         = 4.5384615385      sin agregar
         │                   │                   │
   calcAverages()          │              Razor Average()
   por tipo:               │              por tipo:
   4.8, 4.3, 4.0           │              4.833, 4.333, 4.0
         │                   │                   │
   mean → 4.3666…           │              mean → 4.3666…
   TRUNC → 4.3              │                   │
         │              TRUNC display            │
         │              → 4.5                 ROUND 0.0
         │                   │              → 4.4
         ▼                   ▼                   ▼
      Muestra 4.3        Muestra 4.5        Muestra 4.4
```

---

## Trazabilidad valor por valor — nota final Matemáticas 1T

| # | Capa | Profesor | Consejera | Portal |
|---|------|----------|-----------|--------|
| 1 | BD score individual | 5.0, 4.5, … (13 valores) | Idéntico | Idéntico |
| 2 | Transporte API | JSON crudo por actividad | `AverageScore: 4.5384615385` | `GradeDto.Value` crudo |
| 3 | Agregación | JS: 3 tipos truncados | C#: AVG plano | Razor: 3 tipos sin truncar |
| 4 | Valor pre-display | 4.366666… (interno JS) | 4.5384615385 | 4.366666… |
| 5 | Formato display | `formatGradeDisplay` (trunc) | `formatGradeDisplay` (trunc) | `ToString("0.0")` (round) |
| 6 | **Pantalla** | **4.3** | **4.5** | **4.4** |

---

## Punto exacto donde cambia 4.3 → 4.5 (Profesor vs Consejera)

**Capa:** `StudentActivityScoreService.GetCounselorGroupSubjectAveragesForTrimesterAsync`  
**Líneas:** ~389–397 en `StudentActivityScoreService.cs`

```csharp
AverageScore = g.Average(x => (double)x.Score!.Value)
```

Este `Average` incluye las 13 actividades por igual, en lugar de:

1. Promediar por tipo
2. Truncar cada tipo
3. Promediar tipos
4. Truncar final

**Delta numérico:** 4.5384615385 − 4.3666666667 = **0.1717948718** → **0.2** visible tras truncar ambos.

---

## Punto exacto donde cambia 4.3 → 4.4 (Profesor vs Portal)

**Capa 1 — Cálculo:** `Views/StudentReport/Index.cshtml` ~282–299

```csharp
var promedio = actividadesTipo.Average(g => g.Value.Value);  // sin truncar
decimal? promedioFinal = promediosTipos.Average();           // sin truncar
```

**Capa 2 — Display:** ~372

```csharp
@promedioFinal.Value.ToString("0.0")  // REDONDEO a 4.4
```

El valor interno 4.366666… truncado sería **4.3** (como profesor), pero el portal **redondea** a **4.4**.

**Delta numérico:** 4.4 − 4.3 = **0.1**

---

## Servicios de cálculo identificados en el codebase

| Servicio / Helper | Usado por Profesor grid | Consejera | Portal | PDF/Reportes |
|-------------------|-------------------------|-----------|--------|--------------|
| `GradebookFinalGradeCalculator` | No (solo JS mirror) | No | No | **Sí** |
| `calcAverages()` JS | **Sí** | No | No | No |
| `GetCounselorGroupSubjectAveragesForTrimesterAsync` | No | **Sí** | No | No |
| Razor `Average()` en StudentReport | No | No | **Sí** |
| `GetPromediosFinalesAsync` | Resumen tab | No | No | No |
| `ReportesInstitucionalesBulkLoader.CalcularNotaFinal` | No | No | No | Informes institucionales |
| `AprobadosReprobadosService` | No | No | No | Reportes aprobados |

**Mínimo 4 implementaciones distintas** del concepto “nota final trimestral”.

---

## JavaScript en pantalla — Profesor y Consejera

Ambos comparten en `TeacherGradebook/Index.cshtml`:

```javascript
function truncateToOneDecimal(value) {
    const numValue = parseFloat(value);
    if (isNaN(numValue)) return 0;
    return Math.floor(numValue * 10) / 10;
}
```

La consejera trunca **después** de recibir un promedio ya calculado con algoritmo incorrecto. El truncamiento de display **no corrige** el algoritmo upstream.

---

## Regla de aprobación (>= 3.0)

Los tres módulos usan umbral **3.0** para colorear aprobado/reprobado, pero sobre **valores distintos**, lo que puede causar inconsistencias de estado además de la nota mostrada (no evaluado en detalle para este caso, donde todos los valores > 3.0).
