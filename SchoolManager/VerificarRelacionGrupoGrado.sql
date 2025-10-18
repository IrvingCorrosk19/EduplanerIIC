-- Verificar relación entre grupos, grados y actividades

-- Grupo y grado de Alejandro
SELECT 
    '1. GRUPO Y GRADO DE ALEJANDRO' as paso,
    sa.group_id,
    sa.grade_id,
    g.grade as grade_name,
    g.name as grupo_name,
    gl.name as nivel_nombre
FROM student_assignments sa
INNER JOIN users u ON sa.student_id = u.id
INNER JOIN groups g ON sa.group_id = g.id
INNER JOIN grade_levels gl ON sa.grade_id = gl.id
WHERE u.email = 'alejandro.moreno@estudiante.edu.pa';

-- Actividades del grupo E2
SELECT 
    '2. ACTIVIDADES DEL GRUPO E2' as paso,
    a.id,
    a.type,
    a.name,
    a.group_id,
    a.grade_level_id,
    g.name as grupo_name
FROM activities a
INNER JOIN groups g ON a.group_id = g.id
WHERE g.name = 'E2'
  AND a.type IN ('Notas de apreciación', 'Ejercicios diarios', 'Examen Final')
LIMIT 10;

-- Comparar IDs
SELECT 
    '3. COMPARACIÓN DE IDs' as paso,
    'Alejandro grade_id' as origen,
    sa.grade_id as id
FROM student_assignments sa
INNER JOIN users u ON sa.student_id = u.id
WHERE u.email = 'alejandro.moreno@estudiante.edu.pa'
UNION ALL
SELECT 
    '3. COMPARACIÓN DE IDs',
    'Actividades grade_level_id',
    a.grade_level_id
FROM activities a
INNER JOIN groups g ON a.group_id = g.id
WHERE g.name = 'E2'
  AND a.type = 'Notas de apreciación'
LIMIT 1;

-- Buscar actividades sin importar el grade_level_id
SELECT 
    '4. ACTIVIDADES DEL GRUPO E2 (IGNORANDO GRADE_LEVEL_ID)' as paso,
    COUNT(*) as total_actividades,
    STRING_AGG(DISTINCT a.type, ', ') as tipos
FROM activities a
INNER JOIN groups g ON a.group_id = g.id
WHERE g.name = 'E2'
  AND a.type IN ('Notas de apreciación', 'Ejercicios diarios', 'Examen Final');

-- Insertar calificaciones SIN filtrar por grade_level_id
INSERT INTO student_activity_scores (id, student_id, activity_id, score, created_at, created_by, school_id)
SELECT 
    gen_random_uuid(),
    u.id,
    a.id,
    3.5 + (RANDOM() * 1.5),
    NOW(),
    (SELECT id FROM users WHERE role = 'admin' LIMIT 1),
    (SELECT id FROM schools LIMIT 1)
FROM users u
CROSS JOIN activities a
INNER JOIN groups g ON a.group_id = g.id
WHERE u.email = 'alejandro.moreno@estudiante.edu.pa'
  AND g.name = 'E2'
  AND a.type IN ('Notas de apreciación', 'Ejercicios diarios', 'Examen Final')
  AND NOT EXISTS (
      SELECT 1 FROM student_activity_scores sas 
      WHERE sas.student_id = u.id AND sas.activity_id = a.id
  )
LIMIT 100;

-- Verificar
SELECT 
    '5. VERIFICACIÓN DESPUÉS DE INSERTAR' as paso,
    a.type,
    COUNT(sas.id) as cantidad
FROM student_activity_scores sas
INNER JOIN activities a ON sas.activity_id = a.id
INNER JOIN users u ON sas.student_id = u.id
WHERE u.email = 'alejandro.moreno@estudiante.edu.pa'
  AND a.type IN ('Notas de apreciación', 'Ejercicios diarios', 'Examen Final')
GROUP BY a.type;
