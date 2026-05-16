--==================================================
-- ModuleIntro.lua
-- Gabungan: Intro + PostIntro + Credits
-- Usage di Main.lua:
--   local ModuleIntro = loadfile(ROOT.."Modules/ModuleIntro.lua")()
--   local Intro       = ModuleIntro.Intro
--   local PostIntro   = ModuleIntro.PostIntro
--   local Credits     = ModuleIntro.Credits
--==================================================

local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local Lighting     = game:GetService("Lighting")
local Players      = game:GetService("Players")

local ROOT = "/storage/emulated/0/Delta/Workspace/MyDanceSystem/"

--==================================================
-- CREDITS DATA
-- Edit bagian ini sesuai kebutuhan
--==================================================

local Credits = {
    Title   = "DANCE SYSTEM",
    Version = "v2.0",
    Credits = {
        { Role = "Developer",         Name = "redguy_257"                  },
        { Role = "Animation Engine",  Name = "Animator6D by gObl00x"       },
        { Role = "Framework",         Name = "MyDanceSystem"               },
        { Role = "Executor Support",  Name = "Delta / Mobile Executors"    },
    },
    Note = "Made for fun & learning. Not intended to harm any game.",
}

--==================================================
-- POST INTRO
-- Rules / info UI yang muncul setelah intro selesai
--==================================================

local PostIntro = {}

local POST_SECTIONS = {
    {
        heading = "Purpose",
        lines = {
            "This script is made for learning animation script",
            "and custom style exploration in Roblox.",
            "Not intended to damage or exploit games.",
        },
    },
    {
        heading = "✦  Features",
        lines = {
            "· Custom dance animations (rbxm / Animator6D)",
            "· Style sets for idle & walk animations",
            "· BGM music player with track selection",
        },
    },
    {
        heading = "⚠  Rules",
        lines = {
            "· Do not use to ruin other people's experience",
            "· Do not redistribute without permission",
            "· Do not claim as your own work",
        },
    },
    {
        heading = "ℹ  Info",
        lines = {
            "· Made for fun & learning only",
            "· Compatible with Delta executor (mobile)",
            "· Audio format: OGG / WAV / FLAC (not MP3)",
        },
    },
}

