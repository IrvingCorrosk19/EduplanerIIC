-- ============================================================
-- VERIFICAR DATOS EN RENDER - CONSULTAS ESPECÍFICAS
-- Fecha: 16 de Octubre, 2025
-- Descripción: Consultas específicas para verificar datos y relaciones
-- ============================================================

-- ============================================================
-- CONSULTA 1: ESTUDIANTES CON SUS ASIGNACIONES Y NOTAS
-- ============================================================
SELECT 
    'ESTUDIANTES CON ASIGNACIONES Y NOTAS' as categoria,
    u.id as student_id,
    u.name as nombre,
    u.last_name as apellido,
    u.email,
    u.inclusivo,
    u.orientacion,
    u.disciplina,
    gl.name as grado,
    g.name as grupo,
    COUNT(sas.id) as total_notas,
    ROUND(AVG(sas.score), 2) as promedio_general,
    ROUND(MIN(sas.score), 2) as nota_minima,
    ROUND(MAX(sas.score), 2) as nota_maxima
FROM users u
INNER JOIN student_assignments sa ON u.id = sa.student_id
INNER JOIN grade_levels gl ON sa.grade_id = gl.id
INNER JOIN groups g ON sa.group_id = g.id
LEFT JOIN student_activity_scores sas ON u.id = sas.student_id
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
AND u.status = 'active'
GROUP BY u.id, u.name, u.last_name, u.email, u.inclusivo, u.orientacion, u.disciplina, gl.name, g.name
ORDER BY promedio_general DESC NULLS LAST
LIMIT 20;

-- ============================================================
-- CONSULTA 2: PROFESORES CON SUS ASIGNACIONES Y ACTIVIDADES
-- ============================================================
SELECT 
    'PROFESORES CON ASIGNACIONES Y ACTIVIDADES' as categoria,
    u.id as teacher_id,
    u.name as nombre,
    u.last_name as apellido,
    u.email,
    s.name as materia,
    a.name as area,
    gl.name as grado,
    g.name as grupo,
    COUNT(a.id) as total_actividades,
    COUNT(sas.id) as total_calificaciones
FROM users u
INNER JOIN teacher_assignments ta ON u.id = ta.teacher_id
INNER JOIN subject_assignments sa ON ta.subject_assignment_id = sa.id
INNER JOIN subjects s ON sa.subject_id = s.id
INNER JOIN areas a ON sa.area_id = a.id
INNER JOIN grade_levels gl ON sa.grade_level_id = gl.id
INNER JOIN groups g ON sa.group_id = g.id
LEFT JOIN activities act ON s.id = act.subject_id AND gl.id = act.grade_level_id AND g.id = act.group_id
LEFT JOIN student_activity_scores sas ON act.id = sas.activity_id
WHERE u.role IN ('teacher', 'Teacher')
AND u.status = 'active'
GROUP BY u.id, u.name, u.last_name, u.email, s.name, a.name, gl.name, g.name
ORDER BY total_actividades DESC
LIMIT 20;

-- ============================================================
-- CONSULTA 3: MATERIAS CON ESTADÍSTICAS DE NOTAS
-- ============================================================
SELECT 
    'MATERIAS CON ESTADÍSTICAS DE NOTAS' as categoria,
    s.name as materia,
    a.name as area,
    gl.name as grado,
    g.name as grupo,
    COUNT(DISTINCT act.id) as total_actividades,
    COUNT(sas.id) as total_calificaciones,
    COUNT(DISTINCT sas.student_id) as estudiantes_evaluados,
    ROUND(AVG(sas.score), 2) as promedio_general,
    ROUND(MIN(sas.score), 2) as nota_minima,
    ROUND(MAX(sas.score), 2) as nota_maxima
FROM subjects s
INNER JOIN areas a ON s."AreaId" = a.id
INNER JOIN subject_assignments sa ON s.id = sa.subject_id
INNER JOIN grade_levels gl ON sa.grade_level_id = gl.id
INNER JOIN groups g ON sa.group_id = g.id
LEFT JOIN activities act ON s.id = act.subject_id AND gl.id = act.grade_level_id AND g.id = act.group_id
LEFT JOIN student_activity_scores sas ON act.id = sas.activity_id
WHERE s.status = true
GROUP BY s.id, s.name, a.name, gl.name, g.name
ORDER BY promedio_general DESC NULLS LAST
LIMIT 20;

-- ============================================================
-- CONSULTA 4: ESTUDIANTES INCLUSIVOS CON SUS NOTAS
-- ============================================================
SELECT 
    'ESTUDIANTES INCLUSIVOS CON NOTAS' as categoria,
    u.id as student_id,
    u.name as nombre,
    u.last_name as apellido,
    u.email,
    u.inclusivo,
    u.orientacion,
    u.disciplina,
    gl.name as grado,
    g.name as grupo,
    COUNT(sas.id) as total_notas,
    ROUND(AVG(sas.score), 2) as promedio_general,
    ROUND(MIN(sas.score), 2) as nota_minima,
    ROUND(MAX(sas.score), 2) as nota_maxima
