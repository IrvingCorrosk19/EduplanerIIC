-- ============================================================
-- GENERAR ASISTENCIAS Y REPORTES DE DISCIPLINA EN RENDER (CORREGIDO)
-- Fecha: 18 de Octubre, 2025
-- ============================================================

-- ============================================================
-- PASO 1: Generar registros de asistencia
-- ============================================================
INSERT INTO attendance (id, student_id, grade_id, group_id, teacher_id, date, status, created_at, created_by, school_id)
SELECT 
    gen_random_uuid(),
    sa.student_id,
    sa.grade_id,
    sa.group_id,
    (SELECT id FROM users WHERE role IN ('teacher', 'Teacher') AND status = 'active' ORDER BY RANDOM() LIMIT 1),
    fecha.fecha_asistencia,
    CASE 
        -- 75% Presentes
        WHEN (hashtext(sa.student_id::text || fecha.fecha_asistencia::text) % 100) < 75 THEN 'Presente'
        -- 10% Ausentes
        WHEN (hashtext(sa.student_id::text || fecha.fecha_asistencia::text) % 100) < 85 THEN 'Ausente'
        -- 7% Tardanzas
        WHEN (hashtext(sa.student_id::text || fecha.fecha_asistencia::text) % 100) < 92 THEN 'Tardanza'
        -- 4% Excusas
        WHEN (hashtext(sa.student_id::text || fecha.fecha_asistencia::text) % 100) < 96 THEN 'Excusa'
        -- 4% Fugas
        ELSE 'Fuga'
    END,
    NOW(),
    (SELECT id FROM users WHERE role = 'admin' LIMIT 1),
    (SELECT id FROM schools LIMIT 1)
FROM student_assignments sa
CROSS JOIN LATERAL (
    SELECT d::date as fecha_asistencia
    FROM generate_series(
        '2025-09-22'::date,
        CURRENT_DATE,
        '1 day'::interval
    ) d
    WHERE EXTRACT(DOW FROM d) BETWEEN 1 AND 5
) AS fecha
WHERE NOT EXISTS (
    SELECT 1 FROM attendance att
    WHERE att.student_id = sa.student_id
      AND att.date = fecha.fecha_asistencia
)
ORDER BY RANDOM()
LIMIT 10000;

-- ============================================================
-- PASO 2: Generar Reportes de Disciplina
-- ============================================================
INSERT INTO discipline_reports (
    id, student_id, teacher_id, subject_id, group_id, grade_level_id,
    date, report_type, category, status, description,
    created_at, created_by, school_id
)
SELECT 
    gen_random_uuid(),
    sa.student_id,
    ta.teacher_id,
    suba.subject_id,
    sa.group_id,
    sa.grade_id,
    fecha.fecha_reporte::timestamp,
    CASE 
        WHEN (hashtext(sa.student_id::text || fecha.fecha_reporte::text) % 100) < 30 THEN 'Leve'
        WHEN (hashtext(sa.student_id::text || fecha.fecha_reporte::text) % 100) < 70 THEN 'Moderado'
        ELSE 'Grave'
    END,
    CASE 
        WHEN (hashtext(sa.student_id::text || fecha.fecha_reporte::text) % 100) < 25 THEN 'Comportamiento'
        WHEN (hashtext(sa.student_id::text || fecha.fecha_reporte::text) % 100) < 50 THEN 'Disciplina'
        WHEN (hashtext(sa.student_id::text || fecha.fecha_reporte::text) % 100) < 75 THEN 'Tardanza'
        ELSE 'Ausencia'
    END,
    CASE 
        WHEN (hashtext(sa.student_id::text || fecha.fecha_reporte::text) % 100) < 60 THEN 'Pendiente'
        WHEN (hashtext(sa.student_id::text || fecha.fecha_reporte::text) % 100) < 90 THEN 'Resuelto'
        ELSE 'En proceso'
    END,
    CASE 
        WHEN (hashtext(sa.student_id::text || fecha.fecha_reporte::text) % 100) < 25 THEN 'Uso de celular en clase sin autorización'
        WHEN (hashtext(sa.student_id::text || fecha.fecha_reporte::text) % 100) < 50 THEN 'Conversación constante durante la clase'
        WHEN (hashtext(sa.student_id::text || fecha.fecha_reporte::text) % 100) < 75 THEN 'No trajo los materiales requeridos'
        ELSE 'Llegó tarde a la clase sin justificación'
    END,
    NOW(),
    ta.teacher_id,
    (SELECT id FROM schools LIMIT 1)
FROM student_assignments sa
CROSS JOIN LATERAL (
    SELECT d::date as fecha_reporte
    FROM generate_series(
        '2025-09-22'::date,
        CURRENT_DATE,
        (CASE WHEN RANDOM() < 0.5 THEN 7 ELSE 14 END || ' days')::interval
    ) d
) AS fecha
INNER JOIN LATERAL (
    SELECT ta2.teacher_id, ta2.subject_assignment_id
    FROM teacher_assignments ta2
    INNER JOIN subject_assignments sba ON ta2.subject_assignment_id = sba.id
    WHERE sba.group_id = sa.group_id
      AND sba.grade_level_id = sa.grade_id
    ORDER BY RANDOM()
    LIMIT 1
) ta ON true
INNER JOIN subject_assignments suba ON ta.subject_assignment_id = suba.id
WHERE (hashtext(sa.student_id::text) % 100) < 40
ORDER BY RANDOM()
LIMIT 800;

-- ============================================================
-- VERIFICAR ASISTENCIAS GENERADAS
-- ============================================================
SELECT 
    'ASISTENCIAS POR ESTADO' as categoria,
    status,
    COUNT(*) as cantidad,
    ROUND((COUNT(*)::DECIMAL / (SELECT COUNT(*) FROM attendance) * 100), 2) as porcentaje
