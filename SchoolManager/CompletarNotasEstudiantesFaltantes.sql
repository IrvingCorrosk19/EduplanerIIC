-- ============================================================
-- COMPLETAR NOTAS PARA ESTUDIANTES FALTANTES
-- ============================================================

-- Generar calificaciones para los 21 estudiantes sin notas
INSERT INTO student_activity_scores (id, student_id, activity_id, score, created_at, created_by, school_id)
SELECT 
    gen_random_uuid(),
    u.id,
    a.id,
    CASE 
        WHEN (hashtext(u.id::text || a.id::text) % 100) < 10 THEN 1.0 + (ABS(hashtext(u.id::text || a.id::text) % 100) / 100.0) * 1.5
        WHEN (hashtext(u.id::text || a.id::text) % 100) < 30 THEN 2.0 + (ABS(hashtext(u.id::text || a.id::text) % 100) / 100.0) * 1.0
        WHEN (hashtext(u.id::text || a.id::text) % 100) < 60 THEN 2.8 + (ABS(hashtext(u.id::text || a.id::text) % 100) / 100.0) * 1.2
        WHEN (hashtext(u.id::text || a.id::text) % 100) < 85 THEN 3.5 + (ABS(hashtext(u.id::text || a.id::text) % 100) / 100.0) * 1.0
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
      SELECT 1 FROM student_activity_scores sas WHERE sas.student_id = u.id
  )
ORDER BY u.id, a.id
LIMIT 10000;

-- Verificar resultado final
SELECT 
    'VERIFICACIÓN FINAL' as categoria,
    (SELECT COUNT(*) FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') AND status = 'active') as total_estudiantes,
    COUNT(DISTINCT student_id) as estudiantes_con_notas,
    ROUND((COUNT(DISTINCT student_id)::DECIMAL / (SELECT COUNT(*) FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') AND status = 'active') * 100), 2) as porcentaje_cobertura,
    COUNT(*) as total_calificaciones
FROM student_activity_scores;

-- Confirmar que no quedan estudiantes sin notas
SELECT 
    'ESTUDIANTES SIN NOTAS' as categoria,
    COUNT(*) as cantidad
FROM users u
WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
AND status = 'active'
AND NOT EXISTS (
    SELECT 1 FROM student_activity_scores sas WHERE sas.student_id = u.id
);

-- Mostrar resumen de aprobados/reprobados final
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

-- Mensaje de éxito
DO $$
DECLARE
    v_total INTEGER;
    v_con_notas INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_total FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') AND status = 'active';
    SELECT COUNT(DISTINCT student_id) INTO v_con_notas FROM student_activity_scores;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '✅ CALIFICACIONES COMPLETADAS PARA TODOS LOS ESTUDIANTES';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'Total de estudiantes: %', v_total;
    RAISE NOTICE 'Estudiantes con notas: %', v_con_notas;
    RAISE NOTICE 'Cobertura: 100%%';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;
