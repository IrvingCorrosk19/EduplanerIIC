-- Script para corregir los constraints de la tabla counselor_assignments
-- Eliminar constraints problemáticos y crear los correctos

-- Eliminar constraints existentes problemáticos
DROP INDEX IF EXISTS counselor_assignments_school_grade_key;
DROP INDEX IF EXISTS counselor_assignments_school_group_key;

-- Crear el constraint correcto para combinación grado-grupo única
CREATE UNIQUE INDEX counselor_assignments_school_grade_group_key 
ON counselor_assignments (school_id, grade_id, group_id) 
WHERE grade_id IS NOT NULL AND group_id IS NOT NULL;

-- Verificar que la tabla existe y tiene la estructura correcta
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'counselor_assignments' 
ORDER BY ordinal_position;
