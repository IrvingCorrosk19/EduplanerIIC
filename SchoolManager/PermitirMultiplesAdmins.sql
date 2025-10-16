-- ============================================================
-- PERMITIR MÚLTIPLES ADMINISTRADORES POR ESCUELA
-- ============================================================

BEGIN;

-- 1. Quitar índice UNIQUE de admin_id en schools
DROP INDEX IF EXISTS "IX_schools_admin_id";

-- 2. Crear índice NO único (para performance)
CREATE INDEX IF NOT EXISTS idx_schools_admin_id ON schools(admin_id);

-- 3. Verificar cambio
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE tablename = 'schools' 
        AND indexname = 'IX_schools_admin_id'
    ) THEN
        RAISE NOTICE '❌ Índice único todavía existe';
    ELSE
        RAISE NOTICE '✅ Índice único eliminado correctamente';
        RAISE NOTICE '✅ Ahora se pueden crear múltiples admins por escuela';
    END IF;
END $$;

COMMIT;

-- ============================================================
-- VERIFICACIÓN
-- ============================================================

-- Ver índices de schools
SELECT 
    indexname,
    indexdef
FROM pg_indexes
WHERE tablename = 'schools'
ORDER BY indexname;

