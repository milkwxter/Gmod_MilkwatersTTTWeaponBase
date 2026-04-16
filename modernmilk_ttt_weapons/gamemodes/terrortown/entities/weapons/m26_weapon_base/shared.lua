AddCSLuaFile()
AddCSLuaFile("cl_crosshair.lua")
AddCSLuaFile("sh_recoil.lua")
AddCSLuaFile("sh_reload.lua")
AddCSLuaFile("sh_zoom.lua")
AddCSLuaFile("sh_animations.lua")

-- give clients certain files
if CLIENT then
	include("cl_crosshair.lua")
end

-- shared files
include("sh_recoil.lua")
include("sh_reload.lua")
include("sh_zoom.lua")
include("sh_animations.lua")

-- particles
game.AddParticles( "particles/devtest.pcf" )

SWEP.Kind = WEAPON_NONE
SWEP.CanBuy = nil

if CLIENT then
   SWEP.EquipMenuData = nil
   
   SWEP.Icon = "vgui/ttt/icon_nades"
   
   SWEP.DrawCrosshair = false
   SWEP.ViewModelFOV = 72
   SWEP.ViewModelFlip = false
   SWEP.CSMuzzleFlashes = false
end

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "Ironsights")
end

SWEP.AutoSpawnable = false
SWEP.AllowDrop = true
SWEP.IsSilent = false

SWEP.Base = "weapon_base"
SWEP.MilkBase = true

SWEP.Category = "TTT"
SWEP.Spawnable = true

SWEP.IsGrenade = false

SWEP.Weight = 5

SWEP.Primary.Sound          = Sound( "Weapon_Pistol.Empty" )
SWEP.Primary.Recoil         = 2
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
SWEP.Primary.NumShots		= 1

SWEP.Secondary.Sound		= Sound( "milkwater_common/shoulder_weapon.wav" )
SWEP.Secondary.ClipSize     = 1
SWEP.Secondary.DefaultClip  = 1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"
SWEP.Secondary.ClipMax      = -1

SWEP.HeadshotMultiplier = 2
SWEP.IsSilent = false
SWEP.Tracer = "milkwater_tracer"

SWEP.HasScope = false
SWEP.ScopeTexture = "scope/gdcw_scopesight"
SWEP.ScopedConeMultiplier = 1.0

-- animations
SWEP.DrawAnim = ACT_VM_DRAW
SWEP.PrimaryAnim = ACT_VM_PRIMARYATTACK_4
SWEP.ReloadAnim = ACT_VM_RELOAD
SWEP.ReloadAnim3P = ACT_HL2MP_GESTURE_RELOAD_AR2
SWEP.ViewmodelDownAmount = 0.0

SWEP.fingerprints = {}

-- bloom
SWEP.Bloom = 0
SWEP.BloomIncrease = 0.004
SWEP.BloomDecay = 10
SWEP.BloomMultiplier = 2.5

-- recoil defaults
SWEP.RecoilPitch     = 0
SWEP.RecoilYaw       = 0
SWEP.RecoilRise      = 0
SWEP.RecoilRiseRate  = 0.22

-- recoil advanced stuff
SWEP.RecoilTargetPitch = 0
SWEP.RecoilTargetYaw   = 0
SWEP.RecoilCurPitch = 0
SWEP.RecoilCurYaw   = 0
SWEP.RecoilSpeed = 12
SWEP.RecoilDamping = 3
SWEP.RecoilLastPitch = 0
SWEP.RecoilLastYaw = 0

-- reload types "magazine" or "shell"
SWEP.ReloadType = "magazine"

-- shared reload state
SWEP.IsReloading = false
SWEP.ReloadStage = 0
SWEP.ReloadEndTime = 0

-- shell reload specific
SWEP.ShellInsertTime = 0
SWEP.ShellFinishTime = 0

function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
	PrecacheParticleSystem( "weapon_muzzle_flash_assaultrifle" )
end

