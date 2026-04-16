AddCSLuaFile()

SWEP.Base = "m26_weapon_base"
SWEP.PrintName = "Ingram MAC-11"
SWEP.Category = "TTT2 Weapons"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

-- TTT2 metadata
SWEP.Kind = WEAPON_HEAVY
SWEP.AutoSpawnable = true
SWEP.AllowDrop = true

-- Models
SWEP.HoldType = "ar2"
SWEP.ViewModel = "models/weapons/tacint_extras/v_mac10.mdl"
SWEP.WorldModel = "models/weapons/tacint_extras/w_mac10.mdl"
SWEP.UseHands = true
SWEP.ViewModelFlip = false

-- Primary stats
SWEP.Primary.Sound = Sound( "tacrp_extras/mac10/mac10-1.wav" )
SWEP.Primary.Damage = 15
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 60 / 1000
SWEP.Primary.Cone = 0.019
SWEP.Primary.Recoil = 3

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true

SWEP.AmmoEnt = "item_ammo_smg1_ttt"
SWEP.Primary.Ammo = "SMG1"

SWEP.HeadshotMultiplier = 2.5

-- animations
SWEP.PrimaryAnim = ACT_VM_PRIMARYATTACK_1
SWEP.ReloadAnim = ACT_VM_RELOAD

-- reload sounds thx to tacrp code
local path = "tacrp_extras/mac10/"

local function addsound(name, spath)
    sound.Add({
        name = name,
        channel = 16,
        volume = 1.0,
        sound = spath
    })
end

addsound("tacint_extras_mac10.clip_in", path .. "mac10_clipin.wav")
addsound("tacint_extras_mac10.clip_out", path .. "mac10_clipout.wav")
addsound("tacint_extras_mac10.slide_back", path .. "mac10_boltpull.wav")
addsound("tacint_extras_mac10.slide_forward", path .. "mac10_boltpull2.wav")
addsound("tacint_extras_mac10.slide_shut", path .. "mac10_boltpull2.wav")