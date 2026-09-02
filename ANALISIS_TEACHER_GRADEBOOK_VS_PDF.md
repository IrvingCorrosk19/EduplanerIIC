# ANÁLISIS FORENSE — TeacherGradebook (vista web) vs PDF de calificaciones

**Fecha:** 1 de septiembre de 2026  
**Repositorio:** `EduplanerIIC` · rama `main` · HEAD `bd5bd24`  
**Alcance:** solo diagnóstico. No se modificó código funcional, no se alteró la base de datos, no hubo commit ni despliegue.  
**Librería PDF:** QuestPDF 2025.12.3 (generación nativa; no HTML, no `window.print`, no captura de DOM).  
**Limitación de evidencias externas:** en el workspace clonado **no está** el archivo `Registro_Calificaciones_1T.pdf` ni la captura de `/TeacherGradebook/Index`. El análisis se basa en el código, el historial Git y la descripción del síntoma. Las muestras nominales de estudiantes (Abadía, Agrazal, etc.) **no pudieron cotejarse contra datos reales**.

---

## 1. Resumen ejecutivo

La vista `/TeacherGradebook/Index` **no imprime el DOM**. El botón **Imprimir PDF** abre un endpoint independiente (`GET /TeacherGradebook/ExportRegistroPdf`) que reconstruye el registro con **QuestPDF** en una plantilla propia.

El síntoma visual (tabla minúscula, una sola página A4 horizontal, gran vacío inferior, tipografía ilegible) **está demostrado en código** y no es un efecto de CSS de pantalla ni de `@media print`.

`TeacherGradebookPdfService.BuildPdf` (commit `4d5bd7a`, 31/05/2026) fuerza **todas las columnas de actividad en una sola página** mediante:

1. columnas `RelativeColumn` que comprimen el ancho disponible;
2. reducción de `fontSize` a 5–7 pt según el recuento de columnas;
3. `Scale(scale)` con `scale = max(0.55, 14 / totalCols)` cuando hay más de 14 columnas.

`Scale` reduce a la vez el **ancho y la altura ocupada** por la tabla. El pie (`page.Footer`) permanece al borde inferior. Resultado: franja superior diminuta y espacio vacío debajo. Ese commit se tituló *“ajustar columnas PDF para evitar overflow QuestPDF”*: el overflow se evitó **encogiendo el contenido**, no paginándolo.

Además, **la fuente de columnas no es la misma que la de la tabla visible**:

| Superficie | Origen de actividades | Filtros extra |
|---|---|---|
| Vista web | `POST /TeacherGradebook/GetNotasCargadas` → `ActivityService.GetByTeacherGroupTrimesterAsync` | `SchoolId` + `TrimesterId` del trimestre de la escuela actual |
| PDF | `GET /TeacherGradebook/ExportRegistroPdf` → `StudentActivityScoreService.GetGradeBookAsync` | **No** filtra `SchoolId` ni `TrimesterId`; solo `TeacherId + GroupId + Trimester (texto) + SubjectId + GradeLevelId` |

La web, además, **deduplica columnas por nombre** en JavaScript. El PDF pinta **una columna por cada `Activity.Id`**.

Conclusión:

- **Causa raíz visual (confirmada):** algoritmo de compactación QuestPDF (`RelativeColumn` + `fontSize` dinámico + `Scale`) sobre A4 landscape, una sola composición, sin paginación horizontal.
- **Causa raíz estructural (confirmada como divergencia de diseño; magnitud de filas extra pendiente de BD):** el PDF no reutiliza el modelo ni la consulta de la vista; incluye todas las actividades de `GetGradeBookAsync`.
- **Ilusión de “más columnas” (confirmada):** la web usa scroll horizontal (`overflow-x: auto`, columnas de 122 px). Una captura típica muestra un recorte; el PDF muestra el conjunto completo a la vez.

---

## 2. Descripción del problema

En `/TeacherGradebook/Index` el registro es legible: Estudiante, Cédula, actividades de apreciación, promedio, ejercicios, promedio, examen, promedio, nota final. El usuario se desplaza horizontalmente si hay muchas actividades.

Al pulsar **Imprimir PDF** se descarga `Registro_Calificaciones_{trimestre}.pdf` (p. ej. `Registro_Calificaciones_1T.pdf`) con:

- muchas más columnas aparentes;
- todo en **una página A4 horizontal**;
- encabezados, nombres, cédulas y notas extremadamente pequeños;
- tabla en una franja superior y **gran vacío inferior**;
- marca de agua institucional grande;
- estructura de columnas que no coincide visualmente con la tabla de pantalla.

El problema **no es** `window.print` ni CSS de impresión de la vista (el único `@media print` del Index oculta el ícono de estudiante inclusivo).

---

## 3. Evidencias analizadas

| Evidencia | Resultado |
|---|---|
| Código de `Index.cshtml` (botón y AJAX) | Confirmado: `window.open` a `ExportRegistroPdf` |
| `TeacherGradebookController.ExportRegistroPdf` | Confirmado: `File(..., "Registro_Calificaciones_{safeTrim}.pdf")` |
| `TeacherGradebookPdfService` | Confirmado: QuestPDF, A4 landscape, `Scale`, marca de agua 64 pt |
| `GetGradeBookAsync` vs `GetByTeacherGroupTrimesterAsync` | Confirmado: filtros distintos |
| Deduplicación JS por `a.name` | Confirmado: líneas 2299–2307 de `Index.cshtml` |
| `loadGradeBook` / `GradeBookJson` | Definido pero **nunca invocado** desde el Index |
| CSS `#gradebook` scroll + `width: max-content` | Confirmado: la web no comprime columnas al viewport |
| Historial Git | Feature `2b2c818` (31/05/2026); compactación `4d5bd7a` el mismo día |
| PDF adjunto / captura | **No presentes en el workspace** |
| Consulta a BD de producción | **No ejecutada** (fase de solo análisis; se evitó tocar datos reales) |
| Nombres de muestra (Abadía, Agrazal, …) | **No encontrados** en el código ni en SQL del repo |

---

## 4. Arquitectura actual del flujo

La pantalla `Index` es un cascarón MVC: filtros, formulario de actividades y una tabla vacía que **JavaScript rellena**. El PDF es un **reporte servidor** que no lee el DOM ni el objeto `activities` del navegador.