-- are we allowed to attack
function SWEP:CanPrimaryAttack()
	-- check if owner exists
    local owner = self:GetOwner()
    if not IsValid(owner) then return false end
	
    -- no ammo
    if self:Clip1() <= 0 then
		return false 
	end
	
	if self.IsReloading then
		return false 
	end

    return true
end

function SWEP:PrimaryAttack()
    if not self:CanPrimaryAttack() then return end
	
	-- check if owner exists
    local owner = self:GetOwner()
    if not IsValid(owner) then return false end

    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    self:EmitSound(
		self.Primary.Sound,
		100,
		math.random(98,102),
		1,
		CHAN_WEAPON
	)

    self:ShootBullet(
        self.Primary.Damage,
        self.Primary.NumShots,
		self:GetCurrentCone()
    )

    self:TakePrimaryAmmo(1)
	
	-- add bloom
	self.Bloom = math.min(self.Bloom + self.BloomIncrease, self:GetBloomMax())
	
	-- shake impulse
    self.ShakeTarget = self.Primary.Recoil * self.ShakePower
    self.ShakeFrac = 1

    if math.Rand(0, 1) > 0.7 then
        self.ShakeFlipTarget = -self.ShakeFlipTarget
    end
	
	-- do recoil and muzzlestuff
	if CLIENT and IsFirstTimePredicted() then
		self:DoRecoil()
		self:DoMuzzleFlash()
		self:DoProjectedMuzzleFlash()
	end

	-- animations
    self:SendWeaponAnim(self.PrimaryAnim)
	owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:ShootBullet(dmg, numbul, cone)
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
	
	if CLIENT and not IsFirstTimePredicted() then return end
	
	-- check if we should have a tracer
	local silentGun = self.IsSilent

    -- normal bullet
    local bullet = {}
    bullet.Num = numbul
    bullet.Src = owner:GetShootPos()
    bullet.Dir = owner:EyeAngles():Forward()
    bullet.Spread = Vector(cone, cone, 0)
    bullet.Tracer = silentGun and 0 or 1
	bullet.TracerName = self.Tracer
    bullet.Force  = dmg
    bullet.Damage = dmg
	bullet.Attacker = self:GetOwner()
	bullet.Inflictor = self

    owner:FireBullets(bullet, true)
end

function SWEP:GetHeadshotMultiplier(victim, dmginfo)
	return self.HeadshotMultiplier
end

function SWEP:Deploy()
    local owner = self:GetOwner()
    local dur = 0

    if IsValid(owner) then
        local vm = owner:GetViewModel()
        if IsValid(vm) then
            local seq = self:ResolveAnimation("deploy")

            if seq and seq >= 0 then
                vm:SendViewModelMatchingSequence(seq)

                local rate = vm:GetPlaybackRate()
                if not rate or rate <= 0 then rate = 1 end

                dur = vm:SequenceDuration(seq) / rate
            else
                vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(ACT_VM_DRAW))
                dur = vm:SequenceDuration()
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
	
	-- actually holster
	return true
end

function SWEP:Think()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	
	local dt = FrameTime()
	
	local isFiring = owner:KeyDown(IN_ATTACK) and self:CanPrimaryAttack()

	-- bloom recovery
	if not isFiring then
		local decay = self.BloomDecay or 10

		-- exponential decay
		self.Bloom = self.Bloom * math.exp(-decay * dt)

		if self.Bloom < 0.01 then
			self.Bloom = 0
		end
	end
	
	-- recoil thinking
	self:ThinkRecoil()
	
	-- reload thinking
    if self.IsReloading then
        if self.ReloadType == "shell" then
            self:ThinkShellReload()
        else
            self:ThinkMagazineReload()
        end
    end
end

