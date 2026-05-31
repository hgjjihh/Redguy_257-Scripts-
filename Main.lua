--==================================================
-- MAIN.LUA  ·  Dance System
-- Load via SystemLoader (5 modules → 1 load)
-- Outline: oranye terang, shine/pulse
-- Text: RGB, no UIStroke on text
--==================================================

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player    = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

Player.CharacterAdded:Connect(function(c)
    Character = c
end)

local ROOT = "/storage/emulated/0/Delta/Workspace/MyDanceSystem/"

---------------------------------------------------
-- LOAD SEMUA VIA SYSTEMLOADER (1 baris)
---------------------------------------------------

local System    = loadfile(ROOT .. "Modules/SystemLoader.lua")()

local Core      = System.Core
local BGM       = System.BGM
local SFX       = System.SFX
local Setting   = System.Setting
local DanceInfo = System.DanceInfo
local Intro     = System.Intro
local PostIntro = System.PostIntro
local Credits   = System.Credits

-- Footstep + Jump + Fade to Idle
local FootstepModule = loadfile(ROOT .. "Modules/FootstepModule.lua")()

---------------------------------------------------
-- ORANGE SHINE
-- Dipakai untuk OUTLINE dan TEXT sekaligus
-- Pulse sine wave antara oranye base dan oranye terang
---------------------------------------------------

-- White & Black color system
local UI_WHITE     = Color3.fromRGB(250, 250, 250)   -- background putih
local UI_BLACK     = Color3.fromRGB(15,  15,  15)    -- outline & text hitam
local UI_GRAY      = Color3.fromRGB(235, 235, 235)   -- putih sedikit gelap untuk variasi
local UI_BLACK_SOFT= Color3.fromRGB(40,  40,  40)    -- hitam lembut untuk text sekunder

local function GetShineColor(shineVal)
    -- outline hitam, tidak berubah
    return UI_BLACK
end

-- Text: hitam, no stroke
local function GetTextShine(shineVal)
    return UI_BLACK
end

---------------------------------------------------
-- TRACKING
---------------------------------------------------

local Texts   = {}
local Strokes = {}
local _tOff, _sOff = 0, 0

local function TT(t)
    _tOff = _tOff + 0.035
    table.insert(Texts, { t=t, off=_tOff })
end

local function TS(s)
    _sOff = _sOff + 0.04
    table.insert(Strokes, { s=s, off=_sOff })
end

---------------------------------------------------
-- GUI
---------------------------------------------------

local Gui = Instance.new("ScreenGui")
Gui.Name            = "DanceSystemUI"
Gui.ResetOnSpawn    = false
Gui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
Gui.IgnoreGuiInset  = true
pcall(function() Gui.Parent = game.CoreGui end)

local UIRoot = Instance.new("Frame")
UIRoot.Name                   = "UIRoot"
UIRoot.Size                   = UDim2.new(1,0,1,0)
UIRoot.BackgroundTransparency = 1
UIRoot.Visible                = false
UIRoot.ZIndex                 = 1
UIRoot.Parent                 = Gui

---------------------------------------------------
-- MAIN FRAME  340 × 195  sharp corners
---------------------------------------------------

local W, H = 340, 195

local Main = Instance.new("Frame")
Main.Name             = "Main"
Main.Size             = UDim2.new(0,W,0,H)
Main.Position         = UDim2.new(0.5,-(W/2),0.5,-(H/2))
Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Main.BorderSizePixel  = 0
Main.Active           = true
Main.ClipsDescendants = true
Main.ZIndex           = 2
Main.Parent           = UIRoot

-- UIGradient putih bersih (tidak ada warna lain)
local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(255, 255, 255)),
})
UIGradient.Rotation = 135
UIGradient.Parent   = Main

-- Outline utama (oranye shine)
local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness       = 2
MainStroke.Color           = UI_BLACK
MainStroke.Transparency    = 0
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent          = Main
-- MainStroke diupdate langsung di RenderStepped, tidak lewat Strokes table

---------------------------------------------------
-- SHINE EFFECT (sweep putih keemasan di atas gradient)
---------------------------------------------------

-- Shine utama: sapuan cahaya tipis
local Shimmer = Instance.new("Frame")
Shimmer.Name                   = "Shine"
Shimmer.Size                   = UDim2.new(0, 55, 1.3, 0)
Shimmer.Position               = UDim2.new(-0.25, 0, -0.15, 0)
Shimmer.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
Shimmer.BackgroundTransparency = 1
Shimmer.BorderSizePixel        = 0
Shimmer.Rotation               = 10
Shimmer.ZIndex                 = 20
Shimmer.Parent                 = Main

