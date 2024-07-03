if SERVER then

    hook.Add("Think", "EntityStatusEffectsThink", function()
        for entID, effects in pairs(EntActiveEffects) do
            local Affected = Entity(entID)
            if IsValid(Affected) and (Affected:IsPlayer() or Affected:IsNPC() or Affected:IsNextBot()) then
                for effectName, effectData in pairs(effects) do
                    if CurTime() - effectData.StartTime <= effectData.Duration then
                        effectData.Function(Affected, effectData.Duration, unpack(effectData.Args))
                    else
                        Affected:RemoveEffect(effectName)
                    end
                end
            elseif not IsValid(Affected) then
                EntActiveEffects[entID] = nil
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
        if IsValid(victim) and EntActiveEffects[victim:EntIndex()] then
            for effectName, _ in pairs(EntActiveEffects[victim:EntIndex()]) do
                victim:RemoveEffect(effectName)
            end
        end
    end)

    hook.Add("LambdaOnKilled", "RemoveStatusEffects", function(lambda, dmg, isSilent)
        if IsValid(lambda) and EntActiveEffects[lambda:EntIndex()] then
            for effectName, _ in pairs(EntActiveEffects[lambda:EntIndex()]) do
                lambda:RemoveEffect(effectName)
            end
        end
    end)

    CreateEffectHooks()

    concommand.Add("SEF_CreateEffectHooks", function(ply, cmd, args)
        CreateEffectHooks()
    end, nil, "Reloads or creates all hooks in StatusEffects table.")

end