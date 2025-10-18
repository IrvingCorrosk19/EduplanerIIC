-- ============================================================
-- CREAR ACTIVIDADES CON TIPOS NUEVOS PARA TODOS LOS GRUPOS
-- ============================================================

-- Ver cuántas actividades existen con los tipos nuevos por grupo
SELECT 
    'ACTIVIDADES CON TIPOS NUEVOS POR GRUPO' as categoria,
    g.grade || ' ' || g.name as grupo,
    COUNT(CASE WHEN LOWER(a.type) LIKE '%nota%' OR LOWER(a.type) LIKE '%apreciaci%' THEN 1 END) as notas_apreciacion,
    COUNT(CASE WHEN LOWER(a.type) LIKE '%ejercicio%' OR LOWER(a.type) LIKE '%diario%' THEN 1 END) as ejercicios,
    COUNT(CASE WHEN LOWER(a.type) LIKE '%examen%' OR LOWER(a.type) LIKE '%final%' THEN 1 END) as examenes
FROM groups g
LEFT JOIN activities a ON g.id = a.group_id
GROUP BY g.id, g.grade, g.name
ORDER BY g.grade, g.name
LIMIT 25;

-- ============================================================
-- CREAR ACTIVIDADES PARA TODOS LOS GRUPOS Y MATERIAS
-- ============================================================
INSERT INTO activities (id, school_id, teacher_id, subject_id, group_id, grade_level_id, name, type, trimester, due_date, created_at, created_by)
SELECT 
    gen_random_uuid(),
    (SELECT id FROM schools LIMIT 1),
    ta.teacher_id,
    sa.subject_id,
    sa.group_id,
    sa.grade_level_id,
    tipo.nombre || ' ' || numero.num || ' de ' || s.name,
    tipo.nombre,
    t.name,
    CASE 
        WHEN t.name = '1T' THEN '2025-05-15'::date
        WHEN t.name = '2T' THEN '2025-08-15'::date
        WHEN t.name = '3T' THEN '2025-11-15'::date
        ELSE CURRENT_DATE + INTERVAL '30 days'
    END,
    NOW(),
    ta.teacher_id
FROM subject_assignments sa
INNER JOIN teacher_assignments ta ON sa.id = ta.subject_assignment_id
INNER JOIN subjects s ON sa.subject_id = s.id
CROSS JOIN trimester t
CROSS JOIN LATERAL (
    VALUES 
        ('Notas de apreciación'),
        ('Ejercicios diarios'),
        ('Examen Final')
) AS tipo(nombre)
CROSS JOIN LATERAL (
    VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10)
) AS numero(num)
WHERE t.is_active = true
ORDER BY sa.group_id, sa.subject_id, t.name, tipo.nombre, numero.num
LIMIT 3000;

-- ============================================================
-- GENERAR CALIFICACIONES PARA TODOS CON LOS TIPOS NUEVOS
-- ============================================================
INSERT INTO student_activity_scores (id, student_id, activity_id, score, created_at, created_by, school_id)
SELECT 
    gen_random_uuid(),
    sa.student_id,
    a.id,
    CASE 
        -- Distribución más realista: 50% aprobados
        WHEN (hashtext(sa.student_id::text || a.id::text) % 100) < 15 THEN 1.0 + (ABS(hashtext(sa.student_id::text || a.id::text) % 100) / 100.0) * 1.5
        WHEN (hashtext(sa.student_id::text || a.id::text) % 100) < 35 THEN 2.0 + (ABS(hashtext(sa.student_id::text || a.id::text) % 100) / 100.0) * 1.0
        WHEN (hashtext(sa.student_id::text || a.id::text) % 100) < 55 THEN 2.7 + (ABS(hashtext(sa.student_id::text || a.id::text) % 100) / 100.0) * 1.3
        WHEN (hashtext(sa.student_id::text || a.id::text) % 100) < 80 THEN 3.5 + (ABS(hashtext(sa.student_id::text || a.id::text) % 100) / 100.0) * 1.0
        ELSE 4.2 + (ABS(hashtext(sa.student_id::text || a.id::text) % 100) / 200.0) * 0.8
    END,
    NOW(),
    a.teacher_id,
    (SELECT id FROM schools LIMIT 1)
FROM student_assignments sa
INNER JOIN activities a ON sa.group_id = a.group_id AND sa.grade_id = a.grade_level_id
WHERE (LOWER(a.type) LIKE '%nota%' OR LOWER(a.type) LIKE '%apreciaci%'
       OR LOWER(a.type) LIKE '%ejercicio%' OR LOWER(a.type) LIKE '%diario%'
       OR LOWER(a.type) LIKE '%examen%' OR LOWER(a.type) LIKE '%final%')
  AND NOT EXISTS (
      SELECT 1 
      FROM student_activity_scores sas
      WHERE sas.student_id = sa.student_id
        AND sas.activity_id = a.id
  )
ORDER BY sa.student_id, a.id
LIMIT 50000;

