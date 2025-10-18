-- ============================================================
-- VERIFICAR Y COMPLETAR NOTAS PARA TODOS LOS ESTUDIANTES
-- Fecha: 16 de Octubre, 2025
-- Descripción: Verifica cuántos estudiantes tienen notas y completa las faltantes
-- ============================================================

-- ============================================================
-- PASO 1: Verificar estudiantes con y sin notas
-- ============================================================
DO $$
DECLARE
    total_students INTEGER;
    students_with_scores INTEGER;
    students_without_scores INTEGER;
    total_activities INTEGER;
    total_scores INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_students 
    FROM users 
    WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
    AND status = 'active';
    
    SELECT COUNT(DISTINCT student_id) INTO students_with_scores 
    FROM student_activity_scores;
    
    SELECT COUNT(*) INTO total_activities FROM activities;
    SELECT COUNT(*) INTO total_scores FROM student_activity_scores;
    
    students_without_scores := total_students - students_with_scores;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '📊 VERIFICACIÓN DE NOTAS PARA ESTUDIANTES';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'Total de estudiantes: %', total_students;
    RAISE NOTICE 'Estudiantes con notas: %', students_with_scores;
    RAISE NOTICE 'Estudiantes sin notas: %', students_without_scores;
    RAISE NOTICE 'Total de actividades: %', total_activities;
    RAISE NOTICE 'Total de calificaciones: %', total_scores;
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
    
    IF students_without_scores > 0 THEN
        RAISE NOTICE '⚠️  Hay % estudiantes sin notas', students_without_scores;
        RAISE NOTICE 'Se generarán notas para todos los estudiantes...';
    ELSE
        RAISE NOTICE '✅ Todos los estudiantes tienen notas';
    END IF;
END $$;

-- ============================================================
-- PASO 2: Mostrar estudiantes sin notas
-- ============================================================
SELECT 
    'ESTUDIANTES SIN NOTAS' as categoria,
    u.id,
    u.name as nombre,
    u.last_name as apellido,
    u.email,
    u.inclusivo,
    u.orientacion,
    u.disciplina
FROM users u
LEFT JOIN student_activity_scores sas ON u.id = sas.student_id
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
AND u.status = 'active'
AND sas.student_id IS NULL
ORDER BY u.name
LIMIT 20;

-- ============================================================
-- PASO 3: Generar notas para TODOS los estudiantes
-- ============================================================
INSERT INTO student_activity_scores (
    id, student_id, activity_id, score, created_at, created_by, school_id
)
SELECT 
    uuid_generate_v4(),
    u.id,
    a.id,
    CASE 
        WHEN RANDOM() < 0.1 THEN 1.0 + (RANDOM() * 1.0) -- 10% notas bajas (1.0-2.0)
        WHEN RANDOM() < 0.3 THEN 2.0 + (RANDOM() * 1.0) -- 20% notas regulares (2.0-3.0)
        WHEN RANDOM() < 0.7 THEN 3.0 + (RANDOM() * 1.0) -- 40% notas buenas (3.0-4.0)
        ELSE 4.0 + (RANDOM() * 1.0) -- 30% notas excelentes (4.0-5.0)
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
LIMIT 2000; -- Generar hasta 2000 calificaciones adicionales

-- ============================================================
-- PASO 4: Verificación final
-- ============================================================
DO $$
DECLARE
    total_students INTEGER;
    students_with_scores INTEGER;
    students_without_scores INTEGER;
    total_activities INTEGER;
    total_scores INTEGER;
    avg_score DECIMAL;
    min_score DECIMAL;
    max_score DECIMAL;
BEGIN
    SELECT COUNT(*) INTO total_students 
    FROM users 
    WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
    AND status = 'active';
    
    SELECT COUNT(DISTINCT student_id) INTO students_with_scores 
    FROM student_activity_scores;
    
    SELECT COUNT(*) INTO total_activities FROM activities;
    SELECT COUNT(*) INTO total_scores FROM student_activity_scores;
    SELECT ROUND(AVG(score), 2) INTO avg_score FROM student_activity_scores;
    SELECT ROUND(MIN(score), 2) INTO min_score FROM student_activity_scores;
    SELECT ROUND(MAX(score), 2) INTO max_score FROM student_activity_scores;
    
    students_without_scores := total_students - students_with_scores;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '✅ VERIFICACIÓN FINAL COMPLETADA';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'Total de estudiantes: %', total_students;
    RAISE NOTICE 'Estudiantes con notas: %', students_with_scores;
    RAISE NOTICE 'Estudiantes sin notas: %', students_without_scores;
    RAISE NOTICE 'Total de actividades: %', total_activities;
    RAISE NOTICE 'Total de calificaciones: %', total_scores;
    RAISE NOTICE 'Promedio general: %', avg_score;
    RAISE NOTICE 'Nota mínima: %', min_score;
    RAISE NOTICE 'Nota máxima: %', max_score;
    RAISE NOTICE '';
    
    IF students_without_scores = 0 THEN
        RAISE NOTICE '🎉 ¡TODOS LOS ESTUDIANTES TIENEN NOTAS!';
    ELSE
        RAISE NOTICE '⚠️  Aún hay % estudiantes sin notas', students_without_scores;
    END IF;
    
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;

-- ============================================================
-- PASO 5: Mostrar algunos estudiantes con sus notas
-- ============================================================
SELECT 
    'ESTUDIANTES CON NOTAS (MUESTRA)' as categoria,
    u.name as nombre,
    u.last_name as apellido,
    u.email,
    u.inclusivo,
    COUNT(sas.id) as total_notas,
    ROUND(AVG(sas.score), 2) as promedio_general,
    ROUND(MIN(sas.score), 2) as nota_minima,
    ROUND(MAX(sas.score), 2) as nota_maxima
FROM users u
INNER JOIN student_activity_scores sas ON u.id = sas.student_id
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante') 
AND u.status = 'active'
GROUP BY u.id, u.name, u.last_name, u.email, u.inclusivo
ORDER BY promedio_general DESC
LIMIT 15;
