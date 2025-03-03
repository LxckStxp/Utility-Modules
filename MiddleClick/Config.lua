--[[ 
    Configuration Module
    Settings and State for Middle Click Utility
    Version: 3.3
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
        Mode = nil, -- Renamed CurrentMode to Mode for brevity
        Cooldown = false,
        ModifiedParts = {},
        Enabled = false, -- Renamed IsEnabled to Enabled for brevity
        Highlight = nil, -- Renamed CurrentHighlight for brevity
        Selecting = false, -- Renamed IsSelecting for brevity
        Target = nil -- Renamed SelectedTarget for brevity
    }
}

return Config
