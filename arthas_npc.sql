-- NPC: Arthas (GM Anti-Cheat NPC)
-- Tabla creature_template (sin modelid)
DELETE FROM `creature_template` WHERE `entry` = 445081;
INSERT INTO `creature_template` (
    `entry`, `name`, `subname`, `minlevel`, `maxlevel`, 
    `faction`, `npcflag`, `speed_walk`, `speed_run`, `scale`, 
    `rank`, `unit_class`, `unit_flags`, `dynamicflags`, 
    `family`, `type`, `type_flags`, `lootid`, 
    `pickpocketloot`, `skinloot`, `AIName`, `ScriptName`
) VALUES (
    445081, 'Arthas', 'Guardian del Servidor', 83, 83,
    35, 0, 1, 1.5, 1,
    3, 1, 0, 0,
    0, 7, 0, 0,
    0, 0, 'SmartAI', ''
);

-- Modelos para Arthas
DELETE FROM `creature_template_model` WHERE `CreatureID` = 445081;
INSERT INTO `creature_template_model` (
    `CreatureID`, `Idx`, `CreatureDisplayID`, 
    `DisplayScale`, `Probability`, `VerifiedBuild`
) VALUES 
(445081, 0, 30721, 1.0, 1, 0);

-- NPC: Guardian de Arthas
-- Tabla creature_template (sin modelid)
DELETE FROM `creature_template` WHERE `entry` = 445082;
INSERT INTO `creature_template` (
    `entry`, `name`, `subname`, `minlevel`, `maxlevel`, 
    `faction`, `npcflag`, `speed_walk`, `speed_run`, `scale`, 
    `rank`, `unit_class`, `unit_flags`, `dynamicflags`, 
    `family`, `type`, `type_flags`, `lootid`, 
    `pickpocketloot`, `skinloot`, `AIName`, `ScriptName`
) VALUES (
    445082, 'Guardián de Arthas', 'Centinela', 80, 80,
    35, 0, 1, 1.5, 1,
    1, 1, 0, 0,
    0, 7, 0, 0,
    0, 0, 'SmartAI', ''
);

-- Modelos para Guardian de Arthas
DELETE FROM `creature_template_model` WHERE `CreatureID` = 445082;
INSERT INTO `creature_template_model` (
    `CreatureID`, `Idx`, `CreatureDisplayID`, 
    `DisplayScale`, `Probability`, `VerifiedBuild`
) VALUES 
(445082, 0, 11686, 1.0, 1, 0);