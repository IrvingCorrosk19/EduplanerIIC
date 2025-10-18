-- ============================================================
-- GENERAR NOTAS PARA TODOS LOS ESTUDIANTES (410)
-- Con los 3 tipos nuevos: Notas de apreciación, Ejercicios diarios, Examen Final
-- ============================================================

-- Ver cuántos estudiantes NO tienen notas con los tipos nuevos
SELECT 
    'ESTUDIANTES SIN NOTAS DE TIPOS NUEVOS' as categoria,
    COUNT(DISTINCT u.id) as cantidad
FROM users u
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
  AND u.status = 'active'
  AND NOT EXISTS (
      SELECT 1 
      FROM student_activity_scores sas
      INNER JOIN activities a ON sas.activity_id = a.id
      WHERE sas.student_id = u.id
        AND (LOWER(a.type) LIKE '%nota%' OR LOWER(a.type) LIKE '%apreciaci%'
             OR LOWER(a.type) LIKE '%ejercicio%' OR LOWER(a.type) LIKE '%diario%'
             OR LOWER(a.type) LIKE '%examen%' OR LOWER(a.type) LIKE '%final%')
  );

-- ============================================================
-- GENERAR CALIFICACIONES PARA TODOS LOS ESTUDIANTES
-- ============================================================
INSERT INTO student_activity_scores (id, student_id, activity_id, score, created_at, created_by, school_id)
SELECT 
    gen_random_uuid(),
    u.id,
    a.id,
    CASE 
        -- Distribución realista: 40% aprobados, 60% reprobados
        WHEN (hashtext(u.id::text || a.id::text) % 100) < 15 THEN 1.0 + (ABS(hashtext(u.id::text || a.id::text) % 100) / 100.0) * 1.5
        WHEN (hashtext(u.id::text || a.id::text) % 100) < 40 THEN 2.0 + (ABS(hashtext(u.id::text || a.id::text) % 100) / 100.0) * 1.0
        WHEN (hashtext(u.id::text || a.id::text) % 100) < 65 THEN 2.8 + (ABS(hashtext(u.id::text || a.id::text) % 100) / 100.0) * 1.2
        WHEN (hashtext(u.id::text || a.id::text) % 100) < 90 THEN 3.5 + (ABS(hashtext(u.id::text || a.id::text) % 100) / 100.0) * 1.0
        ELSE 4.0 + (ABS(hashtext(u.id::text || a.id::text) % 100) / 200.0) * 1.0
    END,
    NOW(),
    a.teacher_id,
    (SELECT id FROM schools LIMIT 1)
FROM users u
CROSS JOIN activities a
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
  AND u.status = 'active'
  AND (LOWER(a.type) LIKE '%nota%' OR LOWER(a.type) LIKE '%apreciaci%'
       OR LOWER(a.type) LIKE '%ejercicio%' OR LOWER(a.type) LIKE '%diario%'
       OR LOWER(a.type) LIKE '%examen%' OR LOWER(a.type) LIKE '%final%')
  AND NOT EXISTS (
      SELECT 1 
      FROM student_activity_scores sas
      WHERE sas.student_id = u.id
        AND sas.activity_id = a.id
  )
ORDER BY u.id, a.id
LIMIT 50000;

-- ============================================================
-- VERIFICAR RESULTADOS
-- ============================================================

-- Verificar cobertura total
SELECT 
    'COBERTURA TOTAL' as categoria,
    COUNT(DISTINCT u.id) as total_estudiantes,
    COUNT(DISTINCT sas.student_id) as estudiantes_con_notas_tipos_nuevos,
    ROUND((COUNT(DISTINCT sas.student_id)::DECIMAL / COUNT(DISTINCT u.id) * 100), 2) as porcentaje_cobertura
FROM users u
LEFT JOIN student_activity_scores sas ON u.id = sas.student_id
LEFT JOIN activities a ON sas.activity_id = a.id AND (
    LOWER(a.type) LIKE '%nota%' OR LOWER(a.type) LIKE '%apreciaci%'
    OR LOWER(a.type) LIKE '%ejercicio%' OR LOWER(a.type) LIKE '%diario%'
    OR LOWER(a.type) LIKE '%examen%' OR LOWER(a.type) LIKE '%final%'
)
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
  AND u.status = 'active';

-- Ver distribución por tipo nuevo
SELECT 
    'DISTRIBUCIÓN POR TIPO NUEVO' as categoria,
    CASE 
        WHEN LOWER(a.type) LIKE '%nota%' OR LOWER(a.type) LIKE '%apreciaci%' THEN 'Notas de apreciación'
        WHEN LOWER(a.type) LIKE '%ejercicio%' OR LOWER(a.type) LIKE '%diario%' THEN 'Ejercicios diarios'
        WHEN LOWER(a.type) LIKE '%examen%' OR LOWER(a.type) LIKE '%final%' THEN 'Examen Final'
        ELSE 'Otro'
    END as tipo_agrupado,
    COUNT(DISTINCT sas.student_id) as estudiantes,
    COUNT(sas.id) as total_calificaciones,
    ROUND(AVG(sas.score), 2) as promedio
