--==================================================
-- ModuleEngine.lua
-- Gabungan: ModuleLoader + CoreScriptLoader + BHOPDance
-- Usage di Main.lua:
--   local ModuleEngine = loadfile(ROOT.."Modules/ModuleEngine.lua")()
--   local Loader = ModuleEngine.Loader
--   local Core   = ModuleEngine.Core
--==================================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")

local ROOT   = "/storage/emulated/0/Delta/Workspace/MyDanceSystem/"
local ASSETS = ROOT .. "Assets/"

--==================================================
-- MODULE LOADER (registry framework)
--==================================================

local Loader = {}

Loader.Registry = {
    DANCE    = {},
    STYLESET = {},
    EFFECT   = {},
    ABILITY  = {},
    UNKNOWN  = {},
}

Loader.LoadedModules  = {}
Loader.Notifications  = {}

function Loader:Notify(text, success)
    table.insert(self.Notifications, {
        Text    = text,
        Success = success,
    })
    if success then
        print("[MODULE]", text)
    else
        warn("[MODULE]", text)
    end
end

function Loader:Register(module)
    if not module then
        self:Notify("Module nil", false)
        return
    end

    local Name = module.Name or "Unknown"
    local Type = module.ModuleType

    if not Type then
        table.insert(self.Registry.UNKNOWN, module)
        self:Notify("Unknown type: " .. Name, false)
        return
    end

    if not self.Registry[Type] then
        self.Registry[Type] = {}
    end

    table.insert(self.Registry[Type], module)
    table.insert(self.LoadedModules, module)
    self:Notify("Loaded " .. Type .. ": " .. Name, true)
end

function Loader:LoadFile(path)
    if not isfile(path) then
        self:Notify("Missing file: " .. path, false)
        return nil
    end
    local ok, module = pcall(function()
        return loadfile(path)()
    end)
    if not ok then
        self:Notify("Error loading: " .. path, false)
        warn(module)
        return nil
    end
    self:Register(module)
    return module
end

function Loader:LoadFolder(folder, files)
    for _, file in ipairs(files) do
        self:LoadFile(folder .. file)
    end
end

function Loader:GetModules(Type)
    return self.Registry[Type] or {}
end

function Loader:HasType(Type)
    return self.Registry[Type] ~= nil
end

function Loader:GetNotifications()
    return self.Notifications
end

function Loader:ClearNotifications()
    table.clear(self.Notifications)
end

--==================================================
-- LOAD Animator6D
--==================================================

if not getgenv().Animator6DLoadedPro then
    loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/gObl00x/Stuff/refs/heads/main/Animator6D.lua"
    ))()
    repeat task.wait() until getgenv().Animator6DLoadedPro
end

--==================================================
-- CORE (animation engine)
--==================================================

local Player    = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid  = Character:WaitForChild("Humanoid")

local Core = {}

Core.CurrentStyle  = nil
Core.CurrentDance  = nil
Core.CurrentAnim   = nil
Core.DancePlaying  = false
Core.IdleAnim      = nil
Core.WalkAnim      = nil

-- Expose Loader ke Core juga supaya CoreScriptLoader bisa load styleset/dance
Core.Loader = Loader

---------------------------------------------------
-- LOAD RBXM
---------------------------------------------------

function Core:LoadRBXM(path)
    if not isfile(path) then
        warn("Missing:", path)
        return nil
    end
    local ok, model = pcall(function()
        return game:GetObjects(getcustomasset(path))[1]
    end)
    if not ok or not model then
        warn("Failed:", path)
        return nil
    end
    local anim = nil
    local function Scan(obj)
        if obj:IsA("KeyframeSequence") then anim = obj end
        for _, v in ipairs(obj:GetChildren()) do Scan(v) end
    end
    Scan(model)
    return anim
end

---------------------------------------------------
-- PLAY ANIMATION
---------------------------------------------------

function Core:Play(anim)
    if not anim then return end
    if self.CurrentAnim == anim then return end
    self.CurrentAnim = anim
    pcall(function()
        getgenv().Animator6D(anim, 1, true)
    end)
end

---------------------------------------------------
-- RESET MOTORS
---------------------------------------------------

function Core:ResetMotors()
    for _, v in ipairs(Character:GetDescendants()) do
        if v:IsA("Motor6D") then
            v.Transform    = CFrame.new()
            v.CurrentAngle = 0
        end
    end
end

---------------------------------------------------
-- EQUIP STYLE  (alias + original)
---------------------------------------------------

function Core:EquipStyle(module)
    return self:EquipStyleSet(module)
end

