AddCSLuaFile()

SWEP.Base = "milkwaters_weaponbase"
SWEP.PrintName = "M4A1"
SWEP.Category = "TTT2 Weapons"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

-- TTT2 metadata
SWEP.Kind = WEAPON_HEAVY
SWEP.AutoSpawnable = true
SWEP.AllowDrop = true

-- Models
SWEP.HoldType = "ar2"
SWEP.ViewModel = "models/weapons/v_rif_m4a1.mdl"
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"
SWEP.UseHands = true
SWEP.ViewModelFlip = true

-- Primary stats
SWEP.Primary.Sound = Sound( "Weapon_M4A1.Single" )
SWEP.Primary.Damage = 27
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.09
SWEP.Primary.Cone = 0.01
SWEP.Primary.Recoil = 3

SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic = true

SWEP.AmmoEnt = "item_ammo_smg1_ttt"
SWEP.Primary.Ammo = "SMG1"

SWEP.HeadshotMultiplier = 2.5

-- animations
SWEP.PrimaryAnim = ACT_VM_PRIMARYATTACK
SWEP.ReloadAnim = ACT_VM_RELOAD

SWEP.RecoilPattern = {
    {p = 0.0,    y = 0.0},
    {p = 2.1,    y = -0.45},
    {p = 3.0,    y = 0.15},
    {p = 4.2,    y = 1.2},
    {p = 5.4,    y = -0.9},
    {p = 6.0,    y = 1.8},
    {p = 6.6,    y = 1.2},
    {p = 4.8,    y = -3.6},
    {p = 3.3,    y = -2.7},
    {p = 1.8,    y = -5.1},
    {p = 2.7,    y = 0.9},
    {p = 1.5,    y = 3.9},
    {p = -0.6,   y = 6.9},
    {p = -0.3,   y = 5.1},
    {p = -1.2,   y = 5.4},
    {p = 0.9,    y = -0.3},
    {p = 1.2,    y = -1.8},
    {p = 0.3,    y = 2.4},
    {p = -0.6,   y = 3.3},
    {p = 0.0,    y = 0.0},
}

