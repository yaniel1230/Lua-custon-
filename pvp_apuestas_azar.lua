creado por:yaniel
local NPC_ID = 445085

-- Juegos
local GAMES = {
    DUEL_QUICK = 1,
    BOUNTY_HUNT = 2,
    KING_HILL = 3,
    KILL_STREAK = 4,
}

-- Costos en oro (en oro real, no en cobre)
local COSTS = {
    [GAMES.DUEL_QUICK] = 50,
    [GAMES.BOUNTY_HUNT] = 100,
    [GAMES.KING_HILL] = 75,
    [GAMES.KILL_STREAK] = 75,
}

-- Variables de estado
local activeBounties = {}     -- [targetGUID] = {placerGUID, expireTime, bet}
local activeKillStreaks = {}  -- [playerGUID] = {kills, goal, bet, startTime}
local kingHillActive = false
local kingHillController = nil
local kingHillExpireTime = 0
local kingHillDuration = 120

local kingHillZone = { -- Coordenadas ejemplo, ajustar
    x1 = 1000, y1 = 1000, z1 = 0,
    x2 = 1100, y2 = 1100, z2 = 50,
}

local playerStats = {}    -- [guid] = {statKey = value}
local playerHistory = {}  -- [guid] = {log1, log2, ...}

-- Funciones Auxiliares --

local function SendWorldMessage(text)
    SendWorldText(text)
end

local function AddStat(player, key, val)
    local guid = player:GetGUIDLow()
    playerStats[guid] = playerStats[guid] or {}
    playerStats[guid][key] = (playerStats[guid][key] or 0) + val
end

local function AddHistory(player, text)
    local guid = player:GetGUIDLow()
    playerHistory[guid] = playerHistory[guid] or {}
    table.insert(playerHistory[guid], os.date("%X") .. " - " .. text)
    if #playerHistory[guid] > 10 then
        table.remove(playerHistory[guid], 1)
    end
end

local function IsInKingHillZone(player)
    local x,y,z = player:GetX(), player:GetY(), player:GetZ()
    local kz = kingHillZone
    return x >= kz.x1 and x <= kz.x2 and y >= kz.y1 and y <= kz.y2 and z >= kz.z1 and z <= kz.z2
end

local function GetPlayerByGUID(guid)
    for _, p in pairs(GetPlayersInWorld()) do
        if p:GetGUIDLow() == guid then return p end
    end
    return nil
end

-- Menú principal
local function OnGossipHello(event, player, creature)
    player:GossipClearMenu()
    player:GossipMenuAddItem(0, "Juegos de azar", 100, 0)
    player:GossipMenuAddItem(0, "Juegos PvP", 200, 0)
    player:GossipMenuAddItem(0, "Estadísticas e historial", 300, 0)
    player:GossipSendMenu(1, creature)
end

-- Manejo selección menú
local function OnGossipSelect(event, player, creature, sender, intid, code)
    player:GossipClearMenu()
    if sender == 100 then
        -- Juegos de azar
        player:GossipMenuAddItem(0, "Doble o Nada (Duelo Rápido)", GAMES.DUEL_QUICK, 0)
        player:GossipMenuAddItem(0, "Apuesta por muertes", GAMES.KILL_STREAK, 0)
        player:GossipSendMenu(1, creature)

    elseif sender == 200 then
        -- Juegos PvP
        player:GossipMenuAddItem(0, "Duelo Rápido", GAMES.DUEL_QUICK, 1)
        player:GossipMenuAddItem(0, "Caza de Cabezas", GAMES.BOUNTY_HUNT, 1)
        player:GossipMenuAddItem(0, "King of the Hill", GAMES.KING_HILL, 1)
        player:GossipSendMenu(1, creature)

    elseif sender == 300 then
        -- Estadísticas e historial
        local guid = player:GetGUIDLow()
        local stats = playerStats[guid] or {}
        local history = playerHistory[guid] or {}

        player:SendBroadcastMessage("Estadísticas:")
        for k,v in pairs(stats) do
            player:SendBroadcastMessage(k .. ": " .. v)
        end

        player:SendBroadcastMessage("Historial reciente:")
        for _, entry in ipairs(history) do
            player:SendBroadcastMessage(entry)
        end
        player:GossipComplete()

    elseif sender == 0 then
        -- Confirmar apuestas juegos azar
        if intid == GAMES.DUEL_QUICK then
            StartDuelQuick(player)
        elseif intid == GAMES.KILL_STREAK then
            StartKillStreak(player)
        else
            player:GossipComplete()
        end

    elseif sender == 1 then
        -- Confirmar juegos PvP
        if intid == GAMES.DUEL_QUICK then
            StartDuelQuick(player)
        elseif intid == GAMES.BOUNTY_HUNT then
            StartBountyHuntMenu(player, creature)
        elseif intid == GAMES.KING_HILL then
            StartKingHill(player)
        else
            player:GossipComplete()
        end
    else
        player:GossipComplete()
    end
end

-- Inicio Duelo Rápido
function StartDuelQuick(player)
    local bet = COSTS[GAMES.DUEL_QUICK]
    if player:GetCoinage() < bet * 10000 then
        player:SendBroadcastMessage("No tienes suficiente oro para apostar en Duelo Rápido.")
        player:GossipComplete()
        return
    end
    player:ModifyMoney(-bet * 10000)
    player:SendBroadcastMessage("Has apostado "..bet.." oro en Duelo Rápido. Busca un oponente para comenzar el duelo.")
    AddStat(player, "duelos_rapidos_jugados", 1)
    AddHistory(player, "Apostó "..bet.." oro en Duelo Rápido.")
    player:GossipComplete()
    -- Aquí deberías implementar la lógica de duelo PvP real si deseas
