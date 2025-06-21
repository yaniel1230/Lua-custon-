local NPC_ID = 190000 -- ID de tu NPC personalizado
local RATES = {
    [1] = { rate = 1, gold = 0, minLevel = 1, description = "Normal (Gratis)" },
    [2] = { rate = 2, gold = 50, minLevel = 20, description = "Experiencia x2" },
    [3] = { rate = 3, gold = 150, minLevel = 40, description = "Experiencia x3" },
    [4] = { rate = 4, gold = 300, minLevel = 60, description = "Experiencia x4" },
    [5] = { rate = 5, gold = 500, minLevel = 70, description = "Experiencia x5" }
}

-- Creación de tabla optimizada para AzerothCore actual
CharDBExecute([[
    CREATE TABLE IF NOT EXISTS `custom_xp_rates` (
        `guid` INT UNSIGNED NOT NULL COMMENT 'Player GUID',
        `rate` TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT 'Experience multiplier',
        `last_update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (`guid`),
        CONSTRAINT `fk_xp_rates_characters` FOREIGN KEY (`guid`) 
        REFERENCES `characters` (`guid`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
]])

-- Verificar si la tabla existe y tiene la estructura correcta
local function ValidateDatabase()
    local result = CharDBQuery([[
        SELECT COLUMN_NAME, COLUMN_TYPE 
        FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_SCHEMA = DATABASE() 
        AND TABLE_NAME = 'custom_xp_rates'
    ]])
    
    if not result then
        error("Error al validar la estructura de la tabla custom_xp_rates")
    end
    
    -- Forzar la creación si no existe
    CharDBExecute([[
        CREATE TABLE IF NOT EXISTS `custom_xp_rates` (
            `guid` INT UNSIGNED NOT NULL,
            `rate` TINYINT UNSIGNED NOT NULL DEFAULT 1,
            `last_update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`guid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end

ValidateDatabase()

local PLAYER_CACHE = {}

-- Cargar cache con manejo de errores
local function LoadCache()
    local success, err = pcall(function()
        local result = CharDBQuery("SELECT guid, rate FROM custom_xp_rates")
        if result then
            repeat
                PLAYER_CACHE[result:GetUInt32(0)] = result:GetUInt8(1)
            until not result:NextRow()
        end
    end)
    
    if not success then
        print("[XP Rates] Error al cargar cache: "..err)
        -- Intentar recrear tabla si hay error
        CharDBExecute("DROP TABLE IF EXISTS `custom_xp_rates`")
        ValidateDatabase()
    end
end
LoadCache()

-- Función para obtener rate con cache
local function GetPlayerRate(player)
    return PLAYER_CACHE[player:GetGUIDLow()] or 1
end

-- Actualizar rate en DB y cache
local function UpdatePlayerRate(player, newRate)
    local guid = player:GetGUIDLow()
    local query = format("REPLACE INTO custom_xp_rates (guid, rate) VALUES (%d, %d)", guid, newRate)
    
    local success, err = pcall(function()
        CharDBExecute(query)
        PLAYER_CACHE[guid] = newRate
    end)
    
    if not success then
        print("[XP Rates] Error al actualizar rate: "..err)
        return false
    end
    return true
end

-- Menú del NPC
local function OnGossipHello(event, player, creature)
    player:GossipClearMenu()
    local currentRate = GetPlayerRate(player)
    
    -- Encabezado
    player:GossipMenuAddItem(0, "|TInterface/ICONS/Ability_Druid_FormofNature:30:30:-15|t Sistema de Experiencia", 0, 0)
    player:GossipMenuAddItem(0, "────────────────────", 0, 0)
    player:GossipMenuAddItem(0, format("Multiplicador actual: |cFF00FF00x%d|r", currentRate), 0, 0)
    player:GossipMenuAddItem(0, format("Nivel actual: |cFF00FF00%d|r", player:GetLevel()), 0, 0)
    player:GossipMenuAddItem(0, format("Oro disponible: |cFFDAA520%s|r", GetCoinTextureString(player:GetCoinage())), 0, 0)
    player:GossipMenuAddItem(0, "────────────────────", 0, 0)
    
    -- Opciones de rate
    for i, rateData in ipairs(RATES) do
        local enabled = (player:GetLevel() >= rateData.minLevel) and 
                       (player:GetCoinage() >= rateData.gold * 10000 or rateData.gold == 0) and
                       (currentRate ~= rateData.rate)
        
        local statusColor = enabled and "FF00FF00" or "FFFF0000"
        local statusText = enabled and "Disponible" or 
                         (currentRate == rateData.rate and "Actual") or
                         (player:GetLevel() < rateData.minLevel and "Nivel "..rateData.minLevel.."+") or
                         "Falta oro"
        
        player:GossipMenuAddItem(2, format("|c%s%s|r - |cFFDAA520%d oro|r |c%s[%s]|r", 
            enabled and "FFFFFFFF" or "FFAAAAAA", 
            rateData.description, 
            rateData.gold,
            statusColor,
            statusText), 
            0, i)
    end
    
    player:GossipSendMenu(1, creature)
end

-- Procesar selección
local function OnGossipSelect(event, player, creature, sender, intid, code, menuId)
    if intid == 0 then return end -- Opciones de menú
    
    local rateData = RATES[intid]
    if not rateData then
        creature:SendUnitWhisper("|cFFFF0000Opción no válida|r", player)
        player:GossipComplete()
        return
    end
    
    local currentRate = GetPlayerRate(player)
    if currentRate == rateData.rate then
        creature:SendUnitWhisper("|cFFFF0000Ya tienes este multiplicador activo|r", player)
        player:GossipComplete()
        return
    end
    
    -- Verificar requisitos
    if player:GetLevel() < rateData.minLevel then
        creature:SendUnitWhisper(format("|cFFFF0000Requieres nivel %d para este multiplicador|r", rateData.minLevel), player)
        player:GossipComplete()
        return
    end
    
    if player:GetCoinage() < rateData.gold * 10000 then
        creature:SendUnitWhisper("|cFFFF0000No tienes suficiente oro|r", player)
        player:GossipComplete()
        return
    end
    
    -- Confirmar cambio
    player:GossipMenuAddItem(0, "|cFFFF0000Confirmar cambio|r", 0, 0)
    player:GossipMenuAddItem(0, format("Multiplicador: |cFF00FF00x%d|r", rateData.rate), 0, 0)
    player:GossipMenuAddItem(0, format("Costo: |cFFDAA520%d oro|r", rateData.gold), 0, 0)
    player:GossipMenuAddItem(0, "────────────────────", 0, 0)
    player:GossipMenuAddItem(2, "|TInterface/ICONS/Spell_Nature_TimeStop:20:20:-5|t Confirmar", 0, 100, false, "", rateData.gold * 10000)
    player:GossipMenuAddItem(2, "|TInterface/ICONS/Achievement_BG_returnXflags_def_WSG:20:20:-5|t Cancelar", 0, 200)
    player:GossipSendMenu(1, creature)
end

-- Procesar confirmación
local function OnGossipSelectWithCode(event, player, creature, sender, intid, code)
    if intid == 100 then -- Confirmado
        local rateIndex = tonumber(code)
        local rateData = RATES[rateIndex]
        
        if rateData and UpdatePlayerRate(player, rateData.rate) then
            player:ModifyMoney(-(rateData.gold * 10000))
            player:CastSpell(player, 47292, true) -- Efecto visual
            creature:SendUnitWhisper(format("|cFF00FF00¡Multiplicador cambiado a x%d!|r", rateData.rate), player)
        else
            creature:SendUnitWhisper("|cFFFF0000Error al cambiar el multiplicador|r", player)
        end
    end
    
    player:GossipComplete()
end

-- Modificar experiencia
local function OnGiveXP(event, player, amount, victim)
    local rate = GetPlayerRate(player)
    if rate > 1 then
        return amount * rate
    end
    return amount
end

-- Registrar eventos
RegisterCreatureGossipEvent(NPC_ID, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_ID, 2, OnGossipSelect)
RegisterCreatureGossipEvent(NPC_ID, 3, OnGossipSelectWithCode)
RegisterPlayerEvent(12, OnGiveXP)