AddCSLuaFile()

if SERVER then
    resource.AddFile("materials/vgui/milk_vignette.vmt")
end


SWEP.Kind = WEAPON_NONE
SWEP.CanBuy = nil

if CLIENT then
   SWEP.EquipMenuData = nil
   
   SWEP.Icon = "vgui/ttt/icon_nades"
   
   SWEP.DrawCrosshair = false
   SWEP.ViewModelFOV = 82
   SWEP.ViewModelFlip = false
   SWEP.CSMuzzleFlashes = true
end

SWEP.AutoSpawnable = false

SWEP.AllowDrop = true

SWEP.IsSilent = false

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "Ironsights")
	self:NetworkVar("Bool", 1, "Reloading")
	self:NetworkVar("Float", 2, "ReloadStartTime")
	self:NetworkVar("Float", 3, "ReloadEndTime")
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

SWEP.Secondary.Sound		= Sound( "milkwater_common/shoulder_weapon.wav" )
SWEP.Secondary.ClipSize     = 1
SWEP.Secondary.DefaultClip  = 1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"
SWEP.Secondary.ClipMax      = -1

SWEP.ShotgunReload = false
SWEP.ReloadTimer = 0
SWEP.PendingShells = 0

SWEP.ADS_FOV = 70
SWEP.ADS_Time = 0.18
SWEP.ADS_RecoilMul = 0.65
SWEP.ADS_ConeMul   = 0.55
SWEP.ADS_Pos = Vector(3, 0, 1)
SWEP.ADS_Ang = Angle(0, 0, 0)
SWEP.IronSightsPos = SWEP.ADS_Pos
SWEP.IronSightsAng = SWEP.ADS_Ang

SWEP.HeadshotMultiplier = 2
SWEP.IsSilent = false

SWEP.StoredAmmo = 0

SWEP.IsDropped = false

SWEP.DeploySpeed = 0.5

SWEP.PrimaryAnim = ACT_VM_PRIMARYATTACK
SWEP.ReloadAnim = ACT_VM_RELOAD

SWEP.fingerprints = {}

-- csgo style recoil pattern
SWEP.RecoilPattern = {
    {p = 2.50, y = 1.00},
}

-- visual effects dont touch
SWEP.VignetteStrength = SWEP.VignetteStrength or 0

-- helper function for my timers
local function TimerName(self, id)
    return "mw_wep_" .. tostring(self:EntIndex()) .. "_" .. id
end

-- set the hold type
function SWEP:Initialize()
	if self.SetWeaponHoldType then self:SetWeaponHoldType(self.HoldType or "pistol") end
end

-- are we allowed to attack
function SWEP:CanPrimaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return false end
	
    -- no ammo
    if self:Clip1() <= 0 then return false end
	
    -- allow cancelling shotgun reload
    if self.ShotgunReload and self:GetReloading() then
        return true
    end

    -- dont allow if we networked reloading
    local reloadEnd = self:GetReloadEndTime() or 0
    if CurTime() < reloadEnd then
        return false
    end

    return true
end

-- main shooting function
function SWEP:PrimaryAttack(worldsnd)
	-- bruh
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	
    -- cancel only during shell-insert
	if self.ShotgunReload and self:GetReloading() and IsFirstTimePredicted() then
		local vm = owner:GetViewModel()
		if IsValid(vm) then
			local act = vm:GetSequenceActivity(vm:GetSequence())
			
			if act ~= ACT_SHOTGUN_RELOAD_FINISH then
				self:SetReloading(false)
				self.PendingShells = 0

				local seq = vm:SelectWeightedSequence(ACT_VM_IDLE)
				if seq and seq >= 0 then
					vm:SendViewModelMatchingSequence(seq)
				end
			end
		end
	end
	
	-- no ammo?
	if self:CanPrimaryAttack() == false then
		if CLIENT then
			self:EmitSound("Weapon_Pistol.Empty")
		end
		
		self:SetNextPrimaryFire(CurTime() + 0.2)
		return
	end
	
	-- lol
	if not IsFirstTimePredicted() then return end
	
	-- timing
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	
	-- consume ammo
	self:TakePrimaryAmmo(1)
	
	-- make a sound
	if not worldsnd then
		self:EmitSound( self.Primary.Sound, self.Primary.SoundLevel )
	elseif SERVER then
		sound.Play(self.Primary.Sound, self:GetPos(), self.Primary.SoundLevel)
	end
	
	-- shoot bullet
	local cone = self.Primary.Cone
	self:ShootBullet(self.Primary.Damage, self.Primary.NumShots, cone)
	
	-- do recoil under super specific circumstances
	if SERVER and game.SinglePlayer() or CLIENT and not game.SinglePlayer() and IsFirstTimePredicted() then
		self:DoRecoil()
	end
	
	-- sfx cus its cool
	owner:SetAnimation(PLAYER_ATTACK1)
	self.VignetteStrength = math.min(self.VignetteStrength + 0.1, 1)
