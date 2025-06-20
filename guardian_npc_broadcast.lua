
-- Guardian NPC con múltiples funciones para AzerothCore

local NPC_ID = 91000
local WARNING_RANGE = 50
local WARNING_INTERVAL = 10 -- segundos entre advertencias
local AURA_ID = 705 -- aura visual permanente
local SPELL_EFFECT_ID = 688 -- efecto visual al matar
local SOUND_ID = 1201 -- sonido de advertencia
local ACTIVE_ANIM = 427 -- animación al activarse
local DEACTIVATED_ANIM = 65 -- animación al desactivarse
local undeadEntry = 11197 -- ID del no-muerto invocado

local warnings = {}
local guardianActive = true

local function ResetWarnings()
    warnings = {}
end

local function OnUpdate(event, creature, diff)
    if not guardianActive then return end

    if not creature.warningTimer then creature.warningTimer = 0 end
    creature.warningTimer = creature.warningTimer + diff

    if creature.warningTimer >= (WARNING_INTERVAL * 1000) then
        local playersInRange = creature:GetPlayersInRange(WARNING_RANGE)
        for _, player in ipairs(playersInRange) do
            if player:IsAlive() and not player:IsGM() then
                local guid = player:GetGUIDLow()
                if not warnings[guid] then
                    creature:SendUnitSay("¡Aléjate o enfrentarás las consecuencias!", 0)
                    creature:PlayDirectSound(SOUND_ID)
                    warnings[guid] = true
                else
                    player:Kill(player)
                    creature:CastSpell(player, SPELL_EFFECT_ID, true)
                    creature:SendUnitSay("¡Te lo advertí...", 0)

                    -- Invocar no-muerto en el lugar del jugador
                    local x, y, z = player:GetX(), player:GetY(), player:GetZ()
                    local undead = creature:SpawnCreature(undeadEntry, x + 2, y + 2, z, 0, 14, 60000)
                    if undead then
                        undead:AttackStart(player)
                    end

                    SendWorldMessage("|cffff0000[Guardia]|r " .. player:GetName() .. " ha sido eliminado por ingresar a una zona restringida.")
                end
            end
        end
        creature.warningTimer = 0
    end
end

local function OnEnterCombat(event, creature, target)
    if creature:IsInCombat() then
        creature:ClearInCombat()
    end
end

local function OnSpawn(event, creature)
    creature:AddAura(AURA_ID, creature)
    creature:SetUInt32Value(UNIT_FIELD_FLAGS, UNIT_FLAG_NON_ATTACKABLE + UNIT_FLAG_NOT_SELECTABLE + UNIT_FLAG_IMMUNE_TO_PC)
    creature:RegisterEvent(OnUpdate, 1000, 0)
end

-- Menú para GMs
local function OnGossipHello(event, player, creature)
    if player:IsGM() then
        player:GossipClearMenu()
        if guardianActive then
            player:GossipMenuAddItem(0, "§ Desactivar guardián", 0, 1)
        else
            player:GossipMenuAddItem(0, "§ Activar guardián", 0, 2)
        end
        player:GossipSendMenu(1, creature)
    end
end

local function OnGossipSelect(event, player, creature, sender, intid, code)
    if intid == 1 then
        guardianActive = false
        ResetWarnings()
        creature:Emote(DEACTIVATED_ANIM)
        creature:SendUnitSay("Modo de vigilancia desactivado.", 0)
    elseif intid == 2 then
        guardianActive = true
        creature:Emote(ACTIVE_ANIM)
        creature:SendUnitSay("Modo de vigilancia activado.", 0)
    end
    player:GossipComplete()
end

RegisterCreatureEvent(NPC_ID, 5, OnSpawn)
RegisterCreatureEvent(NPC_ID, 1, OnEnterCombat)
RegisterCreatureGossipEvent(NPC_ID, 1, OnGossipHello)
RegisterCreatureGossipEvent(NPC_ID, 2, OnGossipSelect)
