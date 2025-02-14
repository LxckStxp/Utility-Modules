--[[ 
    Middle Click Utility Script
    Author: Professional Roblox Developer
    Version: 1.0.0
    
    Features:
    - Destroy/Temp Destroy with effects
    - Speed/Jump boosts with particles
    - NoClip with visual feedback
    - AutoClick with customization
    - Character utilities
    - Visual feedback system
    - State management
    - Error handling
]]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- References
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Load UI Framework
local Censura = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura/main/Censura.lua"))()

-- Utility Configuration
local MiddleClickUtil = {
    CurrentMode = "Destroy",
    States = {
        NoClip = false,
        AutoClick = false,
        SpeedBoost = false,
        HighJump = false
    },
    Settings = {
        AutoClick = {
            Interval = 0.05,
            ShowVisuals = true
        },
        TempDestroy = {
            Duration = 10
        },
        Boost = {
            SpeedMultiplier = 2,
            JumpMultiplier = 2,
            Duration = 3
        }
    },
    Cache = {
        DestroyedParts = {},
        Connections = {},
        Effects = {}
    }
}

-- Effect System
local EffectSystem = {
    CreateParticles = function(position, color)
        local emitter = Instance.new("ParticleEmitter")
        emitter.Color = ColorSequence.new(color)
        emitter.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.5),
            NumberSequenceKeypoint.new(1, 0)
        })
        emitter.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        emitter.Rate = 50
        emitter.Lifetime = NumberRange.new(0.5, 1)
        emitter.Speed = NumberRange.new(5, 10)
        emitter.SpreadAngle = Vector2.new(-180, 180)
        
        return emitter
    end,
    
    CreateRing = function(position, color)
        local ring = Instance.new("Part")
        ring.Size = Vector3.new(1, 0.1, 1)
        ring.CFrame = CFrame.new(position)
        ring.Anchored = true
        ring.CanCollide = false
        ring.Transparency = 0
        ring.Material = Enum.Material.Neon
        ring.Color = color
        ring.Parent = workspace
        
        local tween = TweenService:Create(ring, TweenInfo.new(1), {
            Size = Vector3.new(10, 0.1, 10),
            Transparency = 1
        })
        
        tween:Play()
        Debris:AddItem(ring, 1)
        
        return ring
    end,
    
    CreateShatter = function(part)
        local originalCFrame = part.CFrame
        local originalSize = part.Size
        
        for i = 1, 8 do
            local fragment = Instance.new("Part")
            fragment.Size = originalSize / 2
            fragment.CFrame = originalCFrame * CFrame.new(
                math.random(-2, 2),
                math.random(-2, 2),
                math.random(-2, 2)
            )
            fragment.Anchored = true
            fragment.CanCollide = false
            fragment.Material = part.Material
            fragment.Color = part.Color
            fragment.Parent = workspace
            
            local tween = TweenService:Create(fragment, TweenInfo.new(0.5), {
                Transparency = 1,
                Size = Vector3.new(0, 0, 0),
                Orientation = Vector3.new(
                    math.random(-180, 180),
                    math.random(-180, 180),
                    math.random(-180, 180)
                )
            })
            
            tween:Play()
            Debris:AddItem(fragment, 0.5)
        end
    end
}

-- Utility Functions
local function SavePartProperties(part)
    return {
        Size = part.Size,
        CFrame = part.CFrame,
        Color = part.Color,
        Material = part.Material,
        Transparency = part.Transparency,
        Anchored = part.Anchored,
        CanCollide = part.CanCollide,
        Parent = part.Parent
    }
end

local function RestorePart(properties)
    local newPart = Instance.new("Part")
    for prop, value in pairs(properties) do
        newPart[prop] = value
    end
    EffectSystem.CreateRing(newPart.Position, Color3.fromRGB(0, 255, 0))
    return newPart
end

