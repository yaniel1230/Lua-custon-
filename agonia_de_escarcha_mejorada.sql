-- ===== VERIFICACIÓN DE VERSIÓN =====
SET @ACORE_VERSION := (SELECT `core_version` FROM `version` LIMIT 1);
SELECT IF(@ACORE_VERSION LIKE '3.3.5%', '✅ Compatible', CONCAT('❌ Requiere AzerothCore 3.3.5 (Actual: ', @ACORE_VERSION)) AS Compatibilidad;

-- ===== TRANSACCIÓN PRINCIPAL =====
START TRANSACTION;

-- 1. BACKUP AUTOMÁTICO (OPCIONAL)
CREATE TABLE IF NOT EXISTS `item_template_backup_36942` LIKE `item_template`;
INSERT INTO `item_template_backup_36942` SELECT * FROM `item_template` WHERE `entry` = 36942;

-- 2. ACTUALIZACIÓN DEL ITEM
UPDATE `item_template` SET 
    `name` = "Agonía de Escarcha",
    `Quality` = 5,
    `ItemLevel` = 80,
    `RequiredLevel` = 80,
    `stat_type1` = 4, `stat_value1` = 115,
    `stat_type2` = 3, `stat_value2` = 65,
    `stat_type3` = 7, `stat_value3` = 85,
    `dmg_min1` = 330, `dmg_max1` = 620,
    `delay` = 3400,
    `spellid_1` = 72498, `spelltrigger_1` = 1,
    `spellid_2` = 71903, `spelltrigger_2` = 2, `spellppmRate_2` = 1.0,
    `spellid_3` = 72305, `spelltrigger_3` = 2, `spellppmRate_3` = 2.0,
    `description` = "Espada legendaria del Rey Exánime que combina el poder de las sombras con el frío eterno.",
    `bonding` = 1,
    `Material` = 1,
    `sheath` = 1,
    `MaxDurability` = 120,
    `area` = 0,
    `Map` = 0,
    `BagFamily` = 0,
    `ScriptName` = '',
    `DisenchantID` = 0,
    `FoodType` = 0,
    `minMoneyLoot` = 0,
    `maxMoneyLoot` = 0,
    `Duration` = 0,
    `ExtraFlags` = 0
WHERE `entry` = 36942;

-- 3. CONFIGURACIÓN DE PROCS (COMPATIBLE)
INSERT IGNORE INTO `spell_proc_event` 
(`entry`, `SchoolMask`, `SpellFamilyName`, `SpellFamilyMask0`, `procFlags`, `ppmRate`) 
VALUES
(72498, 0, 0, 0, 0x00010000, 0),    -- Rey Exánime
(71903, 0, 0, 0, 0, 1.0),            -- Almas Gemelas
(72305, 16, 15, 0, 0x00010000, 2.0); -- Tormenta Helada (DK/Escarcha)

COMMIT;

-- ===== VERIFICACIÓN POSTERIOR =====
SELECT 
    it.entry,
    it.name,
    it.Quality,
    it.ItemLevel,
    it.RequiredLevel,
    IF(it.spellid_1 = 72498, '✅', CONCAT('❌ (', it.spellid_1, ')')) AS Buff_Rey_Exanime,
    IF(it.spellid_2 = 71903, '✅', '❌') AS Almas_Gemelas,
    IF(it.spellid_3 = 72305, '✅', '❌') AS Tormenta_Helada
FROM item_template it
WHERE it.entry = 36942;