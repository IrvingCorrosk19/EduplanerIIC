-- =====================================================================
-- SCRIPT DE MIGRACIÓN UNIFICADO PARA PRODUCCIÓN (CORREGIDO)
-- EduPlanner - SchoolManager
-- Fecha: 20 de Septiembre 2025
-- =====================================================================

-- =====================================================================
-- SECCIÓN 1: MEJORAS EN TABLA USERS
-- =====================================================================

-- Agregar campos de especialización a la tabla users (si no existen)
DO $BODY$
BEGIN
    -- Campo disciplina
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'users' AND column_name = 'disciplina') THEN
        ALTER TABLE users ADD COLUMN disciplina BOOLEAN DEFAULT false;
        RAISE NOTICE 'Campo disciplina agregado a tabla users';
    ELSE
        RAISE NOTICE 'Campo disciplina ya existe en tabla users';
    END IF;

    -- Campo inclusion
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'users' AND column_name = 'inclusion') THEN
        ALTER TABLE users ADD COLUMN inclusion VARCHAR(255);
        RAISE NOTICE 'Campo inclusion agregado a tabla users';
    ELSE
        RAISE NOTICE 'Campo inclusion ya existe en tabla users';
    END IF;

    -- Campo orientacion
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'users' AND column_name = 'orientacion') THEN
        ALTER TABLE users ADD COLUMN orientacion BOOLEAN DEFAULT false;
        RAISE NOTICE 'Campo orientacion agregado a tabla users';
    ELSE
        RAISE NOTICE 'Campo orientacion ya existe en tabla users';
    END IF;

    -- Campo inclusivo
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'users' AND column_name = 'inclusivo') THEN
        ALTER TABLE users ADD COLUMN inclusivo BOOLEAN DEFAULT false;
        RAISE NOTICE 'Campo inclusivo agregado a tabla users';
    ELSE
        RAISE NOTICE 'Campo inclusivo ya existe en tabla users';
    END IF;
END
$BODY$;

-- =====================================================================
-- SECCIÓN 2: MEJORAS EN TABLA DISCIPLINE_REPORTS
-- =====================================================================

-- Agregar campo category (si no existe)
DO $BODY$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'discipline_reports' AND column_name = 'category') THEN
        ALTER TABLE discipline_reports ADD COLUMN category TEXT;
        RAISE NOTICE 'Campo category agregado a tabla discipline_reports';
    ELSE
        RAISE NOTICE 'Campo category ya existe en tabla discipline_reports';
    END IF;
END
$BODY$;

-- Agregar campo documents (si no existe)
DO $BODY$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'discipline_reports' AND column_name = 'documents') THEN
        ALTER TABLE discipline_reports ADD COLUMN documents TEXT;
        RAISE NOTICE 'Campo documents agregado a tabla discipline_reports';
    ELSE
        RAISE NOTICE 'Campo documents ya existe en tabla discipline_reports';
    END IF;
END
$BODY$;

-- =====================================================================
-- SECCIÓN 3: CREAR TABLA ORIENTATION_REPORTS
-- =====================================================================

-- Crear tabla orientation_reports (si no existe)
DO $BODY$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables 
                   WHERE table_name = 'orientation_reports') THEN
        
        CREATE TABLE orientation_reports (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            school_id UUID,
            student_id UUID NOT NULL,
            teacher_id UUID NOT NULL,
            date TIMESTAMP WITH TIME ZONE NOT NULL,
            report_type VARCHAR(50) NOT NULL,
            description TEXT NOT NULL,
            status VARCHAR(20) DEFAULT 'Pendiente',
            created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
            created_by UUID,
            updated_at TIMESTAMP WITH TIME ZONE,
            updated_by UUID,
            subject_id UUID,
            group_id UUID,
            grade_level_id UUID,
            category TEXT,
            documents TEXT
        );
        
        RAISE NOTICE 'Tabla orientation_reports creada exitosamente';
    ELSE
        RAISE NOTICE 'Tabla orientation_reports ya existe';
    END IF;
END
$BODY$;

-- =====================================================================
-- SECCIÓN 4: FOREIGN KEYS PARA ORIENTATION_REPORTS
-- =====================================================================

-- FK hacia students
DO $BODY$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints
                   WHERE constraint_name = 'FK_orientation_reports_students_student_id') THEN
        ALTER TABLE orientation_reports
        ADD CONSTRAINT FK_orientation_reports_students_student_id
        FOREIGN KEY (student_id) REFERENCES users(id);
        RAISE NOTICE 'FK orientation_reports -> students agregada';
    ELSE
        RAISE NOTICE 'FK orientation_reports -> students ya existe';
    END IF;
