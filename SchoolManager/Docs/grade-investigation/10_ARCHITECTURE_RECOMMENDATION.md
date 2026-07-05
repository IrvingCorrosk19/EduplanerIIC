# 10 — Recomendación arquitectónica

> **Nota:** Este documento propone dirección técnica. No implica implementación en esta fase.

---

## Principio rector

**Un algoritmo. Un servicio. Todos los consumidores.**

La nota final trimestral por estudiante/materia/trimestre debe calcularse **exactamente una vez** mediante reglas de negocio centralizadas y exponerse a todas las UIs y reportes.

---

## Servicio canónico propuesto

### `IGradeFinalCalculationService` (nombre sugerido)

**Ubicación sugerida:** `Services/Interfaces/IGradeFinalCalculationService.cs`  
**Implementación:** `Services/Implementations/GradeFinalCalculationService.cs`  
**Delegación interna:** Reutilizar y extender `GradebookFinalGradeCalculator` (ya correcto).

### API pública mínima

```csharp
Task<decimal?> CalculateTrimesterFinalAsync(
    Guid studentId,
    Guid subjectId,
    Guid groupId,
    Guid gradeLevelId,
    string trimester,
    CancellationToken ct = default);

Task<IReadOnlyDictionary<(Guid StudentId, Guid SubjectId), decimal?>> 
    CalculateTrimesterFinalsForGroupAsync(
        Guid groupId,
        Guid gradeLevelId,
        string trimester,
        IReadOnlyCollection<Guid> subjectIds,
        CancellationToken ct = default);

string FormatGradeForDisplay(decimal value); // siempre trunc, nunca round
```

### Algoritmo obligatorio (ya implementado en `GradebookFinalGradeCalculator`)

1. Agrupar actividades por tipo canónico:
   - `notas de apreciación`
   - `ejercicios diarios`
   - `examen final`
   - `recuperación`
2. Por cada tipo con al menos una nota: `avg = mean(scores)` → `TRUNC(avg, 1)`
3. Si existe recuperación con notas: reemplazar promedio de `examen final`
4. Nota final = `TRUNC(mean(promedios de tipos válidos excluyendo recuperación), 1)`
5. Display: formatear valor **ya truncado** (nunca `Round`, nunca `ToString("0.0")` sin truncar)

---

## Migración por consumidor

| Consumidor actual | Cambio requerido |
|-------------------|------------------|
| `TeacherGradebook/Index.cshtml` `calcAverages()` | Llamar API servidor o recibir nota final precalculada en JSON |
| `GetCounselorGroupAverages` | Reemplazar `GetCounselorGroupSubjectAveragesForTrimesterAsync` AVG plano |
| `StudentReport/Index.cshtml` | Eliminar cálculo Razor/JS; mostrar valor del servicio |
| `GetPromediosFinalesAsync` | Delegar en servicio canónico |
| `TeacherGradebookPdfService` | Ya alineado — delegar explícitamente al servicio |
| `ReportesInstitucionalesService` | Eliminar `Math.Round(..., 1)` residual |
| `TeacherGradebookDuplicate`, `OrientationReport` | Misma migración que gradebook principal |

---

## Formato de presentación unificado

### C# (único helper)

```csharp
public static string FormatTruncatedGrade(decimal value)
{
    var t = GradebookFinalGradeCalculator.TruncateOneDecimal(value);
    return t.ToString("0.0", CultureInfo.InvariantCulture); // seguro post-trunc
}
```

### JavaScript (solo si unavoidable — preferir server-side)

```javascript
function formatGradeDisplay(value) {
    return (Math.floor(parseFloat(value) * 10) / 10).toFixed(1);
}
```

**Prohibido en todo el codebase de calificaciones:**
- `Math.round`, `decimal.Round`, `MidpointRounding`
- `ToString("F1")`, `ToString("N1")`, `ToString("0.0")` sobre valores no truncados
- `toFixed(1)` sin truncar antes

---

## Opciones de persistencia (evaluación)

| Opción | Pros | Contras |
|--------|------|---------|
| **A. Cálculo en runtime (servicio único)** | Sin migración BD; siempre actualizado | Costo CPU por request |
| **B. Columna materializada `final_score`** | Lectura rápida; paridad garantizada en BD | Requiere triggers/job al guardar notas |
| **C. Vista SQL / función PostgreSQL** | SSOT en BD | Duplica lógica de recuperación en SQL |

**Recomendación:** Fase 1 = **Opción A** (servicio único C#). Fase 2 opcional = **Opción B** si hay problemas de performance en consejería (matrices grandes).

---

## Tests de regresión obligatorios

Caso de referencia **Mayte Mojica, Matemáticas 1T**:

```csharp
[Fact]
public void Mayte_Matematicas_1T_Final_Is_4_3()
{
    var result = _sut.CalculateTrimesterFinalAsync(
        studentId: Guid.Parse("ec1b5711-58c1-4f16-ad54-0144349ea243"),
        subjectId: Guid.Parse("d4a4e493-dfec-4b8d-812a-dee0338e4ab6"),
        /* group H, grade 7, trimester 1T */);

    Assert.Equal(4.3m, result);
    Assert.Equal("4.3", GradeFormat.Format(result));
}
```

Casos adicionales de truncamiento:

| Input | Expected |
|-------|----------|
| 4.399999 | 4.3 |
| 4.35 | 4.3 |
| 2.966666 | 2.9 |

---

## Lint / CI propuesto

Agregar regla de análisis estático (Roslyn analyzer o grep en CI) que **falle el build** si en archivos de calificaciones aparece:

- `Math.Round` sobre scores
- `ToString("0.0")` en Views de notas
- `.toFixed(1)` sin `Math.floor` previo en gradebook/report views

---

## Aplicabilidad a eduplaner2

El proyecto `C:\Proyectos\eduplaner2\SchoolManager` comparte la misma arquitectura base. La remediación debe aplicarse **en ambos repositorios** o extraer el servicio canónico a un paquete compartido.

---

## Roadmap sugerido (post-análisis)

| Fase | Entrega | Duración estimada |
|------|---------|-----------------|
| 1 | Crear `IGradeFinalCalculationService` + tests con caso Mayte | 2–3 días |
| 2 | Migrar Consejería y StudentReport | 2 días |
| 3 | Migrar TeacherGradebook JS → server | 2–3 días |
| 4 | Migrar GetPromediosFinales + reportes | 2 días |
| 5 | CI lint anti-rounding | 1 día |

**Resultado esperado:** Profesor, Consejera, Padres, Estudiante e informes muestran **4.3** para el caso analizado y valores idénticos en todos los demás casos.
