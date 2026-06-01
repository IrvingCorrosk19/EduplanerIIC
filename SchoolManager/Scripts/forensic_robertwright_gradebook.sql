-- SOLO LECTURA - Analisis forense robertwright68@gmail.com
\set ON_ERROR_STOP on

\echo '=== CASOS LIMITE: nota muestra 3.0 pero backend < 3.0 ==='
WITH teacher AS (
  SELECT 'ee458ad2-90a1-4da7-b3d4-a12bc04ee7c3'::uuid AS teacher_id
),
assignments AS (
  SELECT sa.subject_id, sa.group_id, sa.grade_level_id, sub.name AS materia, g.name AS grupo
  FROM teacher_assignments ta
  JOIN subject_assignments sa ON sa.id = ta.subject_assignment_id
  JOIN subjects sub ON sub.id = sa.subject_id
  JOIN groups g ON g.id = sa.group_id
  CROSS JOIN teacher t
  WHERE ta.teacher_id = t.teacher_id
),
base AS (
  SELECT
    a.subject_id,
    a.group_id,
    a.grade_level_id,
    ass.materia,
    ass.grupo,
    sas.student_id,
    u.last_name || ', ' || u.name AS estudiante,
    u.document_id,
    a.trimester,
    lower(a.type) AS tipo,
    sas.score
  FROM student_activity_scores sas
  JOIN activities a ON a.id = sas.activity_id
  JOIN assignments ass ON ass.subject_id = a.subject_id
    AND ass.group_id = a.group_id
    AND ass.grade_level_id = a.grade_level_id
  JOIN users u ON u.id = sas.student_id
  CROSS JOIN teacher t
  WHERE a.teacher_id = t.teacher_id
    AND sas.score IS NOT NULL
),
type_avgs AS (
  SELECT subject_id, group_id, grade_level_id, materia, grupo, student_id, estudiante, document_id, trimester, tipo,
         AVG(score) AS avg_tipo,
         FLOOR(AVG(score) * 10) / 10.0 AS trunc_avg_tipo
  FROM base
  GROUP BY 1,2,3,4,5,6,7,8,9,10
),
pivot AS (
  SELECT subject_id, group_id, grade_level_id, materia, grupo, student_id, estudiante, document_id, trimester,
    MAX(CASE WHEN tipo LIKE 'notas de aprecia%' THEN avg_tipo END) AS raw_aprec,
    MAX(CASE WHEN tipo = 'ejercicios diarios' THEN avg_tipo END) AS raw_ejerc,
    MAX(CASE WHEN tipo = 'examen final' THEN avg_tipo END) AS raw_exam,
    MAX(CASE WHEN tipo LIKE 'recuperaci%' THEN avg_tipo END) AS raw_recup,
    MAX(CASE WHEN tipo LIKE 'notas de aprecia%' THEN trunc_avg_tipo END) AS trunc_aprec,
    MAX(CASE WHEN tipo = 'ejercicios diarios' THEN trunc_avg_tipo END) AS trunc_ejerc,
    MAX(CASE WHEN tipo = 'examen final' THEN trunc_avg_tipo END) AS trunc_exam,
    MAX(CASE WHEN tipo LIKE 'recuperaci%' THEN trunc_avg_tipo END) AS trunc_recup
  FROM type_avgs
  GROUP BY 1,2,3,4,5,6,7,8,9
),
trim_final AS (
  SELECT *,
    (SELECT AVG(v) FROM unnest(ARRAY[raw_aprec, raw_ejerc, raw_exam]) v WHERE v IS NOT NULL) AS backend_nota_final,
    (
      SELECT FLOOR(AVG(v) * 10) / 10.0
      FROM unnest(ARRAY[
        NULLIF(trunc_aprec, 0),
        NULLIF(trunc_ejerc, 0),
        NULLIF(CASE WHEN COALESCE(trunc_recup, 0) > 0 THEN trunc_recup ELSE trunc_exam END, 0)
      ]::numeric[]) v
      WHERE v IS NOT NULL
    ) AS frontend_nota_final
  FROM pivot
)
SELECT materia, grupo, estudiante, document_id, trimester,
  ROUND(backend_nota_final::numeric, 4) AS backend_raw,
  ROUND(frontend_nota_final::numeric, 4) AS frontend_trunc,
  ROUND(backend_nota_final::numeric, 1) AS display_toFixed1,
  CASE WHEN backend_nota_final >= 3.0 THEN 'Aprobado' ELSE 'Reprobado' END AS estado_resumen_api,
  CASE WHEN frontend_nota_final >= 3.0 THEN 'Aprobado' ELSE 'Reprobado' END AS estado_libro_js
