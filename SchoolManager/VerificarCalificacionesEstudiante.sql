-- ============================================================
-- VERIFICAR CALIFICACIONES DE UN ESTUDIANTE ESPECÍFICO
-- ============================================================

-- Ver un estudiante específico (Alejandro Moreno)
SELECT 
    'DATOS DEL ESTUDIANTE' as categoria,
    u.id,
    u.name,
    u.last_name,
    u.email,
    u.document_id,
    u.role
FROM users u
WHERE u.email = 'alejandro.moreno@estudiante.edu.pa';

-- Ver si tiene asignación de grupo
SELECT 
    'ASIGNACIÓN DE GRUPO' as categoria,
    sa.student_id,
    g.grade as grado,
    g.name as grupo,
    gl.name as nivel_grado
FROM student_assignments sa
INNER JOIN groups g ON sa.group_id = g.id
INNER JOIN grade_levels gl ON sa.grade_id = gl.id
INNER JOIN users u ON sa.student_id = u.id
WHERE u.email = 'alejandro.moreno@estudiante.edu.pa';

-- Ver actividades disponibles para su grupo
SELECT 
    'ACTIVIDADES DISPONIBLES' as categoria,
    a.id,
    a.name,
    a.type,
    a.trimester,
    s.name as materia,
    g.grade || ' ' || g.name as grupo
FROM activities a
INNER JOIN subjects s ON a.subject_id = s.id
INNER JOIN groups g ON a.group_id = g.id
INNER JOIN grade_levels gl ON a.grade_level_id = gl.id
WHERE EXISTS (
    SELECT 1 FROM student_assignments sa
    INNER JOIN users u ON sa.student_id = u.id
    WHERE u.email = 'alejandro.moreno@estudiante.edu.pa'
      AND sa.group_id = a.group_id
      AND sa.grade_id = a.grade_level_id
)
ORDER BY a.type, s.name
LIMIT 20;

-- Ver calificaciones del estudiante
SELECT 
    'CALIFICACIONES DEL ESTUDIANTE' as categoria,
    a.type,
    s.name as materia,
    a.name as actividad,
    sas.score as nota,
    a.trimester
FROM student_activity_scores sas
INNER JOIN activities a ON sas.activity_id = a.id
INNER JOIN subjects s ON a.subject_id = s.id
INNER JOIN users u ON sas.student_id = u.id
WHERE u.email = 'alejandro.moreno@estudiante.edu.pa'
ORDER BY s.name, a.type
LIMIT 30;

-- Contar calificaciones por tipo
SELECT 
    'CALIFICACIONES POR TIPO' as categoria,
    a.type,
    COUNT(*) as cantidad,
    ROUND(AVG(sas.score), 2) as promedio
FROM student_activity_scores sas
INNER JOIN activities a ON sas.activity_id = a.id
INNER JOIN users u ON sas.student_id = u.id
WHERE u.email = 'alejandro.moreno@estudiante.edu.pa'
GROUP BY a.type
ORDER BY cantidad DESC;

-- Ver todas las calificaciones agrupadas por materia y tipo
SELECT 
    'AGRUPACIÓN POR MATERIA Y TIPO' as categoria,
    s.name as materia,
    a.type,
    COUNT(sas.id) as cantidad_notas,
    ROUND(AVG(sas.score), 2) as promedio_tipo
FROM student_activity_scores sas
INNER JOIN activities a ON sas.activity_id = a.id
INNER JOIN subjects s ON a.subject_id = s.id
INNER JOIN users u ON sas.student_id = u.id
WHERE u.email = 'alejandro.moreno@estudiante.edu.pa'
GROUP BY s.name, a.type
ORDER BY s.name, a.type;

-- Resumen del estudiante
DO $$
DECLARE
    v_student_name TEXT;
    v_total_notas INTEGER;
    v_promedio DECIMAL;
    v_tiene_notas_apreciacion INTEGER;
    v_tiene_ejercicios INTEGER;
    v_tiene_examenes INTEGER;
BEGIN
    SELECT name || ' ' || last_name INTO v_student_name FROM users WHERE email = 'alejandro.moreno@estudiante.edu.pa';
    
    SELECT COUNT(*), ROUND(AVG(sas.score), 2)
    INTO v_total_notas, v_promedio
    FROM student_activity_scores sas
    INNER JOIN users u ON sas.student_id = u.id
    WHERE u.email = 'alejandro.moreno@estudiante.edu.pa';
    
    SELECT COUNT(DISTINCT sas.id) INTO v_tiene_notas_apreciacion
    FROM student_activity_scores sas
    INNER JOIN activities a ON sas.activity_id = a.id
    INNER JOIN users u ON sas.student_id = u.id
    WHERE u.email = 'alejandro.moreno@estudiante.edu.pa'
      AND (LOWER(a.type) LIKE '%nota%' OR LOWER(a.type) LIKE '%apreciaci%');
    
    SELECT COUNT(DISTINCT sas.id) INTO v_tiene_ejercicios
    FROM student_activity_scores sas
    INNER JOIN activities a ON sas.activity_id = a.id
    INNER JOIN users u ON sas.student_id = u.id
    WHERE u.email = 'alejandro.moreno@estudiante.edu.pa'
      AND (LOWER(a.type) LIKE '%ejercicio%' OR LOWER(a.type) LIKE '%diario%');
    
    SELECT COUNT(DISTINCT sas.id) INTO v_tiene_examenes
    FROM student_activity_scores sas
    INNER JOIN activities a ON sas.activity_id = a.id
    INNER JOIN users u ON sas.student_id = u.id
    WHERE u.email = 'alejandro.moreno@estudiante.edu.pa'
      AND (LOWER(a.type) LIKE '%examen%' OR LOWER(a.type) LIKE '%final%');
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'RESUMEN DEL ESTUDIANTE: %', v_student_name;
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'Total de calificaciones: %', v_total_notas;
    RAISE NOTICE 'Promedio general: %', v_promedio;
    RAISE NOTICE '';
    RAISE NOTICE 'NOTAS POR TIPO:';
    RAISE NOTICE '  Notas de apreciacion: %', v_tiene_notas_apreciacion;
    RAISE NOTICE '  Ejercicios diarios: %', v_tiene_ejercicios;
    RAISE NOTICE '  Examenes finales: %', v_tiene_examenes;
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;
