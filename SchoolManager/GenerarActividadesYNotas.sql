-- ============================================================
-- GENERAR ACTIVIDADES Y NOTAS PARA TODOS LOS ESTUDIANTES
-- Fecha: 16 de Octubre, 2025
-- Descripción: Crea actividades y notas para todos los estudiantes asignados
-- ============================================================

-- ============================================================
-- PASO 1: Verificar datos disponibles
-- ============================================================
DO $$
DECLARE
    total_students INTEGER;
    students_with_assignments INTEGER;
    total_teachers INTEGER;
    teachers_with_assignments INTEGER;
    total_subjects INTEGER;
    total_trimesters INTEGER;
    total_activity_types INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_students 
    FROM users 
    WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
    AND status = 'active';
    
    SELECT COUNT(DISTINCT u.id) INTO students_with_assignments
    FROM users u
    INNER JOIN student_assignments sa ON u.id = sa.student_id
    WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante') 
    AND u.status = 'active';
    
    SELECT COUNT(*) INTO total_teachers 
    FROM users 
    WHERE role IN ('teacher', 'Teacher') 
    AND status = 'active';
    
    SELECT COUNT(DISTINCT u.id) INTO teachers_with_assignments
    FROM users u
    INNER JOIN teacher_assignments ta ON u.id = ta.teacher_id
    WHERE u.role IN ('teacher', 'Teacher') 
    AND u.status = 'active';
    
    SELECT COUNT(*) INTO total_subjects FROM subjects WHERE status = true;
    SELECT COUNT(*) INTO total_trimesters FROM trimester WHERE is_active = true;
    SELECT COUNT(*) INTO total_activity_types FROM activity_types WHERE is_active = true;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '📊 DATOS DISPONIBLES PARA GENERAR ACTIVIDADES';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'Estudiantes totales: %', total_students;
    RAISE NOTICE 'Estudiantes con asignaciones: %', students_with_assignments;
    RAISE NOTICE 'Profesores totales: %', total_teachers;
    RAISE NOTICE 'Profesores con asignaciones: %', teachers_with_assignments;
    RAISE NOTICE 'Materias: %', total_subjects;
    RAISE NOTICE 'Trimestres: %', total_trimesters;
    RAISE NOTICE 'Tipos de actividades: %', total_activity_types;
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
    
    IF students_with_assignments < 1 THEN
        RAISE EXCEPTION '❌ No hay estudiantes con asignaciones para generar actividades';
    END IF;
    
    IF teachers_with_assignments < 1 THEN
        RAISE EXCEPTION '❌ No hay profesores con asignaciones para generar actividades';
    END IF;
    
    IF total_subjects < 1 THEN
        RAISE EXCEPTION '❌ No hay materias disponibles';
    END IF;
    
    IF total_trimesters < 1 THEN
        RAISE EXCEPTION '❌ No hay trimestres activos';
    END IF;
    
    IF total_activity_types < 1 THEN
        RAISE EXCEPTION '❌ No hay tipos de actividades disponibles';
    END IF;
END $$;

-- ============================================================
-- PASO 2: Crear trimestres si no existen
-- ============================================================
INSERT INTO trimester (id, name, start_date, end_date, is_active, created_at)
SELECT 
    uuid_generate_v4(),
    trimestres.trimestre,
    trimestres.fecha_inicio,
    trimestres.fecha_fin,
    true,
    NOW()
FROM (
    VALUES 
    ('Trimestre I', '2025-01-15'::date, '2025-04-15'::date),
    ('Trimestre II', '2025-04-16'::date, '2025-07-15'::date),
    ('Trimestre III', '2025-07-16'::date, '2025-10-15'::date)
) AS trimestres(trimestre, fecha_inicio, fecha_fin)
WHERE NOT EXISTS (
    SELECT 1 FROM trimester WHERE name = trimestres.trimestre
);

-- ============================================================
-- PASO 3: Crear tipos de actividades si no existen
-- ============================================================
INSERT INTO activity_types (id, name, description, is_active, created_at)
SELECT 
    uuid_generate_v4(),
    tipos.tipo,
    tipos.descripcion,
    true,
    NOW()
FROM (
    VALUES 
    ('Evaluación', 'Exámenes y evaluaciones formales'),
    ('Tarea', 'Tareas y trabajos asignados'),
    ('Proyecto', 'Proyectos y trabajos especiales'),
    ('Participación', 'Participación en clase'),
    ('Laboratorio', 'Actividades de laboratorio'),
    ('Práctica', 'Ejercicios prácticos')
) AS tipos(tipo, descripcion)
WHERE NOT EXISTS (
    SELECT 1 FROM activity_types WHERE name = tipos.tipo
);

