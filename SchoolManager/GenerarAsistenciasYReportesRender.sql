-- ============================================================
-- GENERAR ASISTENCIAS Y REPORTES DE DISCIPLINA EN RENDER
-- Fecha: 18 de Octubre, 2025
-- Tipos de asistencia: Presente, Ausente, Tardanza, Fuga, Excusa
-- ============================================================

-- ============================================================
-- PASO 1: Verificar trimestre activo
-- ============================================================
SELECT 
    'TRIMESTRES ACTIVOS' as categoria,
    name,
    start_date,
    end_date,
    is_active
FROM trimester
WHERE is_active = true;

-- ============================================================
-- PASO 2: Generar registros de asistencia
-- ============================================================
INSERT INTO attendance (id, student_id, subject_id, grade_level_id, group_id, teacher_id, date, status, notes, created_at, created_by, school_id)
SELECT 
    gen_random_uuid(),
    sa.student_id,
    sub.id,
    sa.grade_id,
    sa.group_id,
    ta.teacher_id,
    fecha.fecha_asistencia,
    CASE 
        -- Distribución realista de asistencia
        WHEN (hashtext(sa.student_id::text || fecha.fecha_asistencia::text || sub.id::text) % 100) < 75 THEN 'Presente'
        WHEN (hashtext(sa.student_id::text || fecha.fecha_asistencia::text || sub.id::text) % 100) < 85 THEN 'Ausente'
        WHEN (hashtext(sa.student_id::text || fecha.fecha_asistencia::text || sub.id::text) % 100) < 92 THEN 'Tardanza'
        WHEN (hashtext(sa.student_id::text || fecha.fecha_asistencia::text || sub.id::text) % 100) < 96 THEN 'Excusa'
        ELSE 'Fuga'
    END,
    CASE 
        WHEN (hashtext(sa.student_id::text || fecha.fecha_asistencia::text || sub.id::text) % 100) >= 75 
        THEN 'Registro automático de asistencia'
        ELSE NULL
    END,
    NOW(),
    ta.teacher_id,
    (SELECT id FROM schools LIMIT 1)
FROM student_assignments sa
CROSS JOIN LATERAL (
    SELECT generate_series(
        '2025-03-01'::date,
        '2025-11-30'::date,
        '1 day'::interval
    )::date as fecha_asistencia
    WHERE EXTRACT(DOW FROM generate_series) BETWEEN 1 AND 5
) AS fecha
INNER JOIN teacher_assignments ta ON EXISTS (
    SELECT 1 FROM subject_assignments sba 
    WHERE sba.group_id = sa.group_id 
      AND sba.grade_level_id = sa.grade_id
      AND ta.subject_assignment_id = sba.id
    LIMIT 1
)
CROSS JOIN LATERAL (
    SELECT sba.subject_id as id
    FROM subject_assignments sba
    WHERE sba.group_id = sa.group_id
      AND sba.grade_level_id = sa.grade_id
      AND ta.subject_assignment_id = sba.id
    LIMIT 1
) AS sub
WHERE NOT EXISTS (
    SELECT 1 FROM attendance att
    WHERE att.student_id = sa.student_id
      AND att.date = fecha.fecha_asistencia
      AND att.subject_id = sub.id
)
ORDER BY RANDOM()
LIMIT 20000;

-- ============================================================
-- PASO 3: Generar Reportes de Disciplina
-- ============================================================
INSERT INTO discipline_reports (
    id, student_id, teacher_id, subject_id, group_id, grade_level_id, 
    date, time, report_type, category, status, description, 
    created_at, created_by, school_id
)
SELECT 
    gen_random_uuid(),
    sa.student_id,
    ta.teacher_id,
    sub.id,
    sa.group_id,
    sa.grade_id,
    fecha.fecha_reporte,
    CASE 
        WHEN (hashtext(sa.student_id::text || fecha.fecha_reporte::text) % 100) < 50 THEN '08:30'
        WHEN (hashtext(sa.student_id::text || fecha.fecha_reporte::text) % 100) < 75 THEN '10:15'
        ELSE '14:00'
    END,
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
    SELECT generate_series(
        '2025-03-01'::date,
        CURRENT_DATE,
        (CASE WHEN RANDOM() < 0.3 THEN 7 ELSE 14 END || ' days')::interval
    )::date as fecha_reporte
) AS fecha
INNER JOIN teacher_assignments ta ON EXISTS (
    SELECT 1 FROM subject_assignments sba 
    WHERE sba.group_id = sa.group_id 
      AND sba.grade_level_id = sa.grade_id
      AND ta.subject_assignment_id = sba.id
    LIMIT 1
)
CROSS JOIN LATERAL (
    SELECT sba.subject_id as id
    FROM subject_assignments sba
    WHERE sba.group_id = sa.group_id
      AND sba.grade_level_id = sa.grade_id
      AND ta.subject_assignment_id = sba.id
    LIMIT 1
) AS sub
WHERE (hashtext(sa.student_id::text) % 100) < 40
ORDER BY RANDOM()
LIMIT 500;

-- ============================================================
-- PASO 4: Verificar asistencias generadas
-- ============================================================
SELECT 
    'ASISTENCIAS POR ESTADO' as categoria,
    status,
    COUNT(*) as cantidad,
    ROUND((COUNT(*)::DECIMAL / (SELECT COUNT(*) FROM attendance) * 100), 2) as porcentaje
FROM attendance
GROUP BY status
ORDER BY cantidad DESC;

-- ============================================================
-- PASO 5: Verificar reportes de disciplina
-- ============================================================
SELECT 
    'REPORTES POR TIPO' as categoria,
    report_type,
    COUNT(*) as cantidad
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

-- ============================================================
-- PASO 6: Estudiantes con más reportes
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
    RAISE NOTICE 'ASISTENCIAS Y REPORTES GENERADOS';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'Total de estudiantes: %', v_total_estudiantes;
    RAISE NOTICE '';
    RAISE NOTICE 'ASISTENCIAS:';
    RAISE NOTICE '  Total de registros: %', v_total_asistencias;
    RAISE NOTICE '  Estudiantes con asistencia: %', v_estudiantes_con_asistencia;
    RAISE NOTICE '  - Presentes: %', v_presentes;
    RAISE NOTICE '  - Ausentes: %', v_ausentes;
    RAISE NOTICE '  - Tardanzas: %', v_tardanzas;
    RAISE NOTICE '  - Fugas: %', v_fugas;
    RAISE NOTICE '  - Excusas: %', v_excusas;
    RAISE NOTICE '';
    RAISE NOTICE 'REPORTES DE DISCIPLINA:';
    RAISE NOTICE '  Total de reportes: %', v_total_reportes;
    RAISE NOTICE '  Estudiantes con reportes: %', v_estudiantes_con_reportes;
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;
