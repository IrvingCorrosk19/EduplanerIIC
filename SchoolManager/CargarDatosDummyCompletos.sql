-- ============================================================
-- CARGA DE DATOS DUMMY COMPLETOS PARA RENDER
-- Fecha: 16 de Octubre, 2025
-- Descripción: Carga estudiantes, profesores y asignaciones completas
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
    total_areas INTEGER;
    total_specialties INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_students FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante');
    SELECT COUNT(*) INTO total_teachers FROM users WHERE role IN ('teacher', 'Teacher');
    SELECT COUNT(*) INTO total_subjects FROM subjects;
    SELECT COUNT(*) INTO total_groups FROM groups;
    SELECT COUNT(*) INTO total_grades FROM grade_levels;
    SELECT COUNT(*) INTO total_areas FROM areas;
    SELECT COUNT(*) INTO total_specialties FROM specialties;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '📊 ESTADO ACTUAL DE LA BASE DE DATOS:';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'Estudiantes: %', total_students;
    RAISE NOTICE 'Profesores: %', total_teachers;
    RAISE NOTICE 'Materias: %', total_subjects;
    RAISE NOTICE 'Grupos: %', total_groups;
    RAISE NOTICE 'Grados: %', total_grades;
    RAISE NOTICE 'Áreas: %', total_areas;
    RAISE NOTICE 'Especialidades: %', total_specialties;
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;

-- ============================================================
-- PASO 2: Crear estudiantes dummy si no existen
-- ============================================================
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
    LPAD((ROW_NUMBER() OVER())::TEXT, 8, '0'),
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
LIMIT 30;

-- ============================================================
-- PASO 3: Crear profesores dummy si no existen
-- ============================================================
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
    LPAD((ROW_NUMBER() OVER() + 1000)::TEXT, 8, '0'),
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
LIMIT 10;

-- ============================================================
-- PASO 4: Crear grados si no existen
-- ============================================================
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

-- ============================================================
-- PASO 5: Crear grupos si no existen
-- ============================================================
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

-- ============================================================
-- PASO 6: Crear áreas si no existen
-- ============================================================
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

-- ============================================================
-- PASO 7: Crear especialidades si no existen
-- ============================================================
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

-- ============================================================
-- PASO 8: Crear materias si no existen
-- ============================================================
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
-- PASO 9: Asignar estudiantes a grados y grupos
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
LIMIT 50; -- Asignar hasta 50 estudiantes

-- ============================================================
-- PASO 10: Crear asignaciones de materias
-- ============================================================
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

-- ============================================================
-- PASO 11: Asignar profesores a materias
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
LIMIT 50; -- Asignar hasta 50 profesores

-- ============================================================
-- PASO 12: Verificar resultados finales
-- ============================================================
DO $$
DECLARE
    total_students INTEGER;
    total_teachers INTEGER;
    total_subjects INTEGER;
    total_groups INTEGER;
    total_grades INTEGER;
    total_areas INTEGER;
    total_specialties INTEGER;
    total_student_assignments INTEGER;
    total_teacher_assignments INTEGER;
    total_subject_assignments INTEGER;
    students_inclusive INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_students FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante');
    SELECT COUNT(*) INTO total_teachers FROM users WHERE role IN ('teacher', 'Teacher');
    SELECT COUNT(*) INTO total_subjects FROM subjects;
    SELECT COUNT(*) INTO total_groups FROM groups;
    SELECT COUNT(*) INTO total_grades FROM grade_levels;
    SELECT COUNT(*) INTO total_areas FROM areas;
    SELECT COUNT(*) INTO total_specialties FROM specialties;
    SELECT COUNT(*) INTO total_student_assignments FROM student_assignments;
    SELECT COUNT(*) INTO total_teacher_assignments FROM teacher_assignments;
    SELECT COUNT(*) INTO total_subject_assignments FROM subject_assignments;
    SELECT COUNT(*) INTO students_inclusive FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') AND inclusivo = true;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '✅ DATOS DUMMY CARGADOS EXITOSAMENTE';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
    RAISE NOTICE '👥 USUARIOS:';
    RAISE NOTICE '   Estudiantes: %', total_students;
    RAISE NOTICE '   Profesores: %', total_teachers;
    RAISE NOTICE '   Estudiantes inclusivos: %', students_inclusive;
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
    RAISE NOTICE '========================================================';
    RAISE NOTICE '🎉 SISTEMA LISTO PARA PRUEBAS';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;
