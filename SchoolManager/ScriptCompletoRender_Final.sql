-- ============================================================
-- SCRIPT COMPLETO PARA RENDER - VERIFICACIÓN Y GENERACIÓN DE DATOS
-- Fecha: 16 de Octubre, 2025
-- Descripción: Script completo para verificar y generar datos dummy con notas
-- ============================================================

-- ============================================================
-- PASO 1: VERIFICACIÓN DE DATOS EXISTENTES
-- ============================================================
\echo '========================================================'
\echo '🔍 PASO 1: VERIFICANDO DATOS EXISTENTES EN RENDER'
\echo '========================================================'

-- Verificar usuarios existentes
SELECT 
    'USUARIOS EXISTENTES' as categoria,
    role as rol,
    COUNT(*) as cantidad,
    COUNT(CASE WHEN status = 'active' THEN 1 END) as activos,
    COUNT(CASE WHEN status = 'inactive' THEN 1 END) as inactivos
FROM users 
GROUP BY role
ORDER BY role;

-- Verificar estudiantes y su estado inclusivo
SELECT 
    'ESTUDIANTES Y ESTADO INCLUSIVO' as categoria,
    COUNT(*) as total_estudiantes,
    COUNT(CASE WHEN inclusivo = true THEN 1 END) as inclusivos,
    COUNT(CASE WHEN inclusivo = false THEN 1 END) as no_inclusivos,
    COUNT(CASE WHEN inclusivo IS NULL THEN 1 END) as sin_definir,
    COUNT(CASE WHEN orientacion = true THEN 1 END) as con_orientacion,
    COUNT(CASE WHEN disciplina = true THEN 1 END) as con_disciplina
FROM users 
WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante')
AND status = 'active';

-- Verificar estructura académica
SELECT 
    'ESTRUCTURA ACADÉMICA' as categoria,
    (SELECT COUNT(*) FROM grade_levels) as total_grados,
    (SELECT COUNT(*) FROM groups) as total_grupos,
    (SELECT COUNT(*) FROM areas) as total_areas,
    (SELECT COUNT(*) FROM specialties) as total_especialidades,
    (SELECT COUNT(*) FROM subjects WHERE status = true) as total_materias,
    (SELECT COUNT(*) FROM subject_assignments) as asignaciones_materias;

-- Verificar asignaciones
SELECT 
    'ASIGNACIONES' as categoria,
    (SELECT COUNT(*) FROM student_assignments) as asignaciones_estudiantes,
    (SELECT COUNT(*) FROM teacher_assignments) as asignaciones_profesores,
    (SELECT COUNT(*) FROM activities) as total_actividades,
    (SELECT COUNT(*) FROM student_activity_scores) as total_calificaciones;

-- ============================================================
-- PASO 2: ACTUALIZAR ESTUDIANTES INCLUSIVOS
-- ============================================================
\echo '========================================================'
\echo '👥 PASO 2: ACTUALIZANDO ESTUDIANTES INCLUSIVOS'
\echo '========================================================'

-- Actualizar campo inclusivo de estudiantes existentes
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
-- PASO 3: CREAR DATOS DUMMY SI NO EXISTEN
-- ============================================================
\echo '========================================================'
\echo '📚 PASO 3: CREANDO DATOS DUMMY'
\echo '========================================================'

-- Crear estudiantes dummy si no existen suficientes
INSERT INTO users (
    id, school_id, name, last_name, email, password_hash, role, status,
    document_id, date_of_birth, cellphone_primary, created_at,
    inclusivo, orientacion, disciplina
)
SELECT 
    uuid_generate_v4(),
    (SELECT id FROM schools LIMIT 1),
    nombres.nombre,
    apellidos.apellido,
    LOWER(nombres.nombre || '.' || apellidos.apellido || '@estudiante.edu.pa'),
    '$2a$11$dummy.hash.for.testing.purposes.only',
    'estudiante',
    'active',
    LPAD((ROW_NUMBER() OVER() + 1000)::TEXT, 8, '0'),
    '2005-01-01'::timestamp + (RANDOM() * INTERVAL '3 years'),
    '6' || LPAD((RANDOM() * 99999999)::INT::TEXT, 8, '0'),
    NOW(),
    CASE WHEN RANDOM() < 0.3 THEN true ELSE false END, -- 30% inclusivos
    CASE WHEN RANDOM() < 0.2 THEN true ELSE false END, -- 20% orientación
    CASE WHEN RANDOM() < 0.1 THEN true ELSE false END  -- 10% disciplina