FROM users u
INNER JOIN student_assignments sa ON u.id = sa.student_id
INNER JOIN grade_levels gl ON sa.grade_id = gl.id
INNER JOIN groups g ON sa.group_id = g.id
LEFT JOIN student_activity_scores sas ON u.id = sas.student_id
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
AND u.status = 'active'
AND u.inclusivo = true
GROUP BY u.id, u.name, u.last_name, u.email, u.inclusivo, u.orientacion, u.disciplina, gl.name, g.name
ORDER BY promedio_general DESC NULLS LAST;

-- ============================================================
-- CONSULTA 5: ACTIVIDADES POR TRIMESTRE
-- ============================================================
SELECT 
    'ACTIVIDADES POR TRIMESTRE' as categoria,
    a.trimester as trimestre,
    a.type as tipo_actividad,
    COUNT(a.id) as total_actividades,
    COUNT(sas.id) as total_calificaciones,
    COUNT(DISTINCT sas.student_id) as estudiantes_evaluados,
    ROUND(AVG(sas.score), 2) as promedio_general
FROM activities a
LEFT JOIN student_activity_scores sas ON a.id = sas.activity_id
GROUP BY a.trimester, a.type
ORDER BY a.trimester, a.type;

-- ============================================================
-- CONSULTA 6: RESUMEN GENERAL DEL SISTEMA
-- ============================================================
SELECT 
    'RESUMEN GENERAL DEL SISTEMA' as categoria,
    COUNT(DISTINCT u.id) as total_estudiantes,
    COUNT(DISTINCT CASE WHEN u.inclusivo = true THEN u.id END) as estudiantes_inclusivos,
    COUNT(DISTINCT t.id) as total_profesores,
    COUNT(DISTINCT s.id) as total_materias,
    COUNT(DISTINCT gl.id) as total_grados,
    COUNT(DISTINCT g.id) as total_grupos,
    COUNT(DISTINCT a.id) as total_actividades,
    COUNT(sas.id) as total_calificaciones,
    ROUND(AVG(sas.score), 2) as promedio_general,
    ROUND(MIN(sas.score), 2) as nota_minima,
    ROUND(MAX(sas.score), 2) as nota_maxima
FROM users u
LEFT JOIN users t ON t.role IN ('teacher', 'Teacher') AND t.status = 'active'
LEFT JOIN subjects s ON s.status = true
LEFT JOIN grade_levels gl ON gl.id IS NOT NULL
LEFT JOIN groups g ON g.id IS NOT NULL
LEFT JOIN activities a ON a.id IS NOT NULL
LEFT JOIN student_activity_scores sas ON sas.id IS NOT NULL
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
AND u.status = 'active';

-- ============================================================
-- CONSULTA 7: ESTUDIANTES SIN NOTAS
-- ============================================================
SELECT 
    'ESTUDIANTES SIN NOTAS' as categoria,
    u.id as student_id,
    u.name as nombre,
    u.last_name as apellido,
    u.email,
    u.inclusivo,
    u.orientacion,
    u.disciplina,
    gl.name as grado,
    g.name as grupo
FROM users u
INNER JOIN student_assignments sa ON u.id = sa.student_id
INNER JOIN grade_levels gl ON sa.grade_id = gl.id
INNER JOIN groups g ON sa.group_id = g.id
LEFT JOIN student_activity_scores sas ON u.id = sas.student_id
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
AND u.status = 'active'
AND sas.student_id IS NULL
ORDER BY u.name;

-- ============================================================
-- CONSULTA 8: PROFESORES SIN ACTIVIDADES
-- ============================================================
SELECT 
    'PROFESORES SIN ACTIVIDADES' as categoria,
    u.id as teacher_id,
    u.name as nombre,
    u.last_name as apellido,
    u.email,
    s.name as materia,
    a.name as area,
    gl.name as grado,
    g.name as grupo
FROM users u
INNER JOIN teacher_assignments ta ON u.id = ta.teacher_id
INNER JOIN subject_assignments sa ON ta.subject_assignment_id = sa.id
INNER JOIN subjects s ON sa.subject_id = s.id
INNER JOIN areas a ON sa.area_id = a.id
INNER JOIN grade_levels gl ON sa.grade_level_id = gl.id
INNER JOIN groups g ON sa.group_id = g.id
LEFT JOIN activities act ON s.id = act.subject_id AND gl.id = act.grade_level_id AND g.id = act.group_id
WHERE u.role IN ('teacher', 'Teacher')
AND u.status = 'active'
AND act.id IS NULL
ORDER BY u.name;
