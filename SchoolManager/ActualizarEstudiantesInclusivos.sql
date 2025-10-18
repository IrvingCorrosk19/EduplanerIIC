-- ============================================================
-- ACTUALIZAR ESTUDIANTES INCLUSIVOS EN RENDER
-- Fecha: 16 de Octubre, 2025
-- Descripción: Actualiza el campo inclusivo de estudiantes existentes
-- ============================================================

-- ============================================================
-- PASO 1: Actualizar campo inclusivo de estudiantes existentes
-- ============================================================
UPDATE users 
SET 
    inclusivo = CASE 
        WHEN RANDOM() < 0.3 THEN true  -- 30% inclusivos
        ELSE false 
    END,
    orientacion = CASE 
        WHEN RANDOM() < 0.2 THEN true  -- 20% orientación
        ELSE false 
    END,
    disciplina = CASE 
        WHEN RANDOM() < 0.1 THEN true  -- 10% disciplina
        ELSE false 
    END,
    updated_at = NOW()
WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
AND status = 'active'
AND (inclusivo IS NULL OR orientacion IS NULL OR disciplina IS NULL);

-- ============================================================
-- PASO 2: Verificar actualizaciones
-- ============================================================
DO $$
DECLARE
    total_students INTEGER;
    students_inclusive INTEGER;
    students_orientation INTEGER;
    students_discipline INTEGER;
    students_updated INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_students 
    FROM users 
    WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
    AND status = 'active';
    
    SELECT COUNT(*) INTO students_inclusive 
    FROM users 
    WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
    AND status = 'active' 
    AND inclusivo = true;
    
    SELECT COUNT(*) INTO students_orientation 
    FROM users 
    WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
    AND status = 'active' 
    AND orientacion = true;
    
    SELECT COUNT(*) INTO students_discipline 
    FROM users 
    WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
    AND status = 'active' 
    AND disciplina = true;
    
    SELECT COUNT(*) INTO students_updated
    FROM users 
    WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') 
    AND status = 'active' 
    AND updated_at > NOW() - INTERVAL '1 minute';
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '✅ ESTUDIANTES INCLUSIVOS ACTUALIZADOS';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
    RAISE NOTICE '👥 ESTADÍSTICAS:';
    RAISE NOTICE '   Total de estudiantes: %', total_students;
    RAISE NOTICE '   Estudiantes inclusivos: % (%%)', students_inclusive, ROUND((students_inclusive::DECIMAL / total_students * 100), 1);
    RAISE NOTICE '   Estudiantes con orientación: % (%%)', students_orientation, ROUND((students_orientation::DECIMAL / total_students * 100), 1);
    RAISE NOTICE '   Estudiantes con disciplina: % (%%)', students_discipline, ROUND((students_discipline::DECIMAL / total_students * 100), 1);
    RAISE NOTICE '   Estudiantes actualizados: %', students_updated;
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;

-- ============================================================
-- PASO 3: Mostrar estudiantes inclusivos
-- ============================================================
SELECT 
    'ESTUDIANTES INCLUSIVOS' as categoria,
    u.name as nombre,
    u.last_name as apellido,
    u.email,
    u.inclusivo,
    u.orientacion,
    u.disciplina,
    u.updated_at as actualizado
FROM users u
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante') 
AND u.status = 'active'
AND u.inclusivo = true
ORDER BY u.name
LIMIT 10;