end

-- Inicio King of the Hill
function StartKingHill(player)
    if kingHillActive then
        player:SendBroadcastMessage("King of the Hill ya está en curso.")
        player:GossipComplete()
        return
    end
    local bet = COSTS[GAMES.KING_HILL]
    if player:GetCoinage() < bet * 10000 then
        player:SendBroadcastMessage("No tienes suficiente oro para apostar en King of the Hill.")
        player:GossipComplete()
        return
    end
    player:ModifyMoney(-bet * 10000)
    kingHillActive = true
    kingHillController = player:GetGUIDLow()
    kingHillExpireTime = os.time() + kingHillDuration
    SendWorldMessage("|cFF00FF00[King of the Hill]|r "..player:GetName().." ha comenzado la batalla para controlar la zona!")
    AddStat(player, "king_hill_inicios", 1)
    AddHistory(player, "Comenzó King of the Hill con apuesta "..bet)
    player:GossipComplete()
end

-- Inicio Apuesta por Muertes
function StartKillStreak(player)
    local bet = COSTS[GAMES.KILL_STREAK]
    local guid = player:GetGUIDLow()
    if player:GetCoinage() < bet * 10000 then
        player:SendBroadcastMessage("No tienes suficiente oro para apostar en Apuesta por Muertes.")
        player:GossipComplete()
        return
    end
    if activeKillStreaks[guid] then
        player:SendBroadcastMessage("Ya tienes una apuesta activa de muertes.")
        player:GossipComplete()
        return
    end
    player:ModifyMoney(-bet * 10000)
    activeKillStreaks[guid] = {kills = 0, goal = 5, bet = bet, startTime = os.time()}
    player:SendBroadcastMessage("Apuesta por Muertes iniciada! Mata 5 jugadores en 3 minutos para ganar.")
    SendWorldMessage("|cFF00FF00[Apuestas]|r "..player:GetName().." ha iniciado una apuesta por muertes. ¡Suerte!")
    AddHistory(player, "Inició apuesta por muertes con apuesta "..bet)
    player:GossipComplete()
end

-- Menú Caza de Cabezas (simplificado)
function StartBountyHuntMenu(player, creature)
    player:GossipClearMenu()
    player:GossipMenuAddItem(0, "Función en desarrollo para selección de objetivo.", 0, 0)
    player:GossipSendMenu(1, creature)
end

-- Evento matar jugador
local function OnPlayerKill(event, killer, victim)
    if not killer or not victim then return end

    local killerGUID = killer:GetGUIDLow()
    local victimGUID = victim:GetGUIDLow()

    -- Caza de Cabezas
    if activeBounties[victimGUID] then
        local bounty = activeBounties[victimGUID]
        if killerGUID == bounty.placerGUID then
            local payout = bounty.bet * 2
            killer:ModifyMoney(payout * 10000)
            killer:SendBroadcastMessage("¡Ganaste la caza por matar a "..victim:GetName().."! Recibiste "..payout.." oro.")
            SendWorldMessage("|cFFFF0000[Caza]|r "..killer:GetName().." ganó la caza y recibió "..payout.." oro.")
            killer:CastSpell(killer, 63431, true) -- efecto visual ganar
            AddStat(killer, "cazas_ganadas", 1)
            AddHistory(killer, "Ganó caza de cabeza matando a "..victim:GetName())
            activeBounties[victimGUID] = nil
        end
    end

    -- Apuesta por muertes
    if activeKillStreaks[killerGUID] then
        local data = activeKillStreaks[killerGUID]
        data.kills = data.kills + 1
        killer:SendBroadcastMessage("Has matado a un jugador! ("..data.kills.."/"..data.goal..")")
        if data.kills >= data.goal then
            local payout = data.bet * 2
            killer:ModifyMoney(payout * 10000)
            killer:SendBroadcastMessage("¡Felicidades! Ganaste la apuesta por muertes y recibiste "..payout.." oro.")
            SendWorldMessage("|cFF00FF00[Apuestas]|r "..killer:GetName().." ganó la apuesta por muertes y recibió "..payout.." oro.")
            killer:CastSpell(killer, 63431, true)
            AddStat(killer, "apuestas_muertes_ganadas", 1)
            AddHistory(killer, "Ganó apuesta por muertes")
            activeKillStreaks[killerGUID] = nil
        end
    end

    -- King of the Hill: extender tiempo si controlador mata dentro zona
    if kingHillActive and killerGUID == kingHillController then
        if IsInKingHillZone(killer) then
            kingHillExpireTime = os.time() + kingHillDuration
            killer:SendBroadcastMessage("Has defendido la zona King of the Hill. El tiempo se extiende.")
        end
    end
end

-- Timer para King of the Hill, revisar expiración
local function KingHillTimer()
    if kingHillActive and os.time() >= kingHillExpireTime then
        local player = GetPlayerByGUID(kingHillController)
        if player then
            SendWorldMessage("|cFFFF0000[King of the Hill]|r "..player:GetName().." ha perdido el control de la zona.")
            player:SendBroadcastMessage("Se terminó tu control en King of the Hill.")
        end
        kingHillActive = false
        kingHillController = nil
    end
end

-- Registrar eventos
RegisterCreatureEvent(NPC_ID, 1, OnGossipHello)
RegisterCreatureEvent(NPC_ID, 2, OnGossipSelect)
RegisterPlayerEvent(6, OnPlayerKill)
CreateLuaEvent(KingHillTimer, 1000, 0) -- cada 1 segundo revisar KingHill

-- Autor y módulo info
print("Módulo de apuestas PvP por Yaniel cargado correctamente.")
