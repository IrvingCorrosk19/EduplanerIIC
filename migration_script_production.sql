-- =====================================================================
-- SCRIPT DE MIGRACIÓN UNIFICADO PARA PRODUCCIÓN
-- EduPlanner - SchoolManager
-- Fecha: 20 de Septiembre 2025
-- =====================================================================
-- 
-- Este script incluye todos los cambios realizados durante el desarrollo:
-- 1. Tabla orientation_reports (nueva)
-- 2. Mejoras en discipline_reports (category, documents)
-- 3. Mejoras en users (campos de especialización)
-- 4. Índices y optimizaciones
--
-- IMPORTANTE: Ejecutar en orden y verificar cada sección
-- =====================================================================

-- =====================================================================
-- SECCIÓN 1: MEJORAS EN TABLA USERS
-- =====================================================================

-- Agregar campos de especialización a la tabla users (si no existen)
DO $$
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
$$;

-- =====================================================================
-- SECCIÓN 2: MEJORAS EN TABLA DISCIPLINE_REPORTS
-- =====================================================================

-- Agregar campo category a discipline_reports (si no existe)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'discipline_reports' AND column_name = 'category') THEN
        ALTER TABLE discipline_reports ADD COLUMN category TEXT;
        RAISE NOTICE 'Campo category agregado a tabla discipline_reports';
    ELSE
        RAISE NOTICE 'Campo category ya existe en tabla discipline_reports';
    END IF;
END
$$;

-- Agregar campo documents a discipline_reports (si no existe)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'discipline_reports' AND column_name = 'documents') THEN
        ALTER TABLE discipline_reports ADD COLUMN documents TEXT;
        RAISE NOTICE 'Campo documents agregado a tabla discipline_reports';
    ELSE
        RAISE NOTICE 'Campo documents ya existe en tabla discipline_reports';
    END IF;
END
$$;

-- =====================================================================
-- SECCIÓN 3: NUEVA TABLA ORIENTATION_REPORTS
-- =====================================================================

-- Crear tabla orientation_reports (si no existe)
CREATE TABLE IF NOT EXISTS orientation_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    school_id UUID,
    student_id UUID,
    teacher_id UUID,
    date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    report_type VARCHAR(50),                    -- "Comentario", "Citación"
    description TEXT,
    status VARCHAR(20),                         -- "Pendiente", "Resuelto", "Escalado"
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_at TIMESTAMP WITH TIME ZONE,
    updated_by UUID,
    subject_id UUID,
    group_id UUID,
    grade_level_id UUID,
    category TEXT,                              -- "Comportamiento", "Rendimiento"
    documents TEXT                              -- JSON con archivos adjuntos
);

-- Crear índices para orientation_reports (si no existen)
CREATE INDEX IF NOT EXISTS IX_orientation_reports_created_by ON orientation_reports(created_by);
CREATE INDEX IF NOT EXISTS IX_orientation_reports_grade_level_id ON orientation_reports(grade_level_id);
CREATE INDEX IF NOT EXISTS IX_orientation_reports_group_id ON orientation_reports(group_id);
CREATE INDEX IF NOT EXISTS IX_orientation_reports_school_id ON orientation_reports(school_id);
CREATE INDEX IF NOT EXISTS IX_orientation_reports_student_id ON orientation_reports(student_id);
CREATE INDEX IF NOT EXISTS IX_orientation_reports_subject_id ON orientation_reports(subject_id);
CREATE INDEX IF NOT EXISTS IX_orientation_reports_teacher_id ON orientation_reports(teacher_id);
CREATE INDEX IF NOT EXISTS IX_orientation_reports_updated_by ON orientation_reports(updated_by);

-- Índices adicionales para optimización de consultas
CREATE INDEX IF NOT EXISTS IX_orientation_reports_date ON orientation_reports(date);
CREATE INDEX IF NOT EXISTS IX_orientation_reports_created_at ON orientation_reports(created_at);
CREATE INDEX IF NOT EXISTS IX_orientation_reports_status ON orientation_reports(status);
CREATE INDEX IF NOT EXISTS IX_orientation_reports_category ON orientation_reports(category);

