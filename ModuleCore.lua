--==================================================
-- ModuleCore.lua
-- Gabungan: BGM + SFX + Setting
-- Usage di Main.lua:
--   local ModuleCore = loadfile(ROOT.."Modules/ModuleCore.lua")()
--   local BGM     = ModuleCore.BGM
--   local SFX     = ModuleCore.SFX
--   local Setting = ModuleCore.Setting
--==================================================

local ROOT =
    "/storage/emulated/0/Delta/Workspace/MyDanceSystem/"

--==================================================
-- BGM
--==================================================

local BGM = {}

BGM.Muted   = false
BGM.Volume  = 0.6
BGM.Sound   = nil
BGM.Paused  = false
BGM._file   = ROOT .. "Assets/BGM/bgm.ogg"

function BGM:SetFile(path)
    self._file = path
end

function BGM:Init()
    if self.Sound then
        pcall(function() self.Sound:Destroy() end)
        self.Sound = nil
    end

    if not isfile(self._file) then
        warn("[BGM] File not found:", self._file)
        return false
    end

    local ok, asset = pcall(getcustomasset, self._file)
    if not ok or not asset then
        warn("[BGM] Failed to load:", asset)
        return false
    end

    local s        = Instance.new("Sound")
    s.Name         = "DanceSystemBGM"
    s.SoundId      = asset
    s.Volume       = self.Muted and 0 or self.Volume
    s.Looped       = true
    s.Parent       = workspace
    self.Sound     = s

    print("[BGM] Loaded:", self._file)
    return true
end

function BGM:Play()
    if not self.Sound then
        local ok = self:Init()
        if not ok then return end
    end
    if self.Muted then return end
    self.Paused = false
    self.Sound:Play()
end

function BGM:Pause()
    if not self.Sound then return end
    self.Paused = true
    self.Sound:Pause()
end

function BGM:Resume()
    if not self.Sound then return end
    if self.Muted then return end
    self.Paused = false
    self.Sound:Resume()
end

function BGM:Stop()
    if self.Sound then
        self.Sound:Stop()
    end
end

function BGM:SetMute(muted)
    self.Muted = muted
    if not self.Sound then return end
    if muted then
        self.Sound:Pause()
    elseif not self.Paused then
        self.Sound:Resume()
    end
end

function BGM:SetVolume(vol)
    self.Volume = vol
    if self.Sound and not self.Muted then
        self.Sound.Volume = vol
    end
end

-- Ganti track langsung (untuk BGM tab)
function BGM:SwitchTrack(path)
    local wasPlaying = self.Sound and self.Sound.Playing
    self:Stop()
    if self.Sound then
        pcall(function() self.Sound:Destroy() end)
        self.Sound = nil
    end
    self._file = path
    local ok = self:Init()
    if ok and wasPlaying and not self.Muted and not self.Paused then
        self.Sound:Play()
    end
end

--==================================================
-- SFX
--==================================================

local SFX = {}

SFX.Sound  = nil
SFX.Muted  = false
SFX.Volume = 2
SFX._file  = ROOT .. "Assets/SFX/click.ogg"

function SFX:Init()
    if self.Sound then
        pcall(function() self.Sound:Destroy() end)
        self.Sound = nil
    end

    if not isfile(self._file) then
        warn("[SFX] File not found:", self._file)
        return false
    end

    local ok, asset = pcall(getcustomasset, self._file)
    if not ok or not asset then
        warn("[SFX] Failed:", asset)
        return false
    end

    local s    = Instance.new("Sound")
    s.Name     = "DanceSystemSFX"
    s.SoundId  = asset
    s.Volume   = self.Volume
    s.Looped   = false
    s.Parent   = workspace
    self.Sound = s

    print("[SFX] Loaded OK")
    return true
end

function SFX:Click()
    if self.Muted then return end
    if not self.Sound then return end
    self.Sound:Stop()
    self.Sound:Play()
end

function SFX:SetMute(muted)
    self.Muted = muted
end

function SFX:SetVolume(vol)
    self.Volume = vol
    if self.Sound then
        self.Sound.Volume = vol
    end
end

--==================================================
-- SETTING
--==================================================

local Setting = {}

Setting.ColorPresets = {
    { Name="Cyan",   Color=Color3.fromRGB(0,   200, 255) },
    { Name="Pink",   Color=Color3.fromRGB(255,  80, 180) },
    { Name="Lime",   Color=Color3.fromRGB(80,  255, 120) },
    { Name="Gold",   Color=Color3.fromRGB(255, 200,   0) },
    { Name="Violet", Color=Color3.fromRGB(180,  80, 255) },
    { Name="White",  Color=Color3.fromRGB(230, 230, 255) },
    { Name="RGB",    Color=nil },
}

Setting.OutlineMode  = "RGB"
Setting.OutlineColor = nil   -- nil = full rainbow
Setting.Muted        = false

function Setting:SetPreset(name)
    for _, p in ipairs(self.ColorPresets) do
        if p.Name == name then
            self.OutlineMode  = p.Name
            self.OutlineColor = p.Color
            return true
        end
    end
    return false
end

--==================================================
-- RETURN SEMUA TIGA
--==================================================

return {
    BGM     = BGM,
    SFX     = SFX,
    Setting = Setting,
}
