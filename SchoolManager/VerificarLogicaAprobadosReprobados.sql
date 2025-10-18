-- ============================================================
-- VERIFICAR LÓGICA DE APROBADOS Y REPROBADOS
-- Fecha: 16 de Octubre, 2025
-- Descripción: Verifica la lógica de aprobados y reprobados
-- ============================================================

-- ============================================================
-- PASO 1: Verificar distribución actual de notas
-- ============================================================
DO $$
DECLARE
    total_scores INTEGER;
    avg_score DECIMAL;
    min_score DECIMAL;
    max_score DECIMAL;
    scores_above_3 DECIMAL;
    scores_below_3 DECIMAL;
    scores_above_4 DECIMAL;
    scores_below_2 DECIMAL;
BEGIN
    SELECT COUNT(*) INTO total_scores FROM student_activity_scores;
    SELECT ROUND(AVG(score), 2) INTO avg_score FROM student_activity_scores;
    SELECT ROUND(MIN(score), 2) INTO min_score FROM student_activity_scores;
    SELECT ROUND(MAX(score), 2) INTO max_score FROM student_activity_scores;
    SELECT ROUND(COUNT(CASE WHEN score >= 3.0 THEN 1 END)::DECIMAL / COUNT(*) * 100, 2) INTO scores_above_3 FROM student_activity_scores;
    SELECT ROUND(COUNT(CASE WHEN score < 3.0 THEN 1 END)::DECIMAL / COUNT(*) * 100, 2) INTO scores_below_3 FROM student_activity_scores;
    SELECT ROUND(COUNT(CASE WHEN score >= 4.0 THEN 1 END)::DECIMAL / COUNT(*) * 100, 2) INTO scores_above_4 FROM student_activity_scores;
    SELECT ROUND(COUNT(CASE WHEN score < 2.0 THEN 1 END)::DECIMAL / COUNT(*) * 100, 2) INTO scores_below_2 FROM student_activity_scores;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '📊 DISTRIBUCIÓN ACTUAL DE NOTAS';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'Total de calificaciones: %', total_scores;
    RAISE NOTICE 'Promedio general: %', avg_score;
    RAISE NOTICE 'Nota mínima: %', min_score;
    RAISE NOTICE 'Nota máxima: %', max_score;
    RAISE NOTICE 'Notas ≥ 3.0 (aprobadas): %%%', scores_above_3;
    RAISE NOTICE 'Notas < 3.0 (reprobadas): %%%', scores_below_3;
    RAISE NOTICE 'Notas ≥ 4.0 (excelentes): %%%', scores_above_4;
    RAISE NOTICE 'Notas < 2.0 (muy bajas): %%%', scores_below_2;
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;

-- ============================================================
-- PASO 2: Verificar estudiantes con promedios
-- ============================================================
SELECT 
    'ESTUDIANTES CON PROMEDIOS' as categoria,
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
-- PASO 3: Mostrar algunos estudiantes aprobados
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
-- PASO 4: Mostrar algunos estudiantes reprobados
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

-- ============================================================
-- PASO 5: Verificar actividades por trimestre
-- ============================================================
SELECT 
    'ACTIVIDADES POR TRIMESTRE' as categoria,
    a.trimester as trimestre,
    COUNT(a.id) as total_actividades,
    COUNT(sas.id) as total_calificaciones,
    COUNT(DISTINCT sas.student_id) as estudiantes_evaluados,
    ROUND(AVG(sas.score), 2) as promedio_general
FROM activities a
LEFT JOIN student_activity_scores sas ON a.id = sas.activity_id
GROUP BY a.trimester
ORDER BY a.trimester;

-- ============================================================
-- PASO 6: Verificar grupos y grados
-- ============================================================
SELECT 
    'GRUPOS Y GRADOS' as categoria,
    gl.name as grado,
    g.name as grupo,
    COUNT(DISTINCT sa.student_id) as estudiantes_asignados,
    COUNT(DISTINCT sas.student_id) as estudiantes_con_notas
FROM grade_levels gl
INNER JOIN groups g ON gl.id = g.grade_level_id
LEFT JOIN student_assignments sa ON g.id = sa.group_id
LEFT JOIN student_activity_scores sas ON sa.student_id = sas.student_id
GROUP BY gl.name, g.name
ORDER BY gl.name, g.name
LIMIT 15;
