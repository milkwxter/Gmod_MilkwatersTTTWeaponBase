AddCSLuaFile()

SWEP.Kind = WEAPON_NONE
SWEP.CanBuy = nil

if CLIENT then
   SWEP.EquipMenuData = nil
   
   SWEP.Icon = "vgui/ttt/icon_nades"
end

SWEP.AutoSpawnable = false

SWEP.AllowDrop = true

SWEP.IsSilent = false

if CLIENT then
   SWEP.DrawCrosshair   = false
   SWEP.ViewModelFOV    = 82
   SWEP.ViewModelFlip   = true
   SWEP.CSMuzzleFlashes = true
end

SWEP.Base = "weapon_base"

SWEP.Category           = "TTT"
SWEP.Spawnable          = true

SWEP.IsGrenade = false

SWEP.Weight             = 5

SWEP.Primary.Sound          = Sound( "Weapon_Pistol.Empty" )
SWEP.Primary.Recoil         = 1.5
SWEP.Primary.Damage         = 1
SWEP.Primary.NumShots       = 1
SWEP.Primary.Cone           = 1
SWEP.Primary.Delay          = 0.15

SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = false
SWEP.AmmoEnt 				= "none"
SWEP.Primary.Ammo           = "none"
SWEP.Primary.ClipMax        = -1

SWEP.Secondary.ClipSize     = 1
SWEP.Secondary.DefaultClip  = 1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"
SWEP.Secondary.ClipMax      = -1

SWEP.HeadshotMultiplier = 2

SWEP.StoredAmmo = 0
SWEP.IsDropped = false

SWEP.DeploySpeed = 0.5

SWEP.PrimaryAnim = ACT_VM_PRIMARYATTACK
SWEP.ReloadAnim = ACT_VM_RELOAD

SWEP.fingerprints = {}

SWEP.RecoilPattern = {
    {p = 1.0, y = 0.00},
    {p = 1.1, y = 0.15},
    {p = 1.2, y = 0.30},
    {p = 1.3, y = 0.45},
    {p = 1.4, y = 0.30},
    {p = 1.5, y = 0.10},
    {p = 1.6, y = -0.10},
    {p = 1.7, y = -0.25},
    {p = 1.8, y = -0.40},
}

SWEP.RecoilMode = {
    CSGO = 1,
    EFT  = 2
}

SWEP.CurrentRecoilMode = SWEP.RecoilMode.CSGO

-- visual effects dont touch
SWEP.VignetteStrength = SWEP.VignetteStrength or 0
SWEP.ChromaStrength = SWEP.VignetteStrength or 0

function SWEP:CanPrimaryAttack()
	if not IsValid(self:GetOwner()) then return end
	
	if self:Clip1() <= 0 then return false end
	
	if self:isCurrentlyReloading() then return false end
	
	return true
end

-- main shooting function
function SWEP:PrimaryAttack(worldsnd)
	-- bruh
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	
	-- no ammo?
	if self:CanPrimaryAttack() == false then
		if self:isCurrentlyReloading() then return end
		self:EmitSound("Weapon_Pistol.Empty")
		self:SetNextPrimaryFire(CurTime() + 0.2)
		return
	end
	
	-- timing
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	
	-- recoil (camera kick)
	self:DoRecoil()
	
	-- consume ammo
	self:TakePrimaryAmmo(1)
	
	-- make a sound
	if not worldsnd then
		self:EmitSound( self.Primary.Sound, self.Primary.SoundLevel )
	elseif SERVER then
		sound.Play(self.Primary.Sound, self:GetPos(), self.Primary.SoundLevel)
	end
	
	-- shoot bullet
	cone = self.Primary.Cone
	self:ShootBullet( self.Primary.Damage, self.Primary.NumShots, cone )
	
	-- sfx cus its cool
	self.VignetteStrength = math.min(self.VignetteStrength + 0.1, 1)
	self.ChromaStrength = math.min(self.ChromaStrength + 0.2, 1)
end

function SWEP:SecondaryAttack()
	-- lol
	return
end

