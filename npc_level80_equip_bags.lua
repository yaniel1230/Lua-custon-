
local NPC_ID = 90000
local COSTE_ORO = 10000000 -- 1,000 de oro en cobre
local NIVEL_OBJETIVO = 80

-- Tabla de ítems iniciales por clase
local equipo_por_clase = {
    [1] = {38661, 38663, 38665, 38666, 38667, 38668, 38669, 38670}, -- Guerrero
    [2] = {38661, 38663, 38665, 38666, 38667, 38668, 38669, 38670}, -- Paladín
    [3] = {23399, 23400, 23401, 23402, 23403, 23404, 23405},        -- Cazador
    [4] = {23399, 23400, 23401, 23402, 23403, 23404, 23405},        -- Pícaro
    [5] = {23389, 23390, 23391, 23392, 23393},                      -- Sacerdote
    [6] = {38661, 38663, 38665, 38666, 38667, 38668, 38669, 38670}, -- Caballero de la Muerte
    [7] = {23399, 23400, 23401, 23402, 23403, 23404, 23405},        -- Chamán
    [8] = {23389, 23390, 23391, 23392, 23393},                      -- Mago
    [9] = {23389, 23390, 23391, 23392, 23393},                      -- Brujo
    [11] = {23399, 23400, 23401, 23402, 23403, 23404, 23405},       -- Druida
}

-- Bolsa que se entregará (puedes cambiar por otra con más espacio si quieres)
local BOLSA_ID = 50317
local CANTIDAD_BOLSAS = 4

function OnGossipHello(event, player, creature)
    player:GossipClearMenu()
    player:GossipMenuAddItem(0, "Subirme al nivel 80 por 1,000 de oro", 0, 1)
    player:GossipSendMenu(1, creature)
end

function OnGossipSelect(event, player, creature, sender, intid)
    if intid == 1 then
        player:GossipClearMenu()
        if player:GetLevel() >= NIVEL_OBJETIVO then
            player:SendBroadcastMessage("Ya eres nivel 80 o superior.")
        elseif player:GetCoinage() >= COSTE_ORO then
            player:ModifyMoney(-COSTE_ORO)
            player:SetLevel(NIVEL_OBJETIVO)
            player:AdvanceSkillsToMax()
            player:LearnAllClassSpells()
            player:SendBroadcastMessage("Has sido ascendido al nivel 80 y has aprendido todas tus habilidades.")

            -- Dar equipo por clase
            local clase = player:GetClass()
            local equipo = equipo_por_clase[clase]
            if equipo then
                for _, itemId in ipairs(equipo) do
                    player:AddItem(itemId, 1)
                end
                player:SendBroadcastMessage("¡Recibiste tu equipo inicial!")
            else
                player:SendBroadcastMessage("Tu clase no tiene equipo configurado.")
            end

            -- Dar bolsas
            for i = 1, CANTIDAD_BOLSAS do
                player:AddItem(BOLSA_ID, 1)
            end
            player:SendBroadcastMessage("¡Has recibido 4 bolsas!")

        else
            player:SendBroadcastMessage("No tienes suficiente oro. Necesitas 1,000 de oro.")
        end
        player:GossipComplete()
    end
end

RegisterCreatureGossipEvent(NPC_ID, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_ID, 2, OnGossipSelect)
