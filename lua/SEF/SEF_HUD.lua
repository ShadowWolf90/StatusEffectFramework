if CLIENT then

    local ply = LocalPlayer()
    local ActiveEffects = {}
    AllEntEffects = {}

    CreateClientConVar("SEF_StatusEffectX", 655, true, false, "X position of Status Effects applied on you.", 0, ScrW())
    CreateClientConVar("SEF_StatusEffectY", 950, true, false, "Y position of Status Effects applied on you.", 0, ScrH())
    CreateClientConVar("SEF_StatusEffectDisplay", 1, true, false, "Shows effects on players/NPCS/Lambdas.", 0, 1)

    local function DrawStatusEffectTimer(x, y, effectName, duration, startTime)
        local effect = StatusEffects[effectName]
        if not effect then return end
    
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
        else
            surface.SetDrawColor(255, 0, 0, 255)
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

            DrawStatusEffectTimer(StatusEffX , StatusEffY, effectName, effectData.Duration, effectData.StartTime)

            draw.SimpleText(math.Round(remainingTime), "TargetIDSmall", StatusEffX , StatusEffY + 20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)

            StatusEffX  = StatusEffX  + 50

        end

        if ShowDisplay then
            for i, ent in ipairs(AllEntEffects) do
                local EntPos = ent.pos
                local EntActiveEffects = ent.EntActiveEffects
                local ID = ent.ID
                local EntTeam = ent.EntTeam
                local EffectAmount = table.Count(EntActiveEffects)
                local ScreenPos = EntPos:ToScreen()
                
                -- Calculate the starting x position to center the effects
                local totalWidth = (EffectAmount - 1) * 25  -- total width of all effects with 25 unit spacing
                local startX = ScreenPos.x - (totalWidth / 2)

                local function WithinDistance(A, target, dist)
                    local Dist = dist * dist
                    
                    return A:GetPos():DistToSqr( target ) < Dist
                end
            
                -- Perform a trace line to check visibility
                local tr = util.TraceLine({
                    start = LocalPlayer():EyePos(),
                    endpos = EntPos,
                    filter = LocalPlayer()
                })
            
                for effect, data in SortedPairsByMemberValue(EntActiveEffects, "Duration", true) do
                    if tr.HitPos == EntPos and ID ~= LocalPlayer():GetCreationID() then
                        if WithinDistance(LocalPlayer(), EntPos, 500) and EntTeam == "NPC" then
                            DrawStatusEffectTimerMini(startX, ScreenPos.y, effect, data.Duration, data.StartTime)
                        elseif WithinDistance(LocalPlayer(), EntPos, 500) and EntTeam == LocalPlayer():Team() and not THROverHead then
                            DrawStatusEffectTimerMini(startX, ScreenPos.y, effect, data.Duration, data.StartTime)
                        elseif WithinDistance(LocalPlayer(), EntPos, 500) and EntTeam ~= LocalPlayer():Team() then
                            DrawStatusEffectTimerMini(startX, ScreenPos.y, effect, data.Duration, data.StartTime)
                        end
                    end
                    startX = startX + 25
                end
            end
        end

    end


    net.Receive("StatusEffectAdd", function()
        local EffectName = net.ReadString()
        local Duration = net.ReadFloat()
        local StartTime = CurTime()

        local StatusEntry = {
            EffectName = EffectName,
            Duration = Duration,
            StartTime = StartTime
        }

        ActiveEffects[EffectName] = StatusEntry
    end)

    net.Receive("StatusEffectRemove", function()
        local EffectName = net.ReadString()
        ActiveEffects[EffectName] = nil
    end)
    

    net.Receive("StatusEffectTransfer", function()

        local DataLength = net.ReadUInt(16)
        local Compressed = net.ReadData(DataLength)
        local Decompressed = util.Decompress(Compressed)

        AllEntEffects = util.JSONToTable(Decompressed)
        
    end)

    hook.Add("HUDPaint", "DisplayStatusEffectsHUD", DisplayStatusEffects)
end