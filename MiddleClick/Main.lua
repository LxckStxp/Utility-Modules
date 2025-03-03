--[[ 
    Middle Click Utility - Main
    Version: 3.3
    Executor-Injected Entry Point for Cheat System
    Hosted on GitHub: LxckStxp/Utility-Modules/MiddleClick/
--]]

-- Base GitHub URL
local BASE_URL = "https://raw.githubusercontent.com/LxckStxp/Utility-Modules/main/MiddleClick/"

-- Load UI Library with error handling
local success, CensuraDev = pcall(loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraDev.lua")))
if not success then
    warn("Failed to load CensuraDev UI: " .. tostring(CensuraDev))
    return
end

-- Initialize global system
getgenv().MiddleClickSystem = {}

-- Load modules dynamically
local function loadModule(name)
    local url = BASE_URL .. name .. ".lua"
    local success, module = pcall(function()
        local func = loadstring(game:HttpGet(url))
        if func then
            setfenv(func, {MiddleClickSystem = getgenv().MiddleClickSystem})
            return func()
        end
    end)
    if not success then
        warn("Failed to load " .. name .. ": " .. tostring(module))
        return nil
    end
    return module
end

-- Load all modules
local Config, Effects, Modes, UI, Utils = loadModule("Config"), loadModule("Effects"), loadModule("Modes"), loadModule("UI"), loadModule("Utils")
if not (Config and Effects and Modes and UI and Utils) then
    warn("Module loading failed. Aborting.")
    return
end

-- Update MiddleClickSystem with config
getgenv().MiddleClickSystem = Config.MiddleClickSystem

-- Services
local Services = setmetatable({
    Players = game.Players,
    UserInput = game.UserInputService,
    Tween = game.TweenService,
    Debris = game.Debris,
    Run = game.RunService
}, {__index = function(_, k) return game:GetService(k) end})

local Player = Services.Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Expose to global system
MiddleClickSystem.Effects, MiddleClickSystem.Modes, MiddleClickSystem.Utils = Effects, Modes, Utils
MiddleClickSystem.Services, MiddleClickSystem.Player, MiddleClickSystem.Mouse = Services, Player, Mouse

-- Initialize UI with feedback
local function init()
    local success, ui = pcall(UI.InitializeUI)
    if success then
        print("Middle Click Utility v3.3 initialized.")
    else
        warn("UI init failed: " .. tostring(ui))
        return nil
    end
    return ui
end

local UIInstance = init()
if not UIInstance then return end

-- Cleanup on events
local function cleanup()
    MiddleClickSystem.State.ModifiedParts = {}
    if MiddleClickSystem.State.Highlight then
        MiddleClickSystem.State.Highlight:Destroy()
        MiddleClickSystem.State.Highlight = nil
    end
    MiddleClickSystem.State.Selecting, MiddleClickSystem.State.Target, MiddleClickSystem.State.Cooldown, MiddleClickSystem.State.Enabled = false, nil, false, false
    print("Utility cleaned up.")
end

Services.Players.LocalPlayer.OnTeleport:Connect(cleanup)
Services.Players.LocalPlayer.CharacterRemoving:Connect(cleanup)

-- Version info
MiddleClickSystem.Version = "3.3"
print("Running Middle Click Utility v" .. MiddleClickSystem.Version)
