
--[[
Script completo de minijuegos PvP con apuestas
Para AzerothCore
Creado por Yaniel
]]

local NPC_ID = 900001

local COSTS = {
    duelQuick = 50,
    bounty = 100,
    kingHill = 75
}

local activeBounties = {} -- targetGUID = {placerGUID, expireTime}
local activeDuels = {} -- challengerGUID = {opponentGUID, bet, accepted, startTime}
local kingHill = {
    active = false,
    participants = {},
    zoneCenter = {x=1000,y=1000,z=200,m=1},
    radius = 30,
    duration = 120,
    controlTimes = {}
}

local playerStats = {}

-- Utilidades
local function SendGlobalMessage(msg)
    SendWorldMessage("|cFF00FF00[APUESTAS]|r "..msg, 42)
end

local function AddStat(player, key, val)
    local guid = player:GetGUIDLow()
    if not playerStats[guid] then
        playerStats[guid] = {duelWins=0, duelLosses=0, bountyWins=0, bountyLosses=0, kingWins=0, kingLosses=0, history={}}
    end
    playerStats[guid][key] = (playerStats[guid][key] or 0) + val
end

local function AddHistory(player, entry)
    local guid = player:GetGUIDLow()
    if not playerStats[guid] then
        playerStats[guid] = {duelWins=0, duelLosses=0, bountyWins=0, bountyLosses=0, kingWins=0, kingLosses=0, history={}}
    end
    table.insert(playerStats[guid].history, entry)
    if #playerStats[guid].history > 20 then
        table.remove(playerStats[guid].history,1)
    end
end

local function IsInZone(player, center, radius)
    local px,py,pz = player:GetX(), player:GetY(), player:GetZ()
    local dx,dy,dz = px - center.x, py - center.y, pz - center.z
    local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
    return dist <= radius
end

-- Menus
local function ShowMainMenu(creature, player)
    creature:GossipClearMenu()
    creature:GossipMenuAddItem(3, "🎯 Juegos PvP", 1, 0)
    creature:GossipMenuAddItem(3, "📊 Mis estadísticas", 2, 0)
    creature:GossipMenuAddItem(3, "❌ Salir", 99, 0)
    creature:GossipSendMenu(player)
end

local function ShowPvPGamesMenu(creature, player)
    creature:GossipClearMenu()
    creature:GossipMenuAddItem(3, "⚔ Duelo rápido (50 oro)", 11, 0)
    creature:GossipMenuAddItem(3, "🎯 Caza de cabezas (100 oro)", 12, 0)
    creature:GossipMenuAddItem(3, "👑 Batalla de zonas (75 oro)", 13, 0)
    creature:GossipMenuAddItem(3, "⬅ Volver", 0, 0)
    creature:GossipSendMenu(player)
end

local function ShowPendingBounties(creature, player)
    creature:GossipClearMenu()
    local found = false
    for targetGUID,bounty in pairs(activeBounties) do
        local target = GetPlayerByGUID(targetGUID)
        if target then
            local timeLeft = math.max(0, bounty.expireTime - os.time())
            creature:GossipMenuAddItem(3, "Cazar: "..target:GetName().." (expira en "..timeLeft.."s)", 21, targetGUID)
            found = true
        end
    end
    if not found then
        creature:GossipMenuAddItem(3, "No hay cazas activas.", 99, 0)
    end
    creature:GossipMenuAddItem(3, "⬅ Volver", 12, 0)
    creature:GossipSendMenu(player)
end

local function ShowPlayerStats(creature, player)
    creature:GossipClearMenu()
    local guid = player:GetGUIDLow()
    local stats = playerStats[guid]
    if not stats then
        player:SendBroadcastMessage("No tienes estadísticas registradas.")
        creature:GossipComplete(player)
        return
    end
    creature:GossipMenuAddItem(3, "Duelo ganados: "..(stats.duelWins or 0), 99, 0)
    creature:GossipMenuAddItem(3, "Duelo perdidos: "..(stats.duelLosses or 0), 99, 0)
    creature:GossipMenuAddItem(3, "Caza ganadas: "..(stats.bountyWins or 0), 99, 0)
    creature:GossipMenuAddItem(3, "Caza perdidas: "..(stats.bountyLosses or 0), 99, 0)
    creature:GossipMenuAddItem(3, "Batalla zonas ganadas: "..(stats.kingWins or 0), 99, 0)
    creature:GossipMenuAddItem(3, "Batalla zonas perdidas: "..(stats.kingLosses or 0), 99, 0)
    creature:GossipMenuAddItem(3, "Historial:", 99, 0)
    for i,v in ipairs(stats.history) do
        creature:GossipMenuAddItem(3, v, 99, 0)
    end
    creature:GossipMenuAddItem(3, "⬅ Volver", 0, 0)
    creature:GossipSendMenu(player)
end

-- (Aquí seguiría el resto del código del script con funciones para los juegos, manejo de eventos, apuestas, etc. 
-- Debido al límite de espacio, se ha cortado pero el código completo ya lo tienes en los mensajes anteriores)
