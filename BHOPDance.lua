--==================================================
-- BHOPDance.lua
-- REGISTRY VERSION
--==================================================

local modules = {}

------------------------------------------------
-- ROOT
------------------------------------------------

local ROOT =
"/storage/emulated/0/Delta/Workspace/MyDanceSystem/"

local ASSETS =
    ROOT ..
    "Assets/"

------------------------------------------------
-- MODULE LOADER
------------------------------------------------

local ModuleLoader =
    loadfile(
        ROOT ..
        "Modules/ModuleLoader.lua"
    )()

------------------------------------------------
-- LOAD RBXM
------------------------------------------------

local function LoadRBXM(path)

    if not isfile(path) then

        warn(
            "Missing:",
            path
        )

        return nil,nil
    end

    local ok,model =
        pcall(function()

        return game:GetObjects(
            getcustomasset(path)
        )[1]
    end)

    if not ok or not model then

        warn(
            "Failed:",
            path
        )

        return nil,nil
    end

    local anim =
        nil

    local function Scan(obj)

        if obj:IsA(
            "KeyframeSequence"
        ) then

            anim =
                obj
        end

        for _,v in ipairs(
            obj:GetChildren()
        ) do

            Scan(v)
        end
    end

    Scan(model)

    return anim,model
end

------------------------------------------------
-- MODULE
------------------------------------------------

local m = {}

------------------------------------------------
-- INFO
------------------------------------------------

m.ModuleType =
    "DANCE"

m.Name =
    "BHOP Dance"

m.Description =
    "loop fixed bhop"

------------------------------------------------
-- VARIABLES
------------------------------------------------

local Music =
    nil

------------------------------------------------
-- INIT
------------------------------------------------

m.Init = function(character)

    ------------------------------------------------
    -- PATHS
    ------------------------------------------------

    local AnimPath =
        ASSETS ..
        "Anims/BHOP Dance.rbxm"

    local MusicPath =
        ASSETS ..
        "Sounds/BHOP Dance.mp3"

    ------------------------------------------------
    -- LOAD RBXM
    ------------------------------------------------

    local anim =
        LoadRBXM(
            AnimPath
        )

    if not anim then

        warn(
            "BHOP failed"
        )

        return
    end

    ------------------------------------------------
    -- PLAY ANIMATION
    ------------------------------------------------

    pcall(function()

        getgenv().Animator6D(
            anim,
            1,
            true
        )
    end)

    ------------------------------------------------
    -- PLAY MUSIC
    ------------------------------------------------

    if isfile(
        MusicPath
    ) then

        local ok2,asset =
            pcall(function()

            return getcustomasset(
                MusicPath
            )
        end)

        if ok2 and asset then

            Music =
                Instance.new(
                    "Sound"
                )

            Music.Name =
                "BHOP_Music"

            Music.SoundId =
                asset

            Music.Volume =
                2

            Music.Looped =
                true

            Music.Parent =
                workspace

            Music:Play()

            print(
                "BHOP music playing"
            )

        else

            warn(
                "BHOP sound failed"
            )
        end
    else

        warn(
            "BHOP sound missing"
        )
    end
end

------------------------------------------------
-- UPDATE
------------------------------------------------

m.Update = function()
    -- nothing
end

------------------------------------------------
-- DESTROY
------------------------------------------------

m.Destroy = function(character)

    ------------------------------------------------
    -- STOP MUSIC
    ------------------------------------------------

    if Music then

        Music:Stop()

        Music:Destroy()

        Music =
            nil
    end

    ------------------------------------------------
    -- RESET MOTORS
    ------------------------------------------------

    for _,v in ipairs(
        character:GetDescendants()
    ) do

        if v:IsA(
            "Motor6D"
        ) then

            v.Transform =
                CFrame.new()

            v.CurrentAngle =
                0
        end
    end
end

------------------------------------------------
-- REGISTER
------------------------------------------------

ModuleLoader:Register(
    m
)

------------------------------------------------
-- INSERT
------------------------------------------------

table.insert(
    modules,
    m
)

------------------------------------------------
-- DEBUG
------------------------------------------------

print(
    "BHOP Loaded"
)

------------------------------------------------
-- RETURN
------------------------------------------------

return modules