-- ============================================================
-- PASO 4: Generar actividades para cada materia asignada
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
        WHEN at.name = 'Evaluación' THEN 'Examen de ' || s.name || ' - ' || t.name
        WHEN at.name = 'Tarea' THEN 'Tarea de ' || s.name || ' - ' || t.name
        WHEN at.name = 'Proyecto' THEN 'Proyecto de ' || s.name || ' - ' || t.name
        WHEN at.name = 'Participación' THEN 'Participación en ' || s.name || ' - ' || t.name
        WHEN at.name = 'Laboratorio' THEN 'Laboratorio de ' || s.name || ' - ' || t.name
        ELSE 'Actividad de ' || s.name || ' - ' || t.name
    END as nombre_actividad,
    at.name,
    t.name,
    CASE 
        WHEN t.name = 'Trimestre I' THEN '2025-03-15'::date
        WHEN t.name = 'Trimestre II' THEN '2025-06-15'::date
        WHEN t.name = 'Trimestre III' THEN '2025-09-15'::date
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
)
ORDER BY RANDOM()
LIMIT 100; -- Generar hasta 100 actividades

-- ============================================================
-- PASO 5: Generar notas para todos los estudiantes
-- ============================================================
INSERT INTO student_activity_scores (
    id, student_id, activity_id, score, created_at, created_by, school_id
)
SELECT 
    uuid_generate_v4(),
    sa.student_id,
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
FROM student_assignments sa
INNER JOIN activities a ON sa.grade_id = a.grade_level_id AND sa.group_id = a.group_id
WHERE NOT EXISTS (
    SELECT 1 FROM student_activity_scores sas 
    WHERE sas.student_id = sa.student_id 
    AND sas.activity_id = a.id
)
ORDER BY RANDOM()
LIMIT 500; -- Generar hasta 500 calificaciones

-- ============================================================
-- PASO 6: Verificar resultados
-- ============================================================
DO $$
DECLARE
    total_activities INTEGER;
    total_scores INTEGER;
    total_students INTEGER;
    students_with_scores INTEGER;
    avg_score DECIMAL;
    min_score DECIMAL;
    max_score DECIMAL;
BEGIN
    SELECT COUNT(*) INTO total_activities FROM activities;
    SELECT COUNT(*) INTO total_scores FROM student_activity_scores;
    SELECT COUNT(*) INTO total_students FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') AND status = 'active';
    SELECT COUNT(DISTINCT student_id) INTO students_with_scores FROM student_activity_scores;
    SELECT ROUND(AVG(score), 2) INTO avg_score FROM student_activity_scores;
    SELECT ROUND(MIN(score), 2) INTO min_score FROM student_activity_scores;
    SELECT ROUND(MAX(score), 2) INTO max_score FROM student_activity_scores;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '✅ ACTIVIDADES Y NOTAS GENERADAS EXITOSAMENTE';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
    RAISE NOTICE '📚 ACTIVIDADES:';
    RAISE NOTICE '   Total de actividades: %', total_activities;
    RAISE NOTICE '';
    RAISE NOTICE '📊 CALIFICACIONES:';
    RAISE NOTICE '   Total de calificaciones: %', total_scores;
    RAISE NOTICE '   Estudiantes con calificaciones: %', students_with_scores;
    RAISE NOTICE '   Promedio general: %', avg_score;
    RAISE NOTICE '   Nota mínima: %', min_score;
    RAISE NOTICE '   Nota máxima: %', max_score;
    RAISE NOTICE '';
    RAISE NOTICE '👥 COBERTURA:';
    RAISE NOTICE '   Estudiantes totales: %', total_students;
    RAISE NOTICE '   Estudiantes con notas: % (%%)', students_with_scores, ROUND((students_with_scores::DECIMAL / total_students * 100), 1);
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '🎉 SISTEMA DE NOTAS LISTO PARA USAR';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;

-- ============================================================
-- PASO 7: Mostrar algunas actividades generadas
-- ============================================================
SELECT 
    'ACTIVIDADES GENERADAS' as categoria,
    a.name as actividad,
    s.name as materia,
    gl.name as grado,
    g.name as grupo,
    a.type as tipo,
    a.trimester as trimestre,
    a.due_date as fecha_vencimiento,
    u.name as profesor
FROM activities a
INNER JOIN subjects s ON a.subject_id = s.id
INNER JOIN grade_levels gl ON a.grade_level_id = gl.id
INNER JOIN groups g ON a.group_id = g.id
INNER JOIN users u ON a.teacher_id = u.id
ORDER BY a.created_at DESC
LIMIT 10;

-- ============================================================
-- PASO 8: Mostrar algunas calificaciones generadas
-- ============================================================
SELECT 
    'CALIFICACIONES GENERADAS' as categoria,
    u.name as estudiante,
    u.last_name as apellido,
    a.name as actividad,
    s.name as materia,
    sas.score as nota,
    a.trimester as trimestre
FROM student_activity_scores sas
INNER JOIN users u ON sas.student_id = u.id
INNER JOIN activities a ON sas.activity_id = a.id
INNER JOIN subjects s ON a.subject_id = s.id
ORDER BY sas.created_at DESC
LIMIT 10;
