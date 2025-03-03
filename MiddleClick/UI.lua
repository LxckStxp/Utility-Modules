--[[ 
    UI Module
    UI Initialization and Input Handling
--]]

local UI = {}

local CensuraDev = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraDev.lua"))()

function UI.InitializeUI()
    local ui = CensuraDev.new("Middle Click Utility v3.3")
    
    -- Status display
    local statusLabel = ui:CreateButton("Select a mode to begin", function() end)
    statusLabel:SetEnabled(false)
    
    -- Master toggle
    ui:CreateToggle("Enable Middle Click", false, function(state)
        MiddleClickSystem.State.IsEnabled = state
        statusLabel.Text = state and "Select a mode to begin" or "Utility Disabled"
    end)
    
    -- Mode selection
    for name, handler in pairs(MiddleClickSystem.Modes) do
        ui:CreateButton(name, function()
            MiddleClickSystem.State.CurrentMode = name
            statusLabel.Text = "Mode: " .. name .. " - Ready"
        end)
    end
    
    -- Additional controls
    ui:CreateSlider("Restore Time", 5, 30, MiddleClickSystem.Settings.RestoreTime, function(value)
        MiddleClickSystem.Settings.RestoreTime = value
        statusLabel.Text = "Restore time set to " .. value .. "s"
        task.delay(1, function()
            if MiddleClickSystem.State.CurrentMode then
                statusLabel.Text = "Mode: " .. MiddleClickSystem.State.CurrentMode .. " - Ready"
            else
                statusLabel.Text = "Select a mode to begin"
            end
        end)
    end)
    
    ui:CreateButton("Clear All Modifications", function()
        for part, data in pairs(MiddleClickSystem.State.ModifiedParts) do
            if data.type == "remove" then
                part.CFrame = data.props.CFrame
                part.Anchored = data.props.Anchored
            end
        end
        MiddleClickSystem.State.ModifiedParts = {}
        statusLabel.Text = "All modifications cleared!"
        task.delay(1, function()
            statusLabel.Text = MiddleClickSystem.State.CurrentMode and 
                "Mode: " .. MiddleClickSystem.State.CurrentMode .. " - Ready" or 
                "Select a mode to begin"
        end)
    end)

    -- Selection phase handler
    MiddleClickSystem.Services.UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton3 
        and MiddleClickSystem.State.IsEnabled 
        and MiddleClickSystem.State.CurrentMode 
        and not MiddleClickSystem.State.Cooldown then
            MiddleClickSystem.State.IsSelecting = true
            statusLabel.Text = "Mode: " .. MiddleClickSystem.State.CurrentMode .. " - Selecting..."
        end
    end)

    MiddleClickSystem.Services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton3 
        and MiddleClickSystem.State.IsEnabled 
        and MiddleClickSystem.State.CurrentMode 
        and MiddleClickSystem.State.IsSelecting then
            MiddleClickSystem.State.IsSelecting = false
            MiddleClickSystem.State.Cooldown = true
            
            if MiddleClickSystem.State.CurrentHighlight then
                MiddleClickSystem.State.CurrentHighlight:Destroy()
                MiddleClickSystem.State.CurrentHighlight = nil
            end
            
            MiddleClickSystem.State.SelectedTarget = MiddleClickSystem.Mouse.Target
            if MiddleClickSystem.State.SelectedTarget then
                MiddleClickSystem.Modes[MiddleClickSystem.State.CurrentMode].execute(statusLabel)
            else
                statusLabel.Text = "No target selected!"
            end
            
            task.delay(MiddleClickSystem.Settings.Cooldown, function()
                MiddleClickSystem.State.Cooldown = false
            end)
        end
    end)

    -- Highlight during selection phase
    MiddleClickSystem.Services.RunService.RenderStepped:Connect(function()
        if MiddleClickSystem.State.IsSelecting and MiddleClickSystem.State.CurrentMode then
            local target = MiddleClickSystem.Mouse.Target
            if target and target:IsA("BasePart") and not MiddleClickSystem.Utils.isHumanoid(target) then
                MiddleClickSystem.Utils.createHighlight(target, MiddleClickSystem.Modes[MiddleClickSystem.State.CurrentMode].color)
            elseif MiddleClickSystem.State.CurrentHighlight then
                MiddleClickSystem.State.CurrentHighlight:Destroy()
                MiddleClickSystem.State.CurrentHighlight = nil
            end
        end
    end)

    ui:Show()
    return ui
end

return UI
