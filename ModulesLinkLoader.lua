--==================================================
-- ModulesLinkLoader.lua
-- Download + cache BHOP dan StyleSet dari GitHub
-- Kalau sudah ada di lokal → skip download
--==================================================

local ROOT        = "/storage/emulated/0/Delta/Workspace/MyDanceSystem/"
local GITHUB_BASE = "https://raw.githubusercontent.com/hgjjihh/Redguy_257-Scripts-/refs/heads/main/"

---------------------------------------------------
-- FILE LIST
-- { name, githubPath, localPath }
---------------------------------------------------

local BHOP_FILES = {
    {
        Name       = "BHOPDance",
        URL        = GITHUB_BASE .. "BHOPDance.lua",
        LocalPath  = ROOT .. "Modules/BHOPDance.lua",
    },
}

local STYLESET_FILES = {
    {
        Name      = "Casual",
        URL       = GITHUB_BASE .. "StyleSets/Casual.lua",
        LocalPath = ROOT .. "Modules/StyleSets/Casual.lua",
    },
    {
        Name      = "Ninja",
        URL       = GITHUB_BASE .. "StyleSets/Ninja.lua",
        LocalPath = ROOT .. "Modules/StyleSets/Ninja.lua",
    },
    {
        Name      = "DefaulStyleSet",
        URL       = GITHUB_BASE .. "StyleSets/DefaulStyleSet.lua",
        LocalPath = ROOT .. "Modules/StyleSets/DefaulStyleSet.lua",
    },
    -- Tambah styleset baru:
    -- { Name="nama", URL=GITHUB_BASE.."StyleSets/nama.lua", LocalPath=ROOT.."Modules/StyleSets/nama.lua" },
}

---------------------------------------------------
-- ENSURE FOLDER
---------------------------------------------------

local function EnsureFolder(path)
    if not isfolder(path) then
        pcall(makefolder, path)
    end
end

---------------------------------------------------
-- LOAD CACHED
-- Sudah ada → langsung load
-- Belum ada → download → simpan → load
---------------------------------------------------

local function LoadCached(entry)
    -- Sudah ada di lokal
    if isfile(entry.LocalPath) then
        print("[LinkLoader] Cached:", entry.Name)
        local ok, result = pcall(loadfile(entry.LocalPath))
        if ok then return result end
        -- Corrupt → hapus dan redownload
        warn("[LinkLoader] Cache corrupt, redownloading:", entry.Name)
        pcall(delfile, entry.LocalPath)
    end

    -- Download dari GitHub
    print("[LinkLoader] Downloading:", entry.Name)
    local ok, result = pcall(function()
        local code = game:HttpGet(entry.URL)
        writefile(entry.LocalPath, code)
        return loadstring(code)()
    end)

    if not ok then
        warn("[LinkLoader] Failed:", entry.Name, "-", tostring(result))
        return nil
    end

    print("[LinkLoader] Downloaded:", entry.Name)
    return result
end

---------------------------------------------------
-- LOAD ALL
---------------------------------------------------

local ModulesLinkLoader = {}

-- BHOP
ModulesLinkLoader.BHOP = {}

EnsureFolder(ROOT .. "Modules")

for _, entry in ipairs(BHOP_FILES) do
    local module = LoadCached(entry)
    if module then
        -- BHOP bisa return table of dances atau single dance
        if module.ModuleType then
            table.insert(ModulesLinkLoader.BHOP, module)
        elseif type(module) == "table" then
            for _, v in ipairs(module) do
                table.insert(ModulesLinkLoader.BHOP, v)
            end
        end
    end
end

-- StyleSets
ModulesLinkLoader.StyleSets = {}

EnsureFolder(ROOT .. "Modules/StyleSets")

for _, entry in ipairs(STYLESET_FILES) do
    local module = LoadCached(entry)
    if module then
        if module.ModuleType == "STYLESET" then
            table.insert(ModulesLinkLoader.StyleSets, module)
            print("[LinkLoader] StyleSet ready:", module.Name or entry.Name)
        else
            warn("[LinkLoader] Invalid StyleSet module:", entry.Name)
        end
    end
end

print("[LinkLoader] BHOP loaded:", #ModulesLinkLoader.BHOP)
print("[LinkLoader] StyleSets loaded:", #ModulesLinkLoader.StyleSets)

---------------------------------------------------
-- RETURN
---------------------------------------------------

return ModulesLinkLoader
