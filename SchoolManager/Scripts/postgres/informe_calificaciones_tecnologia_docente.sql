-- =============================================================================
-- Calificaciones de Tecnología — extracción para docente logueado
-- Ruta app: /CalificacionesInforme/Tecnologia
-- Servicio: ReportesInstitucionalesService.ExportarCalificacionesInformeExcelAsync
-- =============================================================================
-- INSTRUCCIONES: sustituya email, group_id y grade_level_id. La nota final por
-- celda se calcula en C# con la misma lógica que TeacherGradebook (no es AVG simple).

-- ─── Parámetros ───────────────────────────────────────────────────────────────
-- Docente:   trudykir@live.com
-- Grupo:    groups.id del 7-A
-- Grado:    grade_levels.id del 7°

-- ─── 1) Verificar asignación del docente en grupo + grado ───────────────────
SELECT
    u.email AS docente,
    s.name AS materia,
    gl.name AS nivel_academico,
    g.name AS grupo,
    g.grade AS grado_grupo
FROM teacher_assignments ta
JOIN users u ON u.id = ta.teacher_id
JOIN subject_assignments sa ON sa.id = ta.subject_assignment_id
JOIN subjects s ON s.id = sa.subject_id
JOIN groups g ON g.id = sa.group_id
JOIN grade_levels gl ON gl.id = sa.grade_level_id
WHERE lower(u.email) = lower('trudykir@live.com')
  AND sa.group_id = '4a5980a9-3852-4a5c-96af-8bc627042318'::uuid      -- ← groupId
  AND sa.grade_level_id = '9811c9ae-8e25-441c-b7f6-41e2e7cabdef'::uuid -- ← gradeLevelId
ORDER BY s.name;

-- ─── 2) Estudiantes del informe (misma lista que el Excel) ───────────────────
SELECT
    row_number() OVER (ORDER BY u.last_name, u.name) AS numero,
    u.id AS student_id,
    trim(concat(u.name, ' ', u.last_name)) AS nombre
FROM student_assignments sa
JOIN users u ON u.id = sa.student_id
WHERE sa.group_id = '4a5980a9-3852-4a5c-96af-8bc627042318'::uuid
  AND sa.grade_id = '9811c9ae-8e25-441c-b7f6-41e2e7cabdef'::uuid
  AND sa.is_active = true
  AND lower(u.role) IN ('student', 'estudiante', 'alumno');

-- ─── 3) Materias / columnas Tecnología según grado ───────────────────────────
-- Grado 9: CONTABILIDAD | EDUC. HOGAR | ART. INDUSTRIALES
-- Otros:  COMERCIO      | EDUC. HOGAR | ART. INDUSTRIALES
SELECT DISTINCT
    s.id AS subject_id,
    s.name AS materia,
    CASE
        WHEN upper(s.name) LIKE '%CONTABIL%' THEN 'CONTABILIDAD'
        WHEN upper(s.name) LIKE '%COMERC%' THEN 'COMERCIO'
        WHEN upper(s.name) LIKE '%HOGAR%' THEN 'EDUC. HOGAR'
        WHEN upper(s.name) LIKE '%INDUST%' THEN 'ART. INDUSTRIALES'
        ELSE 'OTRA'
    END AS columna_informe
FROM subject_assignments sa
JOIN subjects s ON s.id = sa.subject_id
WHERE sa.group_id = '4a5980a9-3852-4a5c-96af-8bc627042318'::uuid
  AND sa.grade_level_id = '9811c9ae-8e25-441c-b7f6-41e2e7cabdef'::uuid
  AND (
      upper(s.name) LIKE '%COMERC%'
      OR upper(s.name) LIKE '%CONTABIL%'
      OR upper(s.name) LIKE '%HOGAR%'
      OR upper(s.name) LIKE '%INDUST%'
  )
ORDER BY columna_informe, materia;

-- ─── 4) Notas crudas por estudiante, trimestre, materia y tipo de actividad ───
-- (con esto el servicio C# arma la nota final por columna)
SELECT
    e.numero,
    e.nombre,
    t.name AS trimestre,
    s.name AS materia,
    lower(trim(a.type)) AS tipo_actividad,
    a.name AS actividad,
    sas.score AS nota
FROM (
    SELECT
        row_number() OVER (ORDER BY u.last_name, u.name) AS numero,
        u.id AS student_id,
        trim(concat(u.name, ' ', u.last_name)) AS nombre
    FROM student_assignments sa
    JOIN users u ON u.id = sa.student_id
    WHERE sa.group_id = '4a5980a9-3852-4a5c-96af-8bc627042318'::uuid
      AND sa.grade_id = '9811c9ae-8e25-441c-b7f6-41e2e7cabdef'::uuid
      AND sa.is_active = true
) e
CROSS JOIN trimesters t
JOIN activities a ON a.group_id = '4a5980a9-3852-4a5c-96af-8bc627042318'::uuid
    AND a.grade_level_id = '9811c9ae-8e25-441c-b7f6-41e2e7cabdef'::uuid
    AND (a.trimester = t.name OR a.trimester_id = t.id)
JOIN subjects s ON s.id = a.subject_id
LEFT JOIN student_activity_scores sas
    ON sas.activity_id = a.id AND sas.student_id = e.student_id
WHERE t.school_id = (SELECT school_id FROM users WHERE lower(email) = lower('trudykir@live.com') LIMIT 1)
  AND (
      upper(s.name) LIKE '%COMERC%'
      OR upper(s.name) LIKE '%CONTABIL%'
      OR upper(s.name) LIKE '%HOGAR%'
      OR upper(s.name) LIKE '%INDUST%'
  )
ORDER BY e.numero, t."order", s.name, a.type, a.name;

-- ─── 5) Resumen pivot (referencia; nota final exacta = lógica TeacherGradebook) ─
/*
SELECT numero, nombre, trimestre, columna_informe,
       round(avg(nota) FILTER (WHERE nota > 0), 1) AS prom_simple_solo_referencia
FROM ( ... query 4 con columna_informe ... ) x
GROUP BY 1,2,3,4;
*/
