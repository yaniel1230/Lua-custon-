
-- ID de los NPCs
local ArthasNPC_ID = 445081
local GuardianNPC_ID = 445082

-- ID de efecto visual permanente (puedes cambiarlo por otro que te guste)
local VisualEffectID = 61224

-- Frases que Arthas dice mientras patrulla
local PatrolTexts = {
    "Estoy vigilando el servidor, no hay lugar para tramposos.",
    "Cada rincón está bajo mi mirada.",
    "La justicia caerá sobre quienes rompan las reglas.",
    "Nadie puede esconderse de mí.",
    "La muerte es solo el principio de tu castigo.",
}

-- Frases para saludar a los jugadores
local Greetings = {
    "Saludos, valiente héroe.",
    "Mantente en línea, la justicia siempre observa.",
    "Que tu camino sea limpio y justo.",
    "Soy Arthas, protector del servidor.",
    "Tu honor es tu escudo, no lo olvides.",
}

-- Mensajes susurrados a GMs con la ubicación de Arthas
local GMWhispers = {
    "Estoy en la posición X: %.1f, Y: %.1f, Z: %.1f.",
    "Patrullando la zona, todo en orden.",
    "Detectando actividad sospechosa, vigilando a los jugadores.",
}

-- Función para que Arthas diga frases de patrulla
local function ArthasPatrolSpeak(eventId, delay, repeats, creature)
    local text = PatrolTexts[math.random(#PatrolTexts)]
    creature:SendUnitSay(text, 0)
end

-- Función para que Arthas salude a un jugador
local function ArthasGreetPlayer(creature, player)
    local greet = Greetings[math.random(#Greetings)]
    creature:SendUnitSay(greet, 0)
end

-- Función para susurrar la posición a todos los GMs conectados
local function ArthasWhisperToGM(eventId, delay, repeats, creature)
    local x, y, z = creature:GetLocation()
    local text = string.format(GMWhispers[math.random(#GMWhispers)], x, y, z)

    for _, player in pairs(GetPlayersInWorld()) do
        if player:IsGM() then
            player:SendAreaTriggerMessage("[Arthas]: " .. text)
        end
    end
end

-- Función para teletransportarse a un jugador aleatorio y saludarlo
local function ArthasTeleportAndGreet(eventId, delay, repeats, creature)
    local players = GetPlayersInWorld()
    if #players == 0 then return end
    local player = players[math.random(#players)]
    if player and player:IsInWorld() then
        creature:NearTeleport(player:GetX(), player:GetY(), player:GetZ(), player:GetO())
        ArthasGreetPlayer(creature, player)
    end
end

-- Función para detectar hacks comunes en jugadores no GM
local function CheckForHacks(eventId, delay, repeats, creature)
    for _, player in pairs(GetPlayersInWorld()) do
        if not player:IsGM() then
            if player:IsInvisible() then
                creature:SendUnitSay("Detectada invisibilidad ilegal en " .. player:GetName(), 0)
            end
            if player:IsFlying() then
                creature:SendUnitSay("Detectado vuelo ilegal en " .. player:GetName(), 0)
            end
        end
    end
end

-- Función para crear guardianes alrededor de Arthas
local function SpawnGuardians(creature)
    local x, y, z, o = creature:GetLocation()
    local guardianDistance = 3.0
    local angles = {0, math.pi / 2, math.pi, 3 * math.pi / 2}

    for _, angle in pairs(angles) do
        local gx = x + guardianDistance * math.cos(angle)
        local gy = y + guardianDistance * math.sin(angle)
        local gz = z
        creature:SpawnCreature(GuardianNPC_ID, gx, gy, gz, o, 14, 0)
    end
end

-- Evento que se ejecuta cuando Arthas spawnea
local function OnArthasSpawn(event, creature)
    creature:CastSpell(creature, VisualEffectID, true)
    creature:RegisterEvent(ArthasPatrolSpeak, 60000, 0)
    creature:RegisterEvent(ArthasWhisperToGM, 120000, 0)
    creature:RegisterEvent(ArthasTeleportAndGreet, 180000, 0)
    creature:RegisterEvent(CheckForHacks, 30000, 0)
    SpawnGuardians(creature)
end

-- Evento al salir de combate
local function OnArthasLeaveCombat(event, creature)
end

-- Registro de eventos para Arthas
RegisterCreatureEvent(ArthasNPC_ID, 5, OnArthasSpawn)
RegisterCreatureEvent(ArthasNPC_ID, 2, OnArthasLeaveCombat)
