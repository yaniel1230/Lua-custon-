local NPC_ID = 0

-- Lista de apariencias disponibles con escala
local morphs = {
    { nombre = "|TInterface/ICONS/achievement_leader_ thrall.png:20|t Visual Thrall", display = 4527, escala = 1 },
    { nombre = "|TInterface/ICONS/achievement_boss_kael'thassunstrider_01.png:20|t Visual Kael'thas", display = 20023, escala = 0.3 },
    { nombre = "|TInterface/ICONS/achievement_boss_algalon_01.png:20|t Visual Kel'Thuzzad", display = 15945, escala = 0.2 },
    { nombre = "|TInterface/ICONS/achievement_boss_saurfang.png:20|t Visual Gul'Dan", display = 16642, escala = 0.8 },
    { nombre = "|TInterface/ICONS/achievement_leader_ thrall.png:20|t Visual Medivh", display = 18718, escala = 0.9 },
    { nombre = "|TInterface/ICONS/ability_hunter_markedfordeath.png:20|t Quitar visual", display = 0,     escala = 1.0 }
}

function OnGossipHello(event, player, creature)
    player:GossipClearMenu()
    player:GossipMenuAddItem(0, "|TInterface/ICONS/spell_shadow_metamorphosis.png:20|t Elige una apariencia:", 0, 1000)

    for i, morph in ipairs(morphs) do
        player:GossipMenuAddItem(0, morph.nombre, 0, i)
    end

    player:GossipSendMenu(1, creature)
end

function OnGossipSelect(event, player, creature, sender, intid)
    local seleccion = morphs[intid]

    if seleccion then
        if seleccion.display == 0 then
            -- Restaurar apariencia original y escala
            player:SetDisplayId(player:GetNativeDisplayId())
            player:SetScale(1.0)
            player:SendBroadcastMessage("|TInterface/ICONS/spell_arcane_manatap.png:20|t Tu apariencia ha sido restaurada.")
        else
            -- Aplicar morph y escala
            player:SetDisplayId(seleccion.display)
            player:SetScale(seleccion.escala)
            player:SendBroadcastMessage("|TInterface/ICONS/spell_arcane_arcanepotency.png:20|t Has cambiado tu apariencia a: " .. seleccion.nombre)
        end
    end

    player:GossipComplete()
end

RegisterCreatureGossipEvent(NPC_ID, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_ID, 2, OnGossipSelect)

-- Autor y módulo info
print("Módulo de apuestas PvP por Yaniel cargado correctamente.")
