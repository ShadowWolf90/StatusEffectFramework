if SERVER then

    util.AddNetworkString("StatusEffectAdd")
    util.AddNetworkString("StatusEffectRemove")
    util.AddNetworkString("StatusEffectTransfer")

    local ENTITY = FindMetaTable("Entity")

    function ENTITY:ApplyEffect(effectName, time, ...)
        local effect = StatusEffects[effectName]
        if effect and (self:IsPlayer() or self:IsNPC() or self:IsNextBot()) then

            if not self.activeEffects then
                self.activeEffects = {}
            end

            if not self.activeEffects[effectName] then
                print("[Status Effect Framework] Applied effect:", effectName, "to entity:", self)
            end

            self.activeEffects[effectName] = {
                Function = effect.Effect,
                StartTime = CurTime(),
                Duration = time,
                Args = {...}
            }

            if self:IsPlayer() then
                net.Start("StatusEffectAdd")
                net.WriteString(effectName)
                net.WriteFloat(time)
                net.Send(self)
            end

        else
            print("[Status Effect Framework] Effect not found")
        end
    end
    
    function ENTITY:RemoveEffect(effectName)
        if self.activeEffects and self.activeEffects[effectName] then
            self.activeEffects[effectName] = nil
            print("[Status Effect Framework] Effect:", effectName, "removed from", self)

            if self:IsPlayer() then
                net.Start("StatusEffectRemove")
                net.WriteString(effectName)
                net.Send(self)
            end
        else
            print("[Status Effect Framework] Effect not active or not found:", effectName)
        end
    end

end
