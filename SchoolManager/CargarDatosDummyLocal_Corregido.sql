-- ============================================================
-- CARGAR DATOS DUMMY EN BASE DE DATOS LOCAL (CORREGIDO)
-- Fecha: 18 de Octubre, 2025
-- ============================================================

-- Variables globales
DO $$
DECLARE
    v_school_id UUID;
    v_admin_id UUID;
BEGIN
    SELECT id INTO v_school_id FROM schools LIMIT 1;
    SELECT id INTO v_admin_id FROM users WHERE role = 'admin' LIMIT 1;
    
    RAISE NOTICE 'School ID: %', v_school_id;
    RAISE NOTICE 'Admin ID: %', v_admin_id;
END $$;

-- ============================================================
-- PASO 1: Insertar Especialidades
-- ============================================================
INSERT INTO specialties (id, school_id, name, created_at)
VALUES 
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Ciencias', NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Letras', NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Comercio', NOW())
ON CONFLICT DO NOTHING;

-- ============================================================
-- PASO 2: Insertar Niveles de Grado
-- ============================================================
INSERT INTO grade_levels (id, school_id, name, created_at)
VALUES 
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), '7°', NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), '8°', NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), '9°', NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), '10°', NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), '11°', NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), '12°', NOW())
ON CONFLICT DO NOTHING;

-- ============================================================
-- PASO 3: Insertar Grupos
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
-- PASO 4: Insertar Materias
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
        ('Inglés', 'ING')
) AS materia(nombre, codigo);

-- ============================================================
-- PASO 5: Insertar Profesores
-- ============================================================
INSERT INTO users (id, school_id, name, last_name, email, document_id, role, status, password_hash, date_of_birth, created_at)
VALUES 
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'María', 'García López', 'maria.garcia@ipt.edu.pa', '8-123-4567', 'teacher', 'active', '$2a$11$default_hash', '1985-03-15', NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'José', 'Rodríguez Pérez', 'jose.rodriguez@ipt.edu.pa', '8-234-5678', 'teacher', 'active', '$2a$11$default_hash', '1982-07-22', NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Ana', 'Martínez Silva', 'ana.martinez@ipt.edu.pa', '8-345-6789', 'teacher', 'active', '$2a$11$default_hash', '1988-11-10', NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Carlos', 'López Vargas', 'carlos.lopez@ipt.edu.pa', '8-456-7890', 'teacher', 'active', '$2a$11$default_hash', '1980-05-30', NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Laura', 'Sánchez Moreno', 'laura.sanchez@ipt.edu.pa', '8-567-8901', 'teacher', 'active', '$2a$11$default_hash', '1990-09-18', NOW())
ON CONFLICT DO NOTHING;

-- ============================================================
-- PASO 6: Insertar Orientadores
-- ============================================================
INSERT INTO users (id, school_id, name, last_name, email, document_id, role, status, password_hash, date_of_birth, orientacion, created_at)
VALUES 
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Sofía', 'Torres Mendoza', 'sofia.torres@ipt.edu.pa', '8-111-2222', 'counselor', 'active', '$2a$11$default_hash', '1986-06-20', true, NOW()),
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Roberto', 'Ramírez Flores', 'roberto.ramirez@ipt.edu.pa', '8-222-3333', 'counselor', 'active', '$2a$11$default_hash', '1981-10-12', true, NOW())
ON CONFLICT DO NOTHING;

-- ============================================================
-- PASO 7: Insertar Director
-- ============================================================
INSERT INTO users (id, school_id, name, last_name, email, document_id, role, status, password_hash, date_of_birth, created_at)
VALUES 
    (gen_random_uuid(), (SELECT id FROM schools LIMIT 1), 'Miguel', 'Fernández Ortiz', 'miguel.fernandez@ipt.edu.pa', '8-999-8888', 'director', 'active', '$2a$11$default_hash', '1975-02-28', NOW())
ON CONFLICT DO NOTHING;

-- ============================================================
-- PASO 8: Insertar Estudiantes (50 estudiantes)
-- ============================================================
INSERT INTO users (id, school_id, name, last_name, email, document_id, role, status, password_hash, date_of_birth, inclusivo, created_at)
SELECT 
    gen_random_uuid(),
    (SELECT id FROM schools LIMIT 1),
    nombres.nombre,
    apellidos.apellido,
    LOWER(REPLACE(nombres.nombre, ' ', '.')) || '.' || LOWER(REPLACE(apellidos.apellido, ' ', '.')) || n || '@estudiante.ipt.edu.pa',
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
        ELSE 'Hernández Castro'
    END as apellido
) apellidos;

-- ============================================================
-- PASO 9: Crear Asignaciones de Materias
-- ============================================================
INSERT INTO subject_assignments (id, subject_id, grade_level_id, group_id, created_at)
SELECT 
    gen_random_uuid(),
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
-- PASO 10: Asignar Profesores a Materias
-- ============================================================
INSERT INTO teacher_assignments (id, teacher_id, subject_assignment_id, created_at)
SELECT 
    gen_random_uuid(),
    t.teacher_id,
    sa.id,
    NOW()
