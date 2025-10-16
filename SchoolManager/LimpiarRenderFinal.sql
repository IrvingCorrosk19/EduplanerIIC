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
    RAISE NOTICE 'Usuarios Admin/SuperAdmin/Director encontrados: %', admin_count;
    RAISE NOTICE '=================================================';
    
    IF admin_count = 0 THEN
        RAISE EXCEPTION 'ERROR: No hay administradores. Abortando.';
    END IF;
END $$;

-- Eliminar todos los datos excepto admin/superadmin
DO $$
BEGIN
    -- Mensajes
    RAISE NOTICE '🗑️ Eliminando mensajes...';
    DELETE FROM messages;

    -- Calificaciones
    RAISE NOTICE '🗑️ Eliminando calificaciones...';
    DELETE FROM student_activity_scores;

    -- Archivos adjuntos
    RAISE NOTICE '🗑️ Eliminando archivos adjuntos...';
    DELETE FROM activity_attachments;

    -- Actividades  
    RAISE NOTICE '🗑️ Eliminando actividades...';
    DELETE FROM activities;

    -- Reportes
    RAISE NOTICE '🗑️ Eliminando reportes de disciplina...';
    DELETE FROM discipline_reports;
    
    RAISE NOTICE '🗑️ Eliminando reportes de orientación...';
    DELETE FROM orientation_reports;

    -- Asignaciones de estudiantes
    RAISE NOTICE '🗑️ Eliminando asignaciones de estudiantes...';
    DELETE FROM student_assignments;

    -- Asignaciones de consejeros
    RAISE NOTICE '🗑️ Eliminando asignaciones de consejeros...';
    DELETE FROM counselor_assignments;

    -- Asignaciones de profesores
    RAISE NOTICE '🗑️ Eliminando asignaciones de profesores...';
    DELETE FROM teacher_assignments;

    -- Asignaciones de materias
    RAISE NOTICE '🗑️ Eliminando asignaciones de materias...';
    DELETE FROM subject_assignments;

    -- Tabla user_grades
    RAISE NOTICE '🗑️ Eliminando user_grades...';
    DELETE FROM user_grades;

    -- Tabla user_groups
    RAISE NOTICE '🗑️ Eliminando user_groups...';
    DELETE FROM user_groups;

    -- Tabla user_subjects
    RAISE NOTICE '🗑️ Eliminando user_subjects...';
    DELETE FROM user_subjects;

    -- Estudiantes
    RAISE NOTICE '🗑️ Eliminando estudiantes...';
    DELETE FROM students;

    -- Grupos
    RAISE NOTICE '🗑️ Eliminando grupos...';
    DELETE FROM groups;

    -- Trimestres (nombre correcto: trimester)
    RAISE NOTICE '🗑️ Eliminando trimestres...';
    DELETE FROM trimester;

    -- Materias
    RAISE NOTICE '🗑️ Eliminando materias...';
    DELETE FROM subjects;

    -- Especialidades
    RAISE NOTICE '🗑️ Eliminando especialidades...';
    DELETE FROM specialties;

    -- Áreas (nombre correcto: area)
    RAISE NOTICE '🗑️ Eliminando áreas...';
    DELETE FROM area;

    -- Niveles de grado
    RAISE NOTICE '🗑️ Eliminando niveles de grado...';
    DELETE FROM grade_levels;

    -- Tipos de actividades
    RAISE NOTICE '🗑️ Eliminando tipos de actividades...';
    DELETE FROM activity_types;

    -- Asistencias (nombre correcto: attendance)
    RAISE NOTICE '🗑️ Eliminando asistencias...';
    DELETE FROM attendance;

    -- Configuraciones de email - NO SE ELIMINAN (se mantienen)
    RAISE NOTICE '✅ Manteniendo configuraciones de email...';

    -- Configuraciones de seguridad
    RAISE NOTICE '🗑️ Eliminando configuraciones de seguridad...';
    DELETE FROM security_settings;

    -- Logs de auditoría
    RAISE NOTICE '🗑️ Eliminando logs de auditoría...';
    DELETE FROM audit_logs 
    WHERE user_id NOT IN (
        SELECT id FROM users 
        WHERE LOWER(role) IN ('admin', 'administrador', 'superadmin', 'director')
    );

    -- Usuarios (excepto Admin, SuperAdmin y Director)
    RAISE NOTICE '🗑️ Eliminando usuarios (excepto administradores)...';
    DELETE FROM users 
    WHERE LOWER(role) NOT IN ('admin', 'administrador', 'superadmin', 'director');

    -- Escuelas sin administradores
    RAISE NOTICE '🗑️ Eliminando escuelas sin administradores...';
    DELETE FROM schools 
    WHERE id NOT IN (
        SELECT DISTINCT school_id FROM users 
        WHERE LOWER(role) IN ('admin', 'administrador', 'superadmin', 'director')
        AND school_id IS NOT NULL
    );
    
    RAISE NOTICE '=================================================';
    RAISE NOTICE '✅ LIMPIEZA COMPLETADA EXITOSAMENTE';
    RAISE NOTICE '=================================================';
END $$;

-- Resumen
DO $$
DECLARE
    users_count INTEGER;
    schools_count INTEGER;
    students_count INTEGER;
    teachers_count INTEGER;
    admins_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO users_count FROM users;
    SELECT COUNT(*) INTO schools_count FROM schools;
    SELECT COUNT(*) INTO students_count FROM students;
    SELECT COUNT(*) INTO teachers_count FROM users WHERE LOWER(role) = 'teacher';
    SELECT COUNT(*) INTO admins_count FROM users WHERE LOWER(role) IN ('admin', 'administrador', 'superadmin', 'director');
    
    RAISE NOTICE '';
    RAISE NOTICE '📊 RESUMEN DE LA BASE DE DATOS:';
    RAISE NOTICE '=================================================';
    RAISE NOTICE 'Total usuarios: %', users_count;
    RAISE NOTICE '  - Administradores: %', admins_count;
    RAISE NOTICE '  - Profesores: %', teachers_count;
    RAISE NOTICE '  - Estudiantes: %', students_count;
    RAISE NOTICE 'Escuelas: %', schools_count;
    RAISE NOTICE '=================================================';
END $$;

COMMIT;

-- Mostrar usuarios restantes
SELECT 
    name,
    last_name,
    email,
    role,
    status
FROM users
ORDER BY 
    CASE role
        WHEN 'superadmin' THEN 1
        WHEN 'admin' THEN 2
        WHEN 'director' THEN 3
        ELSE 4
    END,
    name;

