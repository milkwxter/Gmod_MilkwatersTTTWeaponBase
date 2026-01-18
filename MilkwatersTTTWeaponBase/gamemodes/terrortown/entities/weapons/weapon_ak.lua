AddCSLuaFile()

SWEP.Base = "milkwaters_weaponbase"
SWEP.PrintName = "AK47"
SWEP.Category = "TTT2 Weapons"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

-- TTT2 metadata
SWEP.Kind = WEAPON_HEAVY
SWEP.AutoSpawnable = true
SWEP.AllowDrop = true

-- Models
SWEP.HoldType = "ar2"
SWEP.ViewModel = "models/weapons/v_rif_ak47.mdl"
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"
SWEP.UseHands = true
SWEP.ViewModelFlip = true

-- Primary stats
SWEP.Primary.Sound = Sound( "Weapon_AK47.Single" )
SWEP.Primary.Damage = 22
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.1
SWEP.Primary.Cone = 0.018
SWEP.Primary.Recoil = 2

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true

SWEP.AmmoEnt = "item_ammo_smg1_ttt"
SWEP.Primary.Ammo = "SMG1"

SWEP.HeadshotMultiplier = 2.5

-- animations
SWEP.PrimaryAnim = ACT_VM_PRIMARYATTACK
SWEP.ReloadAnim = ACT_VM_RELOAD

SWEP.RecoilPattern = {
    {p = 0.0,    y = 0.0},
    {p = 2.1,    y = 1.05},
    {p = 5.55,   y = -1.05},
    {p = 8.7,    y = 0.45},
    {p = 9.15,   y = 0.18},
    {p = 9.75,   y = -3.75},
    {p = 8.25,   y = -2.4},
    {p = 5.85,   y = -3.9},
    {p = 4.35,   y = 4.95},
    {p = -1.2,   y = 12.6},
    {p = 0.75,   y = 6.6},
    {p = 3.3,    y = -3.9},
    {p = 1.8,    y = 4.65},
    {p = -2.55,  y = 7.8},
    {p = 1.5,    y = 0.9},
    {p = 0.45,   y = -12.0},
    {p = 2.1,    y = -5.25},
    {p = 3.15,   y = -4.65},
    {p = -0.45,  y = -8.1},
    {p = -2.7,   y = -9.9},
    {p = -0.75,  y = 6.15},
    {p = 0.9,    y = -1.8},
    {p = 2.85,   y = 1.8},
    {p = 1.05,   y = 2.7},
    {p = -0.9,   y = -5.7},
    {p = 1.5,    y = -1.95},
    {p = -0.15,  y = 6.3},
    {p = -0.9,   y = 13.65},
    {p = -6.3,   y = 4.2},
    {p = 0.0,    y = 0.0},
}
