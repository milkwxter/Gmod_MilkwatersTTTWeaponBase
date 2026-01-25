AddCSLuaFile()

SWEP.Base = "milkwaters_weaponbase"
SWEP.PrintName = "Ithica 37"
SWEP.Category = "TTT2 Weapons"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

-- TTT2 metadata
SWEP.Kind = WEAPON_HEAVY
SWEP.AutoSpawnable = true
SWEP.AllowDrop = true

-- Models
SWEP.HoldType = "shotgun"
SWEP.ViewModel = "models/weapons/chands_ithaca_m37shot.mdl"
SWEP.WorldModel = "models/weapons/w_ithaca_m37.mdl"
SWEP.UseHands = true
SWEP.ViewModelFlip = true

-- Primary stats
SWEP.Primary.Sound = Sound( "weapons/m37/m3-1.wav" )
SWEP.Primary.Damage = 11
SWEP.Primary.NumShots = 9
SWEP.Primary.Delay = 0.9
SWEP.Primary.Cone = 0.06
SWEP.Primary.Recoil = 16

SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = true

SWEP.AmmoEnt = "item_box_buckshot_ttt"
SWEP.Primary.Ammo = "Buckshot"

SWEP.HeadshotMultiplier = 2.0

SWEP.ShotgunReload = true

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