function SWEP:Reload()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if self:Clip1() >= self.Primary.ClipSize then return end
    if self:isCurrentlyReloading() then return end
	if owner:GetAmmoCount(self.Primary.Ammo) == 0 then return end

    -- start reload timer
    self:StartReloadTimer()

    -- play animation WITHOUT blocking Think()
    local vm = owner:GetViewModel()
    if IsValid(vm) then
        local seq = vm:SelectWeightedSequence(self.ReloadAnim)
        vm:SendViewModelMatchingSequence(seq)
    end

    return true
end

function SWEP:FinishReload()
    if self._reloaded then return end
    self._reloaded = true

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local clipMax = self.Primary.ClipSize
    local clip    = self:Clip1()
    local missing = clipMax - clip

    if missing <= 0 then return end

    -- check reserves
    local reserve = owner:GetAmmoCount(self.Primary.Ammo)

    if reserve <= 0 then return end

    -- how much can we load
    local toLoad = math.min(missing, reserve)

    -- fill the magazine
    self:SetClip1(clip + toLoad)

    -- subtract from reserve
    owner:RemoveAmmo(toLoad, self.Primary.Ammo)
end

function SWEP:StartReloadTimer()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local vm = owner:GetViewModel()
    if not IsValid(vm) then return end
	
	self._reloaded = false

    local seq = vm:SelectWeightedSequence(self.ReloadAnim)
    if not seq or seq < 0 then
        self.ReloadEndTime = CurTime() + 1
        return
    end

    local rate = vm:GetPlaybackRate()
    if not rate or rate <= 0 then rate = 1 end

    local dur = vm:SequenceDuration(seq) / rate
    self.ReloadEndTime = CurTime() + dur
end

function SWEP:isCurrentlyReloading()
    return self.ReloadEndTime and CurTime() < self.ReloadEndTime
end

function SWEP:GetHeadshotMultiplier(victim, dmginfo)
   return self.HeadshotMultiplier
end

