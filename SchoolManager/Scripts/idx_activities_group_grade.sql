-- Índice compuesto para consultas por grupo + grado sobre activities (consejería / agregados).
-- Producción: preferir CREATE INDEX CONCURRENTLY para evitar bloquear escrituras prolongadas.
-- Ejecutar fuera de transacciones explícitas cuando use CONCURRENTLY.

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_activities_group_grade
    ON public.activities (group_id, grade_level_id);
