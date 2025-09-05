-- Script para limpiar las tablas que se llenan con SaveAssignmentsFromExcel
-- IMPORTANTE: Ejecutar en el orden correcto debido a las foreign keys

-- 1. Limpiar teacher_assignments (tabla de asignaciones de profesores)
DELETE FROM teacher_assignments;

-- 2. Limpiar subject_assignments (tabla de asignaciones académicas)
DELETE FROM subject_assignments;

-- 3. Limpiar users con rol Teacher (profesores creados automáticamente)
DELETE FROM users WHERE role = 'Teacher';

-- 4. Limpiar grupos creados
DELETE FROM groups;

-- 5. Limpiar materias (subjects) creadas
DELETE FROM subjects;

-- 6. Limpiar áreas creadas
DELETE FROM area;

-- 7. Limpiar especialidades creadas
DELETE FROM specialties;

-- 8. Limpiar niveles de grado creados
DELETE FROM grade_levels;

-- Verificar que las tablas estén vacías
SELECT 'teacher_assignments' as tabla, COUNT(*) as registros FROM teacher_assignments
UNION ALL
SELECT 'subject_assignments' as tabla, COUNT(*) as registros FROM subject_assignments
UNION ALL
SELECT 'users (Teachers)' as tabla, COUNT(*) as registros FROM users WHERE role = 'Teacher'
UNION ALL
SELECT 'groups' as tabla, COUNT(*) as registros FROM groups
UNION ALL
SELECT 'subjects' as tabla, COUNT(*) as registros FROM subjects
UNION ALL
SELECT 'area' as tabla, COUNT(*) as registros FROM area
UNION ALL
SELECT 'specialties' as tabla, COUNT(*) as registros FROM specialties
UNION ALL
SELECT 'grade_levels' as tabla, COUNT(*) as registros FROM grade_levels;
