local ITEM_ID = 0        -- Ejemplo: Poción de maná superior
local SPELL_1_ID = 0    -- Ejemplo: Montura de Aprendiz
local SPELL_2_ID = 0    -- Ejemplo: Buff mágico
local CAST_SPELL_ID = 74192 -- Visual: subida de nivel
local EMOTE_ID = 4          -- Cheer (aplaude alegremente)

function OnFirstLogin(event, player)
    -- Dar ítem
    player:AddItem(ITEM_ID, 1)

    -- Aprender hechizos
    player:LearnSpell(SPELL_1_ID)
    player:LearnSpell(SPELL_2_ID)

    -- Lanzar hechizo visual
    player:CastSpell(player, CAST_SPELL_ID, true)

    -- Ejecutar animación
    player:PerformEmote(EMOTE_ID)

    -- Mensajes de bienvenida
    player:SendBroadcastMessage("🎉 ¡Bienvenido al servidor!")
    player:SendBroadcastMessage("Has recibido Alunos regaloa de bienvenida: 1 Nombre del item y 2 hechizos.")
end

RegisterPlayerEvent(30, OnFirstLogin)  -- EVENT_ON_FIRST_LOGIN

