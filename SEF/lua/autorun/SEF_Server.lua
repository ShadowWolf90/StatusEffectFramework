if SERVER then

    --[[
    hook.Add("Think", "EntityStatusEffectsThink", function()
        for _, ent in ents.Iterator() do
            if (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) and ent.activeEffects then
                for effectName, effectData in pairs(ent.activeEffects) do
                    if CurTime() - effectData.StartTime <= effectData.Duration then
                        effectData.Function(ent, effectData.Duration, unpack(effectData.Args))
                    else
                        ent:RemoveEffect(effectName)
                    end
                end
            end
        end
    end)

    local function CreateEffectHooks()
        for effect, effectData in pairs(StatusEffects) do
            if effect and effectData.HookType ~= "" then

                if not effectData.HookInit then

                    effectData.LastHookFunction = effectData.HookFunction

                    print("[Status Effect Framework] Effect Hook has been created: " .. effect ..  " Hook: " .. effect .. "StatusEffectHookManager")

                    hook.Add(effectData.HookType, effect .. "StatusEffectHookManager", function(...)
                        effectData.HookFunction(...)
                    end)


                    effectData.HookInit = true

                elseif effectData.HookInit and effectData.LastHookFunction != effectData.HookFunction then

                    print("[Status Effect Framework] Updating Hook Function for: " .. effect)

                    hook.Add(effectData.HookType, effect .. "StatusEffectHookManager", function(...)
                        effectData.HookFunction(...)
                    end)

                    effectData.LastHookFunction = effectData.HookFunction

                end
            end
        end
    end

    hook.Add("PlayerDeath", "RemoveStatusEffects", function(victim, inflictor, attacker)
        if IsValid(victim) and victim.activeEffects then
            for effectName, _ in pairs(victim.activeEffects) do
                victim:RemoveEffect(effectName)
            end
        end
    end)

    local function ObtainStatusEffects(ent)

        local EntTeam
        if ent:IsPlayer() or ent.IsLambdaPlayer then
            EntTeam = ent:Team()
        else
            EntTeam = "NPC"
        end

        return {
            pos = ent:WorldSpaceCenter() + Vector(0, 0, 50),
            ID = ent:GetCreationID(),
            EntTeam = EntTeam,
            EntActiveEffects = ent.activeEffects
        }
    end

    local function SortStatusEffects()
        local EntDatas = {}

        for _, ent in ents.Iterator() do
            if ent.activeEffects and next(ent.activeEffects) ~= nil then
                table.insert(EntDatas, ObtainStatusEffects(ent))
            end
        end

        return EntDatas
    end

    CreateEffectHooks()

    concommand.Add("SEF_createeffecthooks", function(ply, cmd, args)
        CreateEffectHooks()
    end, nil, "Reloads or creates all hooks in StatusEffects table.")


    hook.Add("Think", "TransferStatusEffects", function()
        local Ents = SortStatusEffects()

        local JSON = util.TableToJSON(Ents)
        local Compressed = util.Compress(JSON)

        net.Start("StatusEffectTransfer", true)
        net.WriteUInt(#Compressed, 16)
        net.WriteData(Compressed)
        net.Broadcast()
    end)
    ]]--

end