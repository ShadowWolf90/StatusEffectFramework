StatusEffects = {
    Healing = {
        Icon = "SEF_Icons/health-normal.png",
        Type = "BUFF",
        Effect = function(ent, time, healamount)
            local CurrentTime = CurTime()
            local TimeLeft = (ent.activeEffects["Healing"].StartTime + time) - CurrentTime
            if TimeLeft <= CurrentTime then
                if not ent.HealingEffectDelay then
                    ent.HealingEffectDelay  = CurTime()
                end
                if CurTime() >= ent.HealingEffectDelay  then
                    ent:SetHealth(math.min(ent:Health() + healamount, ent:GetMaxHealth()))
                    ent.HealingEffectDelay = CurTime() + 0.3
                end
            end
        end,
        HookType = "",
        HookFunction = function() end
    },
    Energized = {
        Icon = "SEF_Icons/healing-shield.png",
        Type = "BUFF",
        Effect = function(ent, time, healamount, maxamount)
            local CurrentTime = CurTime()
            local TimeLeft = (ent.activeEffects["Energized"].StartTime + time) - CurrentTime
            if TimeLeft <= CurrentTime then
                if not ent.ShieldingEffectDelay then
                    ent.ShieldingEffectDelay = CurTime()
                end
                if CurTime() >= ent.ShieldingEffectDelay  then
                    ent:SetArmor(math.min(ent:Armor() + healamount, maxamount))
                    ent.ShieldingEffectDelay = CurTime() + 0.3
                end
            end
        end,
        HookType = "",
        HookFunction = function() end
    },
    Broken = {
        Icon = "SEF_Icons/broken.png",
        Type = "DEBUFF",
        Effect = function(ent, time, maxhealth)
            local CurrentTime = CurTime()
            local TimeLeft = (ent.activeEffects["Broken"].StartTime + time) - CurrentTime
            if TimeLeft <= CurrentTime then
                ent.BrokenEffectMaxHealth = maxhealth

                if ent:Health() >= ent.BrokenEffectMaxHealth then
                    ent:SetHealth(ent.BrokenEffectMaxHealth)
                    print("MAX HEALTH EXCEEDED: ", ent.BrokenEffectMaxHealth)
                end

                if (ent.activeEffects and ent.activeEffects["Healing"]) then
                    ent:RemoveEffect("Healing")
                end

            end
        end,
        HookType = "",
        HookFunction = function() end
    },
    Exposed = {
        Icon = "SEF_Icons/exposed.png",
        Type = "DEBUFF",
        Effect = function(ent, time)
        end,
        HookType = "EntityTakeDamage",
        HookFunction = function(target, dmginfo)
            if target and target.activeEffects and target.activeEffects["Exposed"] then
                dmginfo:ScaleDamage(2)
                target:EmitSound("player/crit_hit.wav", 110, 100, 1)
            end
        end
    },
    Endurance = {
        Icon = "SEF_Icons/endurance.png",
        Type = "BUFF",
        Effect = function(ent, time)
        end,
        HookType = "EntityTakeDamage",
        HookFunction = function(target, dmginfo)
            if target and target.activeEffects and target.activeEffects["Endurance"] then
                dmginfo:ScaleDamage(0.4)
                target:EmitSound("phx/epicmetal_hard.wav", 110, 100, 1)
                if target:Health() <= 30 then
                    target:ApplyEffect("Healing", 5, math.Round(dmginfo:GetDamage() * 0.05))
                end
            end
        end
    },
    Haste = {
        Icon = "SEF_Icons/haste.png",
        Type = "BUFF",
        Effect = function(ent, time, amount)
            local CurrentTime = CurTime()
            local TimeLeft = (ent.activeEffects["Haste"].StartTime + time) - CurrentTime

            if TimeLeft > 0.5 then
                local walkingSpeed = GetConVar("lambdaplayers_lambda_walkspeed")
                local runningSpeed = GetConVar("lambdaplayers_lambda_runspeed")
    
                if ent:IsPlayer() then
                    ent:SetRunSpeed(240 + amount)
                    ent:SetWalkSpeed(160 + amount)
                elseif ent.IsLambdaPlayer then
                    ent:SetRunSpeed(runningSpeed:GetInt() + amount)
                    ent:SetWalkSpeed(walkingSpeed:GetInt() + amount)
                elseif ent:IsNPC() then
                    ent:RemoveEffect("Haste")
                    print("NPCs are not supported")
                elseif ent:IsNextBot() and not ent.IsLambdaPlayer then
                    if not ent.HasteEffectSpeed then
                        ent.HasteEffectSpeed = ent:GetDesiredSpeed()
                    end
                    ent:SetDesiredSpeed(ent.HasteEffectSpeed + amount)
                end
            elseif TimeLeft <= 0.5 then
                local walkingSpeed = GetConVar("lambdaplayers_lambda_walkspeed")
                local runningSpeed = GetConVar("lambdaplayers_lambda_runspeed")
    
                if ent:IsPlayer() then
                    ent:SetRunSpeed(240)
                    ent:SetWalkSpeed(160)
                elseif ent.IsLambdaPlayer then
                    ent:SetRunSpeed(runningSpeed:GetInt())
                    ent:SetWalkSpeed(walkingSpeed:GetInt())
                elseif ent:IsNextBot() and not ent.IsLambdaPlayer then
                    ent:SetDesiredSpeed(ent.HasteEffectSpeed)
                end
            end
        end,
        HookType = "",
        HookFunction = function() end
    },
    Exhaust = {
        Icon = "SEF_Icons/exhaust.png",
        Type = "DEBUFF",
        Effect = function(ent, time)
            local CurrentTime = CurTime()
            local TimeLeft = (ent.activeEffects["Exhaust"].StartTime + time) - CurrentTime

            if TimeLeft > 0.5 then
                local walkingSpeed = GetConVar("lambdaplayers_lambda_walkspeed")
                local runningSpeed = GetConVar("lambdaplayers_lambda_runspeed")

                if ent.activeEffects["Haste"] then
                    ent:RemoveEffect("Haste")
                end
    
                if ent:IsPlayer() then
                    ent:SetRunSpeed(240)
                    ent:SetWalkSpeed(160)
                elseif ent.IsLambdaPlayer then
                    ent:SetRunSpeed(runningSpeed:GetInt())
                    ent:SetWalkSpeed(walkingSpeed:GetInt())
                elseif ent:IsNextBot() and not ent.IsLambdaPlayer then
                    if not ent.ExhaustEffectSpeed then
                        ent.ExhaustEffectSpeed = ent:GetDesiredSpeed()
                    end
                    ent:SetDesiredSpeed(ent.ExhaustEffectSpeed)
                end
            end
        end,
        HookType = "",
        HookFunction = function() end
    },
    Hindered = {
        Icon = "SEF_Icons/hindered.png",
        Type = "DEBUFF",
        Effect = function(ent, time, amount)
            local CurrentTime = CurTime()
            local TimeLeft = (ent.activeEffects["Hindered"].StartTime + time) - CurrentTime

            if TimeLeft > 0.5 then
                local walkingSpeed = GetConVar("lambdaplayers_lambda_walkspeed")
                local runningSpeed = GetConVar("lambdaplayers_lambda_runspeed")
    
                if ent:IsPlayer() then
                    ent:SetRunSpeed(240 - amount)
                    ent:SetWalkSpeed(160 - amount)
                elseif ent.IsLambdaPlayer then
                    ent:SetRunSpeed(runningSpeed:GetInt() - amount)
                    ent:SetWalkSpeed(walkingSpeed:GetInt() - amount)
                elseif ent:IsNPC() then
                    ent:RemoveEffect("Hindered")
                    print("NPCs are not supported")
                elseif ent:IsNextBot() and not ent.IsLambdaPlayer then
                    if not ent.HinderedEffectSpeed then
                        ent.HasteEffectSpeed = ent:GetDesiredSpeed()
                    end
                    ent:SetDesiredSpeed(ent.HasteEffectSpeed - amount)
                end
            elseif TimeLeft <= 0.5 then
                local walkingSpeed = GetConVar("lambdaplayers_lambda_walkspeed")
                local runningSpeed = GetConVar("lambdaplayers_lambda_runspeed")
    
                if ent:IsPlayer() then
                    ent:SetRunSpeed(240)
                    ent:SetWalkSpeed(160)
                elseif ent.IsLambdaPlayer then
                    ent:SetRunSpeed(runningSpeed:GetInt())
                    ent:SetWalkSpeed(walkingSpeed:GetInt())
                elseif ent:IsNextBot() and not ent.IsLambdaPlayer then
                    ent:SetDesiredSpeed(ent.HindredEffectSpeed)
                end
            end
        end,
        HookType = "",
        HookFunction = function() end
    },
    Bleeding = {
        Icon = "SEF_Icons/bleed.png",
        Type = "DEBUFF",
        Effect = function(ent, time, damageamount)
            local CurrentTime = CurTime()
            local TimeLeft = (ent.activeEffects["Bleeding"].StartTime + time) - CurrentTime
            if TimeLeft <= CurrentTime then
                if not ent.BleedingEffectDelay then
                    ent.BleedingEffectDelay  = CurTime()
                end
                if CurTime() >= ent.BleedingEffectDelay  then
                    ent:TakeDamage(damageamount)
                    ent.BleedingEffectDelay = CurTime() + 0.3
                end
            end
        end,
        HookType = "",
        HookFunction = function() end
    },
    Template = {
        Icon = "SEF_Icons/warning.png",
        Type = "DEBUFF",
        Effect = function(ent, time)
        end,
        HookType = "",
        HookFunction = function() end
    }
}
