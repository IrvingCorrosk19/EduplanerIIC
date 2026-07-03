\set ON_ERROR_STOP on

SELECT '=== MATERIAS EXPRESIONES ===' AS sec;
SELECT s.id, s.name
FROM subjects s
WHERE s.school_id = '6e42399f-6f17-4585-b92e-fa4fff02cb65'
  AND (
    upper(s.name) LIKE '%ARTIST%'
    OR upper(s.name) LIKE '%ART%'
    OR upper(s.name) LIKE '%MUSICAL%'
    OR upper(s.name) LIKE '%MUSICA%'
  )
ORDER BY s.name;

SELECT '=== MEJOR COMBINACION PARA REPORTE ===' AS sec;
WITH materias_exp AS (
  SELECT s.id, s.name,
    CASE
      WHEN upper(s.name) LIKE '%MUSICAL%' OR upper(s.name) LIKE '%MUSICA%' THEN 'musical'
      WHEN upper(s.name) LIKE '%ART%' OR upper(s.name) LIKE '%ARTIST%' THEN 'artistica'
      ELSE 'otro'
    END AS tipo
  FROM subjects s
  WHERE s.school_id = '6e42399f-6f17-4585-b92e-fa4fff02cb65'
    AND (
      upper(s.name) LIKE '%ARTIST%'
      OR (upper(s.name) LIKE '%ART%' AND upper(s.name) NOT LIKE '%PART%')
      OR upper(s.name) LIKE '%MUSICAL%'
      OR upper(s.name) LIKE '%MUSICA%'
    )
),
act_scores AS (
  SELECT
    a.group_id,
    a.grade_level_id,
    a.trimester,
    me.tipo,
    sas.student_id
  FROM activities a
  JOIN materias_exp me ON me.id = a.subject_id
  JOIN student_activity_scores sas ON sas.activity_id = a.id AND sas.score IS NOT NULL
  WHERE a.group_id IS NOT NULL
    AND a.grade_level_id IS NOT NULL
    AND (a.school_id = '6e42399f-6f17-4585-b92e-fa4fff02cb65' OR a.school_id IS NULL)
),
agg AS (
  SELECT
    group_id,
    grade_level_id,
    COUNT(DISTINCT student_id) AS estudiantes_con_notas,
    COUNT(DISTINCT trimester) AS trimestres,
    COUNT(DISTINCT CASE WHEN tipo = 'artistica' THEN student_id END) AS est_art,
    COUNT(DISTINCT CASE WHEN tipo = 'musical' THEN student_id END) AS est_mus
  FROM act_scores
  GROUP BY 1, 2
)
SELECT
  gl.id AS grade_level_id,
  gl.name AS grado_nivel,
  g.id AS group_id,
  g.name AS grupo,
  g.grade AS grado_grupo,
  a.estudiantes_con_notas,
  a.trimestres,
  a.est_art,
  a.est_mus,
  (SELECT COUNT(*) FROM student_assignments sa WHERE sa.group_id = g.id AND sa.grade_id = gl.id AND sa.is_active = true) AS estudiantes_asignados
FROM agg a
JOIN groups g ON g.id = a.group_id
JOIN grade_levels gl ON gl.id = a.grade_level_id
WHERE g.school_id = '6e42399f-6f17-4585-b92e-fa4fff02cb65'
ORDER BY
  (CASE WHEN a.est_art > 0 AND a.est_mus > 0 THEN 1 ELSE 0 END) DESC,
  a.estudiantes_con_notas DESC,
  a.trimestres DESC
LIMIT 10;

SELECT '=== URL EJEMPLO (mejor fila) ===' AS sec;
