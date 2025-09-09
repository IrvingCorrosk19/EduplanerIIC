-- Script para crear la tabla counselor_assignments directamente en PostgreSQL
-- Ejecutar este script en la base de datos local

CREATE TABLE IF NOT EXISTS public.counselor_assignments (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    school_id uuid NOT NULL,
    user_id uuid NOT NULL,
    grade_id uuid,
    group_id uuid,
    is_counselor boolean DEFAULT true NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

-- Primary Key
ALTER TABLE ONLY public.counselor_assignments
    ADD CONSTRAINT counselor_assignments_pkey PRIMARY KEY (id);

-- Foreign Keys
ALTER TABLE ONLY public.counselor_assignments
    ADD CONSTRAINT counselor_assignments_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.counselor_assignments
    ADD CONSTRAINT counselor_assignments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.counselor_assignments
    ADD CONSTRAINT counselor_assignments_grade_id_fkey FOREIGN KEY (grade_id) REFERENCES public.grade_levels(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.counselor_assignments
    ADD CONSTRAINT counselor_assignments_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE SET NULL;

-- Indexes
CREATE INDEX IF NOT EXISTS idx_counselor_assignments_school ON public.counselor_assignments USING btree (school_id);
CREATE INDEX IF NOT EXISTS idx_counselor_assignments_user ON public.counselor_assignments USING btree (user_id);
CREATE INDEX IF NOT EXISTS idx_counselor_assignments_grade ON public.counselor_assignments USING btree (grade_id);
CREATE INDEX IF NOT EXISTS idx_counselor_assignments_group ON public.counselor_assignments USING btree (group_id);

-- Unique Constraints
CREATE UNIQUE INDEX IF NOT EXISTS counselor_assignments_school_user_key ON public.counselor_assignments USING btree (school_id, user_id);
CREATE UNIQUE INDEX IF NOT EXISTS counselor_assignments_school_grade_key ON public.counselor_assignments USING btree (school_id, grade_id) WHERE (grade_id IS NOT NULL);
CREATE UNIQUE INDEX IF NOT EXISTS counselor_assignments_school_group_key ON public.counselor_assignments USING btree (school_id, group_id) WHERE (group_id IS NOT NULL);

-- Comentarios
COMMENT ON TABLE public.counselor_assignments IS 'Tabla para asignar consejeros a escuelas, grados y grupos específicos';
COMMENT ON COLUMN public.counselor_assignments.school_id IS 'ID de la escuela';
COMMENT ON COLUMN public.counselor_assignments.user_id IS 'ID del usuario consejero';
COMMENT ON COLUMN public.counselor_assignments.grade_id IS 'ID del grado específico (opcional)';
COMMENT ON COLUMN public.counselor_assignments.group_id IS 'ID del grupo específico (opcional)';
COMMENT ON COLUMN public.counselor_assignments.is_counselor IS 'Indica si el usuario es consejero';
COMMENT ON COLUMN public.counselor_assignments.is_active IS 'Indica si la asignación está activa';
