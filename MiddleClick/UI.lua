--[[ 
    UI Module
    User Interface for Middle Click Utility
    Version: 3.3
--]]

local UI = {}

local CensuraDev = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraDev.lua"))()

function UI.InitializeUI()
    local ui = CensuraDev.new("Middle Click Utility v3.3")
    local status = ui:CreateButton("Select a mode", function() end):SetEnabled(false)
    
    -- Toggle utility
    ui:CreateToggle("Enable", false, function(state)
        MiddleClickSystem.State.Enabled = state
        status.Text = state and "Select a mode" or "Utility Disabled"
    end)
    
    -- Mode buttons
    for name, mode in pairs(MiddleClickSystem.Modes) do
        ui:CreateButton(name, function()
            MiddleClickSystem.State.Mode = name
            status.Text = "Mode: " .. name .. " - Ready"
        end)
    end
    
    -- Settings
    ui:CreateSlider("Restore Time", 5, 30, MiddleClickSystem.Settings.RestoreTime, function(value)
        MiddleClickSystem.Settings.RestoreTime = value
        status.Text = "Restore: " .. value .. "s"
        task.delay(1, function()
            if MiddleClickSystem.State.Mode then status.Text = "Mode: " .. MiddleClickSystem.State.Mode .. " - Ready" end
        end)
    end)
    
    ui:CreateButton("Clear Mods", function()
        for part, data in pairs(MiddleClickSystem.State.ModifiedParts) do
            if data.type == "remove" then
                part.CFrame, part.Anchored = data.props.CFrame, data.props.Anchored
            end
        end
        MiddleClickSystem.State.ModifiedParts = {}
        status.Text = "Mods cleared!"
        task.delay(1, function()
            if MiddleClickSystem.State.Mode then status.Text = "Mode: " .. MiddleClickSystem.State.Mode .. " - Ready" end
        end)
    end)

    -- Input handling
    MiddleClickSystem.Services.UserInput.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton3 and 
           MiddleClickSystem.State.Enabled and 
           MiddleClickSystem.State.Mode and 
           not MiddleClickSystem.State.Cooldown then
            MiddleClickSystem.State.Selecting = true
            status.Text = "Mode: " .. MiddleClickSystem.State.Mode .. " - Selecting..."
        end
    end)

    MiddleClickSystem.Services.UserInput.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton3 and 
           MiddleClickSystem.State.Enabled and 
           MiddleClickSystem.State.Mode and 
           MiddleClickSystem.State.Selecting then
            MiddleClickSystem.State.Selecting = false
            MiddleClickSystem.State.Cooldown = true
            
            if MiddleClickSystem.State.Highlight then
                MiddleClickSystem.State.Highlight:Destroy()
                MiddleClickSystem.State.Highlight = nil
            end
            
            MiddleClickSystem.State.Target = MiddleClickSystem.Mouse.Target
            if MiddleClickSystem.State.Target then
                MiddleClickSystem.Modes[MiddleClickSystem.State.Mode].execute(status)
            else
                status.Text = "No target!"
            end
            
            task.delay(MiddleClickSystem.Settings.Cooldown, function()
                MiddleClickSystem.State.Cooldown = false
            end)
        end
    end)

    -- Highlight during selection
    MiddleClickSystem.Services.Run.RenderStepped:Connect(function()
        if MiddleClickSystem.State.Selecting and MiddleClickSystem.State.Mode then
            local target = MiddleClickSystem.Mouse.Target
            if target and target:IsA("BasePart") and not MiddleClickSystem.Utils.isHumanoid(target) then
                MiddleClickSystem.Utils.createHighlight(target, MiddleClickSystem.Modes[MiddleClickSystem.State.Mode].color)
            elseif MiddleClickSystem.State.Highlight then
                MiddleClickSystem.State.Highlight:Destroy()
                MiddleClickSystem.State.Highlight = nil
            end
        end
    end)

    ui:Show()
    return ui
end

return UI
