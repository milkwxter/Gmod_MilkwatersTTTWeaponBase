AddCSLuaFile()

SWEP.Base = "m26_weapon_base"
SWEP.PrintName = "PGM Hécate II"
SWEP.Category = "TTT2 Weapons"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

-- TTT2 metadata
SWEP.Kind = WEAPON_HEAVY
SWEP.AutoSpawnable = true
SWEP.AllowDrop = true

-- Models
SWEP.HoldType = "ar2"
SWEP.ViewModel = "models/weapons/tacint_extras/v_hecate.mdl"
SWEP.WorldModel = "models/weapons/tacint_extras/w_hecate.mdl"
SWEP.UseHands = true
SWEP.ViewModelFlip = false

-- Primary stats
SWEP.Primary.Sound = Sound( "tacrp_extras/hecate/ax308_fire_1.wav" )
SWEP.Primary.Damage = 125
SWEP.Primary.NumShots = 1
SWEP.Primary.Delay = 60 / 25
SWEP.Primary.Cone = 0.1
SWEP.Primary.Recoil = 7

SWEP.Primary.ClipSize = 7
SWEP.Primary.DefaultClip = 7
SWEP.Primary.Automatic = true

SWEP.AmmoEnt = "item_ammo_357_ttt"
SWEP.Primary.Ammo = "357"

SWEP.HeadshotMultiplier = 2.5
SWEP.Tracer = "milkwater_tracer_sniper"

SWEP.HasScope = true
SWEP.ScopeTexture = "milk/scopes/sniper.png"
SWEP.ScopedConeMultiplier = 0.05
SWEP.ScopeZoom = 12

-- animations
SWEP.PrimaryAnim = ACT_VM_PRIMARYATTACK_1
SWEP.ReloadAnim = ACT_VM_RELOAD

SWEP.AnimationTranslationTable = {
    ["deploy"] = "unholster",
}

-- reload sounds thx to tacrp code
local path = "tacrp_extras/hecate/ax308_"

local function addsound(name, spath)
    sound.Add({
        name = name,
        channel = 16,
        volume = 1.0,
        sound = spath
    })
end

addsound("tacint_extras_hecate.Clip_Out", path .. "magout.wav")
addsound("tacint_extras_hecate.Clip_In", path .. "magin.wav")
addsound("tacint_extras_hecate.Bolt_Back", path .. "boltrelease.wav")
addsound("tacint_extras_hecate.bolt_forward", path .. "boltback.wav")
addsound("tacint_extras_hecate.Bolt_Up", path .. "boltup.wav")
addsound("tacint_extras_hecate.bolt_down", path .. "boltdown.wav")