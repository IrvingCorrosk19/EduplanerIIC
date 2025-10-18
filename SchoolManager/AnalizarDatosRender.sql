-- ============================================================
-- ANÁLISIS DE DATOS EN RENDER - ESTUDIANTES Y ASIGNACIONES
-- Fecha: 16 de Octubre, 2025
-- Descripción: Analiza estudiantes, profesores y asignaciones
-- ============================================================

-- ============================================================
-- ANÁLISIS 1: ESTUDIANTES Y SU ESTADO INCLUSIVO
-- ============================================================
DO $$
DECLARE
    total_students INTEGER;
    students_with_inclusive INTEGER;
    students_without_inclusive INTEGER;
    students_with_assignments INTEGER;
    students_without_assignments INTEGER;
    total_teachers INTEGER;
    total_subject_assignments INTEGER;
    total_teacher_assignments INTEGER;
    total_student_assignments INTEGER;
BEGIN
    -- Contar estudiantes totales
    SELECT COUNT(*) INTO total_students 
    FROM users 
    WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
    AND status = 'active';
    
    -- Contar estudiantes con campo inclusivo
    SELECT COUNT(*) INTO students_with_inclusive 
    FROM users 
    WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
    AND status = 'active' 
    AND inclusivo IS NOT NULL;
    
    -- Contar estudiantes sin campo inclusivo
    SELECT COUNT(*) INTO students_without_inclusive 
    FROM users 
    WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
    AND status = 'active' 
    AND inclusivo IS NULL;
    
    -- Contar estudiantes con asignaciones
    SELECT COUNT(DISTINCT u.id) INTO students_with_assignments
    FROM users u
    INNER JOIN student_assignments sa ON u.id = sa.student_id
    WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante') 
    AND u.status = 'active';
    
    -- Contar estudiantes sin asignaciones
    SELECT COUNT(*) INTO students_without_assignments
    FROM users u
    LEFT JOIN student_assignments sa ON u.id = sa.student_id
    WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante') 
    AND u.status = 'active'
    AND sa.student_id IS NULL;
    
    -- Contar profesores
    SELECT COUNT(*) INTO total_teachers 
    FROM users 
    WHERE role IN ('teacher', 'Teacher') 
    AND status = 'active';
    
    -- Contar asignaciones de materias
    SELECT COUNT(*) INTO total_subject_assignments FROM subject_assignments;
    
    -- Contar asignaciones de profesores
    SELECT COUNT(*) INTO total_teacher_assignments FROM teacher_assignments;
    
    -- Contar asignaciones de estudiantes
    SELECT COUNT(*) INTO total_student_assignments FROM student_assignments;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '📊 ANÁLISIS DE DATOS EN RENDER';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
    RAISE NOTICE '👥 ESTUDIANTES:';
    RAISE NOTICE '   Total de estudiantes activos: %', total_students;
    RAISE NOTICE '   Con campo inclusivo definido: %', students_with_inclusive;
    RAISE NOTICE '   Sin campo inclusivo definido: %', students_without_inclusive;
    RAISE NOTICE '   Con asignaciones a grados/grupos: %', students_with_assignments;
    RAISE NOTICE '   Sin asignaciones a grados/grupos: %', students_without_assignments;
    RAISE NOTICE '';
    RAISE NOTICE '👨‍🏫 PROFESORES:';
    RAISE NOTICE '   Total de profesores activos: %', total_teachers;
    RAISE NOTICE '';
    RAISE NOTICE '📚 ASIGNACIONES:';
    RAISE NOTICE '   Asignaciones de materias: %', total_subject_assignments;
    RAISE NOTICE '   Asignaciones de profesores: %', total_teacher_assignments;
    RAISE NOTICE '   Asignaciones de estudiantes: %', total_student_assignments;
    RAISE NOTICE '';
    
    -- Análisis de cobertura
    IF total_students > 0 THEN
        RAISE NOTICE '📈 COBERTURA:';
        RAISE NOTICE '   Estudiantes con inclusivo: %%%', ROUND((students_with_inclusive::DECIMAL / total_students * 100), 2);
        RAISE NOTICE '   Estudiantes asignados: %%%', ROUND((students_with_assignments::DECIMAL / total_students * 100), 2);
        RAISE NOTICE '';
    END IF;
    
    -- Recomendaciones
    RAISE NOTICE '💡 RECOMENDACIONES:';
    IF students_without_inclusive > 0 THEN
        RAISE NOTICE '   ⚠️  Actualizar campo inclusivo para % estudiantes', students_without_inclusive;
    END IF;
    IF students_without_assignments > 0 THEN
        RAISE NOTICE '   ⚠️  Asignar % estudiantes a grados/grupos', students_without_assignments;
    END IF;
    IF total_teacher_assignments = 0 THEN
        RAISE NOTICE '   ⚠️  No hay profesores asignados a materias';
    END IF;
    IF total_student_assignments = 0 THEN
        RAISE NOTICE '   ⚠️  No hay estudiantes asignados a grados/grupos';
    END IF;
    
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;

-- ============================================================
-- ANÁLISIS 2: DETALLES DE ESTUDIANTES SIN ASIGNACIONES
-- ============================================================
SELECT 
    'ESTUDIANTES SIN ASIGNACIONES' as categoria,
    u.name as nombre,
    u.last_name as apellido,
    u.email,
    u.inclusivo,
    u.orientacion,
    u.disciplina
FROM users u
LEFT JOIN student_assignments sa ON u.id = sa.student_id
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante') 
AND u.status = 'active'
AND sa.student_id IS NULL
ORDER BY u.name;

-- ============================================================
-- ANÁLISIS 3: DETALLES DE PROFESORES SIN ASIGNACIONES
-- ============================================================
SELECT 
    'PROFESORES SIN ASIGNACIONES' as categoria,
    u.name as nombre,
    u.last_name as apellido,
    u.email
FROM users u
LEFT JOIN teacher_assignments ta ON u.id = ta.teacher_id
WHERE u.role IN ('teacher', 'Teacher') 
AND u.status = 'active'
AND ta.teacher_id IS NULL
ORDER BY u.name;

-- ============================================================
-- ANÁLISIS 4: MATERIAS Y GRUPOS DISPONIBLES
-- ============================================================
SELECT 
    'MATERIAS DISPONIBLES' as categoria,
    s.name as materia,
    s.status as activa,
    a.name as area
FROM subjects s
LEFT JOIN areas a ON s."AreaId" = a.id
ORDER BY s.name;

SELECT 
    'GRUPOS DISPONIBLES' as categoria,
    g.name as grupo,
    gl.name as grado
FROM groups g
LEFT JOIN grade_levels gl ON g.grade_level_id = gl.id
ORDER BY gl.name, g.name;
