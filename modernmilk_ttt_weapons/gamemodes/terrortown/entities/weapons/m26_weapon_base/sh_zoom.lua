-- sh_zoom.lua
function SWEP:SecondaryAttack()
	if self.IsReloading then return end
	
	local ironsightsState = self:GetIronsights()
	self:SetIronsights(not ironsightsState)
	self:SetZoom(not ironsightsState)
   
	if CLIENT and not ironsightsState then
		self:EmitSound(self.Secondary.Sound, 75, 100, 1, CHAN_BODY)
	end
end

local function GetPlayerBaseFOV(ply)
    if not IsValid(ply) then return 90 end
	
    return ply:GetInfoNum("fov_desired", 90)
end

function SWEP:SetZoom(state)
    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() then return end

    local baseFOV = GetPlayerBaseFOV(owner)

    if state then
        if self.HasScope then
            local zoom = self.ScopeZoom or 4
            local scopedFOV = baseFOV / zoom
            owner:SetFOV(scopedFOV, 0.25)
        else
            owner:SetFOV(60, 0.3)
        end
    else
        owner:SetFOV(baseFOV, 0.2)
    end
end

if CLIENT then
    local scopeMat = nil

    function SWEP:DrawHUD()
        if not self.HasScope then return end
        if not self:GetIronsights() then return end

        -- lazy load texture
        if not scopeMat then
            scopeMat = Material(self.ScopeTexture)
        end

        local w, h = ScrW(), ScrH()
        local size = math.min(w, h)

        -- center the scope
        local x = (w - size) * 0.5
        local y = (h - size) * 0.5

        -- draw scope texture
        surface.SetMaterial(scopeMat)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(x, y, size, size)
		
		-- black rest of screen
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(0, 0, x, h)
        surface.DrawRect(x + size, 0, x, h)
    end
end