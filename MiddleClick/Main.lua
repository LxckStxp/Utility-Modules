--[[ 
    Enhanced Middle Click Utility
    Version 3.2
    Using CensuraDev UI Library
    With Selection Phase on Hold and Reduced Modes
--]]

-- Initialize Modules
local CensuraDev = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraDev.lua"))()

-- Initialize Global System
getgenv().MiddleClickSystem = {
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

-- Effect System
local EffectSystem = {}

function EffectSystem.createParticleEffect(part, color)
    local emitter = Instance.new("ParticleEmitter")
    emitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color),
        ColorSequenceKeypoint.new(1, color:Lerp(Color3.new(1, 1, 1), 0.5))
    })
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(0.5, 0.4),
        NumberSequenceKeypoint.new(1, 0)
    })
    emitter.Lifetime = NumberRange.new(0.5, 1.5)
    emitter.Rate = 75
    emitter.Speed = NumberRange.new(8, 15)
    emitter.SpreadAngle = Vector2.new(0, 360)
    emitter.Parent = part
    return emitter
end

function EffectSystem.createEffect(position, color, effectType)
    local effect = Instance.new("Part")
    effect.Size = Vector3.new(1.5, 1.5, 1.5)
    effect.Position = position
    effect.Anchored = true
    effect.CanCollide = false
    effect.Transparency = 0.3
    effect.Material = Enum.Material.Neon
    effect.Color = color
    effect.Parent = workspace

    local emitter = EffectSystem.createParticleEffect(effect, color)

    if effectType == "teleport" or effectType == "remove" then
        local ring = Instance.new("Part")
        ring.Size = Vector3.new(3, 0.3, 3)
        ring.CFrame = CFrame.new(position)
        ring.Anchored = true
        ring.CanCollide = false
        ring.Material = Enum.Material.Neon
        ring.Color = color
        ring.Parent = workspace

        Services.TweenService:Create(ring, TweenInfo.new(0.7), {
            Size = Vector3.new(15, 0.1, 15),
            Transparency = 1
        }):Play()
        Services.Debris:AddItem(ring, 0.7)
    end

    Services.TweenService:Create(effect, TweenInfo.new(0.7), {
        Size = Vector3.new(7, 7, 7),
        Transparency = 1
    }):Play()
    Services.Debris:AddItem(effect, 0.7)

    return emitter
end

-- Utility Functions
local function isHumanoid(target)
    local model = target:FindFirstAncestorOfClass("Model")
    return model and model:FindFirstChildOfClass("Humanoid") ~= nil
end

local function createHighlight(target, color)
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

-- Mode Handlers
local ModeHandlers = {
    Teleport = {
        color = MiddleClickSystem.Settings.Effects.TeleportColor,
        execute = function(statusLabel)
            local target = MiddleClickSystem.State.SelectedTarget
            if target and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = target.Position + Vector3.new(0, target.Size.Y/2 + 5, 0)
                local currentPos = LocalPlayer.Character.HumanoidRootPart.Position

                EffectSystem.createEffect(currentPos, MiddleClickSystem.Settings.Effects.TeleportColor, "teleport")
                task.wait(0.15)
                LocalPlayer.Character:PivotTo(CFrame.new(targetPos))
                EffectSystem.createEffect(targetPos, MiddleClickSystem.Settings.Effects.TeleportColor, "teleport")

                statusLabel.Text = "Teleported to part!"
                task.delay(1.5, function()
                    if MiddleClickSystem.State.CurrentMode == "Teleport" then
                        statusLabel.Text = "Mode: Teleport - Ready"
                    end
                end)
            else
                statusLabel.Text = "Teleport failed - No target or character!"
            end
        end
    },
    
    ["Temporary Remove"] = {
        color = MiddleClickSystem.Settings.Effects.RemoveColor,
        execute = function(statusLabel)
            local target = MiddleClickSystem.State.SelectedTarget
            if target and target:IsA("BasePart") and not isHumanoid(target) and not MiddleClickSystem.State.ModifiedParts[target] then
                local original = {
                    CFrame = target.CFrame,
                    Anchored = target.Anchored
                }
                
                MiddleClickSystem.State.ModifiedParts[target] = {type = "remove", props = original}
                
                EffectSystem.createEffect(target.Position, MiddleClickSystem.Settings.Effects.RemoveColor, "remove")
                target.Anchored = true
                target.CFrame = target.CFrame + Vector3.new(0, MiddleClickSystem.Settings.RemoveDepth, 0)

                statusLabel.Text = "Part removed - Restoring in " .. MiddleClickSystem.Settings.RestoreTime .. "s"

                task.delay(MiddleClickSystem.Settings.RestoreTime, function()
                    if MiddleClickSystem.State.ModifiedParts[target] then
                        target.CFrame = original.CFrame
                        target.Anchored = original.Anchored
                        EffectSystem.createEffect(target.Position, MiddleClickSystem.Settings.Effects.RestoreColor, "remove")
                        MiddleClickSystem.State.ModifiedParts[target] = nil

                        if MiddleClickSystem.State.CurrentMode == "Temporary Remove" then
                            statusLabel.Text = "Mode: Temporary Remove - Ready"
                        end
                    end
                end)
            else
                statusLabel.Text = "Remove failed - Invalid target!"
            end
        end
    }
}

