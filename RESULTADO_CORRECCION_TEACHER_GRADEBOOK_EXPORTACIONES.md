# RESULTADO DE IMPLEMENTACIÓN — TeacherGradebook: PDF y Excel

**Fecha:** 1 de septiembre de 2026  
**Rama:** `main`  
**HEAD previo:** `bd5bd24`  
**Commit / push / despliegue:** no realizados  

Documento consolidado de la corrección del PDF y de la ampliación **Exportar Excel**.  
La versión previa centrada solo en PDF permanece en `RESULTADO_CORRECCION_TEACHER_GRADEBOOK_PDF.md`.

---

## 1. Corrección del PDF

El botón **Imprimir PDF** ya no reconstruye el registro con `GetGradeBookAsync` ni lo compacta con `Scale`.

- Columnas: `ActivityService.GetByTeacherGroupTrimesterAsync` (`SchoolId` + `TrimesterId`).
- Misma regla de columnas que Index (tipos fijos, orden, deduplicación tipo+nombre).
- Promedios y nota final: `GradebookFinalGradeCalculator` (truncamiento a un decimal, sin redondeo).
- QuestPDF pagina por bloques de tipo, fuente mínima 8 pt, sin `Scale`.

La vista web, el guardado de notas y los demás reportes PDF no se modificaron en su lógica de cálculo.

---

## 2. Implementación de Excel

En `/TeacherGradebook/Index` hay dos acciones independientes:

1. **Imprimir PDF** (sin cambio de flujo: `window.open` al PDF).
2. **Exportar Excel** (nuevo): descarga un `.xlsx` real por `fetch` + blob, sin pestaña en blanco y sin recargar la pantalla.

El botón se llama exactamente `Exportar Excel`, va junto al PDF, se deshabilita si faltan grupo o trimestre, y si se pulsa sin filtros muestra la misma validación SweetAlert.

Nombre de archivo:

`Registro_Calificaciones_{Trimestre}_{Grupo}_{Materia}.xlsx`

sanitizado (`GradebookExportFileName`): caracteres inválidos, `..`, barras y controles se sustituyen; no se aceptan rutas.

---

## 3. Fuente canónica compartida

```text
ITeacherGradebookRegistroService.GetRegistroAsync
          ├── Vista web (misma selección lógica de actividades; Index no se reescribió)
          ├── PDF  (TeacherGradebookPdfService → GradebookPdfRenderer)
          └── Excel (TeacherGradebookExcelService → GradebookExcelRenderer)
```

El modelo (`GradebookPdfDto`) incluye: colegio, docente, materia, grupo, grado, trimestre, año lectivo, estudiantes, cédulas, actividades visibles, tipo, orden, calificaciones, promedios por tipo, recuperación cuando aplica y nota final.

La vista Index **no** se migró al DTO (riesgo innecesario sobre `calcAverages` y el guardado). Las pruebas `GradebookExcelParityTests` y `GradebookVisibleActivitySelectorTests` demuestran que Excel/PDF usan el mismo contrato que el JavaScript:

- tipos `notas de apreciación`, `ejercicios diarios`, `examen final`, `recuperación`;
- primera aparición por nombre exacto (`activities[tipo].some(a => a.name === nota.actividad)`).

`GetGradeBookAsync` **no** se usa en PDF ni en Excel.

---

## 4. Endpoint de Excel

```text
GET /TeacherGradebook/ExportRegistroExcel?groupId&trimester&subjectId&gradeLevelId
```

| Control | Comportamiento |
|---|---|
| Autenticación | `[Authorize(Roles = "teacher")]` en el controlador |
| TeacherId | `GetTeacherId()` desde claims; el navegador no envía TeacherId |
| Asignación | `TeacherAssignments` + `SchoolId` del usuario |
| Trimestre | debe existir `Trimesters.Name + SchoolId` |
| 400 | parámetros vacíos o trimestre ajeno al colegio |
| 403 | asignación ajena / sin colegio |
| 500 | error genérico, sin stack al usuario |
| Content-Type | `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet` |

