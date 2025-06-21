-- =============================================
-- CONFIGURACIÓN PRINCIPAL (EDITABLE)
-- =============================================
local ChannelName = "|cff00FF00[Mundo]|r"
local SPAM_COOLDOWN = 5  -- Segundos entre mensajes
local MIN_LEVEL = 10     -- Nivel mínimo para usar el chat
local ACTIVATION_CMD = ".chat on"  -- Comando de activación
local SHOW_LOCATION = true  -- Mostrar ubicación del jugador

-- =============================================
-- SISTEMA DE FILTRADO DE LENGUAJE (COMPLETO)
-- =============================================
local PALABRAS_PROHIBIDAS = {
    -- Palabras explícitas
    "pinga", "tarru", "singao", "puta", "culo", "cago", "verga", "coño", 
    "mierda", "joder", "cabrón", "maricón", "pene", "vagina", "sexo", 
    "follar", "nalgas", "tetas", "porno", "prostituta", "zorra", "malparido",
    
    -- Variantes y evasiones
    "puto", "put@", "pvt@", "m1erda", "jod3r", "c4brón", "m4ricón", 
    "s3xo", "f0llar", "p0rno", "v1rg3n", "ñññ", "xxx", "pene", "polla",
    
    -- Internacionales
    "fuck", "shit", "bitch", "asshole", "cunt", "dick", "pussy", "whore"
}

local function NormalizarTexto(texto)
    local reemplazos = {
        ["@"] = "a", ["4"] = "a", ["3"] = "e", ["1"] = "i", ["!"] = "i",
        ["0"] = "o", ["$"] = "s", ["5"] = "s", ["*"] = "", ["."] = "",
        ["-"] = "", ["_"] = "", [" "] = ""
    }
    return texto:lower():gsub(".", reemplazos)
end

local function ContieneLenguajeInapropiado(texto)
    local normalizado = NormalizarTexto(texto)
    for _, palabra in ipairs(PALABRAS_PROHIBIDAS) do
        if string.find(normalizado, NormalizarTexto(palabra)) then
            return true, palabra
        end
    end
    return false
end

-- =============================================
-- SISTEMA DE DATOS OPTIMIZADO (CACHÉ)
-- =============================================
local FACTION_ICONS = {
    [0] = "|TInterface/icons/Inv_Misc_Tournaments_banner_Human.png:13|t", -- Alianza
    [1] = "|TInterface/icons/Inv_Misc_Tournaments_banner_Orc.png:13|t"    -- Horda
}

local CLASS_DATA = {
    [1]  = { icon = "|TInterface\\icons\\INV_Sword_27.png:13|t", color = "|cffC79C6E" }, -- Guerrero
    -- ... (completar con todas las clases)
}

local RACE_ICONS = {
    [1] = { -- Masculino
        [1] = "|TInterface/ICONS/Achievement_Character_Human_Male:13|t",
        -- ... (completar razas)
    },
    [2] = { -- Femenino
        [1] = "|TInterface/ICONS/Achievement_Character_Human_Female:13|t",
        -- ... (completar razas)
    }
}

local GM_ICON = "|TINTERFACE/CHATFRAME/UI-CHATICON-BLIZZ:13|t"

-- =============================================
-- NÚCLEO DE OPTIMIZACIÓN
-- =============================================
local playerCache = {}
local lastMessageTimes = {}
local chatEnabled = {}

local function UpdateCache(player)
    local guid = player:GetGUID()
    if not playerCache[guid] then
        playerCache[guid] = {
            name = player:GetName(),
            team = player:GetTeam(),
            gender = player:GetGender() + 1,
            race = player:GetRace(),
            class = player:GetClass(),
            level = player:GetLevel(),
            isGM = player:IsGM(),
            zone = SHOW_LOCATION and GetZoneName(player) or nil
        }
    end
    return playerCache[guid]
end

