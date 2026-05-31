--==================================================
-- ModuleContent.lua
-- Gabungan: DanceLoader + StyleSetLoader + DanceInfo
-- Usage di Main.lua:
--   local ModuleContent = loadfile(ROOT.."Modules/ModuleContent.lua")()
--   local Dances     = ModuleContent.Dances      -- table of dance modules
--   local StyleSets  = ModuleContent.StyleSets   -- table of styleset modules
--   local DanceInfo  = ModuleContent.DanceInfo   -- popup module
--==================================================

local ROOT   = "/storage/emulated/0/Delta/Workspace/MyDanceSystem/"
local ASSETS = ROOT .. "Assets/"
local STYLES = ROOT .. "Modules/StyleSets/"

---------------------------------------------------
-- LOCAL REGISTRY (tidak depend pada ModuleLoader.lua)
-- SystemLoader akan sambungkan ke Loader dari ModuleEngine
---------------------------------------------------

local ModuleLoader = {}
ModuleLoader._log  = {}

function ModuleLoader:Notify(text, success)
    table.insert(self._log, { Text=text, Success=success })
    if success then
        print("[MODULE]", text)
    else
        warn("[MODULE]", text)
    end
end

function ModuleLoader:Register(module)
    -- no-op di sini, registration dilakukan via return table
end

---------------------------------------------------
-- SHARED: LoadRBXM helper
---------------------------------------------------

local function LoadRBXM(path)
    if not isfile(path) then
        warn("[ModuleContent] Missing:", path)
        return nil, nil
    end

    local ok, model = pcall(function()
        return game:GetObjects(getcustomasset(path))[1]
    end)

    if not ok or not model then
        warn("[ModuleContent] Failed:", path)
        return nil, nil
    end

    local anim = nil
    local function Scan(obj)
        if obj:IsA("KeyframeSequence") then
            anim = obj
        end
        for _, v in ipairs(obj:GetChildren()) do
            Scan(v)
        end
    end
    Scan(model)

    return anim, model
end

--==================================================
-- DANCE LOADER
--==================================================

local Dances = {}