END
$BODY$;

-- FK hacia teachers
DO $BODY$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints
                   WHERE constraint_name = 'FK_orientation_reports_teachers_teacher_id') THEN
        ALTER TABLE orientation_reports
        ADD CONSTRAINT FK_orientation_reports_teachers_teacher_id
        FOREIGN KEY (teacher_id) REFERENCES users(id);
        RAISE NOTICE 'FK orientation_reports -> teachers agregada';
    ELSE
        RAISE NOTICE 'FK orientation_reports -> teachers ya existe';
    END IF;
END
$BODY$;

-- FK hacia schools
DO $BODY$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints
                   WHERE constraint_name = 'FK_orientation_reports_schools_school_id') THEN
        ALTER TABLE orientation_reports
        ADD CONSTRAINT FK_orientation_reports_schools_school_id
        FOREIGN KEY (school_id) REFERENCES schools(id);
        RAISE NOTICE 'FK orientation_reports -> schools agregada';
    ELSE
        RAISE NOTICE 'FK orientation_reports -> schools ya existe';
    END IF;
END
$BODY$;

-- FK hacia subjects
DO $BODY$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints
                   WHERE constraint_name = 'FK_orientation_reports_subjects_subject_id') THEN
        ALTER TABLE orientation_reports
        ADD CONSTRAINT FK_orientation_reports_subjects_subject_id
        FOREIGN KEY (subject_id) REFERENCES subjects(id);
        RAISE NOTICE 'FK orientation_reports -> subjects agregada';
    ELSE
        RAISE NOTICE 'FK orientation_reports -> subjects ya existe';
    END IF;
END
$BODY$;

-- FK hacia groups
DO $BODY$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints
                   WHERE constraint_name = 'FK_orientation_reports_groups_group_id') THEN
        ALTER TABLE orientation_reports
        ADD CONSTRAINT FK_orientation_reports_groups_group_id
        FOREIGN KEY (group_id) REFERENCES groups(id);
        RAISE NOTICE 'FK orientation_reports -> groups agregada';
    ELSE
        RAISE NOTICE 'FK orientation_reports -> groups ya existe';
    END IF;
END
$BODY$;

-- FK hacia grade_levels
DO $BODY$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints
                   WHERE constraint_name = 'FK_orientation_reports_grade_levels_grade_level_id') THEN
        ALTER TABLE orientation_reports
        ADD CONSTRAINT FK_orientation_reports_grade_levels_grade_level_id
        FOREIGN KEY (grade_level_id) REFERENCES grade_levels(id);
        RAISE NOTICE 'FK orientation_reports -> grade_levels agregada';
    ELSE
        RAISE NOTICE 'FK orientation_reports -> grade_levels ya existe';
    END IF;
END
$BODY$;

-- =====================================================================
-- SECCIÓN 5: ÍNDICES PARA OPTIMIZACIÓN
-- =====================================================================

-- Índices para orientation_reports
DO $BODY$
BEGIN
    -- Índice por estudiante y fecha
    IF NOT EXISTS (SELECT 1 FROM pg_indexes 
                   WHERE indexname = 'idx_orientation_reports_student_date') THEN
        CREATE INDEX idx_orientation_reports_student_date 
        ON orientation_reports(student_id, date);
        RAISE NOTICE 'Índice idx_orientation_reports_student_date creado';
    ELSE
        RAISE NOTICE 'Índice idx_orientation_reports_student_date ya existe';
    END IF;

    -- Índice por profesor y fecha
    IF NOT EXISTS (SELECT 1 FROM pg_indexes 
                   WHERE indexname = 'idx_orientation_reports_teacher_date') THEN
        CREATE INDEX idx_orientation_reports_teacher_date 
        ON orientation_reports(teacher_id, date);
        RAISE NOTICE 'Índice idx_orientation_reports_teacher_date creado';
    ELSE
        RAISE NOTICE 'Índice idx_orientation_reports_teacher_date ya existe';
    END IF;

    -- Índice por grupo y grado
    IF NOT EXISTS (SELECT 1 FROM pg_indexes 
                   WHERE indexname = 'idx_orientation_reports_group_grade') THEN
        CREATE INDEX idx_orientation_reports_group_grade 
        ON orientation_reports(group_id, grade_level_id);
        RAISE NOTICE 'Índice idx_orientation_reports_group_grade creado';
    ELSE
        RAISE NOTICE 'Índice idx_orientation_reports_group_grade ya existe';
    END IF;

    -- Índice por fecha creación
    IF NOT EXISTS (SELECT 1 FROM pg_indexes 
                   WHERE indexname = 'idx_orientation_reports_created_at') THEN
        CREATE INDEX idx_orientation_reports_created_at 
        ON orientation_reports(created_at);
        RAISE NOTICE 'Índice idx_orientation_reports_created_at creado';
    ELSE
        RAISE NOTICE 'Índice idx_orientation_reports_created_at ya existe';
    END IF;
