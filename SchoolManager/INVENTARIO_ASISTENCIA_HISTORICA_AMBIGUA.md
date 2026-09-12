# Inventario de asistencia histórica sin materia inequívoca

**Fecha:** 12 de septiembre de 2026  
**Alcance:** no destructivo. No se eliminó ninguna fila histórica.

## Respaldo

| Tabla | Propósito |
|---|---|
| `attendance_subject_backfill_20260912` | Copia de filas con `subject_id` nulo antes del backfill |
| `attendance_unambiguous_teacher_subject_20260912` | Mapa docente+grupo+grado → materia cuando hay exactamente una materia |
| `attendance_unresolved_subject_inventory_20260912` | Filas que quedaron sin `subject_id` |
| `attendance_duplicate_identity_inventory_20260912` | Identidades funcionales con más de una fila |

## Resultado del backfill automático

| Métrica | Valor |
|---|---|
| Filas con materia asociada de forma inequívoca | 73,261 |
| Filas sin materia (ambiguas) | 3,387 |
| Filas sin docente | 0 |
| Ámbitos docente+grupo+grado con más de una materia | 67 |
| Grupos duplicados (estudiante+materia+grupo+grado+fecha) | 14,354 |

## Regla aplicada

Se asignó `subject_id` **solo** cuando el docente tenía **exactamente una** materia en `teacher_assignments` + `subject_assignments` para el mismo `group_id` y `grade_id`.

Si existían varias materias posibles, la fila se dejó con `subject_id` nulo. No se inventó materia.

## Duplicados históricos

Hay 14,354 combinaciones con más de una fila para la misma identidad funcional.  
**No se eliminaron.** El reporte cuenta **fechas distintas**, no filas.

No se creó índice `UNIQUE` porque esos duplicados harían fallar la migración.

## Limpieza destructiva pendiente

La deduplicación (conservar una fila canónica y borrar extras) **no se ejecutó**.  
Requiere confirmación explícita. El respaldo ya existe.

Hasta entonces, el upsert nuevo actualiza todas las filas coincidentes y no inserta otra.
