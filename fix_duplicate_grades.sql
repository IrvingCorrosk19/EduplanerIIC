-- Script para identificar y corregir calificaciones duplicadas
-- Ejecutar en la base de datos PostgreSQL

-- 1. Identificar registros duplicados en StudentActivityScores
SELECT 
    sas.student_id,
    sas.activity_id,
    COUNT(*) as duplicate_count
FROM student_activity_scores sas
GROUP BY sas.student_id, sas.activity_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- 2. Ver las calificaciones duplicadas para un estudiante específico
-- (Reemplazar 'STUDENT_ID_AQUI' con el ID real del estudiante)
SELECT 
    sas.id,
    sas.student_id,
    sas.activity_id,
    sas.score,
    sas.created_at,
    a.name as activity_name,
    a.trimester
FROM student_activity_scores sas
JOIN activities a ON sas.activity_id = a.id
WHERE sas.student_id = 'STUDENT_ID_AQUI'  -- Reemplazar con ID real
ORDER BY a.name, sas.created_at DESC;

-- 3. Eliminar duplicados manteniendo solo el registro más reciente
-- CUIDADO: Hacer backup antes de ejecutar
WITH duplicates AS (
    SELECT 
        sas.id,
        ROW_NUMBER() OVER (
            PARTITION BY sas.student_id, sas.activity_id 
            ORDER BY sas.created_at DESC
        ) as rn
    FROM student_activity_scores sas
)
DELETE FROM student_activity_scores 
WHERE id IN (
    SELECT id FROM duplicates WHERE rn > 1
);

-- 4. Verificar que no queden duplicados
SELECT 
    sas.student_id,
    sas.activity_id,
    COUNT(*) as count
FROM student_activity_scores sas
GROUP BY sas.student_id, sas.activity_id
HAVING COUNT(*) > 1;
