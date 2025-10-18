-- Diagnóstico completo de Alejandro Moreno

-- 1. Datos básicos del estudiante
SELECT '1. DATOS DEL ESTUDIANTE' as paso;
SELECT id, name, last_name, email, document_id FROM users WHERE email = 'alejandro.moreno@estudiante.edu.pa';

-- 2. Asignación de grupo
SELECT '2. ASIGNACIÓN DE GRUPO' as paso;
SELECT sa.*, g.grade, g.name as grupo_name, gl.name as grade_name
FROM student_assignments sa
INNER JOIN users u ON sa.student_id = u.id
INNER JOIN groups g ON sa.group_id = g.id
INNER JOIN grade_levels gl ON sa.grade_id = gl.id
WHERE u.email = 'alejandro.moreno@estudiante.edu.pa';

-- 3. Actividades en su grupo con tipos exactos
SELECT '3. ACTIVIDADES EN SU GRUPO (TIPO EXACTO)' as paso;
SELECT a.id, a.type, a.name, s.name as materia, a.trimester
FROM activities a
INNER JOIN subjects s ON a.subject_id = s.id
WHERE a.group_id IN (
    SELECT sa.group_id FROM student_assignments sa
    INNER JOIN users u ON sa.student_id = u.id
    WHERE u.email = 'alejandro.moreno@estudiante.edu.pa'
)
AND a.grade_level_id IN (
    SELECT sa.grade_id FROM student_assignments sa
    INNER JOIN users u ON sa.student_id = u.id
    WHERE u.email = 'alejandro.moreno@estudiante.edu.pa'
)
AND a.type IN ('Notas de apreciación', 'Ejercicios diarios', 'Examen Final')
ORDER BY s.name, a.type
LIMIT 50;

-- 4. Intentar insertar UNA calificación para Alejandro
INSERT INTO student_activity_scores (id, student_id, activity_id, score, created_at, created_by, school_id)
SELECT 
    gen_random_uuid(),
    u.id,
    a.id,
    4.5,
    NOW(),
    a.teacher_id,
    (SELECT id FROM schools LIMIT 1)
FROM users u
CROSS JOIN activities a
WHERE u.email = 'alejandro.moreno@estudiante.edu.pa'
  AND a.type = 'Notas de apreciación'
  AND a.group_id IN (
      SELECT sa.group_id FROM student_assignments sa WHERE sa.student_id = u.id
  )
  AND a.grade_level_id IN (
      SELECT sa.grade_id FROM student_assignments sa WHERE sa.student_id = u.id
  )
  AND NOT EXISTS (
      SELECT 1 FROM student_activity_scores sas 
      WHERE sas.student_id = u.id AND sas.activity_id = a.id
  )
LIMIT 1
RETURNING *;

-- 5. Verificar si se insertó
SELECT '5. VERIFICAR INSERCIÓN' as paso;
SELECT COUNT(*) as calificaciones_con_tipos_nuevos
FROM student_activity_scores sas
INNER JOIN activities a ON sas.activity_id = a.id
INNER JOIN users u ON sas.student_id = u.id
WHERE u.email = 'alejandro.moreno@estudiante.edu.pa'
  AND a.type IN ('Notas de apreciación', 'Ejercicios diarios', 'Examen Final');
