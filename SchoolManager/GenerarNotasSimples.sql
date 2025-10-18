-- ============================================================
-- GENERAR NOTAS SIMPLES CON APROBADOS Y REPROBADOS
-- Fecha: 16 de Octubre, 2025
-- Descripción: Genera notas usando una función simple
-- ============================================================

-- ============================================================
-- PASO 1: Limpiar notas existentes
-- ============================================================
DELETE FROM student_activity_scores;

-- ============================================================
-- PASO 2: Generar notas usando una función simple
-- ============================================================
INSERT INTO student_activity_scores (
    id, student_id, activity_id, score, created_at, created_by, school_id
)
SELECT 
    uuid_generate_v4(),
    u.id,
    a.id,
    CASE 
        -- Usar el hash del ID para determinar la distribución
        WHEN (hashtext(u.id::text) % 100) < 10 THEN 0.5 + (hashtext(u.id::text) % 100) / 100.0  -- 10% notas muy bajas (0.5-1.5)
        WHEN (hashtext(u.id::text) % 100) < 30 THEN 1.5 + (hashtext(u.id::text) % 100) / 100.0  -- 20% notas bajas (1.5-2.5)
        WHEN (hashtext(u.id::text) % 100) < 60 THEN 2.5 + (hashtext(u.id::text) % 100) / 100.0  -- 30% notas regulares (2.5-3.5)
        WHEN (hashtext(u.id::text) % 100) < 85 THEN 3.5 + (hashtext(u.id::text) % 100) / 100.0  -- 25% notas buenas (3.5-4.5)
        ELSE 4.5 + (hashtext(u.id::text) % 100) / 200.0  -- 15% notas excelentes (4.5-5.0)
    END as nota,
    NOW(),
    a.teacher_id,
    (SELECT id FROM schools LIMIT 1)
FROM users u
CROSS JOIN activities a
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
AND u.status = 'active'
ORDER BY u.id, a.id
LIMIT 15000; -- Generar 15000 calificaciones

-- ============================================================
-- PASO 3: Verificar resultados
-- ============================================================
SELECT 
    'DISTRIBUCIÓN DE NOTAS' as categoria,
    COUNT(*) as total_calificaciones,
    ROUND(AVG(score), 2) as promedio_general,
    ROUND(MIN(score), 2) as nota_minima,
    ROUND(MAX(score), 2) as nota_maxima,
    COUNT(CASE WHEN score >= 3.0 THEN 1 END) as notas_aprobadas,
    COUNT(CASE WHEN score < 3.0 THEN 1 END) as notas_reprobadas,
    ROUND(COUNT(CASE WHEN score >= 3.0 THEN 1 END)::DECIMAL / COUNT(*) * 100, 2) as porcentaje_aprobadas,
    ROUND(COUNT(CASE WHEN score < 3.0 THEN 1 END)::DECIMAL / COUNT(*) * 100, 2) as porcentaje_reprobadas
FROM student_activity_scores;

-- ============================================================
-- PASO 4: Verificar estudiantes aprobados y reprobados
-- ============================================================
SELECT 
    'ESTUDIANTES APROBADOS Y REPROBADOS' as categoria,
    COUNT(DISTINCT student_id) as total_estudiantes,
    COUNT(DISTINCT CASE WHEN promedio >= 3.0 THEN student_id END) as aprobados,
    COUNT(DISTINCT CASE WHEN promedio < 3.0 THEN student_id END) as reprobados,
    ROUND(COUNT(DISTINCT CASE WHEN promedio >= 3.0 THEN student_id END)::DECIMAL / COUNT(DISTINCT student_id) * 100, 2) as porcentaje_aprobados,
    ROUND(COUNT(DISTINCT CASE WHEN promedio < 3.0 THEN student_id END)::DECIMAL / COUNT(DISTINCT student_id) * 100, 2) as porcentaje_reprobados
FROM (
    SELECT 
        student_id,
        AVG(score) as promedio
    FROM student_activity_scores
    GROUP BY student_id
) as promedios;

-- ============================================================
-- PASO 5: Mostrar estudiantes aprobados
-- ============================================================
SELECT 
    'ESTUDIANTES APROBADOS (≥3.0)' as categoria,
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
HAVING AVG(sas.score) >= 3.0
ORDER BY promedio DESC
LIMIT 15;

-- ============================================================
-- PASO 6: Mostrar estudiantes reprobados
-- ============================================================
SELECT 
    'ESTUDIANTES REPROBADOS (<3.0)' as categoria,
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
HAVING AVG(sas.score) < 3.0
ORDER BY promedio ASC
LIMIT 15;
