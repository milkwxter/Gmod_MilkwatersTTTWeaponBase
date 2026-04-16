AddCSLuaFile()

SWEP.Base = "m26_weapon_base"
SWEP.PrintName = "FB Beryl 96"
SWEP.Category = "TTT2 Weapons"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

-- TTT2 metadata
SWEP.Kind = WEAPON_HEAVY
SWEP.AutoSpawnable = true
SWEP.AllowDrop = true

-- Models
SWEP.HoldType = "ar2"
SWEP.ViewModel = "models/weapons/tacint/v_ak47.mdl"
SWEP.WorldModel = "models/weapons/tacint/w_ak47.mdl"
SWEP.UseHands = true
SWEP.ViewModelFlip = false

-- Primary stats
SWEP.Primary.Sound = Sound( "tacrp/weapons/ak47/ak47_fire-1.wav" )
SWEP.Primary.Damage = 22
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 60 / 650
SWEP.Primary.Cone = 0.012
SWEP.Primary.Recoil = 1.1

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
local path = "tacrp/weapons/ak47/ak47_"

local function addsound(name, spath)
    sound.Add({
        name = name,
        channel = 16,
        volume = 1.0,
        sound = spath
    })
end

addsound("tacint_ak47.remove_clip", path .. "remove_clip.wav")
addsound("tacint_ak47.insert_clip", path .. "insert_clip.wav")
addsound("tacint_ak47.boltaction", path .. "boltaction.wav")
addsound("tacint_ak47.Buttstock_Back", path .. "buttstock_back.wav")