-- Script para crear la tabla orientation_reports
-- Este script crea la tabla orientation_reports basada en discipline_reports

CREATE TABLE IF NOT EXISTS orientation_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    school_id UUID,
    student_id UUID,
    teacher_id UUID,
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    report_type VARCHAR(50),
    description TEXT,
    status VARCHAR(20),
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

-- Crear índices
CREATE INDEX IF NOT EXISTS IX_orientation_reports_grade_level_id ON orientation_reports(grade_level_id);
CREATE INDEX IF NOT EXISTS IX_orientation_reports_group_id ON orientation_reports(group_id);
CREATE INDEX IF NOT EXISTS IX_orientation_reports_student_id ON orientation_reports(student_id);
CREATE INDEX IF NOT EXISTS IX_orientation_reports_subject_id ON orientation_reports(subject_id);
CREATE INDEX IF NOT EXISTS IX_orientation_reports_teacher_id ON orientation_reports(teacher_id);

-- Agregar claves foráneas
ALTER TABLE orientation_reports 
ADD CONSTRAINT orientation_reports_grade_level_id_fkey 
FOREIGN KEY (grade_level_id) REFERENCES grade_levels(id);

ALTER TABLE orientation_reports 
ADD CONSTRAINT orientation_reports_group_id_fkey 
FOREIGN KEY (group_id) REFERENCES groups(id);

ALTER TABLE orientation_reports 
ADD CONSTRAINT orientation_reports_student_id_fkey 
FOREIGN KEY (student_id) REFERENCES users(id);

ALTER TABLE orientation_reports 
ADD CONSTRAINT orientation_reports_subject_id_fkey 
FOREIGN KEY (subject_id) REFERENCES subjects(id);

ALTER TABLE orientation_reports 
ADD CONSTRAINT orientation_reports_teacher_id_fkey 
FOREIGN KEY (teacher_id) REFERENCES users(id);

ALTER TABLE orientation_reports 
ADD CONSTRAINT orientation_reports_school_id_fkey 
FOREIGN KEY (school_id) REFERENCES schools(id);

ALTER TABLE orientation_reports 
ADD CONSTRAINT orientation_reports_created_by_fkey 
FOREIGN KEY (created_by) REFERENCES users(id);

ALTER TABLE orientation_reports 
ADD CONSTRAINT orientation_reports_updated_by_fkey 
FOREIGN KEY (updated_by) REFERENCES users(id);

-- Marcar la migración como aplicada
INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion") 
VALUES ('20250917000000_AddOrientationReportsTable', '9.0.3')
ON CONFLICT ("MigrationId") DO NOTHING;