```
Navegador                         Servidor
─────────                         ────────
GET /TeacherGradebook/Index  →    TeacherGradebookController.Index
                                  ViewModel: filtros, TeacherId
                                  Vista: Index.cshtml (tabla vacía)

Cambio de grupo/trimestre    →    StudentsByGroupAndGrade
                             →    POST GetNotasCargadas
                                  → ActivityService.GetByTeacherGroupTrimesterAsync
                                  → StudentActivityScoreService.GetNotasPorFiltroAsync
                             ←    JSON notas + ids de actividad
                                  JS: dedup por nombre, refreshTable(), calcAverages()

Clic Imprimir PDF            →    GET ExportRegistroPdf?groupId&trimester&subjectId&gradeLevelId
                                  TeacherGradebookPdfService.GenerateRegistroPdfAsync
                                  → validación TeacherAssignments
                                  → GetGradeBookAsync  (OTRA consulta)
                                  → GetBySubjectGroupAndGradeAsync (estudiantes)
                                  → StudentActivityScores por ActivityId
                                  → GradebookPdfDto
                                  → QuestPDF BuildPdf (A4 landscape + Scale)
                             ←    application/pdf  Registro_Calificaciones_{trimestre}.pdf
```

No intervienen Rotativa, DinkToPdf, iText, wkhtmltopdf, Puppeteer, Playwright, jsPDF ni html2canvas en este flujo.

---

## 5. Diagrama del recorrido completo

```text
/TeacherGradebook/Index
        │  TeacherGradebookController.Index  (L297–361)
        │  TeacherGradebookViewModel
        │  Views/TeacherGradebook/Index.cshtml
        ↓
Botón #btnExportRegistroPdf  (L881–883)
        ↓
Evento jQuery click  (L2703–2716)
        │  Valida #selGroup y #selTrimester
        │  Parsea combo: subjectId|groupId|gradeLevelId
        │  window.open(url)
        ↓
GET /TeacherGradebook/ExportRegistroPdf
    ?groupId=&trimester=&subjectId=&gradeLevelId=
        ↓
TeacherGradebookController.ExportRegistroPdf  (L377–403)
        │  teacherId = GetTeacherId()  (claim NameIdentifier)
        │  NO reenvía el TeacherId del combo; usa el usuario autenticado
        ↓
ITeacherGradebookPdfService.GenerateRegistroPdfAsync
        ↓
TeacherGradebookPdfService.BuildModelAsync  (L78–179)
        │  1. TeacherAssignments (autorización)
        │  2. GetGradeBookAsync → cabeceras Activity
        │  3. GetBySubjectGroupAndGradeAsync → estudiantes
        │  4. Users / Subjects / Groups / GradeLevels / Schools (encabezado)
        │  5. StudentActivityScores WHERE ActivityId IN (...)
        │  6. Promedios TruncateOneDecimal + ComputeFinalGrade
        ↓
GradebookPdfDto  (TypeSections + Students)
        ↓
BuildPdf  (L221–257)
        │  PageSizes.A4.Landscape()
        │  totalCols = 3 + actividades + secciones + 1
        │  fontSize 5|6|7 · scale max(0.55, 14/totalCols)
        │  Background watermark 64pt
        │  Header + Table.Scale(scale) + Footer
        ↓
QuestPDF Document.GeneratePdf() → byte[]
        ↓
File(pdfBytes, application/pdf, Registro_Calificaciones_{trimester}.pdf)
```

---

## 6. Inventario de archivos involucrados

| Archivo | Clase / símbolo | Líneas (aprox.) | Responsabilidad | ¿Participa en el problema? |
|---|---|---|---|---|
| `SchoolManager/Views/TeacherGradebook/Index.cshtml` | `#btnExportRegistroPdf`, `refreshTable`, `loadNotasCargadas`, `calcAverages` | 881–883, 1844–1923, 2271–2336, 2177–2236, 2703–2716 | UI, columnas visibles, promedios en vivo, disparo del PDF | Sí: define qué ve el usuario; no genera el PDF |
| `SchoolManager/Controllers/TeacherGradebookController.cs` | `Index`, `GetNotasCargadas`, `StudentsByGroupAndGrade`, `GradeBookJson`, `ExportRegistroPdf` | 139–208, 212–227, 297–361, 368–375, 377–403 | Orquesta web vs PDF | Sí: PDF y web usan actions distintas |
| `SchoolManager/Services/Implementations/TeacherGradebookPdfService.cs` | `GenerateRegistroPdfAsync`, `BuildModelAsync`, `BuildPdf`, `BuildTable`, `ComputeFinalGrade` | 49–498 | Modelo + layout QuestPDF | **Sí — núcleo visual y estructural** |
| `SchoolManager/Services/Interfaces/ITeacherGradebookPdfService.cs` | contrato | 5–13 | DI | No |
| `SchoolManager/Dtos/GradebookPdfDto.cs` | DTOs del PDF | 1–40 | Secciones por tipo + filas | Sí: 1 col por Activity.Id |
| `SchoolManager/Services/Implementations/StudentActivityScoreService.cs` | `GetGradeBookAsync`, `GetNotasPorFiltroAsync` | 83–156, 309–366 | Consultas de libro y notas | **Sí — filtros del PDF más laxos** |
| `SchoolManager/Services/Implementations/ActivityService.cs` | `GetByTeacherGroupTrimesterAsync`, `DeleteAsync` | 222–272, 338–363 | Actividades de la **vista** | Sí: web más estricta (`SchoolId`, `TrimesterId`) |
| `SchoolManager/Services/Implementations/StudentService.cs` | `GetBySubjectGroupAndGradeAsync` | 82–111 | Lista de estudiantes (web y PDF) | Alineado |
| `SchoolManager/Services/Helpers/GradebookFinalGradeCalculator.cs` | helper oficial | 1–101 | Truncamiento / nota final | **No lo llama el PDF** (duplica lógica propia) |
| `SchoolManager/ViewModels/TeacherGradebookViewModel.cs` | VM Index | 1–19 | Filtros iniciales | No define columnas |
| `SchoolManager/Dtos/GradeBookDto.cs` / `ActivityHeaderDto.cs` / `GetNotesDto.cs` | DTOs | — | Transporte | Sí |
| `SchoolManager/Models/Activity.cs` | entidad | 1–61 | Sin `IsDeleted` / `IsActive` / `IsHidden` | Eliminación física |
| `SchoolManager/Models/SchoolDbContext.cs` | `idx_activities_unique_lookup` | 153 | Índice **no único** | Duplicados de nombre posibles |
| `SchoolManager/Program.cs` | DI | 289 | `AddScoped<ITeacherGradebookPdfService, …>` | No |
| `SchoolManager/SchoolManager.csproj` | paquete | 32 | `QuestPDF` 2025.12.3 | Sí (motor) |
| `SchoolManager/Services/Implementations/TrimesterService.cs` | `GetAllAsync`, `EliminarTodosLosTrimestresAsync` | 23–63, 246–274 | Combo de trimestre; al borrar trimestres pone `Activity.TrimesterId = null` | Contribuye a divergencia PDF vs web |