-- ============================================================
-- VERIFICAR RESULTADOS POR GRUPO
-- ============================================================
SELECT 
    'ACTIVIDADES CON TIPOS NUEVOS POR GRUPO (DESPUÉS)' as categoria,
    g.grade || ' ' || g.name as grupo,
    COUNT(DISTINCT CASE WHEN LOWER(a.type) LIKE '%nota%' OR LOWER(a.type) LIKE '%apreciaci%' THEN a.id END) as notas_apreciacion,
    COUNT(DISTINCT CASE WHEN LOWER(a.type) LIKE '%ejercicio%' OR LOWER(a.type) LIKE '%diario%' THEN a.id END) as ejercicios,
    COUNT(DISTINCT CASE WHEN LOWER(a.type) LIKE '%examen%' OR LOWER(a.type) LIKE '%final%' THEN a.id END) as examenes,
    COUNT(DISTINCT a.id) as total_actividades_nuevas
FROM groups g
LEFT JOIN activities a ON g.id = a.group_id
WHERE (LOWER(a.type) LIKE '%nota%' OR LOWER(a.type) LIKE '%apreciaci%'
       OR LOWER(a.type) LIKE '%ejercicio%' OR LOWER(a.type) LIKE '%diario%'
       OR LOWER(a.type) LIKE '%examen%' OR LOWER(a.type) LIKE '%final%')
GROUP BY g.id, g.grade, g.name
ORDER BY g.grade, g.name
LIMIT 25;

-- ============================================================
-- VERIFICAR ESTUDIANTES CON LOS 3 TIPOS
-- ============================================================
SELECT 
    'COBERTURA DE TIPOS NUEVOS' as categoria,
    COUNT(DISTINCT u.id) as total_estudiantes,
    COUNT(DISTINCT CASE WHEN tiene_los_3 THEN u.id END) as con_los_3_tipos,
    ROUND((COUNT(DISTINCT CASE WHEN tiene_los_3 THEN u.id END)::DECIMAL / COUNT(DISTINCT u.id) * 100), 2) as porcentaje_cobertura
FROM users u
CROSS JOIN LATERAL (
    SELECT 
        EXISTS (
            SELECT 1 FROM student_activity_scores sas
            INNER JOIN activities a ON sas.activity_id = a.id
            WHERE sas.student_id = u.id
              AND (LOWER(a.type) LIKE '%nota%' OR LOWER(a.type) LIKE '%apreciaci%')
        ) AND EXISTS (
            SELECT 1 FROM student_activity_scores sas
            INNER JOIN activities a ON sas.activity_id = a.id
            WHERE sas.student_id = u.id
              AND (LOWER(a.type) LIKE '%ejercicio%' OR LOWER(a.type) LIKE '%diario%')
        ) AND EXISTS (
            SELECT 1 FROM student_activity_scores sas
            INNER JOIN activities a ON sas.activity_id = a.id
            WHERE sas.student_id = u.id
              AND (LOWER(a.type) LIKE '%examen%' OR LOWER(a.type) LIKE '%final%')
        ) as tiene_los_3
) AS check_tipos
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
  AND u.status = 'active';

-- Resumen final
DO $$
DECLARE
    v_total_actividades INTEGER;
    v_total_calificaciones INTEGER;
    v_estudiantes_completos INTEGER;
    v_total_estudiantes INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_total_actividades FROM activities;
    SELECT COUNT(*) INTO v_total_calificaciones FROM student_activity_scores;
    SELECT COUNT(*) INTO v_total_estudiantes FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') AND status = 'active';
    
    SELECT COUNT(DISTINCT u.id) INTO v_estudiantes_completos
    FROM users u
    WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
      AND u.status = 'active'
      AND EXISTS (
          SELECT 1 FROM student_activity_scores sas
          INNER JOIN activities a ON sas.activity_id = a.id
          WHERE sas.student_id = u.id AND (LOWER(a.type) LIKE '%nota%' OR LOWER(a.type) LIKE '%apreciaci%')
      )
      AND EXISTS (
          SELECT 1 FROM student_activity_scores sas
          INNER JOIN activities a ON sas.activity_id = a.id
          WHERE sas.student_id = u.id AND (LOWER(a.type) LIKE '%ejercicio%' OR LOWER(a.type) LIKE '%diario%')
      )
      AND EXISTS (
          SELECT 1 FROM student_activity_scores sas
          INNER JOIN activities a ON sas.activity_id = a.id
          WHERE sas.student_id = u.id AND (LOWER(a.type) LIKE '%examen%' OR LOWER(a.type) LIKE '%final%')
      );
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'ACTIVIDADES Y CALIFICACIONES CON TIPOS NUEVOS';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'Total de actividades: %', v_total_actividades;
    RAISE NOTICE 'Total de calificaciones: %', v_total_calificaciones;
    RAISE NOTICE '';
    RAISE NOTICE 'ESTUDIANTES:';
    RAISE NOTICE '  Total: %', v_total_estudiantes;
    RAISE NOTICE '  Con los 3 tipos nuevos: %', v_estudiantes_completos;
    RAISE NOTICE '  Cobertura: %%', ROUND((v_estudiantes_completos::DECIMAL / v_total_estudiantes * 100), 2);
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;
