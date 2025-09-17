-- Script para crear un Super Administrador
-- Actualizado con campos de auditoría (created_by, updated_by, updated_at)
-- Este usuario no tiene SchoolId (es NULL) ya que es global

INSERT INTO users (
    id,
    school_id,
    name,
    last_name,
    email,
    password_hash,
    role,
    status,
    two_factor_enabled,
    last_login,
    created_at,
    updated_at,
    document_id,
    date_of_birth,
    created_by,
    updated_by,
    cellphone_primary,
    cellphone_secondary
) VALUES (
    'b5cb04ba-8b09-4f7c-bf34-6fed01fa080b', -- id (UUID específico del super admin)
    NULL,                                    -- school_id (NULL para superadmin)
    'admin@correo.com',                      -- name
    'Corro',                                 -- last_name
    'admin@correo.com',                      -- email
    '$2a$11$ijYC6tyYjXnk.l2uWu.0QeINxiYVKAVhEHwTbaTg5CUtEtlTEZ8i6', -- password_hash
    'superadmin',                            -- role
    'active',                                -- status
    false,                                   -- two_factor_enabled
    '2025-09-08 23:38:59.273493-05',        -- last_login
    '2025-04-11 22:55:18.363537-05',        -- created_at
    NULL,                                    -- updated_at (NULL inicialmente)
    'DOC000016',                             -- document_id
    '2025-04-22 19:00:00-05',                -- date_of_birth
    NULL,                                    -- created_by (NULL para el primer super admin)
    NULL,                                    -- updated_by (NULL inicialmente)
    NULL,                                    -- cellphone_primary
    NULL                                     -- cellphone_secondary
);

-- Verificar que se creó correctamente
SELECT 
    id,
    name,
    last_name,
    email,
    role,
    status,
    school_id,
    created_at,
    updated_at,
    created_by,
    updated_by
FROM users 
WHERE role = 'superadmin';
