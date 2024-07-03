StatusEffects = {
    Healing = {
        Icon = "SEF_Icons/health-normal.png",
        Type = "BUFF",
        Desc = function(healamount)
            return string.format("You are regenerating %d HP each 0.3 sec.", healamount)
        end,
        Effect = function(ent, time, healamount)
            local TimeLeft = ent:GetTimeLeft("Healing")
            if TimeLeft > 0.1 then
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
    HealthBoost = {
        Icon = "SEF_Icons/health-increase.png",
        Type = "BUFF",
        Desc = function(added)
            return string.format("Your max health has been increased by %d HP!", added)
        end,
        Effect = function(ent, time, healthadd)
            local TimeLeft = ent:GetTimeLeft("HealthBoost")

            if not ent.HealthBoostPreBuff then
                ent.HealthBoostPreBuff = ent:GetMaxHealth()
            end

            if TimeLeft > 0.1 then
                ent:SetMaxHealth(ent.HealthBoostPreBuff + healthadd)
            elseif TimeLeft <= 0.1 then
                ent:SetMaxHealth(ent.HealthBoostPreBuff)
                if ent:Health() > ent.HealthBoostPreBuff then
                    ent:SetHealth(ent.HealthBoostPreBuff) 
                end
            end
        end,
        HookType = "",
        HookFunction = function() end
    },
    Energized = {
        Icon = "SEF_Icons/healing-shield.png",
        Type = "BUFF",
        Desc = function(healamount, maxamount)
            return string.format("You are regenerating %d shield each 0.3 sec.\n [Max Armor: %d]", healamount, maxamount)
        end,
        Effect = function(ent, time, healamount, maxamount)
            local TimeLeft = ent:GetTimeLeft("Energized")
            if TimeLeft > 0.1  then
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
        Desc = function(maxhealth)
            return string.format("Your health is capped at %d HP.", maxhealth)
        end,
        Effect = function(ent, time, maxhealth)
            local TimeLeft = ent:GetTimeLeft("Broken")
            if TimeLeft > 0.1  then
                ent.BrokenEffectMaxHealth = maxhealth

                print(ent:Health())

                if ent:Health() >= ent.BrokenEffectMaxHealth then
                    ent:SetHealth(ent.BrokenEffectMaxHealth)
                end

                if ent:HaveEffect("Healing") then
                    ent:RemoveEffect("Healing")
                elseif ent:HaveEffect("HealthBoost") then
                    ent:SoftRemoveEffect("HealthBoost")
                end

            end
        end,
        HookType = "",
        HookFunction = function() end
    },
    Exposed = {
        Icon = "SEF_Icons/exposed.png",
        Type = "DEBUFF",
        Desc = "Received damage is doubled.",
        Effect = function(ent, time)
        end,
        HookType = "EntityTakeDamage",
        HookFunction = function(target, dmginfo)
            if target and target:HaveEffect("Exposed") then
                dmginfo:ScaleDamage(2)
                target:EmitSound("player/crit_hit.wav", 110, 100, 1)
            end
        end
    },
    Endurance = {
        Icon = "SEF_Icons/endurance.png",
        Type = "BUFF",
        Desc = "Received damage is reduced by 50%.",
        Effect = function(ent, time)
        end,
        HookType = "EntityTakeDamage",
        HookFunction = function(target, dmginfo)
            if target and target:HaveEffect("Endurance") then
                dmginfo:ScaleDamage(0.5)
                target:EmitSound("phx/epicmetal_hard.wav", 110, math.random(75, 125), 1)
            end
        end
    },
    Haste = {
        Icon = "SEF_Icons/haste.png",
        Type = "BUFF",
        Desc = function(amount)
            return string.format("Your movement speed is increased by %d units.", amount)
        end,
        Effect = function(ent, time, amount)
            local TimeLeft = ent:GetTimeLeft("Haste")

            if TimeLeft > 0.5 then
    
                if ent:IsPlayer() then
                    if not ent.HasteEffectSpeedWalk and not ent.HasteEffectSpeedRun then
                        ent.HasteEffectSpeedWalk = ent:GetWalkSpeed()
                        ent.HasteEffectSpeedRun = ent:GetRunSpeed()
                    end
                    ent:SetRunSpeed(ent.HasteEffectSpeedRun  + amount)
                    ent:SetWalkSpeed(ent.HasteEffectSpeedWalk + amount)
                elseif ent.IsLambdaPlayer then
                    local walkingSpeed = GetConVar("lambdaplayers_lambda_walkspeed")
                    local runningSpeed = GetConVar("lambdaplayers_lambda_runspeed")
                    ent:SetRunSpeed(runningSpeed:GetInt() + amount)
                    ent:SetWalkSpeed(walkingSpeed:GetInt() + amount)
                elseif ent:IsNPC() then
                    ent:SoftRemoveEffect("Haste")
                    print("Haste won't work on NPCs.")
                elseif ent:IsNextBot() and not ent.IsLambdaPlayer then
                    if not ent.HasteEffectSpeed then
                        ent.HasteEffectSpeed = ent:GetDesiredSpeed()
                    end
                    ent:SetDesiredSpeed(ent.HasteEffectSpeed + amount)
                end
            elseif TimeLeft <= 0.5 then
    
                if ent:IsPlayer() then
                    ent:SetRunSpeed(ent.HasteEffectSpeedRun)
                    ent:SetWalkSpeed(ent.HasteEffectSpeedWalk)
                elseif ent.IsLambdaPlayer then
                    local walkingSpeed = GetConVar("lambdaplayers_lambda_walkspeed")
                    local runningSpeed = GetConVar("lambdaplayers_lambda_runspeed")
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
        Desc = "You are tired. \nYour speed can't be increased.",
        Effect = function(ent, time)
            local TimeLeft = ent:GetTimeLeft("Exhaust")
    
            if (ent:IsPlayer() or ent.IsLambdaPlayer) and not ent.ExhaustedEffectSpeedWalk and not ent.ExhaustedEffectSpeedRun then
                ent.ExhaustedEffectSpeedWalk = ent:GetWalkSpeed()
                ent.ExhaustedEffectSpeedRun = ent:GetRunSpeed()
            elseif ent:IsNextBot() and not ent.IsLambdaPlayer then
                ent.ExhaustEffectSpeed = ent:GetDesiredSpeed()
            end

            print(ent.ExhaustedEffectSpeedWalk)

            if ent:HaveEffect("Haste") then
                ent:SoftRemoveEffect("Haste")
                if (ent:IsPlayer() or ent.IsLambdaPlayer) then
                    ent.ExhaustedEffectSpeedWalk = ent.HasteEffectSpeedWalk
                    ent.ExhaustedEffectSpeedRun = ent.HasteEffectSpeedRun
                else
                    ent.ExhaustEffectSpeed = ent.HasteEffectSpeed
                end
            end
    
            if TimeLeft > 0.1 then
                local walkingSpeed = GetConVar("lambdaplayers_lambda_walkspeed"):GetInt()
                local runningSpeed = GetConVar("lambdaplayers_lambda_runspeed"):GetInt()
    
                if ent:IsPlayer() and ent.ExhaustedEffectSpeedWalk and ent.ExhaustedEffectSpeedRun then
                    if ent:GetWalkSpeed() > ent.ExhaustedEffectSpeedWalk then
                        ent:SetWalkSpeed(ent.ExhaustedEffectSpeedWalk)
                    end
                    if ent:GetRunSpeed() > ent.ExhaustedEffectSpeedRun then
                        ent:SetRunSpeed(ent.ExhaustedEffectSpeedRun)
                    end
                elseif ent.IsLambdaPlayer and ent.ExhaustedEffectSpeedWalk and ent.ExhaustedEffectSpeedRun then
                    if ent:GetWalkSpeed() > ent.ExhaustedEffectSpeedWalk then
                        ent:SetWalkSpeed(walkingSpeed)
                    end
                    if ent:GetRunSpeed() > ent.ExhaustedEffectSpeedRun then
                        ent:SetRunSpeed(runningSpeed)
                    end
                elseif ent:IsNextBot() and not ent.IsLambdaPlayer and ent.ExhaustEffectSpeed then
                    if ent:GetDesiredSpeed() > ent.ExhaustEffectSpeed then
                        ent:SetDesiredSpeed(ent.ExhaustEffectSpeed)
                    end
                end
            end
        end,
        HookType = "",
        HookFunction = function() end
    },    
    Hindered = {
        Icon = "SEF_Icons/hindered.png",
        Type = "DEBUFF",
        Desc = function(amount)
            return string.format("Your movement speed is decreased by %d units!", amount)
        end,
        Effect = function(ent, time, amount)
            local TimeLeft = ent:GetTimeLeft("Hindered")

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
        Desc = function(damageamount)
            return string.format("You are bleeding.\n You are losing %d HP each 0.3 sec.", damageamount)
        end,
        Effect = function(ent, time, damageamount, inf)
            local TimeLeft = ent:GetTimeLeft("Bleeding")
            if TimeLeft > 0.1  then
                if not ent.BleedingEffectDelay then
                    ent.BleedingEffectDelay  = CurTime()
                end
                if CurTime() >= ent.BleedingEffectDelay  then
                    if IsValid(inf) then
                        local dmg = DamageInfo()
                        dmg:SetDamage(damageamount)
                        dmg:SetInflictor(inf)
                        ent:TakeDamageInfo(dmg)
                    else
                        ent:TakeDamage(damageamount)
                    end
                    ent.BleedingEffectDelay = CurTime() + 0.3
                end
            end
        end,
        HookType = "",
        HookFunction = function() end
    },
    Incapacitated = {
        Icon = "SEF_Icons/incap.png",
        Type = "DEBUFF",
        Desc = "You are unable to use any weapons or tools.",
        Effect = function(ent, time)
            local TimeLeft = ent:GetTimeLeft("Incapacitated")
            if TimeLeft > 0.5 then
                if ent:IsPlayer() then
                    if not ent.IncapEffectWeapon then
                        ent.IncapEffectWeapon = ent:GetActiveWeapon():GetClass()
                    end
                    ent:SetActiveWeapon(NULL)
                elseif ent.IsLambdaPlayer then

                    if not ent.IncapEffectWeapon then
                        ent.IncapEffectWeapon = ent.l_Weapon
                    end

                    ent:RetreatFrom()    
                    ent:SwitchWeapon("none")
                elseif ent:IsNPC() then
                    if not ent.IncapEffectWeapon and IsValid(ent:GetActiveWeapon()) then
                        ent.IncapEffectWeapon = ent:GetActiveWeapon():GetClass()
                    end

                    if IsValid(ent:GetActiveWeapon()) then
                        ent:GetActiveWeapon():Remove()
                    end
                end
            elseif TimeLeft <= 0.1 then
                if ent:IsPlayer() then
                    if ent.IncapEffectWeapon ~= nil then
                        ent:SelectWeapon(ent.IncapEffectWeapon)
                    end
                    ent.IncapEffectWeapon = nil
                elseif ent.IsLambdaPlayer then
                    if ent.IncapEffectWeapon ~= nil then
                        ent:SwitchWeapon(ent.IncapEffectWeapon)
                    end
                    ent.IncapEffectWeapon = nil
                elseif ent:IsNPC() then
                    if ent.IncapEffectWeapon ~= nil then
                        ent:Give(ent.IncapEffectWeapon)
                    end
                    ent.IncapEffectWeapon = nil
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