if CLIENT then
    function SWEP:CalcView(ply, pos, ang, fov)
        if not IsValid(ply) then return pos, ang, fov end

        local dt = FrameTime()

        -- decay shake
        self.ShakeFrac = self.ShakeFrac or 0
        self.ShakeDecay = self.ShakeDecay or 6
        self.ShakeFlip = self.ShakeFlip or 1
        self.ShakeFlipTarget = self.ShakeFlipTarget or 1
        self.ShakeRollMult = self.ShakeRollMult or 0.6
        self.ShakePitchMult = self.ShakePitchMult or 0.4

        self.ShakeFrac = self.ShakeFrac * math.exp(-self.ShakeDecay * dt)
        if self.ShakeFrac < 0.001 then
            self.ShakeFrac = 0
        end

        self.ShakeFlip = Lerp(dt * 10, self.ShakeFlip, self.ShakeFlipTarget)

        local f = math.ease.InElastic(math.ease.InQuad(self.ShakeFrac))

        local roll  = f * (self.ShakeTarget or 0) * self.ShakeFlip * self.ShakeRollMult
        local pitch = f * (self.ShakeTarget or 0) * self.ShakePitchMult

        -- apply visual offset
        ang = ang + Angle(pitch, 0, roll)

        return pos, ang, fov
    end
end

if CLIENT then
    function SWEP:DoMuzzleFlash()
        local vm = self:GetOwner():GetViewModel()
        if not IsValid(vm) then return end
		
        local att = vm:LookupAttachment("muzzle") 
        if att <= 0 then att = 1 end
		
        local particle = "weapon_muzzle_flash_assaultrifle"

        ParticleEffectAttach(
            particle,
            PATTACH_POINT_FOLLOW,
            vm,
            att
        )
    end
end

if CLIENT then
    hook.Add("CalcViewModelView", "MW_" .. tostring(SWEP.ClassName), function(weapon, vm, oldPos, oldAng, pos, ang)
        if weapon ~= LocalPlayer():GetActiveWeapon() then return end
        if not IsValid(weapon) then return end
		if not weapon.MilkBase then return end
		
        weapon._adsLerp = Lerp(FrameTime() * 7, weapon._adsLerp or 0, weapon:GetIronsights() and 1 or 0)

        local t = weapon._adsLerp
		
        if weapon.HasScope then
            if t > 0 then
                local offset = Vector(0, 0, -6)
                pos = pos + ang:Forward() * offset.x * t
                pos = pos + ang:Right() * offset.y * t
                pos = pos + ang:Up() * offset.z * t
            end
        else
            if t > 0 then
                local offset = Vector(-2, -2, 0)
                pos = pos + ang:Forward() * offset.x * t
                pos = pos + ang:Right() * offset.y * t
                pos = pos + ang:Up() * offset.z * t

                ang:RotateAroundAxis(ang:Right(), 2 * t)
                ang:RotateAroundAxis(ang:Up(), 1.5 * t)
                ang:RotateAroundAxis(ang:Forward(), -5 * t)
            end
        end

        -- global stuff
        pos = pos + ang:Up() * -5
		pos = pos + ang:Up() * weapon.ViewmodelDownAmount
        pos = pos + ang:Right() * 1.8

        return pos, ang
    end)
end

if CLIENT then

	local FLASH_LIFETIME = 0.04
	local FLASH_FOV      = 100
	local FLASH_DIST     = 600

	function SWEP:DoProjectedMuzzleFlash()
		local owner = self:GetOwner()
		if not IsValid(owner) then return end

		local vm = owner:GetViewModel()
		if not IsValid(vm) then return end

		local att = vm:LookupAttachment("muzzle")
		if att <= 0 then att = 1 end

		local attData = vm:GetAttachment(att)
		if not attData then return end
		
		local proj = ProjectedTexture()
		if not IsValid(proj) then return end
		
		local eyeAng = owner:EyeAngles()

		proj:SetTexture("tacrp/muzzleflash_light")
		proj:SetFOV(FLASH_FOV)
		proj:SetFarZ(FLASH_DIST)
		proj:SetBrightness(2.5)
		proj:SetAngles(eyeAng + Angle(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(0, 360)))
		proj:SetEnableShadows(false)
		proj:SetPos(attData.Pos)

		proj:Update()
		
		timer.Simple(FLASH_LIFETIME, function()
			if IsValid(proj) then
				proj:Remove()
			end
		end)
	end

end