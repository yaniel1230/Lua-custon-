
-- NPC: Arthas (GM Anti-Cheat NPC)
DELETE FROM `creature_template` WHERE `entry` = 445081;
INSERT INTO `creature_template` (`entry`, `name`, `subname`, `modelid1`, `minlevel`, `maxlevel`, `faction`, `npcflag`, `speed_walk`, `speed_run`, `scale`, `rank`, `unit_class`, `unit_flags`, `dynamicflags`, `family`, `type`, `type_flags`, `lootid`, `pickpocketloot`, `skinloot`, `AIName`, `ScriptName`)
VALUES
(445081, 'Arthas', 'Guardian del Servidor', 30721, 83, 83, 35, 0, 1, 1.5, 1, 3, 1, 0, 0, 0, 7, 0, 0, 0, 0, 'SmartAI', '');

-- NPC: Guardian de Arthas
DELETE FROM `creature_template` WHERE `entry` = 445082;
INSERT INTO `creature_template` (`entry`, `name`, `subname`, `modelid1`, `minlevel`, `maxlevel`, `faction`, `npcflag`, `speed_walk`, `speed_run`, `scale`, `rank`, `unit_class`, `unit_flags`, `dynamicflags`, `family`, `type`, `type_flags`, `lootid`, `pickpocketloot`, `skinloot`, `AIName`, `ScriptName`)
VALUES
(445082, 'Guardián de Arthas', 'Centinela', 11686, 80, 80, 35, 0, 1, 1.5, 1, 1, 1, 0, 0, 0, 7, 0, 0, 0, 0, 'SmartAI', '');
