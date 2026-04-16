AddCSLuaFile()

SWEP.Base = "m26_weapon_base"
SWEP.PrintName = "P2000"
SWEP.Category = "TTT2 Weapons"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

-- TTT2 metadata
SWEP.Kind = WEAPON_PISTOL
SWEP.AutoSpawnable = true
SWEP.AllowDrop = true

-- Models
SWEP.HoldType = "pistol"
SWEP.ViewModel = "models/weapons/tacint/v_p2000.mdl"
SWEP.WorldModel = "models/weapons/tacint/w_p2000.mdl"
SWEP.UseHands = true
SWEP.ViewModelFlip = false

-- Primary stats
SWEP.Primary.Sound = Sound( "tacrp/weapons/p2000/p2000_fire-1.wav" )
SWEP.Primary.Damage = 25
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 60 / 400
SWEP.Primary.Cone = 0.012
SWEP.Primary.Recoil = 1.9

SWEP.Primary.ClipSize = 15
SWEP.Primary.DefaultClip = 15
SWEP.Primary.Automatic = true

SWEP.AmmoEnt = "item_ammo_pistol_ttt"
SWEP.Primary.Ammo = "Pistol"

SWEP.HeadshotMultiplier = 2.0

-- animations
SWEP.PrimaryAnim = ACT_VM_PRIMARYATTACK_1
SWEP.ReloadAnim = ACT_VM_RELOAD

-- reload sounds thx to tacrp code
local path = "tacrp/weapons/p2000/p2000_"

local function addsound(name, spath)
    sound.Add({
        name = name,
        channel = 16,
        volume = 1.0,
        sound = spath
    })
end

addsound("tacint_p2000.clip_in", path .. "clip_in.wav")
addsound("tacint_p2000.clip_in-mid", path .. "clip_in-mid.wav")
addsound("tacint_p2000.clip_out", path .. "clip_out.wav")
addsound("tacint_p2000.slide_action", path .. "slide_action.wav")
addsound("tacint_p2000.slide_shut", path .. "slide_shut.wav")
addsound("tacint_p2000.cock_hammer", path .. "cockhammer.wav")