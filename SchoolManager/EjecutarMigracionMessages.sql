-- ============================================================
-- EJECUTAR ESTE SCRIPT EN PGADMIN PARA CREAR LA TABLA MESSAGES
-- ============================================================
-- Base de datos: schoolmanagement
-- Fecha: 16 de Octubre, 2025
-- ============================================================

\echo '🚀 Iniciando creación de tabla messages...'

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
CREATE INDEX IF NOT EXISTS idx_messages_sender ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_recipient ON messages(recipient_id);
CREATE INDEX IF NOT EXISTS idx_messages_school ON messages(school_id);
CREATE INDEX IF NOT EXISTS idx_messages_sent_at ON messages(sent_at);
CREATE INDEX IF NOT EXISTS idx_messages_recipient_unread ON messages(recipient_id, is_read);
CREATE INDEX IF NOT EXISTS idx_messages_group ON messages(group_id);
CREATE INDEX IF NOT EXISTS idx_messages_parent ON messages(parent_message_id);

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

DROP TRIGGER IF EXISTS messages_updated_at_trigger ON messages;
CREATE TRIGGER messages_updated_at_trigger
    BEFORE UPDATE ON messages
    FOR EACH ROW
    EXECUTE FUNCTION update_messages_updated_at();

-- ============================================================
-- VERIFICACIÓN Y REPORTE
-- ============================================================
DO $$
DECLARE
    column_count INTEGER;
    index_count INTEGER;
    trigger_count INTEGER;
BEGIN
    -- Verificar que la tabla existe
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'messages') THEN
        RAISE NOTICE '';
        RAISE NOTICE '========================================================';
        RAISE NOTICE '✅✅✅ TABLA MESSAGES CREADA EXITOSAMENTE ✅✅✅';
        RAISE NOTICE '========================================================';
        
        -- Contar columnas
        SELECT COUNT(*) INTO column_count
        FROM information_schema.columns
        WHERE table_name = 'messages';
        RAISE NOTICE '📊 Columnas creadas: %', column_count;
        
        -- Contar índices
        SELECT COUNT(*) INTO index_count
        FROM pg_indexes
        WHERE tablename = 'messages';
        RAISE NOTICE '🔍 Índices creados: %', index_count;
        
        -- Verificar trigger
        SELECT COUNT(*) INTO trigger_count
        FROM information_schema.triggers
        WHERE event_object_table = 'messages'
        AND trigger_name = 'messages_updated_at_trigger';
        RAISE NOTICE '⚡ Triggers creados: %', trigger_count;
        
        RAISE NOTICE '';
        RAISE NOTICE '========================================================';
        RAISE NOTICE '🎉 MÓDULO DE MENSAJERÍA LISTO PARA USAR';
        RAISE NOTICE '========================================================';
        RAISE NOTICE 'Accede al módulo en: /Messaging/Inbox';
        RAISE NOTICE '';
    ELSE
        RAISE EXCEPTION '❌ Error: No se pudo crear la tabla messages';
    END IF;
END $$;

-- Mostrar estructura de la tabla
SELECT 
    column_name AS "Columna",
    data_type AS "Tipo",
    is_nullable AS "Nullable",
    column_default AS "Valor por defecto"
FROM information_schema.columns
WHERE table_name = 'messages'
ORDER BY ordinal_position;