function SWEP:DoRecoil()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local recoil = self.Primary.Recoil or 1

    -- initialize recoil step
    self.RecoilStep = (self.RecoilStep or 1)

    -- csgo recoil, recoil pattern that repeats the last step
    if self.CurrentRecoilMode == self.RecoilMode.CSGO then
        local pat = nil

        if self.RecoilPattern then
            pat = self.RecoilPattern[self.RecoilStep] or self.RecoilPattern[#self.RecoilPattern]
        end

        local pitch = recoil
        local yaw = math.Rand(-0.25, 0.25) * recoil

        if pat then
            pitch = pat.p * recoil
            yaw = pat.y * recoil
        end

        -- camera punch
        owner:ViewPunch(Angle(-pitch * 1.2, yaw * 1.0, 0))

        -- viewmodel kick
        if CLIENT and owner == LocalPlayer() then
            self.RecoilKick = (self.RecoilKick or 0) + pitch * 0.3
        end

        -- actual aim drift
        local ang = owner:EyeAngles()
        ang.p = ang.p - pitch * 0.12
        ang.y = ang.y + yaw * 0.12
        owner:SetEyeAngles(ang)

        self.RecoilStep = self.RecoilStep + 1
        return
    -- eft recoil, recoil pattern that STOPS on the last step
    elseif self.CurrentRecoilMode == self.RecoilMode.EFT then
        -- momentum-based recoil
        self.EFT_RecoilPitch = (self.EFT_RecoilPitch or 0) + recoil * 0.25
        self.EFT_RecoilYaw   = (self.EFT_RecoilYaw or 0) + math.Rand(-0.1, 0.1) * recoil

        -- camera punch
        owner:ViewPunch(Angle(-recoil * 0.5, math.Rand(-0.1, 0.1) * recoil, 0))

        -- viewmodel kick
        if CLIENT and owner == LocalPlayer() then
            self.RecoilKick = (self.RecoilKick or 0) + recoil * 0.2
        end

        -- apply accumulated recoil
        local ang = owner:EyeAngles()
        ang.p = ang.p - self.EFT_RecoilPitch
        ang.y = ang.y + self.EFT_RecoilYaw
        owner:SetEyeAngles(ang)

        return
    end
end

function SWEP:ShootBullet(dmg, numbul, cone)
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    self:SendWeaponAnim(self.PrimaryAnim)

    -- recoil modified aim
    local ang = owner:EyeAngles() + owner:GetViewPunchAngles()
    local dir = ang:Forward()
	
	-- most muzzle attachments are named 1
	local muzzleAttachment = "1"

    -- normal bullet
    local bullet = {}
    bullet.Num    = numbul
    bullet.Src    = owner:GetShootPos()
    bullet.Dir    = dir
    bullet.Spread = Vector(cone, cone, 0)
    bullet.Tracer = 0
    bullet.Force  = dmg * 0.5
    bullet.Damage = dmg
	
    bullet.Callback = function(att, tr, dmginfo)
        local startPos = owner:GetShootPos()
        local vm = owner:GetViewModel()
        if IsValid(vm) then
            local id = vm:LookupAttachment(muzzleAttachment)
            if id > 0 then
                local a = vm:GetAttachment(id)
                if a then
                    startPos = a.Pos
                end
            end
        end
		
		
		local modifiedShootPos = startPos
		local kick = self.RecoilKick or 0
		modifiedShootPos = modifiedShootPos - ang:Forward() * kick * 0.5
		modifiedShootPos = modifiedShootPos + ang:Up() * kick * 0.1

        -- spawn my tracer effect
        local effect = EffectData()
        effect:SetStart(modifiedShootPos)
        effect:SetOrigin(tr.HitPos)
        effect:SetNormal(tr.HitNormal)
        util.Effect("milkwater_tracer", effect)
    end

    owner:FireBullets(bullet)
end

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
	
	-- custom reload that does not block think entirely
	if SERVER and self.ReloadEndTime and CurTime() >= self.ReloadEndTime then
		self:FinishReload()
	end
	
	-- make camera recoil slowly return to 0
	if CLIENT then
		self.RecoilKick = Lerp(FrameTime() * 10, self.RecoilKick or 0, 0)
	end

    -- check if player is attacking
	local playerIsAttacking = owner:KeyDown(IN_ATTACK)
	
	-- reset CSGO recoil pattern
    if not playerIsAttacking then
        self.RecoilStep = 1
    end
	
	-- make sfx slowly return to 0 when done firing, out of ammo, or reloading
	if not playerIsAttacking or not self:CanPrimaryAttack()then
		self.VignetteStrength = Lerp(FrameTime() * 6, self.VignetteStrength, 0)
		self.ChromaStrength = Lerp(FrameTime() * 6, self.ChromaStrength, 0)
	end

    -- EFT recoil recovery
    if self.CurrentRecoilMode == self.RecoilMode.EFT then
        self.EFT_RecoilPitch = Lerp(FrameTime() * 6, self.EFT_RecoilPitch or 0, 0)
        self.EFT_RecoilYaw = Lerp(FrameTime() * 6, self.EFT_RecoilYaw or 0, 0)
    end
end

function SWEP:CalcViewModelView(vm, oldPos, oldAng, pos, ang)
	-- get current kick
    local kick = self.RecoilKick or 0

    -- push the gun backward and slightly up
    pos = pos - ang:Forward() * kick * 0.5
    pos = pos + ang:Up() * kick * 0.1

    -- tilt the gun slightly
    ang:RotateAroundAxis(ang:Right(), -kick * 2)
    ang:RotateAroundAxis(ang:Up(), kick * 0.5)

    return pos, ang
end

function SWEP:Deploy()
    local vm = self.Owner:GetViewModel()
    if IsValid(vm) then
		local seq = vm:SelectWeightedSequence(ACT_VM_DRAW)
        vm:SendViewModelMatchingSequence(seq)
		-- get length of deploy sequence
		if seq and seq >= 0 then
			local rate = vm:GetPlaybackRate()
			if not rate or rate <= 0 then rate = 1 end
			dur = vm:SequenceDuration(seq) / rate
		end
    end
	
	self:SetNextPrimaryFire(CurTime() + dur)

    return true
end

if CLIENT then
	function SWEP:DrawHUD()
		local owner = LocalPlayer()
		if not IsValid(owner) then return end

		local x = ScrW() * 0.5
		local y = ScrH() * 0.5

		-- draw crosshair
		self:DrawCrosshairHUD(x, y)

		-- draw ammo arc
		self:DrawAmmoArc(x + 50, y)
		
		-- draw vignette
		self:DrawRecoilVignette()
	end
	
	function SWEP:DrawCrosshairHUD(x, y)
		local baseGap = 12
		local coneGap = (self.Primary.Cone or 0.001) * 300
		local recoilKick = (self.RecoilKick or 0) * 4
		local gap = baseGap + coneGap + recoilKick

		local length = 8
		local thickness = 2

		surface.SetDrawColor(255, 255, 255, 255)

		surface.DrawRect(x - thickness/2, y - gap - length, thickness, length)
		surface.DrawRect(x - thickness/2, y + gap, thickness, length)
		surface.DrawRect(x - gap - length, y - thickness/2, length, thickness)
		surface.DrawRect(x + gap, y - thickness/2, length, thickness)
	end
	
	-- draw a crazy tesselated slice with convex quads
	local function drawDonutSlice(centerX, centerY, innerRadius, outerRadius, startAngle, endAngle, segments, color)
		local arcLen = math.rad(endAngle - startAngle) * innerRadius
		local pixelsPerSegment = 6
		segments = math.max(segments or 0, math.ceil(arcLen / pixelsPerSegment))

		surface.SetDrawColor(color)
		draw.NoTexture()

		for i = 0, segments - 1 do
			local t0 = i / segments
			local t1 = (i + 1) / segments

			local a0 = math.rad(startAngle + t0 * (endAngle - startAngle))
			local a1 = math.rad(startAngle + t1 * (endAngle - startAngle))

			local ox0 = centerX + math.cos(a0) * outerRadius
			local oy0 = centerY + math.sin(a0) * outerRadius
			local ox1 = centerX + math.cos(a1) * outerRadius
			local oy1 = centerY + math.sin(a1) * outerRadius

			local ix0 = centerX + math.cos(a0) * innerRadius
			local iy0 = centerY + math.sin(a0) * innerRadius
			local ix1 = centerX + math.cos(a1) * innerRadius
			local iy1 = centerY + math.sin(a1) * innerRadius
			
			surface.DrawPoly({
				{ x = ox0, y = oy0 },
				{ x = ox1, y = oy1 },
				{ x = ix1, y = iy1 },
				{ x = ix0, y = iy0 },
			})
		end
	end

	function SWEP:DrawAmmoArc(x, y)
		local owner = LocalPlayer()
		if not IsValid(owner) then return end

		local clip = self:Clip1()
		local max  = self.Primary.ClipSize
		if max <= 0 then return end
		
		local minThickness = 3
		local maxThickness = 22

		-- scale thickness
		local thickness = Lerp( math.Clamp(max / 30, 0, 1), maxThickness, minThickness )

		local tickLength = 12
		local innerRadius = 50
		local outerRadius = innerRadius + tickLength
		
		local arcSize = 130

		-- center the arc around 0°
		local arcStart = -arcSize * 0.5
		local arcEnd =  arcSize * 0.5
		
		local tickArc = arcSize / max
		local tickSpacing = tickArc * 0.5
		local tickFill = tickArc - tickSpacing

		for i = 1, max do
			local startAng = arcStart + (i - 1) * tickArc
			local endAng   = startAng + tickFill

			local color
			if i <= clip then
				color = Color(255, 255, 255, 255)
			else
				color = Color(255, 255, 255, 40)
			end

			drawDonutSlice(
				x, y,
				innerRadius,
				outerRadius,
				startAng,
				endAng,
				nil,
				color
			)
		end
	end
	
	function SWEP:DrawRecoilVignette()
		local vignette = Material("vgui/milk_vignette")
		local strength = self.VignetteStrength or 0
		if strength <= 0.01 then return end

		local w, h = ScrW(), ScrH()
		local alpha = 180 * strength

		surface.SetMaterial(vignette)
		surface.SetDrawColor(255, 255, 255, alpha)
		surface.DrawTexturedRect(0, 0, w, h)
	end
	
end
