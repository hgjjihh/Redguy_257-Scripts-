--==================================================
-- SystemLoader.lua
--==================================================

local ROOT        = "/storage/emulated/0/Delta/Workspace/MyDanceSystem/"
local GITHUB_BASE = "https://raw.githubusercontent.com/hgjjihh/Redguy_257-Scripts-/refs/heads/main/"
local MODULES_DIR = ROOT .. "Modules/"

print("[SL] Starting...")

---------------------------------------------------
-- LOAD LOCAL FILE (proper syntax)
---------------------------------------------------

local function LoadFile(path)
    local fn, err = loadfile(path)
    assert(fn, "[SL] Cannot load file: " .. tostring(path) .. " | " .. tostring(err))
    local ok, result = pcall(fn)
    assert(ok, "[SL] Error in file: " .. tostring(path) .. " | " .. tostring(result))
    return result
end

---------------------------------------------------
-- LOAD WITH CACHE
-- Sudah ada lokal → pakai lokal
-- Belum ada → download → tulis → load
---------------------------------------------------

local function LoadCached(name, url)
    local path = MODULES_DIR .. name .. ".lua"

    -- Coba load dari lokal dulu
    if isfile(path) then
        local fn, err = loadfile(path)
        if fn then
            local ok, result = pcall(fn)
            if ok then
                print("[SL] Cached:", name)
                return result
            end
            -- File error → hapus, download ulang
            warn("[SL] File error, redownloading:", name, "|", tostring(result))
        else
            warn("[SL] Parse error, redownloading:", name, "|", tostring(err))
        end
        pcall(delfile, path)
    end

    -- Download dari GitHub
    print("[SL] Downloading:", name)
    local code
    local ok1, err1 = pcall(function()
        code = game:HttpGet(url)
    end)
    assert(ok1, "[SL] HttpGet failed: " .. name .. " | " .. tostring(err1))
    assert(code and #code > 0, "[SL] Empty response: " .. name)

    -- Simpan ke lokal
    if not isfolder(MODULES_DIR) then makefolder(MODULES_DIR) end
    writefile(path, code)

    -- Jalankan
    local fn, ferr = loadstring(code)
    assert(fn, "[SL] Syntax error in downloaded: " .. name .. " | " .. tostring(ferr))
    local ok2, result = pcall(fn)
    assert(ok2, "[SL] Runtime error in downloaded: " .. name .. " | " .. tostring(result))

    print("[SL] Downloaded and cached:", name)
    return result
end

---------------------------------------------------
-- SOURCES
---------------------------------------------------

local SOURCES = {
    ModuleEngine      = GITHUB_BASE .. "ModuleEngine.lua",
    ModuleCore        = GITHUB_BASE .. "ModuleCore.lua",
    ModulesLinkLoader = GITHUB_BASE .. "ModulesLinkLoader.lua",
    ModuleContent     = GITHUB_BASE .. "ModuleContent.lua",
    ModuleIntro       = GITHUB_BASE .. "ModuleIntro.lua",
    FootstepModule    = GITHUB_BASE .. "FootstepModule.lua",
}

---------------------------------------------------
-- LOAD SEMUA
---------------------------------------------------

local ModuleEngine = LoadCached("ModuleEngine", SOURCES.ModuleEngine)
local Core         = ModuleEngine.Core
local Loader       = ModuleEngine.Loader
print("[SL] ModuleEngine OK")

local ModuleCore = LoadCached("ModuleCore", SOURCES.ModuleCore)
local BGM        = ModuleCore.BGM
local SFX        = ModuleCore.SFX
local Setting    = ModuleCore.Setting
print("[SL] ModuleCore OK")

-- ModulesLinkLoader optional — tidak crash kalau 404
local LinkLoader = { BHOP = {}, StyleSets = {} }
local _llOk, _llResult = pcall(LoadCached, "ModulesLinkLoader", SOURCES.ModulesLinkLoader)
if _llOk then
    LinkLoader = _llResult
    print("[SL] ModulesLinkLoader OK")
else
    warn("[SL] ModulesLinkLoader skipped:", tostring(_llResult):sub(1,80))
end

local ModuleContent = LoadCached("ModuleContent", SOURCES.ModuleContent)
local Dances        = ModuleContent.Dances
local StyleSets     = ModuleContent.StyleSets
local DanceInfo     = ModuleContent.DanceInfo
print("[SL] ModuleContent OK")

local ModuleIntro = LoadCached("ModuleIntro", SOURCES.ModuleIntro)
local Intro       = ModuleIntro.Intro
local PostIntro   = ModuleIntro.PostIntro
local Credits     = ModuleIntro.Credits
print("[SL] ModuleIntro OK")

-- FootstepModule optional
local FootstepModule = nil
local _fpOk, _fpResult = pcall(LoadCached, "FootstepModule", SOURCES.FootstepModule)
if _fpOk then
    FootstepModule = _fpResult
    print("[SL] FootstepModule OK")
else
    warn("[SL] FootstepModule skipped:", tostring(_fpResult):sub(1,80))
end

-- MaduleLoader (custom modules lokal)
local FootstepOk = true
local MadulePath = ROOT .. "Modules/MaduleLoader.lua"
local CustomModules = { Dances = {}, StyleSets = {} }
if isfile(MadulePath) then
    local fn, _ = loadfile(MadulePath)
    if fn then
        local ok, result = pcall(fn)
        if ok then CustomModules = result end
    end
end

---------------------------------------------------
-- MERGE
---------------------------------------------------

-- BHOP dari ModuleEngine
for _, m in ipairs(Loader:GetModules("DANCE")) do
    local found = false
    for _, d in ipairs(Dances) do
        if d == m then found = true; break end
    end
    if not found then table.insert(Dances, m) end
end

-- BHOP + StyleSets dari LinkLoader (GitHub)
for _, m in ipairs(LinkLoader.BHOP or {}) do
    table.insert(Dances, m)
end
if #LinkLoader.StyleSets > 0 then
    StyleSets = LinkLoader.StyleSets
end

-- Custom dari CustomModules/
for _, m in ipairs(CustomModules.Dances)    do table.insert(Dances,    m) end
for _, m in ipairs(CustomModules.StyleSets) do table.insert(StyleSets, m) end

Core.Dances    = Dances
Core.StyleSets = StyleSets

print("[SL] Total dances:", #Dances, "stylesets:", #StyleSets)

---------------------------------------------------
-- INIT
---------------------------------------------------

BGM:Init()
SFX:Init()

task.defer(function()
    if StyleSets and StyleSets[1] then
        Core:EquipStyle(StyleSets[1])
        print("[SL] Default style:", StyleSets[1].Name)
    end
end)

print("[SL] All OK")

---------------------------------------------------
-- RETURN
---------------------------------------------------

return {
    Core      = Core,
    Loader    = Loader,
    BGM       = BGM,
    SFX       = SFX,
    Setting   = Setting,
    Dances    = Dances,
    StyleSets = StyleSets,
    DanceInfo = DanceInfo,
    Intro     = Intro,
    PostIntro = PostIntro,
    Credits   = Credits,
    Footstep  = FootstepModule,
}
