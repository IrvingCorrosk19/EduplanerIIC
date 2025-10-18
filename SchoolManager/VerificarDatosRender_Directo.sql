-- ============================================================
-- VERIFICACIÓN DIRECTA DE DATOS EN RENDER
-- Fecha: 16 de Octubre, 2025
-- Descripción: Verifica los datos existentes en Render antes de generar dummy
-- ============================================================

-- ============================================================
-- CONSULTA 1: Verificar usuarios existentes
-- ============================================================
SELECT 
    'USUARIOS EXISTENTES' as categoria,
    role as rol,
    COUNT(*) as cantidad,
    COUNT(CASE WHEN status = 'active' THEN 1 END) as activos,
    COUNT(CASE WHEN status = 'inactive' THEN 1 END) as inactivos
FROM users 
GROUP BY role
ORDER BY role;

-- ============================================================
-- CONSULTA 2: Verificar estudiantes y su estado inclusivo
-- ============================================================
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

-- ============================================================
-- CONSULTA 3: Verificar asignaciones de estudiantes
-- ============================================================
SELECT 
    'ASIGNACIONES DE ESTUDIANTES' as categoria,
    COUNT(*) as total_asignaciones,
    COUNT(DISTINCT student_id) as estudiantes_asignados,
    COUNT(DISTINCT grade_id) as grados_utilizados,
    COUNT(DISTINCT group_id) as grupos_utilizados
FROM student_assignments;

-- ============================================================
-- CONSULTA 4: Verificar asignaciones de profesores
-- ============================================================
SELECT 
    'ASIGNACIONES DE PROFESORES' as categoria,
    COUNT(*) as total_asignaciones,
    COUNT(DISTINCT teacher_id) as profesores_asignados,
    COUNT(DISTINCT subject_assignment_id) as materias_asignadas
FROM teacher_assignments;

-- ============================================================
-- CONSULTA 5: Verificar estructura académica
-- ============================================================
SELECT 
    'ESTRUCTURA ACADÉMICA' as categoria,
    (SELECT COUNT(*) FROM grade_levels) as total_grados,
    (SELECT COUNT(*) FROM groups) as total_grupos,
    (SELECT COUNT(*) FROM areas) as total_areas,
    (SELECT COUNT(*) FROM specialties) as total_especialidades,
    (SELECT COUNT(*) FROM subjects WHERE status = true) as total_materias,
    (SELECT COUNT(*) FROM subject_assignments) as asignaciones_materias;

-- ============================================================
-- CONSULTA 6: Verificar actividades y notas existentes
-- ============================================================
SELECT 
    'ACTIVIDADES Y NOTAS EXISTENTES' as categoria,
    (SELECT COUNT(*) FROM activities) as total_actividades,
    (SELECT COUNT(*) FROM student_activity_scores) as total_calificaciones,
    (SELECT COUNT(DISTINCT student_id) FROM student_activity_scores) as estudiantes_con_notas,
    (SELECT COUNT(DISTINCT activity_id) FROM student_activity_scores) as actividades_con_notas,
    (SELECT ROUND(AVG(score), 2) FROM student_activity_scores) as promedio_general;

-- ============================================================
-- CONSULTA 7: Verificar trimestres y tipos de actividades
-- ============================================================
SELECT 
    'TRIMESTRES Y TIPOS DE ACTIVIDADES' as categoria,
    (SELECT COUNT(*) FROM trimester WHERE is_active = true) as trimestres_activos,
    (SELECT COUNT(*) FROM activity_types WHERE is_active = true) as tipos_actividades_activos;

-- ============================================================
-- CONSULTA 8: Mostrar algunos estudiantes existentes
-- ============================================================
SELECT 
    'ESTUDIANTES EXISTENTES (MUESTRA)' as categoria,
    u.id,
    u.name as nombre,
    u.last_name as apellido,
    u.email,
    u.inclusivo,
    u.orientacion,
    u.disciplina,
    u.status
FROM users u
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
AND u.status = 'active'
ORDER BY u.name
LIMIT 10;

-- ============================================================
-- CONSULTA 9: Mostrar algunos profesores existentes
-- ============================================================
SELECT 
    'PROFESORES EXISTENTES (MUESTRA)' as categoria,
    u.id,
    u.name as nombre,
    u.last_name as apellido,
    u.email,
    u.status
FROM users u
WHERE u.role IN ('teacher', 'Teacher')
AND u.status = 'active'
ORDER BY u.name
LIMIT 10;

-- ============================================================
-- CONSULTA 10: Mostrar materias existentes
-- ============================================================
SELECT 
    'MATERIAS EXISTENTES (MUESTRA)' as categoria,
    s.id,
    s.name as materia,
    s.code as codigo,
    a.name as area,
    s.status
FROM subjects s
LEFT JOIN areas a ON s."AreaId" = a.id
WHERE s.status = true
ORDER BY s.name
LIMIT 10;
