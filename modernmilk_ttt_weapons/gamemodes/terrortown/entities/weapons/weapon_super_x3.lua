AddCSLuaFile()

SWEP.Base = "m26_weapon_base"
SWEP.PrintName = "Winchester Super X3"
SWEP.Category = "TTT2 Weapons"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

-- TTT2 metadata
SWEP.Kind = WEAPON_HEAVY
SWEP.AutoSpawnable = true
SWEP.AllowDrop = true

-- Models
SWEP.HoldType = "shotgun"
SWEP.ViewModel = "models/weapons/tacint_shark/v_superx3.mdl"
SWEP.WorldModel = "models/weapons/tacint_shark/w_superx3.mdl"
SWEP.UseHands = true
SWEP.ViewModelFlip = false

-- Primary stats
SWEP.Primary.Sound = Sound( "tacrp/weapons/m4star10/fire-2.wav" )
SWEP.Primary.Damage = 11
SWEP.Primary.NumShots = 8
SWEP.Primary.Delay = 60 / 200
SWEP.Primary.Cone = 0.06
SWEP.Primary.Recoil = 6.2

SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic = true

SWEP.AmmoEnt = "item_box_buckshot_ttt"
SWEP.Primary.Ammo = "Buckshot"

SWEP.HeadshotMultiplier = 2.5

-- animations
SWEP.PrimaryAnim = ACT_VM_PRIMARYATTACK_1
SWEP.ReloadAnim = ACT_VM_RELOAD
SWEP.ViewmodelDownAmount = -1.5

-- reload type
SWEP.ReloadType = "shell"
SWEP.ShellInsertTimes = { 0.25, 0.55, 0.82 }

-- reload sounds thx to tacrp code
local path = "tacrp/weapons/m4star10/"

local function addsound(name, spath)
    sound.Add({
        name = name,
        channel = 16,
        volume = 1.0,
        sound = spath
    })
end

addsound("tacint_auto5.Insertshell",
    {
        "tacint_shark/weapons/auto5/shotgun_semiauto_reload1.wav",
        "tacint_shark/weapons/auto5/shotgun_semiauto_reload2.wav",
        "tacint_shark/weapons/auto5/shotgun_semiauto_reload3.wav",
        "tacint_shark/weapons/auto5/shotgun_semiauto_reload4.wav",
        "tacint_shark/weapons/auto5/shotgun_semiauto_reload5.wav",
    }
)
addsound("tacint_Bekas.Movement", "tacrp/weapons/bekas/movement-1.wav")
addsound("tacint_auto5.Bolt_Back", "tacint_shark/weapons/auto5/shotgun_semiauto_slide1.wav")
addsound("tacint_auto5.Bolt_release", "tacint_shark/weapons/auto5/shotgun_semiauto_slide2.wav")
addsound("tacint_m4.throw_catch", "tacrp/weapons/m4/m4_throw_catch.wav")