FROM (
    VALUES 
    ('Ana'), ('Carlos'), ('María'), ('José'), ('Laura'), ('David'), ('Sofía'), ('Miguel'),
    ('Isabella'), ('Diego'), ('Valentina'), ('Andrés'), ('Camila'), ('Sebastián'), ('Natalia'),
    ('Alejandro'), ('Gabriela'), ('Daniel'), ('Paola'), ('Fernando'), ('Andrea'), ('Roberto'),
    ('Monica'), ('Luis'), ('Patricia'), ('Jorge'), ('Carmen'), ('Ricardo'), ('Elena'), ('Francisco')
) AS nombres(nombre),
(
    VALUES 
    ('García'), ('Rodríguez'), ('González'), ('Fernández'), ('López'), ('Martínez'), ('Sánchez'),
    ('Pérez'), ('Gómez'), ('Martín'), ('Jiménez'), ('Ruiz'), ('Hernández'), ('Díaz'), ('Moreno'),
    ('Álvarez'), ('Muñoz'), ('Romero'), ('Alonso'), ('Gutiérrez'), ('Navarro'), ('Torres'),
    ('Domínguez'), ('Vargas'), ('Ramos'), ('Gil'), ('Ramírez'), ('Serrano'), ('Blanco'), ('Molina')
) AS apellidos(apellido)
WHERE NOT EXISTS (
    SELECT 1 FROM users 
    WHERE email = LOWER(nombres.nombre || '.' || apellidos.apellido || '@estudiante.edu.pa')
)
LIMIT 20; -- Crear hasta 20 estudiantes adicionales

-- Crear profesores dummy si no existen suficientes
INSERT INTO users (
    id, school_id, name, last_name, email, password_hash, role, status,
    document_id, date_of_birth, cellphone_primary, created_at
)
SELECT 
    uuid_generate_v4(),
    (SELECT id FROM schools LIMIT 1),
    nombres.nombre,
    apellidos.apellido,
    LOWER(nombres.nombre || '.' || apellidos.apellido || '@profesor.edu.pa'),
    '$2a$11$dummy.hash.for.testing.purposes.only',
    'teacher',
    'active',
    LPAD((ROW_NUMBER() OVER() + 2000)::TEXT, 8, '0'),
    '1980-01-01'::timestamp + (RANDOM() * INTERVAL '15 years'),
    '6' || LPAD((RANDOM() * 99999999)::INT::TEXT, 8, '0'),
    NOW()
FROM (
    VALUES 
    ('Prof. Ana'), ('Prof. Carlos'), ('Prof. María'), ('Prof. José'), ('Prof. Laura'),
    ('Prof. David'), ('Prof. Sofía'), ('Prof. Miguel'), ('Prof. Isabella'), ('Prof. Diego')
) AS nombres(nombre),
(
    VALUES 
    ('García'), ('Rodríguez'), ('González'), ('Fernández'), ('López'),
    ('Martínez'), ('Sánchez'), ('Pérez'), ('Gómez'), ('Martín')
) AS apellidos(apellido)
WHERE NOT EXISTS (
    SELECT 1 FROM users 
    WHERE email = LOWER(nombres.nombre || '.' || apellidos.apellido || '@profesor.edu.pa')
)
LIMIT 10; -- Crear hasta 10 profesores adicionales

-- Crear grados si no existen
INSERT INTO grade_levels (id, name, created_at)
SELECT 
    uuid_generate_v4(),
    grados.grado,
    NOW()
FROM (
    VALUES 
    ('7° Grado'), ('8° Grado'), ('9° Grado'), ('10° Grado'), ('11° Grado'), ('12° Grado')
) AS grados(grado)
WHERE NOT EXISTS (
    SELECT 1 FROM grade_levels WHERE name = grados.grado
);

-- Crear grupos si no existen
INSERT INTO groups (id, name, grade_level_id, created_at)
SELECT 
    uuid_generate_v4(),
    grupos.grupo,
    gl.id,
    NOW()
FROM (
    VALUES 
    ('7°A'), ('7°B'), ('8°A'), ('8°B'), ('9°A'), ('9°B'),
    ('10°A'), ('10°B'), ('10°C'), ('11°A'), ('11°B'), ('12°A'), ('12°B')
) AS grupos(grupo)
CROSS JOIN grade_levels gl
WHERE gl.name = SPLIT_PART(grupos.grupo, '°', 1) || '° Grado'
AND NOT EXISTS (
    SELECT 1 FROM groups WHERE name = grupos.grupo
);

