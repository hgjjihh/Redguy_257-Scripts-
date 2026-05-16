--==================================================
-- FootstepModule.lua  [FIXED]
-- Custom footstep sounds + jump sound + fade to idle
-- Taruh file di:
--   Assets/Sounds/footstep.mp3
--   Assets/Sounds/jump.ogg
--==================================================

local FootstepModule = {}

---------------------------------------------------
-- SERVICES
---------------------------------------------------

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")

---------------------------------------------------
-- CONFIG
---------------------------------------------------

local ROOT = "/storage/emulated/0/Delta/Workspace/MyDanceSystem/"

local FOOTSTEP_FILES = {
    ROOT .. "Assets/Sounds/footstep.mp3",
    -- ROOT .. "Assets/Sounds/footstep_2.ogg",
    -- ROOT .. "Assets/Sounds/footstep_3.ogg",
}

local JUMP_FILE = ROOT .. "Assets/Sounds/jump.ogg"

local FOOTSTEP_VOLUME   = 0.5
local JUMP_VOLUME       = 0.6

-- PlaybackSpeed buat ngatur kecepatan langkah (Looped=true)
local FOOTSTEP_SPEED_WALK = 1.0
local FOOTSTEP_SPEED_RUN  = 1.6   -- makin gede = makin cepat saat lari

-- Threshold kecepatan karakter
local WALK_THRESHOLD = 1.5
local RUN_THRESHOLD  = 14

---------------------------------------------------
-- STATE
---------------------------------------------------

local FootstepSounds = {}   -- semua sound instance
local ActiveSound    = nil  -- sound yang lagi diloop sekarang
local JumpSound      = nil
local Active         = false
local Connections    = {}

local wasWalking = false
local wasInAir   = false

local Character, Humanoid, RootPart

---------------------------------------------------
-- LOAD SOUNDS
---------------------------------------------------

local function LoadSound(path, volume, looped)
    if not isfile(path) then
        warn("[Footstep] File not found:", path)
        return nil
    end
    local ok, asset = pcall(getcustomasset, path)
    if not ok or not asset then
        warn("[Footstep] Failed to load:", path)
        return nil
    end
    local s = Instance.new("Sound")
    s.SoundId = asset
    s.Volume  = volume or 0.5
    s.Looped  = looped or false
    s.RollOffMaxDistance = 0
    s.Parent  = workspace
    return s
end

