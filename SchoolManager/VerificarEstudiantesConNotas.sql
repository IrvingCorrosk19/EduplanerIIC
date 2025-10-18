-- ============================================================
-- VERIFICAR ESTUDIANTES CON NOTAS EN RENDER
-- ============================================================

-- Total de estudiantes
SELECT 
    'TOTAL ESTUDIANTES' as categoria,
    COUNT(*) as cantidad
FROM users 
WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
AND status = 'active';

-- Estudiantes con notas
SELECT 
    'ESTUDIANTES CON NOTAS' as categoria,
    COUNT(DISTINCT student_id) as cantidad
FROM student_activity_scores;

-- Estudiantes SIN notas
SELECT 
    'ESTUDIANTES SIN NOTAS' as categoria,
    COUNT(*) as cantidad
FROM users u
WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
AND status = 'active'
AND NOT EXISTS (
    SELECT 1 FROM student_activity_scores sas WHERE sas.student_id = u.id
);

-- Detalle de cobertura
SELECT 
    'COBERTURA DE CALIFICACIONES' as categoria,
    (SELECT COUNT(*) FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') AND status = 'active') as total_estudiantes,
    COUNT(DISTINCT student_id) as estudiantes_con_notas,
    ROUND(
        (COUNT(DISTINCT student_id)::DECIMAL / 
        (SELECT COUNT(*) FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') AND status = 'active') * 100), 
        2
    ) as porcentaje_cobertura,
    COUNT(*) as total_calificaciones,
    ROUND(AVG(score), 2) as promedio_general
FROM student_activity_scores;

-- Estudiantes aprobados vs reprobados
SELECT 
    'APROBADOS' as estado,
    COUNT(*) as cantidad,
    ROUND(AVG(promedio), 2) as promedio_grupo
FROM (
    SELECT student_id, AVG(score) as promedio
    FROM student_activity_scores
    GROUP BY student_id
    HAVING AVG(score) >= 3.0
) as aprobados
UNION ALL
SELECT 
    'REPROBADOS' as estado,
    COUNT(*) as cantidad,
    ROUND(AVG(promedio), 2) as promedio_grupo
FROM (
    SELECT student_id, AVG(score) as promedio
    FROM student_activity_scores
    GROUP BY student_id
    HAVING AVG(score) < 3.0
) as reprobados;

-- Muestra de estudiantes SIN notas (si los hay)
SELECT 
    'ESTUDIANTES SIN NOTAS - MUESTRA' as categoria,
    u.name,
    u.last_name,
    u.email,
    u.document_id
FROM users u
WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
AND status = 'active'
AND NOT EXISTS (
    SELECT 1 FROM student_activity_scores sas WHERE sas.student_id = u.id
)
LIMIT 10;
