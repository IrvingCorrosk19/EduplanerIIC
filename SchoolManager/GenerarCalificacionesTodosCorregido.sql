-- ============================================================
-- GENERAR CALIFICACIONES PARA TODOS (SIN FILTRO DE GRADE_LEVEL)
-- ============================================================

-- Insertar calificaciones para TODOS los estudiantes
INSERT INTO student_activity_scores (id, student_id, activity_id, score, created_at, created_by, school_id)
SELECT 
    gen_random_uuid(),
    u.id,
    a.id,
    CASE 
        WHEN (hashtext(u.id::text || a.id::text) % 100) < 10 THEN 1.0 + (ABS(hashtext(u.id::text || a.id::text) % 10) / 10.0) * 1.5
        WHEN (hashtext(u.id::text || a.id::text) % 100) < 30 THEN 2.0 + (ABS(hashtext(u.id::text || a.id::text) % 10) / 10.0) * 1.0
        WHEN (hashtext(u.id::text || a.id::text) % 100) < 50 THEN 2.7 + (ABS(hashtext(u.id::text || a.id::text) % 10) / 10.0) * 0.8
        WHEN (hashtext(u.id::text || a.id::text) % 100) < 75 THEN 3.3 + (ABS(hashtext(u.id::text || a.id::text) % 10) / 10.0) * 0.7
        ELSE 4.0 + (ABS(hashtext(u.id::text || a.id::text) % 10) / 20.0) * 1.0
    END,
    NOW(),
    (SELECT id FROM users WHERE role = 'admin' LIMIT 1),
    (SELECT id FROM schools LIMIT 1)
FROM users u
CROSS JOIN activities a
INNER JOIN groups g ON a.group_id = g.id
INNER JOIN student_assignments sa ON sa.student_id = u.id AND sa.group_id = a.group_id
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
  AND u.status = 'active'
  AND a.type IN ('Notas de apreciación', 'Ejercicios diarios', 'Examen Final')
  AND NOT EXISTS (
      SELECT 1 FROM student_activity_scores sas 
      WHERE sas.student_id = u.id AND sas.activity_id = a.id
  )
ORDER BY u.id, a.id;

-- Verificar cobertura final
SELECT 
    'COBERTURA FINAL - TIPOS NUEVOS' as categoria,
    COUNT(DISTINCT u.id) as total_estudiantes,
    COUNT(DISTINCT CASE WHEN tiene_notas THEN u.id END) as con_notas_apreciacion,
    COUNT(DISTINCT CASE WHEN tiene_ejercicios THEN u.id END) as con_ejercicios,
    COUNT(DISTINCT CASE WHEN tiene_examenes THEN u.id END) as con_examenes,
    COUNT(DISTINCT CASE WHEN tiene_los_3 THEN u.id END) as con_los_3_tipos
FROM users u
CROSS JOIN LATERAL (
    SELECT 
        EXISTS (SELECT 1 FROM student_activity_scores sas INNER JOIN activities a ON sas.activity_id = a.id WHERE sas.student_id = u.id AND a.type = 'Notas de apreciación') as tiene_notas,
        EXISTS (SELECT 1 FROM student_activity_scores sas INNER JOIN activities a ON sas.activity_id = a.id WHERE sas.student_id = u.id AND a.type = 'Ejercicios diarios') as tiene_ejercicios,
        EXISTS (SELECT 1 FROM student_activity_scores sas INNER JOIN activities a ON sas.activity_id = a.id WHERE sas.student_id = u.id AND a.type = 'Examen Final') as tiene_examenes,
        EXISTS (SELECT 1 FROM student_activity_scores sas INNER JOIN activities a ON sas.activity_id = a.id WHERE sas.student_id = u.id AND a.type = 'Notas de apreciación')
        AND EXISTS (SELECT 1 FROM student_activity_scores sas INNER JOIN activities a ON sas.activity_id = a.id WHERE sas.student_id = u.id AND a.type = 'Ejercicios diarios')
        AND EXISTS (SELECT 1 FROM student_activity_scores sas INNER JOIN activities a ON sas.activity_id = a.id WHERE sas.student_id = u.id AND a.type = 'Examen Final') as tiene_los_3
) AS check_tipos
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
  AND u.status = 'active';

-- Ver muestra de estudiantes con notas
SELECT 
    'TOP 15 ESTUDIANTES CON TIPOS NUEVOS' as categoria,
    u.name || ' ' || u.last_name as estudiante,
    COUNT(CASE WHEN a.type = 'Notas de apreciación' THEN 1 END) as notas,
    COUNT(CASE WHEN a.type = 'Ejercicios diarios' THEN 1 END) as ejercicios,
    COUNT(CASE WHEN a.type = 'Examen Final' THEN 1 END) as examenes,
    COUNT(sas.id) as total,
    ROUND(AVG(sas.score), 2) as promedio
FROM users u
INNER JOIN student_activity_scores sas ON u.id = sas.student_id
INNER JOIN activities a ON sas.activity_id = a.id
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
  AND a.type IN ('Notas de apreciación', 'Ejercicios diarios', 'Examen Final')
GROUP BY u.id, u.name, u.last_name
ORDER BY promedio DESC
LIMIT 15;

-- Resumen
SELECT 
    'RESUMEN FINAL' as categoria,
    (SELECT COUNT(*) FROM users WHERE role IN ('student', 'Student', 'estudiante', 'Estudiante') AND status = 'active') as total_estudiantes,
    COUNT(DISTINCT sas.student_id) as estudiantes_con_notas_nuevas,
    COUNT(sas.id) as total_calificaciones_nuevas,
    ROUND(AVG(sas.score), 2) as promedio_general
FROM student_activity_scores sas
INNER JOIN activities a ON sas.activity_id = a.id
WHERE a.type IN ('Notas de apreciación', 'Ejercicios diarios', 'Examen Final');
