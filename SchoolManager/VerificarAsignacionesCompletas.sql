-- ============================================================
-- VERIFICAR ASIGNACIONES COMPLETAS EN RENDER
-- ============================================================

-- ========== PROFESORES ==========
SELECT 
    '========== PROFESORES ==========' as separador;

-- Total de profesores
SELECT 
    'TOTAL PROFESORES' as categoria,
    COUNT(*) as cantidad
FROM users 
WHERE role IN ('teacher', 'Teacher', 'docente', 'Docente') 
AND status = 'active';

-- Profesores con asignaciones
SELECT 
    'PROFESORES CON ASIGNACIONES' as categoria,
    COUNT(DISTINCT ta.teacher_id) as cantidad
FROM teacher_assignments ta;

-- Profesores SIN asignaciones
SELECT 
    'PROFESORES SIN ASIGNACIONES' as categoria,
    COUNT(*) as cantidad,
    STRING_AGG(u.name || ' ' || u.last_name, ', ') as profesores
FROM users u
WHERE role IN ('teacher', 'Teacher', 'docente', 'Docente') 
AND status = 'active'
AND NOT EXISTS (
    SELECT 1 FROM teacher_assignments ta WHERE ta.teacher_id = u.id
);

-- ========== GRUPOS ==========
SELECT 
    '========== GRUPOS ==========' as separador;

-- Total de grupos
SELECT 
    'TOTAL GRUPOS' as categoria,
    COUNT(*) as cantidad
FROM groups;

-- Grupos con asignaciones de materias
SELECT 
    'GRUPOS CON ASIGNACIONES DE MATERIAS' as categoria,
    COUNT(DISTINCT sa.group_id) as cantidad
FROM subject_assignments sa;

-- Grupos SIN asignaciones de materias
SELECT 
    'GRUPOS SIN ASIGNACIONES DE MATERIAS' as categoria,
    COUNT(*) as cantidad
FROM groups g
WHERE NOT EXISTS (
    SELECT 1 FROM subject_assignments sa WHERE sa.group_id = g.id
);

-- ========== MATERIAS ==========
SELECT 
    '========== MATERIAS ==========' as separador;

-- Total de materias activas
SELECT 
    'TOTAL MATERIAS ACTIVAS' as categoria,
    COUNT(*) as cantidad
FROM subjects
WHERE status = true;

-- Materias con asignaciones
SELECT 
    'MATERIAS CON ASIGNACIONES' as categoria,
    COUNT(DISTINCT sa.subject_id) as cantidad
FROM subject_assignments sa;

-- ========== ESTUDIANTES ==========
SELECT 
    '========== ESTUDIANTES ==========' as separador;

-- Total de estudiantes
SELECT 
    'TOTAL ESTUDIANTES' as categoria,
    COUNT(*) as cantidad
FROM users 
WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
AND status = 'active';

-- Estudiantes con asignaciones de grupo
SELECT 
    'ESTUDIANTES CON GRUPO ASIGNADO' as categoria,
    COUNT(DISTINCT sa.student_id) as cantidad
FROM student_assignments sa;

-- Estudiantes SIN grupo
SELECT 
    'ESTUDIANTES SIN GRUPO' as categoria,
    COUNT(*) as cantidad
FROM users u
WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
AND status = 'active'
AND NOT EXISTS (
    SELECT 1 FROM student_assignments sa WHERE sa.student_id = u.id
);

-- ========== ASIGNACIONES DETALLADAS ==========
SELECT 
    '========== RESUMEN DETALLADO ==========' as separador;

-- Detalle de asignaciones por grupo
SELECT 
    'ASIGNACIONES POR GRUPO' as tipo,
    g.grade as grado,
    g.name as grupo,
    COUNT(DISTINCT sa.subject_id) as materias_asignadas,
    COUNT(DISTINCT ta.teacher_id) as profesores_asignados,
    (SELECT COUNT(*) FROM student_assignments st WHERE st.group_id = g.id) as estudiantes_asignados
FROM groups g
LEFT JOIN subject_assignments sa ON g.id = sa.group_id
LEFT JOIN teacher_assignments ta ON sa.id = ta.subject_assignment_id
GROUP BY g.id, g.grade, g.name
ORDER BY g.grade, g.name
LIMIT 20;

-- Profesores y sus asignaciones
SELECT 
    'PROFESORES Y SUS ASIGNACIONES' as tipo,
    u.name || ' ' || u.last_name as profesor,
    u.email,
    COUNT(DISTINCT ta.subject_assignment_id) as asignaciones,
    STRING_AGG(DISTINCT s.name, ', ') as materias
FROM users u
LEFT JOIN teacher_assignments ta ON u.id = ta.teacher_id
LEFT JOIN subject_assignments sa ON ta.subject_assignment_id = sa.id
LEFT JOIN subjects s ON sa.subject_id = s.id
WHERE u.role IN ('teacher', 'Teacher', 'docente', 'Docente')
AND u.status = 'active'
GROUP BY u.id, u.name, u.last_name, u.email
ORDER BY u.name
LIMIT 20;

-- Resumen final
DO $$
DECLARE
    v_total_profesores INTEGER;
    v_profesores_asignados INTEGER;
    v_total_grupos INTEGER;
    v_grupos_con_materias INTEGER;
    v_total_estudiantes INTEGER;
    v_estudiantes_con_grupo INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_total_profesores FROM users WHERE role IN ('teacher', 'Teacher', 'docente', 'Docente') AND status = 'active';
    SELECT COUNT(DISTINCT teacher_id) INTO v_profesores_asignados FROM teacher_assignments;
    SELECT COUNT(*) INTO v_total_grupos FROM groups;
    SELECT COUNT(DISTINCT group_id) INTO v_grupos_con_materias FROM subject_assignments;
    SELECT COUNT(*) INTO v_total_estudiantes FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') AND status = 'active';
    SELECT COUNT(DISTINCT student_id) INTO v_estudiantes_con_grupo FROM student_assignments;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'RESUMEN DE ASIGNACIONES';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'PROFESORES:';
    RAISE NOTICE '  Total: %', v_total_profesores;
    RAISE NOTICE '  Con asignaciones: %', v_profesores_asignados;
    RAISE NOTICE '  Cobertura: %%', ROUND((v_profesores_asignados::DECIMAL / v_total_profesores * 100), 2);
    RAISE NOTICE '';
    RAISE NOTICE 'GRUPOS:';
    RAISE NOTICE '  Total: %', v_total_grupos;
    RAISE NOTICE '  Con materias: %', v_grupos_con_materias;
    RAISE NOTICE '  Cobertura: %%', ROUND((v_grupos_con_materias::DECIMAL / v_total_grupos * 100), 2);
    RAISE NOTICE '';
    RAISE NOTICE 'ESTUDIANTES:';
    RAISE NOTICE '  Total: %', v_total_estudiantes;
    RAISE NOTICE '  Con grupo: %', v_estudiantes_con_grupo;
    RAISE NOTICE '  Cobertura: %%', ROUND((v_estudiantes_con_grupo::DECIMAL / v_total_estudiantes * 100), 2);
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;