-- ============================================================
-- DATOS DUMMY PARA TABLA MESSAGES
-- Fecha: 16 de Octubre, 2025
-- Descripción: Inserta datos de prueba para el módulo de mensajería
-- ============================================================

-- Limpiar datos de prueba anteriores (opcional)
-- DELETE FROM messages WHERE subject LIKE '[PRUEBA%';

-- ============================================================
-- PASO 1: Obtener IDs reales de la base de datos
-- ============================================================

-- Verificar usuarios disponibles
DO $$
DECLARE
    total_users INTEGER;
    total_schools INTEGER;
    total_groups INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_users FROM users;
    SELECT COUNT(*) INTO total_schools FROM schools;
    SELECT COUNT(*) INTO total_groups FROM groups;
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '📊 DATOS DISPONIBLES EN LA BASE DE DATOS:';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'Total de usuarios: %', total_users;
    RAISE NOTICE 'Total de escuelas: %', total_schools;
    RAISE NOTICE 'Total de grupos: %', total_groups;
    RAISE NOTICE '';
    
    IF total_users < 3 THEN
        RAISE EXCEPTION '❌ Necesitas al menos 3 usuarios para crear mensajes de prueba';
    END IF;
END $$;

-- ============================================================
-- PASO 2: Insertar mensajes de prueba
-- ============================================================

-- Variables para almacenar IDs (usaremos los primeros usuarios/grupos disponibles)
WITH user_ids AS (
    SELECT 
        id,
        name,
        last_name,
        role,
        school_id,
        ROW_NUMBER() OVER (ORDER BY created_at) as rn
    FROM users
    WHERE status = 'active'
    LIMIT 10
),
group_ids AS (
    SELECT 
        id,
        name,
        ROW_NUMBER() OVER (ORDER BY created_at) as rn
    FROM groups
    LIMIT 5
),
school_ids AS (
    SELECT id FROM schools LIMIT 1
)

-- MENSAJE 1: Mensaje individual simple (Director a Profesor)
INSERT INTO messages (
    id, sender_id, recipient_id, school_id, subject, content, 
    message_type, priority, sent_at, is_read, created_at
)
SELECT 
    uuid_generate_v4(),
    (SELECT id FROM user_ids WHERE rn = 1),
    (SELECT id FROM user_ids WHERE rn = 2),
    (SELECT id FROM school_ids),
    '[PRUEBA] Reunión de planificación académica',
    'Buenos días, necesito coordinar una reunión para planificar las actividades del próximo trimestre. ¿Tienes disponibilidad el miércoles a las 10:00 AM?',
    'Individual',
    'Normal',
    NOW() - INTERVAL '2 days',
    true,
    NOW() - INTERVAL '2 days'
WHERE EXISTS (SELECT 1 FROM user_ids WHERE rn = 2);

-- MENSAJE 2: Respuesta al mensaje anterior
INSERT INTO messages (
    id, sender_id, recipient_id, school_id, subject, content, 
    message_type, priority, sent_at, is_read, created_at, parent_message_id
)
SELECT 
    uuid_generate_v4(),
    (SELECT id FROM user_ids WHERE rn = 2),
    (SELECT id FROM user_ids WHERE rn = 1),
    (SELECT id FROM school_ids),
    'RE: [PRUEBA] Reunión de planificación académica',
    'Buen día, sí tengo disponibilidad ese día. Nos vemos en la sala de profesores.',
    'Individual',
    'Normal',
    NOW() - INTERVAL '1 day',
    false,
    NOW() - INTERVAL '1 day',
    (SELECT id FROM messages WHERE subject = '[PRUEBA] Reunión de planificación académica' LIMIT 1)
WHERE EXISTS (SELECT 1 FROM user_ids WHERE rn = 1);

-- MENSAJE 3: Mensaje urgente sin leer
INSERT INTO messages (
    id, sender_id, recipient_id, school_id, subject, content, 
    message_type, priority, sent_at, is_read, created_at
)
SELECT 
    uuid_generate_v4(),
    (SELECT id FROM user_ids WHERE rn = 3),
    (SELECT id FROM user_ids WHERE rn = 1),
    (SELECT id FROM school_ids),
    '[PRUEBA] ⚠️ URGENTE: Reporte de disciplina',
    'Necesito que revises el reporte de disciplina del estudiante Juan Pérez. Es urgente para poder tomar medidas correctivas.',
    'Individual',
    'Urgent',
    NOW() - INTERVAL '3 hours',
    false,
    NOW() - INTERVAL '3 hours'
WHERE EXISTS (SELECT 1 FROM user_ids WHERE rn = 1);

