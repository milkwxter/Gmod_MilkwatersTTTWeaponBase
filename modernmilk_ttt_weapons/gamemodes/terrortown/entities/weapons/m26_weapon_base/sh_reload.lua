SWEP.ShellsPerInsert = 3

function SWEP:Reload()
    if self.IsReloading then return end
    if self:Clip1() >= self.Primary.ClipSize then return end
    if self:GetOwner():GetAmmoCount(self.Primary.Ammo) <= 0 then return end

    self:SetIronsights(false)
    self:SetZoom(false)

    if self.ReloadType == "shell" then
        self:StartShellReload()
    else
        self:StartMagazineReload()
    end
end

-- MAGAZINE RELOAD STAYS THE SAME
function SWEP:StartMagazineReload()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    self.IsReloading = true
    self.ReloadStage = 1

    local vm = owner:GetViewModel()
    local seq = vm:SelectWeightedSequence(ACT_VM_RELOAD)
    vm:SendViewModelMatchingSequence(seq)

    owner:DoAnimationEvent(self.ReloadAnim3P)

    local dur = vm:SequenceDuration(seq)
    self.ReloadEndTime = CurTime() + dur
end

function SWEP:ThinkMagazineReload()
    if CurTime() < self.ReloadEndTime then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local ammo = owner:GetAmmoCount(self.Primary.Ammo)
    local need = self.Primary.ClipSize - self:Clip1()
    local toLoad = math.min(need, ammo)

    self:SetClip1(self:Clip1() + toLoad)
    owner:SetAmmo(ammo - toLoad, self.Primary.Ammo)

    self.IsReloading = false
    self.ReloadStage = 0
end

function SWEP:StartShellReload()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    self.IsReloading = true
    self.ReloadStage = 1

    local vm = owner:GetViewModel()
    local seq = vm:SelectWeightedSequence(ACT_SHOTGUN_RELOAD_START)
    vm:SendViewModelMatchingSequence(seq)

    owner:DoAnimationEvent(self.ReloadAnim3P)

    self.ReloadEndTime = CurTime() + vm:SequenceDuration(seq)

    -- reset timing state
    self.InsertCycleStart = nil
    self.InsertCycleDuration = nil
    self.NextShellIndex = 1
end

function SWEP:StartInsertCycle()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    self.ReloadStage = 2
    self.NextShellIndex = 1  -- 1, 2, 3

    local vm = owner:GetViewModel()
    local seq = vm:SelectWeightedSequence(ACT_VM_RELOAD)

    local start = CurTime()
    local dur = vm:SequenceDuration(seq)
	
    vm:SendViewModelMatchingSequence(seq)

    owner:DoAnimationEvent(self.ReloadAnim3P)
	
    self.InsertCycleStart = start
    self.InsertCycleDuration = dur
    self.ReloadEndTime = start + dur
    self.ShellTimes = {
        start + dur * 0.25,
        start + dur * 0.50,
        start + dur * 0.75
    }
end

function SWEP:ThinkShellInsertWindow()
    if self.ReloadStage ~= 2 then return end
    if not self.InsertCycleDuration then return end
	if not self.ShellTimes then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local ammo = owner:GetAmmoCount(self.Primary.Ammo)
    local need = self.Primary.ClipSize - self:Clip1()
    if ammo <= 0 or need <= 0 then return end

    local t = CurTime()
    local checkpoints = self.ShellTimes

    while self.NextShellIndex <= self.ShellsPerInsert
      and t >= checkpoints[self.NextShellIndex] do

        self:SetClip1(self:Clip1() + 1)
        owner:SetAmmo(ammo - 1, self.Primary.Ammo)

        self.NextShellIndex = self.NextShellIndex + 1
        ammo = owner:GetAmmoCount(self.Primary.Ammo)
        need = self.Primary.ClipSize - self:Clip1()

        if ammo <= 0 or need <= 0 then
            self:FinishShellReload()
            return
        end
    end
end


function SWEP:ThinkShellReload()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    if not self.IsReloading then return end

    -- cancel if player fires
    if owner:KeyDown(IN_ATTACK) then
        self:FinishShellReload()
        return
    end

    -- inside insert animation
    if CurTime() < self.ReloadEndTime then
        self:ThinkShellInsertWindow()
        return
    end

    -- animation finished
    local ammo = owner:GetAmmoCount(self.Primary.Ammo)
    local need = self.Primary.ClipSize - self:Clip1()

    if need <= 0 or ammo <= 0 then
        self:FinishShellReload()
        return
    end

    if self.ReloadStage == 1 then
        self:StartInsertCycle()
        return
    end

    if self.ReloadStage == 2 then
        self:StartInsertCycle()
        return
    end
end


function SWEP:FinishShellReload()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local vm = owner:GetViewModel()
    local seq = vm:SelectWeightedSequence(ACT_SHOTGUN_RELOAD_FINISH)
    vm:SendViewModelMatchingSequence(seq)

    self.ReloadEndTime = CurTime() + vm:SequenceDuration(seq)

    self.IsReloading = false
    self.ReloadStage = 0
end
