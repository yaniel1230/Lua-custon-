local NPC_ID = 123456

-- Posiciones por capital (mapId, x, y, z, o)
local capitals = {
    alliance = {
        { name = "Ventormenta",    map = 0,   x = -8913.23, y = 554.63,   z = 94.38,   o = 0.0 },
        { name = "Forjaz",         map = 0,   x = -4981.25, y = -881.54,  z = 502.21,  o = 0.0 },
        { name = "Darnassus",      map = 1,   x = 9951.52,  y = 2280.32,  z = 1341.39, o = 1.57 },
        { name = "Exodar",         map = 530, x = -4072.1,  y = -12057.3, z = -1.56,   o = 2.4 },
    },
    horde = {
        { name = "Orgrimmar",        map = 1,   x = 1502.68,   y = -4415.42, z = 22.14,   o = 0.0 },
        { name = "Entrañas",         map = 0,   x = 1831.29,   y = 238.52,   z = 60.53,   o = 6.28 },
        { name = "Cima del Trueno",  map = 1,   x = -1274.45,  y = 71.86,    z = 128.16,  o = 5.21 },
        { name = "Lunargenta",       map = 530, x = 9487.43,   y = -7279.55, z = 14.29,   o = 1.64 },
    }
}

-- Mostrar el menú al jugador
function OnGossipHello(event, player, creature)
    player:GossipClearMenu()

    local team = player:GetTeam() -- 0 = Alianza, 1 = Horda
    local opciones = (team == 0) and capitals.alliance or capitals.horde

    player:GossipMenuAddItem(1, "|TInterface/ICONS/inv_misc_map02.png:20|t ¿A qué capital deseas ir?", 0, 999) -- Texto decorativo
    for i, ciudad in ipairs(opciones) do
        player:GossipMenuAddItem(4, "|TInterface/ICONS/spell_arcane_portalironforge.png:20|t Viajar a " .. ciudad.name, 0, i) -- Ícono de portal
    end

    player:GossipSendMenu(1, creature)
end

-- Teletransportar al jugador según su elección
function OnGossipSelect(event, player, creature, sender, intid, code, menu_id)
    local team = player:GetTeam()
    local opciones = (team == 0) and capitals.alliance or capitals.horde

    local ciudad = opciones[intid]
    if ciudad then
        player:Teleport(ciudad.map, ciudad.x, ciudad.y, ciudad.z, ciudad.o)
    else
        player:SendBroadcastMessage("❌ Opción inválida.")
    end

    player:GossipComplete()
end

RegisterCreatureGossipEvent(NPC_ID, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_ID, 2, OnGossipSelect)
