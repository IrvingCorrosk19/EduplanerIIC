# 04 — Flujo de la Consejera (tab Consejería)

## Resumen

La consejera ve promedios por materia en la pestaña **Consejería** del TeacherGradebook. El cálculo es **distinto al del profesor**: promedia **todas las actividades** de la materia sin agrupar por tipo.

---

## Cadena de componentes

```
POST /TeacherGradebook/GetCounselorGroupAverages
  └─ TeacherGradebookController.GetCounselorGroupAverages()
       ├─ CounselorAssignmentService.GetCounselorGroupsAsync()  [permiso]
       ├─ StudentService.GetByGroupAndGradeAsync()
       ├─ SubjectAssignmentService.GetByGroupAndGradeAsync()
       └─ StudentActivityScoreService.GetCounselorGroupSubjectAveragesForTrimesterAsync()
            └─ EF: flat AVG de todos los scores por (StudentId, SubjectId)

[Cliente] loadCounselorGroupAverages() → renderCounselorAveragesTable()
       └─ formatGradeDisplay()  [truncamiento solo en presentación]
```

**Autorización:** El usuario debe ser `teacher` con registro activo en `counselor_assignments`.

---

## Archivos clave

| Capa | Archivo |
|------|---------|
| Controller | `Controllers/TeacherGradebookController.cs` — `GetCounselorGroupAverages` (~588–784) |
| Service scores | `Services/Implementations/StudentActivityScoreService.cs` — `GetCounselorGroupSubjectAveragesForTrimesterAsync` (~367–398) |
| Service consejería | `Services/Implementations/CounselorAssignmentService.cs` |
| View + JS | `Views/TeacherGradebook/Index.cshtml` — `loadCounselorGroupAverages`, `renderCounselorAveragesTable` (~4385+) |
| DTO | `Dtos/CounselorSubjectAverageDto.cs` — `AverageScore` (double) |
| DTO request | `Dtos/GetNotesDto.cs` — GroupId, GradeLevelId, Trimester |

**No usa** `GradebookFinalGradeCalculator`.

---

## Consulta EF (SQL equivalente)

```csharp
from score in _context.StudentActivityScores
join activity in _context.Activities on score.ActivityId equals activity.Id
where activity.GroupId == groupId
   && activity.GradeLevelId == gradeLevelId
   && activity.Trimester == trimester
   && subjectSet.Contains(activity.SubjectId)
select { score.StudentId, activity.SubjectId, score.Score }
```

Agregación en memoria:

```csharp
.GroupBy(x => (x.StudentId, x.SubjectId))
.Select(g => new CounselorSubjectAverageDto {
    AverageScore = g.Average(x => (double)x.Score!.Value)
})
```

### Diferencias críticas vs profesor

| Aspecto | Profesor | Consejera |
|---------|----------|-----------|
| Agrupa por tipo de actividad | **Sí** | **No** |
| Trunca promedios por tipo | **Sí** | **No** |
| Regla recuperación → examen | **Sí** | **No** |
| Filtra por TeacherId | **Sí** | **No** (todas las actividades del grupo/materia) |
| Tipo de retorno promedio | JS number | **double** en C# |

---

## Formateo en cliente

```javascript
function formatGradeDisplay(value) {
    return truncateToOneDecimal(value).toFixed(1);
}
// truncateToOneDecimal = Math.floor(numValue * 10) / 10
```

El servidor envía el promedio **sin truncar** (ej. 4.5384615385). El cliente trunca **solo al mostrar** → **4.5**.

---

## Aplicación al caso Mayte Mojica — Matemáticas 1T

```
Suma de 13 scores = 59.0
Promedio plano = 59.0 / 13 = 4.5384615385
Truncado en UI = floor(45.3846…) / 10 = 4.5
```

**Resultado consejera: 4.5** ✓

---

## Comparación directa con profesor (misma materia, mismo trimestre)

| Métrica | Profesor | Consejera |
|---------|----------|-----------|
| Algoritmo | 3 promedios por tipo (truncados) → promedio → truncar | 1 promedio de 13 actividades |
| Valor interno | 4.366666… | 4.5384615385 |
| Mostrado | 4.3 | 4.5 |
| Diferencia | — | **+0.2** en pantalla |

---

## Punto exacto de divergencia

| Etapa | Valor para Mayte / Matemáticas 1T |
|-------|-----------------------------------|
| BD (scores individuales) | Idénticos para ambos roles |
| `GetCounselorGroupSubjectAveragesForTrimesterAsync` | **4.5384615385** (aquí diverge del algoritmo docente) |
| JSON al cliente | 4.5384615385 |
| `formatGradeDisplay` | **4.5** |

**Componente responsable:** `StudentActivityScoreService.GetCounselorGroupSubjectAveragesForTrimesterAsync` — usa **AVG plano** en lugar del algoritmo oficial por tipos.

---

## Endpoints duplicados

La misma lógica existe en:

- `Controllers/TeacherGradebookDuplicateController.cs`
- `Views/TeacherGradebookDuplicate/Index.cshtml`
- `Views/OrientationReport/Index.cshtml` (llama al duplicate)

La deuda se replica en tres vistas.
