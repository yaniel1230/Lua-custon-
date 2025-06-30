-- =============================================
-- MODIFICACIÓN COMPLETA DE TODAS LAS LEGENDARIAS
-- AzerothCore 3.3.5 - Nivel 80
-- Manteniendo efectos originales, solo ajustando:
-- - Nivel requerido 80
-- - Estadísticas para nivel 80
-- =============================================

START TRANSACTION;

-- 1️⃣ THUNDERFURY (19019)
UPDATE `item_template` SET 
    `ItemLevel` = 80,
    `RequiredLevel` = 80,
    `stat_type1` = 3, `stat_value1` = 60,  -- Agilidad
    `stat_type2` = 7, `stat_value2` = 45,  -- Aguante
    `stat_type3` = 32, `stat_value3` = 120, -- Poder de Ataque
    `dmg_min1` = 180, `dmg_max1` = 320
WHERE `entry` = 19019;

-- 2️⃣ SULFURAS (17182)
UPDATE `item_template` SET 
    `ItemLevel` = 80,
    `RequiredLevel` = 80,
    `stat_type1` = 4, `stat_value1` = 80,  -- Fuerza
    `stat_type2` = 7, `stat_value2` = 70,  -- Aguante
    `dmg_min1` = 220, `dmg_max1` = 380
WHERE `entry` = 17182;

-- 3️⃣ SHADOWMOURNE (49623)
UPDATE `item_template` SET 
    `ItemLevel` = 80,
    `RequiredLevel` = 80,
    `stat_type1` = 4, `stat_value1` = 100, -- Fuerza
    `stat_type2` = 3, `stat_value2` = 50,  -- Agilidad
    `stat_type3` = 7, `stat_value3` = 80   -- Aguante
WHERE `entry` = 49623;

-- 4️⃣ WARGLIAVES OF AZZINOTH (32837/32838)
UPDATE `item_template` SET 
    `ItemLevel` = 80,
    `RequiredLevel` = 80,
    `stat_type1` = 3, `stat_value1` = 70,  -- Agilidad
    `stat_type2` = 32, `stat_value2` = 100 -- Poder de Ataque
WHERE `entry` = 32837;

UPDATE `item_template` SET 
    `ItemLevel` = 80,
    `RequiredLevel` = 80,
    `stat_type1` = 3, `stat_value1` = 50,  -- Agilidad
    `stat_type2` = 32, `stat_value2` = 80  -- Poder de Ataque
WHERE `entry` = 32838;

-- 5️⃣ VAL'ANYR (48712)
UPDATE `item_template` SET 
    `ItemLevel` = 80,
    `RequiredLevel` = 80,
    `stat_type1` = 5, `stat_value1` = 70,  -- Intelecto
    `stat_type2` = 6, `stat_value2` = 50,  -- Espíritu
    `stat_type3` = 45, `stat_value3` = 120 -- Poder de Hechizos
WHERE `entry` = 48712;

-- 6️⃣ ATIESH (22630-22632)
UPDATE `item_template` SET 
    `ItemLevel` = 80,
    `RequiredLevel` = 80,
    `stat_type1` = 5, `stat_value1` = 90,  -- Intelecto
    `stat_type2` = 6, `stat_value2` = 60,  -- Espíritu
    `stat_type3` = 45, `stat_value3` = 150 -- Poder de Hechizos
WHERE `entry` IN (22630, 22631, 22632);

-- 7️⃣ QUEL'DELAR (50045)
UPDATE `item_template` SET 
    `ItemLevel` = 80,
    `RequiredLevel` = 80,
    `stat_type1` = 3, `stat_value1` = 75,  -- Agilidad
    `stat_type2` = 32, `stat_value2` = 110, -- Poder de Ataque
    `stat_type3` = 36, `stat_value3` = 45   -- Índice de golpe
WHERE `entry` = 50045;

-- 8️⃣ ASHBRINGER (13262 - Normal)
UPDATE `item_template` SET 
    `ItemLevel` = 80,
    `RequiredLevel` = 80,
    `stat_type1` = 4, `stat_value1` = 100, -- Fuerza
    `stat_type2` = 3, `stat_value2` = 50,  -- Agilidad
    `stat_type3` = 7, `stat_value3` = 80   -- Aguante
WHERE `entry` = 13262;

-- 9️⃣ CORRUPTED ASHBRINGER (22691)
UPDATE `item_template` SET 
    `ItemLevel` = 80,
    `RequiredLevel` = 80,
    `stat_type1` = 4, `stat_value1` = 120, -- Fuerza
    `stat_type2` = 7, `stat_value2` = 90,  -- Aguante
    `stat_type3` = 37, `stat_value3` = 70  -- Crítico
WHERE `entry` = 22691;

COMMIT;

-- =============================================
-- VERIFICACIÓN FINAL
-- =============================================
SELECT `entry`, `name`, `ItemLevel`, `RequiredLevel`, `dmg_min1`, `dmg_max1` 
FROM `item_template` 
WHERE `entry` IN (
    19019, 17182, 49623, 32837, 32838, 48712, 
    22630, 22631, 22632, 50045, 13262, 22691
);