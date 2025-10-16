-- ============================================================
-- SCRIPT: Verificar existencia de tabla Messages
-- Fecha: 2025-10-16
-- ============================================================

-- Verificar si la tabla existe
SELECT 
    CASE 
        WHEN EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = 'messages'
        ) THEN '✅ La tabla MESSAGES existe'
        ELSE '❌ La tabla MESSAGES NO existe - Debes ejecutar Migrations/CreateMessagesTable.sql'
    END AS estado;

-- Si existe, mostrar información adicional
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'messages') THEN
        RAISE NOTICE '';
        RAISE NOTICE '📊 INFORMACIÓN DE LA TABLA MESSAGES:';
        RAISE NOTICE '================================================';
    END IF;
END $$;

-- Contar registros (si la tabla existe)
SELECT 
    COUNT(*) AS total_mensajes,
    COUNT(*) FILTER (WHERE is_read = false) AS mensajes_no_leidos,
    COUNT(*) FILTER (WHERE is_read = true) AS mensajes_leidos
FROM messages
WHERE EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'messages');

-- Mostrar estructura de columnas (si la tabla existe)
SELECT 
    column_name AS columna,
    data_type AS tipo_dato,
    is_nullable AS permite_null
FROM information_schema.columns
WHERE table_name = 'messages'
AND EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'messages')
ORDER BY ordinal_position;

-- Mostrar índices (si la tabla existe)
SELECT 
    indexname AS nombre_indice,
    indexdef AS definicion
FROM pg_indexes
WHERE tablename = 'messages'
AND EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'messages');

