-- ============================================================
-- GENERAR MÁS NOTAS PARA VER APROBADOS Y REPROBADOS
-- Fecha: 16 de Octubre, 2025
-- Descripción: Genera más calificaciones con distribución realista
-- ============================================================

-- ============================================================
-- PASO 1: Verificar estado actual
-- ============================================================
DO $$
DECLARE
    total_students INTEGER;
    total_activities INTEGER;
    total_scores INTEGER;
    avg_score DECIMAL;
    min_score DECIMAL;
    max_score DECIMAL;
    students_approved INTEGER;
    students_failed INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_students FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') AND status = 'active';
    SELECT COUNT(*) INTO total_activities FROM activities;
    SELECT COUNT(*) INTO total_scores FROM student_activity_scores;
    SELECT ROUND(AVG(score), 2) INTO avg_score FROM student_activity_scores;
    SELECT ROUND(MIN(score), 2) INTO min_score FROM student_activity_scores;
    SELECT ROUND(MAX(score), 2) INTO max_score FROM student_activity_scores;
    
    -- Contar estudiantes aprobados (promedio >= 3.0)
    SELECT COUNT(DISTINCT student_id) INTO students_approved
    FROM (
        SELECT student_id, AVG(score) as promedio
        FROM student_activity_scores
        GROUP BY student_id
        HAVING AVG(score) >= 3.0
    ) as aprobados;
    
    -- Contar estudiantes reprobados (promedio < 3.0)
    SELECT COUNT(DISTINCT student_id) INTO students_failed
    FROM (
        SELECT student_id, AVG(score) as promedio
        FROM student_activity_scores
        GROUP BY student_id
        HAVING AVG(score) < 3.0
    ) as reprobados;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '📊 ESTADO ACTUAL DE NOTAS';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'Total de estudiantes: %', total_students;
    RAISE NOTICE 'Total de actividades: %', total_activities;
    RAISE NOTICE 'Total de calificaciones: %', total_scores;
    RAISE NOTICE 'Promedio general: %', avg_score;
    RAISE NOTICE 'Nota mínima: %', min_score;
    RAISE NOTICE 'Nota máxima: %', max_score;
    RAISE NOTICE 'Estudiantes aprobados: %', students_approved;
    RAISE NOTICE 'Estudiantes reprobados: %', students_failed;
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;

-- ============================================================
-- PASO 2: Generar más actividades
-- ============================================================
INSERT INTO activities (
    id, school_id, teacher_id, subject_id, group_id, grade_level_id, 
    name, type, trimester, due_date, created_at, created_by
)
SELECT 
    uuid_generate_v4(),
    (SELECT id FROM schools LIMIT 1),
    ta.teacher_id,
    sa.subject_id,
    sa.group_id,
    sa.grade_level_id,
    CASE 
        WHEN at.name = 'Evaluación' THEN 'Examen Final de ' || s.name || ' - ' || t.name
        WHEN at.name = 'Tarea' THEN 'Tarea Especial de ' || s.name || ' - ' || t.name
        WHEN at.name = 'Proyecto' THEN 'Proyecto Final de ' || s.name || ' - ' || t.name
        WHEN at.name = 'Participación' THEN 'Participación Final en ' || s.name || ' - ' || t.name
        WHEN at.name = 'Laboratorio' THEN 'Laboratorio Final de ' || s.name || ' - ' || t.name
        ELSE 'Actividad Final de ' || s.name || ' - ' || t.name
    END as nombre_actividad,
    at.name,
    t.name,
    CASE 
        WHEN t.name = 'Trimestre I' THEN '2025-04-15'::date
        WHEN t.name = 'Trimestre II' THEN '2025-07-15'::date
        WHEN t.name = 'Trimestre III' THEN '2025-10-15'::date
        ELSE '2025-12-15'::date
    END as fecha_vencimiento,
    NOW(),
    ta.teacher_id
FROM subject_assignments sa
INNER JOIN teacher_assignments ta ON sa.id = ta.subject_assignment_id
INNER JOIN subjects s ON sa.subject_id = s.id
INNER JOIN trimester t ON t.is_active = true
INNER JOIN activity_types at ON at.is_active = true
WHERE NOT EXISTS (
    SELECT 1 FROM activities a 
    WHERE a.subject_id = sa.subject_id 
    AND a.group_id = sa.group_id 
    AND a.grade_level_id = sa.grade_level_id
    AND a.teacher_id = ta.teacher_id
    AND a.trimester = t.name
    AND a.type = at.name
    AND a.name LIKE '%Final%'
)
ORDER BY RANDOM()
LIMIT 150; -- Generar 150 actividades adicionales

