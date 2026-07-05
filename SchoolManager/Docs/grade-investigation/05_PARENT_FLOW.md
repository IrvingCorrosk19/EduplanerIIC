# 05 — Flujo del Portal de Padres / Estudiante (StudentReport)

## Resumen

El portal titulado **“Portal para Padres”** (`StudentReport/Index`) muestra calificaciones del **usuario autenticado**. No existe flujo separado de “madre de familia” con selección de hijo; la madre vería la nota **iniciando sesión como el estudiante** o mediante la misma vista si comparte credenciales.

**ClubParents** (`/ClubParents/*`) gestiona pagos de carnet/plataforma — **no muestra calificaciones**.

---

## Cadena de componentes

```
GET /StudentReport/Index
  └─ StudentReportController.Index()
       └─ StudentReportService.GetReportByStudentIdAsync(currentUserId)
            └─ EF: student_activity_scores JOIN activities WHERE StudentId
            └─ Map → List<GradeDto> (scores crudos, sin promedio final)
       └─ Views/StudentReport/Index.cshtml
            └─ Razor: cálculo por materia/tipo en servidor (~246–386)
            └─ JS filterAndDisplayGrades(): recálculo en AJAX (~578–733)

GET /StudentReport/GetTrimesterData?studentId=&trimester=
  └─ StudentReportService.GetReportByStudentIdAndTrimesterAsync()
```

---

## Archivos clave

| Capa | Archivo |
|------|---------|
| Controller | `Controllers/StudentReportController.cs` |
| Service | `Services/Implementations/StudentReportService.cs` |
| View | `Views/StudentReport/Index.cshtml` |
| DTO | `Dtos/StudentReportDto.cs`, `Dtos/GradeDto.cs` |

**No usa** `GradebookFinalGradeCalculator`. **No hay** ViewModel de calificaciones ni AutoMapper.

---

## Consulta EF — scores del estudiante

`StudentReportService` filtra:

```csharp
_context.StudentActivityScores
    .Join(_context.Activities, ...)
    .Where(score => score.StudentId == studentId && activity.Trimester == trimester)
```

Características adicionales vs consejera/profesor:

- **Dedup:** `GroupBy(ActivityId, SubjectId, TeacherId, Name)` → toma el más reciente por `CreatedAt`
- **Filtro año académico:** opcional si existe columna `AcademicYearId`
- **Retorna scores individuales** — el promedio final se calcula en la **vista**, no en C#

---

## Algoritmo en Razor (render inicial)

`Views/StudentReport/Index.cshtml` (~260–299):

### Paso 1 — Agrupar por materia

```csharp
var gradesBySubject = Model.Grades
    .Where(g => g.Value.HasValue)
    .GroupBy(g => g.Subject);
```

### Paso 2 — Por cada materia, agrupar por tipo (matching difuso)

```csharp
// Notas de Apreciación: Contains("nota") || Contains("apreciación")
// Ejercicios Diarios: Contains("ejercicio") || Contains("diario")
// Examen Final: Contains("examen") || Contains("final")
var promedio = actividadesTipo.Average(g => g.Value.Value);
promediosTipos.Add(promedio);  // SIN TRUNCAR
```

### Paso 3 — Promedio final de la materia

```csharp
decimal? promedioFinal = promediosTipos.Average();  // SIN TRUNCAR
```

### Paso 4 — Visualización (REDONDEO)

```csharp
promedioFinal.Value.ToString("0.0")   // ← redondeo bancario, NO truncamiento
promedioTipo.ToString("0.0")
actividad.Value.Value.ToString("0.0")
```

### Paso 5 — JavaScript (AJAX al cambiar trimestre)

```javascript
const promedioTipo = actividadesTipo.reduce(...) / actividadesTipo.length;
const promedioFinal = promediosTipos.reduce(...) / promediosTipos.length;
promedioFinal.toFixed(1)  // ← redondeo
```

**No hay regla de recuperación** que reemplace examen final.

---

## Aplicación al caso Mayte Mojica — Matemáticas 1T

| Tipo | Promedio (sin truncar) |
|------|------------------------|
| Notas de Apreciación | 4.833333… |
| Ejercicios Diarios | 4.333333… |
| Examen Final | 4.0 |

```
promedioFinal = (4.833333 + 4.333333 + 4.0) / 3 = 4.366666…
ToString("0.0") → "4.4"  (redondeo)
```

**Resultado portal padres/estudiante: 4.4** ✓

---

## Comparación con profesor (misma materia)

| Paso | Profesor | Portal |
|------|----------|--------|
| Promedio por tipo | Trunca a 1 decimal | **No trunca** |
| Promedio final | Trunca tras promediar tipos | **No trunca** |
| Display | `formatGradeDisplay` (trunc) | **`ToString("0.0")` (round)** |
| Valor mostrado | 4.3 | 4.4 |
| Diferencia | — | **+0.1** |

Aunque ambos usan **agrupación por tipo** (similar estructura), el portal **omite truncamiento** y **aplica redondeo al mostrar**.

---

## Punto exacto de divergencia

| Etapa | Valor |
|-------|-------|
| BD | Scores idénticos |
| `StudentReportService` | Pasa scores crudos; **no calcula nota final** |
| Razor `promediosTipos.Average()` | 4.366666… |
| `ToString("0.0")` | **4.4** ← aquí cambia respecto al profesor |

**Componentes responsables:**

1. Cálculo en vista Razor/JS (lógica duplicada, no centralizada)
2. `ToString("0.0")` y `toFixed(1)` — **violan regla de truncamiento**

---

## Nota sobre “madre de familia”

No se encontró:

- Rol `parent` / `acudiente` en `StudentReportController`
- Lookup padre → hijo en este módulo
- Integración ClubParents → calificaciones

La inconsistencia reportada para “madre de familia” corresponde funcionalmente al módulo **`StudentReport`**, independientemente del rol real del usuario que accede.
