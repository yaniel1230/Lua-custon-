-- npc_teleport_goblin_island_vip.lua
-- Versión compatible con AzerothCore 3.3.5a + Eluna

local NPC_ID = 999000  -- Cambiar por un ID no utilizado
local VIP_COIN_ID = 12345  -- ID del item VIP (ajustar según tu item_template)
local VIP_COIN_COST = 1    -- Cantidad requerida
local GOSSIP_ICON = 6      -- Icono de brújula

-- Coordenadas de la Isla Goblin (ajustar según tu mapa)
local GOBLIN_ISLAND = {
    mapId = 1,        -- Kalimdor
    x = -14499.83,
    y = -490.20,
    z = 15.39,
    o = 0.0
}

-- Textos localizados
local LOCALE = {
    GREET = "|TInterface\\Icons\\inv_misc_coin_01:35|t Por |cFFFFD7001 Moneda VIP|r te llevaré a la Isla Goblin secreta.",
    NO_ITEM = "|cFFFF0000Necesitas una Moneda VIP en tu inventario.|r",
    SUCCESS = "|cFF00FF00¡Teletransportado a la Isla Goblin!|r",
    IN_COMBAT = "|cFFFF0000No puedes viajar durante combate.|r",
    NOT_ENOUGH = "|cFFFF0000No tienes suficientes monedas VIP.|r"
}

-- Función principal del gossip
local function OnGossipHello(event, player, creature)
    -- Mostrar opción solo si tiene el item VIP
    if player:GetItemCount(VIP_COIN_ID) >= VIP_COIN_COST then
        player:GossipMenuAddItem(GOSSIP_ICON, "Viajar a Isla Goblin (1 Moneda VIP)", 0, 1)
    else
        player:GossipMenuAddItem(0, "|TInterface\\Icons\\inv_misc_coin_01:25|t Requieres una Moneda VIP", 0, 99)
    end
    player:GossipSendMenu(1, creature, LOCALE.GREET)
end

-- Función de teletransporte
local function OnGossipSelect(event, player, creature, sender, action, code)
    if action == 1 then
        -- Verificar combate
        if player:IsInCombat() then
            player:SendNotification(LOCALE.IN_COMBAT)
            player:GossipComplete()
            return
        end
        
        -- Verificar monedas VIP
        if player:GetItemCount(VIP_COIN_ID) < VIP_COIN_COST then
            player:SendNotification(LOCALE.NOT_ENOUGH)
            player:GossipComplete()
            return
        end
        
        -- Consumir moneda
        player:RemoveItem(VIP_COIN_ID, VIP_COIN_COST)
        
        -- Teletransportar
        player:Teleport(GOBLIN_ISLAND.mapId, GOBLIN_ISLAND.x, GOBLIN_ISLAND.y, GOBLIN_ISLAND.z, GOBLIN_ISLAND.o)
        player:SendBroadcastMessage(LOCALE.SUCCESS)
        
        -- Efectos opcionales
        player:PlayDirectSound(8595)  -- Sonido de portal
        creature:CastSpell(player, 35517, true)  -- Efecto visual de teletransporte
    end
    
    player:GossipComplete()
end

-- Registrar eventos
RegisterCreatureGossipEvent(NPC_ID, 1, OnGossipHello)  -- EVENT_GOSSIP_HELLO
RegisterCreatureGossipEvent(NPC_ID, 2, OnGossipSelect)  -- EVENT_GOSSIP_SELECT

-- Comando para spawnear el NPC (solo para GMs)
local function OnCommand(event, player, command)
    if command == "spawn vip teleporter" and player:GetGMRank() > 0 then
        player:SpawnCreature(NPC_ID, player:GetX(), player:GetY(), player:GetZ(), player:GetO(), 60, 0)
        player:SendBroadcastMessage("NPC de teletransporte VIP creado por 1 minuto.")
    end
end

RegisterPlayerEvent(42, OnCommand)  -- EVENT_ON_COMMAND