El PDF sigue devolviendo 400 ante `UnauthorizedAccessException` (comportamiento previo). Excel usa 403 para ese caso, según el alcance de esta ampliación.

---

## 5. Librería utilizada

El proyecto **ya tenía** EPPlus para otros reportes (hábitos y actitudes).

| Paquete | Versión | Motivo |
|---|---|---|
| **EPPlus** | **8.0.1** | Ya referenciado en `SchoolManager.csproj`. Licencia no comercial ya configurada en `Program.cs`: `ExcelPackage.License.SetNonCommercialOrganization("EduplanerIIC-SchoolManager")`. |

No se añadió ClosedXML ni se construyó XML a mano. No es un CSV renombrado.  
El proyecto de pruebas referencia la **misma** versión 8.0.1 solo para abrir el archivo generado. No se actualizaron paquetes no relacionados.

NPOI permanece para plantillas `.xls` de otros módulos; no se usó aquí.

---

## 6. Archivos modificados

**Nuevos**

- `SchoolManager/Services/Interfaces/ITeacherGradebookRegistroService.cs`
- `SchoolManager/Services/Interfaces/ITeacherGradebookExcelService.cs`
- `SchoolManager/Services/Implementations/TeacherGradebookRegistroService.cs`
- `SchoolManager/Services/Implementations/TeacherGradebookExcelService.cs`
- `SchoolManager/Services/Implementations/GradebookExcelRenderer.cs`
- `SchoolManager/Services/Helpers/GradebookExcelLayout.cs`
- `SchoolManager/Services/Helpers/GradebookExcelSafety.cs`
- `SchoolManager/Services/Helpers/GradebookExportFileName.cs`
- Pruebas Excel/autorización en `SchoolManager.Tests/`
- `artifacts/gradebook-excel/Registro_Calificaciones_1T_9_G_CIVICA.xlsx`
- Este documento

**Modificados**

- `TeacherGradebookPdfService.cs` (delega en la fuente canónica)
- `GradebookPdfDto.cs` (grado, grupo, fecha de presentación)
- `GradebookPdfRenderer.cs` (usa `GeneratedAtDisplay` si existe)
- `TeacherGradebookController.cs` (endpoint Excel)
- `Views/TeacherGradebook/Index.cshtml` (botón, CSS, descarga)
- `Program.cs` (DI)
- `SchoolManager.csproj` (`InternalsVisibleTo` para pruebas)
- `SchoolManager.Tests/SchoolManager.Tests.csproj` (EPPlus 8.0.1)
- `Docs/grade-investigation/03_TEACHER_FLOW.md`

**No modificados (a propósito)**

- `calcAverages` / guardado de notas
- Migraciones / PostgreSQL
- Otros exportadores institucionales

---

## 7. Protección multitenant

`GetRegistroAsync` (compartido por PDF y Excel):

1. Colegio del usuario autenticado (`ICurrentUserService`).
2. Asignación docente al grupo/materia/grado de **ese** colegio.
3. Trimestre con `Name + SchoolId`.
4. Actividades: `GradebookActivityScope` (`SchoolId`, `TrimesterId`, código).
5. Estudiantes: `Users.SchoolId` nulo o del colegio.
6. Notas: `StudentActivityScores` de los `ActivityId` visibles y `SchoolId` nulo o del colegio.

Una actividad de otro colegio con el mismo texto `1T` no entra. Cubierto en `GradebookActivityScopeTests`.

---

## 8. Filtros de trimestre y año académico

El código `1T` no basta. Se resuelve el trimestre vigente del colegio y se exige `Activity.TrimesterId`.

Quedan fuera: otro `TrimesterId` con el mismo texto, `TrimesterId` null, otros colegios, tipos que Index no muestra.