`loadGradeBook` en `Index.cshtml` (L2724–2741) llama a `GradeBookJson` (misma consulta que el PDF) pero **no hay ninguna invocación** a `loadGradeBook(`. Es código muerto. La tabla visible **nunca** se alimenta de `GetGradeBookAsync`.

---

## 7. Comparación entre vista web y PDF

| Aspecto | Vista web | PDF | Coincide |
|---|---|---|---|
| Tecnología de render | HTML + CSS + JS en el navegador | QuestPDF nativo (no HTML) | No |
| Endpoint de datos | `POST GetNotasCargadas` | `GetGradeBookAsync` + scores por `ActivityId` | No |
| Filtro `SchoolId` en actividades | Sí | No | No |
| Filtro `TrimesterId` | Sí (trimestre de la escuela actual por `Name`) | No (solo texto `1T`/`2T`/`3T`) | No |
| Dedup por nombre de actividad | Sí (JS) | No (por Id) | No |
| Tipos de columna | Solo 4 claves fijas | 4 + cualquier otro `Type` | Parcial |
| Estudiantes | `GetBySubjectGroupAndGradeAsync` | Misma API, `OrderBy FullName` | Sí (mismo servicio) |
| Columna `#` | No | Sí | No |
| Nombres | Completos (formato `Apellido, Nombre`) | Truncados a 28 caracteres en cuerpo; encabezados a 6–18 | No (presentación) |
| Cédula | `documentId` o “Sin cédula” | `DocumentId` o `-` | Sí (dato) / No (rótulo) |
| Scroll / paginación | Horizontal en pantalla | Todo en 1 página A4 landscape | No |
| Promedio por tipo | `calcAverages()` + `Math.floor(*10)/10` | `TruncateOneDecimal` equivalente | Sí **si el conjunto de actividades es el mismo** |
| Nota final | `calcAverages` (recupera examen) | `ComputeFinalGrade` (misma idea, no usa el helper) | Sí **si el conjunto es el mismo** |
| Marca de agua | No | Nombre de escuela, 64 pt, fondo | N/A |
| Año lectivo | No en la tabla | `DateTime.UtcNow.Year` (año calendario UTC, no `AcademicYear`) | N/A |
| CSS Bootstrap / print | Afecta la pantalla | **No entra al PDF** | N/A |

---

## 8. Comparación de columnas

Fórmula del PDF (`BuildPdf`, L223–228):

```text
totalCols = 3 + activityCols + TypeSections.Count + 1
          = (#, Nombre, Cédula) + (1 por Activity.Id) + (1 Promedio por tipo presente) + (Nota final)
```

Umbrales:

| `totalCols` | `fontSize` | truncado de nombre en encabezado | `scale` |
|---|---|---|---|
| ≤ 14 | 7 | 18 (o 14 si > 12) | 1.0 |
| 15–16 | 7 | 10–14 | `max(0.55, 14/totalCols)` |
| 17–22 | 6 | 10 | ídem |
| > 22 | **5** | **6** | ídem, piso **0.55** |

Ejemplo: 5 apreciaciones + 18 ejercicios + 1 examen = 24 actividades + 3 promedios + 4 fijas (`#`, nombre, cédula, final) = **31 columnas** → fuente 5 pt y `scale = 0.55`. Tipografía efectiva ≈ 2,75 pt. Encabezados tipo `Aprec.1` + 6 caracteres del nombre.

La web **no comprime**: cada actividad mide 122 px (`--gb-activity-col`), promedio 78 px, final 88 px, nombre 200 px, cédula 90 px, `table-layout: fixed` y `width: max-content` dentro de `.gradebook-table-scroll { overflow-x: auto }`. Con 24 actividades la tabla supera ~3 500 px: el usuario ve un recorte y desplaza.

### Matriz estructural

| Elemento | Vista web | PDF | Coincide | Evidencia | Observación |
|---|---|---|---|---|---|
| Estudiantes | `GetBySubjectGroupAndGradeAsync`, activos, rol estudiante | Misma consulta | Sí (código) | `StudentService.cs` 82–111; PDF L95–97; JS `loadStudents` L2238 | Muestras nominales no verificadas en BD |
| Cédulas | `documentId` | `DocumentId` | Sí (código) | `StudentBasicDto` | PDF muestra `-` si vacío |
| Actividades de apreciación | Las del JSON de `GetNotasCargadas`, tipo `notas de apreciación`, **únicas por nombre** | Todas las de `GetGradeBookAsync` con tipo normalizado | **No garantizado** | JS 1852–1883 vs PDF `BuildTypeSections` | PDF etiqueta `Aprec.N` |
| Promedio de apreciación | Una col. si hay ≥1 actividad de ese tipo | Una col. por sección | Sí en estructura | JS 1884–1887; PDF L386–387 | Valor puede diferir si el set de actividades difiere |
| Actividades de ejercicios | Igual, tipo `ejercicios diarios` | Todas las del libro PDF | **No garantizado** | Idem | Suelen ser el grueso de columnas |
| Promedio de ejercicios | Sí | Sí | Estructura sí | | |
| Examen | Tipo `examen final` | Idem + posibles tipos extra | Parcial | | |
| Promedio de examen | Sí | Sí | Estructura sí | | |
| Recuperación | Columna si existe en `activities['recuperación']` | Sección `Recup.` si hay actividades | Parcial | Formulario L850 | Solo 9º/12º en UI |
| Tipos no estándar (`tarea`, `parcial`, …) | **No se pintan** (`activeTypes` fijo) | **Sí**, bloque extra al final de `BuildTypeSections` | **No** | JS 1852 vs PDF L196–202 | Puede añadir columnas solo al PDF |
| Nota final | Última columna | Última columna | Estructura sí | | |
| Columna `#` | No | Sí | No | PDF L353, 367–368 | |
| Orden de estudiantes | `LastName, Name` (SQL) | `OrderBy FullName` (`LastName, Name`) | Sí | `StudentService` L99 | |
| Orden de actividades | `CreatedAt` luego orden de tipos fijo | `CreatedAt` (libro) luego `TypeOrder` | Sí para los 4 tipos | | |
| Cantidad de columnas | 2 + actividades (dedup nombre) + promedios de tipos presentes + 1 | 3 + **todas** las actividades + promedios + 1 | **Típicamente no** | Fórmulas arriba | |