end

function SWEP:SecondaryAttack()
	if self:GetReloading() then return end
	
	local ironsightsState = self:GetIronsights()
	self:SetIronsights(not ironsightsState)
	self:SetZoom(not ironsightsState)
   
	if CLIENT and not ironsightsState then
		self:EmitSound(self.Secondary.Sound, 75, 100, 1, CHAN_BODY)
	end
end

local function GetPlayerBaseFOV(ply)
    if not IsValid(ply) then return 90 end
	
    return ply:GetInfoNum("fov_desired", 90)
end

function SWEP:SetZoom(state)
	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:IsPlayer() then return end
	
	if state then
		owner:SetFOV(60, 0.3)
	else
		local baseFOV = GetPlayerBaseFOV(owner)
		owner:SetFOV(baseFOV, 0.2)
	end
end

function SWEP:Reload()
	-- bruh
	if not IsValid(self) then return end
	if not IsValid(self:GetOwner()) then return end
	
	-- if full clip or no ammo, no reload
	if self:Clip1() >= self.Primary.ClipSize then return end
	if self:GetOwner():GetAmmoCount(self.Primary.Ammo) <= 0 then return end
	
	-- if already reloading, no reload
	if self:GetReloading() then return end
	if not IsFirstTimePredicted() then return end
	
	-- stop aiming
	self:SetIronsights(false)
	self:SetZoom(false)
	
    -- normal magazine reload
    if not self.ShotgunReload then
		-- tell player im reloading
		self:SetReloading(true)
		
        self:SendWeaponAnim(ACT_VM_RELOAD)
        self:GetOwner():SetAnimation(PLAYER_RELOAD)

		local now = CurTime()
        local dur = self:SequenceDuration()
		self:SetReloadStartTime(now)
		self:SetReloadEndTime(now + dur)
        self:SetNextPrimaryFire(now + dur)

        local tname = TimerName(self, "mag_reload")
		timer.Create(tname, dur, 1, function()
			if not IsValid(self) then return end
			if self.Holstered then return end
			local owner = self:GetOwner()
			if not IsValid(owner) then return end

			local missing = self.Primary.ClipSize - self:Clip1()
			local toLoad = math.min(missing, owner:GetAmmoCount(self.Primary.Ammo))

			if toLoad > 0 then
				self:SetClip1(self:Clip1() + toLoad)
				owner:RemoveAmmo(toLoad, self.Primary.Ammo)
			end

			self:SetReloading(false)
		end)

        return
    end

    -- shotgun reload
    if self:Clip1() < self.Primary.ClipSize
        and self:GetOwner():GetAmmoCount(self.Primary.Ammo) > 0
    then
        self:StartReload()
    end
end

function SWEP:StartReload()
    self:SetReloading(true)

    local now = CurTime()
    local dur = self:SequenceDuration()

    self.ReloadTimer = now + dur
    self:SetReloadStartTime(now)
    self:SetReloadEndTime(now + dur)

	-- reset irons
    self:SetIronsights(false)
    self:SetZoom(false)

    self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
    self:GetOwner():SetAnimation(PLAYER_RELOAD)

    return true
end

function SWEP:PerformReload()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    -- no reserve ammo?
    if owner:GetAmmoCount(self.Primary.Ammo) <= 0 then
        self:FinishReload()
        return
    end

    -- already full?
    if (self:Clip1() + self.PendingShells) >= self.Primary.ClipSize then
        self:FinishReload()
        return
    end

    -- play insert animation
    self:SendWeaponAnim(ACT_VM_RELOAD)

	local now = CurTime()
	local dur = self:SequenceDuration()
	local animationMalus = 0.3
	
    self.ReloadTimer = now + dur
	self:SetReloadStartTime(now)
	self:SetReloadEndTime(now + dur)

    -- reserve shell immediately so think doesn't double trigger
    self.PendingShells = self.PendingShells + 1
	
    -- add the shell after the animation finishes
    local tname = TimerName(self, "insert_shell")
	timer.Create(tname, math.max(0, dur - animationMalus), 1, function()
		if not IsValid(self) then return end
		if self.Holstered then return end
		local o = self:GetOwner()
		if not IsValid(o) then return end

		if self.PendingShells <= 0 then return end
		if self:Clip1() >= self.Primary.ClipSize then
			self.PendingShells = 0
			self:FinishReload()
			return
		end

		self:SetClip1(self:Clip1() + 1)
		self.PendingShells = self.PendingShells - 1
		o:RemoveAmmo(1, self.Primary.Ammo)
		
		if SERVER then
			o:DoAnimationEvent(ACT_HL2MP_GESTURE_RELOAD_PISTOL)
		end
	end)