**Año lectivo en encabezado:** `trimester.AcademicYear.Name`, o el año activo del colegio. No se usa `DateTime.UtcNow.Year` como valor académico.

**Fecha de generación:** `ITimeZoneService.ToLocalDisplayString` (zona `DateTime:DisplayTimeZoneId`, p. ej. America/Panama). No se presenta UTC como si fuera hora local.

---

## 9. Regla de duplicados

Igual que Index: primera actividad por `tipo.toLowerCase()` + nombre exacto, en orden `CreatedAt`. `AliasIds` resuelve la nota si el id conservado está vacío. Cada actividad lógica aparece **una vez** en Excel.

---

## 10. Regla de truncamiento

`GradebookFinalGradeCalculator.TruncateOneDecimal` = `Math.Floor(value * 10) / 10`.

- `4.59` → `4.5`, nunca `4.6`.
- No se usa `Math.Round`.
- Vacío = celda Excel sin valor; `0.0` = número `0` con formato `0.0`.
- Recuperación sustituye el promedio de examen en la nota final, igual que `calcAverages`.
- Excel **escribe los resultados oficiales del servidor**. No hay fórmulas de recálculo en celdas.

---

## 11. Estructura del workbook

- Una sola hoja: `Registro de Calificaciones`.
- Encabezado: título, colegio, docente, materia, grupo, grado, trimestre, año lectivo, cantidad de estudiantes, fecha/hora local.
- Tabla (orden de Index): Estudiante, Cédula, apreciación + promedio, ejercicios + promedio, examen + promedio, recuperación + promedio (si aplica), nota final.
- Colores Eduplaner (`#1e40af` / `#2563eb`), negrita en encabezados, bordes, filas alternadas, cédula como texto (`@`), notas numéricas `0.0`, ajuste de texto en encabezados de actividad.
- Autofiltro en la tabla.
- Paneles congelados: filas 1–9 y columnas Estudiante + Cédula (`xSplit=2`, `ySplit=9`).
- Formato condicional de nota final según umbral oficial **3.0** (no cambia el valor).
- Sin IDs internos, tokens ni cadenas de conexión.

---

## 12. Configuración de impresión

- Orientación horizontal, papel A4 (`paperSize=9`).
- Márgenes ~0.45–0.6 in.
- Títulos de impresión: fila de encabezados de tabla.
- Área de impresión = rango usado.
- Hasta 12 actividades: ajustar a 1 página de **ancho** (`FitToWidth=1`, alto libre).
- Más de 12 actividades: escala 100 %, varias páginas de ancho (no se microcompacta como el PDF antiguo).
- Encabezado/pie: colegio, grupo · trimestre, materia, `Página &P de &N`.

---

## 13. Seguridad contra inyección de fórmulas

Textos de usuario/BD que empiezan por `=`, `+`, `-` o `@` se escriben con prefijo `'` y `QuotePrefix`. Las celdas de datos no tienen `Formula`. Verificado en `GradebookExcelSafetyTests` y `Generate_FormulaInjection_IsNotExecuted`.

---

## 14. Pruebas ejecutadas

`dotnet test SchoolManager.sln` → **61 passed, 0 failed**.

Incluyen, entre otras:

| # | Cobertura |
|---|---|
| 1–3 | Controlador exige rol `teacher`; Excel es GET; no acepta `TeacherId` |
| 4–7 | `GradebookActivityScope`: otro SchoolId, otro TrimesterId, histórico `1T`, sin mezcla de tenants |
| 8–17 | Paridad Excel vs modelo canónico (actividades, orden, estudiantes, cédulas, promedios, final, duplicados, recuperación, vacío vs 0.0) |
| 18–22 | Content-Type constante, extensión `.xlsx`, abre con EPPlus, una hoja, ZIP `PK` |
| 23–30 | Encabezados, notas `double` + `0.0`, cédula texto, autofiltro, freeze, landscape A4, sin fórmulas |
| 31–36 | Nombres largos, 0 actividades, 1 estudiante, 40 estudiantes, 30+ actividades, inyección `=+ -@` |