**Actividades ocultas / inactivas / archivadas:** el modelo `Activity` **no tiene** flags de visibilidad. `DeleteAsync` hace `_context.Activities.Remove` (borrado físico). No hay columnas “ocultas en CSS que reaparecen al imprimir”.

**Duplicados:** `idx_activities_unique_lookup` (`Name, Type, SubjectId, GroupId, TeacherId, Trimester`) **no es único** (`HasIndex` sin `IsUnique`). Dos filas con el mismo nombre generan **una** columna en la web y **dos** en el PDF.

---

## 9. Comparación de muestras de estudiantes y notas

No se ejecutó el sistema ni se consultó PostgreSQL. Los nombres citados en el encargo **no aparecen** en el repositorio.

| Estudiante (solicitado) | Vista web | PDF | Coincide | Estado |
|---|---|---|---|---|
| Abadía, Yosuan | — | — | Pendiente | Sin dato en repo / sin PDF adjunto |
| Agrazal, Stephany | — | — | Pendiente | Idem |
| Alvarado P., Amado E. | — | — | Pendiente | Idem |
| Amagara M., Xavier A. | — | — | Pendiente | Idem |
| Arauaz, Ruth | — | — | Pendiente | Idem |

### Recorrido teórico de una nota (mismo estudiante, misma actividad)

1. **Web:** `GetNotasCargadas` empareja `act.Name` + tipo → JS `scores[studentId][tipo][nombre]` → celda → `calcAverages` con `Math.floor(avg * 10) / 10`.
2. **PDF:** score por `ActivityId` → `TypeAverages` con `TruncateOneDecimal` (`Math.Floor(value * 10m) / 10m`) → `ComputeFinalGrade`.

Si el conjunto de `Activity.Id` es idéntico, los valores **deben coincidir** (truncamiento equivalente). Si el PDF incluye actividades extra (sin `TrimesterId`, otro año con el mismo texto `1T`, duplicado de nombre, tipo fuera de los 4), **los promedios y la nota final pueden divergir**.

El documento interno `Docs/grade-investigation/03_TEACHER_FLOW.md` afirma que el PDF usa `GradebookFinalGradeCalculator`. **Eso es inexacto:** `TeacherGradebookPdfService` implementa `TruncateOneDecimal` y `ComputeFinalGrade` **locales** (L473–497) y no referencia el helper.

---

## 10. Análisis de consultas y filtros

### 10.1 Vista — actividades (`GetByTeacherGroupTrimesterAsync`)

Archivo: `SchoolManager/Services/Implementations/ActivityService.cs` L222–272.

Filtros:

- `TeacherId`, `GroupId`, `Trimester` (código texto)
- `SchoolId == escuela del usuario actual`
- `TrimesterId == trimesters.Id` donde `Name == codigo AND SchoolId == escuela`
- `SubjectId`, `GradeLevelId`
- `OrderBy CreatedAt`

Si no existe fila de trimestre para esa escuela, **devuelve lista vacía**.

### 10.2 Vista — notas (`GetNotasPorFiltroAsync`)

Archivo: `StudentActivityScoreService.cs` L309–366.

Filtros sobre `Activity`: `TeacherId`, `SubjectId`, `GroupId`, `GradeLevelId`, `Trimester` (texto). **Sin** `SchoolId` ni `TrimesterId`. Las **columnas** de la tabla, sin embargo, las arma el controlador a partir de (10.1), no de esta consulta.

### 10.3 PDF — actividades (`GetGradeBookAsync`)

Archivo: `StudentActivityScoreService.cs` L83–106.

```
TeacherId && GroupId && Trimester == trimesterCode
&& SubjectId && GradeLevelId
OrderBy CreatedAt
```

**Ausentes:** `SchoolId`, `TrimesterId`, año académico.

Consecuencia: cualquier actividad histórica con el mismo código de trimestre (`1T`) para el mismo docente/grupo/materia/grado **entra al PDF**, aunque la web la excluya por `TrimesterId`.

Agravante: `TrimesterService.EliminarTodosLosTrimestresAsync` (L264–270) pone `Activity.TrimesterId = null` al borrar el calendario. Esas filas **desaparecen de la web** y **siguen en el PDF** si `Trimester` texto sigue siendo `1T`.

`GetAllAsync` de trimestres resuelve el Id con `FirstOrDefault(Name + SchoolId)`: si hay varios `1T` (uno por año lectivo), el Id es **no determinista**. La web queda atada a **un** Id; el PDF une **todos** los `1T`.

### 10.4 PDF — calificaciones

`TeacherGradebookPdfService` L116–126:

```
StudentActivityScores.Where(s => activityIds.Contains(s.ActivityId))
```

Sin filtro de tenant ni de año académico. El aislamiento depende de que `activityIds` ya esté bien recortado. Como (10.3) es laxo, el recorte es insuficiente.

### 10.5 Autorización del PDF

`BuildModelAsync` L85–92 exige `TeacherAssignments` para la terna grupo/materia/grado del **usuario autenticado**. Un docente no puede exportar la asignación de otro. El trimestre **no** entra en esa comprobación.

### 10.6 Índice de unicidad

`idx_activities_unique_lookup` no es unique. Duplicados de nombre son posibles y se manifiestan como columnas extra **solo en el PDF**.

---

## 11. Análisis del contexto multitenant

Arquitectura: BD compartida, aislamiento por `school_id` (documentado en `SchoolManager/Docs/ANALISIS_MULTITENANT_EDUPLANER.md`). `Activity.SchoolId` es nullable. No hay `HasQueryFilter` de tenant sobre `Activity` ni `StudentActivityScore`.