local ShimGrad = Instance.new("UIGradient")
ShimGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0,   1),
    NumberSequenceKeypoint.new(0.4, 0.72),
    NumberSequenceKeypoint.new(0.5, 0.65),
    NumberSequenceKeypoint.new(0.6, 0.72),
    NumberSequenceKeypoint.new(1,   1),
})
ShimGrad.Parent = Shimmer

-- Shine ke-2: lebih sempit, lebih terang, sedikit versetzt
local Shimmer2 = Instance.new("Frame")
Shimmer2.Name                   = "Shine2"
Shimmer2.Size                   = UDim2.new(0, 22, 1.3, 0)
Shimmer2.Position               = UDim2.new(-0.25, 0, -0.15, 0)
Shimmer2.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
Shimmer2.BackgroundTransparency = 1
Shimmer2.BorderSizePixel        = 0
Shimmer2.Rotation               = 10
Shimmer2.ZIndex                 = 21
Shimmer2.Parent                 = Main

local ShimGrad2 = Instance.new("UIGradient")
ShimGrad2.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0,   1),
    NumberSequenceKeypoint.new(0.5, 0.55),
    NumberSequenceKeypoint.new(1,   1),
})
ShimGrad2.Parent = Shimmer2

---------------------------------------------------
-- TOPBAR
---------------------------------------------------

local Top = Instance.new("Frame")
Top.Size             = UDim2.new(1,0,0,24)
Top.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Top.BorderSizePixel  = 0
Top.Active           = true
Top.ZIndex           = 4
Top.Parent           = Main

