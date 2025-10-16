-- ============================================================
-- DATOS DUMMY PARA SISTEMA DE NOTAS COMPLETO
-- Fecha: 16 de Octubre, 2025
-- Descripción: Crea datos de prueba para actividades y notas
-- ============================================================

-- ============================================================
-- PASO 1: Verificar datos existentes
-- ============================================================
DO $$
DECLARE
    total_students INTEGER;
    total_teachers INTEGER;
    total_subjects INTEGER;
    total_groups INTEGER;
    total_grades INTEGER;
    total_trimesters INTEGER;
    total_activity_types INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_students FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante');
    SELECT COUNT(*) INTO total_teachers FROM users WHERE role IN ('teacher', 'Teacher');
    SELECT COUNT(*) INTO total_subjects FROM subjects;
    SELECT COUNT(*) INTO total_groups FROM groups;
    SELECT COUNT(*) INTO total_grades FROM grade_levels;
    SELECT COUNT(*) INTO total_trimesters FROM trimester WHERE is_active = true;
    SELECT COUNT(*) INTO total_activity_types FROM activity_types WHERE is_active = true;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '📊 DATOS DISPONIBLES EN EL SISTEMA:';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'Estudiantes activos: %', total_students;
    RAISE NOTICE 'Profesores activos: %', total_teachers;
    RAISE NOTICE 'Materias: %', total_subjects;
    RAISE NOTICE 'Grupos: %', total_groups;
    RAISE NOTICE 'Niveles de grado: %', total_grades;
    RAISE NOTICE 'Trimestres activos: %', total_trimesters;
    RAISE NOTICE 'Tipos de actividades: %', total_activity_types;
    RAISE NOTICE '';
    
    IF total_students < 1 THEN
        RAISE EXCEPTION '❌ Necesitas al menos 1 estudiante para crear notas de prueba';
    END IF;
    
    IF total_teachers < 1 THEN
        RAISE EXCEPTION '❌ Necesitas al menos 1 profesor para crear actividades';
    END IF;
    
    IF total_subjects < 1 THEN
        RAISE EXCEPTION '❌ Necesitas al menos 1 materia configurada';
    END IF;
END $$;

-- ============================================================
-- PASO 2: Crear actividades de prueba para cada trimestre
-- ============================================================

-- Actividades para el Trimestre I
WITH 
school_data AS (
    SELECT id as school_id FROM schools LIMIT 1
),
teacher_data AS (
    SELECT id, school_id FROM users WHERE role IN ('teacher', 'Teacher') AND status = 'active' LIMIT 1
),
subject_data AS (
    SELECT id, name FROM subjects WHERE status = true LIMIT 5
),
group_data AS (
    SELECT id, name FROM groups LIMIT 1
),
grade_data AS (
    SELECT id FROM grade_levels LIMIT 1
),
-- Insertar múltiples actividades
INSERT INTO activities (
    id, school_id, teacher_id, subject_id, group_id, grade_level_id, 
    name, type, trimester, due_date, created_at, created_by
)
SELECT
    uuid_generate_v4(),
    (SELECT id FROM school_data),
    (SELECT id FROM teacher_data),
    s.id,
    (SELECT id FROM group_data),
    (SELECT id FROM grade_data),
    '[PRUEBA] Examen ' || ROW_NUMBER() OVER (PARTITION BY s.id ORDER BY s.id) || ' - ' || s.name,
    'Evaluación',
    'T1',
    NOW() + INTERVAL '7 days',
    NOW(),
    (SELECT id FROM teacher_data)
FROM subject_data s
WHERE NOT EXISTS (
    SELECT 1 FROM activities 
    WHERE name LIKE '[PRUEBA] Examen%' 
    AND subject_id = s.id 
    AND trimester = 'T1'
)
LIMIT 5;

-- Tareas para T1
INSERT INTO activities (
    id, school_id, teacher_id, subject_id, group_id, grade_level_id, 
    name, type, trimester, due_date, created_at, created_by
)
SELECT
    uuid_generate_v4(),
    (SELECT id FROM school_data),
    (SELECT id FROM teacher_data),
    s.id,
    (SELECT id FROM group_data),
    (SELECT id FROM grade_data),
    '[PRUEBA] Tarea ' || ROW_NUMBER() OVER (PARTITION BY s.id ORDER BY s.id) || ' - ' || s.name,
    'Tarea',
    'T1',
    NOW() + INTERVAL '7 days',
    NOW(),
    (SELECT id FROM teacher_data)
