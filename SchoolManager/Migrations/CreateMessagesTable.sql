-- ============================================================
-- MIGRACIÓN: Tabla de Mensajería Interna
-- Fecha: 2025-10-15
-- Descripción: Crea la tabla para el sistema de mensajería
--              interno de la aplicación
-- ============================================================

-- Crear tabla de mensajes
CREATE TABLE IF NOT EXISTS messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sender_id UUID NOT NULL,
    recipient_id UUID,
    school_id UUID,
    subject VARCHAR(200) NOT NULL,
    content TEXT NOT NULL CHECK (LENGTH(content) <= 5000),
    message_type VARCHAR(50) NOT NULL CHECK (message_type IN ('Individual', 'Group', 'AllTeachers', 'AllStudents', 'Broadcast')),
    group_id UUID,
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_read BOOLEAN DEFAULT FALSE NOT NULL,
    read_at TIMESTAMP WITH TIME ZONE,
    is_deleted BOOLEAN DEFAULT FALSE NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE,
    priority VARCHAR(20) DEFAULT 'Normal' CHECK (priority IN ('Low', 'Normal', 'High', 'Urgent')),
    parent_message_id UUID,
    attachments TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE,
    
    -- Relaciones
    CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) 
        REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT messages_recipient_id_fkey FOREIGN KEY (recipient_id) 
        REFERENCES users(id) ON DELETE RESTRICT,
    CONSTRAINT messages_school_id_fkey FOREIGN KEY (school_id) 
        REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT messages_group_id_fkey FOREIGN KEY (group_id) 
        REFERENCES groups(id) ON DELETE SET NULL,
    CONSTRAINT messages_parent_message_id_fkey FOREIGN KEY (parent_message_id) 
        REFERENCES messages(id) ON DELETE RESTRICT
);

-- Crear índices para optimizar consultas
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_recipient ON messages(recipient_id);
CREATE INDEX idx_messages_school ON messages(school_id);
CREATE INDEX idx_messages_sent_at ON messages(sent_at);
CREATE INDEX idx_messages_recipient_unread ON messages(recipient_id, is_read);
CREATE INDEX idx_messages_group ON messages(group_id);
CREATE INDEX idx_messages_parent ON messages(parent_message_id);

-- Comentarios en la tabla
COMMENT ON TABLE messages IS 'Tabla para el sistema de mensajería interna de la aplicación';
COMMENT ON COLUMN messages.message_type IS 'Tipo de mensaje: Individual, Group, AllTeachers, AllStudents, Broadcast';
COMMENT ON COLUMN messages.priority IS 'Prioridad del mensaje: Low, Normal, High, Urgent';
COMMENT ON COLUMN messages.parent_message_id IS 'ID del mensaje padre si es una respuesta';

-- Trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_messages_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER messages_updated_at_trigger
    BEFORE UPDATE ON messages
    FOR EACH ROW
    EXECUTE FUNCTION update_messages_updated_at();

-- ============================================================
-- VERIFICACIÓN
-- ============================================================
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'messages') THEN
        RAISE NOTICE '✅ Tabla messages creada correctamente';
    ELSE
        RAISE EXCEPTION '❌ Error: No se pudo crear la tabla messages';
    END IF;
END $$;

-- ============================================================
-- ROLLBACK (en caso de necesitar revertir)
-- ============================================================
-- DROP TRIGGER IF EXISTS messages_updated_at_trigger ON messages;
-- DROP FUNCTION IF EXISTS update_messages_updated_at();
-- DROP TABLE IF EXISTS messages CASCADE;

