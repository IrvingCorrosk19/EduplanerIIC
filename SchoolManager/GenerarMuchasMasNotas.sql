-- ============================================================
-- GENERAR MUCHAS MÁS NOTAS PARA TODOS LOS ESTUDIANTES
-- ============================================================

-- Contar estado actual
SELECT 
    'ESTADO ANTES DE GENERAR' as categoria,
    COUNT(DISTINCT student_id) as estudiantes,
    COUNT(*) as calificaciones_actuales,
    ROUND(AVG(score), 2) as promedio_actual
FROM student_activity_scores;

-- Generar más calificaciones para TODOS los estudiantes
INSERT INTO student_activity_scores (id, student_id, activity_id, score, created_at, created_by, school_id)
SELECT 
    gen_random_uuid(),
    u.id,
    a.id,
    CASE 
        WHEN (hashtext(u.id::text || a.id::text || NOW()::text) % 100) < 10 THEN 1.0 + (ABS(hashtext(u.id::text || a.id::text) % 100) / 100.0) * 1.5
        WHEN (hashtext(u.id::text || a.id::text || NOW()::text) % 100) < 30 THEN 2.0 + (ABS(hashtext(u.id::text || a.id::text) % 100) / 100.0) * 1.0
        WHEN (hashtext(u.id::text || a.id::text || NOW()::text) % 100) < 60 THEN 2.8 + (ABS(hashtext(u.id::text || a.id::text) % 100) / 100.0) * 1.2
        WHEN (hashtext(u.id::text || a.id::text || NOW()::text) % 100) < 85 THEN 3.5 + (ABS(hashtext(u.id::text || a.id::text) % 100) / 100.0) * 1.0
        ELSE 4.3 + (ABS(hashtext(u.id::text || a.id::text) % 100) / 200.0) * 0.7
    END,
    NOW(),
    a.teacher_id,
    (SELECT id FROM schools LIMIT 1)
FROM users u
CROSS JOIN activities a
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
  AND u.status = 'active'
  AND NOT EXISTS (
      SELECT 1 FROM student_activity_scores sas 
      WHERE sas.student_id = u.id AND sas.activity_id = a.id
  )
ORDER BY RANDOM()
LIMIT 20000;

-- Verificar resultado
SELECT 
    'ESTADO DESPUÉS DE GENERAR' as categoria,
    COUNT(DISTINCT student_id) as estudiantes,
    COUNT(*) as calificaciones_totales,
    ROUND(AVG(score), 2) as promedio_general
FROM student_activity_scores;

-- Distribución de calificaciones por estudiante
SELECT 
    'DISTRIBUCIÓN POR ESTUDIANTE' as categoria,
    MIN(total_notas) as minimo_notas,
    MAX(total_notas) as maximo_notas,
    ROUND(AVG(total_notas), 0) as promedio_notas
FROM (
    SELECT student_id, COUNT(*) as total_notas
    FROM student_activity_scores
    GROUP BY student_id
) as conteo;

-- Aprobados y reprobados
SELECT 
    CASE 
        WHEN promedio >= 3.0 THEN 'APROBADOS'
        ELSE 'REPROBADOS'
    END as estado,
    COUNT(*) as cantidad,
    ROUND(AVG(promedio), 2) as promedio_grupo,
    ROUND(MIN(promedio), 2) as nota_minima,
    ROUND(MAX(promedio), 2) as nota_maxima
FROM (
    SELECT student_id, AVG(score) as promedio
    FROM student_activity_scores
    GROUP BY student_id
) as promedios
GROUP BY estado;

-- Resumen final
DO $$
DECLARE
    v_total_estudiantes INTEGER;
    v_total_calificaciones INTEGER;
    v_promedio_general DECIMAL;
    v_aprobados INTEGER;
    v_reprobados INTEGER;
BEGIN
    SELECT COUNT(DISTINCT student_id) INTO v_total_estudiantes FROM student_activity_scores;
    SELECT COUNT(*) INTO v_total_calificaciones FROM student_activity_scores;
    SELECT ROUND(AVG(score), 2) INTO v_promedio_general FROM student_activity_scores;
    
    SELECT COUNT(*) INTO v_aprobados
    FROM (SELECT student_id, AVG(score) as p FROM student_activity_scores GROUP BY student_id HAVING AVG(score) >= 3.0) x;
    
    SELECT COUNT(*) INTO v_reprobados
    FROM (SELECT student_id, AVG(score) as p FROM student_activity_scores GROUP BY student_id HAVING AVG(score) < 3.0) x;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '✅ MUCHAS MÁS NOTAS GENERADAS EXITOSAMENTE';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'Total de estudiantes con notas: %', v_total_estudiantes;
    RAISE NOTICE 'Total de calificaciones: %', v_total_calificaciones;
    RAISE NOTICE 'Promedio general: %', v_promedio_general;
    RAISE NOTICE '';
    RAISE NOTICE '📊 DISTRIBUCIÓN:';
    RAISE NOTICE '   Aprobados: % (%%)', v_aprobados, ROUND((v_aprobados::DECIMAL / v_total_estudiantes * 100), 1);
    RAISE NOTICE '   Reprobados: % (%%)', v_reprobados, ROUND((v_reprobados::DECIMAL / v_total_estudiantes * 100), 1);
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;
