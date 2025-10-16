-- ============================================================
-- LIMPIAR BASE DE DATOS - MANTENER SOLO ADMINS Y SUPERADMINS
-- Fecha: 16 de Octubre, 2025
-- Descripción: Elimina todos los datos excepto admins, superadmins
--              y configuración de email
-- ============================================================

BEGIN;

DO $$
DECLARE
    total_users INTEGER;
    total_admins INTEGER;
    total_deleted INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_users FROM users;
    SELECT COUNT(*) INTO total_admins FROM users WHERE role IN ('admin', 'Admin', 'superadmin', 'Superadmin', 'director', 'Director');
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '🧹 INICIANDO LIMPIEZA DE BASE DE DATOS';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'Total de usuarios actual: %', total_users;
    RAISE NOTICE 'Admins/Directors que se mantendrán: %', total_admins;
    RAISE NOTICE '';
END $$;

-- ============================================================
-- PASO 1: Eliminar datos transaccionales
-- ============================================================

-- 1.1 Eliminar mensajes
DELETE FROM messages;

-- 1.2 Eliminar calificaciones de actividades
DELETE FROM student_activity_scores;

-- 1.3 Eliminar actividades
DELETE FROM activities;

-- 1.4 Eliminar adjuntos de actividades
DELETE FROM activity_attachments;

-- 1.5 Eliminar asistencias
DELETE FROM attendance;

-- 1.6 Eliminar reportes de disciplina
DELETE FROM discipline_reports;

-- 1.7 Eliminar reportes de orientación
DELETE FROM orientation_reports;

-- 1.8 Eliminar logs de auditoría
DELETE FROM audit_logs;

-- ============================================================
-- PASO 2: Eliminar asignaciones
-- ============================================================

-- 2.1 Eliminar asignaciones de estudiantes
DELETE FROM student_assignments;

-- 2.2 Eliminar asignaciones de profesores
DELETE FROM teacher_assignments;

-- 2.3 Eliminar asignaciones de materias
DELETE FROM subject_assignments;

-- 2.4 Eliminar asignaciones de consejeros
DELETE FROM counselor_assignments;

-- ============================================================
-- PASO 3: Eliminar estudiantes
-- ============================================================

DELETE FROM students;

-- ============================================================
-- PASO 4: Eliminar relaciones many-to-many de usuarios
-- ============================================================

-- Obtener IDs de usuarios que NO son admin/superadmin/director
DO $$
DECLARE
    user_to_delete UUID;
BEGIN
    FOR user_to_delete IN 
        SELECT id FROM users 
        WHERE role NOT IN ('admin', 'Admin', 'superadmin', 'Superadmin', 'director', 'Director')
    LOOP
        -- Eliminar relaciones de grados
        DELETE FROM user_grades WHERE user_id = user_to_delete;
        
        -- Eliminar relaciones de grupos
        DELETE FROM user_groups WHERE user_id = user_to_delete;
        
        -- Eliminar relaciones de materias
        DELETE FROM user_subjects WHERE user_id = user_to_delete;
    END LOOP;
END $$;

-- ============================================================
-- PASO 5: Eliminar usuarios (excepto admin/superadmin/director)
-- ============================================================

DELETE FROM users 
WHERE role NOT IN ('admin', 'Admin', 'superadmin', 'Superadmin', 'director', 'Director');

-- ============================================================
-- PASO 6: Limpiar catálogos configurables (OPCIONAL)
-- ============================================================

-- 6.1 Limpiar trimestres específicos de escuelas
-- DELETE FROM trimester WHERE school_id IS NOT NULL;

-- 6.2 Limpiar tipos de actividades personalizadas
-- DELETE FROM activity_types WHERE is_global = false;

-- 6.3 Limpiar materias personalizadas
-- DELETE FROM subjects WHERE school_id IS NOT NULL;

-- 6.4 Limpiar grupos
DELETE FROM groups;

-- 6.5 Limpiar niveles de grado personalizados
-- DELETE FROM grade_levels WHERE school_id IS NOT NULL;

-- 6.6 Limpiar especialidades personalizadas
-- DELETE FROM specialties WHERE school_id IS NOT NULL;

-- NOTA: Email configurations SE MANTIENEN (no se tocan)

-- ============================================================
-- PASO 7: Resetear secuencias (si hay)
-- ============================================================

-- PostgreSQL no usa secuencias para UUID, así que no es necesario

-- ============================================================
-- PASO 8: Reporte final
-- ============================================================

DO $$
DECLARE
    total_users_final INTEGER;
    total_admins_final INTEGER;
    total_messages INTEGER;
    total_activities INTEGER;
    total_scores INTEGER;
    total_students INTEGER;
    total_groups INTEGER;
    total_email_configs INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_users_final FROM users;
    SELECT COUNT(*) INTO total_admins_final FROM users WHERE role IN ('admin', 'Admin', 'superadmin', 'Superadmin', 'director', 'Director');
    SELECT COUNT(*) INTO total_messages FROM messages;
    SELECT COUNT(*) INTO total_activities FROM activities;
    SELECT COUNT(*) INTO total_scores FROM student_activity_scores;
    SELECT COUNT(*) INTO total_students FROM students;
    SELECT COUNT(*) INTO total_groups FROM groups;
    SELECT COUNT(*) INTO total_email_configs FROM email_configurations;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '✅ LIMPIEZA COMPLETADA EXITOSAMENTE';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
    RAISE NOTICE '📊 DATOS ELIMINADOS:';
    RAISE NOTICE '   Mensajes: %', total_messages;
    RAISE NOTICE '   Actividades: %', total_activities;
    RAISE NOTICE '   Calificaciones: %', total_scores;
    RAISE NOTICE '   Estudiantes: %', total_students;
    RAISE NOTICE '   Grupos: %', total_groups;
    RAISE NOTICE '';
    RAISE NOTICE '✅ DATOS MANTENIDOS:';
    RAISE NOTICE '   Total usuarios: %', total_users_final;
    RAISE NOTICE '   - Admins/Directors: %', total_admins_final;
    RAISE NOTICE '   Configuraciones de email: %', total_email_configs;
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '🎯 BASE DE DATOS LISTA PARA PRODUCCIÓN';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;

COMMIT;

-- ============================================================
-- VERIFICACIÓN FINAL (opcional - descomenta para ver detalles)
-- ============================================================

/*
-- Ver usuarios que quedaron
SELECT 
    id,
    name,
    last_name,
    email,
    role,
    status
FROM users
ORDER BY role, name;

-- Ver configuraciones de email
SELECT 
    id,
    school_id,
    smtp_server,
    from_email,
    is_active
FROM email_configurations;
*/

