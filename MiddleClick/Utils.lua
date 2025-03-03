--[[ 
    Utility Module
    Helper Functions
--]]

local Utils = {}

function Utils.isHumanoid(target)
    local model = target:FindFirstAncestorOfClass("Model")
    return model and model:FindFirstChildOfClass("Humanoid") ~= nil
end

function Utils.createHighlight(target, color)
    if MiddleClickSystem.State.CurrentHighlight then
        MiddleClickSystem.State.CurrentHighlight:Destroy()
    end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = target
    MiddleClickSystem.State.CurrentHighlight = highlight
    return highlight
end

return Utils
