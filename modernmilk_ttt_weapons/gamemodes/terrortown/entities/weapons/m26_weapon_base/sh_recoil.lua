-- sh_recoil.lua

SWEP.ShakePower = 3.0
SWEP.ShakeDecay = 3.0
SWEP.ShakePitchMult = 0.5
SWEP.ShakeRollMult = 1.0

SWEP.ShakeFrac = 0
SWEP.ShakeTarget = 0
SWEP.ShakeFlip = 1
SWEP.ShakeFlipTarget = 1

function SWEP:GetBloomMax()
    return self.Primary.Cone * self.BloomMultiplier
end

function SWEP:GetCurrentCone()
    local owner = self:GetOwner()
    if not IsValid(owner) then
        return self.Primary.Cone + self.Bloom
    end

    local cone = self.Primary.Cone + self.Bloom

    -- crouch bonus
    if owner:Crouching() then
        cone = cone * 0.8
    end

    -- irons bonus
    if self:GetIronsights() then
		if self.ScopedConeMultiplier then
			cone = cone * self.ScopedConeMultiplier
		else
			cone = cone * 0.5
		end
    end

    return cone
end

function SWEP:DoRecoil()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local base = self.Primary.Recoil or 1

    -- crouch bonus
    if owner:Crouching() then
        base = base * 0.8
    end

    -- irons bonus
    if self:GetIronsights() then
        base = base * 0.6
    end

    -- ramp recoil over time
    self.RecoilRise = math.min(self.RecoilRise + self.RecoilRiseRate, 1)

    -- actual recoil values
    local pitch = base * 0.4 * self.RecoilRise
    local yaw   = base * 0.1 * math.Rand(-1, 1)

    -- add to target recoil
    self.RecoilTargetPitch = self.RecoilTargetPitch + pitch
    self.RecoilTargetYaw   = self.RecoilTargetYaw + yaw
end

function SWEP:ThinkRecoil()
    if not CLIENT then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local dt = FrameTime()

    -- critically damped spring constants
    local k = self.RecoilSpeed
    local d = self.RecoilDamping

    -- spring toward target
    local dp = self.RecoilTargetPitch - self.RecoilCurPitch
    local dy = self.RecoilTargetYaw   - self.RecoilCurYaw

    -- update current recoil
    self.RecoilCurPitch = self.RecoilCurPitch + dp * k * dt
    self.RecoilCurYaw   = self.RecoilCurYaw   + dy * k * dt

    -- damping
    self.RecoilCurPitch = self.RecoilCurPitch - self.RecoilCurPitch * d * dt
    self.RecoilCurYaw   = self.RecoilCurYaw   - self.RecoilCurYaw   * d * dt

    -- compute delta to apply to view
    local deltaPitch = self.RecoilCurPitch - self.RecoilLastPitch
    local deltaYaw   = self.RecoilCurYaw   - self.RecoilLastYaw

    -- apply only the delta
    local ang = owner:EyeAngles()
    ang.p = ang.p - deltaPitch
    ang.y = ang.y + deltaYaw
    owner:SetEyeAngles(ang)

    -- store for next frame
    self.RecoilLastPitch = self.RecoilCurPitch
    self.RecoilLastYaw   = self.RecoilCurYaw
end
