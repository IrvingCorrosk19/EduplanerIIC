-- ============================================================
-- CONSULTAS PARA ANALIZAR RELACIONES EN RENDER
-- Fecha: 16 de Octubre, 2025
-- Descripción: Analiza las relaciones entre estudiantes, profesores y materias
-- ============================================================

-- ============================================================
-- CONSULTA 1: ESTUDIANTES Y SUS ASIGNACIONES
-- ============================================================
SELECT 
    'ESTUDIANTES CON ASIGNACIONES' as categoria,
    u.id as student_id,
    u.name as nombre,
    u.last_name as apellido,
    u.email,
    u.inclusivo,
    u.orientacion,
    u.disciplina,
    gl.name as grado,
    g.name as grupo,
    sa.created_at as fecha_asignacion
FROM users u
INNER JOIN student_assignments sa ON u.id = sa.student_id
INNER JOIN grade_levels gl ON sa.grade_id = gl.id
INNER JOIN groups g ON sa.group_id = g.id
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
AND u.status = 'active'
ORDER BY gl.name, g.name, u.name;

-- ============================================================
-- CONSULTA 2: PROFESORES Y SUS ASIGNACIONES
-- ============================================================
SELECT 
    'PROFESORES CON ASIGNACIONES' as categoria,
    u.id as teacher_id,
    u.name as nombre,
    u.last_name as apellido,
    u.email,
    s.name as materia,
    a.name as area,
    gl.name as grado,
    g.name as grupo,
    ta.created_at as fecha_asignacion
FROM users u
INNER JOIN teacher_assignments ta ON u.id = ta.teacher_id
INNER JOIN subject_assignments sa ON ta.subject_assignment_id = sa.id
INNER JOIN subjects s ON sa.subject_id = s.id
INNER JOIN areas a ON sa.area_id = a.id
INNER JOIN grade_levels gl ON sa.grade_level_id = gl.id
INNER JOIN groups g ON sa.group_id = g.id
WHERE u.role IN ('teacher', 'Teacher')
AND u.status = 'active'
ORDER BY s.name, gl.name, g.name, u.name;

-- ============================================================
-- CONSULTA 3: MATERIAS POR GRADO Y GRUPO
-- ============================================================
SELECT 
    'MATERIAS POR GRADO Y GRUPO' as categoria,
    s.name as materia,
    a.name as area,
    gl.name as grado,
    g.name as grupo,
    COUNT(ta.id) as profesores_asignados,
    COUNT(sa.id) as asignaciones_totales
FROM subjects s
INNER JOIN subject_assignments sa ON s.id = sa.subject_id
INNER JOIN areas a ON sa.area_id = a.id
INNER JOIN grade_levels gl ON sa.grade_level_id = gl.id
INNER JOIN groups g ON sa.group_id = g.id
LEFT JOIN teacher_assignments ta ON sa.id = ta.subject_assignment_id
GROUP BY s.id, s.name, a.name, gl.name, g.name
ORDER BY gl.name, g.name, s.name;

-- ============================================================
-- CONSULTA 4: ESTUDIANTES SIN ASIGNACIONES
-- ============================================================
SELECT 
    'ESTUDIANTES SIN ASIGNACIONES' as categoria,
    u.id as student_id,
    u.name as nombre,
    u.last_name as apellido,
    u.email,
    u.inclusivo,
    u.orientacion,
    u.disciplina
FROM users u
LEFT JOIN student_assignments sa ON u.id = sa.student_id
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
AND u.status = 'active'
AND sa.student_id IS NULL
ORDER BY u.name;

-- ============================================================
-- CONSULTA 5: PROFESORES SIN ASIGNACIONES
-- ============================================================
SELECT 
    'PROFESORES SIN ASIGNACIONES' as categoria,
    u.id as teacher_id,
    u.name as nombre,
    u.last_name as apellido,
    u.email
FROM users u
LEFT JOIN teacher_assignments ta ON u.id = ta.teacher_id
WHERE u.role IN ('teacher', 'Teacher')
AND u.status = 'active'
AND ta.teacher_id IS NULL
ORDER BY u.name;

-- ============================================================
-- CONSULTA 6: RESUMEN DE ASIGNACIONES
-- ============================================================
SELECT 
    'RESUMEN DE ASIGNACIONES' as categoria,
    COUNT(DISTINCT u.id) as total_estudiantes,
    COUNT(DISTINCT sa.student_id) as estudiantes_asignados,
    COUNT(DISTINCT t.id) as total_profesores,
    COUNT(DISTINCT ta.teacher_id) as profesores_asignados,
    COUNT(DISTINCT s.id) as total_materias,
    COUNT(DISTINCT sa2.id) as asignaciones_materias,
    COUNT(DISTINCT gl.id) as total_grados,
    COUNT(DISTINCT g.id) as total_grupos
FROM users u
LEFT JOIN student_assignments sa ON u.id = sa.student_id
LEFT JOIN users t ON t.role IN ('teacher', 'Teacher') AND t.status = 'active'
LEFT JOIN teacher_assignments ta ON t.id = ta.teacher_id
LEFT JOIN subjects s ON s.status = true
LEFT JOIN subject_assignments sa2 ON s.id = sa2.subject_id
LEFT JOIN grade_levels gl ON gl.id = sa.grade_id OR gl.id = sa2.grade_level_id
LEFT JOIN groups g ON g.id = sa.group_id OR g.id = sa2.group_id
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
AND u.status = 'active';

-- ============================================================
-- CONSULTA 7: TRIMESTRES DISPONIBLES
-- ============================================================
SELECT 
    'TRIMESTRES DISPONIBLES' as categoria,
    id,
    name as nombre,
    start_date as fecha_inicio,
    end_date as fecha_fin,
    is_active as activo
FROM trimester
ORDER BY name;

-- ============================================================
-- CONSULTA 8: TIPOS DE ACTIVIDADES
-- ============================================================
SELECT 
    'TIPOS DE ACTIVIDADES' as categoria,
    id,
    name as nombre,
    description as descripcion,
    is_active as activo
FROM activity_types
ORDER BY name;
