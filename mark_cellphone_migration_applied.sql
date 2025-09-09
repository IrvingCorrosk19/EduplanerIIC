-- Script para marcar la migración de campos de celular como aplicada
-- Ejecutar este script en la base de datos PostgreSQL

-- Insertar el registro de la migración en la tabla __EFMigrationsHistory
INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20250108000000_AddCellphoneFieldsToUser', '8.0.0')
ON CONFLICT ("MigrationId") DO NOTHING;

-- Verificar que las columnas existen
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'users' 
AND column_name IN ('cellphone_primary', 'cellphone_secondary');

-- Verificar que la migración fue registrada
SELECT "MigrationId", "ProductVersion" 
FROM "__EFMigrationsHistory" 
WHERE "MigrationId" = '20250108000000_AddCellphoneFieldsToUser';
