local CROSSHAIR = {}
CROSSHAIR.Enabled = true

local function ConeToPixels(cone)
    local fov = LocalPlayer():GetFOV()
    local screenDist = ScrH() / (2 * math.tan(math.rad(fov * 0.5)))
    return math.tan(cone) * screenDist
end

local function DrawFilledCircle(x, y, r, col)
    local poly = {}
    local segments = 32

    poly[#poly + 1] = { x = x, y = y }

    for i = 0, segments do
        local a = math.rad((i / segments) * 360)
        poly[#poly + 1] = {
            x = x + math.cos(a) * r,
            y = y + math.sin(a) * r
        }
    end

    surface.SetDrawColor(col)
    draw.NoTexture()
    surface.DrawPoly(poly)
end

hook.Add("HUDPaint", "MW_DrawCrosshair", function()
    if not CROSSHAIR.Enabled then return end

    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return end
    if not wep.MilkBase then return end

    local cx = ScrW() * 0.5
    local cy = ScrH() * 0.5

    local bloom = wep.Bloom or 0
    local cone  = wep.GetCurrentCone and wep:GetCurrentCone() or 0

    local totalCone = cone + bloom
	local radius = ConeToPixels(totalCone)

    local roleCol = ply.GetRoleColor and ply:GetRoleColor() or Color(255, 255, 255)

    local fillCol = Color(roleCol.r, roleCol.g, roleCol.b, 40)   -- transparent fill
    local outCol  = Color(roleCol.r, roleCol.g, roleCol.b, 255)  -- solid outline

    -- filled circle
    DrawFilledCircle(cx, cy, radius, fillCol)

    -- outline ring
    surface.SetDrawColor(outCol)
    surface.DrawCircle(cx, cy, radius, outCol)
end)

