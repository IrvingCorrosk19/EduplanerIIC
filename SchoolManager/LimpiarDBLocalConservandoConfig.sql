-- ============================================================
-- LIMPIAR BASE DE DATOS LOCAL
-- Conserva: EmailConfiguration, Schools, Usuarios Admin/SuperAdmin
-- Fecha: 18 de Octubre, 2025
-- ============================================================

-- ============================================================
-- PASO 1: Deshabilitar triggers y constraints temporalmente
-- ============================================================
SET session_replication_role = 'replica';

-- ============================================================
-- PASO 2: Eliminar datos de tablas relacionadas con estudiantes
-- ============================================================
DELETE FROM student_activity_scores;
DELETE FROM student_assignments;
DELETE FROM attendance;
DELETE FROM discipline_reports;
DELETE FROM orientation_reports;

-- ============================================================
-- PASO 3: Eliminar actividades y sus archivos adjuntos
-- ============================================================
DELETE FROM activity_attachments;
DELETE FROM activities;

-- ============================================================
-- PASO 4: Eliminar asignaciones académicas
-- ============================================================
DELETE FROM counselor_assignments;
DELETE FROM teacher_assignments;
DELETE FROM subject_assignments;

-- ============================================================
-- PASO 5: Eliminar grupos y niveles
-- ============================================================
DELETE FROM groups;
DELETE FROM grade_levels;

-- ============================================================
-- PASO 6: Eliminar materias, áreas y especialidades
-- ============================================================
DELETE FROM subjects;
DELETE FROM area;
DELETE FROM specialties;

-- ============================================================
-- PASO 7: Eliminar tipos de actividad
-- ============================================================
DELETE FROM activity_types;

-- ============================================================
-- PASO 8: Eliminar trimestres
-- ============================================================
DELETE FROM trimester;

-- ============================================================
-- PASO 9: Eliminar mensajes
-- ============================================================
DELETE FROM messages;

-- ============================================================
-- PASO 10: Eliminar usuarios que NO sean Admin o SuperAdmin
-- ============================================================
DELETE FROM user_sessions WHERE user_id IN (
    SELECT id FROM users WHERE role NOT IN ('admin', 'superadmin')
);

DELETE FROM user_groups WHERE user_id IN (
    SELECT id FROM users WHERE role NOT IN ('admin', 'superadmin')
);

DELETE FROM user_subjects WHERE user_id IN (
    SELECT id FROM users WHERE role NOT IN ('admin', 'superadmin')
);

DELETE FROM users WHERE role NOT IN ('admin', 'superadmin');

-- ============================================================
-- PASO 11: Eliminar configuraciones de seguridad (opcional)
-- ============================================================
DELETE FROM security_settings;

-- ============================================================
-- PASO 12: Limpiar logs de auditoría antiguos (opcional)
-- ============================================================
-- DELETE FROM audit_logs WHERE created_at < NOW() - INTERVAL '30 days';

-- ============================================================
-- PASO 13: Re-habilitar triggers y constraints
-- ============================================================
SET session_replication_role = 'origin';

-- ============================================================
-- PASO 14: Verificar lo que quedó en la base de datos
-- ============================================================
SELECT 'USUARIOS RESTANTES' as categoria, role, COUNT(*) as cantidad
FROM users
GROUP BY role
ORDER BY role;

SELECT 'CONFIGURACIÓN EMAIL' as categoria, COUNT(*) as cantidad
FROM email_configurations;

SELECT 'ESCUELAS' as categoria, COUNT(*) as cantidad
FROM schools;

SELECT 'LOGS DE AUDITORÍA' as categoria, COUNT(*) as cantidad
FROM audit_logs;

-- ============================================================
-- RESUMEN FINAL
-- ============================================================
DO $$
DECLARE
    total_users INTEGER;
    total_admins INTEGER;
    total_superadmins INTEGER;
    total_emails INTEGER;
    total_schools INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_users FROM users;
    SELECT COUNT(*) INTO total_admins FROM users WHERE role = 'admin';
    SELECT COUNT(*) INTO total_superadmins FROM users WHERE role = 'superadmin';
    SELECT COUNT(*) INTO total_emails FROM email_configurations;
    SELECT COUNT(*) INTO total_schools FROM schools;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '✅ BASE DE DATOS LOCAL LIMPIADA';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'Total de usuarios: %', total_users;
    RAISE NOTICE '  - Administradores: %', total_admins;
    RAISE NOTICE '  - Super Administradores: %', total_superadmins;
    RAISE NOTICE 'Configuraciones de email: %', total_emails;
    RAISE NOTICE 'Escuelas: %', total_schools;
    RAISE NOTICE '========================================================';
    RAISE NOTICE '📋 DATOS CONSERVADOS:';
    RAISE NOTICE '  ✓ Usuarios Admin/SuperAdmin';
    RAISE NOTICE '  ✓ Configuraciones de Email';
    RAISE NOTICE '  ✓ Escuelas';
    RAISE NOTICE '  ✓ Logs de Auditoría';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '🗑️ DATOS ELIMINADOS:';
    RAISE NOTICE '  ✗ Estudiantes, Profesores, Orientadores';
    RAISE NOTICE '  ✗ Calificaciones y Actividades';
    RAISE NOTICE '  ✗ Asignaciones Académicas';
    RAISE NOTICE '  ✗ Grupos y Niveles';
    RAISE NOTICE '  ✗ Materias, Áreas, Especialidades';
    RAISE NOTICE '  ✗ Trimestres';
    RAISE NOTICE '  ✗ Mensajes';
    RAISE NOTICE '  ✗ Asistencias';
    RAISE NOTICE '  ✗ Reportes';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;