FROM subject_data s
WHERE NOT EXISTS (
    SELECT 1 FROM activities 
    WHERE name LIKE '[PRUEBA] Tarea%' 
    AND subject_id = s.id 
    AND trimester = 'T1'
)
LIMIT 5;

-- Proyectos para T1
INSERT INTO activities (
    id, school_id, teacher_id, subject_id, group_id, grade_level_id, 
    name, type, trimester, due_date, created_at, created_by
)
SELECT
    uuid_generate_v4(),
    (SELECT id FROM school_data),
    (SELECT id FROM teacher_data),
    s.id,
    (SELECT id FROM group_data),
    (SELECT id FROM grade_data),
    '[PRUEBA] Proyecto ' || ROW_NUMBER() OVER (PARTITION BY s.id ORDER BY s.id) || ' - ' || s.name,
    'Proyecto',
    'T1',
    NOW() + INTERVAL '7 days',
    NOW(),
    (SELECT id FROM teacher_data)
FROM subject_data s
WHERE NOT EXISTS (
    SELECT 1 FROM activities 
    WHERE name LIKE '[PRUEBA] Proyecto%' 
    AND subject_id = s.id 
    AND trimester = 'T1'
)
LIMIT 5;

-- Actividades para el Trimestre II
WITH 
school_data AS (
    SELECT id as school_id FROM schools LIMIT 1
),
teacher_data AS (
    SELECT id, school_id FROM users WHERE role IN ('teacher', 'Teacher') AND status = 'active' LIMIT 1
),
subject_data AS (
    SELECT id, name FROM subjects WHERE status = true LIMIT 5
),
group_data AS (
    SELECT id, name FROM groups LIMIT 1
),
grade_data AS (
    SELECT id FROM grade_levels LIMIT 1
),
activity_type_data AS (
    SELECT id, name FROM activity_types WHERE is_active = true LIMIT 3
)

INSERT INTO activities (
    id, school_id, teacher_id, subject_id, group_id, grade_level_id, 
    "ActivityTypeId", name, type, trimester, due_date, created_at, created_by
)
SELECT
    uuid_generate_v4(),
    (SELECT school_id FROM school_data),
    (SELECT id FROM teacher_data),
    s.id,
    (SELECT id FROM group_data),
    (SELECT id FROM grade_data),
    at.id,
    '[PRUEBA T2] ' || 
    CASE 
        WHEN at.name LIKE '%Exam%' OR at.name LIKE '%Evaluaci%' THEN 'Examen'
        WHEN at.name LIKE '%Tarea%' OR at.name LIKE '%Homework%' THEN 'Tarea'
        WHEN at.name LIKE '%Proyecto%' OR at.name LIKE '%Project%' THEN 'Proyecto'
        ELSE 'Actividad'
    END || ' ' || (ROW_NUMBER() OVER (PARTITION BY s.id ORDER BY s.id)) || ' - ' || s.name,
    CASE 
        WHEN at.name LIKE '%Exam%' OR at.name LIKE '%Evaluaci%' THEN 'Evaluación'
        WHEN at.name LIKE '%Tarea%' OR at.name LIKE '%Homework%' THEN 'Tarea'
        ELSE 'Actividad'
    END,
    'T2',
    NOW() + INTERVAL '14 days',
    NOW(),
    (SELECT id FROM teacher_data)
FROM subject_data s
CROSS JOIN activity_type_data at
WHERE NOT EXISTS (
    SELECT 1 FROM activities 
    WHERE name LIKE '[PRUEBA T2]%' 
    AND subject_id = s.id 
    AND trimester = 'T2'
)
LIMIT 10;

-- Actividades para el Trimestre III
WITH 
school_data AS (
    SELECT id as school_id FROM schools LIMIT 1
),
teacher_data AS (
    SELECT id, school_id FROM users WHERE role IN ('teacher', 'Teacher') AND status = 'active' LIMIT 1
),
subject_data AS (
    SELECT id, name FROM subjects WHERE status = true LIMIT 5
),
group_data AS (
    SELECT id, name FROM groups LIMIT 1
),
grade_data AS (
    SELECT id FROM grade_levels LIMIT 1
),
activity_type_data AS (
    SELECT id, name FROM activity_types WHERE is_active = true LIMIT 2
)

