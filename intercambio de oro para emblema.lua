local FROST_EMBLEM_ID = 49426
local EXCHANGE_RATE = 10000
local NPC_ENTRY = 80000

-- Función para formatear el oro
local function FormatGold(money)
    local gold = math.floor(money / 10000)
    local silver = math.floor((money % 10000) / 100)
    local copper = money % 100
    return string.format("%d|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t %d|TInterface\\MoneyFrame\\UI-SilverIcon:0:0:2:0|t %d|TInterface\\MoneyFrame\\UI-CopperIcon:0:0:2:0|t", gold, silver, copper)
end

local function OnGossipHello(event, player, creature)
    -- Configuración inicial
    local playerMoney = player:GetCoinage()
    local maxCanBuy = math.floor(playerMoney / EXCHANGE_RATE)
    
    -- Saludo aleatorio
    local greetings = {
        "¡Bienvenido, aventurero! ¿Necesitas Emblemas de Escarcha?",
        "Cambio seguro de oro a emblemas, ¡garantizado!",
        "Los mejores tipos de cambio en todo Azeroth, ¡solo aquí!"
    }
    player:GossipSetText(string.format("%s\n\nTasa actual: %s oro por 1 Emblema\nTienes: %s oro\nPuedes obtener hasta %d Emblemas", 
        greetings[math.random(1, #greetings)],
        FormatGold(EXCHANGE_RATE),
        FormatGold(playerMoney),
        maxCanBuy))
    
    -- Opciones de compra
    if maxCanBuy >= 1 then
        player:GossipMenuAddItem(2, "Comprar 1 Emblema ("..FormatGold(1*EXCHANGE_RATE)..")", 0, 1)
    end
    if maxCanBuy >= 5 then
        player:GossipMenuAddItem(2, "Comprar 5 Emblemas ("..FormatGold(5*EXCHANGE_RATE)..")", 0, 5)
    end
    if maxCanBuy >= 10 then
        player:GossipMenuAddItem(2, "Comprar 10 Emblemas ("..FormatGold(10*EXCHANGE_RATE)..")", 0, 10)
    end
    if maxCanBuy > 10 then
        player:GossipMenuAddItem(2, "Comprar máximo posible ("..maxCanBuy..")", 0, maxCanBuy)
    end
    
    -- Bonificaciones semanales (ejemplo simplificado)
    local weekday = os.date("%w") -- 0-6 (0=Domingo)
    if weekday == "2" then -- Martes
        player:GossipMenuAddItem(0, "|cff00ff00Bonificación especial hoy:|r ¡1 emblema gratis por cada 5 comprados!", 0, 0)
    elseif weekday == "0" or weekday == "6" then -- Fin de semana
        player:GossipMenuAddItem(0, "|cff00ff00Bonificación especial:|r 10% de descuento en fines de semana", 0, 0)
    end
    
    player:GossipMenuAddItem(5, "Salir", 0, 999)
    player:GossipSendMenu(creature)
end

local function OnGossipSelect(event, player, creature, sender, intid, code)
    if intid == 999 then
        player:GossipComplete()
        return
    end
    
    if intid > 0 and intid <= 1000 then
        local amount = intid
        local totalCost = amount * EXCHANGE_RATE
        local playerMoney = player:GetCoinage()
        
        if playerMoney >= totalCost then
            -- Aplicar bonificación de martes
            local finalAmount = amount
            local bonusMessage = ""
            if os.date("%w") == "2" then -- Martes
                local bonusEmblems = math.floor(amount / 5)
                finalAmount = finalAmount + bonusEmblems
                if bonusEmblems > 0 then
                    bonusMessage = string.format(" |cff00ff00(+%d de bonificación)|r", bonusEmblems)
                end
            elseif os.date("%w") == "0" or os.date("%w") == "6" then -- Fin de semana
                totalCost = math.floor(totalCost * 0.9) -- 10% de descuento
                bonusMessage = " |cff00ff00(10% de descuento)|r"
            end
            
            -- Procesar transacción
            player:ModifyMoney(-totalCost)
            player:AddItem(FROST_EMBLEM_ID, finalAmount)
            
            -- Efectos y mensajes
            creature:SendUnitSay("¡Transacción completada con éxito!", 0)
            player:SendBroadcastMessage(string.format("Has obtenido %d Emblemas de Escarcha por %s%s", 
                finalAmount, FormatGold(totalCost), bonusMessage))
            player:PlayDirectSound(6123) -- Sonido de monedas
            
            -- Efecto visual (usando spell de aura de escarcha)
            creature:CastSpell(player, 12544, true) -- Aura de Escarcha
        else
            player:SendNotification("No tienes suficiente oro para esta transacción")
        end
    end
    
    -- Mostrar menú nuevamente
    OnGossipHello(event, player, creature)
end

RegisterCreatureGossipEvent(NPC_ENTRY, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_ENTRY, 2, OnGossipSelect)