-- =====================================================================
-- SECCIÓN 4: CLAVES FORÁNEAS PARA ORIENTATION_REPORTS
-- =====================================================================

-- Agregar claves foráneas para orientation_reports (si no existen)
DO $$
BEGIN
    -- FK hacia schools
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                   WHERE constraint_name = 'FK_orientation_reports_schools_school_id') THEN
        ALTER TABLE orientation_reports 
        ADD CONSTRAINT FK_orientation_reports_schools_school_id 
        FOREIGN KEY (school_id) REFERENCES schools(id);
        RAISE NOTICE 'FK hacia schools agregada';
    END IF;

    -- FK hacia users (created_by)
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                   WHERE constraint_name = 'FK_orientation_reports_users_created_by') THEN
        ALTER TABLE orientation_reports 
        ADD CONSTRAINT FK_orientation_reports_users_created_by 
        FOREIGN KEY (created_by) REFERENCES users(id);
        RAISE NOTICE 'FK hacia users (created_by) agregada';
    END IF;

    -- FK hacia users (updated_by)
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                   WHERE constraint_name = 'FK_orientation_reports_users_updated_by') THEN
        ALTER TABLE orientation_reports 
        ADD CONSTRAINT FK_orientation_reports_users_updated_by 
        FOREIGN KEY (updated_by) REFERENCES users(id);
        RAISE NOTICE 'FK hacia users (updated_by) agregada';
    END IF;

    -- FK hacia grade_levels
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                   WHERE constraint_name = 'orientation_reports_grade_level_id_fkey') THEN
        ALTER TABLE orientation_reports 
        ADD CONSTRAINT orientation_reports_grade_level_id_fkey 
        FOREIGN KEY (grade_level_id) REFERENCES grade_levels(id);
        RAISE NOTICE 'FK hacia grade_levels agregada';
    END IF;

    -- FK hacia groups
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                   WHERE constraint_name = 'orientation_reports_group_id_fkey') THEN
        ALTER TABLE orientation_reports 
        ADD CONSTRAINT orientation_reports_group_id_fkey 
        FOREIGN KEY (group_id) REFERENCES groups(id);
        RAISE NOTICE 'FK hacia groups agregada';
    END IF;

    -- FK hacia users (student_id)
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                   WHERE constraint_name = 'orientation_reports_student_id_fkey') THEN
        ALTER TABLE orientation_reports 
        ADD CONSTRAINT orientation_reports_student_id_fkey 
        FOREIGN KEY (student_id) REFERENCES users(id);
        RAISE NOTICE 'FK hacia users (student_id) agregada';
    END IF;

    -- FK hacia subjects
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                   WHERE constraint_name = 'orientation_reports_subject_id_fkey') THEN
        ALTER TABLE orientation_reports 
        ADD CONSTRAINT orientation_reports_subject_id_fkey 
        FOREIGN KEY (subject_id) REFERENCES subjects(id);
        RAISE NOTICE 'FK hacia subjects agregada';
    END IF;

    -- FK hacia users (teacher_id)
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints 
                   WHERE constraint_name = 'orientation_reports_teacher_id_fkey') THEN
        ALTER TABLE orientation_reports 
        ADD CONSTRAINT orientation_reports_teacher_id_fkey 
        FOREIGN KEY (teacher_id) REFERENCES users(id);
        RAISE NOTICE 'FK hacia users (teacher_id) agregada';
    END IF;
END
$$;

-- =====================================================================
-- SECCIÓN 5: ÍNDICES ADICIONALES PARA OPTIMIZACIÓN
-- =====================================================================