FROM attendance
GROUP BY status
ORDER BY cantidad DESC;

SELECT 
    'ASISTENCIAS POR MES' as categoria,
    TO_CHAR(date, 'YYYY-MM') as mes,
    COUNT(*) as total_registros,
    COUNT(CASE WHEN status = 'Presente' THEN 1 END) as presentes,
    COUNT(CASE WHEN status = 'Ausente' THEN 1 END) as ausentes,
    COUNT(CASE WHEN status = 'Tardanza' THEN 1 END) as tardanzas,
    COUNT(CASE WHEN status = 'Fuga' THEN 1 END) as fugas,
    COUNT(CASE WHEN status = 'Excusa' THEN 1 END) as excusas
FROM attendance
GROUP BY mes
ORDER BY mes DESC
LIMIT 5;

-- ============================================================
-- VERIFICAR REPORTES DE DISCIPLINA
-- ============================================================
SELECT 
    'REPORTES POR TIPO' as categoria,
    report_type,
    COUNT(*) as cantidad,
    ROUND((COUNT(*)::DECIMAL / (SELECT COUNT(*) FROM discipline_reports) * 100), 2) as porcentaje
FROM discipline_reports
GROUP BY report_type
ORDER BY cantidad DESC;

SELECT 
    'REPORTES POR CATEGORÍA' as categoria,
    category,
    COUNT(*) as cantidad
FROM discipline_reports
GROUP BY category
ORDER BY cantidad DESC;

SELECT 
    'REPORTES POR ESTADO' as categoria,
    status,
    COUNT(*) as cantidad
FROM discipline_reports
GROUP BY status
ORDER BY cantidad DESC;

-- ============================================================
-- TOP ESTUDIANTES CON MÁS REPORTES
-- ============================================================
SELECT 
    'TOP 10 ESTUDIANTES CON MÁS REPORTES' as categoria,
    u.name || ' ' || u.last_name as estudiante,
    u.email,
    COUNT(dr.id) as total_reportes,
    STRING_AGG(DISTINCT dr.category, ', ') as categorias
FROM users u
INNER JOIN discipline_reports dr ON u.id = dr.student_id
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
GROUP BY u.id, u.name, u.last_name, u.email
ORDER BY total_reportes DESC
LIMIT 10;

-- ============================================================
-- RESUMEN FINAL
-- ============================================================
DO $$
DECLARE
    v_total_estudiantes INTEGER;
    v_total_asistencias INTEGER;
    v_total_reportes INTEGER;
    v_estudiantes_con_asistencia INTEGER;
    v_estudiantes_con_reportes INTEGER;
    v_presentes INTEGER;
    v_ausentes INTEGER;
    v_tardanzas INTEGER;
    v_fugas INTEGER;
    v_excusas INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_total_estudiantes FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') AND status = 'active';
    SELECT COUNT(*) INTO v_total_asistencias FROM attendance;
    SELECT COUNT(*) INTO v_total_reportes FROM discipline_reports;
    SELECT COUNT(DISTINCT student_id) INTO v_estudiantes_con_asistencia FROM attendance;
    SELECT COUNT(DISTINCT student_id) INTO v_estudiantes_con_reportes FROM discipline_reports;
    
    SELECT COUNT(*) INTO v_presentes FROM attendance WHERE status = 'Presente';
    SELECT COUNT(*) INTO v_ausentes FROM attendance WHERE status = 'Ausente';
    SELECT COUNT(*) INTO v_tardanzas FROM attendance WHERE status = 'Tardanza';
    SELECT COUNT(*) INTO v_fugas FROM attendance WHERE status = 'Fuga';
    SELECT COUNT(*) INTO v_excusas FROM attendance WHERE status = 'Excusa';
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'ASISTENCIAS Y REPORTES GENERADOS EXITOSAMENTE';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'Total de estudiantes: %', v_total_estudiantes;
    RAISE NOTICE '';
    RAISE NOTICE 'ASISTENCIAS:';
    RAISE NOTICE '  Total de registros: %', v_total_asistencias;
    RAISE NOTICE '  Estudiantes con asistencia: %', v_estudiantes_con_asistencia;
    RAISE NOTICE '  Cobertura: %%', ROUND((v_estudiantes_con_asistencia::DECIMAL / v_total_estudiantes * 100), 2);
    RAISE NOTICE '  - Presentes: % (%%)', v_presentes, ROUND((v_presentes::DECIMAL / v_total_asistencias * 100), 2);
    RAISE NOTICE '  - Ausentes: % (%%)', v_ausentes, ROUND((v_ausentes::DECIMAL / v_total_asistencias * 100), 2);
    RAISE NOTICE '  - Tardanzas: % (%%)', v_tardanzas, ROUND((v_tardanzas::DECIMAL / v_total_asistencias * 100), 2);
    RAISE NOTICE '  - Fugas: % (%%)', v_fugas, ROUND((v_fugas::DECIMAL / v_total_asistencias * 100), 2);
    RAISE NOTICE '  - Excusas: % (%%)', v_excusas, ROUND((v_excusas::DECIMAL / v_total_asistencias * 100), 2);
    RAISE NOTICE '';
    RAISE NOTICE 'REPORTES DE DISCIPLINA:';
    RAISE NOTICE '  Total de reportes: %', v_total_reportes;
    RAISE NOTICE '  Estudiantes con reportes: %', v_estudiantes_con_reportes;
    RAISE NOTICE '  Cobertura: %%', ROUND((v_estudiantes_con_reportes::DECIMAL / v_total_estudiantes * 100), 2);
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;