local TopSep = Instance.new("Frame")
TopSep.Size             = UDim2.new(1,0,0,1)
TopSep.Position         = UDim2.new(0,0,1,-1)
TopSep.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
TopSep.BorderSizePixel  = 0
TopSep.ZIndex           = 4
TopSep.Parent           = Top

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size               = UDim2.new(1,-44,1,0)
TitleLabel.Position           = UDim2.new(0,4,0,0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text               = "Zechzz Dance"
TitleLabel.Font               = Enum.Font.Gotham
TitleLabel.TextScaled         = true
TitleLabel.TextXAlignment     = Enum.TextXAlignment.Center
TitleLabel.ZIndex             = 5
TitleLabel.Parent             = Top
TT(TitleLabel)

local Min = Instance.new("TextButton")
Min.Size             = UDim2.new(0,18,0,16)
Min.Position         = UDim2.new(1,-22,0,4)
Min.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Min.BackgroundTransparency = 1
Min.Text             = "−"
Min.Font             = Enum.Font.Gotham
Min.TextScaled       = true
Min.BorderSizePixel  = 0
Min.ZIndex           = 6
Min.Parent           = Top
TT(Min)
Min.MouseButton1Click:Connect(function() SFX:Click() end)

---------------------------------------------------
-- TAB BAR
---------------------------------------------------

local TabBar = Instance.new("Frame")
TabBar.Size                   = UDim2.new(1,-10,0,20)
TabBar.Position               = UDim2.new(0,5,0,26)
TabBar.BackgroundTransparency = 1
TabBar.ZIndex                 = 4
TabBar.Parent                 = Main

local TabLL = Instance.new("UIListLayout")
TabLL.FillDirection = Enum.FillDirection.Horizontal
TabLL.Padding       = UDim.new(0,3)
TabLL.Parent        = TabBar

---------------------------------------------------
-- INFO BAR (auto-fade)
---------------------------------------------------

local InfoBar = Instance.new("TextLabel")
InfoBar.Size                   = UDim2.new(1,0,0,14)
InfoBar.Position               = UDim2.new(0,0,1,-14)
InfoBar.BackgroundColor3       = Color3.fromRGB(245, 245, 245)
InfoBar.BackgroundTransparency = 0
InfoBar.Text                   = "welcome"
InfoBar.Font                   = Enum.Font.Gotham
InfoBar.TextScaled             = true
InfoBar.BorderSizePixel        = 0
InfoBar.ZIndex                 = 5
InfoBar.Parent                 = Main
TT(InfoBar)

local InfoStroke = Instance.new("UIStroke")
InfoStroke.Thickness       = 0.8
InfoStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
InfoStroke.Parent          = InfoBar
TS(InfoStroke)

local infoThread = nil
local function SetInfo(text)
    if infoThread then pcall(task.cancel, infoThread) end
    InfoBar.TextTransparency       = 0
    InfoBar.BackgroundTransparency = 0
    InfoBar.Text                   = text
    infoThread = task.delay(3.0, function()
        TweenService:Create(InfoBar, TweenInfo.new(0.9), {
            TextTransparency       = 1,
            BackgroundTransparency = 1,
        }):Play()
    end)
end

---------------------------------------------------
-- CONTENT AREA
---------------------------------------------------

local CA = Instance.new("Frame")
CA.Size                   = UDim2.new(1,-10,1,-63)
CA.Position               = UDim2.new(0,5,0,48)
CA.BackgroundTransparency = 1
CA.ClipsDescendants       = true
CA.ZIndex                 = 3
CA.Parent                 = Main

---------------------------------------------------
-- PAGE + BUTTON HELPERS
---------------------------------------------------

local AllPages   = {}
local TabButtons = {}
local TabStrokes = {}

local function MakePage()
    local sf = Instance.new("ScrollingFrame")
    sf.Size                   = UDim2.new(1,0,1,0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel        = 0
    sf.ScrollBarThickness     = 2
    sf.ScrollBarImageColor3   = UI_BLACK
    sf.CanvasSize             = UDim2.new(0,0,0,0)
    sf.Visible                = false
    sf.ZIndex                 = 4
    sf.Parent                 = CA

    local L = Instance.new("UIListLayout")
    L.FillDirection = Enum.FillDirection.Vertical
    L.Padding       = UDim.new(0,4)
    L.Parent        = sf

    local P = Instance.new("UIPadding")
    P.PaddingLeft   = UDim.new(0,3); P.PaddingRight  = UDim.new(0,3)
    P.PaddingTop    = UDim.new(0,3); P.PaddingBottom = UDim.new(0,3)
    P.Parent        = sf

    L:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sf.CanvasSize = UDim2.new(0,0,0, L.AbsoluteContentSize.Y + 8)
    end)

    table.insert(AllPages, sf)
    return sf
end

local function ShowPage(page)
    for _, p in ipairs(AllPages) do p.Visible = false end
    page.Visible = true
end

-- Button: RGB text, no UIStroke on text
local function MkBtn(parent, text, h, cb)
    local B = Instance.new("TextButton")
    B.Size             = UDim2.new(1,0,0,h or 25)
    B.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    B.BackgroundTransparency = 1   -- transparan, tidak ada kotak warna
    B.Text             = text
    B.TextScaled       = true
    B.Font             = Enum.Font.Gotham
    B.BorderSizePixel  = 0
    B.ZIndex           = 5
    B.Parent           = parent
    TT(B)

    -- Outline hitam saja, tidak ada background
    local bs = Instance.new("UIStroke")
    bs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    bs.Thickness    = 1
    bs.Color        = Color3.fromRGB(0, 0, 0)
    bs.Transparency = 0
    bs.Parent       = B
    TS(bs)

    B.MouseButton1Click:Connect(function()
        SFX:Click()

        -- GLOW SOROT: lingkaran cahaya abu muncul dari tengah
        -- expand keluar dan fade hilang (bukan kotak)
        local glow = Instance.new("Frame")
        glow.Size                   = UDim2.new(0, 0, 0, 0)
        glow.Position               = UDim2.new(0.5, 0, 0.5, 0)
        glow.AnchorPoint            = Vector2.new(0.5, 0.5)
        glow.BackgroundColor3       = Color3.fromRGB(180, 180, 180)
        glow.BackgroundTransparency = 0.1
        glow.BorderSizePixel        = 0
        glow.ZIndex                 = B.ZIndex + 2
        glow.Parent                 = B

        local gc = Instance.new("UICorner")
        gc.CornerRadius = UDim.new(1, 0)
        gc.Parent       = glow

        local sz = B.AbsoluteSize.X * 1.6
        TweenService:Create(glow,
            TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {
                Size                   = UDim2.new(0, sz, 0, sz),
                BackgroundTransparency = 1,
            }
        ):Play()

        game:GetService("Debris"):AddItem(glow, 0.32)

        if cb then cb() end
    end)
    return B
end

local function MkLbl(parent, text, h)
    local L = Instance.new("TextLabel")
    L.Size               = UDim2.new(1,0,0,h or 16)
    L.BackgroundTransparency = 1
    L.Text               = text
    L.Font               = Enum.Font.Gotham
    L.TextScaled         = true
    L.TextXAlignment     = Enum.TextXAlignment.Left
    L.BorderSizePixel    = 0
    L.ZIndex             = 5
    L.Parent             = parent
    TT(L)
    return L
end

local function MkSep(parent)
    local f = Instance.new("Frame")
    f.Size             = UDim2.new(1,0,0,1)
    f.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    f.BorderSizePixel  = 0
    f.ZIndex           = 5
    f.Parent           = parent
end

-- Tab: hitam, outline oranye, text RGB no stroke
local function MkTab(text, page, onSwitch)
    local B = Instance.new("TextButton")
    B.Size             = UDim2.new(0,44,1,0)
    B.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    B.BackgroundTransparency = 1
    B.Text             = text
    B.TextScaled       = true
    B.Font             = Enum.Font.Gotham
    B.BorderSizePixel  = 0
    B.ZIndex           = 5
    B.Parent           = TabBar
    TT(B)

    -- Outline tab: default hidden, hanya aktif yang keliatan
    local ts = Instance.new("UIStroke")
    ts.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ts.Thickness    = 1
    ts.Color        = Color3.fromRGB(0, 0, 0)
    ts.Transparency = 1   -- hidden by default
    ts.Parent       = B

    table.insert(TabButtons, B)
    table.insert(TabStrokes, ts)

    B.MouseButton1Click:Connect(function()
        SFX:Click()
        -- Semua tab: hilangkan outline + reset background
        for i, tb in ipairs(TabButtons) do
            TweenService:Create(tb, TweenInfo.new(0.12), {
                BackgroundTransparency = 1
            }):Play()
            TweenService:Create(TabStrokes[i], TweenInfo.new(0.12), {
                Transparency = 1
            }):Play()
        end
        -- Tab aktif: outline muncul + background sedikit gelap
        TweenService:Create(B, TweenInfo.new(0.12), {
            BackgroundTransparency = 0.75
        }):Play()
        TweenService:Create(ts, TweenInfo.new(0.12), {
            Transparency = 0
        }):Play()
        ShowPage(page)
        if onSwitch then onSwitch() end
    end)
    return B, ts
end

---------------------------------------------------
-- PAGE: MENU
---------------------------------------------------

local MenuPage = MakePage()

MkLbl(MenuPage, Credits.Title or "DANCE SYSTEM", 20)
MkLbl(MenuPage, Credits.Version or "v2.0", 12)
MkSep(MenuPage)
MkLbl(MenuPage, "select a tab above", 12)
MkSep(MenuPage)
MkLbl(MenuPage, "— credits —", 12)

for _, c in ipairs(Credits.Credits or {}) do
    MkLbl(MenuPage, c.Role .. "  ·  " .. c.Name, 13)
end
if Credits.Note and Credits.Note ~= "" then
    MkSep(MenuPage)
    MkLbl(MenuPage, Credits.Note, 12)
end

---------------------------------------------------
-- PAGE: DANCE (card per dance)
---------------------------------------------------

local DancePage    = MakePage()
local PlayingDance = nil

local function MakeDanceCard(parent, v)
    local card = Instance.new("Frame")
    card.Size             = UDim2.new(1,0,0,72)
    card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    card.BorderSizePixel  = 0
    card.ZIndex           = 5
    card.Parent           = parent

    local cs = Instance.new("UIStroke")
    cs.Thickness    = 1
    cs.Color        = UI_BLACK
    cs.Transparency = 0.55
    cs.Parent       = card
    TS(cs)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size               = UDim2.new(1,-90,0,24)
    nameLbl.Position           = UDim2.new(0,6,0,4)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text               = v.Name or "Dance"
    nameLbl.Font               = Enum.Font.Gotham
    nameLbl.TextScaled         = true
    nameLbl.TextXAlignment     = Enum.TextXAlignment.Left
    nameLbl.ZIndex             = 6
    nameLbl.Parent             = card
    TT(nameLbl)

    local descLbl = Instance.new("TextLabel")
    descLbl.Size               = UDim2.new(1,-12,0,32)
    descLbl.Position           = UDim2.new(0,6,0,28)
    descLbl.BackgroundTransparency = 1
    descLbl.Text               = v.Description or "Custom animation dance"
    descLbl.Font               = Enum.Font.Gotham
    descLbl.TextScaled         = true
    descLbl.TextXAlignment     = Enum.TextXAlignment.Left
    descLbl.TextWrapped        = true
    descLbl.ZIndex             = 6
    descLbl.Parent             = card
    TT(descLbl)

    local actBtn = Instance.new("TextButton")
    actBtn.Size             = UDim2.new(0,80,0,22)
    actBtn.Position         = UDim2.new(1,-84,0,4)
    actBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    actBtn.BackgroundTransparency = 1
    actBtn.Text             = "Activate"
    actBtn.Font             = Enum.Font.Gotham
    actBtn.TextScaled       = true
    actBtn.BorderSizePixel  = 0
    actBtn.ZIndex           = 7
    actBtn.Parent           = card
    TT(actBtn)

    local abs = Instance.new("UIStroke")
    abs.Thickness    = 1
    abs.Color        = Color3.fromRGB(0, 0, 0)
    abs.Transparency = 0
    abs.Parent       = actBtn
    TS(abs)

    actBtn.MouseButton1Click:Connect(function()
        SFX:Click()
        if PlayingDance == v then
            Core:StopDance()
            PlayingDance            = nil
            actBtn.Text             = "Activate"
            actBtn.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
            BGM:Resume()
            SetInfo("stopped  ·  bgm on")
        else
            if PlayingDance then
                for _, ch in ipairs(DancePage:GetDescendants()) do
                    if ch:IsA("TextButton") and ch.Text == "Deactivate" then
                        ch.Text             = "Activate"
                        ch.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
                    end
                end
                Core:StopDance()
            end
            Core:PlayDance(v)
            PlayingDance            = v
            actBtn.Text             = "Deactivate"
            actBtn.BackgroundColor3 = Color3.fromRGB(220, 245, 220)
            BGM:Pause()
            SetInfo("dancing: " .. v.Name .. "  ·  bgm off")
        end
    end)
end

for _, v in ipairs(Core.Dances) do
    MakeDanceCard(DancePage, v)
end

---------------------------------------------------
-- PAGE: STYLE SET
---------------------------------------------------

local StylePage = MakePage()

for _, v in ipairs(Core.StyleSets) do
    MkBtn(StylePage, v.Name, 25, function()
        Core:EquipStyle(v)
        SetInfo("style: " .. v.Name)
    end)
end

---------------------------------------------------
-- PAGE: BGM
---------------------------------------------------

local BGMPage = MakePage()
local bgmBtns = {}

MkLbl(BGMPage, "select track", 14)
MkSep(BGMPage)

local BGMList = {
    { Name="Suffering Siblings",              File=ROOT.."Assets/BGM/bgm.ogg"  },
    { Name="Suffering Siblings v3 (with vocal)", File=ROOT.."Assets/BGM/bgm2.ogg" },
}
local CurrentBGMIndex = 1

local function LoadBGMTrack(index)
    local entry = BGMList[index]
    if not entry then return end
    BGM:Stop()
    if BGM.Sound then
        pcall(function() BGM.Sound:Destroy() end)
        BGM.Sound = nil
    end
    BGM._file = entry.File
    BGM:Init()
    if not BGM.Muted then BGM:Play() end
    CurrentBGMIndex = index
end

for i, entry in ipairs(BGMList) do
    local btn = MkBtn(BGMPage,
        (i == CurrentBGMIndex and "▶  " or "    ") .. entry.Name,
        28,
        function()
            LoadBGMTrack(i)
            for j, b in ipairs(bgmBtns) do
                b.Text = (j == i and "▶  " or "    ") .. BGMList[j].Name
            end
            SetInfo("bgm: " .. entry.Name)
        end
    )
    table.insert(bgmBtns, btn)
end

MkSep(BGMPage)

local muteBtn
muteBtn = MkBtn(BGMPage, "♪  music on", 25, function()
    BGM.Muted = not BGM.Muted
    BGM:SetMute(BGM.Muted)
    muteBtn.Text = BGM.Muted and "♪  muted" or "♪  music on"
    SetInfo(BGM.Muted and "music muted" or "music on")
end)

---------------------------------------------------
-- PAGE: SETTING
---------------------------------------------------

local SettingPage = MakePage()

local sfxBtn
sfxBtn = MkBtn(SettingPage, "♦  sfx on", 25, function()
    SFX.Muted = not SFX.Muted
    SFX:SetMute(SFX.Muted)
    sfxBtn.Text = SFX.Muted and "♦  sfx muted" or "♦  sfx on"
    SetInfo(SFX.Muted and "sfx muted" or "sfx on")
end)

-- text color: fixed orange shine (no picker needed)

MkSep(SettingPage)

MkBtn(SettingPage, "↺  reset name", 25, function()
    SetInfo("restarting...")
    task.delay(0.6, function()
        UIRoot.Visible = false
        BGM:Stop()
        Intro:Play(Gui, function()
            PostIntro:Show(Gui, SFX, function()
                UIRoot.Visible = true
                BGM:Play()
                SetInfo("welcome back")
            end)
        end)
    end)
end)


---------------------------------------------------
-- PAGE: GALERI
-- Showcase semua dance dengan info lengkap
---------------------------------------------------

local GaleriPage, _ = MakePage()

---------------------------------------------------
-- GALLERY
-- Foto/gambar dari folder Assets/Gallery/
-- Format: .png / .jpg
-- Nama file = caption
---------------------------------------------------

local GALLERY_FILES = {
    { File = "gallery_1.jpg", Caption = "Gallery 1" },
    { File = "gallery_2.png", Caption = "Gallery 2" },
    { File = "gallery_3.jpg", Caption = "Gallery 3" },
    -- Tambah gambar baru: { File="nama.png", Caption="keterangan" }
}

local GALLERY_PATH = ROOT .. "Assets/Gallery/"

MkLbl(GaleriPage, "photo gallery", 14)
MkSep(GaleriPage)

for _, entry in ipairs(GALLERY_FILES) do
    local path = GALLERY_PATH .. entry.File

    -- Card foto
    local card = Instance.new("Frame")
    card.Size             = UDim2.new(1,0,0,120)
    card.BackgroundColor3 = Color3.fromRGB(252, 252, 252)
    card.BorderSizePixel  = 0
    card.ZIndex           = 5
    card.Parent           = GaleriPage

    local cs2 = Instance.new("UIStroke")
    cs2.Thickness       = 1
    cs2.Transparency    = 0.45
    cs2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    cs2.Parent          = card
    TS(cs2)

    -- ImageLabel
    local img = Instance.new("ImageLabel")
    img.Size                    = UDim2.new(1,-2,1,-22)
    img.Position                = UDim2.new(0,1,0,1)
    img.BackgroundColor3        = Color3.fromRGB(230, 230, 230)
    img.BorderSizePixel         = 0
    img.ScaleType               = Enum.ScaleType.Fit
    img.ZIndex                  = 6
    img.Parent                  = card

    -- Load gambar dari file lokal
    if isfile(path) then
        local ok, asset = pcall(getcustomasset, path)
        if ok and asset then
            img.Image = asset
            img.BackgroundTransparency = 1
        else
            img.Image = ""
            img.BackgroundTransparency = 0.5
        end
    else
        img.Image = ""
        img.BackgroundTransparency = 0.5
        -- Tampil placeholder text
        local ph = Instance.new("TextLabel")
        ph.Size = UDim2.new(1,0,1,0)
        ph.BackgroundTransparency = 1
        ph.Text = "image not found"
        ph.Font = Enum.Font.Gotham
        ph.TextScaled = true
        ph.TextColor3 = Color3.fromRGB(120, 120, 120)
        ph.ZIndex = 7
        ph.Parent = img
    end

    -- Caption bawah
    local cap = Instance.new("TextLabel")
    cap.Size               = UDim2.new(1,-4,0,18)
    cap.Position           = UDim2.new(0,2,1,-20)
    cap.BackgroundTransparency = 1
    cap.Text               = entry.Caption
    cap.Font               = Enum.Font.Gotham
    cap.TextScaled         = true
    cap.TextXAlignment     = Enum.TextXAlignment.Left
    cap.ZIndex             = 7
    cap.Parent             = card
    TT(cap)
end

if #GALLERY_FILES == 0 then
    MkLbl(GaleriPage, "no images — add files to Assets/Gallery/", 16)
end

---------------------------------------------------
-- PAGE: OTHER SCRIPTS
-- Script lain bisa di-copy langsung dari sini
---------------------------------------------------

local OtherPage, _ = MakePage()

---------------------------------------------------
-- DAFTAR SCRIPT LAIN
-- Tambah entry baru: { Name, Desc, Code }
-- Code = string script yang bisa di-copy
---------------------------------------------------

local OtherScripts = {
    {
        Name = "ShadowBHOP",
        Desc = "BHOP movement + shadow trail",
        Code = "loadfile('/storage/emulated/0/Delta/Workspace/MyDanceSystem/ShadowBHOP.lua')()",
    },
    {
        Name = "AutoIdle",
        Desc = "Force idle animation loop",
        Code = "loadfile('/storage/emulated/0/Delta/Workspace/MyDanceSystem/AutoIdle.lua')()",
    },
    {
        Name = "QuickTP",
        Desc = "Teleport to spawn point",
        Code = "local p=game:GetService('Players').LocalPlayer; p.Character.HumanoidRootPart.CFrame=CFrame.new(0,5,0)",
    },
    -- Tambah script baru:
    -- { Name="nama", Desc="deskripsi", Code="script code here" },
}

MkLbl(OtherPage, "other scripts", 14)
MkSep(OtherPage)

for _, entry in ipairs(OtherScripts) do

    local card = Instance.new("Frame")
    card.Size             = UDim2.new(1,0,0,64)
    card.BackgroundColor3 = Color3.fromRGB(252, 252, 252)
    card.BorderSizePixel  = 0
    card.ZIndex           = 5
    card.Parent           = OtherPage

    local cs3 = Instance.new("UIStroke")
    cs3.Thickness       = 1
    cs3.Transparency    = 0.45
    cs3.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    cs3.Parent          = card
    TS(cs3)

    -- Nama script
    local nLbl = Instance.new("TextLabel")
    nLbl.Size               = UDim2.new(1,-70,0,22)
    nLbl.Position           = UDim2.new(0,4,0,4)
    nLbl.BackgroundTransparency = 1
    nLbl.Text               = ">> " .. entry.Name
    nLbl.Font               = Enum.Font.Gotham
    nLbl.TextScaled         = true
    nLbl.TextXAlignment     = Enum.TextXAlignment.Left
    nLbl.ZIndex             = 6
    nLbl.Parent             = card
    TT(nLbl)

    -- Deskripsi
    local dLbl = Instance.new("TextLabel")
    dLbl.Size               = UDim2.new(1,-70,0,18)
    dLbl.Position           = UDim2.new(0,4,0,26)
    dLbl.BackgroundTransparency = 1
    dLbl.Text               = entry.Desc
    dLbl.Font               = Enum.Font.Gotham
    dLbl.TextScaled         = true
    dLbl.TextXAlignment     = Enum.TextXAlignment.Left
    dLbl.ZIndex             = 6
    dLbl.Parent             = card
    TT(dLbl)

    -- Info code preview (singkat)
    local codePrev = entry.Code:sub(1, 40) .. (entry.Code:len() > 40 and "..." or "")
    local iLbl = Instance.new("TextLabel")
    iLbl.Size               = UDim2.new(1,-70,0,14)
    iLbl.Position           = UDim2.new(0,4,0,46)
    iLbl.BackgroundTransparency = 1
    iLbl.Text               = codePrev
    iLbl.Font               = Enum.Font.Gotham
    iLbl.TextScaled         = true
    iLbl.TextXAlignment     = Enum.TextXAlignment.Left
    iLbl.TextColor3         = Color3.fromRGB(120, 120, 120)
    iLbl.ZIndex             = 6
    iLbl.Parent             = card
    -- No TT() - warna redup fixed, bukan orange shine

    -- COPY BUTTON
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size             = UDim2.new(0,58,0,40)
    copyBtn.Position         = UDim2.new(1,-62,0,12)
    copyBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    copyBtn.BackgroundTransparency = 1
    copyBtn.Text             = "copy"
    copyBtn.Font             = Enum.Font.Gotham
    copyBtn.TextScaled       = true
    copyBtn.BorderSizePixel  = 0
    copyBtn.ZIndex           = 7
    copyBtn.Parent           = card
    TT(copyBtn)

    local copySt = Instance.new("UIStroke")
    copySt.Thickness       = 1
    copySt.Color           = Color3.fromRGB(0, 0, 0)
    copySt.Transparency    = 0
    copySt.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    copySt.Parent          = copyBtn
    TS(copySt)

    local code = entry.Code  -- capture untuk closure

    copyBtn.MouseButton1Click:Connect(function()
        SFX:Click()
        -- setclipboard tersedia di executor
        pcall(function()
            setclipboard(code)
        end)
        -- Visual feedback: ganti teks sementara
        copyBtn.Text = "✓"
        TweenService:Create(copyBtn, TweenInfo.new(0.08), {
            BackgroundColor3 = Color3.fromRGB(220, 245, 220)
        }):Play()
        task.delay(1.2, function()
            copyBtn.Text = "copy"
            TweenService:Create(copyBtn, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(245, 245, 245)
            }):Play()
        end)
        SetInfo("copied: " .. entry.Name)
    end)