function Core:EquipStyleSet(module)
    if not module then return end
    self.CurrentStyle = module

    -- Only load if Idle/Walk path is defined and non-empty
    local idleFile = module.Idle or ""
    local walkFile = module.Walk or ""

    if idleFile ~= "" then
        self.IdleAnim = self:LoadRBXM(ASSETS .. "Anims/" .. idleFile)
    else
        self.IdleAnim = nil
    end

    if walkFile ~= "" then
        self.WalkAnim = self:LoadRBXM(ASSETS .. "Anims/" .. walkFile)
    else
        self.WalkAnim = nil
    end

    if module.OnEquip then
        pcall(function() module.OnEquip(Character) end)
    end

    self.CurrentAnim = nil
end

---------------------------------------------------
-- PLAY DANCE
---------------------------------------------------

function Core:PlayDance(module)
    if not module then return end
    self:StopDance()
    self.CurrentDance = module
    self.DancePlaying = true
    if module.Init then
        pcall(function() module.Init(Character) end)
    end
end

---------------------------------------------------
-- STOP DANCE
---------------------------------------------------

function Core:StopDance()
    if self.CurrentDance and self.CurrentDance.Destroy then
        pcall(function() self.CurrentDance.Destroy(Character) end)
    end
    self.CurrentDance = nil
    self.DancePlaying = false
    self.CurrentAnim  = nil
    self:ResetMotors()
end

---------------------------------------------------
-- RENDER LOOP
---------------------------------------------------

RunService.RenderStepped:Connect(function(dt)
    if Core.DancePlaying then
        if Core.CurrentDance and Core.CurrentDance.Update then
            pcall(function() Core.CurrentDance.Update(dt, Character) end)
        end
        return
    end

    if not Core.CurrentStyle then return end

    if Humanoid.MoveDirection.Magnitude > 0.05 then
        Core:Play(Core.WalkAnim)
    else
        Core:Play(Core.IdleAnim)
    end
end)

---------------------------------------------------
-- RESPAWN
---------------------------------------------------

Player.CharacterAdded:Connect(function(char)
    Character        = char
    Humanoid         = char:WaitForChild("Humanoid")
    Core.CurrentAnim = nil
end)

--==================================================
-- BHOP DANCE (inline, tidak perlu file terpisah)
--==================================================

local BHOPMusic = nil

local bhop = {}
bhop.ModuleType  = "DANCE"
bhop.Name        = "BHOP Dance"
bhop.Description = "loop fixed bhop"

bhop.Init = function(character)
    local AnimPath  = ASSETS .. "Anims/BHOP Dance.rbxm"
    local MusicPath = ASSETS .. "Sounds/BHOP Dance.mp3"

    -- Load anim
    if not isfile(AnimPath) then
        warn("[BHOP] Missing anim:", AnimPath)
        return
    end
    local ok, model = pcall(function()
        return game:GetObjects(getcustomasset(AnimPath))[1]
    end)
    if not ok or not model then
        warn("[BHOP] Failed loading anim")
        return
    end
    local anim = nil
    local function Scan(obj)
        if obj:IsA("KeyframeSequence") then anim = obj end
        for _, v in ipairs(obj:GetChildren()) do Scan(v) end
    end
    Scan(model)
    if anim then
        pcall(function() getgenv().Animator6D(anim, 1, true) end)
    end

    -- Load music
    if isfile(MusicPath) then
        local ok2, asset = pcall(getcustomasset, MusicPath)
        if ok2 and asset then
            BHOPMusic          = Instance.new("Sound")
            BHOPMusic.Name     = "BHOP_Music"
            BHOPMusic.SoundId  = asset
            BHOPMusic.Volume   = 2
            BHOPMusic.Looped   = true
            BHOPMusic.Parent   = workspace
            BHOPMusic:Play()
            print("[BHOP] Music playing")
        else
            warn("[BHOP] Sound failed")
        end
    else
        warn("[BHOP] Missing sound:", MusicPath)
    end
end

bhop.Update = function() end

bhop.Destroy = function(character)
    if BHOPMusic then
        BHOPMusic:Stop()
        BHOPMusic:Destroy()
        BHOPMusic = nil
    end
    for _, v in ipairs(character:GetDescendants()) do
        if v:IsA("Motor6D") then
            v.Transform    = CFrame.new()
            v.CurrentAngle = 0
        end
    end
end

Loader:Register(bhop)
print("[ModuleEngine] BHOP Dance registered")

--==================================================
-- EXPOSE StyleSets & Dances untuk Core
-- (diisi oleh ModuleContent setelah load)
--==================================================

Core.StyleSets = {}
Core.Dances    = {}

--==================================================
-- RETURN
--==================================================

print("[ModuleEngine] Loaded OK")

return {
    Loader = Loader,
    Core   = Core,
}