No hay prueba HTTP contra PostgreSQL de producción (solo lectura no configurada en esta fase; no se escribe en BD).

---

## 15. Resultados de compilación

```text
dotnet restore SchoolManager.sln
dotnet build SchoolManager.sln
dotnet test SchoolManager.sln
```

| Comando | Resultado |
|---|---|
| restore | OK |
| build | 0 errores en SchoolManager. Advertencia MSB3277 EF Relational 9.0.1 vs 9.0.3 **solo en el proyecto de pruebas** (baseline previo). |
| test | **61 passed, 0 failed** |

---

## 16. Ruta del PDF corregido

`c:\Proyectos\eduplaner\artifacts\gradebook-pdf\Registro_Calificaciones_1T_corregido.pdf`

Páginas de inspección: `pagina_01.png` … `pagina_05.png`.

---

## 17. Ruta del Excel generado

`c:\Proyectos\eduplaner\artifacts\gradebook-excel\Registro_Calificaciones_1T_9_G_CIVICA.xlsx`

Abierto como ZIP OOXML válido (una hoja, `sheet1.xml`, sin `testzip` corrupto). Inspección XML:

- Hoja `Registro de Calificaciones`.
- Encabezado institucional IPT San Miguelito / GERTRUDIS KIRTON WINTER / CÍVICA / grupo G / grado 9 / 1T / 2026.
- Estudiantes: Abadía, Yosuan; Agrazal, Stephany; Alvarado P., Amado E.; Amagara M., Xavier A.; Arauaz, Ruth (más extras del fixture de 12).
- Cédulas texto `8-123-001` … `8-123-005`.
- Freeze `xSplit=2` `ySplit=9` `state=frozen`.
- `pageSetup orientation=landscape paperSize=9 scale=100`.
- Autofiltro `A9:AE21`.
- 0 fórmulas de celda.

Fixture representativo; **no** es un dump de producción. La captura real de IPT San Miguelito no está en el workspace.

---

## 18. Comparación de paridad web / PDF / Excel

| Aspecto | Index | PDF | Excel |
|---|---|---|---|
| Consulta de actividades | `GetByTeacherGroupTrimesterAsync` | misma vía `GetRegistroAsync` | misma |
| Dedup tipo+nombre | JS `some(a => a.name === …)` | `GradebookVisibleActivitySelector` | misma |
| Orden de tipos | `activeTypes` | selector | mismas columnas |
| Promedios / final | `calcAverages` + floor | `GradebookFinalGradeCalculator` | valores ya calculados |
| Vacío vs 0.0 | celda vacía vs `0.0` | `-` vs `0.0` | celda vacía vs número 0 |
| Truncamiento | `Math.floor(*10)/10` | mismo helper | mismo número exportado |

Alvarado P. conserva el ejercicio 1 vacío (no se convierte en 0.0). Arauaz conserva `0.0` en Aprec 2.

---

## 19. Migraciones

No se creó ninguna migración. No se ejecutó `dotnet ef`.

---

## 20. Datos

Ningún `SaveChanges`, insert, update ni delete en la fuente canónica ni en los exportadores. Confirmado por revisión de `TeacherGradebookRegistroService` y prueba de código de solo lectura.

---

## 21. Despliegue

No se desplegó. No hay `commit` ni `push`.

---

## Confirmación obligatoria

```text
Datos modificados: NO
Estructura de base de datos modificada: NO
Migraciones creadas: NO
Migraciones ejecutadas: NO
```

---

## Pendientes de entorno

1. Validar el `.xlsx` contra datos reales de IPT San Miguelito cuando haya un entorno de **solo lectura**.
2. La UI en navegador no se recorrió en vivo en esta sesión (no hay servidor ni sesión docente). El marcado y el JS están en `Index.cshtml`.
3. MSB3277 del proyecto de tests (preexistente).
