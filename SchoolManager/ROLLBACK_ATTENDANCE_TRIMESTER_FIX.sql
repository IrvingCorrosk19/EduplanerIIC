-- Reversion manual de la correccion de asistencia historica.
-- NO ejecutar salvo que se decida revertir la migracion AddAttendanceAcademicScope.
-- Este script elimina solo FK, indices y columnas agregadas; no toca datos originales
-- de actividades, notas, estudiantes, docentes ni grupos.

BEGIN;

ALTER TABLE attendance
    DROP CONSTRAINT IF EXISTS attendance_trimester_id_fkey;

ALTER TABLE attendance
    DROP CONSTRAINT IF EXISTS attendance_academic_year_id_fkey;

DROP INDEX IF EXISTS "IX_Attendance_Student_Trimester";
DROP INDEX IF EXISTS "IX_Attendance_Date_Trimester";
DROP INDEX IF EXISTS "IX_Attendance_TrimesterId";
DROP INDEX IF EXISTS "IX_Attendance_AcademicYearId";

ALTER TABLE attendance
    DROP COLUMN IF EXISTS trimester_id;

ALTER TABLE attendance
    DROP COLUMN IF EXISTS academic_year_id;

DELETE FROM "__EFMigrationsHistory"
WHERE "MigrationId" = '20260621180847_AddAttendanceAcademicScope';

COMMIT;
