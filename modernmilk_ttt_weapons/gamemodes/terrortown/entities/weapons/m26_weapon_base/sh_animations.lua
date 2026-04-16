-- sh_animations.lua

SWEP.AnimationTranslationTable = {
    ["deploy"] = "deploy",
}

function SWEP:ResolveAnimation(event)
    local tbl = self.AnimationTranslationTable
    if not tbl then return nil end

    local seqName = tbl[event]
    if not seqName then return nil end

    local owner = self:GetOwner()
    if not IsValid(owner) then return nil end

    local vm = owner:GetViewModel()
    if not IsValid(vm) then return nil end
	
    local seq = vm:LookupSequence(seqName)
    if seq and seq > 0 then
        return seq
    end

    return nil
end
