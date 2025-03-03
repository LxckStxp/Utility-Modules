--[[ 
    Enhanced Middle Click Utility - Main
    Version 3.3
    Modular Entry Point for Cheat Utility System
--]]

-- Load UI Library
local success, CensuraDev = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraDev.lua"))()
end)
if not success then
    warn("Failed to load CensuraDev UI Library!")
    return
end

-- Initialize Modules
local Config = require(script.Parent.Config)
local Effects = require(script.Parent.Effects)
local Modes = require(script.Parent.Modes)
local UI = require(script.Parent.UI)
local Utils = require(script.Parent.Utils)

-- Initialize Global System
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

-- Safety Cleanup on Teleport or Script Termination
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

-- Ensure cleanup on script end (if applicable)
game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
    cleanup()
end)

-- Version Check (Optional Debugging)
if MiddleClickSystem then
    MiddleClickSystem.Version = "3.3"
end