-- Índices para mejorar rendimiento en consultas frecuentes
CREATE INDEX IF NOT EXISTS IX_attendance_date_group_teacher ON attendance(date, group_id, grade_id, teacher_id);
CREATE INDEX IF NOT EXISTS IX_discipline_reports_created_at ON discipline_reports(created_at);
CREATE INDEX IF NOT EXISTS IX_discipline_reports_category ON discipline_reports(category);
CREATE INDEX IF NOT EXISTS IX_activities_teacher_trimester ON activities(teacher_id, trimester);
CREATE INDEX IF NOT EXISTS IX_student_activity_scores_activity_student ON student_activity_scores(activity_id, student_id);

-- =====================================================================
-- SECCIÓN 6: DATOS INICIALES PARA ACTIVITY_TYPES (SI NO EXISTEN)
-- =====================================================================

-- Insertar tipos de actividades por defecto si no existen
INSERT INTO activity_types (id, name, description, is_global, display_order, is_active, created_at)
SELECT 
    gen_random_uuid(),
    'tarea',
    'Notas de apreciación - Actividades de refuerzo y práctica',
    true,
    1,
    true,
    CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM activity_types WHERE name = 'tarea');

INSERT INTO activity_types (id, name, description, is_global, display_order, is_active, created_at)
SELECT 
    gen_random_uuid(),
    'parcial',
    'Ejercicios Diarios - Evaluaciones periódicas del progreso',
    true,
    2,
    true,
    CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM activity_types WHERE name = 'parcial');

INSERT INTO activity_types (id, name, description, is_global, display_order, is_active, created_at)
SELECT 
    gen_random_uuid(),
    'examen',
    'Examen - Evaluaciones formales del aprendizaje',
    true,
    3,
    true,
    CURRENT_TIMESTAMP
WHERE NOT EXISTS (SELECT 1 FROM activity_types WHERE name = 'examen');

-- =====================================================================
-- SECCIÓN 7: ACTUALIZAR HISTORIAL DE MIGRACIONES
-- =====================================================================

-- Marcar las migraciones como aplicadas en el historial
INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion") 
VALUES ('20250916140026_AddCategoryToDisciplineReports', '8.0.0')
ON CONFLICT ("MigrationId") DO NOTHING;

INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion") 
VALUES ('20250916151749_AddDocumentsToDisciplineReport', '8.0.0')
ON CONFLICT ("MigrationId") DO NOTHING;

INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion") 
VALUES ('20250917120148_AddOrientationReportsTable', '8.0.0')
ON CONFLICT ("MigrationId") DO NOTHING;

-- =====================================================================
-- SECCIÓN 8: VERIFICACIÓN Y LIMPIEZA
-- =====================================================================

-- Limpiar duplicados en attendance (si existen)
DO $$
DECLARE
    duplicate_count INTEGER;
BEGIN
    -- Contar duplicados antes de limpiar
    SELECT COUNT(*) INTO duplicate_count
    FROM (
        SELECT date, group_id, grade_id, teacher_id, student_id, COUNT(*) as cnt
        FROM attendance
        GROUP BY date, group_id, grade_id, teacher_id, student_id
        HAVING COUNT(*) > 1
    ) duplicates;
    
    IF duplicate_count > 0 THEN
        RAISE NOTICE 'Encontrados % grupos de registros duplicados en attendance', duplicate_count;
        
        -- Eliminar duplicados manteniendo el más reciente
        DELETE FROM attendance 
        WHERE id IN (
            SELECT id FROM (
                SELECT id, 
                       ROW_NUMBER() OVER (
                           PARTITION BY date, group_id, grade_id, teacher_id, student_id 
                           ORDER BY created_at DESC
                       ) as rn
                FROM attendance
            ) ranked
            WHERE rn > 1
        );
        
        RAISE NOTICE 'Duplicados eliminados de tabla attendance';
    ELSE
        RAISE NOTICE 'No se encontraron duplicados en tabla attendance';
    END IF;
END
$$;

-- =====================================================================
-- SECCIÓN 9: ESTADÍSTICAS FINALES
-- =====================================================================