end

if #OtherScripts == 0 then
    MkLbl(OtherPage, "no scripts added yet", 16)
end


---------------------------------------------------
-- CREATE TABS
---------------------------------------------------

MkTab("menu",    MenuPage,    function() TitleLabel.Text = "Zechzz Dance" end)
MkTab("dance",   DancePage,   function()
    TitleLabel.Text = "dance"
    SetInfo("tap activate to play")
end)
MkTab("style",   StylePage,   function()
    TitleLabel.Text = "style set"
    SetInfo("pick a style")
end)
MkTab("bgm",     BGMPage,     function()
    TitleLabel.Text = "bgm"
    SetInfo("pick a track")
end)
MkTab("setting", SettingPage, function() TitleLabel.Text = "setting" end)
MkTab("galeri",  GaleriPage,  function()
    TitleLabel.Text = "galeri"
    SetInfo("dance gallery")
end)
MkTab("other",   OtherPage,   function()
    TitleLabel.Text = "other scripts"
    SetInfo("other scripts info")
end)

ShowPage(MenuPage)
TabButtons[1].BackgroundTransparency = 0.75   -- tab aktif pertama
TabStrokes[1].Transparency = 0                -- outline tab pertama langsung muncul

---------------------------------------------------
-- MINIMIZE
---------------------------------------------------