FROM student_activity_scores sas
INNER JOIN activities a ON sas.activity_id = a.id
WHERE LOWER(a.type) LIKE '%nota%' OR LOWER(a.type) LIKE '%apreciaci%'
   OR LOWER(a.type) LIKE '%ejercicio%' OR LOWER(a.type) LIKE '%diario%'
   OR LOWER(a.type) LIKE '%examen%' OR LOWER(a.type) LIKE '%final%'
GROUP BY tipo_agrupado
ORDER BY tipo_agrupado;

-- Verificar estudiantes con todos los tipos
SELECT 
    'ESTUDIANTES CON LOS 3 TIPOS' as categoria,
    COUNT(*) as cantidad
FROM (
    SELECT u.id
    FROM users u
    WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
      AND u.status = 'active'
      AND EXISTS (
          SELECT 1 FROM student_activity_scores sas
          INNER JOIN activities a ON sas.activity_id = a.id
          WHERE sas.student_id = u.id
            AND (LOWER(a.type) LIKE '%nota%' OR LOWER(a.type) LIKE '%apreciaci%')
      )
      AND EXISTS (
          SELECT 1 FROM student_activity_scores sas
          INNER JOIN activities a ON sas.activity_id = a.id
          WHERE sas.student_id = u.id
            AND (LOWER(a.type) LIKE '%ejercicio%' OR LOWER(a.type) LIKE '%diario%')
      )
      AND EXISTS (
          SELECT 1 FROM student_activity_scores sas
          INNER JOIN activities a ON sas.activity_id = a.id
          WHERE sas.student_id = u.id
            AND (LOWER(a.type) LIKE '%examen%' OR LOWER(a.type) LIKE '%final%')
      )
) AS estudiantes_completos;

-- Mostrar muestra de estudiantes con los 3 tipos
SELECT 
    'MUESTRA DE ESTUDIANTES CON LOS 3 TIPOS' as categoria,
    u.name || ' ' || u.last_name as estudiante,
    u.email,
    COUNT(CASE WHEN LOWER(a.type) LIKE '%nota%' OR LOWER(a.type) LIKE '%apreciaci%' THEN 1 END) as notas_apreciacion,
    COUNT(CASE WHEN LOWER(a.type) LIKE '%ejercicio%' OR LOWER(a.type) LIKE '%diario%' THEN 1 END) as ejercicios,
    COUNT(CASE WHEN LOWER(a.type) LIKE '%examen%' OR LOWER(a.type) LIKE '%final%' THEN 1 END) as examenes,
    ROUND(AVG(sas.score), 2) as promedio
FROM users u
INNER JOIN student_activity_scores sas ON u.id = sas.student_id
INNER JOIN activities a ON sas.activity_id = a.id
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
  AND (LOWER(a.type) LIKE '%nota%' OR LOWER(a.type) LIKE '%apreciaci%'
       OR LOWER(a.type) LIKE '%ejercicio%' OR LOWER(a.type) LIKE '%diario%'
       OR LOWER(a.type) LIKE '%examen%' OR LOWER(a.type) LIKE '%final%')
GROUP BY u.id, u.name, u.last_name, u.email
HAVING COUNT(CASE WHEN LOWER(a.type) LIKE '%nota%' OR LOWER(a.type) LIKE '%apreciaci%' THEN 1 END) > 0
   AND COUNT(CASE WHEN LOWER(a.type) LIKE '%ejercicio%' OR LOWER(a.type) LIKE '%diario%' THEN 1 END) > 0
   AND COUNT(CASE WHEN LOWER(a.type) LIKE '%examen%' OR LOWER(a.type) LIKE '%final%' THEN 1 END) > 0
ORDER BY promedio DESC
LIMIT 15;

-- Resumen final
DO $$
DECLARE
    v_total INTEGER;
    v_con_tipos_nuevos INTEGER;
    v_calificaciones INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_total FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') AND status = 'active';
    
    SELECT COUNT(DISTINCT u.id) INTO v_con_tipos_nuevos
    FROM users u
    WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
      AND u.status = 'active'
      AND EXISTS (
          SELECT 1 FROM student_activity_scores sas
          INNER JOIN activities a ON sas.activity_id = a.id
          WHERE sas.student_id = u.id
            AND (LOWER(a.type) LIKE '%nota%' OR LOWER(a.type) LIKE '%apreciaci%'
                 OR LOWER(a.type) LIKE '%ejercicio%' OR LOWER(a.type) LIKE '%diario%'
                 OR LOWER(a.type) LIKE '%examen%' OR LOWER(a.type) LIKE '%final%')
      );
    
    SELECT COUNT(*) INTO v_calificaciones FROM student_activity_scores;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'RESUMEN FINAL';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'Total de estudiantes: %', v_total;
    RAISE NOTICE 'Estudiantes con tipos nuevos: %', v_con_tipos_nuevos;
    RAISE NOTICE 'Cobertura: %%', ROUND((v_con_tipos_nuevos::DECIMAL / v_total * 100), 2);
    RAISE NOTICE 'Total de calificaciones: %', v_calificaciones;
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;