local function CreateDance(Name, Desc, AnimFile, MusicFile, UseEffects)

    local m       = {}
    m.ModuleType  = "DANCE"
    m.Name        = Name
    m.Description = Desc

    local Music = nil

    m.Init = function(character)
        local AnimPath  = ASSETS .. "Anims/"  .. AnimFile
        local MusicPath = ASSETS .. "Sounds/" .. MusicFile

        local anim, model = LoadRBXM(AnimPath)
        if not anim then
            warn("[Dance] Animation failed:", AnimPath)
            return
        end

        pcall(function()
            getgenv().Animator6D(anim, 1, true)
        end)

        if isfile(MusicPath) then
            local ok2, asset = pcall(getcustomasset, MusicPath)
            if ok2 and asset then
                Music          = Instance.new("Sound")
                Music.Name     = m.Name .. "_Music"
                Music.SoundId  = asset
                Music.Volume   = 2
                Music.Looped   = true
                Music.Parent   = workspace
                Music:Play()
                print("[Dance] Playing:", MusicPath)
            else
                warn("[Dance] Sound failed:", MusicPath)
            end
        else
            warn("[Dance] Missing sound:", MusicPath)
        end

        if UseEffects and model then
            local root = character:FindFirstChild("HumanoidRootPart")
            if root then
                local function ScanEffects(obj)
                    if obj:IsA("ParticleEmitter")
                    or obj:IsA("Trail")
                    or obj:IsA("Beam")
                    or obj:IsA("Attachment")
                    or obj:IsA("PointLight") then
                        local clone = obj:Clone()
                        clone.Parent = root
                        pcall(function() clone.Enabled = true end)
                    end
                    for _, v in ipairs(obj:GetChildren()) do
                        ScanEffects(v)
                    end
                end
                ScanEffects(model)
            end
        end
    end

    m.Update = function() end

    m.Destroy = function(character)
        if Music then
            Music:Stop()
            Music:Destroy()
            Music = nil
        end

        local root = character:FindFirstChild("HumanoidRootPart")
        if root then
            for _, v in ipairs(root:GetChildren()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail")
                or v:IsA("Beam") or v:IsA("Attachment")
                or v:IsA("PointLight") then
                    v:Destroy()
                end
            end
        end

        for _, v in ipairs(character:GetDescendants()) do
            if v:IsA("Motor6D") then
                v.Transform    = CFrame.new()
                v.CurrentAngle = 0
            end
        end
    end

    ModuleLoader:Register(m)
    table.insert(Dances, m)
end

---------------------------------------------------
-- DAFTAR DANCE
-- Tambah dance baru di sini
---------------------------------------------------

CreateDance(
    "Hypno Dance",
    "hey hey hypno dance",
    "Hypno Dance.rbxm",
    "Hypno Dance.mp3",
    false
)

CreateDance(
    "Bonk Mortal",
    "BOINK!",
    "Bonk Mortal.rbxm",
    "Bonk Mortal.mp3",
    false
)

CreateDance(
    "Spin Dance",
    "BOUNCIN",
    "BOUNCIN.rbxm",
    "BOUNCIN.mp3",
    false
)

CreateDance(
    "BOX Swing",
    "IDK WHAT I NEED TO PUT",
    "BOX Swing.rbxm",
    "BOX Swing.mp3",
    false
)

CreateDance(
    "Head Lock",
    "Tuff edit",
    "Headlock.rbxm",
    "Headlock.mp3",
    false
)

CreateDance(
    "Distraction Dance",
    "MISSION FAILED",
    "Distraction Dance.rbxm",
    "Distraction Dance.mp3",
    false
)

CreateDance(
    "Shadow Dash",
    "I FOUND YOU FAKER",
    "Shadow Dash.rbxm",
    "Shadow Dash.mp3",
    true
)

CreateDance(
    "JUMPSTYLE",
    "IN BACKROOM DOING JUMPSTYLE",
    "JumpStyle.rbxm",
    "JumpStyle.ogg",
    false
)

CreateDance(
    "BRICKS BATLLER",
    "Kabomm its that your tower!",
    "BrickaBattler.rbxm",
    "BrickBattler.mp3",
    false
)

CreateDance(
    "PRINCE",
    "FORSAKEN!!",
    "Prince.rbxm",
    "Prince.mp3",
    false
)

CreateDance(
    "I miss the Quite",
    "Lord X?",
    "I Miss The Quitet.rbxm",
    "I Miss The Quiet.ogg",
    false
)


-- BHOP Dance sudah dihandle di ModuleEngine.lua

print("[ModuleContent] Dances loaded:", #Dances)

--==================================================
-- STYLE SET LOADER
--==================================================

local StyleSets = {}

local StyleSetFiles = {
    "Ninja.lua",
    "Casual.lua",
    "DefaulStyleSet.lua",
}

for _, file in ipairs(StyleSetFiles) do
    local path = STYLES .. file

    if not isfile(path) then
        ModuleLoader:Notify("Missing StyleSet: " .. file, false)
        continue
    end

    local ok2, module = pcall(function()
        return loadfile(path)()
    end)

    if not ok2 then
        ModuleLoader:Notify("Failed loading: " .. file, false)
        warn(module)
        continue
    end

    if not module then
        ModuleLoader:Notify("Nil module: " .. file, false)
        continue
    end

    if module.ModuleType ~= "STYLESET" then
        ModuleLoader:Notify("Invalid type in: " .. file, false)
        continue
    end

    if not module.Name then
        ModuleLoader:Notify("No name in: " .. file, false)
        continue
    end

    if not module.Abilities then
        module.Abilities = {}
    elseif typeof(module.Abilities) ~= "table" then
        ModuleLoader:Notify("Abilities not table: " .. module.Name, false)
        continue
    end

    ModuleLoader:Register(module)
    table.insert(StyleSets, module)
    ModuleLoader:Notify("StyleSet Loaded: " .. module.Name, true)
end

print("[ModuleContent] StyleSets loaded:", #StyleSets)

--==================================================
-- DANCE INFO
-- Popup nama + description setelah dance stop
--==================================================

local DanceInfo = {}

local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")

local _popup     = nil
local _popupConn = nil
local _fadeThread= nil

local function DismissPopup()
    if _fadeThread then
        pcall(task.cancel, _fadeThread)
        _fadeThread = nil
    end
    if _popupConn then
        _popupConn:Disconnect()
        _popupConn = nil
    end
    if _popup and _popup.Parent then
        TweenService:Create(_popup, TweenInfo.new(0.5), {
            BackgroundTransparency = 1
        }):Play()
        for _, v in ipairs(_popup:GetDescendants()) do
            if v:IsA("TextLabel") then
                TweenService:Create(v, TweenInfo.new(0.4), {
                    TextTransparency = 1
                }):Play()
            end
            if v:IsA("UIStroke") then
                TweenService:Create(v, TweenInfo.new(0.4), {
                    Transparency = 1
                }):Play()
            end
        end
        local ref = _popup
        _popup = nil
        task.delay(0.65, function()
            pcall(function() ref:Destroy() end)
        end)
    end
end

function DanceInfo:Show(gui, danceName, danceDesc, duration)
    DismissPopup()

    duration = duration or 4.5

    local frame = Instance.new("Frame")
    frame.Name                    = "DanceInfoPopup"
    frame.Size                    = UDim2.new(0, 280, 0, 70)
    frame.Position                = UDim2.new(0.5, -140, 1, -60)
    frame.BackgroundColor3        = Color3.fromRGB(8, 8, 16)
    frame.BackgroundTransparency  = 0.1
    frame.BorderSizePixel         = 0
    frame.ZIndex                  = 80
    frame.Parent                  = gui
    _popup = frame

    local fstroke = Instance.new("UIStroke")
    fstroke.Thickness       = 1.8
    fstroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    fstroke.Parent          = frame

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size               = UDim2.new(1,-10,0,28)
    nameLbl.Position           = UDim2.new(0,5,0,5)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text               = danceName or "Dance"
    nameLbl.Font               = Enum.Font.GothamBold
    nameLbl.TextScaled         = true
    nameLbl.TextColor3         = Color3.fromRGB(200,215,255)
    nameLbl.TextXAlignment     = Enum.TextXAlignment.Left
    nameLbl.ZIndex             = 81
    nameLbl.Parent             = frame

    local descLbl = Instance.new("TextLabel")
    descLbl.Size               = UDim2.new(1,-10,0,28)
    descLbl.Position           = UDim2.new(0,5,0,36)
    descLbl.BackgroundTransparency = 1
    descLbl.Text               = danceDesc or ""
    descLbl.Font               = Enum.Font.Gotham
    descLbl.TextScaled         = true
    descLbl.TextColor3         = Color3.fromRGB(130,150,205)
    descLbl.TextXAlignment     = Enum.TextXAlignment.Left
    descLbl.ZIndex             = 81
    descLbl.Parent             = frame

    -- Slide up
    TweenService:Create(frame, TweenInfo.new(0.35,
        Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5,-140,1,-115)
    }):Play()

    -- RGB stroke cycle
    local hue = 0
    _popupConn = RunService.RenderStepped:Connect(function(dt)
        hue = (hue + dt * 0.15) % 1
        fstroke.Color    = Color3.fromHSV(hue, 1, 1)
        nameLbl.TextColor3 = Color3.fromHSV((hue+0.15)%1, 0.5, 1)
    end)

    -- Auto dismiss
    _fadeThread = task.delay(duration, function()
        DismissPopup()
    end)
end

function DanceInfo:Hide()
    DismissPopup()
end

--==================================================
-- RETURN SEMUA TIGA
--==================================================

return {
    Dances    = Dances,
    StyleSets = StyleSets,
    DanceInfo = DanceInfo,
}