local Minimized = false
Min.MouseButton1Click:Connect(function()
    Minimized           = not Minimized
    TabBar.Visible      = not Minimized
    CA.Visible          = not Minimized
    InfoBar.Visible     = not Minimized
    Main.Size           = Minimized
        and UDim2.new(0,W,0,24)
        or  UDim2.new(0,W,0,H)
    Min.Text            = Minimized and "+" or "−"
end)

---------------------------------------------------
-- DRAG
---------------------------------------------------

local Dragging  = false
local DragStart, StartPos

Top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging  = true
        DragStart = input.Position
        StartPos  = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if not Dragging then return end
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - DragStart
        Main.Position = UDim2.new(
            StartPos.X.Scale, StartPos.X.Offset + d.X,
            StartPos.Y.Scale, StartPos.Y.Offset + d.Y
        )
    end
end)

---------------------------------------------------
-- RENDER LOOP
-- Orange shine = sine wave pada outline brightness
-- Text RGB cycling
-- Shimmer sweep
-- Float animation
---------------------------------------------------

local shimX  = -0.2
local floatT = 0
local shineT = 0
local baseY, baseYOff = 0.5, -(H/2)

RunService.RenderStepped:Connect(function(dt)
    shimX  = shimX   + dt * 0.36
    floatT = floatT  + dt
    shineT = shineT  + dt

    -- Float UI naik turun pelan
    if not Dragging and UIRoot.Visible then
        Main.Position = UDim2.new(
            Main.Position.X.Scale,
            Main.Position.X.Offset,
            baseY,
            baseYOff + math.sin(floatT * 0.5) * 4
        )
    end

    -- White theme: outline hitam fixed, text hitam fixed
    -- Tidak perlu sine wave untuk warna
    MainStroke.Color = UI_BLACK

    -- Semua stroke = hitam, transparency 0 (keliatan)
    for _, e in ipairs(Strokes) do
        if e.s and e.s.Parent then
            e.s.Color        = UI_BLACK
            e.s.Transparency = 0
        end
    end

    -- Text = hitam
    for _, e in ipairs(Texts) do
        if e.t and e.t.Parent then
            e.t.TextColor3 = UI_BLACK
        end
    end

    -- Shimmer sweep (putih transparan, efek kilap di atas white bg)
    if shimX > 1.22 then shimX = -0.22 end
    Shimmer.Position  = UDim2.new(shimX,        0, -0.15, 0)
    Shimmer2.Position = UDim2.new(shimX - 0.08, 0, -0.15, 0)
    Shimmer.BackgroundColor3  = Color3.fromRGB(255, 255, 255)
    Shimmer2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
end)

---------------------------------------------------
-- SHOW MAIN UI
---------------------------------------------------

local function ShowMainUI()
    UIRoot.Visible = true
    baseY          = Main.Position.Y.Scale
    baseYOff       = Main.Position.Y.Offset
    BGM:Play()
    -- Init footstep system
    FootstepModule:Init(Character)

    SetInfo("welcome  ·  bgm playing")
    print("[Main] UI ready")
end

---------------------------------------------------
-- FLOW: Intro → PostIntro → UI
---------------------------------------------------

Intro:Play(Gui, function()
    PostIntro:Show(Gui, SFX, function()
        ShowMainUI()
    end)
end)

print("[ZechzzDance] Loaded via SystemLoader")