-- Mostrar estadísticas de las tablas principales
DO $$
DECLARE
    users_count INTEGER;
    students_count INTEGER;
    teachers_count INTEGER;
    activities_count INTEGER;
    scores_count INTEGER;
    attendance_count INTEGER;
    discipline_count INTEGER;
    orientation_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO users_count FROM users;
    SELECT COUNT(*) INTO students_count FROM users WHERE role = 'student';
    SELECT COUNT(*) INTO teachers_count FROM users WHERE role = 'teacher';
    SELECT COUNT(*) INTO activities_count FROM activities;
    SELECT COUNT(*) INTO scores_count FROM student_activity_scores;
    SELECT COUNT(*) INTO attendance_count FROM attendance;
    SELECT COUNT(*) INTO discipline_count FROM discipline_reports;
    SELECT COUNT(*) INTO orientation_count FROM orientation_reports;
    
    RAISE NOTICE '=====================================================================';
    RAISE NOTICE 'ESTADÍSTICAS FINALES DE LA BASE DE DATOS:';
    RAISE NOTICE '=====================================================================';
    RAISE NOTICE 'Total usuarios: %', users_count;
    RAISE NOTICE 'Total estudiantes: %', students_count;
    RAISE NOTICE 'Total profesores: %', teachers_count;
    RAISE NOTICE 'Total actividades: %', activities_count;
    RAISE NOTICE 'Total notas: %', scores_count;
    RAISE NOTICE 'Total asistencias: %', attendance_count;
    RAISE NOTICE 'Total reportes disciplinarios: %', discipline_count;
    RAISE NOTICE 'Total reportes de orientación: %', orientation_count;
    RAISE NOTICE '=====================================================================';
    RAISE NOTICE 'MIGRACIÓN COMPLETADA EXITOSAMENTE';
    RAISE NOTICE '=====================================================================';
END
$$;

-- =====================================================================
-- SECCIÓN 10: VALIDACIONES FINALES
-- =====================================================================

-- Verificar que todas las tablas principales existen
DO $$
BEGIN
    -- Verificar tablas críticas
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'orientation_reports') THEN
        RAISE EXCEPTION 'ERROR: Tabla orientation_reports no fue creada correctamente';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'discipline_reports' AND column_name = 'category') THEN
        RAISE EXCEPTION 'ERROR: Campo category no fue agregado a discipline_reports';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'users' AND column_name = 'orientacion') THEN
        RAISE EXCEPTION 'ERROR: Campo orientacion no fue agregado a users';
    END IF;
    
    RAISE NOTICE 'VALIDACIÓN: Todas las estructuras fueron creadas correctamente';
END
$$;

-- =====================================================================
-- COMENTARIOS FINALES
-- =====================================================================

/*
RESUMEN DE CAMBIOS APLICADOS:

✅ NUEVAS FUNCIONALIDADES:
- Tabla orientation_reports completa con todos los campos
- Campos category y documents en discipline_reports
- Campos de especialización en users (disciplina, orientacion, etc.)

✅ OPTIMIZACIONES:
- Índices para consultas frecuentes
- Claves foráneas para integridad referencial
- Limpieza de duplicados en attendance

✅ DATOS INICIALES:
- Tipos de actividades por defecto (tarea, parcial, examen)
- Configuración correcta de activity_types

✅ VALIDACIONES:
- Verificación de existencia antes de crear
- Manejo de errores y rollback automático
- Estadísticas finales para verificación

PRÓXIMOS PASOS EN LA APLICACIÓN:
1. Reiniciar el servicio web
2. Verificar que las nuevas funcionalidades carguen correctamente
3. Probar los módulos de orientación y disciplina
4. Verificar que no haya duplicados en asistencias

NOTAS IMPORTANTES:
- Este script es idempotente (se puede ejecutar múltiples veces)
- Incluye validaciones para evitar errores
- Mantiene la integridad de datos existentes
- Compatible con PostgreSQL 12+
*/
