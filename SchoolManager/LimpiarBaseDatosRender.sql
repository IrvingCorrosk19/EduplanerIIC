-- ============================================================
-- LIMPIEZA COMPLETA DE BASE DE DATOS - MANTENER SOLO ADMIN Y SUPERADMIN
-- Fecha: 2025-10-15
-- ADVERTENCIA: Esta operación eliminará TODOS los datos excepto
--              usuarios con rol Admin y SuperAdmin
-- ============================================================

-- Iniciar transacción para poder revertir si algo sale mal
BEGIN;

DO $$
DECLARE
    admin_count INTEGER;
    superadmin_count INTEGER;
BEGIN
    -- Verificar que existen usuarios admin y superadmin
    SELECT COUNT(*) INTO admin_count FROM users WHERE LOWER(role) IN ('admin', 'administrador');
    SELECT COUNT(*) INTO superadmin_count FROM users WHERE LOWER(role) = 'superadmin';
    
    RAISE NOTICE '=================================================';
    RAISE NOTICE 'Usuarios Admin encontrados: %', admin_count;
    RAISE NOTICE 'Usuarios SuperAdmin encontrados: %', superadmin_count;
    RAISE NOTICE '=================================================';
    
    IF admin_count = 0 AND superadmin_count = 0 THEN
        RAISE EXCEPTION 'ERROR: No se encontraron usuarios Admin o SuperAdmin. Abortando operación.';
    END IF;
END $$;

-- ============================================================
-- ELIMINAR TODOS LOS DATOS
-- ============================================================
DO $$
BEGIN
    -- PASO 1: Eliminar mensajes
    RAISE NOTICE 'Eliminando mensajes...';
    DELETE FROM messages 
    WHERE sender_id NOT IN (
        SELECT id FROM users WHERE LOWER(role) IN ('admin', 'administrador', 'superadmin')
    )
    OR recipient_id NOT IN (
        SELECT id FROM users WHERE LOWER(role) IN ('admin', 'administrador', 'superadmin')
    );

    -- PASO 2: Eliminar calificaciones y actividades
    RAISE NOTICE 'Eliminando calificaciones de estudiantes...';
    DELETE FROM student_activity_scores;

    RAISE NOTICE 'Eliminando archivos adjuntos de actividades...';
    DELETE FROM activity_attachments;

    RAISE NOTICE 'Eliminando actividades...';
    DELETE FROM activities;

    -- PASO 3: Eliminar asistencias
    RAISE NOTICE 'Eliminando registros de asistencia...';
    DELETE FROM attendances;

    -- PASO 4: Eliminar reportes
    RAISE NOTICE 'Eliminando reportes de disciplina...';
    DELETE FROM discipline_reports;

    RAISE NOTICE 'Eliminando reportes de orientación...';
    DELETE FROM orientation_reports;

    -- PASO 5: Eliminar asignaciones de estudiantes
    RAISE NOTICE 'Eliminando asignaciones de estudiantes...';
    DELETE FROM student_assignments;

    -- PASO 6: Eliminar asignaciones de consejeros
    RAISE NOTICE 'Eliminando asignaciones de consejeros...';
    DELETE FROM counselor_assignments;

    -- PASO 7: Eliminar asignaciones de profesores y materias
    RAISE NOTICE 'Eliminando asignaciones de profesores...';
    DELETE FROM teacher_assignments;

    RAISE NOTICE 'Eliminando asignaciones de materias...';
    DELETE FROM subject_assignments;

    -- PASO 8: Eliminar estudiantes
    RAISE NOTICE 'Eliminando estudiantes...';
    DELETE FROM students;

    -- PASO 9: Eliminar grupos
    RAISE NOTICE 'Eliminando grupos...';
    DELETE FROM groups;

    -- PASO 10: Eliminar trimestres
    RAISE NOTICE 'Eliminando trimestres...';
    DELETE FROM trimesters;

    -- PASO 11: Eliminar materias
    RAISE NOTICE 'Eliminando materias...';
    DELETE FROM subjects;

    -- PASO 12: Eliminar especialidades
    RAISE NOTICE 'Eliminando especialidades...';
    DELETE FROM specialties;

    -- PASO 13: Eliminar áreas
    RAISE NOTICE 'Eliminando áreas...';
    DELETE FROM areas;

    -- PASO 14: Eliminar niveles de grado
    RAISE NOTICE 'Eliminando niveles de grado...';
    DELETE FROM grade_levels;

    -- PASO 15: Eliminar tipos de actividades
    RAISE NOTICE 'Eliminando tipos de actividades...';
    DELETE FROM activity_types;

    -- PASO 16: Eliminar configuraciones de email
    RAISE NOTICE 'Eliminando configuraciones de email...';
    DELETE FROM email_configurations;

    -- PASO 17: Eliminar configuraciones de seguridad
    RAISE NOTICE 'Eliminando configuraciones de seguridad...';
    DELETE FROM security_settings;

    -- PASO 18: Eliminar logs de auditoría
    RAISE NOTICE 'Eliminando logs de auditoría...';
    DELETE FROM audit_logs 
    WHERE user_id NOT IN (
        SELECT id FROM users WHERE LOWER(role) IN ('admin', 'administrador', 'superadmin')
    );

    -- PASO 19: Eliminar usuarios que NO sean Admin o SuperAdmin
    RAISE NOTICE 'Eliminando usuarios (excepto Admin y SuperAdmin)...';
    DELETE FROM users 
    WHERE LOWER(role) NOT IN ('admin', 'administrador', 'superadmin');

    -- PASO 20: Eliminar escuelas sin administradores
    RAISE NOTICE 'Eliminando escuelas sin administradores...';
    DELETE FROM schools 
    WHERE id NOT IN (
        SELECT DISTINCT school_id FROM users 
        WHERE LOWER(role) IN ('admin', 'administrador', 'superadmin')
        AND school_id IS NOT NULL
    );
END $$;

-- ============================================================
-- RESUMEN FINAL
-- ============================================================
DO $$
DECLARE
    users_remaining INTEGER;
    schools_remaining INTEGER;
    messages_remaining INTEGER;
BEGIN
    SELECT COUNT(*) INTO users_remaining FROM users;
    SELECT COUNT(*) INTO schools_remaining FROM schools;
    SELECT COUNT(*) INTO messages_remaining FROM messages;
    
    RAISE NOTICE '=================================================';
    RAISE NOTICE '✅ LIMPIEZA COMPLETADA EXITOSAMENTE';
    RAISE NOTICE '=================================================';
    RAISE NOTICE 'Usuarios restantes: %', users_remaining;
    RAISE NOTICE 'Escuelas restantes: %', schools_remaining;
    RAISE NOTICE 'Mensajes restantes: %', messages_remaining;
    RAISE NOTICE '=================================================';
    RAISE NOTICE 'Todos los demás datos han sido eliminados.';
    RAISE NOTICE '=================================================';
END $$;

-- Confirmar la transacción
COMMIT;

-- ============================================================
-- VERIFICACIÓN ADICIONAL
-- ============================================================
SELECT 
    id,
    name,
    last_name,
    email,
    role,
    status,
    school_id
FROM users
ORDER BY role, name;