INSERT INTO activities (
    id, school_id, teacher_id, subject_id, group_id, grade_level_id, 
    "ActivityTypeId", name, type, trimester, due_date, created_at, created_by
)
SELECT
    uuid_generate_v4(),
    (SELECT school_id FROM school_data),
    (SELECT id FROM teacher_data),
    s.id,
    (SELECT id FROM group_data),
    (SELECT id FROM grade_data),
    at.id,
    '[PRUEBA T3] Evaluación Final - ' || s.name,
    'Evaluación',
    'T3',
    NOW() + INTERVAL '21 days',
    NOW(),
    (SELECT id FROM teacher_data)
FROM subject_data s
CROSS JOIN activity_type_data at
WHERE NOT EXISTS (
    SELECT 1 FROM activities 
    WHERE name LIKE '[PRUEBA T3]%' 
    AND subject_id = s.id 
    AND trimester = 'T3'
)
LIMIT 8;

-- ============================================================
-- PASO 3: Crear calificaciones para los estudiantes
-- ============================================================

-- Calificaciones variadas para el Trimestre I
WITH 
students AS (
    SELECT id FROM users 
    WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
    AND status = 'active'
    LIMIT 20
),
activities_t1 AS (
    SELECT id FROM activities 
    WHERE name LIKE '[PRUEBA]%' 
    AND trimester = 'T1'
),
school_data AS (
    SELECT id FROM schools LIMIT 1
)

INSERT INTO student_activity_scores (
    id, student_id, activity_id, score, school_id, created_at, created_by
)
SELECT
    uuid_generate_v4(),
    s.id,
    a.id,
    CASE 
        -- 60% de notas buenas (3.5 - 5.0)
        WHEN random() < 0.6 THEN ROUND((random() * 1.5 + 3.5)::numeric, 1)
        -- 30% de notas regulares (3.0 - 3.4)
        WHEN random() < 0.9 THEN ROUND((random() * 0.4 + 3.0)::numeric, 1)
        -- 10% de notas bajas (1.0 - 2.9)
        ELSE ROUND((random() * 1.9 + 1.0)::numeric, 1)
    END,
    (SELECT id FROM school_data),
    NOW(),
    (SELECT id FROM users WHERE role IN ('teacher', 'Teacher') LIMIT 1)
FROM students s
CROSS JOIN activities_t1 a
WHERE NOT EXISTS (
    SELECT 1 FROM student_activity_scores 
    WHERE student_id = s.id AND activity_id = a.id
)
ON CONFLICT DO NOTHING;

-- Calificaciones para el Trimestre II
WITH 
students AS (
    SELECT id FROM users 
    WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
    AND status = 'active'
    LIMIT 20
),
activities_t2 AS (
    SELECT id FROM activities 
    WHERE name LIKE '[PRUEBA T2]%' 
    AND trimester = 'T2'
),
school_data AS (
    SELECT id FROM schools LIMIT 1
)

INSERT INTO student_activity_scores (
    id, student_id, activity_id, score, school_id, created_at, created_by
)
SELECT
    uuid_generate_v4(),
    s.id,
    a.id,
    ROUND((random() * 4.0 + 1.0)::numeric, 1), -- Notas de 1.0 a 5.0
    (SELECT id FROM school_data),
    NOW(),
    (SELECT id FROM users WHERE role IN ('teacher', 'Teacher') LIMIT 1)
FROM students s
CROSS JOIN activities_t2 a
WHERE NOT EXISTS (
    SELECT 1 FROM student_activity_scores 
    WHERE student_id = s.id AND activity_id = a.id
)
ON CONFLICT DO NOTHING;

-- Calificaciones para el Trimestre III (algunas pendientes)
WITH 
students AS (
    SELECT id FROM users 
    WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
    AND status = 'active'
    LIMIT 20
),
activities_t3 AS (
    SELECT id FROM activities 
    WHERE name LIKE '[PRUEBA T3]%' 
    AND trimester = 'T3'
),
school_data AS (
    SELECT id FROM schools LIMIT 1
)

INSERT INTO student_activity_scores (
    id, student_id, activity_id, score, school_id, created_at, created_by
)
SELECT
    uuid_generate_v4(),
    s.id,
    a.id,
    CASE 
        -- 70% tiene calificación
        WHEN random() < 0.7 THEN ROUND((random() * 4.0 + 1.0)::numeric, 1)
        -- 30% sin calificación aún (NULL se maneja después)
        ELSE ROUND((random() * 4.0 + 1.0)::numeric, 1)
    END,
    (SELECT id FROM school_data),
    NOW(),
    (SELECT id FROM users WHERE role IN ('teacher', 'Teacher') LIMIT 1)
