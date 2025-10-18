-- ============================================================
-- VERIFICAR ASIGNACIONES DE PROFESORES EN RENDER
-- Fecha: 16 de Octubre, 2025
-- Descripción: Verifica y crea asignaciones de profesores a materias
-- ============================================================

-- ============================================================
-- PASO 1: Verificar estado actual de asignaciones
-- ============================================================
DO $$
DECLARE
    total_teachers INTEGER;
    teachers_with_assignments INTEGER;
    teachers_without_assignments INTEGER;
    total_subject_assignments INTEGER;
    total_teacher_assignments INTEGER;
    total_students INTEGER;
    students_with_assignments INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_teachers 
    FROM users 
    WHERE role IN ('teacher', 'Teacher') 
    AND status = 'active';
    
    SELECT COUNT(DISTINCT u.id) INTO teachers_with_assignments
    FROM users u
    INNER JOIN teacher_assignments ta ON u.id = ta.teacher_id
    WHERE u.role IN ('teacher', 'Teacher') 
    AND u.status = 'active';
    
    SELECT COUNT(*) INTO teachers_without_assignments
    FROM users u
    LEFT JOIN teacher_assignments ta ON u.id = ta.teacher_id
    WHERE u.role IN ('teacher', 'Teacher') 
    AND u.status = 'active'
    AND ta.teacher_id IS NULL;
    
    SELECT COUNT(*) INTO total_subject_assignments FROM subject_assignments;
    SELECT COUNT(*) INTO total_teacher_assignments FROM teacher_assignments;
    
    SELECT COUNT(*) INTO total_students 
    FROM users 
    WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
    AND status = 'active';
    
    SELECT COUNT(DISTINCT u.id) INTO students_with_assignments
    FROM users u
    INNER JOIN student_assignments sa ON u.id = sa.student_id
    WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante') 
    AND u.status = 'active';
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '📊 ESTADO DE ASIGNACIONES';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
    RAISE NOTICE '👨‍🏫 PROFESORES:';
    RAISE NOTICE '   Total: %', total_teachers;
    RAISE NOTICE '   Con asignaciones: %', teachers_with_assignments;
    RAISE NOTICE '   Sin asignaciones: %', teachers_without_assignments;
    RAISE NOTICE '';
    RAISE NOTICE '👥 ESTUDIANTES:';
    RAISE NOTICE '   Total: %', total_students;
    RAISE NOTICE '   Con asignaciones: %', students_with_assignments;
    RAISE NOTICE '';
    RAISE NOTICE '📚 ASIGNACIONES:';
    RAISE NOTICE '   Asignaciones de materias: %', total_subject_assignments;
    RAISE NOTICE '   Asignaciones de profesores: %', total_teacher_assignments;
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;

-- ============================================================
-- PASO 2: Crear asignaciones de profesores si no existen
-- ============================================================
INSERT INTO teacher_assignments (id, teacher_id, subject_assignment_id, created_at)
SELECT 
    uuid_generate_v4(),
    u.id,
    sa.id,
    NOW()
FROM users u
CROSS JOIN subject_assignments sa
WHERE u.role IN ('teacher', 'Teacher')
AND u.status = 'active'
AND NOT EXISTS (
    SELECT 1 FROM teacher_assignments ta 
    WHERE ta.teacher_id = u.id AND ta.subject_assignment_id = sa.id
)
ORDER BY RANDOM()
LIMIT 30; -- Asignar hasta 30 profesores

-- ============================================================
-- PASO 3: Crear asignaciones de estudiantes si no existen
-- ============================================================
INSERT INTO student_assignments (id, student_id, grade_id, group_id, created_at)
SELECT 
    uuid_generate_v4(),
    u.id,
    gl.id,
    g.id,
    NOW()
FROM users u
CROSS JOIN grade_levels gl
CROSS JOIN groups g
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
AND u.status = 'active'
AND gl.name = SPLIT_PART(g.name, '°', 1) || '° Grado'
AND NOT EXISTS (
    SELECT 1 FROM student_assignments sa 
    WHERE sa.student_id = u.id AND sa.grade_id = gl.id AND sa.group_id = g.id
)
ORDER BY RANDOM()
LIMIT 40; -- Asignar hasta 40 estudiantes

-- ============================================================
-- PASO 4: Verificar resultados finales
-- ============================================================
DO $$
DECLARE
    total_teachers INTEGER;
    teachers_with_assignments INTEGER;
    total_students INTEGER;
    students_with_assignments INTEGER;
    total_teacher_assignments INTEGER;
    total_student_assignments INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_teachers 
    FROM users 
    WHERE role IN ('teacher', 'Teacher') 
    AND status = 'active';
    
    SELECT COUNT(DISTINCT u.id) INTO teachers_with_assignments
    FROM users u
    INNER JOIN teacher_assignments ta ON u.id = ta.teacher_id
    WHERE u.role IN ('teacher', 'Teacher') 
    AND u.status = 'active';
    
    SELECT COUNT(*) INTO total_students 
    FROM users 
    WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
    AND status = 'active';
    
    SELECT COUNT(DISTINCT u.id) INTO students_with_assignments
    FROM users u
    INNER JOIN student_assignments sa ON u.id = sa.student_id
    WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante') 
    AND u.status = 'active';
    
    SELECT COUNT(*) INTO total_teacher_assignments FROM teacher_assignments;
    SELECT COUNT(*) INTO total_student_assignments FROM student_assignments;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '✅ ASIGNACIONES COMPLETADAS';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
    RAISE NOTICE '👨‍🏫 PROFESORES:';
    RAISE NOTICE '   Total: %', total_teachers;
    RAISE NOTICE '   Con asignaciones: % (%%)', teachers_with_assignments, ROUND((teachers_with_assignments::DECIMAL / total_teachers * 100), 1);
    RAISE NOTICE '';
    RAISE NOTICE '👥 ESTUDIANTES:';
    RAISE NOTICE '   Total: %', total_students;
    RAISE NOTICE '   Con asignaciones: % (%%)', students_with_assignments, ROUND((students_with_assignments::DECIMAL / total_students * 100), 1);
    RAISE NOTICE '';
    RAISE NOTICE '🔗 ASIGNACIONES TOTALES:';
    RAISE NOTICE '   Asignaciones de profesores: %', total_teacher_assignments;
    RAISE NOTICE '   Asignaciones de estudiantes: %', total_student_assignments;
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '🎉 SISTEMA LISTO PARA PRUEBAS';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;

-- ============================================================
-- PASO 5: Mostrar resumen de asignaciones
-- ============================================================
SELECT 
    'PROFESORES CON ASIGNACIONES' as categoria,
    u.name as nombre,
    u.last_name as apellido,
    u.email,
    COUNT(ta.id) as asignaciones
FROM users u
INNER JOIN teacher_assignments ta ON u.id = ta.teacher_id
INNER JOIN subject_assignments sa ON ta.subject_assignment_id = sa.id
INNER JOIN subjects s ON sa.subject_id = s.id
WHERE u.role IN ('teacher', 'Teacher') 
AND u.status = 'active'
GROUP BY u.id, u.name, u.last_name, u.email
ORDER BY asignaciones DESC
LIMIT 10;
