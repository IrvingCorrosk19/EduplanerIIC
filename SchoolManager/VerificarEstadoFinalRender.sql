-- ============================================================
-- VERIFICAR ESTADO FINAL DE RENDER
-- ============================================================

-- Resumen general
SELECT 
    'RESUMEN GENERAL' as categoria,
    (SELECT COUNT(*) FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') AND status = 'active') as estudiantes_activos,
    (SELECT COUNT(DISTINCT student_id) FROM student_activity_scores) as estudiantes_con_notas,
    (SELECT COUNT(*) FROM users WHERE role IN ('teacher', 'Teacher', 'docente', 'Docente') AND status = 'active') as profesores,
    (SELECT COUNT(*) FROM activities) as actividades,
    (SELECT COUNT(*) FROM student_activity_scores) as calificaciones_totales,
    (SELECT ROUND(AVG(score), 2) FROM student_activity_scores) as promedio_general;

-- Estudiantes con y sin notas
SELECT 
    'COBERTURA DE ESTUDIANTES' as categoria,
    COUNT(DISTINCT u.id) as total_estudiantes,
    COUNT(DISTINCT CASE WHEN sas.student_id IS NOT NULL THEN u.id END) as con_notas,
    COUNT(DISTINCT CASE WHEN sas.student_id IS NULL THEN u.id END) as sin_notas,
    ROUND(COUNT(DISTINCT CASE WHEN sas.student_id IS NOT NULL THEN u.id END)::DECIMAL / COUNT(DISTINCT u.id) * 100, 2) as porcentaje_cobertura
FROM users u
LEFT JOIN student_activity_scores sas ON u.id = sas.student_id
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante') AND u.status = 'active';

-- Distribución de aprobados y reprobados
SELECT 
    'APROBADOS Y REPROBADOS' as categoria,
    COUNT(DISTINCT CASE WHEN promedio >= 3.0 THEN student_id END) as aprobados,
    COUNT(DISTINCT CASE WHEN promedio < 3.0 THEN student_id END) as reprobados,
    ROUND(COUNT(DISTINCT CASE WHEN promedio >= 3.0 THEN student_id END)::DECIMAL / COUNT(DISTINCT student_id) * 100, 2) as porcentaje_aprobados,
    ROUND(COUNT(DISTINCT CASE WHEN promedio < 3.0 THEN student_id END)::DECIMAL / COUNT(DISTINCT student_id) * 100, 2) as porcentaje_reprobados
FROM (
    SELECT student_id, AVG(score) as promedio
    FROM student_activity_scores
    GROUP BY student_id
) promedios;

-- Actividades por trimestre
SELECT 
    trimester as trimestre,
    COUNT(*) as total_actividades,
    COUNT(DISTINCT subject_id) as materias_cubiertas,
    COUNT(DISTINCT teacher_id) as profesores_asignados
FROM activities
GROUP BY trimester
ORDER BY trimester;
