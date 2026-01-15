EFFECT.Mat = Material("trails/laser")

function EFFECT:Init(data)
    self.Position = data:GetStart()
	self.EndPos = data:GetOrigin()
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	self:SetRenderBoundsWS( self.StartPos, self.EndPos )

	self.Dir = ( self.EndPos - self.StartPos ):GetNormalized()
	self.Dist = self.StartPos:Distance( self.EndPos )

    self.LifeTime = 0.05
    self.DieTime  = CurTime() + self.LifeTime
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
    local frac = (self.DieTime - CurTime()) / self.LifeTime
    local width = 3 * frac
	local fade = 100 * frac

    render.SetMaterial(self.Mat)
    render.DrawBeam(
        self.StartPos,
        self.EndPos,
        width,
        0,
        1,
        Color(255, 255, 255, fade)
    )
end

