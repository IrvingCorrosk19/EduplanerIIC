-- =====================================================
-- SCRIPT: Borrar TODO excepto Admin y SuperAdmin
-- DESCRIPCIÓN: Elimina todos los datos de la BD
--              Mantiene solo usuarios admin/superadmin
--              Mantiene tabla emailconfiguration
-- FECHA: 16 de Octubre de 2025
-- =====================================================

BEGIN;

DO $$ BEGIN RAISE NOTICE '⚠️ INICIANDO LIMPIEZA TOTAL DE LA BASE DE DATOS...'; END $$;

-- =====================================================
-- 1. ELIMINAR DATOS DE TODAS LAS TABLAS DEPENDIENTES
-- =====================================================

-- Eliminar calificaciones de actividades
DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando calificaciones...'; END $$;
DELETE FROM student_activity_scores;

-- Eliminar adjuntos de actividades
DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando adjuntos de actividades...'; END $$;
DELETE FROM activity_attachments;

-- Eliminar actividades
DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando actividades...'; END $$;
DELETE FROM activities;

-- Eliminar asignaciones de estudiantes
DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando asignaciones de estudiantes...'; END $$;
DELETE FROM student_assignments;

-- Eliminar asignaciones de profesores
DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando asignaciones de profesores...'; END $$;
DELETE FROM teacher_assignments;

-- Eliminar asignaciones de consejeros
DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando asignaciones de consejeros...'; END $$;
DELETE FROM counselor_assignments;

-- Eliminar asignaciones de materias
DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando asignaciones de materias...'; END $$;
DELETE FROM subject_assignments;

-- Eliminar reportes de disciplina
DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando reportes de disciplina...'; END $$;
DELETE FROM discipline_reports;

-- Eliminar reportes de orientación
DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando reportes de orientación...'; END $$;
DELETE FROM orientation_reports;

-- Eliminar mensajes
DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando mensajes...'; END $$;
DELETE FROM messages;

-- Eliminar asistencias
DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando asistencias...'; END $$;
DELETE FROM attendance;

-- Eliminar logs de auditoría
DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando logs de auditoría...'; END $$;
DELETE FROM audit_logs;

-- Eliminar configuraciones de seguridad
DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando configuraciones de seguridad...'; END $$;
DELETE FROM security_settings;

-- Eliminar relaciones usuario-grado
DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando relaciones usuario-grado...'; END $$;
DELETE FROM user_grades;

-- Eliminar relaciones usuario-grupo
DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando relaciones usuario-grupo...'; END $$;
DELETE FROM user_groups;

-- Eliminar relaciones usuario-materia
DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando relaciones usuario-materia...'; END $$;
DELETE FROM user_subjects;

-- Eliminar estudiantes
DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando tabla students...'; END $$;
DELETE FROM students;

-- =====================================================
-- 2. ELIMINAR USUARIOS (excepto admin y superadmin)
-- =====================================================

DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando todos los usuarios excepto admin y superadmin...'; END $$;
DELETE FROM users 
WHERE LOWER(role) NOT IN ('admin', 'superadmin');

-- =====================================================
-- 3. ELIMINAR CATÁLOGOS ACADÉMICOS
-- =====================================================

-- Eliminar tipos de actividades
DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando tipos de actividades...'; END $$;
DELETE FROM activity_types;

-- Eliminar trimestres
DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando trimestres...'; END $$;
DELETE FROM trimester;

-- Eliminar materias
DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando materias...'; END $$;
DELETE FROM subjects;

-- Eliminar áreas
DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando áreas...'; END $$;
DELETE FROM area;

-- Eliminar especialidades
DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando especialidades...'; END $$;
DELETE FROM specialties;

-- Eliminar grupos
DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando grupos...'; END $$;
DELETE FROM groups;

-- Eliminar niveles de grado
DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando niveles de grado...'; END $$;
DELETE FROM grade_levels;

-- =====================================================
-- 4. ELIMINAR ESCUELAS
-- =====================================================

DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando escuelas...'; END $$;
DELETE FROM schools;

-- =====================================================
-- 5. VERIFICAR ESTADO FINAL
-- =====================================================

DO $$
DECLARE
    total_users INT;
    admin_count INT;
    superadmin_count INT;
    total_schools INT;
    total_subjects INT;
    total_activities INT;
    total_messages INT;
    total_email_configs INT;
BEGIN
    SELECT COUNT(*) INTO total_users FROM users;
    SELECT COUNT(*) INTO admin_count FROM users WHERE LOWER(role) = 'admin';
    SELECT COUNT(*) INTO superadmin_count FROM users WHERE LOWER(role) = 'superadmin';
    SELECT COUNT(*) INTO total_schools FROM schools;
    SELECT COUNT(*) INTO total_subjects FROM subjects;
    SELECT COUNT(*) INTO total_activities FROM activities;
    SELECT COUNT(*) INTO total_messages FROM messages;
    SELECT COUNT(*) INTO total_email_configs FROM email_configurations;
    
    RAISE NOTICE '==============================================';
    RAISE NOTICE '✅ LIMPIEZA TOTAL COMPLETADA';
    RAISE NOTICE '==============================================';
    RAISE NOTICE '👥 USUARIOS:';
    RAISE NOTICE '   Total usuarios: %', total_users;
    RAISE NOTICE '   Administradores: %', admin_count;
    RAISE NOTICE '   SuperAdmins: %', superadmin_count;
    RAISE NOTICE '';
    RAISE NOTICE '🏫 DATOS DEL SISTEMA:';
    RAISE NOTICE '   Escuelas: %', total_schools;
    RAISE NOTICE '   Materias: %', total_subjects;
    RAISE NOTICE '   Actividades: %', total_activities;
    RAISE NOTICE '   Mensajes: %', total_messages;
    RAISE NOTICE '   Configuraciones de Email: %', total_email_configs;
    RAISE NOTICE '==============================================';
END $$;

-- Mostrar los usuarios que quedan
DO $$ BEGIN RAISE NOTICE '📋 USUARIOS RESTANTES:'; END $$;

SELECT 
    id,
    name,
    last_name,
    email,
    role,
    status
FROM users
ORDER BY role, name;

DO $$ BEGIN RAISE NOTICE '✅ TRANSACCIÓN COMPLETADA - LA BASE DE DATOS ESTÁ LIMPIA'; END $$;

COMMIT;
