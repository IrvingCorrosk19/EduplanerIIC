-- ============================================================
-- CARGAR DATOS DUMMY EN BASE DE DATOS LOCAL
-- Fecha: 18 de Octubre, 2025
-- Descripción: Carga estructura académica completa con datos de prueba
-- ============================================================

-- ============================================================
-- PASO 1: Obtener el ID de la escuela
-- ============================================================
DO $$
DECLARE
    v_school_id UUID;
    v_admin_id UUID;
BEGIN
    -- Obtener el ID de la escuela
    SELECT id INTO v_school_id FROM schools LIMIT 1;
    
    -- Obtener el ID del administrador
    SELECT id INTO v_admin_id FROM users WHERE role = 'admin' LIMIT 1;
    
    RAISE NOTICE 'School ID: %', v_school_id;
    RAISE NOTICE 'Admin ID: %', v_admin_id;
END $$;

-- ============================================================
-- PASO 2: Insertar Trimestres
-- ============================================================
INSERT INTO trimester (id, school_id, name, start_date, end_date, is_active, "order", created_at)
SELECT 
    gen_random_uuid(),
    (SELECT id FROM schools LIMIT 1),
    '1T',
    '2025-03-01'::date,
    '2025-05-31'::date,
    true,
    1,
    NOW()
WHERE NOT EXISTS (SELECT 1 FROM trimester WHERE name = '1T');

INSERT INTO trimester (id, school_id, name, start_date, end_date, is_active, "order", created_at)
SELECT 
    gen_random_uuid(),
    (SELECT id FROM schools LIMIT 1),
    '2T',
    '2025-06-01'::date,
    '2025-08-31'::date,
    true,
    2,
    NOW()
WHERE NOT EXISTS (SELECT 1 FROM trimester WHERE name = '2T');

INSERT INTO trimester (id, school_id, name, start_date, end_date, is_active, "order", created_at)
SELECT 
    gen_random_uuid(),
    (SELECT id FROM schools LIMIT 1),
    '3T',
    '2025-09-01'::date,
    '2025-11-30'::date,
    true,
    3,
    NOW()
WHERE NOT EXISTS (SELECT 1 FROM trimester WHERE name = '3T');

-- ============================================================
-- PASO 3: Insertar Áreas Académicas
-- ============================================================
INSERT INTO area (id, school_id, name, code, is_active, display_order, created_at)
VALUES 
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Humanística', 'HUM', true, 1, NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Científica', 'CIE', true, 2, NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Tecnológica', 'TEC', true, 3, NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Artística', 'ART', true, 4, NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Deportiva', 'DEP', true, 5, NOW())
ON CONFLICT DO NOTHING;

-- ============================================================
-- PASO 4: Insertar Especialidades
-- ============================================================
INSERT INTO specialties (id, school_id, name, code, is_active, created_at)
VALUES 
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Ciencias', 'CIE', true, NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Letras', 'LET', true, NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Comercio', 'COM', true, NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Industrial', 'IND', true, NOW())
ON CONFLICT DO NOTHING;

-- ============================================================
-- PASO 5: Insertar Niveles de Grado (Grade Levels)
-- ============================================================
INSERT INTO grade_levels (id, school_id, name, code, created_at)
VALUES 
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), '7°', '7', NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), '8°', '8', NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), '9°', '9', NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), '10°', '10', NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), '11°', '11', NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), '12°', '12', NOW())
ON CONFLICT DO NOTHING;

-- ============================================================
-- PASO 6: Insertar Grupos
-- ============================================================
INSERT INTO groups (id, school_id, grade, name, created_at)
SELECT 
    gen_random_uuid(),
    (SELECT id FROM schools LIMIT 1),
    gl.name,
    chr(64 + n),
    NOW()
FROM grade_levels gl
CROSS JOIN generate_series(1, 3) n;

