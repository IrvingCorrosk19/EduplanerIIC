-- ============================================================
-- GENERAR NOTAS REALISTAS CON APROBADOS Y REPROBADOS
-- Fecha: 16 de Octubre, 2025
-- Descripción: Genera notas con distribución realista
-- ============================================================

-- ============================================================
-- PASO 1: Limpiar notas existentes para regenerar
-- ============================================================
DELETE FROM student_activity_scores;

-- ============================================================
-- PASO 2: Generar notas con distribución realista
-- ============================================================
INSERT INTO student_activity_scores (
    id, student_id, activity_id, score, created_at, created_by, school_id
)
SELECT 
    uuid_generate_v4(),
    u.id,
    a.id,
    CASE 
        -- 5% estudiantes con notas muy bajas (0.5-1.5) - REPROBADOS
        WHEN RANDOM() < 0.05 THEN 0.5 + (RANDOM() * 1.0)
        -- 15% estudiantes con notas bajas (1.5-2.5) - REPROBADOS
        WHEN RANDOM() < 0.20 THEN 1.5 + (RANDOM() * 1.0)
        -- 25% estudiantes con notas regulares (2.5-3.5) - MIXTO
        WHEN RANDOM() < 0.45 THEN 2.5 + (RANDOM() * 1.0)
        -- 35% estudiantes con notas buenas (3.5-4.5) - APROBADOS
        WHEN RANDOM() < 0.80 THEN 3.5 + (RANDOM() * 1.0)
        -- 20% estudiantes con notas excelentes (4.5-5.0) - APROBADOS
        ELSE 4.5 + (RANDOM() * 0.5)
    END as nota,
    NOW(),
    a.teacher_id,
    (SELECT id FROM schools LIMIT 1)
FROM users u
CROSS JOIN activities a
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
AND u.status = 'active'
ORDER BY RANDOM()
LIMIT 8000; -- Generar 8000 calificaciones

-- ============================================================
-- PASO 3: Verificar resultados
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
    RAISE NOTICE '✅ NOTAS REALISTAS GENERADAS';
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
-- PASO 4: Mostrar estudiantes aprobados
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
-- PASO 5: Mostrar estudiantes reprobados
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
