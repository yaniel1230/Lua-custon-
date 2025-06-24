-- ================= CONFIGURACIÓN PRINCIPAL ================= --
local ARTHAS_ENTRY = 445081
local DEBUG_MODE = false  -- True para solo registrar sin actuar

-- Spells prohibidos y sus mensajes
local CHEAT_SPELLS = {
    [1787]  = "Invisibilidad (Hampa)",
    [32612] = "Invisibilidad Avanzada",
    [41451] = "Vanish (Pícaro)",
    [31621] = "Vuelo no autorizado",
    [11392] = "Speed hacking",
    [22888] = "Salto ilegal"
}

-- Zonas donde ciertos cheats son permitidos
local LEGIT_ZONES = {
    [37] = true,    -- Shadowfang Keep
    [189] = true,   -- Scarlet Monastery
    [4395] = true   -- Dalaran (vuelo permitido)
}

-- Umbrales de detección
local TELEPORT_THRESHOLD = 100  -- Yardas
local SPEED_THRESHOLD = 7.0     -- Velocidad base
local CHECK_INTERVAL = 1000     -- ms entre chequeos

-- ================= VARIABLES DEL SISTEMA ================= --
local PLAYER_WARNINGS = {}
local LAST_PLAYER_POSITIONS = {}
local WARNING_MESSAGES = {
    [1] = "|cFFFF0000[ARTHAS]|r Advertencia #1: %s",
    [2] = "|cFFFF0000[ARTHAS]|r ¡Última oportunidad! (%s)",
    [3] = "|cFFFF0000[ARTHAS]|r Baneado: %s"
}

-- ================= FUNCIONES PRINCIPALES ================= --

-- Manejo de infracciones
local function HandleCheat(player, offense, spellId)
    local guid = player:GetGUIDLow()
    PLAYER_WARNINGS[guid] = (PLAYER_WARNINGS[guid] or 0) + 1
    local warningLevel = PLAYER_WARNINGS[guid]
    spellId = spellId or 0

    -- Acción según nivel de advertencia
    if not DEBUG_MODE then
        if warningLevel == 1 then
            player:CastSpell(player, 27740, true)  -- Stun visual
        elseif warningLevel == 2 then
            player:KickPlayer()
        else
            WorldDBExecute(string.format(
                "INSERT INTO account_banned VALUES (%d, UNIX_TIMESTAMP(), UNIX_TIMESTAMP() + 86400, 'Arthas', '%s', 1)",
                player:GetAccountId(), offense
            ))
            player:KickPlayer()
        end
    end

    -- Mensaje al jugador
    player:SendBroadcastMessage(WARNING_MESSAGES[math.min(warningLevel, 3)]:format(offense))

    -- Registro en DB
    CharDBExecute(string.format(
        "INSERT INTO arthas_logs (player_guid, player_name, offense, warning_level, spell_id, timestamp) "..
        "VALUES (%d, '%s', '%s', %d, %d, UNIX_TIMESTAMP())",
        guid, player:GetName(), offense, warningLevel, spellId
    ))

    print(string.format("[Arthas] %s - %s (Nivel %d)", player:GetName(), offense, warningLevel))
end

-- Detección de movimiento ilegal
local function CheckMovement(player)
    local guid = player:GetGUIDLow()
    local currentPos = player:GetLocation()
    local currentTime = GetTime()

    if LAST_PLAYER_POSITIONS[guid] then
        local lastPos = LAST_PLAYER_POSITIONS[guid].pos
        local lastTime = LAST_PLAYER_POSITIONS[guid].time
        local distance = lastPos:GetDistance(currentPos)
        local timeDiff = (currentTime - lastTime) * 1000  -- Convertir a ms

        -- Teleport hacking
        if distance > TELEPORT_THRESHOLD and timeDiff < 1000 and not player:IsTaxiFlying() then
            HandleCheat(player, string.format("Teleport hacking (%dy en %dms)", distance, timeDiff))
            player:Teleport(player:GetMapId(), lastPos.x, lastPos.y, lastPos.z)
            return
        end

        -- Speed hacking
        local speed = (distance / timeDiff) * 1000  -- yardas/segundo
        if speed > SPEED_THRESHOLD and not player:HasAuraType(SPELL_AURA_MOD_INCREASE_SPEED) then
            HandleCheat(player, string.format("Speed hacking (%.1f y/s)", speed))
            return
        end
    end

    LAST_PLAYER_POSITIONS[guid] = { pos = currentPos, time = currentTime }
end

-- Detección de spells prohibidos
local function CheckSpells(player)
    for i = 1, 40 do  -- Revisar todos los slots de aura
        local spellId = player:GetAuraSpellId(i)
        if spellId and CHEAT_SPELLS[spellId] and not LEGIT_ZONES[player:GetZoneId()] then
            HandleCheat(player, CHEAT_SPELLS[spellId], spellId)
            player:RemoveAura(spellId)
        end
    end
end

-- Detección de vuelo ilegal
local function CheckFlying(player)
    if player:IsFlying() and not player:CanFly() and not LEGIT_ZONES[player:GetZoneId()] then
        HandleCheat(player, "Vuelo ilegal", 31621)
        player:SetMovement(MOVE_LAND_WALK)
    end
end

-- ================= EVENTOS Y REGISTROS ================= --

local function OnPlayerUpdate(event, player, diff)
    if player:IsGM() then return end
    
    CheckSpells(player)
    CheckMovement(player)
    CheckFlying(player)
end

-- Reset diario de advertencias
local function ResetWarnings()
    PLAYER_WARNINGS = {}
    print("[Arthas] Contadores de advertencias reiniciados")
end

-- Registro de eventos
RegisterPlayerEvent(8, OnPlayerUpdate)  -- EVENT_ON_PLAYER_UPDATE
CreateLuaEvent(ResetWarnings, 86400000, 0)  -- Reset cada 24 horas

-- ================= INICIALIZACIÓN ================= --

print("[Arthas] Sistema anti-cheat cargado correctamente")
print(string.format("• %d spells prohibidos configurados", #CHEAT_SPELLS))
print(string.format("• %d zonas seguras definidas", #LEGIT_ZONES))