FROM students s
CROSS JOIN activities_t3 a
WHERE random() < 0.7 -- Solo insertar el 70%
AND NOT EXISTS (
    SELECT 1 FROM student_activity_scores 
    WHERE student_id = s.id AND activity_id = a.id
)
ON CONFLICT DO NOTHING;

-- ============================================================
-- PASO 4: Crear algunos casos especiales
-- ============================================================

-- Estudiante con calificaciones perfectas (para pruebas)
WITH 
best_student AS (
    SELECT id FROM users 
    WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
    AND status = 'active'
    ORDER BY created_at
    LIMIT 1
),
all_activities AS (
    SELECT id FROM activities 
    WHERE name LIKE '[PRUEBA%'
    LIMIT 15
),
school_data AS (
    SELECT id FROM schools LIMIT 1
)

INSERT INTO student_activity_scores (
    id, student_id, activity_id, score, school_id, created_at, created_by
)
SELECT
    uuid_generate_v4(),
    (SELECT id FROM best_student),
    a.id,
    5.0, -- Calificación perfecta
    (SELECT id FROM school_data),
    NOW(),
    (SELECT id FROM users WHERE role IN ('teacher', 'Teacher') LIMIT 1)
FROM all_activities a
WHERE NOT EXISTS (
    SELECT 1 FROM student_activity_scores 
    WHERE student_id = (SELECT id FROM best_student) AND activity_id = a.id
)
ON CONFLICT DO NOTHING;

-- Estudiante con calificaciones bajas (para pruebas de recuperación)
WITH 
struggling_student AS (
    SELECT id FROM users 
    WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
    AND status = 'active'
    ORDER BY created_at DESC
    LIMIT 1
),
all_activities AS (
    SELECT id FROM activities 
    WHERE name LIKE '[PRUEBA%'
    AND trimester = 'T1'
    LIMIT 10
),
school_data AS (
    SELECT id FROM schools LIMIT 1
)

INSERT INTO student_activity_scores (
    id, student_id, activity_id, score, school_id, created_at, created_by
)
SELECT
    uuid_generate_v4(),
    (SELECT id FROM struggling_student),
    a.id,
    ROUND((random() * 1.5 + 1.0)::numeric, 1), -- Notas bajas: 1.0 - 2.5
    (SELECT id FROM school_data),
    NOW(),
    (SELECT id FROM users WHERE role IN ('teacher', 'Teacher') LIMIT 1)
FROM all_activities a
WHERE NOT EXISTS (
    SELECT 1 FROM student_activity_scores 
    WHERE student_id = (SELECT id FROM struggling_student) AND activity_id = a.id
)
ON CONFLICT DO NOTHING;

-- ============================================================
-- PASO 5: Reportar resultados
-- ============================================================

DO $$
DECLARE
    total_activities INTEGER;
    total_scores INTEGER;
    total_t1 INTEGER;
    total_t2 INTEGER;
    total_t3 INTEGER;
    avg_score NUMERIC;
    min_score NUMERIC;
    max_score NUMERIC;
