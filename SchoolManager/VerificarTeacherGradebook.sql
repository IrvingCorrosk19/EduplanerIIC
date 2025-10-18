-- Script para verificar los datos necesarios para TeacherGradebook/Index

-- 1. Verificar usuarios con rol teacher
SELECT 
    u.id,
    u.name,
    u.last_name,
    u.email,
    u.role,
    u.status
FROM users u 
WHERE u.role = 'teacher' 
ORDER BY u.name;

-- 2. Verificar asignaciones de docentes
SELECT 
    ta.id as teacher_assignment_id,
    u.name as teacher_name,
    u.last_name as teacher_last_name,
    sa.subject_id,
    s.name as subject_name,
    sa.group_id,
    g.name as group_name,
    sa.grade_level_id,
    gl.name as grade_level_name
FROM teacher_assignments ta
JOIN users u ON ta.teacher_id = u.id
JOIN subject_assignments sa ON ta.subject_assignment_id = sa.id
JOIN subjects s ON sa.subject_id = s.id
JOIN groups g ON sa.group_id = g.id
JOIN grade_levels gl ON sa.grade_level_id = gl.id
WHERE u.role = 'teacher'
ORDER BY u.name, s.name, g.name;

-- 3. Verificar estudiantes asignados a grupos
SELECT 
    sa.id as student_assignment_id,
    u.name as student_name,
    u.last_name as student_last_name,
    u.document_id,
    sa.group_id,
    g.name as group_name,
    sa.grade_id as grade_level_id,
    gl.name as grade_level_name
FROM student_assignments sa
JOIN users u ON sa.student_id = u.id
JOIN groups g ON sa.group_id = g.id
JOIN grade_levels gl ON sa.grade_id = gl.id
WHERE u.role IN ('student', 'estudiante')
ORDER BY g.name, u.name;

-- 4. Verificar trimestres
SELECT 
    id,
    name,
    is_active,
    school_id
FROM trimesters
ORDER BY name;

-- 5. Verificar tipos de actividad
SELECT 
    id,
    name,
    is_active,
    display_order
FROM activity_types
ORDER BY display_order, name;

-- 6. Verificar actividades existentes
SELECT 
    a.id,
    a.name,
    a.type,
    a.teacher_id,
    u.name as teacher_name,
    a.group_id,
    g.name as group_name,
    a.trimester,
    a.created_at
FROM activities a
JOIN users u ON a.teacher_id = u.id
JOIN groups g ON a.group_id = g.id
ORDER BY a.created_at DESC
LIMIT 10;

-- 7. Verificar calificaciones existentes
SELECT 
    sas.id,
    sas.student_id,
    u.name as student_name,
    sas.activity_name,
    sas.activity_type,
    sas.score,
    sas.subject_id,
    s.name as subject_name,
    sas.group_id,
    g.name as group_name,
    sas.trimester
FROM student_activity_scores sas
JOIN users u ON sas.student_id = u.id
LEFT JOIN subjects s ON sas.subject_id = s.id
LEFT JOIN groups g ON sas.group_id = g.id
ORDER BY sas.created_at DESC
LIMIT 10;