| Capa | ¿Filtra SchoolId? | Riesgo |
|---|---|---|
| Web actividades | Sí | Bajo para columnas |
| PDF `GetGradeBookAsync` | **No** | Medio: mezcla por `Trimester` texto; GUID de teacher/group suelen aislar en la práctica |
| PDF scores | **No** (solo `ActivityId`) | Hereda el riesgo anterior |
| Encabezado PDF (nombre/logo escuela) | `currentUser.SchoolId` | Cosmético; no filtra filas |
| Estudiantes | Grupo/grado + EXISTS `SubjectAssignments` | Sin `Users.SchoolId` explícito |

**¿Mezcla de otro colegio?** Improbable si `TeacherId` y `GroupId` son UUID de un solo tenant, pero **no está garantizado por la consulta del PDF**.  
**¿Mezcla de otro trimestre/año?** **Sí, plausible:** el predicado es el string `1T`/`2T`/`3T`, no el `TrimesterId` ni `AcademicYearId`.  
**¿Mezcla de otra materia?** No: ambos flujos filtran `SubjectId` y `GradeLevelId`.

El PDF **no** usa el `TeacherId` del body de `GetNotasCargadas`; usa el claim del usuario. Coherente con la vista (el JS también manda `const teacherId = '@Model.TeacherId'`).

---

## 12. Análisis del HTML/CSS de impresión

El PDF **no usa** la vista.

CSS relevante de **pantalla** (`Index.cshtml` L9–220):

- `.gradebook-table-scroll`: `overflow-x: auto`
- `#gradebook.gradebook-table`: `table-layout: fixed`, `width: max-content`, `min-width: 100%`
- columnas de actividad: 122 px fijas
- sticky Estudiante / Cédula

`@media print` (L38–42): solo oculta `.inclusive-heart`. **Irrelevante** para `ExportRegistroPdf`.

Bootstrap en el PDF: **no aplica**. QuestPDF no interpreta `px`/`rem`/`vw` de la vista.

No hay plantilla Razor, `_PrintLayout` ni CSS `reporte-*.css` en este flujo (esos archivos sirven a **otros** informes institucionales con `window.print`).

---

## 13. Análisis de la librería generadora

**Paquete:** QuestPDF 2025.12.3 (`SchoolManager.csproj`).  
**Licencia en runtime:** `LicenseType.Community` (`BuildPdf` L74).  
**API:** `Document.Create` → `container.Page` → `GeneratePdf()`.

Configuración de página (`BuildPdf` L232–256):

| Parámetro | Valor |
|---|---|
| Tamaño | `PageSizes.A4.Landscape()` (~297 × 210 mm / 841,9 × 595,3 pt) |
| Margen horizontal | 16 pt |
| Margen vertical | 20 pt |
| Fuente por defecto | Arial, 5–7 pt, gris |
| Marca de agua | `page.Background().AlignCenter().AlignMiddle().Text(SchoolName).FontSize(64)` |
| Pie | `page.Footer()` — queda anclado abajo (“Página X de Y”) |
| Tabla | `table.ColumnsDefinition` con `RelativeColumn` (reparte el 100 % del ancho del contenedor) |
| Compactación extra | `c.Scale(scale)` si `totalCols > 14` |
| Saltos de página | No hay paginación horizontal. `Scale` reduce la caja de la tabla; con muchos alumnos suele caber en **una** página de alto |

`ShowOnce()` se aplica al **encabezado institucional**, no a las filas.

Efecto combinado de `RelativeColumn` + `Scale`:

1. QuestPDF **primero** reparte todas las columnas en el ancho útil (~810 pt). Con 30 columnas cada una mide ~27 pt.
2. **Después** escala al 55 %: cada columna ~15 pt; la **altura** de la tabla también cae al 55 %.
3. El área inferior de la página queda vacía porque el contenido ya no estira.
4. El pie sigue al fondo → sensación de “franja + desierto”.

Esto reproduce el PDF descrito **sin necesidad de CSS**.

---

## 14. Hipótesis evaluadas

| ID | Hipótesis | Evidencia a favor | Evidencia en contra | Estado |
|---|---|---|---|---|
| H-01 | El PDF es `window.print` / `@media print` de la vista | El botón se llama “Imprimir PDF” | `window.open` a `ExportRegistroPdf`; QuestPDF; print CSS irrelevante | **Descartada** |
| H-02 | Captura DOM (html2canvas, Puppeteer, Playwright) | Otros módulos sí usan Puppeteer | Este flujo es QuestPDF puro | **Descartada** |
| H-03 | CSS Bootstrap / `table-layout` de pantalla se hereda | La vista sí usa Bootstrap | El PDF no renderiza HTML | **Descartada** |
| H-04 | Compactación QuestPDF (`Scale` + fuente + RelativeColumn) en A4 landscape | Código L223–251; commit `4d5bd7a` “evitar overflow” | — | **Confirmada** (causa visual) |
| H-05 | `Scale` deja el vacío inferior | `Scale` reduce alto; footer anclado; content no stretch | — | **Confirmada** |
| H-06 | Una sola página porque se fuerza el contenido | Encoger hasta `scale ≥ 0.55` + fuente 5 pt | QuestPDF podría paginar filas si no hubiera Scale; con Scale cabe en 1 página | **Confirmada** |
| H-07 | La web muestra un recorte (scroll); el PDF todas las columnas | `overflow-x: auto`, 122 px/col | — | **Confirmada** (factor de percepción) |
| H-08 | El PDF usa otra consulta de actividades (`GetGradeBookAsync`) | Código PDF L94 vs web L158 | Si no hay filas huérfanas, los sets pueden coincidir | **Confirmada** como divergencia; **pendiente** el conteo real |
| H-09 | Extra columnas por falta de `SchoolId`/`TrimesterId` | Contraste L245–252 vs L89–94; `TrimesterId = null` al borrar calendario | Sin dump de BD no se cuenta | **Pendiente (plausible)** |
| H-10 | Extra columnas por dedup JS de nombre | L2300 `some(a => a.name === nota.actividad)` | Índice no unique, pero puede no haber duplicados | **Pendiente (plausible)** |
| H-11 | Extra columnas por tipos fuera de los 4 de la UI | PDF `BuildTypeSections` añade restos; JS `activeTypes` fijo | El alta actual solo ofrece 4 tipos | **Pendiente** (legado `tarea`/`parcial`) |
| H-12 | Columnas de actividades eliminadas/ocultas | — | Borrado físico; sin flag hidden | **Descartada** |
| H-13 | Mezcla de otro tenant | PDF sin `SchoolId` | UUID teacher/group | **Pendiente / riesgo bajo-medio** |
| H-14 | Mezcla de otro año lectivo con el mismo `1T` | PDF filtra string de trimestre; `AcademicYear` del PDF es `UtcNow.Year` | Web ata `TrimesterId` | **Pendiente (plausible)** |
| H-15 | Promedios/nota final distintos por algoritmo | PDF no usa el helper | `Floor(*10)/10` equivalente si el set coincide | **Descartada como causa principal**; **pendiente** si el set difiere |
| H-16 | Estudiantes distintos | PDF ignora `book.Rows` | Ambos usan `GetBySubjectGroupAndGradeAsync` | **Descartada** (mismo servicio) |
| H-17 | El problema apareció al crear el PDF | Feature `2b2c818` 31/05/2026 | El layout actual es el “fix” `4d5bd7a` 41 min después | **Confirmada** (origen del diseño) |

