-- =============================================
-- NPC de Cambio Oro -> Emblemas de Escarcha
-- Versión 2.0 (Corregida y Optimizada)
-- Para AzerothCore (WotLK 3.3.5a)
-- =============================================

-- CONFIGURACIÓN BÁSICA
local FROST_EMBLEM_ID = 49426  -- ID del Emblema de Escarcha
local EXCHANGE_RATE = 10000     -- 10,000 de oro por 1 emblema
local NPC_ENTRY = 80000         -- Entry ID de tu NPC personalizado

-- DATOS REUTILIZABLES
local RANDOM_GREETINGS = {
    "¡Bienvenido, aventurero! ¿Necesitas Emblemas de Escarcha?",
    "Cambio seguro de oro a emblemas, ¡garantizado!",
    "Los mejores tipos de cambio en todo Azeroth, ¡solo aquí!"
}

local WEATHER_EFFECTS = {
    ["sunny"] = {text = "|cffffcc00¡Día soleado perfecto para comerciar!|r", sound = 0},
    ["rain"] = {text = "|cff3399ffLa lluvia aumenta el valor de los emblemas un 2%|r", sound = 8458},
    ["snow"] = {text = "|cff99ffff¡Nieva en Northrend! Emblemas con descuento|r", sound = 3439}
}

local KINGDOM_NEWS = {
    "Nueva incursión: La Cámara de los Lores Azules abierta!",
    "Torreón de la Mano ha sido conquistado por "..({"la Alianza","la Horda"})[math.random(1,2)],
    "Evento PvP esta noche: Batalla por Gilneas"
}

local LOYALTY_LEVELS = {
    {name = "Novato", color = "00ccff", min = 20, max = 49, next = "50 compras para rango Plata"},
    {name = "Plata", color = "c0c0c0", min = 50, max = 99, next = "100 compras para rango Oro"},
    {name = "Oro", color = "ffd700", min = 100, max = 100, next = "¡Máximo nivel alcanzado!"}
}

