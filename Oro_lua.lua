local REWARD_CONFIG = {
    BASE_GOLD = 100,                  -- Oro base (en piezas de cobre, 10000 = 1 oro)
    INTERVAL = 10 * 60 * 1000,        -- 10 minutos en milisegundos
    ANNOUNCE_REWARDS = true,          -- Anunciar recompensas globalmente
    LEVEL_BONUS_ENABLED = true,       -- Habilitar bonus por nivel
    MAX_LEVEL = 80,                   -- Nivel máximo para cálculo de bonus
    BONUS_PER_LEVEL = 0.01,           -- 1% de bonus por nivel
    EXCLUDE_GMS = true,               -- Excluir GMs
    GM_MIN_RANK = 1                   -- Rango mínimo de GM a excluir
}

-- Función para enviar mensajes con formato
local function SendFormattedMessage(player, message)
    player:SendBroadcastMessage("|cff00ccff[Recompensas]|r "..message)
end

-- Función para anuncio global con formato
local function SendGlobalAnnouncement(message)
    SendWorldMessage("|cff00ccff[Anuncio]|r "..message)
end

-- Función para calcular bonus por nivel
local function CalculateLevelBonus(player)
    if not REWARD_CONFIG.LEVEL_BONUS_ENABLED then
        return 0
    end
    
    local level = player:GetLevel()
    if level > REWARD_CONFIG.MAX_LEVEL then
        level = REWARD_CONFIG.MAX_LEVEL
    end
    
    return level * REWARD_CONFIG.BONUS_PER_LEVEL
end

-- Función para dar recompensas
local function GiveRewardsToOnlinePlayers()
    local players = GetPlayersInWorld()
    local rewardedPlayers = 0
    local totalGoldGiven = 0
    
    for _, player in ipairs(players) do
        if player:IsInWorld() then
            -- Verificar exclusión de GMs
            if REWARD_CONFIG.EXCLUDE_GMS and player:IsGM() and player:GetGMRank() > REWARD_CONFIG.GM_MIN_RANK then
                goto continue
            end
            
            -- Calcular recompensa con bonus por nivel
            local levelBonus = CalculateLevelBonus(player)
            local reward = REWARD_CONFIG.BASE_GOLD * (1 + levelBonus)
            reward = math.floor(reward)
            
            -- Dar el oro al jugador
            player:ModifyMoney(reward)
            
            -- Enviar mensaje al jugador
            local bonusMessage = ""
            if levelBonus > 0 then
                bonusMessage = string.format(" (|cff00ff00+%.0f%%|r bonus por nivel)", levelBonus * 100)
            end
            
            SendFormattedMessage(player, string.format(
                "Has recibido |cffffd700%.2f|r oro%s por estar conectado!", 
                reward / 10000, 
                bonusMessage
            ))
            
            rewardedPlayers = rewardedPlayers + 1
            totalGoldGiven = totalGoldGiven + reward
            
            ::continue::
        end
    end
    
    -- Anuncio global si hay jugadores premiados
    if REWARD_CONFIG.ANNOUNCE_REWARDS and rewardedPlayers > 0 then
        SendGlobalAnnouncement(string.format(
            "%d jugadores han recibido un total de |cffffd700%.2f|r oro en recompensas por conexión!", 
            rewardedPlayers, 
            totalGoldGiven / 10000
        ))
    end
    
    -- Programar próximo evento
    CreateLuaEvent(GiveRewardsToOnlinePlayers, REWARD_CONFIG.INTERVAL, 1)
end

-- Iniciar el sistema cuando el servidor esté listo
local function OnServerStart(event, delay, repeats)
    -- Mensaje de inicio en la consola
    print("[Recompensas] Sistema iniciado. Configuración:")
    print("- Intervalo: "..(REWARD_CONFIG.INTERVAL/60000).." minutos")
    print("- Oro base: "..(REWARD_CONFIG.BASE_GOLD/10000).." oro")
    print("- Bonus por nivel: "..(REWARD_CONFIG.LEVEL_BONUS_ENABLED and "Activado" or "Desactivado"))
    if REWARD_CONFIG.LEVEL_BONUS_ENABLED then
        print("  - Máximo nivel: "..REWARD_CONFIG.MAX_LEVEL)
        print("  - Bonus por nivel: "..(REWARD_CONFIG.BONUS_PER_LEVEL*100).."%")
    end
    
    -- Iniciar el temporizador de recompensas
    CreateLuaEvent(GiveRewardsToOnlinePlayers, REWARD_CONFIG.INTERVAL, 1)
end

RegisterServerEvent(33, OnServerStart)  -- EVENT_ON_STARTUP