---

## 15. Causa raíz principal

Hay **dos causas raíz**, de capas distintas. No deben fusionarse.

### 15.1 Causa raíz visual (confirmada)

`TeacherGradebookPdfService.BuildPdf` (commit `4d5bd7a`) **impide el desbordamiento horizontal encogiendo el documento**:

- página única A4 apaisada;
- todas las columnas en `RelativeColumn`;
- `fontSize` hasta 5 pt;
- `Scale(max(0.55, 14/totalCols))` sobre la tabla completa.

Eso explica, con evidencia de código, por qué la tabla es ilegible, cabe en una página y deja un vacío grande debajo (más marca de agua de 64 pt).

### 15.2 Causa raíz estructural (confirmada como diseño; magnitud de extras pendiente)

El PDF **no es una impresión de la tabla visible**. Es un reporte que:

1. llama a `GetGradeBookAsync` (no a `GetByTeacherGroupTrimesterAsync`);
2. emite **una columna por `Activity.Id`**, sin deduplicar por nombre;
3. admite tipos de actividad que la UI jamás pinta.

Por eso la composición de columnas **puede** (y en la práctica percibida **suele**) no coincidir con `/TeacherGradebook/Index`, incluso con los mismos `groupId`, `subjectId`, `gradeLevelId` y texto de trimestre.

### 15.3 Clasificación

| Tipo | Qué es |
|---|---|
| Síntoma | PDF ilegible, 1 página, vacío, “demasiadas columnas” |
| Defecto técnico | Compactación por `Scale`/fuente en lugar de paginación; dos pipelines de datos |
| Factor contribuyente | Scroll horizontal de la web; etiquetas `Aprec.N`; truncado de nombres |
| Causa raíz principal (visual) | `BuildPdf` L223–251 |
| Causa raíz principal (datos/estructura) | PDF ← `GetGradeBookAsync`; web ← `GetByTeacherGroupTrimesterAsync` + dedup JS |
| Riesgo asociado | Promedios distintos; posible inclusión de actividades de otro `TrimesterId`/año; tenant no filtrado en lectura PDF |

---

## 16. Causas secundarias

1. **`loadGradeBook` / `GradeBookJson` muertos:** la UI nunca se alineó al libro que consume el PDF.
2. **PDF no usa `GradebookFinalGradeCalculator`:** duplicación; el doc `03_TEACHER_FLOW.md` está desactualizado.
3. **Año lectivo del PDF = `DateTime.UtcNow.Year`:** no es el año académico de la escuela.
4. **Encabezados `Aprec.1` + nombre cortado a 6 caracteres** cuando `totalCols > 22`: parece “otra grilla”.
5. **Columna `#` solo en PDF.**
6. **`TrimesterService.GetAllAsync` usa `Name` en el `<option>`**, no el `Id`: web y PDF trabajan con el código `1T`, no con el GUID del trimestre.
7. **Al borrar trimestres se anula `TrimesterId`** y la web deja de ver esas actividades; el PDF no.
8. **Índice de lookup no único.**
9. **Marca de agua 64 pt** resta contraste a una tabla ya de 5 pt.
10. **Scores del PDF** recargan `StudentActivityScores` en lugar de reutilizar `GradeBookDto.Rows` (después del fix `0ff1111` las filas del libro ya usan `User.Id`; se ignora ese pivot).

---

## 17. Riesgos

| Riesgo | Severidad | Notas |
|---|---|---|
| Documento oficial ilegible / no archivable | Alta | El PDF es el artefacto de impresión |
| Promedio/nota final distintos a la pantalla | Media–alta | Si el set de actividades del PDF es mayor |
| Inclusión de actividades de años anteriores con el mismo `1T` | Media | Sin `TrimesterId` / `AcademicYearId` en `GetGradeBookAsync` |
| Lectura cross-tenant | Baja–media | Sin `SchoolId` en el libro PDF; mitigado por UUIDs |
| `ToDictionary(ActivityId)` lanza si hubiera scores duplicados | Baja | Existe `uq_scores` único |
| Compactar más actividades empeora la legibilidad | Alta | El algoritmo es monótono: más columnas → más pequeño |
| Corregir solo el CSS de la vista | Nulo efecto | El PDF no lo usa |
| Corregir solo `Scale` sin acotar columnas | El PDF puede volver a overflow QuestPDF (motivo de `4d5bd7a`) | Hay que paginar, no solo quitar Scale |

No se exponen cadenas de conexión ni secretos en este informe.

---

## 18. Alternativas de solución (sin implementar)

### A. El PDF debe mostrar exactamente las columnas de la pantalla

**Descripción:** Reutilizar `GetByTeacherGroupTrimesterAsync` (o un servicio único de “columnas del libro”) y la misma lista/orden/dedup que `refreshTable`.  
**Archivos:** `TeacherGradebookPdfService.cs`, posiblemente `ActivityService.cs` / nuevo servicio compartido; no la vista salvo para documentar el contrato.  
**Ventajas:** Paridad visual y de promedios.  
**Desventajas:** Hay que decidir qué hacer con duplicados de nombre (la web oculta el segundo Id).  
**Riesgos:** Cambiar promedios del PDF si hoy incluía extras (puede ser lo deseado).  
**Impacto otros reportes:** Nulo si el cambio es local al gradebook PDF.  
**Multitenant:** Mejora (hereda `SchoolId` + `TrimesterId`).  
**Complejidad:** Media.  
**Pruebas:** Paridad de recuento de columnas y de nota final vs `calcAverages`.  
**Recomendación:** **Sí**, como fuente de datos.

