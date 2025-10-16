-- Verificar usuarios en Render
SELECT 
    id,
    name,
    last_name,
    email,
    role,
    status,
    created_at
FROM users
ORDER BY role, created_at;

-- Contar por rol
SELECT 
    role,
    COUNT(*) as total
FROM users
GROUP BY role
ORDER BY role;

-- Ver escuelas
SELECT id, name, address FROM schools;

-- Ver email configurations
SELECT id, school_id, smtp_server, from_email, is_active FROM email_configurations;