-- ============================================================
-- PASO 7: Insertar Tipos de Actividad
-- ============================================================
INSERT INTO activity_types (id, school_id, name, is_active, display_order, created_at)
VALUES 
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Notas de apreciación', true, 1, NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Ejercicios diarios', true, 2, NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Examen Final', true, 3, NOW())
ON CONFLICT DO NOTHING;

-- ============================================================
-- PASO 8: Insertar Materias
-- ============================================================
INSERT INTO subjects (id, school_id, area_id, name, code, status, created_at)
SELECT 
    gen_random_uuid(),
    (SELECT id FROM schools LIMIT 1),
    a.id,
    materia.nombre,
    materia.codigo,
    true,
    NOW()
FROM area a
CROSS JOIN LATERAL (
    VALUES 
        ('Español', 'ESP'),
        ('Matemáticas', 'MAT'),
        ('Ciencias Naturales', 'CN'),
        ('Ciencias Sociales', 'CS'),
        ('Inglés', 'ING'),
        ('Educación Física', 'EF'),
        ('Informática', 'INF'),
        ('Arte', 'ART'),
        ('Música', 'MUS'),
        ('Religión', 'REL')
) AS materia(nombre, codigo)
WHERE a.code IN ('HUM', 'CIE', 'TEC')
LIMIT 20;

-- ============================================================
-- PASO 9: Insertar Profesores
-- ============================================================
INSERT INTO users (id, school_id, name, last_name, email, document_id, role, status, password_hash, birth_date, created_at)
VALUES 
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'María', 'García López', 'maria.garcia@ipt.edu.pa', '8-123-4567', 'teacher', 'active', '$2a$11$default_hash', '1985-03-15', NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'José', 'Rodríguez Pérez', 'jose.rodriguez@ipt.edu.pa', '8-234-5678', 'teacher', 'active', '$2a$11$default_hash', '1982-07-22', NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Ana', 'Martínez Silva', 'ana.martinez@ipt.edu.pa', '8-345-6789', 'teacher', 'active', '$2a$11$default_hash', '1988-11-10', NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Carlos', 'López Vargas', 'carlos.lopez@ipt.edu.pa', '8-456-7890', 'teacher', 'active', '$2a$11$default_hash', '1980-05-30', NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Laura', 'Sánchez Moreno', 'laura.sanchez@ipt.edu.pa', '8-567-8901', 'teacher', 'active', '$2a$11$default_hash', '1990-09-18', NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Pedro', 'Hernández Castro', 'pedro.hernandez@ipt.edu.pa', '8-678-9012', 'teacher', 'active', '$2a$11$default_hash', '1983-12-05', NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Carmen', 'Gómez Ruiz', 'carmen.gomez@ipt.edu.pa', '8-789-0123', 'teacher', 'active', '$2a$11$default_hash', '1987-04-25', NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Luis', 'Díaz Jiménez', 'luis.diaz@ipt.edu.pa', '8-890-1234', 'teacher', 'active', '$2a$11$default_hash', '1984-08-14', NOW());

-- ============================================================
-- PASO 10: Insertar Orientadores
-- ============================================================
INSERT INTO users (id, school_id, name, last_name, email, document_id, role, status, password_hash, birth_date, is_counselor, created_at)
VALUES 
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Sofía', 'Torres Mendoza', 'sofia.torres@ipt.edu.pa', '8-111-2222', 'counselor', 'active', '$2a$11$default_hash', '1986-06-20', true, NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Roberto', 'Ramírez Flores', 'roberto.ramirez@ipt.edu.pa', '8-222-3333', 'counselor', 'active', '$2a$11$default_hash', '1981-10-12', true, NOW());

-- ============================================================
-- PASO 11: Insertar Director
-- ============================================================
INSERT INTO users (id, school_id, name, last_name, email, document_id, role, status, password_hash, birth_date, created_at)
VALUES 
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Miguel', 'Fernández Ortiz', 'miguel.fernandez@ipt.edu.pa', '8-999-8888', 'director', 'active', '$2a$11$default_hash', '1975-02-28', NOW())
ON CONFLICT DO NOTHING;