FROM (
    SELECT id as teacher_id, ROW_NUMBER() OVER (ORDER BY id) as rn
    FROM users 
    WHERE role = 'teacher'
) t
CROSS JOIN LATERAL (
    SELECT id
    FROM subject_assignments
    ORDER BY id
    OFFSET (t.rn - 1) * 12
    LIMIT 12
) sa
ON CONFLICT DO NOTHING;

-- ============================================================
-- PASO 11: Asignar Estudiantes a Grupos
-- ============================================================
WITH student_group_pairs AS (
    SELECT 
        u.id as student_id,
        g.id as group_id,
        gl.id as grade_id,
        ROW_NUMBER() OVER (PARTITION BY u.id ORDER BY RANDOM()) as rn
    FROM users u
    CROSS JOIN groups g
    CROSS JOIN grade_levels gl
    WHERE u.role = 'student' AND g.grade = gl.name
)
INSERT INTO student_assignments (id, student_id, group_id, grade_id, created_at)
SELECT 
    gen_random_uuid(),
    student_id,
    group_id,
    grade_id,
    NOW()
FROM student_group_pairs
WHERE rn = 1;

-- ============================================================
-- PASO 12: Crear Actividades
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
-- PASO 13: Generar Calificaciones
-- ============================================================
INSERT INTO student_activity_scores (id, student_id, activity_id, score, created_at, created_by, school_id)
SELECT 
    gen_random_uuid(),
    sa.student_id,
    a.id,
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
FROM student_assignments sa
INNER JOIN activities a ON sa.group_id = a.group_id AND sa.grade_id = a.grade_level_id
LIMIT 1000;

-- ============================================================
-- RESUMEN FINAL
-- ============================================================
DO $$
DECLARE
    v_trimestres INTEGER;
    v_areas INTEGER;
    v_especialidades INTEGER;
    v_niveles INTEGER;
    v_grupos INTEGER;
    v_materias INTEGER;
    v_tipos_actividad INTEGER;
    v_profesores INTEGER;
    v_orientadores INTEGER;
    v_directores INTEGER;
    v_estudiantes INTEGER;
    v_asig_materias INTEGER;
    v_asig_profesores INTEGER;
    v_asig_estudiantes INTEGER;
    v_actividades INTEGER;
    v_calificaciones INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_trimestres FROM trimester;
    SELECT COUNT(*) INTO v_areas FROM area;
    SELECT COUNT(*) INTO v_especialidades FROM specialties;
    SELECT COUNT(*) INTO v_niveles FROM grade_levels;
    SELECT COUNT(*) INTO v_grupos FROM groups;
    SELECT COUNT(*) INTO v_materias FROM subjects;
    SELECT COUNT(*) INTO v_tipos_actividad FROM activity_types;
    SELECT COUNT(*) INTO v_profesores FROM users WHERE role = 'teacher';
    SELECT COUNT(*) INTO v_orientadores FROM users WHERE role = 'counselor';
    SELECT COUNT(*) INTO v_directores FROM users WHERE role = 'director';
    SELECT COUNT(*) INTO v_estudiantes FROM users WHERE role = 'student';
    SELECT COUNT(*) INTO v_asig_materias FROM subject_assignments;
    SELECT COUNT(*) INTO v_asig_profesores FROM teacher_assignments;
    SELECT COUNT(*) INTO v_asig_estudiantes FROM student_assignments;
    SELECT COUNT(*) INTO v_actividades FROM activities;
    SELECT COUNT(*) INTO v_calificaciones FROM student_activity_scores;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '✅ DATOS DUMMY CARGADOS EXITOSAMENTE';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '📚 ESTRUCTURA ACADÉMICA:';
    RAISE NOTICE '   Trimestres: %', v_trimestres;
    RAISE NOTICE '   Áreas: %', v_areas;
    RAISE NOTICE '   Especialidades: %', v_especialidades;
    RAISE NOTICE '   Niveles de Grado: %', v_niveles;
    RAISE NOTICE '   Grupos: %', v_grupos;
    RAISE NOTICE '   Materias: %', v_materias;
    RAISE NOTICE '   Tipos de Actividad: %', v_tipos_actividad;
    RAISE NOTICE '';
    RAISE NOTICE '👥 USUARIOS:';
    RAISE NOTICE '   Profesores: %', v_profesores;
    RAISE NOTICE '   Orientadores: %', v_orientadores;
    RAISE NOTICE '   Directores: %', v_directores;
    RAISE NOTICE '   Estudiantes: %', v_estudiantes;
    RAISE NOTICE '';
    RAISE NOTICE '📋 ASIGNACIONES:';
    RAISE NOTICE '   Asignaciones de Materias: %', v_asig_materias;
    RAISE NOTICE '   Asignaciones de Profesores: %', v_asig_profesores;
    RAISE NOTICE '   Asignaciones de Estudiantes: %', v_asig_estudiantes;
    RAISE NOTICE '';
    RAISE NOTICE '📝 ACTIVIDADES Y CALIFICACIONES:';
    RAISE NOTICE '   Actividades: %', v_actividades;
    RAISE NOTICE '   Calificaciones: %', v_calificaciones;
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '🎉 BASE DE DATOS LISTA PARA USAR';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;
