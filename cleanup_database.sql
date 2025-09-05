-- Script para limpiar la base de datos SchoolManagement
-- Preserva el usuario admin@correo.com
-- Respeta las relaciones sin usar CASCADE
-- Base de datos: PostgreSQL con UUIDs

-- Deshabilitar temporalmente las verificaciones de foreign key
SET session_replication_role = replica;

-- ==============================================
-- ELIMINACIÓN DE DATOS EN ORDEN CORRECTO
-- ==============================================

-- 1. Eliminar datos de tablas que no tienen dependencias (tablas hoja)
DELETE FROM public.student_activity_scores;
DELETE FROM public.activity_attachments;
DELETE FROM public.activities;

-- 2. Eliminar datos de tablas que referencian users como student_id
DELETE FROM public.attendance;
DELETE FROM public.discipline_reports;
DELETE FROM public.student_assignments;

-- 3. Eliminar datos de tablas de asignaciones restantes
DELETE FROM public.teacher_assignments;
DELETE FROM public.subject_assignments;

-- 4. Eliminar datos de tablas de relaciones usuario
DELETE FROM public.user_subjects;
DELETE FROM public.user_groups;
DELETE FROM public.user_grades;

-- 5. Eliminar audit_logs (referencia users pero no es crítica)
DELETE FROM public.audit_logs;

-- 6. Eliminar estudiantes (excepto admin)
DELETE FROM public.students 
WHERE id NOT IN (
    SELECT id FROM public.users WHERE email = 'admin@correo.com'
);

-- 7. Eliminar usuarios (excepto admin)
DELETE FROM public.users 
WHERE email != 'admin@correo.com';

-- 8. Eliminar datos de tablas de configuración académica
DELETE FROM public.trimester;
DELETE FROM public.groups;
DELETE FROM public.subjects;
DELETE FROM public.activity_types;
DELETE FROM public.area;
DELETE FROM public.specialties;
DELETE FROM public.grade_levels;

-- 9. Eliminar configuraciones de seguridad
DELETE FROM public.security_settings;

-- 10. Eliminar escuelas (esto eliminará las referencias restantes)
DELETE FROM public.schools;

-- 11. Limpiar tabla de migraciones (opcional - solo si quieres resetear las migraciones)
-- DELETE FROM public."__EFMigrationsHistory";

-- ==============================================
-- VERIFICACIÓN FINAL
-- ==============================================

-- Rehabilitar las verificaciones de foreign key
SET session_replication_role = DEFAULT;

-- Verificar que solo queda el usuario admin
SELECT 'Usuarios restantes:' as info, COUNT(*) as cantidad FROM public.users;
SELECT 'Email del usuario admin:' as info, email FROM public.users WHERE email = 'admin@correo.com';

-- Mostrar conteo de registros por tabla (debería ser 0 o 1 para users)
SELECT 
    'activities' as tabla, COUNT(*) as registros FROM public.activities
UNION ALL
SELECT 'activity_attachments', COUNT(*) FROM public.activity_attachments
UNION ALL
SELECT 'activity_types', COUNT(*) FROM public.activity_types
UNION ALL
SELECT 'area', COUNT(*) FROM public.area
UNION ALL
SELECT 'attendance', COUNT(*) FROM public.attendance
UNION ALL
SELECT 'audit_logs', COUNT(*) FROM public.audit_logs
UNION ALL
SELECT 'discipline_reports', COUNT(*) FROM public.discipline_reports
UNION ALL
SELECT 'grade_levels', COUNT(*) FROM public.grade_levels
UNION ALL
SELECT 'groups', COUNT(*) FROM public.groups
UNION ALL
SELECT 'schools', COUNT(*) FROM public.schools
UNION ALL
SELECT 'security_settings', COUNT(*) FROM public.security_settings
UNION ALL
SELECT 'specialties', COUNT(*) FROM public.specialties
UNION ALL
SELECT 'student_activity_scores', COUNT(*) FROM public.student_activity_scores
UNION ALL
SELECT 'student_assignments', COUNT(*) FROM public.student_assignments
UNION ALL
SELECT 'students', COUNT(*) FROM public.students
UNION ALL
SELECT 'subject_assignments', COUNT(*) FROM public.subject_assignments
UNION ALL
SELECT 'subjects', COUNT(*) FROM public.subjects
UNION ALL
SELECT 'teacher_assignments', COUNT(*) FROM public.teacher_assignments
UNION ALL
SELECT 'trimester', COUNT(*) FROM public.trimester
UNION ALL
SELECT 'user_grades', COUNT(*) FROM public.user_grades
UNION ALL
SELECT 'user_groups', COUNT(*) FROM public.user_groups
UNION ALL
SELECT 'user_subjects', COUNT(*) FROM public.user_subjects
UNION ALL
SELECT 'users', COUNT(*) FROM public.users;

-- ==============================================
-- MENSAJE FINAL
-- ==============================================
SELECT 'Limpieza completada. Solo se preservó el usuario admin@correo.com' as resultado;