BEGIN
    -- Contar actividades
    SELECT COUNT(*) INTO total_activities FROM activities WHERE name LIKE '[PRUEBA%';
    SELECT COUNT(*) INTO total_t1 FROM activities WHERE name LIKE '[PRUEBA]%' AND trimester = 'T1';
    SELECT COUNT(*) INTO total_t2 FROM activities WHERE name LIKE '[PRUEBA T2]%' AND trimester = 'T2';
    SELECT COUNT(*) INTO total_t3 FROM activities WHERE name LIKE '[PRUEBA T3]%' AND trimester = 'T3';
    
    -- Contar calificaciones
    SELECT COUNT(*) INTO total_scores 
    FROM student_activity_scores sas
    JOIN activities a ON a.id = sas.activity_id
    WHERE a.name LIKE '[PRUEBA%';
    
    -- Estadísticas de calificaciones
    SELECT 
        ROUND(AVG(sas.score), 2),
        MIN(sas.score),
        MAX(sas.score)
    INTO avg_score, min_score, max_score
    FROM student_activity_scores sas
    JOIN activities a ON a.id = sas.activity_id
    WHERE a.name LIKE '[PRUEBA%';
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '✅ DATOS DUMMY DE NOTAS CREADOS EXITOSAMENTE';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
    RAISE NOTICE '📚 ACTIVIDADES CREADAS:';
    RAISE NOTICE '   Total de actividades: %', total_activities;
    RAISE NOTICE '   - Trimestre I: %', total_t1;
    RAISE NOTICE '   - Trimestre II: %', total_t2;
    RAISE NOTICE '   - Trimestre III: %', total_t3;
    RAISE NOTICE '';
    RAISE NOTICE '📊 CALIFICACIONES GENERADAS:';
    RAISE NOTICE '   Total de calificaciones: %', total_scores;
    RAISE NOTICE '   Promedio general: %', avg_score;
    RAISE NOTICE '   Nota mínima: %', min_score;
    RAISE NOTICE '   Nota máxima: %', max_score;
    RAISE NOTICE '';
    RAISE NOTICE '🎯 CASOS ESPECIALES:';
    RAISE NOTICE '   ✅ Estudiante con notas perfectas (5.0)';
    RAISE NOTICE '   ⚠️  Estudiante con notas bajas (1.0 - 2.5)';
    RAISE NOTICE '   📝 Algunas actividades sin calificar en T3';
    RAISE NOTICE '';
    RAISE NOTICE '🚀 PRÓXIMOS PASOS:';
    RAISE NOTICE '   1. Inicia la aplicación: dotnet run';
    RAISE NOTICE '   2. Ve a los reportes de estudiantes';
    RAISE NOTICE '   3. Prueba el cuadro de aprobados/reprobados';
    RAISE NOTICE '   4. Verifica el libro de calificaciones de profesores';
    RAISE NOTICE '';
    RAISE NOTICE '💡 TIP: Las actividades tienen el prefijo [PRUEBA]';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;

-- ============================================================
-- CONSULTAS ÚTILES PARA VERIFICAR LOS DATOS
-- ============================================================

-- Ver resumen por estudiante y trimestre
/*
SELECT 
    u.name || ' ' || u.last_name AS estudiante,
    a.trimester,
    COUNT(sas.id) AS actividades_calificadas,
    ROUND(AVG(sas.score), 2) AS promedio,
    MIN(sas.score) AS nota_minima,
    MAX(sas.score) AS nota_maxima
FROM users u
JOIN student_activity_scores sas ON sas.student_id = u.id
JOIN activities a ON a.id = sas.activity_id
WHERE a.name LIKE '[PRUEBA%'
GROUP BY u.id, u.name, u.last_name, a.trimester
ORDER BY u.name, a.trimester;
*/

-- Ver actividades por materia y trimestre
/*
SELECT 
    s.name AS materia,
    a.trimester,
    COUNT(*) AS total_actividades,
    a.type AS tipo
FROM activities a
JOIN subjects s ON s.id = a.subject_id
WHERE a.name LIKE '[PRUEBA%'
GROUP BY s.name, a.trimester, a.type
ORDER BY s.name, a.trimester;
*/

-- Ver distribución de calificaciones
/*
SELECT 
    CASE 
        WHEN score >= 4.5 THEN 'Excelente (4.5-5.0)'
        WHEN score >= 4.0 THEN 'Sobresaliente (4.0-4.4)'
        WHEN score >= 3.5 THEN 'Bueno (3.5-3.9)'
        WHEN score >= 3.0 THEN 'Aceptable (3.0-3.4)'
        ELSE 'Bajo (<3.0)'
    END AS rango,
    COUNT(*) AS cantidad,
    ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()), 2) AS porcentaje
FROM student_activity_scores sas
JOIN activities a ON a.id = sas.activity_id
WHERE a.name LIKE '[PRUEBA%'
GROUP BY 
    CASE 
        WHEN score >= 4.5 THEN 'Excelente (4.5-5.0)'
        WHEN score >= 4.0 THEN 'Sobresaliente (4.0-4.4)'
        WHEN score >= 3.5 THEN 'Bueno (3.5-3.9)'
        WHEN score >= 3.0 THEN 'Aceptable (3.0-3.4)'
        ELSE 'Bajo (<3.0)'
    END
ORDER BY rango;
*/

-- ============================================================
-- LIMPIAR DATOS DE PRUEBA (si es necesario)
-- ============================================================
/*
-- Borrar calificaciones de prueba
DELETE FROM student_activity_scores 
WHERE activity_id IN (
    SELECT id FROM activities WHERE name LIKE '[PRUEBA%'
);

-- Borrar actividades de prueba
DELETE FROM activities WHERE name LIKE '[PRUEBA%';

SELECT 'Datos de prueba eliminados' AS resultado;
*/