### B. Mantener todas las actividades y paginar en horizontal

**Descripción:** Bloques de N columnas por página, repitiendo Estudiante + Cédula (+ `#`) en cada bloque. Sin `Scale` o con escala mínima ≥ 0.9.  
**Archivos:** `TeacherGradebookPdfService.BuildPdf` / `BuildTable`.  
**Ventajas:** Legible; no se pierden actividades.  
**Desventajas:** Más páginas; hay que fijar un `maxColsPerPage`.  
**Riesgos:** Overflow si el máximo sigue siendo alto.  
**Impacto:** Solo este PDF.  
**Multitenant:** Neutro.  
**Complejidad:** Media–alta.  
**Pruebas:** 0, 5, 15, 30+ actividades; con/sin recuperación.  
**Recomendación:** **Sí**, como layout, combinada con A o C.

### C. Repetir estudiante/cédula en cada bloque horizontal

**Descripción:** Complemento de B.  
**Recomendación:** **Sí**, inseparable de B.

### D. Papel más grande (A3 / legal landscape) cuando `totalCols` sea alto

**Descripción:** `page.Size` condicional.  
**Ventajas:** Simple.  
**Desventajas:** Impresoras escolares suelen ser A4; A3 no elimina 30 columnas diminutas.  
**Recomendación:** **No** como solución única; opcional como extra.

### E. Paginación horizontal controlada (ancho mínimo de columna en pt)

**Descripción:** `ConstantColumn` de ~28–36 pt para notas, no `RelativeColumn` elástico; dejar que QuestPDF pase de página.  
**Ventajas:** Tipografía estable.  
**Desventajas:** QuestPDF pagina **filas**, no columnas: hay que partir la tabla a mano (vuelve a B).  
**Recomendación:** Usar como detalle de implementación de B, no sola.

### F. Reporte resumido + reporte detallado

**Descripción:** PDF corto (promedios + final) y PDF largo (todas las actividades paginadas).  
**Ventajas:** El resumen es siempre legible.  
**Desventajas:** Dos artefactos; el botón actual no distingue.  
**Recomendación:** **Opcional** de producto, no sustituye arreglar el actual.

### G. Solo bajar Scale / subir fuente / márgenes

**Descripción:** Quitar `Scale` o piso 0.55→0.85, fuente mínima 8 pt.  
**Ventajas:** Cambio mínimo.  
**Desventajas:** Reintroduce el overflow que `4d5bd7a` intentó tapar; no arregla columnas extra.  
**Recomendación:** **No** como única medida.

### H. Compartir ViewModel/DTO entre web y PDF

**Descripción:** Un `GradebookGridDto` usado por `GetNotasCargadas` y por el PDF.  
**Ventajas:** Una sola verdad.  
**Desventajas:** Refactor de JSON anónimo del controlador.  
**Recomendación:** **Sí** a medio plazo.

### I. Centralizar selección y orden de actividades

**Descripción:** Extraer “actividades visibles del libro” (filtros + orden de tipos + regla de duplicados).  
**Recomendación:** **Sí**; es el núcleo de A+H.

---

## 19. Archivos que serían afectados por una futura corrección

**Probables (layout y/o datos del PDF):**

- `SchoolManager/Services/Implementations/TeacherGradebookPdfService.cs`
- `SchoolManager/Dtos/GradebookPdfDto.cs` (si hay bloques/páginas)
- `SchoolManager/Services/Implementations/StudentActivityScoreService.cs` (`GetGradeBookAsync`, si se alinean filtros)
- O bien dejar `GetGradeBookAsync` y que el PDF llame a `IActivityService.GetByTeacherGroupTrimesterAsync`

**Opcionales (unificación):**

- `SchoolManager/Controllers/TeacherGradebookController.cs` (`GetNotasCargadas` / DTO compartido)
- `SchoolManager/Services/Helpers/GradebookFinalGradeCalculator.cs` (eliminar duplicado en el PDF)
- `SchoolManager/Views/TeacherGradebook/Index.cshtml` **solo** si se elimina `loadGradeBook` muerto o se documenta el contrato; **no** es obligatorio para el PDF

**No tocar en la corrección del PDF** (funcionan para la pantalla):

- `calcAverages` / `GuardarNotasTemp` / CRUD de actividades
- CSS del gradebook (no entra al PDF)
- Otros PDF QuestPDF (carnets, planes, aprobados/reprobados)
- Migraciones, salvo que se decida **después** hacer unique el índice de actividades (fuera de esta incidencia visual)

---

## 20. Plan recomendado para la siguiente fase

1. **Congelar la fuente de columnas:** el PDF debe obtener actividades con los **mismos filtros** que `GetByTeacherGroupTrimesterAsync` (incluir `SchoolId` + `TrimesterId`). Decidir por escrito la regla de duplicados de nombre (alineada a la UI: un nombre = una columna, o mostrar ambos).
2. **Usar `GradebookFinalGradeCalculator`** (o extraer un método único) para promedios y nota final, sobre ese mismo set.
3. **Rediseñar `BuildPdf`:** eliminar o limitar `Scale`; no bajar de ~8 pt; paginar en **bloques horizontales** con Estudiante + Cédula repetidos; `RelativeColumn` solo dentro de un máximo de columnas por página.
4. **No** usar A3 como parche único.
5. **Verificación con el PDF real** `Registro_Calificaciones_1T.pdf` y la captura: contar columnas, listar nombres de actividad, comparar 5 estudiantes.
6. **Consulta de solo lectura** (cuando se autorice): para un `teacher_id/group_id/subject_id/grade_level_id/trimester` concreto, contar `GetGradeBookAsync` vs `GetByTeacherGroupTrimesterAsync` vs nombres distintos.
7. Actualizar `Docs/grade-investigation/03_TEACHER_FLOW.md` (hoy atribuye el helper al PDF de forma incorrecta).
8. No mezclar en el mismo cambio el rediseño de consejería, asistencia ni otros informes.

---

