-- ============================================================
-- CORREGIR NOTAS NEGATIVAS
-- Fecha: 16 de Octubre, 2025
-- Descripción: Corrige las notas negativas para que estén en rango 0-5
-- ============================================================

-- ============================================================
-- PASO 1: Corregir notas negativas
-- ============================================================
UPDATE student_activity_scores 
SET score = ABS(score)
WHERE score < 0;

-- ============================================================
-- PASO 2: Asegurar que todas las notas estén en rango 0-5
-- ============================================================
UPDATE student_activity_scores 
SET score = CASE 
    WHEN score > 5.0 THEN 5.0
    WHEN score < 0.0 THEN 0.0
    ELSE score
END;

-- ============================================================
-- PASO 3: Verificar resultados finales
-- ============================================================
SELECT 
    'DISTRIBUCIÓN FINAL DE NOTAS' as categoria,
    COUNT(*) as total_calificaciones,
    ROUND(AVG(score), 2) as promedio_general,
    ROUND(MIN(score), 2) as nota_minima,
    ROUND(MAX(score), 2) as nota_maxima,
    COUNT(CASE WHEN score >= 3.0 THEN 1 END) as notas_aprobadas,
    COUNT(CASE WHEN score < 3.0 THEN 1 END) as notas_reprobadas,
    ROUND(COUNT(CASE WHEN score >= 3.0 THEN 1 END)::DECIMAL / COUNT(*) * 100, 2) as porcentaje_aprobadas,
    ROUND(COUNT(CASE WHEN score < 3.0 THEN 1 END)::DECIMAL / COUNT(*) * 100, 2) as porcentaje_reprobadas
FROM student_activity_scores;

-- ============================================================
-- PASO 4: Verificar estudiantes aprobados y reprobados
-- ============================================================
SELECT 
    'ESTUDIANTES APROBADOS Y REPROBADOS' as categoria,
    COUNT(DISTINCT student_id) as total_estudiantes,
    COUNT(DISTINCT CASE WHEN promedio >= 3.0 THEN student_id END) as aprobados,
    COUNT(DISTINCT CASE WHEN promedio < 3.0 THEN student_id END) as reprobados,
    ROUND(COUNT(DISTINCT CASE WHEN promedio >= 3.0 THEN student_id END)::DECIMAL / COUNT(DISTINCT student_id) * 100, 2) as porcentaje_aprobados,
    ROUND(COUNT(DISTINCT CASE WHEN promedio < 3.0 THEN student_id END)::DECIMAL / COUNT(DISTINCT student_id) * 100, 2) as porcentaje_reprobados
FROM (
    SELECT 
        student_id,
        AVG(score) as promedio
    FROM student_activity_scores
    GROUP BY student_id
) as promedios;

-- ============================================================
-- PASO 5: Mostrar estudiantes aprobados
-- ============================================================
SELECT 
    'ESTUDIANTES APROBADOS (≥3.0)' as categoria,
    u.name as nombre,
    u.last_name as apellido,
    u.email,
    u.inclusivo,
    COUNT(sas.id) as total_notas,
    ROUND(AVG(sas.score), 2) as promedio
FROM users u
INNER JOIN student_activity_scores sas ON u.id = sas.student_id
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante') 
AND u.status = 'active'
GROUP BY u.id, u.name, u.last_name, u.email, u.inclusivo
HAVING AVG(sas.score) >= 3.0
ORDER BY promedio DESC
LIMIT 10;

-- ============================================================
-- PASO 6: Mostrar estudiantes reprobados
-- ============================================================
SELECT 
    'ESTUDIANTES REPROBADOS (<3.0)' as categoria,
    u.name as nombre,
    u.last_name as apellido,
    u.email,
    u.inclusivo,
    COUNT(sas.id) as total_notas,
    ROUND(AVG(sas.score), 2) as promedio
FROM users u
INNER JOIN student_activity_scores sas ON u.id = sas.student_id
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante') 
AND u.status = 'active'
GROUP BY u.id, u.name, u.last_name, u.email, u.inclusivo
HAVING AVG(sas.score) < 3.0
ORDER BY promedio ASC
LIMIT 10;