-- FUNCIÓN PRINCIPAL DEL MENÚ
local function ShowExchangeMenu(event, player, creature)
    -- Animaciones y efectos iniciales
    creature:PerformAnimDelay(133)  -- Animación de hablar
    creature:SetFacingToObject(player)  -- Se gira hacia el jugador
    
    player:GossipClearMenu()  -- Limpiar menú anterior
    
    -- Cálculos iniciales
    local playerMoney = player:GetCoinage()
    local maxCanBuy = math.floor(playerMoney / EXCHANGE_RATE)
    local currentWeather = ({"sunny", "rain", "snow"})[math.random(1, 3)]
    local loyaltyData = LOYALTY_LEVELS[math.random(1, #LOYALTY_LEVELS)]
    local progress = math.random(loyaltyData.min, loyaltyData.max)
    
    -- Encabezado con saludo aleatorio
    player:GossipMenuAddItem(0, "|cff00ccff"..RANDOM_GREETINGS[math.random(1, #RANDOM_GREETINGS)].."|r", 0, 0)
    player:GossipMenuAddItem(0, "----------------------------------", 0, 0)
    
    -- Efecto climático
    player:GossipMenuAddItem(0, WEATHER_EFFECTS[currentWeather].text, 0, 0)
    if WEATHER_EFFECTS[currentWeather].sound ~= 0 then
        player:PlayDirectSound(WEATHER_EFFECTS[currentWeather].sound)
    end
    
    player:GossipMenuAddItem(0, "----------------------------------", 0, 0)
    
    -- Información de intercambio
    player:GossipMenuAddItem(0, string.format("Tasa actual: |cffff0000%s|r oro por 1 Emblema", GetCoinTextureString(EXCHANGE_RATE)), 0, 0)
    player:GossipMenuAddItem(0, string.format("Tienes: |cff00ff00%s|r oro", GetCoinTextureString(playerMoney)), 0, 0)
    player:GossipMenuAddItem(0, string.format("Puedes obtener hasta |cff00ff00%d|r Emblemas", maxCanBuy), 0, 0)
    player:GossipMenuAddItem(0, "----------------------------------", 0, 0)
    
    -- Opciones de compra con iconos
    if maxCanBuy >= 1 then
        player:GossipMenuAddItem(2, "|TInterface\\Icons\\inv_misc_coin_01:25|t Comprar 1 Emblema ("..GetCoinTextureString(1*EXCHANGE_RATE)..")", 0, 1)
    end
    if maxCanBuy >= 5 then
        player:GossipMenuAddItem(2, "|TInterface\\Icons\\inv_misc_coin_03:25|t Comprar 5 Emblemas ("..GetCoinTextureString(5*EXCHANGE_RATE)..")", 0, 5)
    end
    if maxCanBuy >= 10 then
        player:GossipMenuAddItem(2, "|TInterface\\Icons\\inv_misc_coin_05:25|t Comprar 10 Emblemas ("..GetCoinTextureString(10*EXCHANGE_RATE)..")", 0, 10)
    end
    if maxCanBuy > 10 then
        player:GossipMenuAddItem(2, "|TInterface\\Icons\\achievement_guildperk_cashflow:25|t Comprar máximos posibles ("..maxCanBuy..")", 0, maxCanBuy)
    end
    
    -- Programa de fidelidad
    player:GossipMenuAddItem(0, "----------------------------------", 0, 0)
    player:GossipMenuAddItem(0, "|cff00ccffPrograma de Fidelidad:|r", 0, 0)
    player:GossipMenuAddItem(0, string.format("Rango actual: |cff%s%s|r", loyaltyData.color, loyaltyData.name), 0, 0)
    player:GossipMenuAddItem(0, string.format("Progreso: |cff00ff00%d%%|r", progress), 0, 0)
    player:GossipMenuAddItem(0, "Siguiente nivel: "..loyaltyData.next, 0, 0)
    
    -- Noticias del reino
    player:GossipMenuAddItem(0, "----------------------------------", 0, 0)
    player:GossipMenuAddItem(0, "|cff00ccffNoticias del Reino:|r", 0, 0)
    player:GossipMenuAddItem(0, "|TInterface\\GossipFrame\\DailyActiveQuestIcon:20|t "..KINGDOM_NEWS[math.random(1, #KINGDOM_NEWS)], 0, 0)
    
    -- Pie de página
    player:GossipMenuAddItem(0, "----------------------------------", 0, 0)
    player:GossipMenuAddItem(0, "|cff888888Servidor: Frostmourne v3.3.5a|r", 0, 0)
    
    player:GossipMenuAddItem(5, "|TInterface/ICONS/Ability_Spy:30|t Salir", 0, 999)
    player:GossipSendMenu(1, creature)
end

-- FUNCIÓN DE SELECCIÓN DE OPCIONES
local function OnSelectOption(event, player, creature, sender, intid, code)
    if intid == 999 then
        player:GossipComplete()
        return
    end
    
    if intid > 0 and intid <= 1000 then  -- Límite seguro
        local amount = intid
        local totalCost = amount * EXCHANGE_RATE
        local playerMoney = player:GetCoinage()
        
        if playerMoney >= totalCost then
            -- Procesar transacción
            player:ModifyMoney(-totalCost)
            player:AddItem(FROST_EMBLEM_ID, amount)
            
            -- Efectos de confirmación
            player:PlayDirectSound(6123)  -- Sonido de transacción
            creature:SendUnitEmote("Entrega cuidadosamente los emblemas al jugador.", player)
            
            -- Mensaje de éxito
            player:SendBroadcastMessage(string.format("|cff00ff00Has cambiado %s oro por |cffff0000%d|r Emblemas de Escarcha.|r", 
                GetCoinTextureString(totalCost), amount))
        else
            player:SendBroadcastMessage("|cffff0000No tienes suficiente oro para esta transacción.|r")
        end
    end
    
    -- Mostrar menú nuevamente
    ShowExchangeMenu(event, player, creature)
end

-- REGISTRO DE EVENTOS
RegisterCreatureGossipEvent(NPC_ENTRY, 1, ShowExchangeMenu)
RegisterCreatureGossipEvent(NPC_ENTRY, 2, OnSelectOption)

-- =============================================
-- FIN DEL SCRIPT
-- =============================================