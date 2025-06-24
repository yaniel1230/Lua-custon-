-- 1. Tabla para registrar las infracciones detectadas
CREATE TABLE IF NOT EXISTS `arthas_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_guid` int(11) NOT NULL,
  `player_name` varchar(12) NOT NULL,
  `offense` varchar(100) NOT NULL,
  `warning_level` tinyint(3) NOT NULL,
  `spell_id` int(11) DEFAULT NULL,
  `timestamp` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `player_guid` (`player_guid`),
  KEY `timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Tabla de jugadores baneados temporalmente
CREATE TABLE IF NOT EXISTS `arthas_temp_bans` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_guid` int(11) NOT NULL,
  `account_id` int(11) NOT NULL,
  `player_name` varchar(12) NOT NULL,
  `reason` varchar(255) NOT NULL,
  `ban_time` int(11) NOT NULL,
  `unban_time` int(11) NOT NULL,
  `banned_by` varchar(12) DEFAULT 'Arthas',
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`),
  KEY `player_guid` (`player_guid`),
  KEY `unban_time` (`unban_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Tabla de configuración del sistema
CREATE TABLE IF NOT EXISTS `arthas_config` (
  `config_name` varchar(50) NOT NULL,
  `config_value` varchar(255) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`config_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Configuración inicial
INSERT INTO `arthas_config` (`config_name`, `config_value`, `description`) VALUES
('debug_mode', '0', 'Modo depuración (1 activado, 0 desactivado)'),
('teleport_threshold', '100', 'Umbral de detección de teleport (yardas)'),
('speed_threshold', '7.0', 'Umbral de velocidad máxima permitida (yardas/segundo)'),
('check_interval', '1000', 'Intervalo entre chequeos (ms)'),
('max_warnings', '3', 'Número máximo de advertencias antes de ban');

-- 4. Tabla de zonas seguras (para actualización dinámica)
CREATE TABLE IF NOT EXISTS `arthas_safe_zones` (
  `zone_id` int(11) NOT NULL,
  `zone_name` varchar(50) NOT NULL,
  `allowed_cheats` varchar(255) NOT NULL COMMENT 'Lista de spell_ids permitidos separados por coma',
  PRIMARY KEY (`zone_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insertar zonas seguras por defecto
INSERT INTO `arthas_safe_zones` (`zone_id`, `zone_name`, `allowed_cheats`) VALUES
(37, 'Shadowfang Keep', '1787,41451'),
(189, 'Scarlet Monastery', '1787,41451'),
(4395, 'Dalaran', '31621');

-- 5. Tabla de hechizos prohibidos (para actualización dinámica)
CREATE TABLE IF NOT EXISTS `arthas_banned_spells` (
  `spell_id` int(11) NOT NULL,
  `spell_name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`spell_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insertar hechizos prohibidos por defecto
INSERT INTO `arthas_banned_spells` (`spell_id`, `spell_name`, `description`) VALUES
(1787, 'Invisibilidad (Hampa)', 'Invisibilidad no autorizada'),
(32612, 'Invisibilidad Avanzada', 'Invisibilidad no autorizada'),
(41451, 'Vanish (Pícaro)', 'Invisibilidad no autorizada'),
(31621, 'Vuelo no autorizado', 'Vuelo en zonas no permitidas'),
(11392, 'Speed hacking', 'Movimiento demasiado rápido'),
(22888, 'Salto ilegal', 'Salto no autorizado');

-- 6. Procedimientos almacenados para gestión

-- Actualizar configuración
DELIMITER //
CREATE PROCEDURE `arthas_update_config`(IN config_name VARCHAR(50), IN config_value VARCHAR(255))
BEGIN
    IF EXISTS (SELECT 1 FROM `arthas_config` WHERE `config_name` = config_name) THEN
        UPDATE `arthas_config` SET `config_value` = config_value WHERE `config_name` = config_name;
    ELSE
        INSERT INTO `arthas_config` (`config_name`, `config_value`) VALUES (config_name, config_value);
    END IF;
END //
DELIMITER ;

-- Añadir zona segura
DELIMITER //
CREATE PROCEDURE `arthas_add_safe_zone`(IN zone_id INT, IN zone_name VARCHAR(50), IN allowed_cheats VARCHAR(255))
BEGIN
    IF EXISTS (SELECT 1 FROM `arthas_safe_zones` WHERE `zone_id` = zone_id) THEN
        UPDATE `arthas_safe_zones` SET `zone_name` = zone_name, `allowed_cheats` = allowed_cheats WHERE `zone_id` = zone_id;
    ELSE
        INSERT INTO `arthas_safe_zones` (`zone_id`, `zone_name`, `allowed_cheats`) VALUES (zone_id, zone_name, allowed_cheats);
    END IF;
END //
DELIMITER ;

-- Añadir hechizo prohibido
DELIMITER //
CREATE PROCEDURE `arthas_ban_spell`(IN spell_id INT, IN spell_name VARCHAR(50), IN description VARCHAR(255))
BEGIN
    IF EXISTS (SELECT 1 FROM `arthas_banned_spells` WHERE `spell_id` = spell_id) THEN
        UPDATE `arthas_banned_spells` SET `spell_name` = spell_name, `description` = description WHERE `spell_id` = spell_id;
    ELSE
        INSERT INTO `arthas_banned_spells` (`spell_id`, `spell_name`, `description`) VALUES (spell_id, spell_name, description);
    END IF;
END //
DELIMITER ;

-- 7. Eventos programados para limpieza

-- Limpiar logs antiguos (30 días)
DELIMITER //
CREATE EVENT `arthas_clean_logs`
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    DELETE FROM `arthas_logs` WHERE `timestamp` < UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL 30 DAY));
END //
DELIMITER ;

-- Limpiar bans temporales expirados
DELIMITER //
CREATE EVENT `arthas_clean_temp_bans`
ON SCHEDULE EVERY 1 HOUR
DO
BEGIN
    DELETE FROM `arthas_temp_bans` WHERE `unban_time` < UNIX_TIMESTAMP();
END //
DELIMITER ;