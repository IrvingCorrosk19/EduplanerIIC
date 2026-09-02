# RESULTADO DE IMPLEMENTACIÓN — Corrección TeacherGradebook vs PDF

**Estado:** consolidado y ampliado en [`RESULTADO_CORRECCION_TEACHER_GRADEBOOK_EXPORTACIONES.md`](RESULTADO_CORRECCION_TEACHER_GRADEBOOK_EXPORTACIONES.md) (PDF + Excel).

El contenido histórico de la corrección del PDF permanece en las secciones siguientes.

---


**Fecha:** 1 de septiembre de 2026  
**Rama:** `main`  
**HEAD previo:** `bd5bd24`  
**Commit / push / despliegue:** no realizados  

---

## 1. Resumen ejecutivo

El PDF de **Imprimir PDF** en `/TeacherGradebook/Index` dejó de reconstruir el registro con `GetGradeBookAsync` y de compactarlo con `Scale`. Ahora:

- Las columnas salen de la **misma consulta** que la pantalla: `ActivityService.GetByTeacherGroupTrimesterAsync` (`SchoolId` + `TrimesterId`).
- Se aplica la **misma regla de columnas** que el JavaScript de Index (tipos fijos, orden, deduplicación por tipo+nombre).
- Los promedios y la nota final usan `GradebookFinalGradeCalculator` (truncamiento a un decimal, sin redondeo).
- QuestPDF pagina por **bloques de tipo** (y subbloques si hay demasiadas actividades), con Estudiante y Cédula repetidos, fuente mínima **8 pt**, sin `Scale`.

La vista web, el guardado de notas y los demás PDF no se modificaron.

---

## 2. Causas corregidas

| Causa (análisis) | Corrección |
|---|---|
| PDF usaba `GetGradeBookAsync` sin `SchoolId`/`TrimesterId` | `IActivityService.GetByTeacherGroupTrimesterAsync` + predicado `GradebookActivityScope` |
| Una columna por `Activity.Id`; la web deduplica por nombre | `GradebookVisibleActivitySelector` (primera aparición por `CreatedAt`, alias para la nota) |
| Tipos no admitidos por la UI | Solo los 4 tipos de `activeTypes` |
| `Scale(max(0.55, 14/totalCols))` y fuente 5–7 pt | Eliminado. Fuente 8 pt. `ConstantColumn` según ancho A4 landscape |
| Todo en una composición horizontal | Un `Page` QuestPDF por bloque de tipo / subbloque |

---

## 3. Archivos modificados

**Nuevos**

- `SchoolManager/Services/Helpers/GradebookActivityScope.cs`
- `SchoolManager/Services/Helpers/GradebookVisibleActivitySelector.cs`
- `SchoolManager/Services/Helpers/GradebookPdfLayout.cs`
- `SchoolManager/Services/Implementations/GradebookPdfRenderer.cs`
- `SchoolManager.Tests/` (proyecto xUnit + pruebas)
- `artifacts/gradebook-pdf/Registro_Calificaciones_1T_corregido.pdf` (fixture, no producción)
- `RESULTADO_CORRECCION_TEACHER_GRADEBOOK_PDF.md` (este archivo)

**Modificados**

- `SchoolManager/Services/Implementations/TeacherGradebookPdfService.cs` (fuente de datos + tenant + renderer)
- `SchoolManager/Services/Implementations/ActivityService.cs` (usa el predicado canónico)
- `SchoolManager/Services/Helpers/GradebookFinalGradeCalculator.cs` (`TruncatedAverageOrZero`, `HasAnyScore`)
- `SchoolManager/Dtos/GradebookPdfDto.cs` (`AliasIds`)
- `SchoolManager/Docs/grade-investigation/03_TEACHER_FLOW.md` (el PDF sí usa el helper)
- `SchoolManager.sln`

**No modificados (a propósito)**

- `Views/TeacherGradebook/Index.cshtml` (CSS y `calcAverages`)
- `StudentActivityScoreService.GetGradeBookAsync` (sigue en `GradeBookJson` y `TeacherGradebookDuplicateController`)
- Otros servicios QuestPDF
- Migraciones / base de datos

---

## 4. Fuente canónica de actividades

1. Resolver colegio del usuario autenticado (`ICurrentUserService.GetCurrentUserSchoolAsync`). Obligatorio.
2. Comprobar `TeacherAssignments` para docente + grupo + materia + grado, con `SubjectAssignment.SchoolId` nulo o igual al colegio actual.
3. **`IActivityService.GetByTeacherGroupTrimesterAsync`** — la misma API que `GetNotasCargadas`.
4. El predicado EF extraído a `GradebookActivityScope.VisibleOnTeacherGradebookIndex`:

   `TeacherId`, `GroupId`, `SubjectId`, `GradeLevelId`, `SchoolId`, `TrimesterId`, código de trimestre.

