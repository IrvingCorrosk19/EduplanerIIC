-- =====================================================
-- SCRIPT: Insertar Áreas Académicas Básicas
-- Descripción: Crea las áreas académicas principales del sistema educativo panameño
-- Autor: Sistema EduPlanner
-- Fecha: 2025-01-16
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '📚 Iniciando inserción de áreas académicas...';
END $$;

-- =====================================================
-- LIMPIAR ÁREAS EXISTENTES (OPCIONAL)
-- =====================================================

-- Descomentar si quieres eliminar áreas antiguas:
-- DELETE FROM area WHERE is_global = true;

-- =====================================================
-- INSERTAR ÁREAS ACADÉMICAS PRINCIPALES
-- =====================================================

-- 1. Área de Humanidades
INSERT INTO area (id, name, description, code, is_global, display_order, is_active, created_at)
VALUES (
    gen_random_uuid(),
    'Humanidades',
    'Comprende las asignaturas relacionadas con lenguas, historia, geografía y ciencias sociales',
    'HUM',
    true,
    1,
    true,
    CURRENT_TIMESTAMP
)
ON CONFLICT (name) DO UPDATE SET
    description = EXCLUDED.description,
    is_active = true,
    display_order = EXCLUDED.display_order,
    updated_at = CURRENT_TIMESTAMP;

-- 2. Área de Ciencias Naturales
INSERT INTO area (id, name, description, code, is_global, display_order, is_active, created_at)
VALUES (
    gen_random_uuid(),
    'Ciencias Naturales',
    'Incluye biología, química, física y ciencias naturales',
    'CNAT',
    true,
    2,
    true,
    CURRENT_TIMESTAMP
)
ON CONFLICT (name) DO UPDATE SET
    description = EXCLUDED.description,
    is_active = true,
    display_order = EXCLUDED.display_order,
    updated_at = CURRENT_TIMESTAMP;

-- 3. Área de Matemáticas
INSERT INTO area (id, name, description, code, is_global, display_order, is_active, created_at)
VALUES (
    gen_random_uuid(),
    'Matemáticas',
    'Comprende matemática, geometría, trigonometría, cálculo y estadística',
    'MAT',
    true,
    3,
    true,
    CURRENT_TIMESTAMP
)
ON CONFLICT (name) DO UPDATE SET
    description = EXCLUDED.description,
    is_active = true,
    display_order = EXCLUDED.display_order,
    updated_at = CURRENT_TIMESTAMP;

-- 4. Área de Idiomas
INSERT INTO area (id, name, description, code, is_global, display_order, is_active, created_at)
VALUES (
    gen_random_uuid(),
    'Idiomas',
    'Incluye español, inglés y otros idiomas extranjeros',
    'IDI',
    true,
    4,
    true,
    CURRENT_TIMESTAMP
)
ON CONFLICT (name) DO UPDATE SET
    description = EXCLUDED.description,
    is_active = true,
    display_order = EXCLUDED.display_order,
    updated_at = CURRENT_TIMESTAMP;

-- 5. Área de Tecnología
INSERT INTO area (id, name, description, code, is_global, display_order, is_active, created_at)
VALUES (
    gen_random_uuid(),
    'Tecnología',
    'Comprende informática, computación, programación y tecnología',
    'TEC',
    true,
    5,
    true,
    CURRENT_TIMESTAMP
)
ON CONFLICT (name) DO UPDATE SET
    description = EXCLUDED.description,
    is_active = true,
    display_order = EXCLUDED.display_order,
    updated_at = CURRENT_TIMESTAMP;

-- 6. Área de Artes
INSERT INTO area (id, name, description, code, is_global, display_order, is_active, created_at)
VALUES (
    gen_random_uuid(),
    'Artes',
    'Incluye música, dibujo, artes plásticas y expresión artística',
    'ART',
    true,
    6,
    true,
    CURRENT_TIMESTAMP
)
ON CONFLICT (name) DO UPDATE SET
    description = EXCLUDED.description,
    is_active = true,
    display_order = EXCLUDED.display_order,
    updated_at = CURRENT_TIMESTAMP;

-- 7. Área de Educación Física
INSERT INTO area (id, name, description, code, is_global, display_order, is_active, created_at)
VALUES (
    gen_random_uuid(),
    'Educación Física',
    'Comprende educación física, deportes y recreación',
    'EF',
    true,
    7,
    true,
    CURRENT_TIMESTAMP
)
ON CONFLICT (name) DO UPDATE SET
    description = EXCLUDED.description,
    is_active = true,
    display_order = EXCLUDED.display_order,
    updated_at = CURRENT_TIMESTAMP;

-- 8. Área de Formación Integral
INSERT INTO area (id, name, description, code, is_global, display_order, is_active, created_at)
VALUES (
    gen_random_uuid(),
    'Formación Integral',
    'Incluye religión, ética, valores, orientación y cívica',
    'FI',
    true,
    8,
    true,
    CURRENT_TIMESTAMP
)
ON CONFLICT (name) DO UPDATE SET
    description = EXCLUDED.description,
    is_active = true,
    display_order = EXCLUDED.display_order,
    updated_at = CURRENT_TIMESTAMP;

-- =====================================================
-- VERIFICAR INSERCIÓN
-- =====================================================

DO $$
DECLARE
    total_areas INT;
BEGIN
    SELECT COUNT(*) INTO total_areas FROM area WHERE is_active = true;
    RAISE NOTICE '✅ Áreas académicas insertadas correctamente';
    RAISE NOTICE '📊 Total de áreas activas: %', total_areas;
END $$;

-- Mostrar todas las áreas activas
SELECT 
    name AS "Nombre del Área",
    code AS "Código",
    display_order AS "Orden",
    is_active AS "Activa",
    created_at AS "Fecha de Creación"
FROM area 
WHERE is_active = true
ORDER BY display_order;