FROM trim_final
WHERE backend_nota_final IS NOT NULL
  AND (
    (ROUND(backend_nota_final::numeric, 1) = 3.0 AND backend_nota_final < 3.0)
    OR (frontend_nota_final IS NOT NULL AND ROUND(frontend_nota_final::numeric, 1) = 3.0 AND frontend_nota_final < 3.0)
    OR (backend_nota_final >= 2.9 AND backend_nota_final < 3.0)
    OR (frontend_nota_final IS NOT NULL AND frontend_nota_final >= 2.9 AND frontend_nota_final < 3.0)
  )
ORDER BY materia, grupo, estudiante, trimester;

\echo '=== PROMEDIO ANUAL: trunc vs round vs estado ==='
WITH teacher AS (
  SELECT 'ee458ad2-90a1-4da7-b3d4-a12bc04ee7c3'::uuid AS teacher_id
),
assignments AS (
  SELECT sa.subject_id, sa.group_id, sa.grade_level_id, sub.name AS materia, g.name AS grupo
  FROM teacher_assignments ta
  JOIN subject_assignments sa ON sa.id = ta.subject_assignment_id
  JOIN subjects sub ON sub.id = sa.subject_id
  JOIN groups g ON g.id = sa.group_id
  CROSS JOIN teacher t
  WHERE ta.teacher_id = t.teacher_id
),
base AS (
  SELECT a.subject_id, a.group_id, a.grade_level_id, ass.materia, ass.grupo,
         sas.student_id, u.last_name || ', ' || u.name AS estudiante, a.trimester,
         lower(a.type) AS tipo, sas.score
  FROM student_activity_scores sas
  JOIN activities a ON a.id = sas.activity_id
  JOIN assignments ass ON ass.subject_id = a.subject_id AND ass.group_id = a.group_id AND ass.grade_level_id = a.grade_level_id
  JOIN users u ON u.id = sas.student_id
  CROSS JOIN teacher t
  WHERE a.teacher_id = t.teacher_id AND sas.score IS NOT NULL
),
type_avgs AS (
  SELECT subject_id, group_id, grade_level_id, materia, grupo, student_id, estudiante, trimester, tipo,
         AVG(score) AS avg_tipo, FLOOR(AVG(score) * 10) / 10.0 AS trunc_avg_tipo
  FROM base GROUP BY 1,2,3,4,5,6,7,8,9,10
),
pivot AS (
  SELECT subject_id, group_id, grade_level_id, materia, grupo, student_id, estudiante, trimester,
    MAX(CASE WHEN tipo LIKE 'notas de aprecia%' THEN avg_tipo END) AS raw_aprec,
    MAX(CASE WHEN tipo = 'ejercicios diarios' THEN avg_tipo END) AS raw_ejerc,
    MAX(CASE WHEN tipo = 'examen final' THEN avg_tipo END) AS raw_exam,
    MAX(CASE WHEN tipo LIKE 'recuperaci%' THEN trunc_avg_tipo END) AS trunc_recup,
    MAX(CASE WHEN tipo LIKE 'notas de aprecia%' THEN trunc_avg_tipo END) AS trunc_aprec,
    MAX(CASE WHEN tipo = 'ejercicios diarios' THEN trunc_avg_tipo END) AS trunc_ejerc,
    MAX(CASE WHEN tipo = 'examen final' THEN trunc_avg_tipo END) AS trunc_exam
  FROM type_avgs GROUP BY 1,2,3,4,5,6,7,8,9
),
trim_final AS (
  SELECT subject_id, group_id, grade_level_id, materia, grupo, student_id, estudiante, trimester,
    (SELECT AVG(v) FROM unnest(ARRAY[raw_aprec, raw_ejerc, raw_exam]) v WHERE v IS NOT NULL) AS backend_trim,
    (SELECT FLOOR(AVG(v)*10)/10.0 FROM unnest(ARRAY[
      NULLIF(trunc_aprec,0), NULLIF(trunc_ejerc,0),
      NULLIF(CASE WHEN COALESCE(trunc_recup,0)>0 THEN trunc_recup ELSE trunc_exam END,0)
    ]::numeric[]) v WHERE v IS NOT NULL) AS frontend_trim
  FROM pivot
),
annual AS (
  SELECT materia, grupo, student_id, estudiante,
    AVG(CASE WHEN trimester='1T' THEN backend_trim END) AS b1,
    AVG(CASE WHEN trimester='2T' THEN backend_trim END) AS b2,
    AVG(CASE WHEN trimester='3T' THEN backend_trim END) AS b3,
    AVG(CASE WHEN trimester='1T' THEN frontend_trim END) AS f1,
    AVG(CASE WHEN trimester='2T' THEN frontend_trim END) AS f2,
    AVG(CASE WHEN trimester='3T' THEN frontend_trim END) AS f3
  FROM trim_final WHERE backend_trim IS NOT NULL
  GROUP BY 1,2,3,4,5
),
annual_calc AS (
  SELECT *,
    (COALESCE(b1,0)+COALESCE(b2,0)+COALESCE(b3,0)) / NULLIF(
      (CASE WHEN b1>0 THEN 1 ELSE 0 END)+(CASE WHEN b2>0 THEN 1 ELSE 0 END)+(CASE WHEN b3>0 THEN 1 ELSE 0 END),0) AS prom_backend,
    (COALESCE(NULLIF(f1,0),0)+COALESCE(NULLIF(f2,0),0)+COALESCE(NULLIF(f3,0),0)) / NULLIF(
      (CASE WHEN f1>0 THEN 1 ELSE 0 END)+(CASE WHEN f2>0 THEN 1 ELSE 0 END)+(CASE WHEN f3>0 THEN 1 ELSE 0 END),0) AS prom_frontend,
    FLOOR(((COALESCE(b1,0)+COALESCE(b2,0)+COALESCE(b3,0)) / NULLIF(
      (CASE WHEN b1>0 THEN 1 ELSE 0 END)+(CASE WHEN b2>0 THEN 1 ELSE 0 END)+(CASE WHEN b3>0 THEN 1 ELSE 0 END),0)) * 10) / 10.0 AS prom_trunc_js
  FROM annual
)
SELECT materia, grupo, estudiante,
  ROUND(prom_backend::numeric,4) AS prom_anual_backend,
  ROUND(prom_frontend::numeric,4) AS prom_anual_frontend,
  ROUND(prom_trunc_js::numeric,4) AS prom_anual_trunc,
  ROUND(prom_backend::numeric,1) AS display_round,
  CASE WHEN prom_backend >= 3.0 THEN 'Aprobado' ELSE 'Reprobado' END AS estado_api,
  CASE WHEN prom_trunc_js >= 3.0 THEN 'Aprobado' ELSE 'Reprobado' END AS estado_updateResumen
FROM annual_calc
WHERE prom_backend IS NOT NULL
  AND (
    (ROUND(prom_backend::numeric,1)=3.0 AND prom_backend < 3.0)
    OR (ROUND(prom_trunc_js::numeric,1)=3.0 AND prom_trunc_js < 3.0)
    OR (prom_backend >= 2.9 AND prom_backend < 3.0)
  )
ORDER BY materia, grupo, estudiante;
