--[[ 
    Effects Module
    Sophisticated Particle and Visual Effects with Dynamic Target Matching
--]]

local Effects = {}

-- Advanced particle emitter with gradient and motion complexity
function Effects.createParticleEffect(part, color, intensity, style)
    local emitter = Instance.new("ParticleEmitter")
    emitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color), -- Start with target or mode color
        ColorSequenceKeypoint.new(0.4, color:Lerp(Color3.new(1, 1, 1), 0.6)), -- Brighten midway
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)) -- Fade to white
    })
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1.2 * intensity),
        NumberSequenceKeypoint.new(0.5, 0.8 * intensity),
        NumberSequenceKeypoint.new(1, 0)
    })
    emitter.Lifetime = NumberRange.new(0.6, 1.8)
    emitter.Rate = 120
    emitter.Speed = NumberRange.new(12, 25)
    emitter.SpreadAngle = style == "burst" and Vector2.new(-60, 60) or Vector2.new(-30, 30)
    emitter.Rotation = NumberRange.new(0, 360)
    emitter.RotSpeed = NumberRange.new(-150, 150)
    emitter.Acceleration = Vector3.new(0, -5, 0)
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.9, 0.2),
        NumberSequenceKeypoint.new(1, 1)
    })
    emitter.Parent = part
    return emitter
end

