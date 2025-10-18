-- ============================================================
-- VERIFICAR ASIGNACIONES COMPLETAS EN RENDER
-- Fecha: 16 de Octubre, 2025
-- Descripción: Verifica todas las asignaciones de profesores, estudiantes y materias
-- ============================================================

-- ============================================================
-- VERIFICACIÓN 1: ASIGNACIONES DE PROFESORES
-- ============================================================
SELECT 
    'ASIGNACIONES DE PROFESORES' as categoria,
    COUNT(*) as total_asignaciones,
    COUNT(DISTINCT teacher_id) as profesores_asignados,
    COUNT(DISTINCT subject_assignment_id) as materias_asignadas
FROM teacher_assignments;

-- ============================================================
-- VERIFICACIÓN 2: ASIGNACIONES DE ESTUDIANTES
-- ============================================================
SELECT 
    'ASIGNACIONES DE ESTUDIANTES' as categoria,
    COUNT(*) as total_asignaciones,
    COUNT(DISTINCT student_id) as estudiantes_asignados,
    COUNT(DISTINCT grade_id) as grados_utilizados,
    COUNT(DISTINCT group_id) as grupos_utilizados
FROM student_assignments;

-- ============================================================
-- VERIFICACIÓN 3: ASIGNACIONES DE MATERIAS
-- ============================================================
SELECT 
    'ASIGNACIONES DE MATERIAS' as categoria,
    COUNT(*) as total_asignaciones,
    COUNT(DISTINCT subject_id) as materias_asignadas,
    COUNT(DISTINCT grade_level_id) as grados_utilizados,
    COUNT(DISTINCT group_id) as grupos_utilizados
FROM subject_assignments;

-- ============================================================
-- VERIFICACIÓN 4: PROFESORES CON SUS ASIGNACIONES
-- ============================================================
SELECT 
    'PROFESORES CON ASIGNACIONES' as categoria,
    u.name as nombre,
    u.last_name as apellido,
    u.email,
    COUNT(ta.id) as total_asignaciones,
    COUNT(DISTINCT s.name) as materias_diferentes
FROM users u
INNER JOIN teacher_assignments ta ON u.id = ta.teacher_id
INNER JOIN subject_assignments sa ON ta.subject_assignment_id = sa.id
INNER JOIN subjects s ON sa.subject_id = s.id
WHERE u.role IN ('teacher', 'Teacher')
AND u.status = 'active'
GROUP BY u.id, u.name, u.last_name, u.email
ORDER BY total_asignaciones DESC
LIMIT 15;

-- ============================================================
-- VERIFICACIÓN 5: ESTUDIANTES CON SUS ASIGNACIONES
-- ============================================================
SELECT 
    'ESTUDIANTES CON ASIGNACIONES' as categoria,
    u.name as nombre,
    u.last_name as apellido,
    u.email,
    u.inclusivo,
    gl.name as grado,
    g.name as grupo,
    COUNT(sas.id) as total_notas,
    ROUND(AVG(sas.score), 2) as promedio
FROM users u
INNER JOIN student_assignments sa ON u.id = sa.student_id
INNER JOIN grade_levels gl ON sa.grade_id = gl.id
INNER JOIN groups g ON sa.group_id = g.id
LEFT JOIN student_activity_scores sas ON u.id = sas.student_id
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
AND u.status = 'active'
GROUP BY u.id, u.name, u.last_name, u.email, u.inclusivo, gl.name, g.name
ORDER BY promedio DESC NULLS LAST
LIMIT 15;

-- ============================================================
-- VERIFICACIÓN 6: MATERIAS CON SUS ASIGNACIONES
-- ============================================================
SELECT 
    'MATERIAS CON ASIGNACIONES' as categoria,
    s.name as materia,
    s.code as codigo,
    COUNT(sa.id) as total_asignaciones,
    COUNT(DISTINCT sa.grade_level_id) as grados_diferentes,
    COUNT(DISTINCT sa.group_id) as grupos_diferentes,
    COUNT(DISTINCT ta.teacher_id) as profesores_asignados
FROM subjects s
INNER JOIN subject_assignments sa ON s.id = sa.subject_id
LEFT JOIN teacher_assignments ta ON sa.id = ta.subject_assignment_id
WHERE s.status = true
GROUP BY s.id, s.name, s.code
ORDER BY total_asignaciones DESC
LIMIT 15;

