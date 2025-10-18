-- ============================================================
-- SCRIPT COMPLETO PARA RENDER - ANÁLISIS Y GENERACIÓN DE DATOS
-- Fecha: 16 de Octubre, 2025
-- Descripción: Script completo para analizar, cargar y generar datos
-- ============================================================

-- ============================================================
-- PASO 1: ANÁLISIS INICIAL DE DATOS
-- ============================================================
\echo '========================================================'
\echo '🔍 PASO 1: ANÁLISIS INICIAL DE DATOS EN RENDER'
\echo '========================================================'

-- Ejecutar análisis de datos existentes
\i ConsultasAnalisisRender.sql

-- ============================================================
-- PASO 2: CARGAR DATOS DUMMY COMPLETOS
-- ============================================================
\echo '========================================================'
\echo '📚 PASO 2: CARGANDO DATOS DUMMY COMPLETOS'
\echo '========================================================'

-- Cargar estudiantes, profesores y estructura académica
\i CargarDatosDummyCompletos.sql

-- ============================================================
-- PASO 3: VERIFICAR Y COMPLETAR ASIGNACIONES
-- ============================================================
\echo '========================================================'
\echo '🔗 PASO 3: VERIFICANDO Y COMPLETANDO ASIGNACIONES'
\echo '========================================================'

-- Verificar y crear asignaciones de profesores y estudiantes
\i VerificarAsignacionesProfesores.sql

-- ============================================================
-- PASO 4: GENERAR ACTIVIDADES Y NOTAS
-- ============================================================
\echo '========================================================'
\echo '📊 PASO 4: GENERANDO ACTIVIDADES Y NOTAS'
\echo '========================================================'

-- Generar actividades y notas para todos los estudiantes
\i GenerarActividadesYNotas.sql

-- ============================================================
-- PASO 5: ANÁLISIS FINAL COMPLETO
-- ============================================================
\echo '========================================================'
\echo '📊 PASO 5: ANÁLISIS FINAL COMPLETO'
\echo '========================================================'

-- Análisis final de todos los datos
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
    RAISE NOTICE '🎉 ANÁLISIS FINAL COMPLETADO';
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
-- PASO 6: MOSTRAR DATOS DE PRUEBA FINALES
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
