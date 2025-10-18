-- Verificar si Alejandro Moreno tiene calificaciones con tipos nuevos
SELECT 
    'CALIFICACIONES DE ALEJANDRO CON TIPOS NUEVOS' as categoria,
    a.type,
    s.name as materia,
    COUNT(sas.id) as cantidad_notas,
    ROUND(AVG(sas.score), 2) as promedio
FROM student_activity_scores sas
INNER JOIN activities a ON sas.activity_id = a.id
INNER JOIN subjects s ON a.subject_id = s.id
INNER JOIN users u ON sas.student_id = u.id
WHERE u.email = 'alejandro.moreno@estudiante.edu.pa'
  AND (LOWER(a.type) LIKE '%nota%' OR LOWER(a.type) LIKE '%apreciaci%'
       OR LOWER(a.type) LIKE '%ejercicio%' OR LOWER(a.type) LIKE '%diario%'
       OR LOWER(a.type) LIKE '%examen%' OR LOWER(a.type) LIKE '%final%')
GROUP BY a.type, s.name
ORDER BY s.name, a.type;

-- Ver total de calificaciones con tipos nuevos
SELECT 
    'RESUMEN TIPOS NUEVOS - ALEJANDRO' as categoria,
    COUNT(sas.id) as total_calificaciones,
    ROUND(AVG(sas.score), 2) as promedio
FROM student_activity_scores sas
INNER JOIN activities a ON sas.activity_id = a.id
INNER JOIN users u ON sas.student_id = u.id
WHERE u.email = 'alejandro.moreno@estudiante.edu.pa'
  AND (LOWER(a.type) LIKE '%nota%' OR LOWER(a.type) LIKE '%apreciaci%'
       OR LOWER(a.type) LIKE '%ejercicio%' OR LOWER(a.type) LIKE '%diario%'
       OR LOWER(a.type) LIKE '%examen%' OR LOWER(a.type) LIKE '%final%');

-- Ver actividades disponibles para Alejandro con tipos nuevos
SELECT 
    'ACTIVIDADES DISPONIBLES CON TIPOS NUEVOS' as categoria,
    a.type,
    s.name as materia,
    COUNT(a.id) as cantidad_actividades
FROM activities a
INNER JOIN subjects s ON a.subject_id = s.id
WHERE a.group_id IN (
    SELECT sa.group_id FROM student_assignments sa
    INNER JOIN users u ON sa.student_id = u.id
    WHERE u.email = 'alejandro.moreno@estudiante.edu.pa'
)
AND (LOWER(a.type) LIKE '%nota%' OR LOWER(a.type) LIKE '%apreciaci%'
     OR LOWER(a.type) LIKE '%ejercicio%' OR LOWER(a.type) LIKE '%diario%'
     OR LOWER(a.type) LIKE '%examen%' OR LOWER(a.type) LIKE '%final%')
GROUP BY a.type, s.name
ORDER BY s.name, a.type;