function PostIntro:Show(gui, sfx, onContinue)

    -- Semi-transparent overlay
    local overlay = Instance.new("Frame")
    overlay.Size                   = UDim2.new(1,0,1,0)
    overlay.BackgroundColor3       = Color3.fromRGB(0,0,0)
    overlay.BackgroundTransparency = 0.5
    overlay.BorderSizePixel        = 0
    overlay.ZIndex                 = 90
    overlay.Parent                 = gui

    -- Panel tengah (rounded, abu-abu transparan)
    local panel = Instance.new("Frame")
    panel.Size                   = UDim2.new(0,360,0,300)
    panel.Position               = UDim2.new(0.5,-180,0.5,-150)
    panel.BackgroundColor3       = Color3.fromRGB(45,45,45)
    panel.BackgroundTransparency = 1
    panel.BorderSizePixel        = 0
    panel.ZIndex                 = 91
    panel.Parent                 = gui

    TweenService:Create(panel, TweenInfo.new(0.5), {
        BackgroundTransparency = 0.35   -- abu-abu agak transparan
    }):Play()

    local pCorner = Instance.new("UICorner")
    pCorner.CornerRadius = UDim.new(0, 10)
    pCorner.Parent       = panel

    local pstroke = Instance.new("UIStroke")
    pstroke.Thickness       = 2
    pstroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    pstroke.Parent          = panel

    -- Title
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size               = UDim2.new(1,-10,0,30)
    titleLbl.Position           = UDim2.new(0,5,0,6)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text               = "BEFORE YOU START"
    titleLbl.Font               = Enum.Font.GothamBold
    titleLbl.TextScaled         = true
    titleLbl.TextColor3         = Color3.fromRGB(200,215,255)
    titleLbl.ZIndex             = 92
    titleLbl.Parent             = panel

    local sep = Instance.new("Frame")
    sep.Size             = UDim2.new(1,-10,0,1)
    sep.Position         = UDim2.new(0,5,0,38)
    sep.BackgroundColor3 = Color3.fromRGB(40,40,75)
    sep.BorderSizePixel  = 0
    sep.ZIndex           = 92
    sep.Parent           = panel

    -- Scroll content
    local sf = Instance.new("ScrollingFrame")
    sf.Size                   = UDim2.new(1,-10,1,-90)
    sf.Position               = UDim2.new(0,5,0,42)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel        = 0
    sf.ScrollBarThickness     = 2
    sf.ScrollBarImageColor3   = Color3.fromRGB(0,200,255)
    sf.CanvasSize             = UDim2.new(0,0,0,0)
    sf.ZIndex                 = 92
    sf.Parent                 = panel

    local sLayout = Instance.new("UIListLayout")
    sLayout.Padding = UDim.new(0,4)
    sLayout.Parent  = sf

    local sPad = Instance.new("UIPadding")
    sPad.PaddingTop    = UDim.new(0,4)
    sPad.PaddingBottom = UDim.new(0,4)
    sPad.PaddingLeft   = UDim.new(0,4)
    sPad.PaddingRight  = UDim.new(0,4)
    sPad.Parent        = sf

    sLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0,0,0, sLayout.AbsoluteContentSize.Y + 10)
    end)

    for _, sec in ipairs(POST_SECTIONS) do
        -- Deteksi heading Rules → merah, lainnya → hijau
        local isWarning = sec.heading:find("Rules") ~= nil

        local headingColor = isWarning
            and Color3.fromRGB(255, 80, 80)     -- merah untuk Rules
            or  Color3.fromRGB(80, 220, 120)    -- hijau untuk Purpose/Features/Info

        local lineColor = isWarning
            and Color3.fromRGB(220, 100, 100)   -- merah muda untuk line Rules
            or  Color3.fromRGB(140, 155, 200)   -- warna asli untuk line biasa

        local h = Instance.new("TextLabel")
        h.Size = UDim2.new(1,0,0,20)
        h.BackgroundTransparency = 1
        h.Text = sec.heading
        h.Font = Enum.Font.GothamBold
        h.TextScaled = true
        h.TextColor3 = headingColor
        h.TextXAlignment = Enum.TextXAlignment.Left
        h.ZIndex = 93
        h.Parent = sf

        for _, line in ipairs(sec.lines) do
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1,0,0,15)
            l.BackgroundTransparency = 1
            l.Text = line
            l.Font = Enum.Font.Gotham
            l.TextScaled = true
            l.TextColor3 = lineColor
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.ZIndex = 93
            l.Parent = sf
        end

        local gap = Instance.new("Frame")
        gap.Size = UDim2.new(1,0,0,4)
        gap.BackgroundTransparency = 1
        gap.ZIndex = 93
        gap.Parent = sf
    end

    -- Continue button
    local contBtn = Instance.new("TextButton")
    contBtn.Size             = UDim2.new(1,-10,0,30)
    contBtn.Position         = UDim2.new(0,5,1,-35)
    contBtn.BackgroundColor3 = Color3.fromRGB(0,44,100)
    contBtn.Text             = "CONTINUE  →"
    contBtn.Font             = Enum.Font.GothamBold
    contBtn.TextScaled       = true
    contBtn.TextColor3       = Color3.fromRGB(220,230,255)
    contBtn.BorderSizePixel  = 0
    contBtn.ZIndex           = 92
    contBtn.Parent           = panel

    local cbStroke = Instance.new("UIStroke")
    cbStroke.Thickness = 1.5
    cbStroke.Parent    = contBtn

    -- Outline + stroke hitam fixed (tidak RGB)
    pstroke.Color       = Color3.fromRGB(0, 0, 0)
    cbStroke.Color      = Color3.fromRGB(0, 0, 0)
    titleLbl.TextColor3 = Color3.fromRGB(200, 215, 255)
    contBtn.TextColor3  = Color3.fromRGB(220, 230, 255)
    local conn = nil   -- tidak ada RenderStepped loop untuk warna

    -- Wait continue (polling)
    local continued = false
    contBtn.MouseButton1Click:Connect(function()
        if continued then return end
        continued = true
    end)

    task.spawn(function()
        while not continued do task.wait(0.05) end

        if sfx then pcall(function() sfx:Click() end) end
        if conn then conn:Disconnect() end

        TweenService:Create(panel, TweenInfo.new(0.4), {
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(overlay, TweenInfo.new(0.5), {
            BackgroundTransparency = 1
        }):Play()

        task.delay(0.55, function()
            pcall(function() panel:Destroy()   end)
            pcall(function() overlay:Destroy() end)
            if onContinue then onContinue() end
        end)
    end)
end

--==================================================
-- INTRO
--==================================================

local Intro = {}

-- Config
local INTRO_BGM_FILE   = ROOT .. "Assets/Intro/intro_bgm.ogg"
local INTRO_BGM_VOLUME = 0.55
local WIN_SFX_FILE     = ROOT .. "Assets/SFX/win.ogg"
local FOUND_YOU_FILE   = ROOT .. "Assets/SFX/Creepy_Ambient.ogg"
local EASTER_EGG_NAME  = "redguy_257"
local FADE_IN_TIME     = 0.7
local PAUSE_BETWEEN    = 1.2
local FADE_OUT_TIME    = 1.0
local KICK_DELAY       = 15

local BLUE   = Color3.fromRGB(80,  160, 255)
local WARN   = Color3.fromRGB(255, 80,  80 )
local GOLDEN = Color3.fromRGB(255, 215, 60 )

-- Sounds
local IntroBGMSound = nil

local function StartIntroBGM()
    if not isfile(INTRO_BGM_FILE) then
        warn("[Intro] BGM file not found:", INTRO_BGM_FILE)
        return
    end
    local ok, asset = pcall(getcustomasset, INTRO_BGM_FILE)
    if not ok or not asset or asset == "" then
        warn("[Intro] Failed to load BGM:", INTRO_BGM_FILE)
        return
    end
    local s = Instance.new("Sound")
    s.SoundId = asset
    s.Volume  = INTRO_BGM_VOLUME
    s.Looped  = true
    s.Parent  = workspace
    s:Play()
    IntroBGMSound = s
    print("[Intro] BGM playing:", INTRO_BGM_FILE)
end

local function StopIntroBGM(cb)
    if not IntroBGMSound then if cb then cb() end return end
    local s = IntroBGMSound; IntroBGMSound = nil
    local step = 0.05
    local dec  = INTRO_BGM_VOLUME / (1.2 / step)
    task.spawn(function()
        while s and s.Parent and s.Volume > 0 do
            s.Volume = math.max(0, s.Volume - dec)
            task.wait(step)
        end
        pcall(function() s:Stop(); s:Destroy() end)
        if cb then cb() end
    end)
end

local function PlayWinSFX()
    if not isfile(WIN_SFX_FILE) then return end
    local ok, asset = pcall(getcustomasset, WIN_SFX_FILE)
    if not ok or not asset then return end
    local s = Instance.new("Sound")
    s.SoundId = asset; s.Volume = 0.8; s.Looped = false
    s.Parent = workspace; s:Play()
    game:GetService("Debris"):AddItem(s, 12)
end

local function PlayFoundYou()
    if not isfile(FOUND_YOU_FILE) then
        warn("[Intro] FoundYou SFX not found:", FOUND_YOU_FILE)
        return nil
    end
    local ok, asset = pcall(getcustomasset, FOUND_YOU_FILE)
    if not ok or not asset or asset == "" then
        warn("[Intro] Failed to load FoundYou SFX")
        return nil
    end
    local s = Instance.new("Sound")
    s.SoundId = asset
    s.Volume  = 0.85
    s.Looped  = true
    s.Parent  = workspace
    s:Play()
    return s
end

-- Lighting helpers
local origAmbient, origOutdoor

local function SaveLighting()
    origAmbient = Lighting.Ambient
    origOutdoor = Lighting.OutdoorAmbient
end

local function RestoreLighting()
    pcall(function()
        Lighting.Ambient        = origAmbient or Color3.fromRGB(70,70,70)
        Lighting.OutdoorAmbient = origOutdoor or Color3.fromRGB(70,70,70)
    end)
end

local function CleanupEffects(bloom, cc, pl, parts)
    pcall(function() if bloom then bloom:Destroy() end end)
    pcall(function() if cc    then cc:Destroy()    end end)
    pcall(function() if pl    then pl:Destroy()    end end)
    for _, l in ipairs(parts or {}) do
        pcall(function() if l then l:Destroy() end end)
    end
    RestoreLighting()
end

-- UI helpers
local function MakeOverlay(gui)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,1,0)
    f.BackgroundColor3 = Color3.fromRGB(0,0,0)
    f.BackgroundTransparency = 0
    f.BorderSizePixel = 0; f.ZIndex = 200; f.Parent = gui
    return f
end

local function MakeLbl(parent, text, yPos, size, bold, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.8,0,0,size or 30)
    l.Position = UDim2.new(0.1,0,yPos,0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.TextScaled = true
    l.TextColor3 = color or BLUE
    l.TextTransparency = 1
    l.ZIndex = 201; l.Parent = parent
    return l
end

local function MakeInput(parent, yPos)
    local b = Instance.new("TextBox")
    b.Size = UDim2.new(0.5,0,0,36)
    b.Position = UDim2.new(0.25,0,yPos,0)
    b.BackgroundColor3 = Color3.fromRGB(8,12,24)
    b.BackgroundTransparency = 1
    b.Text = ""; b.PlaceholderText = "type your name here"
    b.PlaceholderColor3 = Color3.fromRGB(40,70,140)
    b.Font = Enum.Font.Gotham; b.TextScaled = true
    b.TextColor3 = BLUE; b.TextTransparency = 1
    b.BorderSizePixel = 0; b.ZIndex = 201
    b.ClearTextOnFocus = false; b.Parent = parent
    local s = Instance.new("UIStroke")
    s.Thickness = 1.5; s.Color = Color3.fromRGB(40,80,180)
    s.Transparency = 1; s.Parent = b
    return b, s
end

local function MakeBtn(parent, text, xScale, yPos, w, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,w or 110,0,34)
    b.Position = UDim2.new(xScale,-(w or 110)/2,yPos,0)
    b.BackgroundColor3 = Color3.fromRGB(0,0,0)
    b.BackgroundTransparency = 1
    b.Text = text; b.Font = Enum.Font.GothamBold
    b.TextScaled = true; b.TextColor3 = Color3.fromRGB(220,220,220)
    b.TextTransparency = 1; b.BorderSizePixel = 0
    b.ZIndex = 202; b.Parent = parent
    local s = Instance.new("UIStroke")
    s.Thickness = 1.5
    s.Color = Color3.fromRGB(0, 0, 0)   -- outline hitam
    s.Transparency = 1; s.Parent = b
    return b, s
end

local function MakeWarn(parent, yPos)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.5,0,0,18)
    l.Position = UDim2.new(0.25,0,yPos,0)
    l.BackgroundTransparency = 1
    l.Text = "please enter your name first"
    l.Font = Enum.Font.Gotham; l.TextScaled = true
    l.TextColor3 = WARN; l.TextTransparency = 1
    l.ZIndex = 203; l.Parent = parent
    return l
end

local function ShowLbl(l,t)
    TweenService:Create(l,TweenInfo.new(t or FADE_IN_TIME),{TextTransparency=0}):Play()
end
local function HideLbl(l,t)
    TweenService:Create(l,TweenInfo.new(t or 0.4),{TextTransparency=1}):Play()
end
local function ShowBox(b,s,t)
    t=t or FADE_IN_TIME
    TweenService:Create(b,TweenInfo.new(t),{TextTransparency=0,BackgroundTransparency=0.3}):Play()
    TweenService:Create(s,TweenInfo.new(t),{Transparency=0}):Play()
end
local function HideBox(b,s,t)
    t=t or 0.4
    TweenService:Create(b,TweenInfo.new(t),{TextTransparency=1,BackgroundTransparency=1}):Play()
    TweenService:Create(s,TweenInfo.new(t),{Transparency=1}):Play()
end
local function ShowBtn(b,s,t)
    t=t or FADE_IN_TIME
    TweenService:Create(b,TweenInfo.new(t),{TextTransparency=0,BackgroundTransparency=0.15}):Play()
    TweenService:Create(s,TweenInfo.new(t),{Transparency=0}):Play()
end
local function HideBtn(b,s,t)
    t=t or 0.35
    TweenService:Create(b,TweenInfo.new(t),{TextTransparency=1,BackgroundTransparency=1}):Play()
    TweenService:Create(s,TweenInfo.new(t),{Transparency=1}):Play()
end

local function FadeOverlay(overlay, cb)
    TweenService:Create(overlay,TweenInfo.new(FADE_OUT_TIME),{BackgroundTransparency=1}):Play()
    for _, v in ipairs(overlay:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
            TweenService:Create(v,TweenInfo.new(FADE_OUT_TIME*0.7),{
                TextTransparency=1,BackgroundTransparency=1
            }):Play()
        end
        if v:IsA("UIStroke") then
            TweenService:Create(v,TweenInfo.new(FADE_OUT_TIME*0.6),{Transparency=1}):Play()
        end
    end
    task.delay(FADE_OUT_TIME+0.15, function()
        pcall(function() overlay:Destroy() end)
        if cb then cb() end
    end)
end

-- No sequence: efek gelap + fog tebal abu-abu, lanjut ke main UI
local function DoNoEffect(gui, onFinished)
    StopIntroBGM(nil)
    SaveLighting()

    -- ColorCorrection: gelap, saturation turun, tint abu
    local cc = Instance.new("ColorCorrectionEffect")
    cc.Saturation = 0
    cc.Brightness = 0
    cc.Contrast   = 0
    cc.TintColor  = Color3.fromRGB(255, 255, 255)
    cc.Parent     = Lighting

    -- Atmosphere: fog tebal abu-abu
    local atmo = Instance.new("Atmosphere")
    atmo.Density    = 0
    atmo.Offset     = 0
    atmo.Color      = Color3.fromRGB(130, 130, 130)
    atmo.Glare      = 0
    atmo.Haze       = 0
    atmo.Parent     = Lighting

    -- Tween lighting jadi hampir gelap
    TweenService:Create(Lighting, TweenInfo.new(1.2, Enum.EasingStyle.Quad), {
        Ambient        = Color3.fromRGB(15, 15, 15),
        OutdoorAmbient = Color3.fromRGB(10, 10, 10),
    }):Play()

    -- Tween ColorCorrection ke gelap
    TweenService:Create(cc, TweenInfo.new(1.2, Enum.EasingStyle.Quad), {
        Brightness = -0.55,
        Saturation = -0.8,
        TintColor  = Color3.fromRGB(160, 160, 160),
    }):Play()

    -- Tween Atmosphere: fog makin tebal
    TweenService:Create(atmo, TweenInfo.new(1.4, Enum.EasingStyle.Quad), {
        Density = 0.85,
        Haze    = 2.5,
        Offset  = 0.25,
    }):Play()

    -- Overlay hitam fade in agak gelap
    local darkOverlay = Instance.new("Frame")
    darkOverlay.Size                   = UDim2.new(1, 0, 1, 0)
    darkOverlay.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    darkOverlay.BackgroundTransparency = 1
    darkOverlay.BorderSizePixel        = 0
    darkOverlay.ZIndex                 = 250
    darkOverlay.Parent                 = gui

    TweenService:Create(darkOverlay, TweenInfo.new(1.4, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0.35,  -- hampir gelap tapi masih kelihatan
    }):Play()

    -- Tunggu efek masuk, lalu lanjut ke main UI
    task.wait(2.0)

    -- Fade overlay keluar
    TweenService:Create(darkOverlay, TweenInfo.new(0.8), {
        BackgroundTransparency = 1,
    }):Play()

    -- Kembalikan lighting pelan-pelan
    TweenService:Create(Lighting, TweenInfo.new(1.5), {
        Ambient        = Color3.fromRGB(70, 70, 70),
        OutdoorAmbient = Color3.fromRGB(70, 70, 70),
    }):Play()
    TweenService:Create(cc, TweenInfo.new(1.5), {
        Brightness = 0,
        Saturation = 0,
        TintColor  = Color3.fromRGB(255, 255, 255),
    }):Play()
    TweenService:Create(atmo, TweenInfo.new(1.5), {
        Density = 0,
        Haze    = 0,
        Offset  = 0,
    }):Play()

    task.delay(1.6, function()
        pcall(function() cc:Destroy() end)
        pcall(function() atmo:Destroy() end)
        pcall(function() darkOverlay:Destroy() end)
        RestoreLighting()
        if onFinished then onFinished() end
    end)
end

-- DoTroll: mulai fog gelap abu → transisi ke efek merah, loop selamanya
local function DoTroll(gui)
    StopIntroBGM(nil)
    SaveLighting()
    local player = Players.LocalPlayer
    local char   = player and player.Character

    -- FASE 1: Fog tebal abu + gelap dulu (1.5 detik)
    local fogAtmo = Instance.new("Atmosphere")
    fogAtmo.Density = 0
    fogAtmo.Haze    = 0
    fogAtmo.Offset  = 0
    fogAtmo.Color   = Color3.fromRGB(100, 100, 100)
    fogAtmo.Glare   = 0
    fogAtmo.Parent  = Lighting

    local fogCC = Instance.new("ColorCorrectionEffect")
    fogCC.Brightness = 0
    fogCC.Saturation = 0
    fogCC.Contrast   = 0
    fogCC.TintColor  = Color3.fromRGB(255, 255, 255)
    fogCC.Parent     = Lighting

    -- Overlay gelap abu masuk
    local darkOverlay = Instance.new("Frame")
    darkOverlay.Size                   = UDim2.new(1, 0, 1, 0)
    darkOverlay.BackgroundColor3       = Color3.fromRGB(10, 10, 10)
    darkOverlay.BackgroundTransparency = 1
    darkOverlay.BorderSizePixel        = 0
    darkOverlay.ZIndex                 = 250
    darkOverlay.Parent                 = gui

    TweenService:Create(darkOverlay, TweenInfo.new(1.2, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0.3,
    }):Play()

    TweenService:Create(Lighting, TweenInfo.new(1.2, Enum.EasingStyle.Quad), {
        Ambient        = Color3.fromRGB(3, 3, 3),
        OutdoorAmbient = Color3.fromRGB(2, 2, 2),
    }):Play()

    TweenService:Create(fogCC, TweenInfo.new(1.2, Enum.EasingStyle.Quad), {
        Brightness = -0.8,
        Saturation = -1,
        TintColor  = Color3.fromRGB(110, 110, 110),
    }):Play()

    TweenService:Create(fogAtmo, TweenInfo.new(1.4, Enum.EasingStyle.Quad), {
        Density = 0.98,
        Haze    = 5.0,
        Offset  = 0.5,
    }):Play()

    task.wait(2.0)   -- tahan efek abu gelap sebentar

    -- FASE 2: Transisi ke efek merah
    pcall(function() fogCC:Destroy() end)

    local bloom = Instance.new("BloomEffect")
    bloom.Intensity = 3.5; bloom.Size = 60; bloom.Threshold = 0.9
    bloom.Parent    = Lighting

    local cc = Instance.new("ColorCorrectionEffect")
    cc.Saturation = -0.5; cc.Brightness = 0.05
    cc.Contrast   = 0.2;  cc.TintColor  = Color3.fromRGB(255, 60, 60)
    cc.Parent     = Lighting

    TweenService:Create(Lighting, TweenInfo.new(0.6), {
        Ambient        = Color3.fromRGB(60, 0, 0),
        OutdoorAmbient = Color3.fromRGB(40, 0, 0),
    }):Play()

    -- Fog warna merah, tetap tebal tidak mengecil
    TweenService:Create(fogAtmo, TweenInfo.new(0.8), {
        Color   = Color3.fromRGB(120, 0, 0),
        Density = 0.95,
        Haze    = 4.5,
    }):Play()

    -- Overlay gelap keluar
    TweenService:Create(darkOverlay, TweenInfo.new(0.6), {
        BackgroundTransparency = 1,
    }):Play()
    task.delay(0.7, function() pcall(function() darkOverlay:Destroy() end) end)

    local pl = nil
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        pl = Instance.new("PointLight")
        pl.Color      = Color3.fromRGB(255, 0, 0)
        pl.Brightness = 5; pl.Range = 30; pl.Shadows = true
        pl.Parent     = root
    end

    local partLights = {}
    if root then
        local pos = root.Position; local cnt = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            if cnt >= 35 then break end
            if obj:IsA("BasePart") and obj ~= root
            and not obj:FindFirstChildOfClass("PointLight")
            and (obj.Position - pos).Magnitude <= 100 then
                local l = Instance.new("PointLight")
                l.Color = Color3.fromRGB(255, 0, 0)
                l.Brightness = 2; l.Range = 20; l.Parent = obj
                table.insert(partLights, l); cnt = cnt + 1
            end
        end
    end

    task.wait(0.3)
    local foundSound = PlayFoundYou()

    -- Loop selamanya, tidak ada batas waktu, onFinished tidak dipanggil
    local t = 0
    RunService.RenderStepped:Connect(function(dt)
        t = t + dt
        pcall(function()
            bloom.Intensity = math.clamp(2.5 + math.sin(t*4)*1.0 + math.sin(t*9)*0.3, 1.5, 4.5)
        end)
        if pl and pl.Parent then
            pl.Brightness = 4 + math.sin(t*6)*2
            pl.Range      = 28 + math.sin(t*3.5)*8
        end
        if cc and cc.Parent then
            local v = math.sin(t*5)*0.5 + 0.5
            cc.TintColor = Color3.fromRGB(255, math.floor(v*50), math.floor(v*50))
        end
        -- Fog pulse tetap tebal, range kecil biar tidak mengecil jauh
        if fogAtmo and fogAtmo.Parent then
            pcall(function()
                fogAtmo.Density = 0.92 + math.sin(t*2)*0.05
                fogAtmo.Haze    = 4.2  + math.sin(t*1.5)*0.3
            end)
        end
    end)
end

-- Y positions
local Y = {
    Line1=0.30, Input=0.40, Confirm=0.52, Warn=0.62,
    Question=0.28, YesNo=0.42, Result=0.37,
}

-- Play function
function Intro:Play(gui, onFinished)
    local overlay = MakeOverlay(gui)
    StartIntroBGM()

    task.spawn(function()
        task.wait(0.6)

        local line1 = MakeLbl(overlay,"Enter your name.",Y.Line1,28)
        ShowLbl(line1)
        task.wait(FADE_IN_TIME+PAUSE_BETWEEN)

        local inputBox,inputStroke = MakeInput(overlay,Y.Input)
        ShowBox(inputBox,inputStroke)
        task.wait(FADE_IN_TIME+0.15)

        local confirmBtn,confirmStroke = MakeBtn(
            overlay,"Continue",0.5,Y.Confirm,130,
            Color3.fromRGB(0,30,80)
        )
        ShowBtn(confirmBtn,confirmStroke)
        local warnLbl = MakeWarn(overlay,Y.Warn)

        local confirmed=false; local enteredName=""

        confirmBtn.MouseButton1Click:Connect(function()
            if confirmed then return end
            local trimmed=(inputBox.Text or ""):match("^%s*(.-)%s*$") or ""
            if trimmed=="" then
                TweenService:Create(warnLbl,TweenInfo.new(0.3),{TextTransparency=0}):Play()
                task.delay(2,function()
                    TweenService:Create(warnLbl,TweenInfo.new(0.4),{TextTransparency=1}):Play()
                end)
                return
            end
            enteredName=trimmed; confirmed=true
        end)

        while not confirmed do task.wait(0.05) end

        HideLbl(line1); HideLbl(warnLbl)
        HideBtn(confirmBtn,confirmStroke)
        HideBox(inputBox,inputStroke)
        task.wait(0.55)

        local isSpecial=string.lower(enteredName)==string.lower(EASTER_EGG_NAME)

        if isSpecial then
            local q=MakeLbl(overlay,'Is this really you,  "'..enteredName..'"?',Y.Question,28)
            ShowLbl(q)
            task.wait(FADE_IN_TIME+PAUSE_BETWEEN)

            local yesBtn,yesStroke=MakeBtn(overlay,"Yes",0.35,Y.YesNo,100,Color3.fromRGB(30, 55, 30))
            local noBtn,noStroke=MakeBtn(overlay,"No",0.65,Y.YesNo,100,Color3.fromRGB(55, 22, 22))
            ShowBtn(yesBtn,yesStroke); ShowBtn(noBtn,noStroke)
            task.wait(FADE_IN_TIME+0.2)

            local choice=nil
            yesBtn.MouseButton1Click:Connect(function() if not choice then choice="yes" end end)
            noBtn.MouseButton1Click:Connect(function() if not choice then choice="no" end end)
            while not choice do task.wait(0.05) end

            HideLbl(q); HideBtn(yesBtn,yesStroke); HideBtn(noBtn,noStroke)
            task.wait(0.5)

            if choice=="yes" then
                StopIntroBGM(nil); PlayWinSFX()
                local chosen=MakeLbl(overlay,"Now you are the chosen one.",Y.Result,32,true,GOLDEN)
                ShowLbl(chosen,FADE_IN_TIME+0.2)
                task.wait(FADE_IN_TIME+2.8)
                HideLbl(chosen); task.wait(0.5)
                FadeOverlay(overlay,onFinished)
            else
                pcall(function() overlay:Destroy() end)
                DoTroll(gui)
                -- onFinished TIDAK dipanggil di sini → script tidak keload
            end

        else
            local chosen=MakeLbl(overlay,enteredName..",  you have been chosen.",Y.Result,28)
            ShowLbl(chosen)
            task.wait(FADE_IN_TIME+2.0)
            HideLbl(chosen); task.wait(0.4)
            StopIntroBGM(function()
                task.wait(0.3)
                FadeOverlay(overlay,onFinished)
            end)
        end
    end)
end

--==================================================
-- RETURN SEMUA TIGA
--==================================================

return {
    Intro     = Intro,
    PostIntro = PostIntro,
    Credits   = Credits,
}
