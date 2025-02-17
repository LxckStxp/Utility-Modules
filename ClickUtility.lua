--[[ 
    Enhanced Middle Click Utility
    Version 2.0
    Using CensuraDev UI Library
--]]

-- Initialize Modules
local CensuraDev = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/Censura.lua"))()

-- Initialize Global System
getgenv().MiddleClickSystem = {
    Settings = {
        Cooldown = 0.5,
        RestoreTime = 10,
        Effects = {
            TeleportColor = Color3.fromRGB(0, 255, 255),
            DeleteColor = Color3.fromRGB(255, 0, 0),
            RestoreColor = Color3.fromRGB(0, 255, 0)
        }
    },
    State = {
        CurrentMode = nil,
        Cooldown = false,
        DeletedParts = {}
    }
}

-- Services
local Services = {
    Players = game:GetService("Players"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    Debris = game:GetService("Debris")
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
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(0.5, 0.25),
        NumberSequenceKeypoint.new(1, 0)
    })
    emitter.Lifetime = NumberRange.new(0.5, 1)
    emitter.Rate = 50
    emitter.Speed = NumberRange.new(5, 10)
    emitter.SpreadAngle = Vector2.new(0, 180)
    emitter.Parent = part
    return emitter
end

function EffectSystem.createEffect(position, color, effectType)
    -- Create base effect
    local effect = Instance.new("Part")
    effect.Size = Vector3.new(1, 1, 1)
    effect.Position = position
    effect.Anchored = true
    effect.CanCollide = false
    effect.Transparency = 0.5
    effect.Material = Enum.Material.Neon
    effect.Color = color
    effect.Parent = workspace

    -- Add primary particles
    EffectSystem.createParticleEffect(effect, color)

    -- Effect-specific additions
    if effectType == "teleport" then
        -- Create ring effect
        local ring = Instance.new("Part")
        ring.Size = Vector3.new(2, 0.2, 2)
        ring.CFrame = CFrame.new(position)
        ring.Anchored = true
        ring.CanCollide = false
        ring.Transparency = 0
        ring.Material = Enum.Material.Neon
        ring.Color = color
        ring.Parent = workspace

        -- Animate ring
        Services.TweenService:Create(ring, TweenInfo.new(0.5), {
            Size = Vector3.new(10, 0.2, 10),
            Transparency = 1
        }):Play()
        
        Services.Debris:AddItem(ring, 0.5)
    end

    -- Animate main effect
    Services.TweenService:Create(effect, TweenInfo.new(0.5), {
        Size = Vector3.new(5, 5, 5),
        Transparency = 1
    }):Play()

    Services.Debris:AddItem(effect, 0.5)
end

-- Mode Handlers
local ModeHandlers = {
    Teleport = {
        color = MiddleClickSystem.Settings.Effects.TeleportColor,
        execute = function(statusLabel)
            local target = Mouse.Target
            if target and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = target.Position + Vector3.new(0, target.Size.Y/2 + 3, 0)
                local currentPos = LocalPlayer.Character.HumanoidRootPart.Position

                EffectSystem.createEffect(currentPos, MiddleClickSystem.Settings.Effects.TeleportColor, "teleport")
                task.wait(0.1)
                LocalPlayer.Character:PivotTo(CFrame.new(targetPos))
                EffectSystem.createEffect(targetPos, MiddleClickSystem.Settings.Effects.TeleportColor, "teleport")

                statusLabel.Text = "Teleported!"
                task.delay(1, function()
                    if MiddleClickSystem.State.CurrentMode == "Teleport" then
                        statusLabel.Text = "Mode: Teleport - Ready"
                    end
                end)
            end
        end
    },
    
    ["Temporary Delete"] = {
        color = MiddleClickSystem.Settings.Effects.DeleteColor,
        execute = function(statusLabel)
            local target = Mouse.Target
            if target and not target:IsDescendantOf(LocalPlayer.Character) then
                local properties = {
                    Size = target.Size,
                    CFrame = target.CFrame,
                    Color = target.Color,
                    Material = target.Material,
                    Transparency = target.Transparency,
                    Anchored = target.Anchored,
                    CanCollide = target.CanCollide
                }

                EffectSystem.createEffect(target.Position, MiddleClickSystem.Settings.Effects.DeleteColor, "delete")
                target.Parent = nil
                MiddleClickSystem.State.DeletedParts[target] = properties

                statusLabel.Text = "Part deleted - Restoring in 10s"

                task.delay(MiddleClickSystem.Settings.RestoreTime, function()
                    if MiddleClickSystem.State.DeletedParts[target] then
                        local newPart = Instance.new("Part")
                        for prop, value in pairs(properties) do
                            newPart[prop] = value
                        end
                        newPart.Parent = workspace
                        
                        EffectSystem.createEffect(newPart.Position, MiddleClickSystem.Settings.Effects.RestoreColor, "delete")
                        MiddleClickSystem.State.DeletedParts[target] = nil

                        if MiddleClickSystem.State.CurrentMode == "Temporary Delete" then
                            statusLabel.Text = "Mode: Temporary Delete - Ready"
                        end
                    end
                end)
            end
        end
    }
}

-- Initialize UI
local function InitializeUI()
    local UI = CensuraDev.new()
    
    -- Create status label
    local statusLabel = UI:CreateButton("Select a mode to begin", function() end)

    -- Create mode buttons
    for name, handler in pairs(ModeHandlers) do
        UI:CreateButton(name, function()
            MiddleClickSystem.State.CurrentMode = name
            statusLabel.Text = "Mode: " .. name .. " - Ready"
        end)
    end

    -- Setup middle click handler
    Services.UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton3 
        and MiddleClickSystem.State.CurrentMode 
        and not MiddleClickSystem.State.Cooldown then
            MiddleClickSystem.State.Cooldown = true
            
            ModeHandlers[MiddleClickSystem.State.CurrentMode].execute(statusLabel)
            
            task.delay(MiddleClickSystem.Settings.Cooldown, function()
                MiddleClickSystem.State.Cooldown = false
            end)
        end
    end)

    UI:Show()
    return UI
end

-- Initialize the utility
local UI = InitializeUI()
