
-- Spawn de Arthas en la Isla de los GMs
DELETE FROM `creature` WHERE `id` = 445081 AND `map` = 1;
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `spawndist`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`)
VALUES (NULL, 445081, 1, 876, 876, 1, 1, 16222.1, 16265.2, 13.2, 1.57, 300, 0, 0, 100000, 10000, 0);