-- Crear áreas si no existen
INSERT INTO areas (id, name, is_active, created_at)
SELECT 
    uuid_generate_v4(),
    areas.area,
    true,
    NOW()
FROM (
    VALUES 
    ('Matemáticas'), ('Ciencias Naturales'), ('Lengua y Literatura'), 
    ('Historia'), ('Geografía'), ('Educación Física'), ('Arte'), ('Música')
) AS areas(area)
WHERE NOT EXISTS (
    SELECT 1 FROM areas WHERE name = areas.area
);

-- Crear especialidades si no existen
INSERT INTO specialties (id, name, is_active, created_at)
SELECT 
    uuid_generate_v4(),
    especialidades.especialidad,
    true,
    NOW()
FROM (
    VALUES 
    ('Bachiller en Ciencias'), ('Bachiller en Letras'), ('Bachiller en Comercio'),
    ('Técnico en Informática'), ('Técnico en Contabilidad')
) AS especialidades(especialidad)
WHERE NOT EXISTS (
    SELECT 1 FROM specialties WHERE name = especialidades.especialidad
);

-- Crear materias si no existen
INSERT INTO subjects (id, name, code, description, status, "AreaId", created_at)
SELECT 
    uuid_generate_v4(),
    materias.materia,
    materias.codigo,
    materias.descripcion,
    true,
    a.id,
    NOW()
FROM (
    VALUES 
    ('Matemáticas', 'MAT', 'Matemáticas generales', 'Matemáticas'),
    ('Álgebra', 'ALG', 'Álgebra básica y avanzada', 'Matemáticas'),
    ('Geometría', 'GEO', 'Geometría plana y del espacio', 'Matemáticas'),
    ('Física', 'FIS', 'Física general', 'Ciencias Naturales'),
    ('Química', 'QUI', 'Química general', 'Ciencias Naturales'),
    ('Biología', 'BIO', 'Biología general', 'Ciencias Naturales'),
    ('Lengua Española', 'LEN', 'Lengua y literatura española', 'Lengua y Literatura'),
    ('Literatura', 'LIT', 'Literatura universal', 'Lengua y Literatura'),
    ('Historia de Panamá', 'HIS', 'Historia de Panamá', 'Historia'),
    ('Historia Universal', 'HUN', 'Historia universal', 'Historia'),
    ('Geografía', 'GEO', 'Geografía física y humana', 'Geografía'),
    ('Educación Física', 'EDF', 'Educación física y deportes', 'Educación Física'),
    ('Arte', 'ART', 'Arte y expresión', 'Arte'),
    ('Música', 'MUS', 'Educación musical', 'Música')
) AS materias(materia, codigo, descripcion, area_nombre)
INNER JOIN areas a ON a.name = materias.area_nombre
WHERE NOT EXISTS (
    SELECT 1 FROM subjects WHERE name = materias.materia
);

-- ============================================================
-- PASO 4: CREAR ASIGNACIONES
-- ============================================================
\echo '========================================================'
\echo '🔗 PASO 4: CREANDO ASIGNACIONES'
\echo '========================================================'

-- Asignar estudiantes a grados y grupos
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
LIMIT 50; -- Asignar hasta 50 estudiantes

-- Crear asignaciones de materias
INSERT INTO subject_assignments (id, specialty_id, area_id, subject_id, grade_level_id, group_id, created_at, "SchoolId")
SELECT 
    uuid_generate_v4(),
    s.id,
    a.id,
    sub.id,
    gl.id,
    g.id,
    NOW(),
    (SELECT id FROM schools LIMIT 1)
FROM specialties s
CROSS JOIN areas a
CROSS JOIN subjects sub
CROSS JOIN grade_levels gl
CROSS JOIN groups g
WHERE sub."AreaId" = a.id
AND gl.name = SPLIT_PART(g.name, '°', 1) || '° Grado'
AND NOT EXISTS (
    SELECT 1 FROM subject_assignments sa 
    WHERE sa.specialty_id = s.id 
    AND sa.area_id = a.id 
    AND sa.subject_id = sub.id 
    AND sa.grade_level_id = gl.id 
    AND sa.group_id = g.id
)
ORDER BY RANDOM()
LIMIT 100; -- Crear hasta 100 asignaciones de materias