5. `GradebookVisibleActivitySelector.SelectVisibleColumns` sobre esa lista ya ordenada por `CreatedAt`.

`GetGradeBookAsync` **no** se alteró de forma global.

---

## 5. Filtros multitenant aplicados

| Recurso | Filtro |
|---|---|
| Actividades | `SchoolId` del usuario + `TrimesterId` del trimestre de **ese** colegio |
| Asignación docente | terna académica y `SubjectAssignment.SchoolId` |
| Calificaciones | `ActivityId` ∈ columnas lógicas y `SchoolId` nulo o del colegio |
| Estudiantes | lista del grupo/materia y `Users.SchoolId` nulo o del colegio |
| Encabezado | nombre y logo del colegio del usuario, no `UtcNow.Year` a ciegas |

Una actividad de otro colegio con el mismo texto `1T` **no** pasa el predicado (`SchoolId` y `TrimesterId` distintos). Cubierto en `GradebookActivityScopeTests`.

---

## 6. Trimestre y año académico

El código `1T`/`2T`/`3T` no basta. Se resuelve el trimestre con `Name + SchoolId` (igual que la vista) y se exige `Activity.TrimesterId == trimestre.Id`.

Quedan fuera:

- otro `TrimesterId` con el mismo texto;
- `TrimesterId = null` (la web también las excluye);
- actividades de otro colegio.

**Limitación (sin migración):** `Activity` no tiene `AcademicYearId`. El aislamiento de año lectivo es el de la vista: el `TrimesterId` vigente de la escuela. Si existen varios registros `1T` para la misma escuela, `FirstOrDefault` es el mismo criterio ambiguo de Index.

**Encabezado “Año lectivo”:** `trimester.AcademicYear.Name`, y si falta, `IAcademicYearService.GetActiveAcademicYearAsync(schoolId)`. **Ya no** se usa `DateTime.UtcNow.Year` como valor académico.

---

## 7. Regla de duplicados

Comportamiento real de Index (`loadNotasCargadas`):

- Recorre las actividades en orden `CreatedAt` (servidor) por cada estudiante.
- Columna: primer `tipo.toLowerCase()` + `name ===` (igualdad estricta, sin trim del nombre).
- Nota: el JSON repite el `FirstOrDefault` por nombre; el JS sobrescribe la misma clave. En la práctica hay **una celda por nombre**.

En servidor:

- Clave lógica: `NormalizeType(type) + "\n" + Name` (nombre exacto).
- Se conserva el **primer** `Id` (`CreatedAt`).
- `AliasIds` guarda los duplicados posteriores.
- `ResolveScore` usa primero el Id conservado; si está vacío, el primer alias con valor (para no perder una nota que la UI podría mostrar por nombre).

No se borró ni se migró nada en base de datos.

---

## 8. Regla de truncamiento

`GradebookFinalGradeCalculator`:

- `TruncateOneDecimal` = `Math.Floor(value * 10) / 10` (4.59 → 4.5, nunca 4.6).
- Celdas vacías = `null` (se muestran `-`).
- `0.0` tiene valor y entra al promedio.
- Recuperación: sustituye el promedio de examen en el cálculo final, con la misma restricción que `calcAverages` (el examen solo entra al final si ese tipo tiene notas propias).

El PDF ya no duplica `ComputeFinalGrade` local.

---

## 9. Diseño de paginación horizontal

A4 apaisado, márgenes 20 pt. Ancho útil ≈ 801.9 pt.

| Columna | Ancho (pt) |
|---|---|
| # | 22 |
| Nombre | 148 |
| Cédula | 74 |
| Cada actividad | 40 |
| Promedio de tipo | 46 |
| Nota final | 50 |

`SafeActivityChunkSize` = máximo de actividades que caben junto a identidad + promedio + nota final (**11** con estas medidas). Justificado por aritmética de página, no por un número mágico suelto.

Orden de bloques:

1. Apreciación  
2. Ejercicios (subbloques `Bloque N de M` si hace falta)  
3. Examen  
4. Recuperación  

En cada página/bloque se repiten `#`, Nombre y Cédula. El promedio del tipo va en el **último** subbloque y se etiqueta `(completo)` cuando hay más de un subbloque (no es el promedio parcial del bloque). La nota final va en el último bloque del último tipo.

Paginación vertical: QuestPDF parte filas de estudiantes y repite el encabezado de tabla. El encabezado institucional va en `page.Header` de cada plantilla de bloque.

---

## 10. Tamaño mínimo de fuente

**8 pt** (`GradebookPdfLayout.MinFontSize` / `BodyFontSize`). Título 13 pt. No hay `Scale`.

---

## 11. Pruebas creadas