-- Main effect function with dynamic size and color based on target
function Effects.createEffect(position, color, effectType, target)
    local TweenService = MiddleClickSystem.Services.TweenService
    local Debris = MiddleClickSystem.Services.Debris

    -- Determine dynamic scale and color from target
    local targetSize = target and target:IsA("BasePart") and target.Size or Vector3.new(1, 1, 1)
    local targetColor = target and target:IsA("BasePart") and target.Color or color -- Fallback to mode color
    local scaleFactor = math.max(targetSize.X, targetSize.Y, targetSize.Z) / 2 -- Base scale on largest dimension

    -- Core effect: Pulsing orb with glow
    local core = Instance.new("Part")
    core.Shape = Enum.PartType.Ball
    core.Size = Vector3.new(2.5, 2.5, 2.5) * scaleFactor
    core.Position = position
    core.Anchored = true
    core.CanCollide = false
    core.Transparency = 0.1
    core.Material = Enum.Material.ForceField
    core.Color = targetColor
    core.Parent = workspace

    local coreEmitter = Effects.createParticleEffect(core, targetColor, 1.8 * scaleFactor, "burst")
    local coreTween = TweenService:Create(core, TweenInfo.new(0.9, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
        Size = Vector3.new(10, 10, 10) * scaleFactor,
        Transparency = 1
    })
    coreTween:Play()
    Debris:AddItem(core, 0.9)

    -- Shared glow aura
    local aura = Instance.new("Part")
    aura.Shape = Enum.PartType.Ball
    aura.Size = Vector3.new(5, 5, 5) * scaleFactor
    aura.Position = position
    aura.Anchored = true
    aura.CanCollide = false
    aura.Transparency = 0.6
    aura.Material = Enum.Material.Neon
    aura.Color = targetColor:Lerp(Color3.new(1, 1, 1), 0.3)
    aura.Parent = workspace

    TweenService:Create(aura, TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = Vector3.new(15, 15, 15) * scaleFactor,
        Transparency = 1
    }):Play()
    Debris:AddItem(aura, 0.7)

    -- Effect-specific animations
    if effectType == "teleport" then
        -- Teleport: Dual beams, orbiting rings
        local beamUp = Instance.new("Part")
        beamUp.Size = Vector3.new(0.8, 12, 0.8) * scaleFactor
        beamUp.CFrame = CFrame.new(position) * CFrame.Angles(math.rad(90), 0, 0)
        beamUp.Anchored = true
        beamUp.CanCollide = false
        beamUp.Material = Enum.Material.Neon
        beamUp.Color = targetColor
        beamUp.Transparency = 0.3
        beamUp.Parent = workspace

        TweenService:Create(beamUp, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            Size = Vector3.new(0.3, 20, 0.3) * scaleFactor,
            Position = position + Vector3.new(0, 10 * scaleFactor, 0),
            Transparency = 1
        }):Play()
        Debris:AddItem(beamUp, 0.5)

        local beamDown = beamUp:Clone()
        beamDown.CFrame = CFrame.new(position) * CFrame.Angles(math.rad(-90), 0, 0)
        beamDown.Parent = workspace
        TweenService:Create(beamDown, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            Size = Vector3.new(0.3, 20, 0.3) * scaleFactor,
            Position = position - Vector3.new(0, 10 * scaleFactor, 0),
            Transparency = 1
        }):Play()
        Debris:AddItem(beamDown, 0.5)

        -- Orbiting rings
        for i = 1, 2 do
            local orbit = Instance.new("Part")
            orbit.Size = Vector3.new(5, 0.2, 5) * scaleFactor
            orbit.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(90 * i), 0)
            orbit.Anchored = true
            orbit.CanCollide = false
            orbit.Material = Enum.Material.Neon
            orbit.Color = targetColor
            orbit.Parent = workspace

            TweenService:Create(orbit, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Size = Vector3.new(14, 0.1, 14) * scaleFactor,
                CFrame = orbit.CFrame * CFrame.Angles(0, math.rad(360 * i), 0),
                Transparency = 1
            }):Play()
            Debris:AddItem(orbit, 0.8)
        end

    elseif effectType == "remove" then
        -- Remove: Implosion vortex, collapsing shards, and burst
        local vortex = Instance.new("Part")
        vortex.Size = Vector3.new(8, 0.4, 8) * scaleFactor
        vortex.CFrame = CFrame.new(position)
        vortex.Anchored = true
        vortex.CanCollide = false
        vortex.Material = Enum.Material.Neon
        vortex.Color = targetColor
        vortex.Transparency = 0.4
        vortex.Parent = workspace

        TweenService:Create(vortex, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = Vector3.new(1, 0.1, 1) * scaleFactor,
            CFrame = vortex.CFrame * CFrame.Angles(0, math.rad(270), 0),
            Transparency = 1
        }):Play()
        Debris:AddItem(vortex, 0.6)

        -- Shards collapsing inward
        for i = 1, 4 do
            local shard = Instance.new("Part")
            shard.Size = Vector3.new(1, 1, 1) * scaleFactor
            shard.CFrame = CFrame.new(position + Vector3.new(math.cos(i * math.pi/2) * 5 * scaleFactor, 0, math.sin(i * math.pi/2) * 5 * scaleFactor))
            shard.Anchored = true
            shard.CanCollide = false
            shard.Material = Enum.Material.Neon
            shard.Color = targetColor
            shard.Parent = workspace

            TweenService:Create(shard, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = position,
                Size = Vector3.new(0.5, 0.5, 0.5) * scaleFactor,
                Transparency = 1
            }):Play()
            Debris:AddItem(shard, 0.5)
        end

        -- Secondary burst
        local burst = Instance.new("Part")
        burst.Size = Vector3.new(1.5, 1.5, 1.5) * scaleFactor
        burst.Position = position
        burst.Anchored = true
        burst.CanCollide = false
        burst.Transparency = 0.2
        burst.Material = Enum.Material.ForceField
        burst.Color = targetColor
        burst.Parent = workspace

        Effects.createParticleEffect(burst, targetColor, 1 * scaleFactor, "burst")
        TweenService:Create(burst, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            Size = Vector3.new(6, 6, 6) * scaleFactor,
            Transparency = 1
        }):Play()
        Debris:AddItem(burst, 0.4)

    elseif effectType == "restore" then
        -- Restore: Rising spiral, glowing pulse, and particle flourish
        local spiral = Instance.new("Part")
        spiral.Size = Vector3.new(4, 0.3, 4) * scaleFactor
        spiral.Position = position - Vector3.new(0, 6 * scaleFactor, 0)
        spiral.Anchored = true
        spiral.CanCollide = false
        spiral.Material = Enum.Material.Neon
        spiral.Color = targetColor
        spiral.Transparency = 0.5
        spiral.Parent = workspace

        TweenService:Create(spiral, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            Position = position + Vector3.new(0, 3 * scaleFactor, 0),
            Size = Vector3.new(8, 0.1, 8) * scaleFactor,
            CFrame = spiral.CFrame * CFrame.Angles(0, math.rad(540), 0),
            Transparency = 1
        }):Play()
        Debris:AddItem(spiral, 1)

        -- Glowing pulse
        local pulse = Instance.new("Part")
        pulse.Shape = Enum.PartType.Ball
        pulse.Size = Vector3.new(3, 3, 3) * scaleFactor
        pulse.Position = position
        pulse.Anchored = true
        pulse.CanCollide = false
        pulse.Material = Enum.Material.ForceField
        pulse.Color = targetColor
        pulse.Transparency = 0.4
        pulse.Parent = workspace

        TweenService:Create(pulse, TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
            Size = Vector3.new(7, 7, 7) * scaleFactor,
            Transparency = 1
        }):Play()
        Debris:AddItem(pulse, 0.8)

        -- Particle flourish
        local flourish = Instance.new("Part")
        flourish.Size = Vector3.new(1, 1, 1) * scaleFactor
        flourish.Position = position + Vector3.new(0, 2 * scaleFactor, 0)
        flourish.Anchored = true
        flourish.CanCollide = false
        flourish.Material = Enum.Material.Neon
        flourish.Color = targetColor
        flourish.Parent = workspace

        Effects.createParticleEffect(flourish, targetColor, 1.2 * scaleFactor, "burst")
        TweenService:Create(flourish, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(4, 4, 4) * scaleFactor,
            Transparency = 1
        }):Play()
        Debris:AddItem(flourish, 0.6)
    end

    return coreEmitter
end

return Effects
