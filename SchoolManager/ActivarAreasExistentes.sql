-- =====================================================
-- SCRIPT: Activar Áreas Existentes
-- Descripción: Activa todas las áreas que están inactivas en la base de datos
-- Autor: Sistema EduPlanner
-- Fecha: 2025-01-16
-- =====================================================

-- Mostrar estado antes de la actualización
DO $$
DECLARE
    total_inactivas INT;
BEGIN
    SELECT COUNT(*) INTO total_inactivas FROM area WHERE is_active = false;
    RAISE NOTICE '📊 Áreas inactivas encontradas: %', total_inactivas;
END $$;

-- Activar todas las áreas existentes
UPDATE area 
SET 
    is_active = true,
    updated_at = CURRENT_TIMESTAMP
WHERE is_active = false;

-- Verificar estado después de la actualización
DO $$
DECLARE
    total_activas INT;
    total_inactivas INT;
BEGIN
    SELECT COUNT(*) INTO total_activas FROM area WHERE is_active = true;
    SELECT COUNT(*) INTO total_inactivas FROM area WHERE is_active = false;
    
    RAISE NOTICE '✅ Actualización completada';
    RAISE NOTICE '📊 Áreas activas: %', total_activas;
    RAISE NOTICE '📊 Áreas inactivas: %', total_inactivas;
END $$;

-- Mostrar todas las áreas activas
SELECT 
    name AS "Nombre del Área",
    is_active AS "Activa",
    created_at AS "Fecha de Creación",
    updated_at AS "Última Actualización"
FROM area 
ORDER BY name;