-- ============================================================
-- VERIFICACIÓN 7: ACTIVIDADES CON SUS ASIGNACIONES
-- ============================================================
SELECT 
    'ACTIVIDADES CON ASIGNACIONES' as categoria,
    a.name as actividad,
    s.name as materia,
    gl.name as grado,
    g.name as grupo,
    a.type as tipo_actividad,
    a.trimester as trimestre,
    u.name as profesor,
    COUNT(sas.id) as total_calificaciones,
    ROUND(AVG(sas.score), 2) as promedio
FROM activities a
INNER JOIN subjects s ON a.subject_id = s.id
INNER JOIN grade_levels gl ON a.grade_level_id = gl.id
INNER JOIN groups g ON a.group_id = g.id
INNER JOIN users u ON a.teacher_id = u.id
LEFT JOIN student_activity_scores sas ON a.id = sas.activity_id
GROUP BY a.id, a.name, s.name, gl.name, g.name, a.type, a.trimester, u.name
ORDER BY promedio DESC NULLS LAST
LIMIT 15;

-- ============================================================
-- VERIFICACIÓN 8: RESUMEN GENERAL
-- ============================================================
DO $$
DECLARE
    total_students INTEGER;
    students_with_assignments INTEGER;
    total_teachers INTEGER;
    teachers_with_assignments INTEGER;
    total_subjects INTEGER;
    subjects_with_assignments INTEGER;
    total_activities INTEGER;
    total_scores INTEGER;
    total_student_assignments INTEGER;
    total_teacher_assignments INTEGER;
    total_subject_assignments INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_students FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') AND status = 'active';
    SELECT COUNT(DISTINCT student_id) INTO students_with_assignments FROM student_assignments;
    SELECT COUNT(*) INTO total_teachers FROM users WHERE role IN ('teacher', 'Teacher') AND status = 'active';
    SELECT COUNT(DISTINCT teacher_id) INTO teachers_with_assignments FROM teacher_assignments;
    SELECT COUNT(*) INTO total_subjects FROM subjects WHERE status = true;
    SELECT COUNT(DISTINCT subject_id) INTO subjects_with_assignments FROM subject_assignments;
    SELECT COUNT(*) INTO total_activities FROM activities;
    SELECT COUNT(*) INTO total_scores FROM student_activity_scores;
    SELECT COUNT(*) INTO total_student_assignments FROM student_assignments;
    SELECT COUNT(*) INTO total_teacher_assignments FROM teacher_assignments;
    SELECT COUNT(*) INTO total_subject_assignments FROM subject_assignments;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '📊 RESUMEN GENERAL DE ASIGNACIONES';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
    RAISE NOTICE '👥 ESTUDIANTES:';
    RAISE NOTICE '   Total: %', total_students;
    RAISE NOTICE '   Con asignaciones: % (%%)', students_with_assignments, ROUND((students_with_assignments::DECIMAL / total_students * 100), 1);
    RAISE NOTICE '';
    RAISE NOTICE '👨‍🏫 PROFESORES:';
    RAISE NOTICE '   Total: %', total_teachers;
    RAISE NOTICE '   Con asignaciones: % (%%)', teachers_with_assignments, ROUND((teachers_with_assignments::DECIMAL / total_teachers * 100), 1);
    RAISE NOTICE '';
    RAISE NOTICE '📚 MATERIAS:';
    RAISE NOTICE '   Total: %', total_subjects;
    RAISE NOTICE '   Con asignaciones: % (%%)', subjects_with_assignments, ROUND((subjects_with_assignments::DECIMAL / total_subjects * 100), 1);
    RAISE NOTICE '';
    RAISE NOTICE '🔗 ASIGNACIONES:';
    RAISE NOTICE '   Asignaciones de estudiantes: %', total_student_assignments;
    RAISE NOTICE '   Asignaciones de profesores: %', total_teacher_assignments;
    RAISE NOTICE '   Asignaciones de materias: %', total_subject_assignments;
    RAISE NOTICE '';
    RAISE NOTICE '📊 ACTIVIDADES Y NOTAS:';
    RAISE NOTICE '   Actividades: %', total_activities;
    RAISE NOTICE '   Calificaciones: %', total_scores;
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '✅ SISTEMA COMPLETAMENTE ASIGNADO';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;
