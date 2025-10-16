-- ============================================================
-- VERIFICAR TABLA MESSAGES EN RENDER
-- ============================================================
-- Conexión Render:
-- Host: dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com
-- Database: schoolmanagement_xqks
-- Username: admin
-- Password: 2c2GygJl2ArUP5fKuFDsRtWFYC4NJdtk
-- Port: 5432
-- SSL: Required
-- ============================================================

-- 1. Verificar si la tabla messages existe
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = 'messages'
        ) THEN '✅ La tabla MESSAGES existe en RENDER'
        ELSE '❌ La tabla MESSAGES NO existe en RENDER'
    END AS estado_messages;

-- 2. Verificar si la tabla activities existe y sus columnas
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'activities'
ORDER BY ordinal_position;

-- 3. Verificar específicamente ActivityTypeId en activities
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM information_schema.columns 
            WHERE table_name = 'activities' 
            AND column_name = 'ActivityTypeId'
        ) THEN '✅ activities tiene ActivityTypeId (PascalCase)'
        WHEN EXISTS (
            SELECT 1 
            FROM information_schema.columns 
            WHERE table_name = 'activities' 
            AND column_name = 'activity_type_id'
        ) THEN '✅ activities tiene activity_type_id (snake_case)'
        ELSE '❌ activities NO tiene columna de tipo de actividad'
    END AS estado_activity_type;

-- 4. Comparar número de columnas entre LOCAL y RENDER
SELECT 
    COUNT(*) as total_columnas_activities
FROM information_schema.columns
WHERE table_name = 'activities';

-- 5. Ver todas las tablas disponibles
SELECT 
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as columnas
FROM information_schema.tables t
WHERE table_schema = 'public'
ORDER BY table_name;