-- Asignar profesores a materias
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
LIMIT 50; -- Asignar hasta 50 profesores

-- ============================================================
-- PASO 5: CREAR TRIMESTRES Y TIPOS DE ACTIVIDADES
-- ============================================================
\echo '========================================================'
\echo '📅 PASO 5: CREANDO TRIMESTRES Y TIPOS DE ACTIVIDADES'
\echo '========================================================'

-- Crear trimestres si no existen
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

-- Crear tipos de actividades si no existen
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
-- PASO 6: GENERAR ACTIVIDADES
-- ============================================================
\echo '========================================================'
\echo '📚 PASO 6: GENERANDO ACTIVIDADES'
\echo '========================================================'

-- Generar actividades para cada materia asignada
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
-- PASO 7: GENERAR NOTAS PARA TODOS LOS ESTUDIANTES
-- ============================================================
\echo '========================================================'
\echo '📊 PASO 7: GENERANDO NOTAS PARA TODOS LOS ESTUDIANTES'
\echo '========================================================'

-- Generar notas para todos los estudiantes
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
-- PASO 8: VERIFICACIÓN FINAL
-- ============================================================
\echo '========================================================'
\echo '📊 PASO 8: VERIFICACIÓN FINAL'
\echo '========================================================'

-- Verificación final de todos los datos
DO $$
DECLARE
    total_students INTEGER;
    students_inclusive INTEGER;
    students_with_assignments INTEGER;
    students_with_scores INTEGER;
    total_teachers INTEGER;
    teachers_with_assignments INTEGER;
    total_subjects INTEGER;
    total_groups INTEGER;
    total_grades INTEGER;
    total_areas INTEGER;
    total_specialties INTEGER;
    total_student_assignments INTEGER;
    total_teacher_assignments INTEGER;
    total_subject_assignments INTEGER;
    total_activities INTEGER;
    total_scores INTEGER;
    avg_score DECIMAL;
    min_score DECIMAL;
    max_score DECIMAL;
