# Indicador visual — Estudiantes inclusivos en TeacherGradebook

Fecha: 2026-05-24

## Fase 1 — Fuente real del dato

| Pregunta | Respuesta |
|----------|-----------|
| ¿Dónde se guarda? | Tabla **`users`**, columna **`inclusivo`** (`boolean`, nullable) |
| ¿Tabla `students`? | No tiene campo de inclusión; el libro de calificaciones une por **`student_assignments` → `users`** |
| Campo relacionado | `users.inclusion` (`varchar`) — usado sobre todo en docentes / texto "si"/"no"; para **estudiantes** la UI de administración mapea el selector "Inclusión E" a **`Inclusivo`** (`Views/User/Index.cshtml`) |
| ¿Lógica previa? | `StudentAssignmentController` actualiza `student.Inclusivo` al guardar matrículas; listado de usuarios muestra corazón si `Inclusivo == true` |

### Búsqueda global (resumen)

- `Inclusivo` / `inclusivo` → `User`, EF `SchoolDbContext`, matrículas, vista de usuarios.
- No existe tabla `student_profiles` con flag de inclusión en este proyecto.

## Fase 2 — Evidencia base de datos

```sql
-- Solo lectura (PostgreSQL)
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'users'
  AND column_name IN ('inclusivo', 'inclusion');
```

Resultado esperado en Eduplaner:

- `inclusivo` → `boolean`
- `inclusion` → `character varying` (u otro tipo texto)

Estudiantes del libro de calificaciones:

```sql
SELECT u.id, u.name, u.last_name, u.inclusivo
FROM users u
JOIN student_assignments sa ON sa.student_id = u.id
WHERE sa.group_id = :groupId
  AND sa.grade_id = :gradeLevelId
  AND sa.is_active = true
  AND u.role IN ('student', 'estudiante', 'alumno');
```

Criterio aplicado en código: **`u.inclusivo = true`**.

## Fase 3 — Archivos modificados

| Archivo | Cambio |
|---------|--------|
| `Dtos/StudentBasicDto.cs` | Propiedad `IsInclusive` |
| `Services/Implementations/StudentService.cs` | Proyección `IsInclusive = student.Inclusivo == true` en `GetByGroupAndGradeAsync` y `GetBySubjectGroupAndGradeAsync` |
| `Views/TeacherGradebook/Index.cshtml` | CSS `.inclusive-student`, helper `renderGradebookStudentName`, columna **Estudiante** en `refreshTable`, flag en `loadStudents` |

**No modificados:** controlador (ya expone `StudentsByGroupAndGrade` → JSON del DTO), PDF (`TeacherGradebookPdfService` sigue usando solo `FullName`), exportaciones, promedios, asistencia, otros módulos.

## Fase 4 — Interfaz

En la tabla principal del libro (`#gradebook`), columna **Estudiante**:

- Inclusivo: `❤️ Apellido, Nombre` (peso 600, corazón rojo discreto).
- No inclusivo: nombre sin icono.

## Fase 5 — Impresión / PDF

- `@media print`: el emoji se oculta; el nombre se imprime normal (no rompe layout).
- Export PDF del registro: sin cambios (no muestra corazón).

## Fase 6 — Validaciones

| Caso | Resultado esperado |
|------|-------------------|
| `inclusivo = true` | Corazón + nombre en columna Estudiante |
| `inclusivo = false` o `NULL` | Solo nombre |
| Varios inclusivos en el grupo | Cada fila afectada |
| Grupo sin inclusivos | Sin corazones |
| Guardar notas / promedios | Sin cambio (solo presentación) |
| Impresión navegador | Nombre sin emoji |

## Confirmaciones

- No se crearon tablas, columnas ni migraciones.
- No se alteró lógica de cálculo de notas.
- `dotnet build`: correcto.

## Resultado visual (descripción)

Fila de ejemplo en pantalla:

`❤️ Pérez Gómez, Juan` — texto en negrita moderada, corazón rojo pequeño a la izquierda del apellido.

Fila normal:

`Rodríguez, María` — sin prefijo.