-- =============================================
-- MANEJADORES PRINCIPALES (ULTRA-OPTIMIZADOS)
-- =============================================
local function OnChatCommand(event, player, command)
    local cmd = command:lower()
    if cmd == "chat on" then
        local cached = UpdateCache(player)
        
        if cached.level < MIN_LEVEL and not cached.isGM then
            player:SendAreaTriggerMessage("|cffFF0000Requieres nivel "..MIN_LEVEL.."+|r")
            return false
        end
        
        chatEnabled[player:GetGUID()] = true
        player:SendAreaTriggerMessage("|cff00FF00Chat global ACTIVADO.|r Usa |cffFFFF00DECIR|r o |cffFFFF00GRITAR|r.")
        return false
        
    elseif cmd == "chat off" then
        chatEnabled[player:GetGUID()] = nil
        player:SendAreaTriggerMessage("|cffFF0000Chat global DESACTIVADO.|r")
        return false
    end
end

local function OnChatMessage(event, player, msg, lang, channel)
    if channel ~= 1 and channel ~= 6 then return end
    
    -- Verificación ultra-rápida
    local guid = player:GetGUID()
    if not chatEnabled[guid] then
        player:SendAreaTriggerMessage("|cffFFA500Escribe |cffFFFF00"..ACTIVATION_CMD.."|r para usar el chat global.|r")
        return false
    end

    -- Anti-spam con tiempo unix
    local currentTime = os.time()
    if (currentTime - (lastMessageTimes[guid] or 0)) < SPAM_COOLDOWN then
        player:SendAreaTriggerMessage("|cffFF0000Espera "..(SPAM_COOLDOWN - (currentTime - (lastMessageTimes[guid] or 0))).."s.|r")
        return false
    end

    -- Filtrado de lenguaje (optimizado)
    local esInapropiado, palabra = ContieneLenguajeInapropiado(msg)
    if esInapropiado then
        player:SendAreaTriggerMessage("|cffFF0000Advertencia:|r Palabra bloqueada: '"..palabra.."'")
        SendWorldMessageToGMs("|cffFF0000[ALERTA]|r "..player:GetName().." intentó decir: "..msg:sub(1, 50).."...")
        return false
    end

    -- Construcción de mensaje optimizada
    local cached = UpdateCache(player)
    local messageParts = { ChannelName }
    
    if cached.isGM then
        table.insert(messageParts, GM_ICON)
        table.insert(messageParts, string.format("[GM][%s][Nv.%d]", cached.name, cached.level))
    else
        local classInfo = CLASS_DATA[cached.class] or { icon = "", color = "|cffFFFFFF" }
        local raceIcon = (RACE_ICONS[cached.gender] and RACE_ICONS[cached.gender][cached.race]) or ""
        
        table.insert(messageParts, FACTION_ICONS[cached.team] or "")
        table.insert(messageParts, raceIcon)
        table.insert(messageParts, classInfo.icon)
        table.insert(messageParts, string.format("%s%s|r[Nv.%d]", classInfo.color, cached.name, cached.level))
    end

    if cached.zone then
        table.insert(messageParts, "["..cached.zone.."]")
    end

    table.insert(messageParts, ": "..msg)
    
    -- Envío final
    SendWorldMessage(table.concat(messageParts))
    lastMessageTimes[guid] = currentTime
    return false
end

-- =============================================
-- REGISTRO DE EVENTOS Y MANTENIMIENTO
-- =============================================
RegisterPlayerEvent(18, OnChatMessage) -- EVENT_ON_CHAT (SAY)
RegisterPlayerEvent(22, OnChatMessage) -- EVENT_ON_YELL
RegisterPlayerEvent(42, OnChatCommand)  -- EVENT_ON_COMMAND

-- Limpieza automática de cache
CreateLuaEvent(function()
    local currentTime = os.time()
    for guid, time in pairs(lastMessageTimes) do
        if (currentTime - time) > 1800 then -- 30 minutos de inactividad
            playerCache[guid] = nil
            lastMessageTimes[guid] = nil
            chatEnabled[guid] = nil
        end
    end
end, 1800000, 0) -- Ejecutar cada 30 minutos

-- Ayuda al logearse
RegisterPlayerEvent(3, function(event, player)
    player:SendBroadcastMessage("|cff00FF00Escribe |cffFFFF00.chat on|r para activar el chat global (Nv. "..MIN_LEVEL.."+)|r")
end)