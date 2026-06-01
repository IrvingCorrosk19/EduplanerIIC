-- SOLO LECTURA - Análisis forense trudykir@live.com
\set ON_ERROR_STOP on

\echo '=== USUARIO ==='
SELECT id, email, role, school_id, status, name, last_name
FROM users
WHERE LOWER(email) = LOWER('trudykir@live.com');

\echo '=== ESCUELA ==='
SELECT s.id, s.name
FROM schools s
WHERE s.id = (SELECT school_id FROM users WHERE LOWER(email) = LOWER('trudykir@live.com') LIMIT 1);

\echo '=== TEACHER_ASSIGNMENTS + SUBJECT_ASSIGNMENTS + GRUPOS ==='
SELECT ta.id AS ta_id, ta.teacher_id, sa.id AS subject_assignment_id,
       sub.name AS materia, g.id AS group_id, g.name AS grupo, g.grade AS grado_grupo,
       gl.name AS grado_nivel, sp.name AS especialidad, sa.status AS sa_status
FROM teacher_assignments ta
JOIN subject_assignments sa ON sa.id = ta.subject_assignment_id
JOIN subjects sub ON sub.id = sa.subject_id
JOIN groups g ON g.id = sa.group_id
JOIN grade_levels gl ON gl.id = sa.grade_level_id
LEFT JOIN specialties sp ON sp.id = sa.specialty_id
WHERE ta.teacher_id = (SELECT id FROM users WHERE LOWER(email) = LOWER('trudykir@live.com') LIMIT 1)
ORDER BY g.grade, g.name, sub.name;

\echo '=== GRUPOS DISTINTOS DEL DOCENTE (via subject_assignments) ==='
SELECT DISTINCT g.id, g.name, g.grade
FROM teacher_assignments ta
JOIN subject_assignments sa ON sa.id = ta.subject_assignment_id
JOIN groups g ON g.id = sa.group_id
WHERE ta.teacher_id = (SELECT id FROM users WHERE LOWER(email) = LOWER('trudykir@live.com') LIMIT 1)
ORDER BY g.grade, g.name;

\echo '=== MATERIAS DEL DOCENTE ==='
SELECT DISTINCT sub.id, sub.name
FROM teacher_assignments ta
JOIN subject_assignments sa ON sa.id = ta.subject_assignment_id
JOIN subjects sub ON sub.id = sa.subject_id
WHERE ta.teacher_id = (SELECT id FROM users WHERE LOWER(email) = LOWER('trudykir@live.com') LIMIT 1)
ORDER BY sub.name;

\echo '=== USER_GROUPS (si aplica) ==='
SELECT ug.user_id, ug.group_id, g.name, g.grade
FROM user_groups ug
JOIN groups g ON g.id = ug.group_id
WHERE ug.user_id = (SELECT id FROM users WHERE LOWER(email) = LOWER('trudykir@live.com') LIMIT 1);

\echo '=== USER_SUBJECTS ==='
SELECT us.user_id, us.subject_id, s.name
FROM user_subjects us
JOIN subjects s ON s.id = us.subject_id
WHERE us.user_id = (SELECT id FROM users WHERE LOWER(email) = LOWER('trudykir@live.com') LIMIT 1);

\echo '=== TODOS GRUPOS ESCUELA (reporte sin filtro docente) ==='
SELECT g.id, g.name, g.grade
FROM groups g
WHERE g.school_id = (SELECT school_id FROM users WHERE LOWER(email) = LOWER('trudykir@live.com') LIMIT 1)
ORDER BY g.grade, g.name;

\echo '=== CONTEO por grado: docente vs escuela ==='
WITH teacher_groups AS (
  SELECT DISTINCT g.id, g.grade
  FROM teacher_assignments ta
  JOIN subject_assignments sa ON sa.id = ta.subject_assignment_id
  JOIN groups g ON g.id = sa.group_id
  WHERE ta.teacher_id = (SELECT id FROM users WHERE LOWER(email) = LOWER('trudykir@live.com') LIMIT 1)
),
school_groups AS (
  SELECT g.id, g.grade
  FROM groups g
  WHERE g.school_id = (SELECT school_id FROM users WHERE LOWER(email) = LOWER('trudykir@live.com') LIMIT 1)
)
SELECT COALESCE(sg.grade, '(sin grado)') AS grado,
       COUNT(DISTINCT sg.id) AS grupos_escuela,
       COUNT(DISTINCT tg.id) AS grupos_docente,
       COUNT(DISTINCT sg.id) - COUNT(DISTINCT tg.id) AS grupos_extra_en_reporte
FROM school_groups sg
LEFT JOIN teacher_groups tg ON tg.id = sg.id
GROUP BY sg.grade
ORDER BY sg.grade;

\echo '=== GRUPOS EXTRA (en escuela pero NO del docente) ==='
SELECT g.id, g.name, g.grade
FROM groups g
WHERE g.school_id = (SELECT school_id FROM users WHERE LOWER(email) = LOWER('trudykir@live.com') LIMIT 1)
  AND g.id NOT IN (
    SELECT DISTINCT sa.group_id
    FROM teacher_assignments ta
    JOIN subject_assignments sa ON sa.id = ta.subject_assignment_id
    WHERE ta.teacher_id = (SELECT id FROM users WHERE LOWER(email) = LOWER('trudykir@live.com') LIMIT 1)
  )
ORDER BY g.grade, g.name;

\echo '=== DUPLICADOS teacher_assignments mismo subject_assignment ==='
SELECT teacher_id, subject_assignment_id, COUNT(*) AS cnt
FROM teacher_assignments
WHERE teacher_id = (SELECT id FROM users WHERE LOWER(email) = LOWER('trudykir@live.com') LIMIT 1)
GROUP BY teacher_id, subject_assignment_id
HAVING COUNT(*) > 1;

\echo '=== GRUPOS SIN GRADO ASIGNADO en escuela ==='
SELECT COUNT(*) AS grupos_sin_grade
FROM groups g
WHERE g.school_id = (SELECT school_id FROM users WHERE LOWER(email) = LOWER('trudykir@live.com') LIMIT 1)
  AND (g.grade IS NULL OR TRIM(g.grade) = '');
