-- ============================================================
-- GENERAR NOTAS PARA USUARIOS EXISTENTES EN RENDER
-- Fecha: 18 de Octubre, 2025
-- Descripción: Genera actividades y calificaciones para estudiantes existentes
-- ============================================================

-- ============================================================
-- PASO 1: Verificar datos existentes
-- ============================================================
DO $$
DECLARE
    v_students INTEGER;
    v_teachers INTEGER;
    v_groups INTEGER;
    v_subjects INTEGER;
    v_trimestres INTEGER;
    v_actividades INTEGER;
    v_calificaciones INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_students FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') AND status = 'active';
    SELECT COUNT(*) INTO v_teachers FROM users WHERE role IN ('teacher', 'Teacher', 'docente', 'Docente') AND status = 'active';
    SELECT COUNT(*) INTO v_groups FROM groups;
    SELECT COUNT(*) INTO v_subjects FROM subjects WHERE status = true;
    SELECT COUNT(*) INTO v_trimestres FROM trimester WHERE is_active = true;
    SELECT COUNT(*) INTO v_actividades FROM activities;
    SELECT COUNT(*) INTO v_calificaciones FROM student_activity_scores;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '📊 ESTADO ACTUAL DE LA BASE DE DATOS';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'Estudiantes activos: %', v_students;
    RAISE NOTICE 'Profesores activos: %', v_teachers;
    RAISE NOTICE 'Grupos: %', v_groups;
    RAISE NOTICE 'Materias activas: %', v_subjects;
    RAISE NOTICE 'Trimestres activos: %', v_trimestres;
    RAISE NOTICE 'Actividades existentes: %', v_actividades;
    RAISE NOTICE 'Calificaciones existentes: %', v_calificaciones;
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;

-- ============================================================
-- PASO 2: Crear más actividades para todos los trimestres
-- ============================================================
INSERT INTO activities (id, school_id, teacher_id, subject_id, group_id, grade_level_id, name, type, trimester, due_date, created_at, created_by)
SELECT 
    gen_random_uuid(),
    (SELECT id FROM schools LIMIT 1),
    ta.teacher_id,
    sa.subject_id,
    sa.group_id,
    sa.grade_level_id,
    at.name || ' ' || (ROW_NUMBER() OVER (PARTITION BY sa.subject_id, sa.group_id, t.name, at.name ORDER BY RANDOM())) || ' - ' || s.name,
    at.name,
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
CROSS JOIN activity_types at
WHERE t.is_active = true 
  AND at.is_active = true
  AND NOT EXISTS (
      SELECT 1 FROM activities a2
      WHERE a2.subject_id = sa.subject_id
        AND a2.group_id = sa.group_id
        AND a2.grade_level_id = sa.grade_level_id
        AND a2.teacher_id = ta.teacher_id
        AND a2.trimester = t.name
        AND a2.type = at.name
        AND a2.name = at.name || ' ' || (ROW_NUMBER() OVER (PARTITION BY sa.subject_id, sa.group_id, t.name, at.name ORDER BY RANDOM())) || ' - ' || s.name
  )
LIMIT 500;

-- ============================================================
-- PASO 3: Generar calificaciones para TODOS los estudiantes
-- ============================================================
INSERT INTO student_activity_scores (id, student_id, activity_id, score, created_at, created_by, school_id)
SELECT 
    gen_random_uuid(),
    u.id,
    a.id,
    CASE 
        -- Usar hash del ID del estudiante para consistencia
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
LIMIT 5000;

-- ============================================================
-- PASO 4: Verificar resultados finales
-- ============================================================
DO $$
DECLARE
    v_students INTEGER;
    v_students_con_notas INTEGER;
    v_actividades_nuevas INTEGER;
    v_calificaciones_nuevas INTEGER;
    v_promedio_general DECIMAL;
    v_aprobados INTEGER;
    v_reprobados INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_students FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') AND status = 'active';
    SELECT COUNT(DISTINCT student_id) INTO v_students_con_notas FROM student_activity_scores;
    SELECT COUNT(*) INTO v_actividades_nuevas FROM activities;
    SELECT COUNT(*) INTO v_calificaciones_nuevas FROM student_activity_scores;
    SELECT ROUND(AVG(score), 2) INTO v_promedio_general FROM student_activity_scores;
    
    -- Contar aprobados y reprobados
    SELECT COUNT(DISTINCT student_id) INTO v_aprobados
    FROM (
        SELECT student_id, AVG(score) as promedio
        FROM student_activity_scores
        GROUP BY student_id
        HAVING AVG(score) >= 3.0
    ) as aprobados;
    
    SELECT COUNT(DISTINCT student_id) INTO v_reprobados
    FROM (
        SELECT student_id, AVG(score) as promedio
        FROM student_activity_scores
        GROUP BY student_id
        HAVING AVG(score) < 3.0
    ) as reprobados;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '✅ NOTAS GENERADAS EXITOSAMENTE';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'Total de estudiantes: %', v_students;
    RAISE NOTICE 'Estudiantes con notas: %', v_students_con_notas;
    RAISE NOTICE 'Cobertura: %%', ROUND((v_students_con_notas::DECIMAL / v_students * 100), 2);
    RAISE NOTICE '';
    RAISE NOTICE '📚 ACTIVIDADES Y CALIFICACIONES:';
    RAISE NOTICE 'Total de actividades: %', v_actividades_nuevas;
    RAISE NOTICE 'Total de calificaciones: %', v_calificaciones_nuevas;
    RAISE NOTICE 'Promedio general: %', v_promedio_general;
    RAISE NOTICE '';
    RAISE NOTICE '📊 APROBADOS Y REPROBADOS:';
    RAISE NOTICE 'Estudiantes aprobados (≥3.0): % (%%)', v_aprobados, ROUND((v_aprobados::DECIMAL / v_students_con_notas * 100), 1);
    RAISE NOTICE 'Estudiantes reprobados (<3.0): % (%%)', v_reprobados, ROUND((v_reprobados::DECIMAL / v_students_con_notas * 100), 1);
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '🎉 SISTEMA LISTO CON DATOS DE CALIFICACIONES';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;

-- ============================================================
-- PASO 5: Mostrar muestra de estudiantes con sus promedios
-- ============================================================
SELECT 
    'TOP 10 ESTUDIANTES APROBADOS' as categoria,
    u.name as nombre,
    u.last_name as apellido,
    u.email,
    COUNT(sas.id) as total_notas,
    ROUND(AVG(sas.score), 2) as promedio
FROM users u
INNER JOIN student_activity_scores sas ON u.id = sas.student_id
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
GROUP BY u.id, u.name, u.last_name, u.email
HAVING AVG(sas.score) >= 3.0
ORDER BY promedio DESC
LIMIT 10;

SELECT 
    'TOP 10 ESTUDIANTES REPROBADOS' as categoria,
    u.name as nombre,
    u.last_name as apellido,
    u.email,
    COUNT(sas.id) as total_notas,
    ROUND(AVG(sas.score), 2) as promedio
FROM users u
INNER JOIN student_activity_scores sas ON u.id = sas.student_id
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
GROUP BY u.id, u.name, u.last_name, u.email
HAVING AVG(sas.score) < 3.0
ORDER BY promedio ASC
LIMIT 10;
