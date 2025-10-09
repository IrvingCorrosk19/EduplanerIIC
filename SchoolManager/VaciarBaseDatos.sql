-- =========================================================
-- Script para VACIAR todas las tablas EXCEPTO:
-- - public.schools
-- - public."EmailConfigurations"
-- - public.users
-- =========================================================
-- NOTA: Este script conserva los datos de schools, users y configuraciones de email
-- =========================================================

BEGIN;

-- Desactivar temporalmente las restricciones de foreign keys
SET CONSTRAINTS ALL DEFERRED;

-- =========================================================
-- VACIAR TABLAS DE RELACIÓN (Many-to-Many)
-- =========================================================
TRUNCATE TABLE public.user_grades CASCADE;
TRUNCATE TABLE public.user_groups CASCADE;
TRUNCATE TABLE public.user_subjects CASCADE;

-- =========================================================
-- VACIAR TABLAS DE ACTIVIDADES Y CALIFICACIONES
-- =========================================================
TRUNCATE TABLE public.student_activity_scores CASCADE;
TRUNCATE TABLE public.activity_attachments CASCADE;
TRUNCATE TABLE public.activities CASCADE;
TRUNCATE TABLE public.activity_types CASCADE;

-- =========================================================
-- VACIAR TABLAS DE ASISTENCIA Y REPORTES
-- =========================================================
TRUNCATE TABLE public.attendance CASCADE;
TRUNCATE TABLE public.discipline_reports CASCADE;
TRUNCATE TABLE public.audit_logs CASCADE;

-- =========================================================
-- VACIAR TABLAS DE ASIGNACIONES
-- =========================================================
TRUNCATE TABLE public.teacher_assignments CASCADE;
TRUNCATE TABLE public.student_assignments CASCADE;
TRUNCATE TABLE public.subject_assignments CASCADE;
TRUNCATE TABLE public.counselor_assignments CASCADE;

-- =========================================================
-- VACIAR TABLAS DE ESTUDIANTES Y ACADÉMICAS
-- =========================================================
TRUNCATE TABLE public.students CASCADE;
TRUNCATE TABLE public.subjects CASCADE;
TRUNCATE TABLE public.groups CASCADE;
TRUNCATE TABLE public.grade_levels CASCADE;
TRUNCATE TABLE public.specialties CASCADE;
TRUNCATE TABLE public.area CASCADE;
TRUNCATE TABLE public.trimester CASCADE;

-- =========================================================
-- VACIAR CONFIGURACIONES
-- =========================================================
TRUNCATE TABLE public.security_settings CASCADE;

-- Vaciar email_configurations (minúsculas) si existe datos duplicados
-- TRUNCATE TABLE public.email_configurations CASCADE;

-- =========================================================
-- LIMPIAR TABLA USERS (conservar solo admin y superadmin)
-- =========================================================
DELETE FROM public.users WHERE role NOT IN ('admin', 'superadmin');

-- =========================================================
-- TABLAS QUE SE CONSERVAN (NO SE TOCAN):
-- - public.schools (completa)
-- - public."EmailConfigurations" (completa)
-- - public.email_configurations (completa)
-- - public.users (solo admin y superadmin)
-- =========================================================

COMMIT;

-- Verificar cantidad de registros restantes
SELECT 
    'schools' as tabla, COUNT(*) as registros FROM public.schools
UNION ALL
SELECT 
    'EmailConfigurations (mayúsculas)' as tabla, COUNT(*) as registros FROM public."EmailConfigurations"
UNION ALL
SELECT 
    'email_configurations (minúsculas)' as tabla, COUNT(*) as registros FROM public.email_configurations
UNION ALL
SELECT 
    'users' as tabla, COUNT(*) as registros FROM public.users
ORDER BY tabla;

-- Mensaje final
SELECT '✓ Base de datos vaciada exitosamente. Schools, EmailConfigurations conservadas. Users: solo admin y superadmin.' as resultado;

