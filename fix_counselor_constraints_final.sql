-- =====================================================
-- SCRIPT PARA CORREGIR CONSTRAINTS DE COUNSELOR_ASSIGNMENTS
-- =====================================================
-- Este script corrige los constraints problemáticos que impiden
-- asignar múltiples consejeros por grado-grupo

-- Paso 1: Verificar constraints actuales
SELECT 
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename = 'counselor_assignments' 
AND indexname LIKE '%counselor_assignments_school_%key%'
ORDER BY indexname;

-- Paso 2: Eliminar constraints problemáticos
DROP INDEX IF EXISTS counselor_assignments_school_grade_key;
DROP INDEX IF EXISTS counselor_assignments_school_group_key;

-- Paso 3: Crear constraint correcto para combinación grado-grupo
CREATE UNIQUE INDEX counselor_assignments_school_grade_group_key 
ON counselor_assignments (school_id, grade_id, group_id) 
WHERE grade_id IS NOT NULL AND group_id IS NOT NULL;

-- Paso 4: Verificar que se aplicaron los cambios
SELECT 
    indexname,
    indexdef
FROM pg_indexes 
WHERE tablename = 'counselor_assignments' 
AND indexname LIKE '%counselor_assignments_school_%key%'
ORDER BY indexname;

-- Paso 5: Verificar datos existentes (opcional)
SELECT 
    school_id,
    grade_id,
    group_id,
    user_id,
    is_active
FROM counselor_assignments 
WHERE is_active = true
ORDER BY school_id, grade_id, group_id;

-- =====================================================
-- INSTRUCCIONES:
-- =====================================================
-- 1. Ejecuta este script en tu base de datos PostgreSQL
-- 2. Verifica que no haya errores
-- 3. Los constraints problemáticos serán eliminados
-- 4. Se creará el constraint correcto
-- 5. Ahora podrás asignar múltiples consejeros por grado-grupo
-- =====================================================
