hook.Add("RenderScreenspaceEffects", "Milk_ChromaticAberration", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or not wep.ChromaStrength then return end

    local strength = wep.ChromaStrength
    if strength <= 0.01 then return end

    -- fake chromatic aberration by shifting color channels
    DrawColorModify({
        ["$pp_colour_addr"] = strength * 0.02,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = -strength * 0.02,
        ["$pp_colour_brightness"] = 0,
        ["$pp_colour_contrast"] = 1,
        ["$pp_colour_colour"] = 1 - (strength * 0.5),
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    })
	
	DrawSharpen( strength * 0.5, 1.2 )
end)