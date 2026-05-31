--==================================================
-- SystemLoader.lua
-- Master loader — load semua 4 module sekaligus
-- Usage di Main.lua:
--   local System = loadfile(ROOT.."Modules/SystemLoader.lua")()
--   local Core      = System.Core
--   local BGM       = System.BGM
--   local SFX       = System.SFX
--   local Setting   = System.Setting
--   local Dances    = System.Dances
--   local StyleSets = System.StyleSets
--   local DanceInfo = System.DanceInfo
--   local Loader    = System.Loader
--   local Intro     = System.Intro
--   local PostIntro = System.PostIntro
--   local Credits   = System.Credits
--==================================================

local ROOT = "/storage/emulated/0/Delta/Workspace/MyDanceSystem/"

print("[SystemLoader] Starting...")

---------------------------------------------------
-- LOAD helper (pcall wrapper biar gak crash total)
---------------------------------------------------

local function Load(path)
    if not isfile(path) then
        error("[SystemLoader] File not found: " .. path)
    end
    local ok, result = pcall(function()
        return loadfile(path)()
    end)
    if not ok then
        error("[SystemLoader] Failed loading " .. path .. "\n" .. tostring(result))
    end
    return result
end

---------------------------------------------------
-- 1. ModuleEngine  (Loader + Core + BHOP)
---------------------------------------------------

local ModuleEngine = Load(ROOT .. "Modules/ModuleEngine.lua")
local Core         = ModuleEngine.Core
local Loader       = ModuleEngine.Loader

print("[SystemLoader] ModuleEngine OK")

---------------------------------------------------
-- 2. ModuleCore  (BGM + SFX + Setting)
---------------------------------------------------

local ModuleCore = Load(ROOT .. "Modules/ModuleCore.lua")
local BGM        = ModuleCore.BGM
local SFX        = ModuleCore.SFX
local Setting    = ModuleCore.Setting

print("[SystemLoader] ModuleCore OK")

---------------------------------------------------
-- 3. ModuleContent  (Dances + StyleSets + DanceInfo)
---------------------------------------------------

local ModuleContent = Load(ROOT .. "Modules/ModuleContent.lua")
local Dances        = ModuleContent.Dances
local StyleSets     = ModuleContent.StyleSets
local DanceInfo     = ModuleContent.DanceInfo

-- Tambahkan BHOP dari ModuleEngine ke Dances
-- (BHOP sudah di-register di Loader, tinggal masuk table)
for _, m in ipairs(Loader:GetModules("DANCE")) do
    local found = false
    for _, d in ipairs(Dances) do
        if d == m then found = true; break end
    end
    if not found then
        table.insert(Dances, m)
    end
end

-- Sambungkan ke Core
Core.Dances    = Dances
Core.StyleSets = StyleSets

print("[SystemLoader] ModuleContent OK —",
    #Dances, "dances,", #StyleSets, "stylesets")

---------------------------------------------------
-- 4. ModuleIntro  (Intro + PostIntro + Credits)
---------------------------------------------------

local ModuleIntro = Load(ROOT .. "Modules/ModuleIntro.lua")
local Intro       = ModuleIntro.Intro
local PostIntro   = ModuleIntro.PostIntro
local Credits     = ModuleIntro.Credits

print("[SystemLoader] ModuleIntro OK")

---------------------------------------------------
-- Init audio
---------------------------------------------------

BGM:Init()
SFX:Init()

---------------------------------------------------
-- Default StyleSet (equip otomatis saat load)
---------------------------------------------------

task.defer(function()
    if StyleSets and StyleSets[1] then
        Core:EquipStyle(StyleSets[1])
        print("[SystemLoader] Default style:", StyleSets[1].Name)
    end
end)

---------------------------------------------------
-- RETURN SEMUA
---------------------------------------------------

print("[SystemLoader] All modules loaded OK")

return {
    -- Engine
    Core    = Core,
    Loader  = Loader,

    -- Audio & Settings
    BGM     = BGM,
    SFX     = SFX,
    Setting = Setting,

    -- Content
    Dances    = Dances,
    StyleSets = StyleSets,
    DanceInfo = DanceInfo,

    -- Intro flow
    Intro     = Intro,
    PostIntro = PostIntro,
    Credits   = Credits,
}
