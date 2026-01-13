EFFECT.Mat = Material("trails/laser")

function EFFECT:Init(data)
    self.StartPos = data:GetStart()
    self.HitPos   = data:GetOrigin()
    self.Normal   = data:GetNormal()

    -- extend the tracer slightly past the hit point
    self.EndPos = self.HitPos + self.Normal * 4

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

