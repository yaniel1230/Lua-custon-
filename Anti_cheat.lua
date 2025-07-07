local SPEED_HACK_THRESHOLD = 7.0
local CHECK_INTERVAL = 2000  -- 2 segundos
local TELEPORT_DISTANCE_THRESHOLD = 100
local WALLCLIMB_ANGLE_THRESHOLD = 1.5

-- Configuración de sanciones
local MAX_WARNINGS = 3
local BAN_STAGES = {
    [1] = {duration = 604800, reason = "Hacking (1ra infracción - 7 días)"},  -- 7 días
    [2] = {duration = 2592000, reason = "Hacking (2da infracción - 1 mes)"}, -- 30 días
    [3] = {duration = -1, reason = "Hacking (Ban permanente)"}
}

-- Constantes específicas de 3.3.5
local UnitSpeedIndex = { WALK = 0, RUN = 1, RUN_BACK = 2, SWIM = 3, SWIM_BACK = 4, FLY = 5 }
local SPELL_AURA_FLY = 44

-- Tabla de violaciones (persistente por sesión)
local playerViolations = {}

local function NotifyGMs(message)
    SendWorldMessage("|cFFFF0000[ANTI-CHEAT]|r "..message)
    for _, gm in ipairs(GetPlayersInWorld()) do
        if gm:GetGMRank() > 0 then
            gm:SendAreaTriggerMessage("|cFFFF0000[AC]|r "..message)
        end
    end
end

local function ApplyBan(player, stage)
    local accountId = player:GetAccountId()
    local banInfo = BAN_STAGES[stage]
    
    if banInfo.duration == -1 then
        CharDBExecute(string.format(
            "INSERT INTO account_banned VALUES (%d, UNIX_TIMESTAMP(), UNIX_TIMESTAMP(), 'Anti-Cheat', '%s', 1, 0)",
            accountId, banInfo.reason
        ))
        NotifyGMs(string.format("%s baneado permanentemente por hacking", player:GetName()))
    else
        CharDBExecute(string.format(
            "INSERT INTO account_banned VALUES (%d, UNIX_TIMESTAMP(), UNIX_TIMESTAMP() + %d, 'Anti-Cheat', '%s', 1, 0)",
            accountId, banInfo.duration, banInfo.reason
        ))
        NotifyGMs(string.format("%s baneado por %d días", player:GetName(), banInfo.duration/86400))
    end
    player:KickPlayer()
end

local function CheckMovement(player)
    if player:IsGM() then return end
    
    local accountId = player:GetAccountId()
    playerViolations[accountId] = playerViolations[accountId] or {count = 0, stage = 1}
    
    -- Detección de Speed Hack
    local currentSpeed = player:GetSpeed(UnitSpeedIndex.RUN)
    if currentSpeed > SPEED_HACK_THRESHOLD then
        playerViolations[accountId].count = playerViolations[accountId].count + 1
        local msg = string.format("%s (Velocidad: %.1f) [%d/%d]", 
            player:GetName(), currentSpeed, playerViolations[accountId].count, MAX_WARNINGS)
        
        NotifyGMs("Speed Hack detectado: "..msg)
        player:SendBroadcastMessage("|cFFFF0000[AC]|r Movimiento antinatural detectado ("..playerViolations[accountId].count.."/"..MAX_WARNINGS..")")
        
        if playerViolations[accountId].count >= MAX_WARNINGS then
            ApplyBan(player, playerViolations[accountId].stage)
            playerViolations[accountId].stage = math.min(playerViolations[accountId].stage + 1, 3)
            playerViolations[accountId].count = 0
        else
            player:KickPlayer()
        end
        return true
    end
    
    -- Detección de Fly Hack (solo en zonas donde no se puede volar)
    if not player:IsInFlight() and player:IsFlying() and not player:HasAuraType(SPELL_AURA_FLY) then
        playerViolations[accountId].count = playerViolations[accountId].count + 1
        NotifyGMs("Fly Hack detectado: "..player:GetName())
        
        if playerViolations[accountId].count >= MAX_WARNINGS then
            ApplyBan(player, playerViolations[accountId].stage)
            playerViolations[accountId].stage = math.min(playerViolations[accountId].stage + 1, 3)
            playerViolations[accountId].count = 0
        else
            player:SetMovementFlags(0)
            player:KickPlayer()
        end
        return true
    end
    
    -- Detección de Teleport/Wallclimb
    local lastPos = player:GetData("LastPos") or {player:GetX(), player:GetY(), player:GetZ()}
    local currentPos = {player:GetX(), player:GetY(), player:GetZ()}
    local dist = math.sqrt((currentPos[1]-lastPos[1])^2 + (currentPos[2]-lastPos[2])^2)
    
    if dist > TELEPORT_DISTANCE_THRESHOLD then
        playerViolations[accountId].count = playerViolations[accountId].count + 1
        NotifyGMs(string.format("Teleport Hack: %s (Distancia: %.1fyd)", player:GetName(), dist))
        
        if playerViolations[accountId].count >= MAX_WARNINGS then
            ApplyBan(player, playerViolations[accountId].stage)
            playerViolations[accountId].stage = math.min(playerViolations[accountId].stage + 1, 3)
            playerViolations[accountId].count = 0
        else
            player:Teleport(player:GetMapId(), lastPos[1], lastPos[2], lastPos[3])
            player:KickPlayer()
        end
        return true
    end
    
    player:SetData("LastPos", currentPos)
    return false
end

local function AntiCheat_OnUpdate(event, delay, calls, player)
    CheckMovement(player)
end

local function OnLogin(event, player)
    player:RegisterEvent(AntiCheat_OnUpdate, CHECK_INTERVAL, 0)
    player:SetData("LastPos", {player:GetX(), player:GetY(), player:GetZ()})
end

RegisterPlayerEvent(3, OnLogin)  -- EVENT_PLAYER_LOGIN