-- ============================================================
-- PASO 12: Insertar Estudiantes (50 estudiantes)
-- ============================================================
INSERT INTO users (id, school_id, name, last_name, email, document_id, role, status, password_hash, birth_date, inclusivo, created_at)
SELECT 
    gen_random_uuid(),
    (SELECT id FROM schools LIMIT 1),
    nombres.nombre,
    apellidos.apellido,
    LOWER(REPLACE(nombres.nombre, ' ', '.')) || '.' || LOWER(REPLACE(apellidos.apellido, ' ', '.')) || '@estudiante.ipt.edu.pa',
    '9-' || LPAD((1000 + n)::text, 4, '0'),
    'student',
    'active',
    '$2a$11$default_hash',
    '2008-01-01'::date + (n || ' days')::interval,
    CASE WHEN RANDOM() < 0.15 THEN true ELSE false END,
    NOW()
FROM generate_series(1, 50) n
CROSS JOIN LATERAL (
    SELECT CASE (n % 10)
        WHEN 0 THEN 'Juan'
        WHEN 1 THEN 'María'
        WHEN 2 THEN 'Carlos'
        WHEN 3 THEN 'Ana'
        WHEN 4 THEN 'Luis'
        WHEN 5 THEN 'Laura'
        WHEN 6 THEN 'Pedro'
        WHEN 7 THEN 'Carmen'
        WHEN 8 THEN 'José'
        ELSE 'Sofía'
    END as nombre
) nombres
CROSS JOIN LATERAL (
    SELECT CASE ((n / 10) % 10)
        WHEN 0 THEN 'García López'
        WHEN 1 THEN 'Rodríguez Pérez'
        WHEN 2 THEN 'Martínez Silva'
        WHEN 3 THEN 'López Vargas'
        WHEN 4 THEN 'Sánchez Moreno'
        WHEN 5 THEN 'Hernández Castro'
        WHEN 6 THEN 'Gómez Ruiz'
        WHEN 7 THEN 'Díaz Jiménez'
        WHEN 8 THEN 'Torres Mendoza'
        ELSE 'Ramírez Flores'
    END as apellido
) apellidos;

-- ============================================================
-- PASO 13: Crear Asignaciones de Materias (Subject Assignments)
-- ============================================================
INSERT INTO subject_assignments (id, school_id, subject_id, grade_level_id, group_id, created_at)
SELECT 
    gen_random_uuid(),
    (SELECT id FROM schools LIMIT 1),
    s.id,
    gl.id,
    g.id,
    NOW()
FROM subjects s
CROSS JOIN grade_levels gl
CROSS JOIN groups g
WHERE g.grade = gl.name
LIMIT 100;

-- ============================================================
-- PASO 14: Asignar Profesores a Materias
-- ============================================================
INSERT INTO teacher_assignments (id, teacher_id, subject_assignment_id, created_at)
SELECT 
    gen_random_uuid(),
    t.id,
    sa.id,
    NOW()
FROM (
    SELECT id, ROW_NUMBER() OVER (ORDER BY RANDOM()) as rn
    FROM users 
    WHERE role = 'teacher'
) t
CROSS JOIN LATERAL (
    SELECT id, ROW_NUMBER() OVER (ORDER BY RANDOM()) as rn
    FROM subject_assignments
    LIMIT 12
) sa
WHERE t.rn <= 8 AND sa.rn <= 100
ON CONFLICT DO NOTHING;

-- ============================================================
-- PASO 15: Asignar Estudiantes a Grupos
-- ============================================================
INSERT INTO student_assignments (id, student_id, group_id, grade_id, school_id, created_at)
SELECT 
    gen_random_uuid(),
    u.id,
    g.id,
    gl.id,
    (SELECT id FROM schools LIMIT 1),
    NOW()