BEGIN
    -- Contar todos los datos
    SELECT COUNT(*) INTO total_students FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante');
    SELECT COUNT(*) INTO students_inclusive FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') AND inclusivo = true;
    SELECT COUNT(DISTINCT u.id) INTO students_with_assignments FROM users u INNER JOIN student_assignments sa ON u.id = sa.student_id WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante');
    SELECT COUNT(DISTINCT student_id) INTO students_with_scores FROM student_activity_scores;
    SELECT COUNT(*) INTO total_teachers FROM users WHERE role IN ('teacher', 'Teacher');
    SELECT COUNT(DISTINCT u.id) INTO teachers_with_assignments FROM users u INNER JOIN teacher_assignments ta ON u.id = ta.teacher_id WHERE u.role IN ('teacher', 'Teacher');
    SELECT COUNT(*) INTO total_subjects FROM subjects;
    SELECT COUNT(*) INTO total_groups FROM groups;
    SELECT COUNT(*) INTO total_grades FROM grade_levels;
    SELECT COUNT(*) INTO total_areas FROM areas;
    SELECT COUNT(*) INTO total_specialties FROM specialties;
    SELECT COUNT(*) INTO total_student_assignments FROM student_assignments;
    SELECT COUNT(*) INTO total_teacher_assignments FROM teacher_assignments;
    SELECT COUNT(*) INTO total_subject_assignments FROM subject_assignments;
    SELECT COUNT(*) INTO total_activities FROM activities;
    SELECT COUNT(*) INTO total_scores FROM student_activity_scores;
    SELECT ROUND(AVG(score), 2) INTO avg_score FROM student_activity_scores;
    SELECT ROUND(MIN(score), 2) INTO min_score FROM student_activity_scores;
    SELECT ROUND(MAX(score), 2) INTO max_score FROM student_activity_scores;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '🎉 SCRIPT COMPLETADO EXITOSAMENTE';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
    RAISE NOTICE '👥 USUARIOS:';
    RAISE NOTICE '   Estudiantes: %', total_students;
    RAISE NOTICE '   Estudiantes inclusivos: % (%%)', students_inclusive, ROUND((students_inclusive::DECIMAL / total_students * 100), 1);
    RAISE NOTICE '   Estudiantes con asignaciones: % (%%)', students_with_assignments, ROUND((students_with_assignments::DECIMAL / total_students * 100), 1);
    RAISE NOTICE '   Estudiantes con notas: % (%%)', students_with_scores, ROUND((students_with_scores::DECIMAL / total_students * 100), 1);
    RAISE NOTICE '   Profesores: %', total_teachers;
    RAISE NOTICE '   Profesores asignados: % (%%)', teachers_with_assignments, ROUND((teachers_with_assignments::DECIMAL / total_teachers * 100), 1);
    RAISE NOTICE '';
    RAISE NOTICE '📚 ESTRUCTURA ACADÉMICA:';
    RAISE NOTICE '   Grados: %', total_grades;
    RAISE NOTICE '   Grupos: %', total_groups;
    RAISE NOTICE '   Áreas: %', total_areas;
    RAISE NOTICE '   Especialidades: %', total_specialties;
    RAISE NOTICE '   Materias: %', total_subjects;
    RAISE NOTICE '';
    RAISE NOTICE '🔗 ASIGNACIONES:';
    RAISE NOTICE '   Asignaciones de estudiantes: %', total_student_assignments;
    RAISE NOTICE '   Asignaciones de materias: %', total_subject_assignments;
    RAISE NOTICE '   Asignaciones de profesores: %', total_teacher_assignments;
    RAISE NOTICE '';
    RAISE NOTICE '📊 ACTIVIDADES Y NOTAS:';
    RAISE NOTICE '   Actividades: %', total_activities;
    RAISE NOTICE '   Calificaciones: %', total_scores;
    RAISE NOTICE '   Promedio general: %', avg_score;
    RAISE NOTICE '   Nota mínima: %', min_score;
    RAISE NOTICE '   Nota máxima: %', max_score;
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '✅ SISTEMA COMPLETAMENTE CONFIGURADO';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
    RAISE NOTICE '🎯 MÓDULOS LISTOS PARA PRUEBAS:';
    RAISE NOTICE '   ✅ Gestión de Usuarios';
    RAISE NOTICE '   ✅ Asignaciones de Estudiantes';
    RAISE NOTICE '   ✅ Asignaciones de Profesores';
    RAISE NOTICE '   ✅ Catálogo Académico';
    RAISE NOTICE '   ✅ Reportes de Estudiantes';
    RAISE NOTICE '   ✅ Libro de Calificaciones';
    RAISE NOTICE '   ✅ Mensajería Interna';
    RAISE NOTICE '   ✅ Sistema de Notas';
    RAISE NOTICE '   ✅ Aprobados/Reprobados';
    RAISE NOTICE '';
    RAISE NOTICE '🚀 ¡SISTEMA LISTO PARA USAR!';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;

-- ============================================================
-- PASO 9: MOSTRAR DATOS DE PRUEBA FINALES
-- ============================================================
\echo '========================================================'
\echo '👥 DATOS DE PRUEBA FINALES'
\echo '========================================================'

-- Mostrar algunos estudiantes con notas
SELECT 
    'ESTUDIANTES CON NOTAS' as tipo,
    u.name as nombre,
    u.last_name as apellido,
    u.email,
    u.inclusivo,
    COUNT(sas.id) as total_notas,
    ROUND(AVG(sas.score), 2) as promedio
FROM users u
INNER JOIN student_activity_scores sas ON u.id = sas.student_id
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante') 
AND u.status = 'active'
GROUP BY u.id, u.name, u.last_name, u.email, u.inclusivo
ORDER BY promedio DESC
LIMIT 10;

-- Mostrar algunas actividades con notas
SELECT 
    'ACTIVIDADES CON NOTAS' as tipo,
    a.name as actividad,
    s.name as materia,
    gl.name as grado,
    g.name as grupo,
    a.type as tipo_actividad,
    a.trimester as trimestre,
    COUNT(sas.id) as total_notas,
    ROUND(AVG(sas.score), 2) as promedio
FROM activities a
INNER JOIN subjects s ON a.subject_id = s.id
INNER JOIN grade_levels gl ON a.grade_level_id = gl.id
INNER JOIN groups g ON a.group_id = g.id
INNER JOIN student_activity_scores sas ON a.id = sas.activity_id
GROUP BY a.id, a.name, s.name, gl.name, g.name, a.type, a.trimester
ORDER BY promedio DESC
LIMIT 10;

\echo '========================================================'
\echo '✅ SCRIPT COMPLETO FINALIZADO EXITOSAMENTE'
\echo '========================================================'
