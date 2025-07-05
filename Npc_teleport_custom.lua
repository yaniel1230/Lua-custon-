local NPC_ID = 50000 -- ID del NPC (debe existir en creature_template)

-- Configuración del teletransporte (100% modificable)
local TELEPORT_CONFIG = {
    destination = {
        map = 0,              -- Mapa (0=Este de Reinos)
        x = -8913.23,         -- Coordenada X
        y = 554.633,          -- Coordenada Y
        z = 93.7944,          -- Altura (Z)
        o = 0.614292,         -- Orientación
        name = "Ventormenta"   -- Nombre que se muestra
    },
    cost = 100000,            -- Coste en cobre (100000 = 10 oro)
    gossipIcons = {
        main = "Achievement_Character_Human_Male",
        teleport = "Spell_Arcade_Teleport",
        cancel = "Ability_Spy"
    }
}

-- Función para formatear dinero
local function FormatMoney(copper)
    local gold = math.floor(copper / 10000)
    return string.format("|cFFFFD700%d oro|r", gold)
end

-- Evento al hablar con el NPC
local function OnGossipHello(event, player, creature)
    -- Crear el menú de diálogo
    player:GossipMenuAddItem(0, 
        string.format("|TInterface\\ICONS\\%s:35:35|t Teletransporte a %s", 
        TELEPORT_CONFIG.gossipIcons.main, 
        TELEPORT_CONFIG.destination.name), 
        0, 1, 
        false, 
        string.format("¿Deseas viajar a %s por %s?", 
            TELEPORT_CONFIG.destination.name, 
            FormatMoney(TELEPORT_CONFIG.cost))
    )
    
    player:GossipMenuAddItem(1, 
        string.format("|TInterface\\ICONS\\%s:35:35|t Cancelar", 
        TELEPORT_CONFIG.gossipIcons.cancel), 
        0, 2)
    
    player:GossipSendMenu(1, creature)
end

-- Evento al seleccionar opción
local function OnGossipSelect(event, player, creature, sender, intid, code)
    if intid == 1 then -- Opción de teletransporte
        -- Verificar combate
        if player:IsInCombat() then
            player:SendBroadcastMessage("|cFFFF0000[Servidor]|r No puedes viajar en combate.")
            player:GossipComplete()
            return
        end
        
        -- Verificar dinero
        if player:GetCoinage() < TELEPORT_CONFIG.cost then
            player:SendBroadcastMessage(string.format("|cFFFF0000[Servidor]|r Necesitas %s para este viaje.", 
                FormatMoney(TELEPORT_CONFIG.cost)))
            player:GossipComplete()
            return
        end
        
        -- Realizar teletransporte
        player:ModifyMoney(-TELEPORT_CONFIG.cost)
        player:Teleport(
            TELEPORT_CONFIG.destination.map,
            TELEPORT_CONFIG.destination.x,
            TELEPORT_CONFIG.destination.y,
            TELEPORT_CONFIG.destination.z,
            TELEPORT_CONFIG.destination.o
        )
        
        -- Mensaje de confirmación
        player:SendBroadcastMessage(string.format("|cFF00FF00[Servidor]|r ¡Viaje a %s completado! %s fueron gastados.",
            TELEPORT_CONFIG.destination.name,
            FormatMoney(TELEPORT_CONFIG.cost)))
            
    elseif intid == 2 then -- Opción cancelar
        player:SendBroadcastMessage("|cFF00FF00[Servidor]|r Viaje cancelado.")
    end
    
    player:GossipComplete()
end

-- Evento al aparecer el NPC
local function OnSpawn(event, creature)
    creature:SetNPCFlags(1) -- Flag para NPC con diálogo
    creature:SendUnitSay(string.format("Teletransportes a %s disponibles por %s!", 
        TELEPORT_CONFIG.destination.name, 
        FormatMoney(TELEPORT_CONFIG.cost)), 0)
end

-- Registrar eventos
RegisterCreatureGossipEvent(NPC_ID, 1, OnGossipHello)  -- EVENT_GOSSIP_HELLO
RegisterCreatureGossipEvent(NPC_ID, 2, OnGossipSelect) -- EVENT_GOSSIP_SELECT
RegisterCreatureEvent(NPC_ID, 5, OnSpawn)              -- EVENT_ON_SPAWN

-- Mensaje de carga
print(string.format("[NPC Teletransporte] Script cargado: NPC %d - Destino: %s - Coste: %s",
    NPC_ID,
    TELEPORT_CONFIG.destination.name,
    FormatMoney(TELEPORT_CONFIG.cost)))