FROM (
    SELECT id, ROW_NUMBER() OVER (ORDER BY RANDOM()) as rn
    FROM users 
    WHERE role = 'student'
) u
CROSS JOIN LATERAL (
    SELECT g.id, gl.id
    FROM groups g
    INNER JOIN grade_levels gl ON g.grade = gl.name
    ORDER BY RANDOM()
    LIMIT 1
) AS lateral_join(group_id, grade_id)
INNER JOIN groups g ON g.id = lateral_join.group_id
INNER JOIN grade_levels gl ON gl.id = lateral_join.grade_id;

-- ============================================================
-- PASO 16: Crear Actividades
-- ============================================================
INSERT INTO activities (id, school_id, teacher_id, subject_id, group_id, grade_level_id, name, type, trimester, due_date, created_at)
SELECT 
    gen_random_uuid(),
    (SELECT id FROM schools LIMIT 1),
    ta.teacher_id,
    sa.subject_id,
    sa.group_id,
    sa.grade_level_id,
    at.name || ' - ' || s.name || ' (' || t.name || ')',
    at.name,
    t.name,
    CASE 
        WHEN t.name = '1T' THEN '2025-05-15'::date
        WHEN t.name = '2T' THEN '2025-08-15'::date
        ELSE '2025-11-15'::date
    END,
    NOW()
FROM subject_assignments sa
INNER JOIN teacher_assignments ta ON sa.id = ta.subject_assignment_id
INNER JOIN subjects s ON sa.subject_id = s.id
CROSS JOIN trimester t
CROSS JOIN activity_types at
WHERE t.is_active = true AND at.is_active = true
LIMIT 300;

-- ============================================================
-- PASO 17: Generar Calificaciones
-- ============================================================
INSERT INTO student_activity_scores (id, student_id, activity_id, score, created_at, created_by, school_id)
SELECT 
    gen_random_uuid(),
    student_id,
    activity_id,
    CASE 
        WHEN RANDOM() < 0.10 THEN 0.5 + (RANDOM() * 1.5)
        WHEN RANDOM() < 0.30 THEN 2.0 + (RANDOM() * 1.0)
        WHEN RANDOM() < 0.60 THEN 3.0 + (RANDOM() * 1.0)
        WHEN RANDOM() < 0.85 THEN 4.0 + (RANDOM() * 0.5)
        ELSE 4.5 + (RANDOM() * 0.5)
    END,
    NOW(),
    (SELECT id FROM users WHERE role = 'teacher' LIMIT 1),
    (SELECT id FROM schools LIMIT 1)
FROM (
    SELECT DISTINCT
        sa_student.student_id,
        a.id as activity_id
    FROM student_assignments sa_student
    INNER JOIN activities a ON sa_student.group_id = a.group_id 
        AND sa_student.grade_id = a.grade_level_id
    WHERE EXISTS (
        SELECT 1 FROM teacher_assignments ta
        INNER JOIN subject_assignments sa ON ta.subject_assignment_id = sa.id
        WHERE sa.subject_id = a.subject_id
    )
    ORDER BY RANDOM()
    LIMIT 1000
) AS valid_combinations;

-- ============================================================
-- PASO 18: Verificar Resultados
-- ============================================================
SELECT 
    'RESUMEN DE DATOS CARGADOS' as categoria,
    (SELECT COUNT(*) FROM trimester) as trimestres,
    (SELECT COUNT(*) FROM area) as areas,
    (SELECT COUNT(*) FROM specialties) as especialidades,
    (SELECT COUNT(*) FROM grade_levels) as niveles,
    (SELECT COUNT(*) FROM groups) as grupos,
    (SELECT COUNT(*) FROM subjects) as materias,
    (SELECT COUNT(*) FROM activity_types) as tipos_actividad,
    (SELECT COUNT(*) FROM users WHERE role = 'teacher') as profesores,
    (SELECT COUNT(*) FROM users WHERE role = 'counselor') as orientadores,
    (SELECT COUNT(*) FROM users WHERE role = 'director') as directores,
    (SELECT COUNT(*) FROM users WHERE role = 'student') as estudiantes,
    (SELECT COUNT(*) FROM subject_assignments) as asignaciones_materias,
    (SELECT COUNT(*) FROM teacher_assignments) as asignaciones_profesores,
    (SELECT COUNT(*) FROM student_assignments) as asignaciones_estudiantes,
    (SELECT COUNT(*) FROM activities) as actividades,
    (SELECT COUNT(*) FROM student_activity_scores) as calificaciones;

