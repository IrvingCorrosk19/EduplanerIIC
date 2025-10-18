-- ============================================================
-- GENERAR CALIFICACIONES CON TIPOS NUEVOS EN RENDER
-- Fecha: 18 de Octubre, 2025
-- Tipos: Notas de apreciación, Ejercicios diarios, Examen Final
-- ============================================================

-- ============================================================
-- PASO 1: Verificar estado actual
-- ============================================================
DO $$
DECLARE
    v_students INTEGER;
    v_activities INTEGER;
    v_scores INTEGER;
    v_tipos_notas INTEGER;
    v_tipos_ejercicios INTEGER;
    v_tipos_examenes INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_students FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') AND status = 'active';
    SELECT COUNT(*) INTO v_activities FROM activities;
    SELECT COUNT(*) INTO v_scores FROM student_activity_scores;
    
    SELECT COUNT(*) INTO v_tipos_notas FROM activities WHERE LOWER(type) LIKE '%nota%' OR LOWER(type) LIKE '%apreciaci%';
    SELECT COUNT(*) INTO v_tipos_ejercicios FROM activities WHERE LOWER(type) LIKE '%ejercicio%' OR LOWER(type) LIKE '%diario%';
    SELECT COUNT(*) INTO v_tipos_examenes FROM activities WHERE LOWER(type) LIKE '%examen%' OR LOWER(type) LIKE '%final%';
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'ESTADO ACTUAL DE LA BASE DE DATOS';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'Estudiantes activos: %', v_students;
    RAISE NOTICE 'Actividades totales: %', v_activities;
    RAISE NOTICE 'Calificaciones actuales: %', v_scores;
    RAISE NOTICE '';
    RAISE NOTICE 'ACTIVIDADES POR TIPO:';
    RAISE NOTICE '  Notas de apreciacion: %', v_tipos_notas;
    RAISE NOTICE '  Ejercicios diarios: %', v_tipos_ejercicios;
    RAISE NOTICE '  Examenes finales: %', v_tipos_examenes;
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;

-- ============================================================
-- PASO 2: Crear más actividades con los tipos nuevos
-- ============================================================
INSERT INTO activities (id, school_id, teacher_id, subject_id, group_id, grade_level_id, name, type, trimester, due_date, created_at, created_by)
SELECT 
    gen_random_uuid(),
    (SELECT id FROM schools LIMIT 1),
    ta.teacher_id,
    sa.subject_id,
    sa.group_id,
    sa.grade_level_id,
    tipo.nombre || ' ' || numero.num || ' - ' || s.name,
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
    VALUES (1), (2), (3), (4), (5)
) AS numero(num)
WHERE t.is_active = true
  AND NOT EXISTS (
      SELECT 1 FROM activities a
      WHERE a.subject_id = sa.subject_id
        AND a.group_id = sa.group_id
        AND a.grade_level_id = sa.grade_level_id
        AND a.teacher_id = ta.teacher_id
        AND a.type = tipo.nombre
        AND a.trimester = t.name
        AND a.name = tipo.nombre || ' ' || numero.num || ' - ' || s.name
  )
LIMIT 1500;

-- ============================================================
-- PASO 3: Generar calificaciones para TODAS las actividades
-- ============================================================
INSERT INTO student_activity_scores (id, student_id, activity_id, score, created_at, created_by, school_id)
SELECT 
    gen_random_uuid(),
    u.id,
    a.id,
    CASE 
        -- Distribución realista de notas
        WHEN (hashtext(u.id::text || a.id::text) % 100) < 15 THEN 1.0 + (ABS(hashtext(u.id::text || a.id::text) % 100) / 100.0) * 1.5
        WHEN (hashtext(u.id::text || a.id::text) % 100) < 35 THEN 2.0 + (ABS(hashtext(u.id::text || a.id::text) % 100) / 100.0) * 1.0
        WHEN (hashtext(u.id::text || a.id::text) % 100) < 65 THEN 2.8 + (ABS(hashtext(u.id::text || a.id::text) % 100) / 100.0) * 1.2
        WHEN (hashtext(u.id::text || a.id::text) % 100) < 90 THEN 3.5 + (ABS(hashtext(u.id::text || a.id::text) % 100) / 100.0) * 1.0
        ELSE 4.3 + (ABS(hashtext(u.id::text || a.id::text) % 100) / 200.0) * 0.7
    END,
    NOW(),
    a.teacher_id,
    (SELECT id FROM schools LIMIT 1)
FROM users u
CROSS JOIN activities a
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
  AND u.status = 'active'
  AND EXISTS (
      SELECT 1 
      FROM student_assignments sa
      WHERE sa.student_id = u.id
        AND sa.group_id = a.group_id
        AND sa.grade_id = a.grade_level_id
  )
  AND NOT EXISTS (
      SELECT 1 
      FROM student_activity_scores sas
      WHERE sas.student_id = u.id
        AND sas.activity_id = a.id
  )
ORDER BY u.id, a.id
LIMIT 30000;

