if CLIENT then

    local ply = LocalPlayer()
    local ActiveEffects = {}
    AllEntEffects = {}

    CreateClientConVar("SEF_StatusEffectX", 50, true, false, "X position of Status Effects applied on you.", 0, ScrW())
    CreateClientConVar("SEF_StatusEffectY", 925, true, false, "Y position of Status Effects applied on you.", 0, ScrH())
    CreateClientConVar("SEF_StatusEffectDisplay", 1, true, false, "Shows effects on players/NPCS/Lambdas.", 0, 1)

    local function SplitCamelCase(str)
        return str:gsub("(%l)(%u)", "%1 %2")
    end

    local function DrawStatusEffectTimer(x, y, effectName, effectDesc, duration, startTime)
        local effect = StatusEffects[effectName]
        if not effect then return end

        local mouseX = gui.MouseX()
        local mouseY = gui.MouseY()

        surface.SetFont("TargetIDSmall")

        local FormattedName = SplitCamelCase(effectName)
        local TextColor
        local NameW, NameH = surface.GetTextSize(FormattedName)
        local DescW, DescH = 0, 0
        if effectDesc != nil and effectDesc != "" then
            DescW, DescH = surface.GetTextSize(effectDesc)
        end
        local DurW, DurH = surface.GetTextSize("Duration: " .. duration .. " seconds")
        local TotalWidth = math.max(NameW, DurW, DescW)
        local TotalHeight = NameH + DurH + DescH

    
        local icon = Material(effect.Icon)
        local radius = 22
        local centerX, centerY = x, y
    
        -- Oblicz upływ czasu
        local elapsedTime = CurTime() - startTime
        local fraction = math.Clamp(elapsedTime / duration, 0, 1)
        local startAngle = 270  -- Początkowy kąt (góra)
        local angle = 360 * (1 - fraction)  -- Odwrotność frakcji aby się "opróżniało"
    
        -- Rysowanie kółka
        local vertices = {}
        table.insert(vertices, { x = centerX, y = centerY })
    
        for i = startAngle, startAngle + angle, 1 do
            local rad = math.rad(i)
            table.insert(vertices, {
                x = centerX + math.cos(rad) * radius,
                y = centerY + math.sin(rad) * radius
            })
        end
    
        if StatusEffects[effectName].Type == "BUFF" then
            surface.SetDrawColor(30, 255, 0, 255)
            TextColor = Color(30, 255, 0, 255)
        else
            surface.SetDrawColor(255, 0, 0, 255)
            TextColor = Color(255, 0, 0, 255)
        end
        draw.NoTexture()
        surface.DrawPoly(vertices)

        surface.SetDrawColor(80, 80, 80)
        surface.SetMaterial(Material("SEF_Icons/StatusEffectCircle.png"))
        surface.DrawTexturedRectRotated(centerX, centerY, 50, 50, 0 )
    
        -- Rysowanie ikony w środku
        surface.SetMaterial(icon)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(centerX - 16, centerY - 16, 32, 32)

        local remainingTime = duration - (CurTime() - startTime)
        draw.SimpleText(math.Round(remainingTime), "TargetIDSmall", centerX, centerY + 20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)

        if mouseX >= centerX - 16 and mouseX <= centerX + 16 and mouseY >= centerY - 16 and mouseY <= centerY + 16 then
            surface.SetDrawColor(0, 0, 0, 155)
            surface.DrawRect(mouseX, mouseY + 30, TotalWidth + 10, TotalHeight)
            draw.SimpleText(FormattedName, "TargetIDSmall", mouseX + 5, mouseY + 30, Color(255,208,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            if DescH > 0 then
                draw.DrawText(effectDesc, "TargetIDSmall", mouseX + 5, mouseY + 30 + NameH, TextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end
            draw.SimpleText("Duration: " .. duration .." seconds", "TargetIDSmall", mouseX + 5, mouseY + 45 + DescH, TextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
    end

    local function DrawStatusEffectTimerMini(x, y, effectName, duration, startTime)
        local effect = StatusEffects[effectName]
        if not effect then return end
    
        local icon = Material(effect.Icon)
        local radius = 13
        local centerX, centerY = x, y
    
        -- Oblicz upływ czasu
        local elapsedTime = CurTime() - startTime
        local fraction = math.Clamp(elapsedTime / duration, 0, 1)
        local startAngle = 270  -- Początkowy kąt (góra)
        local angle = 360 * (1 - fraction)  -- Odwrotność frakcji aby się "opróżniało"
    
        -- Rysowanie kółka
        local vertices = {}
        table.insert(vertices, { x = centerX, y = centerY })
    
        for i = startAngle, startAngle + angle, 1 do
            local rad = math.rad(i)
            table.insert(vertices, {
                x = centerX + math.cos(rad) * radius,
                y = centerY + math.sin(rad) * radius
            })
        end
    
        if StatusEffects[effectName].Type == "BUFF" then
            surface.SetDrawColor(30, 255, 0, 255)
        else
            surface.SetDrawColor(255, 0, 0, 255)
        end
        draw.NoTexture()
        surface.DrawPoly(vertices)

        surface.SetDrawColor(80, 80, 80)
        surface.SetMaterial(Material("SEF_Icons/StatusEffectCircle.png"))
        surface.DrawTexturedRectRotated(centerX, centerY, 23, 23, 0 )
    
        -- Rysowanie ikony w środku
        surface.SetMaterial(icon)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRectRotated(centerX, centerY, 18, 18, 0)
    end

    local function WithinDistance(A, target, dist)
        local Dist = dist * dist

        return A:GetPos():DistToSqr( target ) < Dist
    end
    

    local function DisplayStatusEffects()
            
        local StatusEffX = GetConVar("SEF_StatusEffectX"):GetInt()
        local StatusEffY = GetConVar("SEF_StatusEffectY"):GetInt()
        local ShowDisplay = GetConVar("SEF_StatusEffectDisplay"):GetBool()
        local THROverHead

        if ConVarExists("THR_OverheadUI") then
            THROverHead = GetConVar("THR_OverheadUI"):GetBool()
        else
            THROverHead = false
        end

        for effectName, effectData in SortedPairsByMemberValue(ActiveEffects, "Duration", true) do

            local remainingTime = effectData.Duration - (CurTime() - effectData.StartTime)

            DrawStatusEffectTimer(StatusEffX , StatusEffY, effectName, effectData.Desc, effectData.Duration, effectData.StartTime)

            StatusEffX  = StatusEffX  + 50

        end

        if ShowDisplay then
            for entID, statuseffects in pairs(AllEntEffects) do
                local ent = Entity(entID)
                if IsValid(ent) and entID ~= LocalPlayer():EntIndex() then
                    local PosClient = ent:GetPos() + Vector(0, 0, 80)
                    local screenPos = PosClient:ToScreen()
                    local effectAmount = table.Count(statuseffects)
                    local TotalWidth = (effectAmount - 1) * 25
                    local startX = screenPos.x - (TotalWidth / 2)

                    local tr = util.TraceLine({
                        start = plyEyePos,
                        endpos = EntPos,
                        filter = LocalPlayer()
                    })
    
                    for effectName, effectData in SortedPairsByMemberValue(statuseffects, "Duration", true) do
                        local effectCount = table.Count(statuseffects)
                        if tr.HitPos and WithinDistance(LocalPlayer(), PosClient, 500) then
                            local remainingTime = effectData.Duration - (CurTime() - effectData.StartTime)
                            if remainingTime > 0 then
                                if THROverHead and (ent:IsNPC() or ent:IsNextBot() and not ent.IsLambdaPlayer) then
                                    DrawStatusEffectTimerMini(startX, screenPos.y, effectName, effectData.Duration, effectData.StartTime)
                                elseif not THROverHead then
                                    DrawStatusEffectTimerMini(startX, screenPos.y, effectName, effectData.Duration, effectData.StartTime)
                                end
                                startX = startX + 25
                            else
                                -- Usuwamy efekt, jeśli czas jego trwania się skończył
                                AllEntEffects[entID][effectName] = nil
                                if table.Count(AllEntEffects[entID]) == 0 then
                                    AllEntEffects[entID] = nil  -- Usuwamy podtabelę, jeśli nie ma już żadnych efektów
                                end
                            end
                        end
                    end
                elseif not IsValid(ent) then
                    print("[Status Effect Framework] Removed data about no longer valid entity.")
                    AllEntEffects[entID] = nil
                end
            end
        end

    end


    net.Receive("StatusEffectAdd", function()
        local EffectName = net.ReadString()
        local Desc = net.ReadString()
        local Duration = net.ReadFloat()
        local StartTime = CurTime()

        local StatusEntry = {
            EffectName = EffectName,
            Desc = Desc,
            Duration = Duration,
            StartTime = StartTime
        }

        ActiveEffects[EffectName] = StatusEntry
    end)

    net.Receive("StatusEffectRemove", function()
        local EffectName = net.ReadString()
        ActiveEffects[EffectName] = nil
    end)
    

    net.Receive("StatusEffectEntityAdd", function()
        local EntID = net.ReadInt(32)
        local EffectName = net.ReadString()
        local Duration = net.ReadFloat()
        local TimeApply = net.ReadFloat()

        if not AllEntEffects[EntID] then
            AllEntEffects[EntID] = {}
        end

        AllEntEffects[EntID][EffectName] = {
            Duration = Duration,
            StartTime = TimeApply
        }
    end)

    net.Receive("StatusEffectEntityRemove", function()
        local EntID = net.ReadInt(32)
        local EffectName = net.ReadString()

        if AllEntEffects[EntID] and AllEntEffects[EntID][EffectName] then
            AllEntEffects[EntID][EffectName] = nil
            
            -- Usuń podtabelę jeśli nie ma już żadnych efektów
            if next(AllEntEffects[EntID]) == nil then
                AllEntEffects[EntID] = nil
            end
        end
    end)

    hook.Add("HUDPaint", "DisplayStatusEffectsHUD", DisplayStatusEffects)
end