-- ============================================================
-- RESUMEN FINAL
-- ============================================================
DO $$
DECLARE
    total_trimestres INTEGER;
    total_areas INTEGER;
    total_especialidades INTEGER;
    total_niveles INTEGER;
    total_grupos INTEGER;
    total_materias INTEGER;
    total_tipos_actividad INTEGER;
    total_profesores INTEGER;
    total_orientadores INTEGER;
    total_directores INTEGER;
    total_estudiantes INTEGER;
    total_asig_materias INTEGER;
    total_asig_profesores INTEGER;
    total_asig_estudiantes INTEGER;
    total_actividades INTEGER;
    total_calificaciones INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_trimestres FROM trimester;
    SELECT COUNT(*) INTO total_areas FROM area;
    SELECT COUNT(*) INTO total_especialidades FROM specialties;
    SELECT COUNT(*) INTO total_niveles FROM grade_levels;
    SELECT COUNT(*) INTO total_grupos FROM groups;
    SELECT COUNT(*) INTO total_materias FROM subjects;
    SELECT COUNT(*) INTO total_tipos_actividad FROM activity_types;
    SELECT COUNT(*) INTO total_profesores FROM users WHERE role = 'teacher';
    SELECT COUNT(*) INTO total_orientadores FROM users WHERE role = 'counselor';
    SELECT COUNT(*) INTO total_directores FROM users WHERE role = 'director';
    SELECT COUNT(*) INTO total_estudiantes FROM users WHERE role = 'student';
    SELECT COUNT(*) INTO total_asig_materias FROM subject_assignments;
    SELECT COUNT(*) INTO total_asig_profesores FROM teacher_assignments;
    SELECT COUNT(*) INTO total_asig_estudiantes FROM student_assignments;
    SELECT COUNT(*) INTO total_actividades FROM activities;
    SELECT COUNT(*) INTO total_calificaciones FROM student_activity_scores;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '✅ DATOS DUMMY CARGADOS EXITOSAMENTE';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '📚 ESTRUCTURA ACADÉMICA:';
    RAISE NOTICE '   Trimestres: %', total_trimestres;
    RAISE NOTICE '   Áreas: %', total_areas;
    RAISE NOTICE '   Especialidades: %', total_especialidades;
    RAISE NOTICE '   Niveles de Grado: %', total_niveles;
    RAISE NOTICE '   Grupos: %', total_grupos;
    RAISE NOTICE '   Materias: %', total_materias;
    RAISE NOTICE '   Tipos de Actividad: %', total_tipos_actividad;
    RAISE NOTICE '';
    RAISE NOTICE '👥 USUARIOS:';
    RAISE NOTICE '   Profesores: %', total_profesores;
    RAISE NOTICE '   Orientadores: %', total_orientadores;
    RAISE NOTICE '   Directores: %', total_directores;
    RAISE NOTICE '   Estudiantes: %', total_estudiantes;
    RAISE NOTICE '';
    RAISE NOTICE '📋 ASIGNACIONES:';
    RAISE NOTICE '   Asignaciones de Materias: %', total_asig_materias;
    RAISE NOTICE '   Asignaciones de Profesores: %', total_asig_profesores;
    RAISE NOTICE '   Asignaciones de Estudiantes: %', total_asig_estudiantes;
    RAISE NOTICE '';
    RAISE NOTICE '📝 ACTIVIDADES Y CALIFICACIONES:';
    RAISE NOTICE '   Actividades: %', total_actividades;
    RAISE NOTICE '   Calificaciones: %', total_calificaciones;
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '🎉 BASE DE DATOS LISTA PARA USAR';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;
