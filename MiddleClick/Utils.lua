--[[ 
    Utility Module
    Helper Functions for Middle Click Utility
    Version: 3.3
--]]

local Utils = {}

function Utils.isHumanoid(target)
    local model = target:FindFirstAncestorOfClass("Model")
    return model and model:FindFirstChildOfClass("Humanoid") ~= nil
end

function Utils.createHighlight(target, color)
    if MiddleClickSystem.State.Highlight then
        MiddleClickSystem.State.Highlight:Destroy()
    end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color or MiddleClickSystem.Settings.Effects.HighlightColor
    highlight.OutlineColor = color or MiddleClickSystem.Settings.Effects.HighlightColor
    highlight.FillTransparency, highlight.OutlineTransparency = 0.5, 0
    highlight.Parent = target
    MiddleClickSystem.State.Highlight = highlight
    return highlight
end

return Utils
