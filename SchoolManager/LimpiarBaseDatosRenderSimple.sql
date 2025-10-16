-- ============================================================
-- LIMPIEZA COMPLETA - MANTENER SOLO ADMIN Y SUPERADMIN
-- Fecha: 2025-10-15
-- ============================================================

BEGIN;

-- Verificar administradores
DO $$
DECLARE
    admin_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO admin_count 
    FROM users 
    WHERE LOWER(role) IN ('admin', 'administrador', 'superadmin', 'director');
    
    RAISE NOTICE '=================================================';
    RAISE NOTICE 'Usuarios Admin/SuperAdmin encontrados: %', admin_count;
    RAISE NOTICE '=================================================';
    
    IF admin_count = 0 THEN
        RAISE EXCEPTION 'ERROR: No hay administradores. Abortando.';
    END IF;
END $$;

-- Eliminar en orden correcto (de lo más dependiente a lo menos)
DO $$
BEGIN
    -- Mensajes
    RAISE NOTICE 'Eliminando mensajes...';
    DELETE FROM messages;

    -- Calificaciones
    RAISE NOTICE 'Eliminando calificaciones...';
    DELETE FROM student_activity_scores;

    -- Archivos adjuntos
    RAISE NOTICE 'Eliminando archivos adjuntos...';
    DELETE FROM activity_attachments;

    -- Actividades  
    RAISE NOTICE 'Eliminando actividades...';
    DELETE FROM activities;

    -- Reportes
    RAISE NOTICE 'Eliminando reportes de disciplina...';
    DELETE FROM discipline_reports;
    
    RAISE NOTICE 'Eliminando reportes de orientación...';
    DELETE FROM orientation_reports;

    -- Asignaciones de estudiantes
    RAISE NOTICE 'Eliminando asignaciones de estudiantes...';
    DELETE FROM student_assignments;

    -- Asignaciones de consejeros
    RAISE NOTICE 'Eliminando asignaciones de consejeros...';
    DELETE FROM counselor_assignments;

    -- Asignaciones de profesores
    RAISE NOTICE 'Eliminando asignaciones de profesores...';
    DELETE FROM teacher_assignments;

    -- Asignaciones de materias
    RAISE NOTICE 'Eliminando asignaciones de materias...';
    DELETE FROM subject_assignments;

    -- Estudiantes
    RAISE NOTICE 'Eliminando estudiantes...';
    DELETE FROM students;

    -- Grupos
    RAISE NOTICE 'Eliminando grupos...';
    DELETE FROM groups;

    -- Trimestres
    RAISE NOTICE 'Eliminando trimestres...';
    DELETE FROM trimesters;

    -- Materias
    RAISE NOTICE 'Eliminando materias...';
    DELETE FROM subjects;

    -- Especialidades
    RAISE NOTICE 'Eliminando especialidades...';
    DELETE FROM specialties;

    -- Áreas
    RAISE NOTICE 'Eliminando áreas...';
    DELETE FROM areas;

    -- Niveles de grado
    RAISE NOTICE 'Eliminando niveles de grado...';
    DELETE FROM grade_levels;

    -- Tipos de actividades
    RAISE NOTICE 'Eliminando tipos de actividades...';
    DELETE FROM activity_types;

    -- Configuraciones
    RAISE NOTICE 'Eliminando configuraciones de email...';
    DELETE FROM email_configurations;

    RAISE NOTICE 'Eliminando configuraciones de seguridad...';
    DELETE FROM security_settings;

    -- Logs de auditoría (excepto de admin/superadmin)
    RAISE NOTICE 'Eliminando logs de auditoría...';
    DELETE FROM audit_logs 
    WHERE user_id NOT IN (
        SELECT id FROM users 
        WHERE LOWER(role) IN ('admin', 'administrador', 'superadmin', 'director')
    );

    -- Usuarios (excepto Admin, SuperAdmin y Director)
    RAISE NOTICE 'Eliminando usuarios que NO son administradores...';
    DELETE FROM users 
    WHERE LOWER(role) NOT IN ('admin', 'administrador', 'superadmin', 'director');

    -- Escuelas sin administradores
    RAISE NOTICE 'Eliminando escuelas sin administradores...';
    DELETE FROM schools 
    WHERE id NOT IN (
        SELECT DISTINCT school_id FROM users 
        WHERE LOWER(role) IN ('admin', 'administrador', 'superadmin', 'director')
        AND school_id IS NOT NULL
    );
END $$;

-- Resumen
DO $$
DECLARE
    users_count INTEGER;
    schools_count INTEGER;
    messages_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO users_count FROM users;
    SELECT COUNT(*) INTO schools_count FROM schools;
    SELECT COUNT(*) INTO messages_count FROM messages;
    
    RAISE NOTICE '=================================================';
    RAISE NOTICE '✅ LIMPIEZA COMPLETADA';
    RAISE NOTICE '=================================================';
    RAISE NOTICE 'Usuarios restantes: %', users_count;
    RAISE NOTICE 'Escuelas restantes: %', schools_count;
    RAISE NOTICE 'Mensajes restantes: %', messages_count;
    RAISE NOTICE '=================================================';
END $$;

COMMIT;

-- Mostrar usuarios que quedaron
SELECT 
    name,
    last_name,
    email,
    role,
    status
FROM users
ORDER BY role, name;