-- ============================================================
-- PASO 3: Generar más notas con distribución realista
-- ============================================================
INSERT INTO student_activity_scores (
    id, student_id, activity_id, score, created_at, created_by, school_id
)
SELECT 
    uuid_generate_v4(),
    u.id,
    a.id,
    CASE 
        -- 15% estudiantes con notas muy bajas (0.5-2.0) - REPROBADOS
        WHEN RANDOM() < 0.15 THEN 0.5 + (RANDOM() * 1.5)
        -- 25% estudiantes con notas bajas (2.0-2.9) - REPROBADOS
        WHEN RANDOM() < 0.40 THEN 2.0 + (RANDOM() * 0.9)
        -- 35% estudiantes con notas regulares (3.0-3.9) - APROBADOS
        WHEN RANDOM() < 0.75 THEN 3.0 + (RANDOM() * 0.9)
        -- 20% estudiantes con notas buenas (4.0-4.5) - APROBADOS
        WHEN RANDOM() < 0.95 THEN 4.0 + (RANDOM() * 0.5)
        -- 5% estudiantes con notas excelentes (4.5-5.0) - APROBADOS
        ELSE 4.5 + (RANDOM() * 0.5)
    END as nota,
    NOW(),
    a.teacher_id,
    (SELECT id FROM schools LIMIT 1)
FROM users u
CROSS JOIN activities a
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
AND u.status = 'active'
AND NOT EXISTS (
    SELECT 1 FROM student_activity_scores sas 
    WHERE sas.student_id = u.id 
    AND sas.activity_id = a.id
)
ORDER BY RANDOM()
LIMIT 3000; -- Generar 3000 calificaciones adicionales

-- ============================================================
-- PASO 4: Verificar resultados finales
-- ============================================================
DO $$
DECLARE
    total_students INTEGER;
    total_activities INTEGER;
    total_scores INTEGER;
    avg_score DECIMAL;
    min_score DECIMAL;
    max_score DECIMAL;
    students_approved INTEGER;
    students_failed INTEGER;
    students_with_notes INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_students FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') AND status = 'active';
    SELECT COUNT(*) INTO total_activities FROM activities;
    SELECT COUNT(*) INTO total_scores FROM student_activity_scores;
    SELECT ROUND(AVG(score), 2) INTO avg_score FROM student_activity_scores;
    SELECT ROUND(MIN(score), 2) INTO min_score FROM student_activity_scores;
    SELECT ROUND(MAX(score), 2) INTO max_score FROM student_activity_scores;
    SELECT COUNT(DISTINCT student_id) INTO students_with_notes FROM student_activity_scores;
    
    -- Contar estudiantes aprobados (promedio >= 3.0)
    SELECT COUNT(DISTINCT student_id) INTO students_approved
    FROM (
        SELECT student_id, AVG(score) as promedio
        FROM student_activity_scores
        GROUP BY student_id
        HAVING AVG(score) >= 3.0
    ) as aprobados;
    
    -- Contar estudiantes reprobados (promedio < 3.0)
    SELECT COUNT(DISTINCT student_id) INTO students_failed
    FROM (
        SELECT student_id, AVG(score) as promedio
        FROM student_activity_scores
        GROUP BY student_id
        HAVING AVG(score) < 3.0
    ) as reprobados;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '✅ NOTAS GENERADAS CON APROBADOS Y REPROBADOS';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'Total de estudiantes: %', total_students;
    RAISE NOTICE 'Estudiantes con notas: %', students_with_notes;
    RAISE NOTICE 'Total de actividades: %', total_activities;
    RAISE NOTICE 'Total de calificaciones: %', total_scores;
    RAISE NOTICE 'Promedio general: %', avg_score;
    RAISE NOTICE 'Nota mínima: %', min_score;
    RAISE NOTICE 'Nota máxima: %', max_score;
    RAISE NOTICE '';
    RAISE NOTICE '📊 APROBADOS Y REPROBADOS:';
    RAISE NOTICE '   Estudiantes aprobados (≥3.0): % (%%)', students_approved, ROUND((students_approved::DECIMAL / students_with_notes * 100), 1);
    RAISE NOTICE '   Estudiantes reprobados (<3.0): % (%%)', students_failed, ROUND((students_failed::DECIMAL / students_with_notes * 100), 1);
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '🎉 SISTEMA LISTO PARA APROBADOS/REPROBADOS';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;

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
