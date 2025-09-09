-- Script para corregir SOLO los constraints de counselor_assignments
-- Sin tocar email_configurations

-- Verificar si la tabla counselor_assignments existe
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'counselor_assignments') THEN
        -- Eliminar constraints problemáticos si existen
        DROP INDEX IF EXISTS counselor_assignments_school_grade_key;
        DROP INDEX IF EXISTS counselor_assignments_school_group_key;
        
        -- Crear el constraint correcto para combinación grado-grupo única
        CREATE UNIQUE INDEX IF NOT EXISTS counselor_assignments_school_grade_group_key 
        ON counselor_assignments (school_id, grade_id, group_id) 
        WHERE grade_id IS NOT NULL AND group_id IS NOT NULL;
        
        RAISE NOTICE 'Constraints de counselor_assignments corregidos exitosamente';
    ELSE
        RAISE NOTICE 'La tabla counselor_assignments no existe aún';
    END IF;
END $$;