-- MENSAJE 4: Mensaje de prioridad alta
INSERT INTO messages (
    id, sender_id, recipient_id, school_id, subject, content, 
    message_type, priority, sent_at, is_read, created_at
)
SELECT 
    uuid_generate_v4(),
    (SELECT id FROM user_ids WHERE rn = 1),
    (SELECT id FROM user_ids WHERE rn = 4),
    (SELECT id FROM school_ids),
    '[PRUEBA] Actualización de notas pendiente',
    'Por favor, actualiza las calificaciones del trimestre actual antes del viernes. Es importante para los reportes académicos.',
    'Individual',
    'High',
    NOW() - INTERVAL '5 hours',
    false,
    NOW() - INTERVAL '5 hours'
WHERE EXISTS (SELECT 1 FROM user_ids WHERE rn = 4);

-- MENSAJE 5: Mensaje grupal (si hay grupos disponibles)
INSERT INTO messages (
    id, sender_id, recipient_id, school_id, group_id, subject, content, 
    message_type, priority, sent_at, is_read, created_at
)
SELECT 
    uuid_generate_v4(),
    u.id,
    u.id,
    (SELECT id FROM school_ids),
    (SELECT id FROM group_ids WHERE rn = 1),
    '[PRUEBA] Tarea de matemáticas para el grupo',
    'Estimados estudiantes, la tarea de matemáticas debe entregarse el próximo lunes. Recuerden resolver los ejercicios del capítulo 5.',
    'Group',
    'Normal',
    NOW() - INTERVAL '1 day',
    false,
    NOW() - INTERVAL '1 day'
FROM user_ids u
WHERE u.rn = 2 AND EXISTS (SELECT 1 FROM group_ids WHERE rn = 1)
LIMIT 1;

-- MENSAJE 6: Anuncio general (AllTeachers)
INSERT INTO messages (
    id, sender_id, recipient_id, school_id, subject, content, 
    message_type, priority, sent_at, is_read, created_at
)
SELECT 
    uuid_generate_v4(),
    (SELECT id FROM user_ids WHERE rn = 1),
    u.id,
    (SELECT id FROM school_ids),
    '[PRUEBA] 📢 Capacitación docente - Todos los profesores',
    'Recordatorio: La capacitación sobre nuevas metodologías de enseñanza será el sábado 19 de octubre a las 9:00 AM. Asistencia obligatoria.',
    'AllTeachers',
    'High',
    NOW() - INTERVAL '12 hours',
    CASE WHEN u.rn = 2 THEN true ELSE false END,
    NOW() - INTERVAL '12 hours'
FROM user_ids u
WHERE u.role IN ('teacher', 'Teacher')
LIMIT 5;

-- MENSAJE 7: Mensaje a todos los estudiantes
INSERT INTO messages (
    id, sender_id, recipient_id, school_id, subject, content, 
    message_type, priority, sent_at, is_read, created_at
)
SELECT 
    uuid_generate_v4(),
    (SELECT id FROM user_ids WHERE rn = 1),
    u.id,
    (SELECT id FROM school_ids),
    '[PRUEBA] 🎓 Importante: Fechas de exámenes finales',
    'Estimados estudiantes, les informamos que los exámenes finales serán del 25 al 29 de noviembre. Prepárense con anticipación y cualquier duda pueden escribirnos.',
    'AllStudents',
    'Normal',
    NOW() - INTERVAL '6 hours',
    false,
    NOW() - INTERVAL '6 hours'
FROM user_ids u
WHERE u.role IN ('student', 'Student', 'estudiante', 'Estudiante')
LIMIT 10;

-- MENSAJE 8: Mensaje de baja prioridad
INSERT INTO messages (
    id, sender_id, recipient_id, school_id, subject, content, 
    message_type, priority, sent_at, is_read, created_at
)
SELECT 
    uuid_generate_v4(),
    (SELECT id FROM user_ids WHERE rn = 3),
    (SELECT id FROM user_ids WHERE rn = 5),
    (SELECT id FROM school_ids),
    '[PRUEBA] Sugerencia para actividad extracurricular',
    'Hola, tengo una idea para una actividad extracurricular de lectura. Me gustaría conocer tu opinión cuando tengas tiempo.',
    'Individual',
    'Low',
    NOW() - INTERVAL '2 days',
    true,
    NOW() - INTERVAL '2 days'
WHERE EXISTS (SELECT 1 FROM user_ids WHERE rn = 5);