-- ============================================================
-- PASO 4: Verificar distribución de notas por tipo
-- ============================================================
SELECT 
    'NOTAS POR TIPO DE ACTIVIDAD' as categoria,
    a.type as tipo_actividad,
    COUNT(sas.id) as total_calificaciones,
    ROUND(AVG(sas.score), 2) as promedio,
    ROUND(MIN(sas.score), 2) as nota_minima,
    ROUND(MAX(sas.score), 2) as nota_maxima
FROM student_activity_scores sas
INNER JOIN activities a ON sas.activity_id = a.id
GROUP BY a.type
ORDER BY COUNT(sas.id) DESC;

-- ============================================================
-- PASO 5: Verificar estudiantes con notas por tipo
-- ============================================================
SELECT 
    'COBERTURA POR TIPO' as categoria,
    a.type as tipo,
    COUNT(DISTINCT sas.student_id) as estudiantes_con_notas
FROM student_activity_scores sas
INNER JOIN activities a ON sas.activity_id = a.id
GROUP BY a.type
ORDER BY tipo;

-- ============================================================
-- PASO 6: Verificar distribución aprobados/reprobados
-- ============================================================
SELECT 
    CASE 
        WHEN promedio >= 3.0 THEN 'APROBADOS (≥3.0)'
        ELSE 'REPROBADOS (<3.0)'
    END as estado,
    COUNT(*) as cantidad,
    ROUND(AVG(promedio), 2) as promedio_grupo,
    ROUND(MIN(promedio), 2) as nota_minima,
    ROUND(MAX(promedio), 2) as nota_maxima,
    ROUND((COUNT(*)::DECIMAL / (SELECT COUNT(DISTINCT student_id) FROM student_activity_scores) * 100), 2) as porcentaje
FROM (
    SELECT student_id, AVG(score) as promedio
    FROM student_activity_scores
    GROUP BY student_id
) as promedios
GROUP BY estado
ORDER BY estado DESC;

-- ============================================================
-- PASO 7: Mostrar muestra de estudiantes con sus notas
-- ============================================================
SELECT 
    'TOP 10 ESTUDIANTES' as categoria,
    u.name || ' ' || u.last_name as estudiante,
    u.email,
    COUNT(CASE WHEN LOWER(a.type) LIKE '%nota%' OR LOWER(a.type) LIKE '%apreciaci%' THEN 1 END) as notas_apreciacion,
    COUNT(CASE WHEN LOWER(a.type) LIKE '%ejercicio%' OR LOWER(a.type) LIKE '%diario%' THEN 1 END) as ejercicios_diarios,
    COUNT(CASE WHEN LOWER(a.type) LIKE '%examen%' OR LOWER(a.type) LIKE '%final%' THEN 1 END) as examenes_finales,
    COUNT(sas.id) as total_calificaciones,
    ROUND(AVG(sas.score), 2) as promedio_general
FROM users u
INNER JOIN student_activity_scores sas ON u.id = sas.student_id
INNER JOIN activities a ON sas.activity_id = a.id
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
GROUP BY u.id, u.name, u.last_name, u.email
ORDER BY promedio_general DESC
LIMIT 10;

-- ============================================================
-- RESUMEN FINAL
-- ============================================================
DO $$
DECLARE
    v_total_estudiantes INTEGER;
    v_estudiantes_con_notas INTEGER;
    v_total_actividades INTEGER;
    v_total_calificaciones INTEGER;
    v_promedio_general DECIMAL;
    v_aprobados INTEGER;
    v_reprobados INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_total_estudiantes FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') AND status = 'active';
    SELECT COUNT(DISTINCT student_id) INTO v_estudiantes_con_notas FROM student_activity_scores;
    SELECT COUNT(*) INTO v_total_actividades FROM activities;
    SELECT COUNT(*) INTO v_total_calificaciones FROM student_activity_scores;
    SELECT ROUND(AVG(score), 2) INTO v_promedio_general FROM student_activity_scores;
    
    SELECT COUNT(DISTINCT student_id) INTO v_aprobados
    FROM (SELECT student_id, AVG(score) as p FROM student_activity_scores GROUP BY student_id HAVING AVG(score) >= 3.0) x;
    
    SELECT COUNT(DISTINCT student_id) INTO v_reprobados
    FROM (SELECT student_id, AVG(score) as p FROM student_activity_scores GROUP BY student_id HAVING AVG(score) < 3.0) x;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'CALIFICACIONES GENERADAS CON TIPOS NUEVOS';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'Total de estudiantes: %', v_total_estudiantes;
    RAISE NOTICE 'Estudiantes con notas: %', v_estudiantes_con_notas;
    RAISE NOTICE 'Cobertura: %%', ROUND((v_estudiantes_con_notas::DECIMAL / v_total_estudiantes * 100), 2);
    RAISE NOTICE '';
    RAISE NOTICE 'Total de actividades: %', v_total_actividades;
    RAISE NOTICE 'Total de calificaciones: %', v_total_calificaciones;
    RAISE NOTICE 'Promedio general: %', v_promedio_general;
    RAISE NOTICE '';
    RAISE NOTICE 'Aprobados: % (%%)', v_aprobados, ROUND((v_aprobados::DECIMAL / v_estudiantes_con_notas * 100), 2);
    RAISE NOTICE 'Reprobados: % (%%)', v_reprobados, ROUND((v_reprobados::DECIMAL / v_estudiantes_con_notas * 100), 2);
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;
