-- Ver columnas de activities
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'activities'
ORDER BY ordinal_position;

