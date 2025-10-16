-- Vaciar tabla de configuraciones de email
DELETE FROM email_configurations;
DELETE FROM "EmailConfigurations";

-- Mostrar estado final
SELECT 'Configuraciones de email: ' || COUNT(*) FROM email_configurations;
SELECT 'Usuarios totales: ' || COUNT(*) FROM users;
SELECT 'SuperAdmins: ' || COUNT(*) FROM users WHERE LOWER(role) = 'superadmin';

-- Mostrar el único usuario
SELECT id, name, email, role, status FROM users;

