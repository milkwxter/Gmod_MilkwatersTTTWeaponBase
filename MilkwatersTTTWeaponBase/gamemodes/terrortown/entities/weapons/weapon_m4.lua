AddCSLuaFile()

SWEP.Base = "milkwaters_weaponbase"
SWEP.PrintName = "M4"
SWEP.Category = "TTT2 Weapons"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

-- TTT2 metadata
SWEP.Kind = WEAPON_PISTOL
SWEP.AutoSpawnable = true
SWEP.AllowDrop = true

-- Models
SWEP.ViewModel = "models/weapons/v_rif_m4a1.mdl"
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"
SWEP.UseHands = true
SWEP.ViewModelFlip = true

-- Primary stats
SWEP.Primary.Sound = Sound( "Weapon_M4A1.Single" )
SWEP.Primary.Damage = 27
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 0.25
SWEP.Primary.Cone = 0.005
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

-- CSGO recoil = 1, EFT recoil = 2
SWEP.CurrentRecoilMode = 2
