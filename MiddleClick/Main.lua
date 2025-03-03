--[[ 
    Enhanced Middle Click Utility - Main
    Version 3.3
    Executor-Injected Entry Point for Cheat Utility System
    Hosted on GitHub: LxckStxp/Utility-Modules/MiddleClick/
--]]

-- Base GitHub URL for module loading
local BASE_URL = "https://raw.githubusercontent.com/LxckStxp/Utility-Modules/main/MiddleClick/"

-- Load UI Library
local success, CensuraDev = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraDev.lua"))()
end)
if not success then
    warn("Failed to load CensuraDev UI Library!")
    return
end

-- Initialize Global System (before loading modules)
getgenv().MiddleClickSystem = {}

-- Dynamic Module Loader
local function loadModule(moduleName, env)
    local url = BASE_URL .. moduleName .. ".lua"
    local success, funcOrError = pcall(function()
        return loadstring(game:HttpGet(url))
    end)
    
    if not success then
        warn("Failed to load module " .. moduleName .. ": " .. tostring(funcOrError))
        return nil
    end
    
    -- Ensure funcOrError is a function before calling setfenv
    if type(funcOrError) ~= "function" then
        warn("Module " .. moduleName .. " did not return a function: " .. tostring(funcOrError))
        return nil
    end
    
    -- Set environment if provided
    if env then
        setfenv(funcOrError, env)
    end
    
    -- Execute the loaded function and return its result
    local success, module = pcall(funcOrError)
    if not success then
        warn("Failed to execute module " .. moduleName .. ": " .. tostring(module))
        return nil
    end
    return module
end

-- Load Modules with MiddleClickSystem in their environment
local env = getfenv(1)
env.MiddleClickSystem = getgenv().MiddleClickSystem -- Ensure MiddleClickSystem is available

local Config = loadModule("Config", env)
local Effects = loadModule("Effects", env)
local Modes = loadModule("Modes", env)
local UI = loadModule("UI", env)
local Utils = loadModule("Utils", env)

-- Check for module loading failures
if not (Config and Effects and Modes and UI and Utils) then
    warn("One or more modules failed to load. Aborting initialization.")
    return
end

-- Update MiddleClickSystem with Config data
getgenv().MiddleClickSystem = Config.MiddleClickSystem

-- Services
local Services = {
    Players = game:GetService("Players"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    Debris = game:GetService("Debris"),
    RunService = game:GetService("RunService")
}

local LocalPlayer = Services.Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Expose Modules and Services to Global Scope
MiddleClickSystem.Effects = Effects
MiddleClickSystem.Modes = Modes
MiddleClickSystem.Utils = Utils
MiddleClickSystem.Services = Services
MiddleClickSystem.LocalPlayer = LocalPlayer
MiddleClickSystem.Mouse = Mouse

-- Initialization Function with Feedback
local function initializeUtility()
    local uiInstance
    local success, err = pcall(function()
        uiInstance = UI.InitializeUI()
    end)
    
    if success then
        print("Middle Click Utility v3.3 initialized successfully!")
    else
        warn("Failed to initialize UI: " .. tostring(err))
    end
    
    return uiInstance
end

-- Initialize the Utility
local UIInstance = initializeUtility()
if not UIInstance then
    warn("Utility initialization failed. Check logs for details.")
    return
end

-- Safety Cleanup on Teleport or Character Removal
local function cleanup()
    MiddleClickSystem.State.ModifiedParts = {}
    if MiddleClickSystem.State.CurrentHighlight then
        MiddleClickSystem.State.CurrentHighlight:Destroy()
        MiddleClickSystem.State.CurrentHighlight = nil
    end
    MiddleClickSystem.State.IsSelecting = false
    MiddleClickSystem.State.SelectedTarget = nil
    MiddleClickSystem.State.Cooldown = false
    MiddleClickSystem.State.IsEnabled = false
    print("Middle Click Utility cleaned up due to teleport or termination.")
end

Services.Players.LocalPlayer.OnTeleport:Connect(cleanup)
Services.Players.LocalPlayer.CharacterRemoving:Connect(cleanup)

-- Version and Debug Info
MiddleClickSystem.Version = "3.3"
print("Running Middle Click Utility v" .. MiddleClickSystem.Version .. " via executor.")
