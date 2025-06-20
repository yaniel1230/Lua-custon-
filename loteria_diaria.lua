
local NPC_ID = 90000
local DAILY_ID = 50001 -- ID ficticio para marcar la participación diaria

-- Convierte segundos a formato 00h 00m
local function SecondsToTimeString(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    return string.format("%02dh %02dm", hours, minutes)
end

-- Verifica si el jugador ya participó hoy
local function HasPlayedToday(player)
    return player:HasDailyQuest(DAILY_ID)
end

-- Marca al jugador como que ya participó hoy
local function MarkAsPlayed(player)
    player:SaveToDB()
    player:AddQuest(DAILY_ID)
end

-- Menú de bienvenida
local function OnGossipHello(event, player, creature)
    creature:SendUnitSay("¡Bienvenido a la lotería, " .. player:GetName() .. "! ¿Te atreves a probar tu suerte por 100 de oro?", 0)
    player:GossipClearMenu()

    if HasPlayedToday(player) then
        local resetTime = player:GetDailyQuestResetTime()
        local now = os.time()
        local remaining = resetTime - now
        if remaining < 0 then remaining = 0 end
        local timeStr = SecondsToTimeString(remaining)
        player:GossipMenuAddItem(0, "Ya participaste hoy. Vuelve en: " .. timeStr, 0, 0)
    else
        player:GossipMenuAddItem(0, "Participar en la lotería (100 de oro)", 0, 1)
    end

    player:GossipSendMenu(1, creature)
end

-- Resultado de la lotería
local function OnGossipSelect(event, player, creature, sender, intid, code)
    if intid == 1 then
        local entryFee = 10000 * 100 -- 100 oro

        if player:GetCoinage() >= entryFee then
            player:ModifyMoney(-entryFee)
            creature:SendUnitSay("¡Veamos qué tan afortunado eres!", 0)

            local roll = math.random(1, 100)
            local reward = 0

            if roll <= 40 then
                reward = 0
                player:SendBroadcastMessage("¡Nada esta vez! Mejor suerte la próxima.")
                creature:SendUnitSay("¡JAJA! ¡Perdiste tu oro!", 0)
                creature:Emote(11) -- Emote de risa
            elseif roll <= 70 then
                reward = 150000
                player:SendBroadcastMessage("Ganaste 150 de oro. ¡No está mal!")
                creature:Emote(66) -- Emote aplauso
            elseif roll <= 90 then
                reward = 300000
                player:SendBroadcastMessage("¡Ganaste 300 de oro!")
                creature:Emote(66)
                SendWorldMessage("|cff00ff00[LOTERÍA]|r " .. player:GetName() .. " ha ganado 300 de oro en la lotería.")
            elseif roll <= 99 then
                reward = 500000
                player:SendBroadcastMessage("¡Gran suerte! ¡500 de oro para ti!")
                creature:Emote(66)
                SendWorldMessage("|cff00ff00[LOTERÍA]|r " .. player:GetName() .. " ha ganado 500 de oro en la lotería.")
            else
                reward = 1000000
                player:SendBroadcastMessage("¡JACKPOT! ¡Has ganado 1000 de oro!")
                creature:Emote(66)
                SendWorldMessage("|cffff8000[LOTERÍA]|r " .. player:GetName() .. " ha ganado el PREMIO MAYOR de 1000 de oro en la lotería.")
            end

            if reward > 0 then
                player:ModifyMoney(reward)
            end

            MarkAsPlayed(player)
        else
            player:SendBroadcastMessage("No tienes suficiente oro.")
        end

        player:GossipComplete()
        creature:SendUnitSay("¡Gracias por participar, " .. player:GetName() .. "! Vuelve mañana para otra oportunidad.", 0)
    else
        player:GossipComplete()
    end
end

-- Registra los eventos del NPC
RegisterCreatureGossipEvent(NPC_ID, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_ID, 2, OnGossipSelect)