local function LoadAllSounds()
    for _, path in ipairs(FOOTSTEP_FILES) do
        -- Looped = true supaya langkah ngeloop otomatis selama jalan
        local s = LoadSound(path, FOOTSTEP_VOLUME, true)
        if s then table.insert(FootstepSounds, s) end
    end

    JumpSound = LoadSound(JUMP_FILE, JUMP_VOLUME, false)

    if #FootstepSounds > 0 then
        print("[Footstep]", #FootstepSounds, "footstep sound(s) loaded")
    end
    if JumpSound then
        print("[Footstep] Jump sound loaded")
    end
end

---------------------------------------------------
-- FOOTSTEP CONTROL
-- Looped = true, jadi cukup Play() buat looping
-- Stop() buat instant cut
---------------------------------------------------

local rng = Random.new()

local function StartFootstep(isRunning)
    if #FootstepSounds == 0 then return end

    local target = FootstepSounds[rng:NextInteger(1, #FootstepSounds)]
    if not target or not target.Parent then return end

    -- Kalau sound yang sama sudah playing, cukup update speed-nya
    if ActiveSound == target and target.IsPlaying then
        target.PlaybackSpeed = isRunning and FOOTSTEP_SPEED_RUN or FOOTSTEP_SPEED_WALK
        return
    end

    -- Stop sound lama dulu
    if ActiveSound and ActiveSound.IsPlaying then
        ActiveSound:Stop()
    end

    -- Play sound baru dengan looping
    ActiveSound = target
    ActiveSound.PlaybackSpeed = isRunning and FOOTSTEP_SPEED_RUN or FOOTSTEP_SPEED_WALK
    ActiveSound:Play()
end

local function StopFootstep()
    -- Instant stop, tidak ada fade biar snap berhenti
    if ActiveSound and ActiveSound.IsPlaying then
        ActiveSound:Stop()
    end
    ActiveSound = nil
end

local function PlayJump()
    if JumpSound and JumpSound.Parent then
        JumpSound:Stop()
        JumpSound:Play()
    end
end

---------------------------------------------------
-- FADE TO IDLE
-- Dipertahankan utuh — dipanggil saat character diam
---------------------------------------------------

local walkFadeActive = false

local function FadeToIdle()
    if walkFadeActive then return end
    walkFadeActive = true

    local animator = Humanoid and Humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        walkFadeActive = false
        return
    end

    local tracks = animator:GetPlayingAnimationTracks()
    for _, track in ipairs(tracks) do
        pcall(function()
            track:AdjustWeight(0, 0.8)   -- fade animasi ke weight 0 dalam 0.8 detik
        end)
    end

    task.delay(1.0, function()   -- kasih waktu lebih dari durasi fade biar smooth
        walkFadeActive = false
    end)
end

---------------------------------------------------
-- MAIN LOOP
---------------------------------------------------

local function StartLoop()
    local conn = RunService.RenderStepped:Connect(function()
        if not Active then return end
        if not Humanoid or not RootPart then return end
        if Humanoid.Health <= 0 then
            StopFootstep()
            return
        end

        local state   = Humanoid:GetState()
        local vel     = RootPart.AssemblyLinearVelocity
        local moveSpd = Vector3.new(vel.X, 0, vel.Z).Magnitude

        local isWalking = moveSpd > WALK_THRESHOLD
        local isRunning = moveSpd > RUN_THRESHOLD
        local isInAir   = (state == Enum.HumanoidStateType.Jumping
                        or state == Enum.HumanoidStateType.Freefall)

        -- Deteksi takeoff → stop langkah + mainkan jump sound
        if isInAir and not wasInAir then
            StopFootstep()
            PlayJump()
        end

        -- Logika footstep utama
        if isWalking and not isInAir then
            -- Ngeloop selama jalan, update speed kalau switch walk/run
            StartFootstep(isRunning)
            wasWalking = true
        else
            -- Berhenti atau di udara → instant stop
            if wasWalking or isInAir then
                StopFootstep()
                wasWalking = false
            end
        end

        -- Fade to idle: saat benar-benar diam di tanah
        if not isWalking and not isInAir and moveSpd < 0.5 then
            FadeToIdle()
        end

        wasInAir = isInAir
    end)

    table.insert(Connections, conn)
end

---------------------------------------------------
-- BIND CHARACTER
---------------------------------------------------

local function BindCharacter(char)
    StopFootstep()
    wasWalking = false
    wasInAir   = false

    Character = char
    Humanoid  = char:WaitForChild("Humanoid", 10)
    RootPart  = char:WaitForChild("HumanoidRootPart", 10)
end

---------------------------------------------------
-- PUBLIC: INIT
---------------------------------------------------

function FootstepModule:Init(char)
    BindCharacter(char)
    LoadAllSounds()
    StartLoop()
    Active = true

    local respawnConn = Players.LocalPlayer.CharacterAdded:Connect(function(c)
        BindCharacter(c)
    end)
    table.insert(Connections, respawnConn)

    print("[Footstep] System initialized")
end

---------------------------------------------------
-- PUBLIC: SET ACTIVE
---------------------------------------------------

function FootstepModule:SetActive(state)
    Active = state
    if not state then StopFootstep() end
end

---------------------------------------------------
-- PUBLIC: SET VOLUME
---------------------------------------------------

function FootstepModule:SetFootstepVolume(vol)
    FOOTSTEP_VOLUME = vol
    for _, s in ipairs(FootstepSounds) do
        if s and s.Parent then s.Volume = vol end
    end
end

function FootstepModule:SetJumpVolume(vol)
    JUMP_VOLUME = vol
    if JumpSound and JumpSound.Parent then
        JumpSound.Volume = vol
    end
end

---------------------------------------------------
-- PUBLIC: DESTROY
---------------------------------------------------

function FootstepModule:Destroy()
    Active = false
    StopFootstep()

    for _, c in ipairs(Connections) do
        pcall(function() c:Disconnect() end)
    end
    Connections = {}

    for _, s in ipairs(FootstepSounds) do
        pcall(function() s:Stop(); s:Destroy() end)
    end
    FootstepSounds = {}

    if JumpSound then
        pcall(function() JumpSound:Stop(); JumpSound:Destroy() end)
        JumpSound = nil
    end

    print("[Footstep] System destroyed")
end

---------------------------------------------------
-- RETURN
---------------------------------------------------

return FootstepModule