Proyecto `SchoolManager.Tests` (31 pruebas):

- Alcance tenant / trimestre / `TrimesterId` null / histórico `1T`
- Selector: tipos de la vista, orden, dedup, nombre case-sensitive, tipos legado
- Truncamiento, 0.0 vs vacío, recuperación, nota final
- Capacidad de bloque, 0/1/15/30 actividades, promedio solo al final del tipo
- Renderer: 0 actividades, 1, límite, límite+1, 15, 30, 40 estudiantes, nombres largos, con/sin logo, con/sin recuperación, sin `.Scale(` en el fuente, artefactos PNG/PDF

No hay prueba de integración HTTP contra PostgreSQL de producción (prohibido escribir; no hay credenciales de lectura en esta fase).

---

## 12. Comandos ejecutados

```text
dotnet restore SchoolManager.sln
dotnet build SchoolManager.sln
dotnet test SchoolManager.sln
dotnet test SchoolManager.Tests/SchoolManager.Tests.csproj --filter FullyQualifiedName~Generate_WritesCorrectedArtifactPdfAndPageImages
```

Sin `git commit`, `git push`, `git reset`, `git clean`, ni despliegue.

---

## 13. Resultados de build y tests

| Comando | Resultado |
|---|---|
| `dotnet build SchoolManager.sln` | 0 errores. 1 advertencia MSB3277 (conflicto EF Relational 9.0.1 vs 9.0.3 **solo en el proyecto de pruebas**, preexistente por el Web SDK). |
| `dotnet test SchoolManager.sln` | **31 passed, 0 failed** |

No había suite xUnit previa en la solución; no hay regresiones de pruebas antiguas de este módulo.

---

## 14. Comparación antes / después

| Aspecto | Antes | Después |
|---|---|---|
| Actividades | `GetGradeBookAsync` | `GetByTeacherGroupTrimesterAsync` |
| Tenant | No en el libro PDF | `SchoolId` + `TrimesterId` |
| Columnas | Un `Id` por fila | Igual que Index (tipo + nombre) |
| Layout | `Scale` ≥ 0.55, 5–7 pt, 1 página | Bloques, 8 pt, sin Scale |
| Cálculo | Copia local | `GradebookFinalGradeCalculator` |
| Año lectivo | `UtcNow.Year` | Año académico del trimestre o activo |
| Marca de agua | 64 pt gris | 28 pt `#f1f5f9` |

---

## 15. Evidencias visuales del PDF corregido

Generadas con fixture (no dump de producción) equivalente al escenario pedido:

- Instituto Profesional y Técnico San Miguelito  
- Docente GERTRUDIS KIRTON WINTER  
- Materia CÍVICA · Grupo 9 G · Trimestre 1T  

Rutas:

- `c:\Proyectos\eduplaner\artifacts\gradebook-pdf\Registro_Calificaciones_1T_corregido.pdf`
- `c:\Proyectos\eduplaner\artifacts\gradebook-pdf\pagina_01.png` … `pagina_05.png`

Inspección de las páginas:

- Pág. 1: Apreciación + promedio; Abadía 3.5–3.8 → **3.6** (truncado, no 3.7).
- Pág. 2: Ejercicios bloque 1 de 2; Estudiante y Cédula repetidos; Alvarado tiene `-` en Ejerc.1 (vacío ≠ 0.0).
- Pág. 3: Ejercicios bloque 2 + **Prom. Ejerc. (completo)** del tipo entero (no el subconjunto del bloque).
- Pág. 5: Recuperación + nota final en verde.

La captura y el PDF reales de producción **no estaban en el workspace**. El vacío inferior con 12 alumnos en A4 apaisado es papel sin usar (pocas filas), no un `Scale` que encoja la tabla.

---

## 16. Riesgos pendientes

1. Validación contra el PDF/captura reales de IPT San Miguelito en un entorno con datos de solo lectura.
2. Si una escuela tiene **varios** `trimesters` con `Name = 1T`, web y PDF siguen el mismo `FirstOrDefault` (deuda previa del calendario).
3. Prueba automatizada de “docente sin asignación” no levanta `SchoolDbContext` InMemory (extensiones PostgreSQL). El `UnauthorizedAccessException` permanece en el servicio.
4. Advertencia MSB3277 del proyecto de tests (no afecta el runtime de SchoolManager).
5. `GetGradeBookAsync` sigue existiendo para `GradeBookJson` (código muerto en Index) y el controlador duplicado.

---

## 17. Estado final de Git

Sin commit. Working tree con archivos nuevos/modificados de la corrección más `ANALISIS_TEACHER_GRADEBOOK_VS_PDF.md` (fase anterior) y artefactos de prueba.

---

## 18. Confirmación de que no se desplegó

No se desplegó a VPS ni producción. No hay `commit` ni `push`.
