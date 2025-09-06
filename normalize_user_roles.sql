-- Script para normalizar roles de usuarios en la base de datos
-- Este script convierte todos los roles inconsistentes a su forma normalizada en inglés

-- 1. Actualizar todos los roles 'estudiante' a 'student'
UPDATE users 
SET role = 'student' 
WHERE role = 'estudiante';

-- 2. Verificar que no hay otros roles inconsistentes
SELECT role, COUNT(*) as cantidad
FROM users 
GROUP BY role 
ORDER BY role;

-- 3. Opcional: Actualizar la constraint para solo permitir roles en inglés
-- (Descomenta las siguientes líneas si quieres eliminar 'estudiante' de la constraint)

-- ALTER TABLE users DROP CONSTRAINT users_role_check;
-- ALTER TABLE users ADD CONSTRAINT users_role_check 
-- CHECK (role::text = ANY (ARRAY[
--     'superadmin'::character varying::text, 
--     'admin'::character varying::text, 
--     'director'::character varying::text, 
--     'teacher'::character varying::text, 
--     'parent'::character varying::text, 
--     'student'::character varying::text
-- ]));

-- 4. Verificar el resultado final
SELECT role, COUNT(*) as cantidad
FROM users 
GROUP BY role 
ORDER BY role;
