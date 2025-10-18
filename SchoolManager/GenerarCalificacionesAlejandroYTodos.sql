-- ============================================================
-- GENERAR CALIFICACIONES PARA ALEJANDRO Y TODOS LOS ESTUDIANTES
-- Con los tipos nuevos específicamente
-- ============================================================

-- Generar calificaciones para TODOS los estudiantes con actividades de tipos nuevos
INSERT INTO student_activity_scores (id, student_id, activity_id, score, created_at, created_by, school_id)
SELECT 
    gen_random_uuid(),
    sa.student_id,
    a.id,
    CASE 
        -- 50% aprobados, 50% reprobados
        WHEN (hashtext(sa.student_id::text || a.id::text) % 100) < 10 THEN 1.0 + (ABS(hashtext(sa.student_id::text || a.id::text) % 10) / 10.0) * 1.5
        WHEN (hashtext(sa.student_id::text || a.id::text) % 100) < 30 THEN 2.0 + (ABS(hashtext(sa.student_id::text || a.id::text) % 10) / 10.0) * 1.0
        WHEN (hashtext(sa.student_id::text || a.id::text) % 100) < 50 THEN 2.7 + (ABS(hashtext(sa.student_id::text || a.id::text) % 10) / 10.0) * 0.8
        WHEN (hashtext(sa.student_id::text || a.id::text) % 100) < 75 THEN 3.3 + (ABS(hashtext(sa.student_id::text || a.id::text) % 10) / 10.0) * 0.7
        ELSE 4.0 + (ABS(hashtext(sa.student_id::text || a.id::text) % 10) / 20.0) * 1.0
    END,
    NOW(),
    a.teacher_id,
    (SELECT id FROM schools LIMIT 1)
FROM student_assignments sa
INNER JOIN activities a ON sa.group_id = a.group_id AND sa.grade_id = a.grade_level_id
WHERE (a.type = 'Notas de apreciación' OR a.type = 'Ejercicios diarios' OR a.type = 'Examen Final')
  AND NOT EXISTS (
      SELECT 1 
      FROM student_activity_scores sas
      WHERE sas.student_id = sa.student_id
        AND sas.activity_id = a.id
  )
ORDER BY sa.student_id, a.id;

-- Verificar Alejandro específicamente
SELECT 
    'ALEJANDRO - CALIFICACIONES POR TIPO' as categoria,
    a.type,
    COUNT(sas.id) as cantidad,
    ROUND(AVG(sas.score), 2) as promedio
FROM student_activity_scores sas
INNER JOIN activities a ON sas.activity_id = a.id
INNER JOIN users u ON sas.student_id = u.id
WHERE u.email = 'alejandro.moreno@estudiante.edu.pa'
  AND (a.type = 'Notas de apreciación' OR a.type = 'Ejercicios diarios' OR a.type = 'Examen Final')
GROUP BY a.type
ORDER BY a.type;

-- Ver por materia y tipo
SELECT 
    'ALEJANDRO - POR MATERIA Y TIPO' as categoria,
    s.name as materia,
    a.type,
    COUNT(sas.id) as cantidad_notas,
    ROUND(AVG(sas.score), 2) as promedio_tipo
FROM student_activity_scores sas
INNER JOIN activities a ON sas.activity_id = a.id
INNER JOIN subjects s ON a.subject_id = s.id
INNER JOIN users u ON sas.student_id = u.id
WHERE u.email = 'alejandro.moreno@estudiante.edu.pa'
  AND (a.type = 'Notas de apreciación' OR a.type = 'Ejercicios diarios' OR a.type = 'Examen Final')
GROUP BY s.name, a.type
ORDER BY s.name, a.type
LIMIT 30;

-- Verificar todos los estudiantes
SELECT 
    'COBERTURA FINAL - TODOS LOS ESTUDIANTES' as categoria,
    COUNT(DISTINCT u.id) as total_estudiantes,
    COUNT(DISTINCT CASE WHEN tiene_los_3 THEN u.id END) as con_los_3_tipos,
    ROUND((COUNT(DISTINCT CASE WHEN tiene_los_3 THEN u.id END)::DECIMAL / COUNT(DISTINCT u.id) * 100), 2) as porcentaje_cobertura
FROM users u
CROSS JOIN LATERAL (
    SELECT 
        EXISTS (
            SELECT 1 FROM student_activity_scores sas
            INNER JOIN activities a ON sas.activity_id = a.id
            WHERE sas.student_id = u.id AND a.type = 'Notas de apreciación'
        ) AND EXISTS (
            SELECT 1 FROM student_activity_scores sas
            INNER JOIN activities a ON sas.activity_id = a.id
            WHERE sas.student_id = u.id AND a.type = 'Ejercicios diarios'
        ) AND EXISTS (
            SELECT 1 FROM student_activity_scores sas
            INNER JOIN activities a ON sas.activity_id = a.id
            WHERE sas.student_id = u.id AND a.type = 'Examen Final'
        ) as tiene_los_3
) AS check_tipos
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
  AND u.status = 'active';

-- Resumen final
DO $$
DECLARE
    v_total_cal INTEGER;
    v_estudiantes_completos INTEGER;
    v_total_est INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_total_cal FROM student_activity_scores;
    SELECT COUNT(*) INTO v_total_est FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') AND status = 'active';
    
    SELECT COUNT(DISTINCT u.id) INTO v_estudiantes_completos
    FROM users u
    WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
      AND u.status = 'active'
      AND EXISTS (SELECT 1 FROM student_activity_scores sas INNER JOIN activities a ON sas.activity_id = a.id WHERE sas.student_id = u.id AND a.type = 'Notas de apreciación')
      AND EXISTS (SELECT 1 FROM student_activity_scores sas INNER JOIN activities a ON sas.activity_id = a.id WHERE sas.student_id = u.id AND a.type = 'Ejercicios diarios')
      AND EXISTS (SELECT 1 FROM student_activity_scores sas INNER JOIN activities a ON sas.activity_id = a.id WHERE sas.student_id = u.id AND a.type = 'Examen Final');
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'RESUMEN FINAL DE CALIFICACIONES';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'Total de calificaciones: %', v_total_cal;
    RAISE NOTICE 'Estudiantes con 3 tipos: % de %', v_estudiantes_completos, v_total_est;
    RAISE NOTICE 'Cobertura: %%', ROUND((v_estudiantes_completos::DECIMAL / v_total_est * 100), 2);
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;
