-- Actualizar todos los registros de la tabla area para activarlos
-- Base de datos: schoolmanagement_xqks en Render
-- Host: dpg-d3jfdcb3fgac73cblbag-a.oregon-postgres.render.com

-- Actualizar is_active a true para todos los registros
UPDATE area SET is_active = true;

-- Verificar los resultados
SELECT area_id, name, is_active 
FROM area 
ORDER BY area_id;

