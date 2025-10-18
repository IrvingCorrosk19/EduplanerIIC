-- ============================================================
-- ASIGNAR LOS 20 ESTUDIANTES FALTANTES A GRUPOS
-- ============================================================

-- Ver quiénes son los estudiantes sin grupo
SELECT 
    'ESTUDIANTES SIN GRUPO (ANTES)' as categoria,
    u.name,
    u.last_name,
    u.email,
    u.document_id
FROM users u
WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
AND status = 'active'
AND NOT EXISTS (
    SELECT 1 FROM student_assignments sa WHERE sa.student_id = u.id
)
ORDER BY u.name;

-- Asignar estudiantes faltantes a grupos distribuidos
WITH estudiantes_sin_grupo AS (
    SELECT 
        u.id as student_id,
        ROW_NUMBER() OVER (ORDER BY u.id) as rn
    FROM users u
    WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
    AND status = 'active'
    AND NOT EXISTS (
        SELECT 1 FROM student_assignments sa WHERE sa.student_id = u.id
    )
),
grupos_con_grados AS (
    SELECT 
        g.id as group_id,
        gl.id as grade_id,
        ROW_NUMBER() OVER (ORDER BY g.id) as rn
    FROM groups g
    CROSS JOIN grade_levels gl
    LIMIT 100
)
INSERT INTO student_assignments (id, student_id, group_id, grade_id, created_at)
SELECT 
    gen_random_uuid(),
    e.student_id,
    gg.group_id,
    gg.grade_id,
    NOW()
FROM estudiantes_sin_grupo e
INNER JOIN grupos_con_grados gg ON MOD(e.rn - 1, 25) + 1 = gg.rn;

-- Verificar resultado
SELECT 
    'ESTUDIANTES SIN GRUPO (DESPUÉS)' as categoria,
    COUNT(*) as cantidad
FROM users u
WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
AND status = 'active'
AND NOT EXISTS (
    SELECT 1 FROM student_assignments sa WHERE sa.student_id = u.id
);

-- Ver asignaciones de los estudiantes recién asignados
SELECT 
    'ESTUDIANTES RECIÉN ASIGNADOS' as categoria,
    u.name || ' ' || u.last_name as estudiante,
    g.grade as grado,
    g.name as grupo,
    gl.name as nivel_grado
FROM users u
INNER JOIN student_assignments sa ON u.id = sa.student_id
INNER JOIN groups g ON sa.group_id = g.id
INNER JOIN grade_levels gl ON sa.grade_id = gl.id
WHERE u.document_id IN (
    '00001017', '00001008', '00001009', '00001010', '00001011',
    '00001012', '00001014', '00001015', '00001018', '00001019'
)
ORDER BY u.name;

-- Resumen final
DO $$
DECLARE
    v_total_estudiantes INTEGER;
    v_estudiantes_con_grupo INTEGER;
    v_sin_grupo INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_total_estudiantes 
    FROM users 
    WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') AND status = 'active';
    
    SELECT COUNT(DISTINCT student_id) INTO v_estudiantes_con_grupo 
    FROM student_assignments;
    
    SELECT COUNT(*) INTO v_sin_grupo
    FROM users u
    WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
    AND status = 'active'
    AND NOT EXISTS (SELECT 1 FROM student_assignments sa WHERE sa.student_id = u.id);
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'ASIGNACION DE ESTUDIANTES A GRUPOS';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'Total de estudiantes: %', v_total_estudiantes;
    RAISE NOTICE 'Estudiantes con grupo: %', v_estudiantes_con_grupo;
    RAISE NOTICE 'Estudiantes sin grupo: %', v_sin_grupo;
    RAISE NOTICE 'Cobertura: %%', ROUND((v_estudiantes_con_grupo::DECIMAL / v_total_estudiantes * 100), 2);
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;
