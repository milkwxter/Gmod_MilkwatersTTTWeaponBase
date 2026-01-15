AddCSLuaFile()

SWEP.Base = "milkwaters_weaponbase"
SWEP.PrintName = "AK"
SWEP.Category = "TTT2 Weapons"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

-- TTT2 metadata
SWEP.Kind = WEAPON_PISTOL
SWEP.AutoSpawnable = true
SWEP.AllowDrop = true

-- Models
SWEP.ViewModel = "models/weapons/cstrike/c_rif_ak47.mdl"
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"
SWEP.UseHands = true
SWEP.ViewModelFlip = false

-- Primary stats
SWEP.Primary.Sound = Sound( "Weapon_AK47.Single" )
SWEP.Primary.Damage = 22
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.15
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
    {p = 5.00, y =  2.00},
    {p = 6.00, y =  2.40},
    {p = 7.00, y =  2.80},
    {p = 8.00, y =  3.20},
    {p = 9.00, y =  3.60},
    {p = 10.00, y =  4.00},
    {p = 10.40, y =  4.40},
    {p = 10.80, y =  4.80},
    {p = 10.60, y =  4.20},
    {p = 10.20, y =  3.40},
    {p = 9.60,  y =  2.40},
    {p = 9.00,  y =  0.80},
    {p = 8.40,  y = -0.80},
    {p = 7.80,  y = -2.40},
    {p = 7.20,  y = -3.20},
    {p = 6.80,  y = -2.40},
    {p = 6.40,  y = -1.20},
    {p = 6.00,  y =  0.40},
    {p = 5.60,  y =  1.60},
    {p = 5.20,  y =  0.80},
}