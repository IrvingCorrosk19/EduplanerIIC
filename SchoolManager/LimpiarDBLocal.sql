-- =====================================================
-- SCRIPT: Limpiar Base de Datos Local - SIMPLIFICADO
-- DESCRIPCIÓN: Elimina todos los usuarios excepto admin y superadmin
--              Elimina los datos de emailconfiguration
-- FECHA: 16 de Octubre de 2025
-- =====================================================

BEGIN;

-- =====================================================
-- 1. MOSTRAR INFORMACIÓN ANTES DE LIMPIAR
-- =====================================================
DO $$
DECLARE
    total_users INT;
    admin_count INT;
    superadmin_count INT;
    other_users INT;
BEGIN
    SELECT COUNT(*) INTO total_users FROM users;
    SELECT COUNT(*) INTO admin_count FROM users WHERE LOWER(role) = 'admin';
    SELECT COUNT(*) INTO superadmin_count FROM users WHERE LOWER(role) = 'superadmin';
    SELECT COUNT(*) INTO other_users FROM users WHERE LOWER(role) NOT IN ('admin', 'superadmin');
    
    RAISE NOTICE '==============================================';
    RAISE NOTICE '📊 ESTADO ACTUAL DE LA BASE DE DATOS';
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'Total de usuarios: %', total_users;
    RAISE NOTICE 'Administradores: %', admin_count;
    RAISE NOTICE 'SuperAdmins: %', superadmin_count;
    RAISE NOTICE 'Otros usuarios (a eliminar): %', other_users;
    RAISE NOTICE '==============================================';
END $$;

-- =====================================================
-- 2. ELIMINAR DATOS DE TABLAS RELACIONADAS
-- =====================================================

DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando datos de tablas relacionadas...'; END $$;

-- Eliminar asignaciones de estudiantes
DELETE FROM student_assignments 
WHERE student_id IN (
    SELECT id FROM users 
    WHERE LOWER(role) NOT IN ('admin', 'superadmin')
);

DO $$ BEGIN RAISE NOTICE '✅ Asignaciones de estudiantes eliminadas'; END $$;

-- Eliminar asignaciones de profesores
DELETE FROM teacher_assignments 
WHERE teacher_id IN (
    SELECT id FROM users 
    WHERE LOWER(role) NOT IN ('admin', 'superadmin')
);

DO $$ BEGIN RAISE NOTICE '✅ Asignaciones de profesores eliminadas'; END $$;

-- Eliminar asignaciones de consejeros
DELETE FROM counselor_assignments 
WHERE user_id IN (
    SELECT id FROM users 
    WHERE LOWER(role) NOT IN ('admin', 'superadmin')
);

DO $$ BEGIN RAISE NOTICE '✅ Asignaciones de consejeros eliminadas'; END $$;

-- Eliminar calificaciones de actividades
DELETE FROM student_activity_scores 
WHERE activity_id IN (
    SELECT id FROM activities 
    WHERE teacher_id IN (
        SELECT id FROM users 
        WHERE LOWER(role) NOT IN ('admin', 'superadmin')
    )
);

DO $$ BEGIN RAISE NOTICE '✅ Calificaciones de actividades eliminadas'; END $$;

-- Eliminar actividades
DELETE FROM activities 
WHERE teacher_id IN (
    SELECT id FROM users 
    WHERE LOWER(role) NOT IN ('admin', 'superadmin')
);

DO $$ BEGIN RAISE NOTICE '✅ Actividades eliminadas'; END $$;

-- Eliminar reportes de disciplina
DELETE FROM discipline_reports 
WHERE student_id IN (
    SELECT id FROM users 
    WHERE LOWER(role) NOT IN ('admin', 'superadmin')
)
OR teacher_id IN (
    SELECT id FROM users 
    WHERE LOWER(role) NOT IN ('admin', 'superadmin')
);

DO $$ BEGIN RAISE NOTICE '✅ Reportes de disciplina eliminados'; END $$;

-- Eliminar reportes de orientación
DELETE FROM orientation_reports 
WHERE student_id IN (
    SELECT id FROM users 
    WHERE LOWER(role) NOT IN ('admin', 'superadmin')
)
OR teacher_id IN (
    SELECT id FROM users 
    WHERE LOWER(role) NOT IN ('admin', 'superadmin')
);

DO $$ BEGIN RAISE NOTICE '✅ Reportes de orientación eliminados'; END $$;

-- Eliminar mensajes
DELETE FROM messages 
WHERE sender_id IN (
    SELECT id FROM users 
    WHERE LOWER(role) NOT IN ('admin', 'superadmin')
)
OR recipient_id IN (
    SELECT id FROM users 
    WHERE LOWER(role) NOT IN ('admin', 'superadmin')
);

DO $$ BEGIN RAISE NOTICE '✅ Mensajes eliminados'; END $$;

-- =====================================================
-- 3. ELIMINAR USUARIOS (excepto admin y superadmin)
-- =====================================================

DO $$ BEGIN RAISE NOTICE '🗑️ Eliminando usuarios que no son admin ni superadmin...'; END $$;

DELETE FROM users 
WHERE LOWER(role) NOT IN ('admin', 'superadmin');

DO $$ BEGIN RAISE NOTICE '✅ Usuarios eliminados exitosamente'; END $$;

-- =====================================================
-- 4. LIMPIAR TABLA DE CONFIGURACIÓN DE EMAIL
-- =====================================================

DO $$ BEGIN RAISE NOTICE '🗑️ Limpiando tabla de configuración de email...'; END $$;

DELETE FROM email_configurations;

DO $$ BEGIN RAISE NOTICE '✅ Configuraciones de email eliminadas'; END $$;

-- =====================================================
-- 5. MOSTRAR INFORMACIÓN DESPUÉS DE LIMPIAR
-- =====================================================
DO $$
DECLARE
    total_users INT;
    admin_count INT;
    superadmin_count INT;
BEGIN
    SELECT COUNT(*) INTO total_users FROM users;
    SELECT COUNT(*) INTO admin_count FROM users WHERE LOWER(role) = 'admin';
    SELECT COUNT(*) INTO superadmin_count FROM users WHERE LOWER(role) = 'superadmin';
    
    RAISE NOTICE '==============================================';
    RAISE NOTICE '✅ LIMPIEZA COMPLETADA';
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'Total de usuarios restantes: %', total_users;
    RAISE NOTICE 'Administradores: %', admin_count;
    RAISE NOTICE 'SuperAdmins: %', superadmin_count;
    RAISE NOTICE '==============================================';
    RAISE NOTICE '📋 USUARIOS RESTANTES:';
END $$;

-- Mostrar los usuarios que quedan
SELECT 
    id,
    name,
    last_name,
    email,
    role,
    status
FROM users
ORDER BY role, name;

DO $$ BEGIN RAISE NOTICE '✅ TRANSACCIÓN COMPLETADA EXITOSAMENTE'; END $$;

COMMIT;
