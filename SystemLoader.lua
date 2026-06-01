--==================================================
-- SystemLoader.lua
-- Semua module dari GitHub (cached)
-- Custom dance/styleset dari CustomModules/ folder
--==================================================

local ROOT        = "/storage/emulated/0/Delta/Workspace/MyDanceSystem/"
local GITHUB_BASE = "https://raw.githubusercontent.com/hgjjihh/Redguy_257-Scripts-/refs/heads/main/"

print("[SystemLoader] Starting...")

---------------------------------------------------
-- SEMUA MODULE DI GITHUB
---------------------------------------------------

local SOURCES = {
    ModuleEngine      = GITHUB_BASE .. "ModuleEngine.lua",
    ModuleCore        = GITHUB_BASE .. "ModuleCore.lua",
    ModuleContent     = GITHUB_BASE .. "ModuleContent.lua",
    ModulesLinkLoader = GITHUB_BASE .. "ModulesLinkLoader.lua",
    ModuleIntro       = GITHUB_BASE .. "ModuleIntro.lua",
    FootstepModule    = GITHUB_BASE .. "FootstepModule.lua",
}

---------------------------------------------------
-- LOAD CACHED
-- Ada di lokal → langsung load
-- Belum ada → download → simpan → load
-- Corrupt → hapus → redownload
---------------------------------------------------

local function LoadCached(name, url)
    local localPath = ROOT .. "Modules/" .. name .. ".lua"

    if isfile(localPath) then
        print("[SystemLoader] Cached:", name)
        local ok, result = pcall(loadfile(localPath))
        if ok then return result end
        warn("[SystemLoader] Cache corrupt, redownloading:", name)
        pcall(delfile, localPath)
    end

    print("[SystemLoader] Downloading:", name, "...")
    local ok, result = pcall(function()
        local code = game:HttpGet(url)
        if not isfolder(ROOT .. "Modules") then
            makefolder(ROOT .. "Modules")
        end
        writefile(localPath, code)
        return loadstring(code)()
    end)

    if not ok then
        error("[SystemLoader] Failed: " .. name .. "\n" .. tostring(result))
    end

    print("[SystemLoader] Downloaded:", name)
    return result
end

---------------------------------------------------
-- MaduleLoader — LOCAL ONLY
-- Scan CustomModules/ untuk dance/styleset custom
-- Tidak di-cache dari GitHub, selalu lokal
---------------------------------------------------

local function LoadMaduleLoader()
    local path = ROOT .. "Modules/MaduleLoader.lua"
    if not isfile(path) then
        warn("[SystemLoader] MaduleLoader.lua not found, skipping custom modules")
        return { Dances = {}, StyleSets = {} }
    end
    local ok, result = pcall(loadfile(path))
    if not ok then
        warn("[SystemLoader] MaduleLoader failed:", tostring(result))
        return { Dances = {}, StyleSets = {} }
    end
    return result
end

---------------------------------------------------
-- LOAD SEMUA
---------------------------------------------------

-- 1. ModuleEngine
local ModuleEngine = LoadCached("ModuleEngine", SOURCES.ModuleEngine)
local Core         = ModuleEngine.Core
local Loader       = ModuleEngine.Loader
print("[SystemLoader] ModuleEngine OK")

-- 2. ModuleCore (BGM + SFX + Setting)
local ModuleCore = LoadCached("ModuleCore", SOURCES.ModuleCore)
local BGM        = ModuleCore.BGM
local SFX        = ModuleCore.SFX
local Setting    = ModuleCore.Setting
print("[SystemLoader] ModuleCore OK")

-- 3. ModulesLinkLoader (BHOP + StyleSets dari GitHub)
local LinkLoader = LoadCached("ModulesLinkLoader", SOURCES.ModulesLinkLoader)
print("[SystemLoader] ModulesLinkLoader OK")

-- 4. ModuleContent (dance list core, dance info)
local ModuleContent = LoadCached("ModuleContent", SOURCES.ModuleContent)
local Dances        = ModuleContent.Dances
local StyleSets     = ModuleContent.StyleSets
local DanceInfo     = ModuleContent.DanceInfo
print("[SystemLoader] ModuleContent OK")

-- 5. ModuleIntro (Intro + PostIntro + Credits)
local ModuleIntro = LoadCached("ModuleIntro", SOURCES.ModuleIntro)
local Intro       = ModuleIntro.Intro
local PostIntro   = ModuleIntro.PostIntro
local Credits     = ModuleIntro.Credits
print("[SystemLoader] ModuleIntro OK")

-- 6. FootstepModule
local FootstepModule = LoadCached("FootstepModule", SOURCES.FootstepModule)
print("[SystemLoader] FootstepModule OK")

-- 7. MaduleLoader (custom modules dari folder lokal)
local CustomModules = LoadMaduleLoader()
print("[SystemLoader] MaduleLoader OK")

---------------------------------------------------
-- MERGE SEMUA KE CORE
---------------------------------------------------

-- Merge BHOP dari ModuleEngine (inline)
for _, m in ipairs(Loader:GetModules("DANCE")) do
    local found = false
    for _, d in ipairs(Dances) do
        if d == m then found = true; break end
    end
    if not found then table.insert(Dances, m) end
end

-- Merge BHOP dari LinkLoader (GitHub)
for _, m in ipairs(LinkLoader.BHOP or {}) do
    local found = false
    for _, d in ipairs(Dances) do
        if d == m then found = true; break end
    end
    if not found then table.insert(Dances, m) end
end

-- Merge custom dances dari CustomModules/
for _, m in ipairs(CustomModules.Dances) do
    table.insert(Dances, m)
end

-- StyleSets: GitHub dulu, lalu custom
if #LinkLoader.StyleSets > 0 then
    StyleSets = LinkLoader.StyleSets
end
for _, m in ipairs(CustomModules.StyleSets) do
    table.insert(StyleSets, m)
end

Core.Dances    = Dances
Core.StyleSets = StyleSets

print("[SystemLoader] Total dances:", #Dances,
      "| stylesets:", #StyleSets,
      "| custom:", #CustomModules.Dances + #CustomModules.StyleSets)

---------------------------------------------------
-- Init audio
---------------------------------------------------

BGM:Init()
SFX:Init()

---------------------------------------------------
-- Default StyleSet
---------------------------------------------------

task.defer(function()
    if StyleSets and StyleSets[1] then
        Core:EquipStyle(StyleSets[1])
        print("[SystemLoader] Default style:", StyleSets[1].Name)
    end
end)

---------------------------------------------------
-- RETURN
---------------------------------------------------

print("[SystemLoader] All modules loaded OK")

return {
    Core         = Core,
    Loader       = Loader,
    BGM          = BGM,
    SFX          = SFX,
    Setting      = Setting,
    Dances       = Dances,
    StyleSets    = StyleSets,
    DanceInfo    = DanceInfo,
    Intro        = Intro,
    PostIntro    = PostIntro,
    Credits      = Credits,
    Footstep     = FootstepModule,
}
