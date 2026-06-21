# Correccion definitiva de asistencia, trimestres y ano academico 2026

Fecha de ejecucion: 2026-06-21

## Objetivo

Persistir en `attendance` el trimestre historico y el ano academico historico para que cambios futuros en el calendario academico no reclasifiquen reportes de asistencia ya registrados.

## Backup obligatorio

### Aplicacion

- Origen: `C:\Proyectos\EduplanerIIC\SchoolManager`
- Destino: `C:\Proyectos\EduplanerIIC\Backups\attendance_trimester_fix_20260621_130351\application`
- Exclusiones: `bin`, `obj`, `.git`
- Archivos: 1,230
- Tamano: 283,952,376 bytes
- Fecha: `2026-06-21T13:03:53`
- Resultado: correcto

### PostgreSQL

- Destino: `C:\Proyectos\EduplanerIIC\Backups\attendance_trimester_fix_20260621_130351\database\schoolmanagement_xqks_full.dump`
- Formato: custom `pg_dump`
- Tamano: 6,380,727 bytes
- Fecha: `2026-06-21T13:05:49`
- SHA256: `0036C0453503A4C1C97E4AD80B35219B0CF71A29CEC233395A4E1896F9710A81`
- Validacion: `pg_restore --list OK`
- Lista generada: `C:\Proyectos\EduplanerIIC\Backups\attendance_trimester_fix_20260621_130351\database\pg_restore_list.txt`

## Migracion creada y aplicada

Migracion EF Core: `20260621180847_AddAttendanceAcademicScope`

Cambios aditivos en `attendance`:

- `trimester_id uuid null`
- `academic_year_id uuid null`
- `IX_Attendance_TrimesterId`
- `IX_Attendance_AcademicYearId`
- `IX_Attendance_Date_Trimester`
- `IX_Attendance_Student_Trimester`
- FK `attendance_trimester_id_fkey` hacia `trimester(id)`
- FK `attendance_academic_year_id_fkey` hacia `academic_years(id)`

No se eliminaron columnas ni datos.

## Script de reversion

Archivo generado: `ROLLBACK_ATTENDANCE_TRIMESTER_FIX.sql`

Estado: generado, no ejecutado.

El script revierte unicamente FKs, indices, columnas nuevas y registro de migracion EF. No toca datos originales ajenos a las columnas agregadas.

## Validacion previa

Archivo: `C:\Proyectos\EduplanerIIC\Backups\attendance_trimester_fix_20260621_130351\database\attendance_pre_validation.txt`

- Total `attendance`: 32,297
- Antes de `2026-06-08`: 17,649
- Desde `2026-06-08`: 14,648
- Sin `trimester_id`: 32,297
- Sin `academic_year_id`: 32,297

Referencias usadas:

- Ano academico 2026: `f7ccb57f-fa3e-4d9f-973b-552030c9852d`
- 1T: `54d2db96-495a-4db2-96e4-04415f9ae267`
- 2T: `7038b0cd-581b-470c-8753-618f34929a5a`

## SQL ejecutado

Archivo de salida: `C:\Proyectos\EduplanerIIC\Backups\attendance_trimester_fix_20260621_130351\database\attendance_backfill_execution.txt`

```sql
BEGIN;
UPDATE attendance
SET
  academic_year_id = 'f7ccb57f-fa3e-4d9f-973b-552030c9852d'::uuid,
  trimester_id = CASE
    WHEN date < DATE '2026-06-08' THEN '54d2db96-495a-4db2-96e4-04415f9ae267'::uuid
    ELSE '7038b0cd-581b-470c-8753-618f34929a5a'::uuid
  END
WHERE academic_year_id IS NULL OR trimester_id IS NULL;
COMMIT;
```

Registros afectados: 32,297.

No se tocaron `activities`, `student_activity_scores`, notas, estudiantes, docentes, grupos ni fechas.

## Validacion posterior

Archivo: `C:\Proyectos\EduplanerIIC\Backups\attendance_trimester_fix_20260621_130351\database\attendance_post_validation.txt`

- Total `attendance`: 32,297
- Con `trimester_id`: 32,297
- Con `academic_year_id`: 32,297
- Sin `trimester_id`: 0
- Sin `academic_year_id`: 0
- 1T: 17,649
- 2T: 14,648
- Ano academico 2026: 32,297
- Antes de `2026-06-08` no asignado a 1T: 0
- Desde `2026-06-08` no asignado a 2T: 0

La suma final coincide exactamente con el total original: 17,649 + 14,648 = 32,297.

## Cambios funcionales

- `AttendanceService.SaveAttendancesAsync` ahora persiste `school_id`, `created_by`, `updated_by`, `academic_year_id` y `trimester_id` al registrar asistencia.
- `AttendanceService.CreateAsync` tambien resuelve el alcance academico para nuevas asistencias.
- Los reportes estudiantiles y reportes institucionales priorizan `attendance.trimester_id`.
- Si `trimester_id` esta vacio, se usa `academic_year_id` para restringir el fallback por fecha cuando sea posible.
- Solo si las columnas historicas estan vacias, se conserva la logica por rango de fechas.

## Compilacion

- `dotnet restore`: correcto
- `dotnet build`: correcto
- Resultado: `0 Warning(s), 0 Error(s)`

## Riesgos pendientes

- La tabla `attendance` conserva duplicados historicos detectados en auditorias previas; no se consolidaron porque estaba fuera del alcance aprobado.
- Las asistencias historicas siguen con `school_id` vacio; no se backfilleo `school_id` porque la ejecucion aprobada solo autorizaba actualizar `trimester_id` y `academic_year_id`.
- Los trimestres actuales mantienen fechas de calendario que no cubren completamente el periodo operativo observado; los reportes corregidos ya no dependen de esas fechas para registros backfilleados.
