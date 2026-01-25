AddCSLuaFile()

SWEP.Base = "milkwaters_weaponbase"
SWEP.PrintName = "M1911"
SWEP.Category = "TTT2 Weapons"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

-- TTT2 metadata
SWEP.Kind = WEAPON_PISTOL
SWEP.AutoSpawnable = true
SWEP.AllowDrop = true

-- Models
SWEP.HoldType = "pistol"
SWEP.ViewModel = "models/weapons/chands_dmgf_co1911.mdl"
SWEP.WorldModel = "models/weapons/s_dmgf_co1911.mdl"
SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 100

-- Primary stats
SWEP.Primary.Sound = Sound( "weapons/dmg_colt1911/deagle-1.wav" )
SWEP.Primary.Damage = 34
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.2
SWEP.Primary.Cone = 0.02
SWEP.Primary.Recoil = 7

SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = true

SWEP.AmmoEnt = "item_ammo_pistol_ttt"
SWEP.Primary.Ammo = "Pistol"

SWEP.HeadshotMultiplier = 2.0

SWEP.ShotgunReload = false

-- animations
SWEP.PrimaryAnim = ACT_VM_PRIMARYATTACK
SWEP.ReloadAnim = ACT_VM_RELOAD

SWEP.RecoilPattern = {
    {p = 6.0, y = -1.2},
    {p = 5.2, y = -1.0},
    {p = 4.6, y = -0.8},
    {p = 4.0, y = -0.6},
    {p = 3.6, y = -0.4},
    {p = 3.2, y = -0.2},
    {p = 2.8, y =  0.0},
    {p = 2.4, y =  0.2},
}