-- Action Functions
local Actions = {
    Destroy = {
        name = "Destroy",
        color = Color3.fromRGB(255, 0, 0),
        action = function()
            local target = Mouse.Target
            if not target then return end
            
            -- Check if target is valid
            if target:IsDescendantOf(LocalPlayer.Character) or
               target.Parent:FindFirstChild("Humanoid") then
                return
            end
            
            EffectSystem.CreateShatter(target)
            target:Destroy()
        end
    },
    
    TempDestroy = {
        name = "Temp Destroy",
        color = Color3.fromRGB(255, 128, 0),
        action = function()
            local target = Mouse.Target
            if not target then return end
            
            -- Check if target is valid
            if target:IsDescendantOf(LocalPlayer.Character) or
               target.Parent:FindFirstChild("Humanoid") then
                return
            end
            
            local properties = SavePartProperties(target)
            EffectSystem.CreateShatter(target)
            target.Parent = nil
            
            -- Store in cache
            MiddleClickUtil.Cache.DestroyedParts[target] = properties
            
            -- Restore after duration
            task.delay(MiddleClickUtil.Settings.TempDestroy.Duration, function()
                if MiddleClickUtil.Cache.DestroyedParts[target] then
                    RestorePart(properties)
                    MiddleClickUtil.Cache.DestroyedParts[target] = nil
                end
            end)
        end
    },
    
    SpeedBoost = {
        name = "Speed Boost",
        color = Color3.fromRGB(0, 255, 255),
        action = function()
            local character = LocalPlayer.Character
            if not character or MiddleClickUtil.States.SpeedBoost then return end
            
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                MiddleClickUtil.States.SpeedBoost = true
                local originalSpeed = humanoid.WalkSpeed
                
                humanoid.WalkSpeed = originalSpeed * MiddleClickUtil.Settings.Boost.SpeedMultiplier
                EffectSystem.CreateRing(character.HumanoidRootPart.Position, Color3.fromRGB(0, 255, 255))
                
                -- Create trailing effect
                local connection = RunService.Heartbeat:Connect(function()
                    if character.HumanoidRootPart then
                        EffectSystem.CreateParticles(
                            character.HumanoidRootPart.Position,
                            Color3.fromRGB(0, 255, 255)
                        )
                    end
                end)
                
                task.delay(MiddleClickUtil.Settings.Boost.Duration, function()
                    connection:Disconnect()
                    if character and humanoid then
                        humanoid.WalkSpeed = originalSpeed
                        MiddleClickUtil.States.SpeedBoost = false
                    end
                end)
            end
        end
    },
    
    HighJump = {
        name = "High Jump",
        color = Color3.fromRGB(255, 255, 0),
        action = function()
            local character = LocalPlayer.Character
            if not character or MiddleClickUtil.States.HighJump then return end
            
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                MiddleClickUtil.States.HighJump = true
                local originalJumpPower = humanoid.JumpPower
                
                humanoid.JumpPower = originalJumpPower * MiddleClickUtil.Settings.Boost.JumpMultiplier
                EffectSystem.CreateRing(character.HumanoidRootPart.Position, Color3.fromRGB(255, 255, 0))
                
                task.delay(MiddleClickUtil.Settings.Boost.Duration, function()
                    if character and humanoid then
                        humanoid.JumpPower = originalJumpPower
                        MiddleClickUtil.States.HighJump = false
                    end
                end)
            end
        end
    },
    
    NoClip = {
        name = "NoClip",
        color = Color3.fromRGB(128, 0, 255),
        action = function()
            MiddleClickUtil.States.NoClip = not MiddleClickUtil.States.NoClip
            
            if MiddleClickUtil.States.NoClip then
                local connection = RunService.Stepped:Connect(function()
                    if LocalPlayer.Character then
                        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                        
                        -- Visual effect
                        if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            EffectSystem.CreateParticles(
                                LocalPlayer.Character.HumanoidRootPart.Position,
                                Color3.fromRGB(128, 0, 255)
                            )
                        end
                    end
                end)
                
                MiddleClickUtil.Cache.Connections.NoClip = connection
            else
                if MiddleClickUtil.Cache.Connections.NoClip then
                    MiddleClickUtil.Cache.Connections.NoClip:Disconnect()
                end
            end
        end
    },
    
    AutoClick = {
        name = "AutoClick",
        color = Color3.fromRGB(0, 255, 0),
        action = function()
            MiddleClickUtil.States.AutoClick = not MiddleClickUtil.States.AutoClick
            
            if MiddleClickUtil.States.AutoClick then
                local connection = RunService.Heartbeat:Connect(function()
                    mouse1click()
                    
                    if MiddleClickUtil.Settings.AutoClick.ShowVisuals then
                        EffectSystem.CreateRing(
                            Mouse.Hit.Position,
                            Color3.fromRGB(0, 255, 0)
                        )
                    end
                    
                    task.wait(MiddleClickUtil.Settings.AutoClick.Interval)
                end)
                
                MiddleClickUtil.Cache.Connections.AutoClick = connection
            else
                if MiddleClickUtil.Cache.Connections.AutoClick then
                    MiddleClickUtil.Cache.Connections.AutoClick:Disconnect()
                end
            end
        end
    }
}

-- Create UI
local Window = Censura:CreateWindow({
    title = "Middle Click Utility",
    size = UDim2.new(0, 200, 0, 300)
})

-- Add Status Label
local StatusLabel = Window:AddButton({
    label = "Status: Ready",
    callback = function() end
})

-- Create Buttons for Each Action
for _, action in pairs(Actions) do
    local button = Window:AddButton({
        label = action.name,
        callback = function()
            MiddleClickUtil.CurrentMode = action.name
            StatusLabel.Instance.Text = "Selected: " .. action.name
        end
    })
    
    -- Update button appearance
    RunService.Heartbeat:Connect(function()
        local isActive = MiddleClickUtil.CurrentMode == action.name
        local isStateActive = MiddleClickUtil.States[action.name]
        
        button.Instance.BackgroundColor3 = 
            (isActive and isStateActive) and action.color
            or isActive and Censura.Config.Theme.Success
            or Censura.Config.Theme.Primary
    end)
end

-- Handle Middle Click
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton3 then
        local action = Actions[MiddleClickUtil.CurrentMode]
        if action then
            action.action()
        end
    end
end)

-- Cleanup
game:BindToClose(function()
    for _, connection in pairs(MiddleClickUtil.Cache.Connections) do
        if connection then
            connection:Disconnect()
        end
    end
end)
