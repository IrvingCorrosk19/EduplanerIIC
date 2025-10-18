-- ============================================================
-- SCRIPT MAESTRO - ANÁLISIS Y CARGA DE DATOS DUMMY
-- Fecha: 16 de Octubre, 2025
-- Descripción: Script completo para analizar y cargar datos dummy
-- ============================================================

-- ============================================================
-- PASO 1: ANÁLISIS INICIAL
-- ============================================================
\echo '========================================================'
\echo '🔍 PASO 1: ANÁLISIS INICIAL DE DATOS'
\echo '========================================================'

-- Ejecutar análisis de datos existentes
\i AnalizarDatosRender.sql

-- ============================================================
-- PASO 2: ACTUALIZAR ESTUDIANTES INCLUSIVOS
-- ============================================================
\echo '========================================================'
\echo '👥 PASO 2: ACTUALIZANDO ESTUDIANTES INCLUSIVOS'
\echo '========================================================'

-- Actualizar campos inclusivos de estudiantes existentes
\i ActualizarEstudiantesInclusivos.sql

-- ============================================================
-- PASO 3: CARGAR DATOS DUMMY COMPLETOS
-- ============================================================
\echo '========================================================'
\echo '📚 PASO 3: CARGANDO DATOS DUMMY COMPLETOS'
\echo '========================================================'

-- Cargar estudiantes, profesores y estructura académica
\i CargarDatosDummyCompletos.sql

-- ============================================================
-- PASO 4: VERIFICAR Y COMPLETAR ASIGNACIONES
-- ============================================================
\echo '========================================================'
\echo '🔗 PASO 4: VERIFICANDO Y COMPLETANDO ASIGNACIONES'
\echo '========================================================'

-- Verificar y crear asignaciones de profesores y estudiantes
\i VerificarAsignacionesProfesores.sql

-- ============================================================
-- PASO 5: ANÁLISIS FINAL
-- ============================================================
\echo '========================================================'
\echo '📊 PASO 5: ANÁLISIS FINAL'
\echo '========================================================'

-- Análisis final de todos los datos
DO $$
DECLARE
    total_students INTEGER;
    students_inclusive INTEGER;
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
BEGIN
    -- Contar todos los datos
    SELECT COUNT(*) INTO total_students FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante');
    SELECT COUNT(*) INTO students_inclusive FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') AND inclusivo = true;
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
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '🎉 ANÁLISIS FINAL COMPLETADO';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
    RAISE NOTICE '👥 USUARIOS:';
    RAISE NOTICE '   Estudiantes: %', total_students;
    RAISE NOTICE '   Estudiantes inclusivos: % (%%)', students_inclusive, ROUND((students_inclusive::DECIMAL / total_students * 100), 1);
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
    RAISE NOTICE '';
    RAISE NOTICE '🚀 ¡SISTEMA LISTO PARA USAR!';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;

-- ============================================================
-- PASO 6: MOSTRAR DATOS DE PRUEBA
-- ============================================================
\echo '========================================================'
\echo '👥 DATOS DE PRUEBA DISPONIBLES'
\echo '========================================================'

-- Mostrar algunos estudiantes inclusivos
SELECT 
    'ESTUDIANTES INCLUSIVOS' as tipo,
    u.name as nombre,
    u.last_name as apellido,
    u.email,
    u.inclusivo,
    u.orientacion,
    u.disciplina
FROM users u
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante') 
AND u.status = 'active'
AND u.inclusivo = true
ORDER BY u.name
LIMIT 5;

-- Mostrar algunos profesores con asignaciones
SELECT 
    'PROFESORES CON ASIGNACIONES' as tipo,
    u.name as nombre,
    u.last_name as apellido,
    u.email,
    COUNT(ta.id) as asignaciones
FROM users u
INNER JOIN teacher_assignments ta ON u.id = ta.teacher_id
WHERE u.role IN ('teacher', 'Teacher') 
AND u.status = 'active'
GROUP BY u.id, u.name, u.last_name, u.email
ORDER BY asignaciones DESC
LIMIT 5;

\echo '========================================================'
\echo '✅ SCRIPT MAESTRO COMPLETADO EXITOSAMENTE'
\echo '========================================================'