-- MENSAJE 9: Mensaje largo con múltiples párrafos
INSERT INTO messages (
    id, sender_id, recipient_id, school_id, subject, content, 
    message_type, priority, sent_at, is_read, created_at
)
SELECT 
    uuid_generate_v4(),
    (SELECT id FROM user_ids WHERE rn = 1),
    (SELECT id FROM user_ids WHERE rn = 2),
    (SELECT id FROM school_ids),
    '[PRUEBA] Informe detallado del trimestre',
    E'Estimado profesor,\n\nEspero que se encuentre bien. Le escribo para compartir un resumen del desempeño general del trimestre:\n\n1. Rendimiento académico: El promedio general ha mejorado un 15% comparado con el trimestre anterior.\n2. Asistencia: Se ha mantenido estable en un 95%.\n3. Disciplina: Hemos tenido una reducción del 30% en reportes disciplinarios.\n\nEstos resultados son muy positivos y reflejan el esfuerzo de todo el equipo docente.\n\nSaludos cordiales.',
    'Individual',
    'Normal',
    NOW() - INTERVAL '8 hours',
    false,
    NOW() - INTERVAL '8 hours'
WHERE EXISTS (SELECT 1 FROM user_ids WHERE rn = 2);

-- MENSAJE 10: Mensaje reciente sin leer
INSERT INTO messages (
    id, sender_id, recipient_id, school_id, subject, content, 
    message_type, priority, sent_at, is_read, created_at
)
SELECT 
    uuid_generate_v4(),
    (SELECT id FROM user_ids WHERE rn = 4),
    (SELECT id FROM user_ids WHERE rn = 1),
    (SELECT id FROM school_ids),
    '[PRUEBA] ✉️ Consulta sobre horarios',
    '¿Podrías confirmarme el horario de clases para la próxima semana? Necesito hacer algunos ajustes en mi planificación.',
    'Individual',
    'Normal',
    NOW() - INTERVAL '30 minutes',
    false,
    NOW() - INTERVAL '30 minutes'
WHERE EXISTS (SELECT 1 FROM user_ids WHERE rn = 1);

-- ============================================================
-- PASO 3: Verificar los datos insertados
-- ============================================================

DO $$
DECLARE
    total_messages INTEGER;
    total_unread INTEGER;
    total_high_priority INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_messages FROM messages WHERE subject LIKE '[PRUEBA%';
    SELECT COUNT(*) INTO total_unread FROM messages WHERE subject LIKE '[PRUEBA%' AND is_read = false;
    SELECT COUNT(*) INTO total_high_priority FROM messages WHERE subject LIKE '[PRUEBA%' AND priority IN ('High', 'Urgent');
    
    RAISE NOTICE '';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '✅ DATOS DUMMY INSERTADOS CORRECTAMENTE';
    RAISE NOTICE '========================================================';
    RAISE NOTICE 'Total de mensajes de prueba: %', total_messages;
    RAISE NOTICE 'Mensajes no leídos: %', total_unread;
    RAISE NOTICE 'Mensajes de alta prioridad: %', total_high_priority;
    RAISE NOTICE '';
    RAISE NOTICE '🎯 PRÓXIMOS PASOS:';
    RAISE NOTICE '   1. Inicia la aplicación: dotnet run';
    RAISE NOTICE '   2. Ve a: /Messaging/Inbox';
    RAISE NOTICE '   3. Inicia sesión con cualquier usuario';
    RAISE NOTICE '   4. Verás los mensajes de prueba';
    RAISE NOTICE '';
    RAISE NOTICE '💡 TIP: Los mensajes tienen el prefijo [PRUEBA] para identificarlos';
    RAISE NOTICE '========================================================';
    RAISE NOTICE '';
END $$;

-- ============================================================
-- CONSULTAS ÚTILES PARA VERIFICAR
-- ============================================================

-- Ver todos los mensajes de prueba
-- SELECT 
--     subject,
--     message_type,
--     priority,
--     is_read,
--     sent_at
-- FROM messages 
-- WHERE subject LIKE '[PRUEBA%'
-- ORDER BY sent_at DESC;

-- Ver mensajes por tipo
-- SELECT 
--     message_type,
--     COUNT(*) as total
-- FROM messages 
-- WHERE subject LIKE '[PRUEBA%'
-- GROUP BY message_type;

-- Ver mensajes por prioridad
-- SELECT 
--     priority,
--     COUNT(*) as total
-- FROM messages 
-- WHERE subject LIKE '[PRUEBA%'
-- GROUP BY priority;

-- ============================================================
-- LIMPIAR DATOS DE PRUEBA (ejecutar si necesitas borrarlos)
-- ============================================================
-- DELETE FROM messages WHERE subject LIKE '[PRUEBA%';
-- SELECT 'Datos de prueba eliminados' AS resultado;

