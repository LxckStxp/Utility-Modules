--[[ 
    Configuration Module
    Settings and Initial State
--]]

local Config = {}

Config.MiddleClickSystem = {
    Settings = {
        Cooldown = 0.5,
        RestoreTime = 15,
        RemoveDepth = -1000,
        Effects = {
            TeleportColor = Color3.fromRGB(0, 255, 255),
            RemoveColor = Color3.fromRGB(255, 165, 0),
            RestoreColor = Color3.fromRGB(0, 255, 0),
            HighlightColor = Color3.fromRGB(255, 255, 0)
        }
    },
    State = {
        CurrentMode = nil,
        Cooldown = false,
        ModifiedParts = {},
        IsEnabled = false,
        CurrentHighlight = nil,
        IsSelecting = false,
        SelectedTarget = nil
    }
}

return Config