END
$BODY$;

-- Índices para discipline_reports (optimización)
DO $BODY$
BEGIN
    -- Índice por categoría
    IF NOT EXISTS (SELECT 1 FROM pg_indexes 
                   WHERE indexname = 'idx_discipline_reports_category') THEN
        CREATE INDEX idx_discipline_reports_category 
        ON discipline_reports(category);
        RAISE NOTICE 'Índice idx_discipline_reports_category creado';
    ELSE
        RAISE NOTICE 'Índice idx_discipline_reports_category ya existe';
    END IF;
END
$BODY$;

-- =====================================================================
-- SECCIÓN 6: VERIFICACIONES FINALES
-- =====================================================================

-- Verificar estructura de users
DO $BODY$
DECLARE
    disciplina_exists BOOLEAN;
    inclusion_exists BOOLEAN;
    orientacion_exists BOOLEAN;
    inclusivo_exists BOOLEAN;
BEGIN
    SELECT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'users' AND column_name = 'disciplina') INTO disciplina_exists;
    
    SELECT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'users' AND column_name = 'inclusion') INTO inclusion_exists;
    
    SELECT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'users' AND column_name = 'orientacion') INTO orientacion_exists;
    
    SELECT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'users' AND column_name = 'inclusivo') INTO inclusivo_exists;
    
    RAISE NOTICE '=== VERIFICACIÓN TABLA USERS ===';
    RAISE NOTICE 'Campo disciplina: %', CASE WHEN disciplina_exists THEN '✓ EXISTE' ELSE '✗ FALTA' END;
    RAISE NOTICE 'Campo inclusion: %', CASE WHEN inclusion_exists THEN '✓ EXISTE' ELSE '✗ FALTA' END;
    RAISE NOTICE 'Campo orientacion: %', CASE WHEN orientacion_exists THEN '✓ EXISTE' ELSE '✗ FALTA' END;
    RAISE NOTICE 'Campo inclusivo: %', CASE WHEN inclusivo_exists THEN '✓ EXISTE' ELSE '✗ FALTA' END;
END
$BODY$;

-- Verificar estructura de discipline_reports
DO $BODY$
DECLARE
    category_exists BOOLEAN;
    documents_exists BOOLEAN;
BEGIN
    SELECT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'discipline_reports' AND column_name = 'category') INTO category_exists;
    
    SELECT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'discipline_reports' AND column_name = 'documents') INTO documents_exists;
    
    RAISE NOTICE '=== VERIFICACIÓN TABLA DISCIPLINE_REPORTS ===';
    RAISE NOTICE 'Campo category: %', CASE WHEN category_exists THEN '✓ EXISTE' ELSE '✗ FALTA' END;
    RAISE NOTICE 'Campo documents: %', CASE WHEN documents_exists THEN '✓ EXISTE' ELSE '✗ FALTA' END;
END
$BODY$;

-- Verificar tabla orientation_reports
DO $BODY$
DECLARE
    table_exists BOOLEAN;
    record_count INTEGER;
BEGIN
    SELECT EXISTS (SELECT 1 FROM information_schema.tables 
                   WHERE table_name = 'orientation_reports') INTO table_exists;
    
    IF table_exists THEN
        SELECT COUNT(*) FROM orientation_reports INTO record_count;
        RAISE NOTICE '=== VERIFICACIÓN TABLA ORIENTATION_REPORTS ===';
        RAISE NOTICE 'Tabla orientation_reports: ✓ EXISTE';
        RAISE NOTICE 'Registros existentes: %', record_count;
    ELSE
        RAISE NOTICE '=== VERIFICACIÓN TABLA ORIENTATION_REPORTS ===';
        RAISE NOTICE 'Tabla orientation_reports: ✗ NO EXISTE';
    END IF;
END
$BODY$;

-- Mensaje final
DO $BODY$
BEGIN
    RAISE NOTICE '=====================================================================';
    RAISE NOTICE '✅ MIGRACIÓN COMPLETADA EXITOSAMENTE';
    RAISE NOTICE '📅 Fecha: %', CURRENT_TIMESTAMP;
    RAISE NOTICE '🗄️ Base de datos actualizada con todas las mejoras';
    RAISE NOTICE '=====================================================================';
END
$BODY$;
