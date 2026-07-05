# 03 — Flujo del Profesor (TeacherGradebook)

## Resumen

El profesor ve la nota final trimestral principalmente en la pestaña **Registrar Notas** del libro de calificaciones (`/TeacherGradebook/Index`), columna **Nota Final**, calculada en **JavaScript del cliente**.

---

## Cadena de componentes

```
GET /TeacherGradebook/Index
  └─ TeacherGradebookController.Index()
       └─ TeacherGradebookViewModel (filtros: trimestres, grupos, materias)
            └─ Views/TeacherGradebook/Index.cshtml

POST /TeacherGradebook/GetNotasCargadas
  └─ TeacherGradebookController.GetNotasCargadas()
       ├─ ActivityService.GetByTeacherGroupTrimesterAsync()
       └─ StudentActivityScoreService.GetNotasPorFiltroAsync()
            └─ EF: student_activity_scores JOIN activities (filtro por teacher, subject, group, grade, trimester)

[Cliente] refreshTable() → calcAverages() → formatGradeDisplay()
```

---

## Archivos clave

| Capa | Archivo | Responsabilidad |
|------|---------|-----------------|
| Controller | `Controllers/TeacherGradebookController.cs` | Endpoints HTTP |
| Service | `Services/Implementations/StudentActivityScoreService.cs` | Consultas EF de scores |
| Helper (PDF/reportes) | `Services/Helpers/GradebookFinalGradeCalculator.cs` | Algoritmo oficial truncado (no usado en grid en vivo) |
| View + JS | `Views/TeacherGradebook/Index.cshtml` | Cálculo y visualización en vivo |
| DTO request | `Dtos/GetNotesDto.cs` | Filtros TeacherId, SubjectId, GroupId, GradeLevelId, Trimester |
| Entity | `Models/StudentActivityScore.cs` | `Score` decimal? |

**No existe** `GradeService`, `TeacherGradebookService` ni Repository dedicado a calificaciones.

---

## Consulta EF — notas crudas

`StudentActivityScoreService.GetNotasPorFiltroAsync`:

```csharp
_context.StudentActivityScores
    .Include(sa => sa.Activity)
    .Include(sa => sa.Student)
    .Where(sa =>
        sa.Activity.TeacherId == notes.TeacherId &&
        sa.Activity.SubjectId == notes.SubjectId &&
        sa.Activity.GroupId == notes.GroupId &&
        sa.Activity.GradeLevelId == notes.GradeLevelId &&
        sa.Activity.Trimester == notes.Trimester)
```

Las notas se devuelven como `NotaDetalleDto.Nota` con `Score.ToString("0.00")` (2 decimales en transporte, sin truncamiento de nota final).

---

## Algoritmo de nota final (pestaña Registrar Notas)

Función **`calcAverages()`** en `Index.cshtml` (~líneas 2177–2236):

### Paso 1 — Promedio por tipo de actividad

Tipos considerados (en orden):

1. `notas de apreciación`
2. `ejercicios diarios`
3. `examen final`
4. `recuperación`

Para cada tipo con celdas con valor:

```
avg = suma / cantidad
truncAvg = Math.floor(avg * 10) / 10
```

### Paso 2 — Regla de recuperación

Si hay notas en `recuperación`, reemplaza el promedio de `examen final`:

```javascript
if (typeHasScores['recuperación']) {
    typeAvgs['examen final'] = typeAvgs['recuperación'];
}
```

### Paso 3 — Nota final trimestral

Promedio de los promedios truncados de los tipos que tienen al menos una nota (excluyendo `recuperación` del promedio final):

```
finalGrade = mean(typeAvgs[t] for t in typesWithScores, t != 'recuperación')
truncFinalGrade = Math.floor(finalGrade * 10) / 10
```

### Paso 4 — Visualización

```javascript
function truncateToOneDecimal(value) {
    return Math.floor(numValue * 10) / 10;
}
function formatGradeDisplay(value) {
    return truncateToOneDecimal(value).toFixed(1);
}
```

`toFixed(1)` aquí **no redondea** porque opera sobre un valor ya truncado.

---

## Aplicación al caso Mayte Mojica — Matemáticas 1T

| Tipo | Promedio raw | Truncado |
|------|--------------|----------|
| notas de apreciación | 4.8333… | **4.8** |
| ejercicios diarios | 4.3333… | **4.3** |
| examen final | 4.0 | **4.0** |

```
finalGrade = (4.8 + 4.3 + 4.0) / 3 = 4.366666…
truncFinalGrade = floor(43.666…) / 10 = 4.3
```

**Resultado profesor: 4.3** ✓

---

## Otras pestañas del mismo módulo (inconsistencias internas)

| Pestaña | Endpoint | Algoritmo | ¿Trunca? |
|---------|----------|-----------|----------|
| Registrar Notas | GetNotasCargadas + calcAverages | Por tipo + trunc | **Sí** |
| Promedios Finales / Resumen | GetPromediosFinales | Promedio plano por tipo sin truncar | **No** (servidor) |
| Consejería | GetCounselorGroupAverages | Promedio plano total | **No** (distinto algoritmo) |
| PDF | ExportRegistroPdf | GradebookFinalGradeCalculator | **Sí** |

El profesor puede ver **valores distintos** según la pestaña que consulte; para el caso reportado, la referencia **4.3** corresponde al algoritmo de **Registrar Notas** (columna Nota Final).

---

## Punto donde la nota “cambia” respecto a otros roles

La divergencia **no ocurre en la BD ni en el Controller del profesor**. Ocurre porque:

1. El profesor usa **agrupación por tipo + doble truncamiento**.
2. Otros roles usan **otros algoritmos** (documentados en fases 04 y 05).

El servicio `GetPromediosFinalesAsync` (pestaña Resumen) tampoco usa `GradebookFinalGradeCalculator`, lo que genera deuda técnica adicional dentro del mismo módulo docente.