## 21. Pruebas de regresión que deberá exigir la corrección

1. Grupo con **pocas** actividades (`totalCols ≤ 14`): tipografía ≥ 8 pt, sin Scale, una página o paginación vertical natural por alumnos.
2. Grupo con **muchas** actividades (p. ej. ≥ 18 ejercicios): **no** una sola franja ilegible; varias páginas o bloques; nombres y cédulas leíbles.
3. Paridad de **número y orden** de columnas de actividad vs la tabla de Index (mismos filtros).
4. Paridad de **promedio por tipo y nota final** vs `calcAverages` para ≥ 5 alumnos (incluir 0.0, vacíos, recuperación).
5. Caso **sin actividades**.
6. Caso **solo examen** / **con recuperación**.
7. Trimestre `1T`, `2T`, `3T`; caracteres de trimestre en el nombre de archivo.
8. Docente **sin** asignación: 400, no PDF ajeno.
9. Logo ausente o corrupto: no debe tumbar la generación (ya hay try/catch).
10. Nombres largos y cédulas largas: no overflow QuestPDF.
11. Estudiantes inclusivos: el PDF hoy **no** muestra el indicador; no regresionar la **web**.
12. Multitenant: actividades de otra escuela con el mismo código de trimestre no deben aparecer.
13. Actividades con `TrimesterId` null y `Trimester = '1T'`: definir el resultado esperado (hoy: web no / PDF sí).
14. Botón sin filtros: SweetAlert, sin request.
15. Autorización: rol `teacher` requerido.

---

## 22. Preguntas o puntos pendientes

1. ¿Cuántas columnas de actividad hay **exactamente** en la captura vs el PDF adjunto? Hace falta el binario o una consulta de lectura.
2. ¿El colegio tiene **varios** registros `trimesters` con `Name = '1T'` (años distintos)?
3. ¿Se ejecutó `EliminarTodosLosTrimestresAsync` o recreó el calendario, dejando `TrimesterId` null?
4. ¿Hay actividades legado con `Type` distinto de los cuatro del `<select>`?
5. ¿Hay duplicados de `activities.name` para el mismo docente/grupo/materia/trimestre?
6. ¿La captura muestra la tabla **completa** o un viewport con scroll?
7. ¿Se requiere que el PDF sea archivo de archivo legal (todas las actividades) o espejo de lo que el docente ve?
8. ¿Hay que incluir recuperación y la columna `#`?
9. ¿Muestras Abadía / Agrazal / … corresponden a un grupo/materia concretos para la fase de corrección?

---

## 23. Conclusión final

Respuestas al encargo:

1. **¿Por qué el PDF tiene otra estructura?** Porque no imprime la vista. QuestPDF arma una tabla propia desde `GradebookPdfDto`, con `#`, etiquetas `Aprec.N`/`Ejerc.N` y una columna por `Activity.Id`.
2. **¿Por qué aparecen más columnas?** (a) El PDF muestra **todas** las actividades del libro a la vez; la web las reparte en scroll de 122 px. (b) El PDF usa `GetGradeBookAsync` **sin** `SchoolId`/`TrimesterId` y **sin** dedup por nombre. (c) Puede incluir tipos que la UI ignora.
3. **¿Por qué la tabla es tan pequeña?** `fontSize` 5–7 pt **y** `Scale` hasta 0,55, más columnas `RelativeColumn` ya estrechos.
4. **¿Por qué todo en una página?** El encogimiento hace que el bloque cabe en el alto de A4 landscape; no hay partición horizontal.
5. **¿Por qué tanto vacío?** `Scale` reduce la altura ocupada; el footer queda abajo; no hay stretch.
6. **¿Misma fuente de datos?** **No.** Web: `GetNotasCargadas` → `GetByTeacherGroupTrimesterAsync`. PDF: `GetGradeBookAsync`. Estudiantes: sí, mismo servicio.
7. **¿Coinciden valores y promedios?** Solo si el conjunto de actividades es el mismo. El truncamiento es equivalente (`floor` a 1 decimal). No verificado con alumnos reales.
8. **¿Riesgo de mezclar trimestre/materia/grupo/tenant?** Materia/grupo/docente están filtrados. Tenant y año lectivo **no** están bien cerrados en el PDF. El riesgo más realista es **otro `TrimesterId` / año con el mismo código `1T`**, no otro colegio.
9. **¿Qué modificar después?** Sobre todo `TeacherGradebookPdfService` (layout) y la consulta de actividades del PDF (paridad con la web). Opcional: helper de nota final y DTO compartido.
10. **¿Qué no tocar?** Cálculo en vivo de la UI, guardado de notas, CSS del Index, otros generadores PDF, migraciones.

**Veredicto:** el defecto visible es un **diseño deliberado de compactación QuestPDF** (31/05/2026, `4d5bd7a`) sobre un **pipeline de datos distinto al de la pantalla**. No es un bug de CSS de impresión.

---

### Trazabilidad resumida por paso

| Paso | Archivo | Símbolo | Líneas | Datos in → out | ¿Problema? |
|---|---|---|---|---|---|
| 1. Abrir pantalla | `TeacherGradebookController.cs` | `Index` | 297–361 | teacherId → ViewModel | No |
| 2. Cargar tabla | `Index.cshtml` | `loadStudents` + `loadNotasCargadas` | 2238–2336, 2551–2564 | combo + trimestre → JSON | Define columnas web |
| 3. Botón | `Index.cshtml` | `#btnExportRegistroPdf` click | 2703–2716 | mismos ids de filtro → URL GET | No captura DOM |
| 4. Endpoint | `TeacherGradebookController.cs` | `ExportRegistroPdf` | 377–403 | querystring → `byte[]` PDF | Nombre `Registro_Calificaciones_{trim}` |
| 5. Servicio | `TeacherGradebookPdfService.cs` | `GenerateRegistroPdfAsync` / `BuildModelAsync` | 49–179 | ids → `GradebookPdfDto` | Consulta distinta |
| 6. Libro | `StudentActivityScoreService.cs` | `GetGradeBookAsync` | 83–156 | ids → headers | Sin SchoolId/TrimesterId |
| 7. Layout | `TeacherGradebookPdfService.cs` | `BuildPdf` | 221–257 | DTO → PDF | **Scale / 1 página / vacío** |

---

*Fin del análisis. Ningún archivo funcional fue modificado en esta fase.*