end

function SWEP:FinishReload()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    -- make reload timer based on final pumping animation ending
    local dur = 0
    local vm = owner:GetViewModel()
    if IsValid(vm) then
        local seq = vm:SelectWeightedSequence(ACT_SHOTGUN_RELOAD_FINISH)
        if seq and seq >= 0 then
            vm:SendViewModelMatchingSequence(seq)
            local rate = vm:GetPlaybackRate() or 1
            dur = vm:SequenceDuration(seq) / rate
        end
    end
	
	self.ReloadTimer = CurTime() + dur
	self:SetReloadEndTime(self.ReloadTimer)
    self:SetReloading(false)

    -- flush pending shells after animation is done
    local tname = TimerName(self, "finish_flush")
	timer.Create(tname, dur, 1, function()
		if not IsValid(self) then return end
		if self.Holstered then return end
		local o = self:GetOwner()
		if not IsValid(o) then return end

		if self.PendingShells > 0 then
			local canAdd = math.min(self.PendingShells, self.Primary.ClipSize - self:Clip1())
			if canAdd > 0 then
				self:SetClip1(self:Clip1() + canAdd)
				self.PendingShells = self.PendingShells - canAdd
			end
		end
	end)
end

function SWEP:DoRecoil()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local recoil = self.Primary.Recoil or 1
	
	-- modify if aiming down sights
	if self:GetIronsights() then
		recoil = recoil * 0.5
	end

    -- initialize recoil step
    self.RecoilStep = (self.RecoilStep or 1)

    -- csgo recoil, recoil pattern that repeats the last step
	local pat = nil

	if self.RecoilPattern then
		pat = self.RecoilPattern[self.RecoilStep] or self.RecoilPattern[#self.RecoilPattern]
	end

	local pitch = recoil
	local yaw = math.Rand(-0.20, 0.20) * recoil

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
	ang.y = ang.y - yaw * 0.12
	owner:SetEyeAngles(ang)

	self.RecoilStep = self.RecoilStep + 1
	return
end

function SWEP:ShootBullet(dmg, numbul, cone)
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    self:SendWeaponAnim(self.PrimaryAnim)

    -- recoil modified aim
    local ang = owner:EyeAngles() + owner:GetViewPunchAngles()
    local dir = ang:Forward()
	
	-- check if we should have a tracer
	local silentGun = self.IsSilent

    -- normal bullet
    local bullet = {}
    bullet.Num    = numbul
    bullet.Src    = owner:GetShootPos()
    bullet.Dir    = dir
    bullet.Spread = Vector(cone, cone, 0)
    bullet.Tracer = silentGun and 0 or 1
	bullet.TracerName = "milkwater_tracer"
    bullet.Force  = dmg * 0.5
    bullet.Damage = dmg

    owner:FireBullets(bullet)
end

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
	
	-- custom reload that does not block think entirely
	if SERVER and self.ShotgunReload and self:GetReloading() then
        if CurTime() >= self.ReloadTimer then
            if self:Clip1() < self.Primary.ClipSize and self:GetOwner():GetAmmoCount(self.Primary.Ammo) > 0 then
                self:PerformReload()
            else
                self:FinishReload()
            end
        end
	end
	
	-- custom aim down sights lerp
	if not self:GetReloading() then
		local aiming = self:GetIronsights()
		local target = aiming and 1 or 0
		self.ADS_Progress = Lerp(FrameTime() * (1 / self.ADS_Time), self.ADS_Progress or 0, target)
	end
	
	-- make camera recoil slowly return to 0
	if CLIENT then
		self.RecoilKick = Lerp(FrameTime() * 10, self.RecoilKick or 0, 0)
	end

    -- check if player is attacking
	local playerIsAttacking = owner:KeyDown(IN_ATTACK)
	
	-- reset recoil pattern
    if not playerIsAttacking then
		self.RecoilStep = 1
    end
	
	-- make sfx slowly return to 0 when done firing, out of ammo, or reloading
	if not playerIsAttacking or not self:CanPrimaryAttack()then
		self.VignetteStrength = Lerp(FrameTime() * 6, self.VignetteStrength, 0)
	end
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    local dur = 0

    if IsValid(owner) then
        local vm = owner:GetViewModel()
        if IsValid(vm) then
            local seq = vm:SelectWeightedSequence(ACT_VM_DRAW)
            if seq and seq >= 0 then
                vm:SendViewModelMatchingSequence(seq)
                local rate = vm:GetPlaybackRate()
                if not rate or rate <= 0 then rate = 1 end
                dur = vm:SequenceDuration(seq) / rate
            end
        end
    end

    self:SetNextPrimaryFire(CurTime() + dur)
    return true
end

function SWEP:Holster(weapon)
	-- stop aiming down sights
	self:SetIronsights(false)
	self:SetZoom(false)
	
	-- cancel reload states
	self:CancelAllTimers()
	
	-- actually holster
	return true
end

function SWEP:OwnerChanged()
    -- if owner is gone or dead clean up timers
    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:Alive() then
        self:CancelAllTimers()
    end
end

function SWEP:OnRemove()
    -- clean up if the weapon entity itself is removed
    self:CancelAllTimers()
end

function SWEP:CancelAllTimers()
    local base = "mw_wep_" .. tostring(self:EntIndex()) .. "_"
    timer.Remove(base .. "mag_reload")
    timer.Remove(base .. "insert_shell")
    timer.Remove(base .. "finish_flush")

    -- reset states
    self:SetReloading(false)
    self.PendingShells = 0
    self.ReloadTimer = 0
    if self.SetReloadStartTime then
        self:SetReloadStartTime(0)
    end
    if self.SetReloadEndTime then
        self:SetReloadEndTime(0)
    end
end


function SWEP:GetHeadshotMultiplier(victim, dmginfo)
	return self.HeadshotMultiplier
end

if CLIENT then
	function SWEP:CalcViewModelView(vm, oldPos, oldAng, pos, ang)
		-- get current kick
		local kick = self.RecoilKick or 0

		-- push the gun backward and slightly up
		pos = pos - ang:Forward() * kick * 0.5
		pos = pos + ang:Up() * kick * 0.1
		
		-- mirror if possible
		if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() and vm == self:GetOwner():GetViewModel() and self.ViewModelFlip then
			ang.r = -ang.r
		end

		-- tilt the gun slightly
		ang:RotateAroundAxis(ang:Right(), -kick * 2)
		ang:RotateAroundAxis(ang:Up(), kick * 0.5)
		
		-- custom aim down sights
		if self.ADS_Progress and self.ADS_Progress > 0 then
			local flipModifier = 1
			if self.ViewModelFlip then
				flipModifier = -1
			end
			pos = pos - ang:Right() * self.IronSightsPos.x * self.ADS_Progress * flipModifier
			pos = pos - ang:Forward() * self.IronSightsPos.y * self.ADS_Progress
			pos = pos - ang:Up() * self.IronSightsPos.z * self.ADS_Progress
			ang:RotateAroundAxis(ang:Right(), self.IronSightsAng.p * self.ADS_Progress)
			ang:RotateAroundAxis(ang:Up(), self.IronSightsAng.y * self.ADS_Progress)
			ang:RotateAroundAxis(ang:Forward(), self.IronSightsAng.r * self.ADS_Progress)
		end

		return pos, ang
	end

	function SWEP:DrawHUD()
		local owner = LocalPlayer()
		if not IsValid(owner) then return end

		local x = ScrW() * 0.5
		local y = ScrH() * 0.5

		-- draw crosshair
		if self:GetReloading() then
			self:DrawReloadCircle(x, y)
		else
			self:DrawCrosshairHUD(x, y)
		end

		-- draw ammo arc
		self:DrawAmmoArc(x + 50, y)
		
		-- draw vignette
		self:DrawRecoilVignette()
		
		-- lol
		self:DrawRecoilPatternHUD()
	end
	
	function SWEP:DrawCrosshairHUD(x, y)
		local baseGap = math.max(0.2, 100 * self.Primary.Cone)
		local coneGap = self.Primary.Cone * 300
		local recoilKick = (self.RecoilKick or 0) * 4
		local gap = baseGap + coneGap + recoilKick

		local length = 8 + recoilKick

		surface.SetDrawColor(255, 255, 255, 255)
		
		surface.DrawLine(x - gap, y, x - gap - length, y) -- left
		surface.DrawLine(x + gap, y, x + gap + length, y) -- right
		surface.DrawLine(x, y - gap, x, y - gap - length) -- top
		surface.DrawLine(x, y + gap, x, y + gap + length) -- bottom
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
		
		local arcSize = 120

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
	
	function SWEP:DrawRecoilPatternHUD()
		local pat = self.RecoilPattern
		if not pat then return end

		local step = math.min(self.RecoilStep or 1, #pat) or 1

		-- HUD box
		local x = 10
		local y = ScrH() - 400
		local w = 200
		local h = 200

		-- background
		surface.SetDrawColor(0, 0, 0, 120)
		surface.DrawRect(x, y, w, h)

		-- border
		surface.SetDrawColor(255, 255, 255, 40)
		surface.DrawOutlinedRect(x, y, w, h)
		
		-- border text
		draw.SimpleText("Current Recoil Pattern", "DermaDefaultBold", x + 10, y + h + 10, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		
		-- build cumulative pitch/yaw
		local cumP = {}
		local cumY = {}

		cumP[1] = pat[1].p
		cumY[1] = pat[1].y

		for i = 2, #pat do
			cumP[i] = cumP[i-1] + pat[i].p
			cumY[i] = cumY[i-1] + pat[i].y
		end

		-- find max values for scaling
		local maxCumP, maxCumY = 0, 0
		for i = 1, #pat do
			maxCumP = math.max(maxCumP, cumP[i])
			maxCumY = math.max(maxCumY, math.abs(cumY[i]))
		end

		local yawScale = 0.8

		-- draw pattern
		for i = 1, #pat - 1 do
			local ax = x + w * 0.5 + (cumY[i] / maxCumY) * (w * 0.5) * yawScale
			local ay = y + h - (cumP[i] / maxCumP) * h

			local bx = x + w * 0.5 + (cumY[i+1] / maxCumY) * (w * 0.5) * yawScale
			local by = y + h - (cumP[i+1] / maxCumP) * h

			surface.SetDrawColor(255, 255, 255, 180)
			surface.DrawLine(ax, ay, bx, by)

			-- dot
			surface.SetDrawColor(255, 255, 255, 220)
			surface.DrawRect(ax - 2, ay - 2, 4, 4)
		end


		-- highlight current step
		if pat[step] then
			local c = pat[step]
			local repeating = (step >= #self.RecoilPattern)

			local cx = x + w * 0.5 + (cumY[step] / maxCumY) * (w * 0.5) * yawScale
			local cy = y + h - (cumP[step] / maxCumP) * h

			surface.SetDrawColor(255, 100, 100, 255)
			surface.DrawRect(cx - 3, cy - 3, 6, 6)

			if repeating then
				draw.SimpleText("REPEATING", "DermaDefaultBold", cx + 10, cy - 10, Color(255, 100, 100, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
		end
	end
	
	function SWEP:GetReloadProgress()
		if not self:GetReloading() then return 0 end

		local start = self:GetReloadStartTime() or 0
		local finish = self:GetReloadEndTime() or 0
		local now = CurTime()

		if start <= 0 or finish <= start then return 0 end
		if now >= finish then return 1 end

		return math.Clamp((now - start) / (finish - start), 0, 1)
	end

	function SWEP:DrawReloadCircle(x, y)
		local prog = self:GetReloadProgress()
		if prog <= 0 then return end

		local radius = 20
		local thickness = 20
		local segments = 64

		surface.SetDrawColor(255, 255, 255, 220)
		draw.NoTexture()

		local startAng = -90
		local endAng = startAng + (prog * 360)

		for i = 0, segments - 1 do
			local t0 = i / segments
			local t1 = (i + 1) / segments

			local a0 = math.rad(startAng + t0 * (endAng - startAng))
			local a1 = math.rad(startAng + t1 * (endAng - startAng))

			local ox0 = x + math.cos(a0) * radius
			local oy0 = y + math.sin(a0) * radius
			local ox1 = x + math.cos(a1) * radius
			local oy1 = y + math.sin(a1) * radius

			local ix0 = x + math.cos(a0) * (radius - thickness)
			local iy0 = y + math.sin(a0) * (radius - thickness)
			local ix1 = x + math.cos(a1) * (radius - thickness)
			local iy1 = y + math.sin(a1) * (radius - thickness)

			surface.DrawPoly({
				{ x = ox0, y = oy0 },
				{ x = ox1, y = oy1 },
				{ x = ix1, y = iy1 },
				{ x = ix0, y = iy0 },
			})
		end
	end
	
end