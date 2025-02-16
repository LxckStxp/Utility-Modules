--[[ 
    Enhanced Middle Click Utility
    Using CensuraDev UI Library
]]

local CensuraDev = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/CensuraDev.lua"))()
local UI = CensuraDev.new()

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Enhanced Particle Effects System
local function createEnhancedEffect(position, color, effectType)
    -- Main effect part
    local effect = Instance.new("Part")
    effect.Size = Vector3.new(1, 1, 1)
    effect.Position = position
    effect.Anchored = true
    effect.CanCollide = false
    effect.Transparency = 0.5
    effect.Material = Enum.Material.Neon
    effect.Color = color
    effect.Parent = workspace

    -- Primary particle emitter
    local primaryEmitter = Instance.new("ParticleEmitter")
    primaryEmitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color),
        ColorSequenceKeypoint.new(1, color:Lerp(Color3.new(1, 1, 1), 0.5))
    })
    primaryEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(0.5, 0.25),
        NumberSequenceKeypoint.new(1, 0)
    })
    primaryEmitter.Lifetime = NumberRange.new(0.5, 1)
    primaryEmitter.Rate = 50
    primaryEmitter.Speed = NumberRange.new(5, 10)
    primaryEmitter.SpreadAngle = Vector2.new(0, 180)
    primaryEmitter.Parent = effect

    -- Effect-specific enhancements
    if effectType == "teleport" then
        -- Ring effect
        local ring = Instance.new("Part")
        ring.Size = Vector3.new(2, 0.2, 2)
        ring.CFrame = CFrame.new(position)
        ring.Anchored = true
        ring.CanCollide = false
        ring.Transparency = 0
        ring.Material = Enum.Material.Neon
        ring.Color = color
        ring.Parent = workspace

        -- Ring expansion and fade
        TweenService:Create(ring, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(10, 0.2, 10),
            Transparency = 1
        }):Play()
        
        Debris:AddItem(ring, 0.5)
    elseif effectType == "delete" then
        -- Dissolve particles
        local dissolveEmitter = Instance.new("ParticleEmitter")
        dissolveEmitter.Color = ColorSequence.new(color)
        dissolveEmitter.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.2),
            NumberSequenceKeypoint.new(1, 0)
        })
        dissolveEmitter.Lifetime = NumberRange.new(0.5, 1)
        dissolveEmitter.Rate = 100
        dissolveEmitter.Speed = NumberRange.new(3, 6)
        dissolveEmitter.SpreadAngle = Vector2.new(180, 180)
        dissolveEmitter.Parent = effect
    end

    -- Main effect expansion and fade
    TweenService:Create(effect, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(5, 5, 5),
        Transparency = 1
    }):Play()

    Debris:AddItem(effect, 0.5)
end

-- Enhanced Settings Handler
local currentSetting = nil
local deletedParts = {}

-- Status Display
local statusLabel = UI:CreateButton("Select a mode to begin", function() end)

local settings = {
    Teleport = {
        color = Color3.fromRGB(0, 255, 255),
        action = function()
            local target = Mouse.Target
            if target then
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local targetPos = target.Position + Vector3.new(0, target.Size.Y/2 + 3, 0)
                    local currentPos = character.HumanoidRootPart.Position

                    -- Pre-teleport effect
                    createEnhancedEffect(currentPos, Color3.fromRGB(0, 255, 255), "teleport")
                    
                    -- Small delay for effect visibility
                    task.wait(0.1)
                    
                    -- Teleport
                    character:PivotTo(CFrame.new(targetPos))
                    
                    -- Post-teleport effect
                    createEnhancedEffect(targetPos, Color3.fromRGB(0, 255, 255), "teleport")
                    
                    -- Update status
                    statusLabel.Text = "Teleported!"
                    task.delay(1, function()
                        if currentSetting == "Teleport" then
                            statusLabel.Text = "Mode: Teleport - Ready"
                        end
                    end)
                end
            end
        end
    },
    
    ["Temporary Delete"] = {
        color = Color3.fromRGB(255, 0, 0),
        action = function()
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

                -- Delete effect
                createEnhancedEffect(target.Position, Color3.fromRGB(255, 0, 0), "delete")
                target.Parent = nil
                deletedParts[target] = properties

                -- Update status
                statusLabel.Text = "Part deleted - Restoring in 10s"

                task.delay(10, function()
                    if deletedParts[target] then
                        local newPart = Instance.new("Part")
                        for prop, value in pairs(properties) do
                            newPart[prop] = value
                        end
                        newPart.Parent = workspace
                        
                        -- Restore effect
                        createEnhancedEffect(newPart.Position, Color3.fromRGB(0, 255, 0), "delete")
                        deletedParts[target] = nil

                        -- Update status
                        if currentSetting == "Temporary Delete" then
                            statusLabel.Text = "Mode: Temporary Delete - Ready"
                        end
                    end
                end)
            end
        end
    }
}

-- Create Setting Buttons
for name, setting in pairs(settings) do
    UI:CreateButton(name, function()
        currentSetting = name
        statusLabel.Text = "Mode: " .. name .. " - Ready"
    end)
end

-- Middle Click Handler with Cooldown
local cooldown = false
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton3 and currentSetting and not cooldown then
        cooldown = true
        settings[currentSetting].action()
        task.delay(0.5, function()
            cooldown = false
        end)
    end
end)

UI:Show()