-- Initialize UI
local function InitializeUI()
    local UI = CensuraDev.new("Middle Click Utility v3.2")
    
    -- Status display
    local statusLabel = UI:CreateButton("Select a mode to begin", function() end)
    statusLabel:SetEnabled(false)
    
    -- Master toggle
    UI:CreateToggle("Enable Middle Click", false, function(state)
        MiddleClickSystem.State.IsEnabled = state
        statusLabel.Text = state and "Select a mode to begin" or "Utility Disabled"
    end)
    
    -- Mode selection
    for name, handler in pairs(ModeHandlers) do
        UI:CreateButton(name, function()
            MiddleClickSystem.State.CurrentMode = name
            statusLabel.Text = "Mode: " .. name .. " - Ready"
        end)
    end
    
    -- Additional controls
    UI:CreateSlider("Restore Time", 5, 30, MiddleClickSystem.Settings.RestoreTime, function(value)
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
    
    UI:CreateButton("Clear All Modifications", function()
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
    Services.UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton3 
        and MiddleClickSystem.State.IsEnabled 
        and MiddleClickSystem.State.CurrentMode 
        and not MiddleClickSystem.State.Cooldown then
            MiddleClickSystem.State.IsSelecting = true
            statusLabel.Text = "Mode: " .. MiddleClickSystem.State.CurrentMode .. " - Selecting..."
        end
    end)

    Services.UserInputService.InputEnded:Connect(function(input)
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
            
            MiddleClickSystem.State.SelectedTarget = Mouse.Target
            if MiddleClickSystem.State.SelectedTarget then
                ModeHandlers[MiddleClickSystem.State.CurrentMode].execute(statusLabel)
            else
                statusLabel.Text = "No target selected!"
            end
            
            task.delay(MiddleClickSystem.Settings.Cooldown, function()
                MiddleClickSystem.State.Cooldown = false
            end)
        end
    end)

    -- Highlight during selection phase
    Services.RunService.RenderStepped:Connect(function()
        if MiddleClickSystem.State.IsSelecting and MiddleClickSystem.State.CurrentMode then
            local target = Mouse.Target
            if target and target:IsA("BasePart") and not isHumanoid(target) then
                createHighlight(target, ModeHandlers[MiddleClickSystem.State.CurrentMode].color)
            elseif MiddleClickSystem.State.CurrentHighlight then
                MiddleClickSystem.State.CurrentHighlight:Destroy()
                MiddleClickSystem.State.CurrentHighlight = nil
            end
        end
    end)

    UI:Show()
    return UI
end

-- Initialize the utility
local UI = InitializeUI()

-- Safety cleanup on script end
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
    MiddleClickSystem.State.ModifiedParts = {}
    if MiddleClickSystem.State.CurrentHighlight then
        MiddleClickSystem.State.CurrentHighlight:Destroy()
        MiddleClickSystem.State.CurrentHighlight = nil
    end
    MiddleClickSystem.State.IsSelecting = false
    MiddleClickSystem.State.SelectedTarget = nil
end)
