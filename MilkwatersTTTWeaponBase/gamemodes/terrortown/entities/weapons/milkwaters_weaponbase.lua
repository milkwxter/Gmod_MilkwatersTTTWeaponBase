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

-- main shooting function
function SWEP:PrimaryAttack(worldsnd)
	-- bruh
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	
	-- no ammo?
	if self:Clip1() <= 0 then
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
end

function SWEP:SecondaryAttack()
	-- lol
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

    -- ============================
    --  MODE 1: CS:GO STYLE RECOIL
    -- ============================
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
    -- ============================
    --  MODE 2: EFT STYLE RECOIL
    -- ============================
    elseif self.CurrentRecoilMode == self.RecoilMode.EFT then
        -- momentum-based recoil
        self.EFT_RecoilPitch = (self.EFT_RecoilPitch or 0) + recoil * 0.25
        self.EFT_RecoilYaw   = (self.EFT_RecoilYaw or 0) + math.Rand(-0.1, 0.1) * recoil

        -- camera punch (lighter than CSGO)
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

    -- recoil‑modified aim
    local ang = owner:EyeAngles() + owner:GetViewPunchAngles()
    local dir = ang:Forward()

    -- normal bullet
    local bullet = {}
    bullet.Num    = numbul
    bullet.Src    = owner:GetShootPos()   -- keep physics correct
    bullet.Dir    = dir
    bullet.Spread = Vector(cone, cone, 0)
    bullet.Tracer = 0                     -- disable engine tracer
    bullet.Force  = dmg * 0.5
    bullet.Damage = dmg

    ----------------------------------------------------
    -- CALLBACK: draw tracer from attachment "1"
    ----------------------------------------------------
    bullet.Callback = function(att, tr, dmginfo)
        local startPos = owner:GetShootPos()
		
        local vm = owner:GetViewModel()
        if IsValid(vm) then
            local id = vm:LookupAttachment("1")
            if id > 0 then
                local a = vm:GetAttachment(id)
                if a then
                    startPos = a.Pos
                end
            end
        end

        -- spawn your tracer effect
        local effect = EffectData()
        effect:SetStart(startPos)
        effect:SetOrigin(tr.HitPos)
        effect:SetNormal(tr.HitNormal)
        util.Effect("milkwater_tracer", effect)
    end

    owner:FireBullets(bullet)
end


function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
	
	-- make camera recoil slowly return to 0
	if CLIENT then
		self.RecoilKick = Lerp(FrameTime() * 10, self.RecoilKick or 0, 0)
	end

    -- reset CSGO recoil pattern
    if not owner:KeyDown(IN_ATTACK) then
        self.RecoilStep = 1
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
	
end
