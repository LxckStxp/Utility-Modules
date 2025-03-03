--[[ 
    Effects Module
    Dynamic and Visual Effects for Middle Click Utility
    Version: 3.3
--]]

local Effects = {}

-- Advanced particle emitter with customizable style and intensity
local function createParticleEmitter(part, color, intensity, style)
    local emitter = Instance.new("ParticleEmitter")
    emitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color),
        ColorSequenceKeypoint.new(0.4, color:Lerp(Color3.new(1, 1, 1), 0.6)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
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

-- Main effect function with dynamic target scaling and color
function Effects.createEffect(position, color, effectType, target, customScale)
    local Services = MiddleClickSystem.Services
    local TweenService, Debris = Services.TweenService, Services.Debris

    -- Determine dynamic scale and color from target
    local targetSize = (target and target:IsA("BasePart")) and target.Size or Vector3.new(1, 1, 1)
    local targetColor = (target and target:IsA("BasePart")) and target.Color or color
    local scale = customScale or (math.max(targetSize.X, targetSize.Y, targetSize.Z) / 2)

    -- Core effect: Pulsing orb
    local core = Instance.new("Part")
    core.Shape = Enum.PartType.Ball
    core.Size = Vector3.new(2.5, 2.5, 2.5) * scale
    core.Position = position
    core.Anchored = true
    core.CanCollide = false
    core.Transparency = 0.1
    core.Material = Enum.Material.ForceField
    core.Color = targetColor
    core.Parent = workspace

    local coreEmitter = createParticleEmitter(core, targetColor, 1.8 * scale, "burst")
    TweenService:Create(core, TweenInfo.new(0.9, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
        Size = Vector3.new(10, 10, 10) * scale,
        Transparency = 1
    }):Play()
    Debris:AddItem(core, 0.9)

    -- Aura effect
    local aura = Instance.new("Part")
    aura.Shape = Enum.PartType.Ball
    aura.Size = Vector3.new(5, 5, 5) * scale
    aura.Position = position
    aura.Anchored = true
    aura.CanCollide = false
    aura.Transparency = 0.6
    aura.Material = Enum.Material.Neon
    aura.Color = targetColor:Lerp(Color3.new(1, 1, 1), 0.3)
    aura.Parent = workspace

    TweenService:Create(aura, TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = Vector3.new(15, 15, 15) * scale,
        Transparency = 1
    }):Play()
    Debris:AddItem(aura, 0.7)

    -- Effect-specific animations
    if effectType == "teleport" then
        -- Dual beams
        local beamUp = Instance.new("Part")
        beamUp.Size = Vector3.new(0.8, 12, 0.8) * scale
        beamUp.CFrame = CFrame.new(position) * CFrame.Angles(math.rad(90), 0, 0)
        beamUp.Anchored, beamUp.CanCollide = true, false
        beamUp.Material, beamUp.Color, beamUp.Transparency = Enum.Material.Neon, targetColor, 0.3
        beamUp.Parent = workspace

        TweenService:Create(beanUp, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            Size = Vector3.new(0.3, 20, 0.3) * scale,
            Position = position + Vector3.new(0, 10 * scale, 0),
            Transparency = 1
        }):Play()
        Debris:AddItem(beamUp, 0.5)

        local beamDown = beamUp:Clone()
        beamDown.CFrame = CFrame.new(position) * CFrame.Angles(math.rad(-90), 0, 0)
        beamDown.Parent = workspace
        TweenService:Create(beamDown, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            Size = Vector3.new(0.3, 20, 0.3) * scale,
            Position = position - Vector3.new(0, 10 * scale, 0),
            Transparency = 1
        }):Play()
        Debris:AddItem(beamDown, 0.5)

        -- Orbiting rings
        for i = 1, 2 do
            local orbit = Instance.new("Part")
            orbit.Size = Vector3.new(5, 0.2, 5) * scale
            orbit.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(90 * i), 0)
            orbit.Anchored, orbit.CanCollide = true, false
            orbit.Material, orbit.Color, orbit.Transparency = Enum.Material.Neon, targetColor, 0
            orbit.Parent = workspace

            TweenService:Create(orbit, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Size = Vector3.new(14, 0.1, 14) * scale,
                CFrame = orbit.CFrame * CFrame.Angles(0, math.rad(360 * i), 0),
                Transparency = 1
            }):Play()
            Debris:AddItem(orbit, 0.8)
        end

    elseif effectType == "remove" then
        -- Implosion vortex
        local vortex = Instance.new("Part")
        vortex.Size = Vector3.new(8, 0.4, 8) * scale
        vortex.CFrame = CFrame.new(position)
        vortex.Anchored, vortex.CanCollide = true, false
        vortex.Material, vortex.Color, vortex.Transparency = Enum.Material.Neon, targetColor, 0.4
        vortex.Parent = workspace

        TweenService:Create(vortex, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = Vector3.new(1, 0.1, 1) * scale,
            CFrame = vortex.CFrame * CFrame.Angles(0, math.rad(270), 0),
            Transparency = 1
        }):Play()
        Debris:AddItem(vortex, 0.6)

        -- Collapsing shards
        for i = 1, 4 do
            local shard = Instance.new("Part")
            shard.Size = Vector3.new(1, 1, 1) * scale
            shard.CFrame = CFrame.new(position + Vector3.new(math.cos(i * math.pi/2) * 5 * scale, 0, math.sin(i * math.pi/2) * 5 * scale))
            shard.Anchored, shard.CanCollide = true, false
            shard.Material, shard.Color, shard.Transparency = Enum.Material.Neon, targetColor, 0
            shard.Parent = workspace

            TweenService:Create(shard, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = position,
                Size = Vector3.new(0.5, 0.5, 0.5) * scale,
                Transparency = 1
            }):Play()
            Debris:AddItem(shard, 0.5)
        end

        -- Secondary burst
        local burst = Instance.new("Part")
        burst.Size = Vector3.new(1.5, 1.5, 1.5) * scale
        burst.Position = position
        burst.Anchored, burst.CanCollide = true, false
        burst.Material, burst.Color, burst.Transparency = Enum.Material.ForceField, targetColor, 0.2
        burst.Parent = workspace

        createParticleEmitter(burst, targetColor, 1 * scale, "burst")
        TweenService:Create(burst, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
            Size = Vector3.new(6, 6, 6) * scale,
            Transparency = 1
        }):Play()
        Debris:AddItem(burst, 0.4)

    elseif effectType == "restore" then
        -- Rising spiral
        local spiral = Instance.new("Part")
        spiral.Size = Vector3.new(4, 0.3, 4) * scale
        spiral.Position = position - Vector3.new(0, 6 * scale, 0)
        spiral.Anchored, spiral.CanCollide = true, false
        spiral.Material, spiral.Color, spiral.Transparency = Enum.Material.Neon, targetColor, 0.5
        spiral.Parent = workspace

        TweenService:Create(spiral, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            Position = position + Vector3.new(0, 3 * scale, 0),
            Size = Vector3.new(8, 0.1, 8) * scale,
            CFrame = spiral.CFrame * CFrame.Angles(0, math.rad(540), 0),
            Transparency = 1
        }):Play()
        Debris:AddItem(spiral, 1)

        -- Glowing pulse
        local pulse = Instance.new("Part")
        pulse.Shape = Enum.PartType.Ball
        pulse.Size = Vector3.new(3, 3, 3) * scale
        pulse.Position = position
        pulse.Anchored, pulse.CanCollide = true, false
        pulse.Material, pulse.Color, pulse.Transparency = Enum.Material.ForceField, targetColor, 0.4
        pulse.Parent = workspace

        TweenService:Create(pulse, TweenInfo.new(0.8, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
            Size = Vector3.new(7, 7, 7) * scale,
            Transparency = 1
        }):Play()
        Debris:AddItem(pulse, 0.8)

        -- Particle flourish
        local flourish = Instance.new("Part")
        flourish.Size = Vector3.new(1, 1, 1) * scale
        flourish.Position = position + Vector3.new(0, 2 * scale, 0)
        flourish.Anchored, flourish.CanCollide = true, false
        flourish.Material, flourish.Color, flourish.Transparency = Enum.Material.Neon, targetColor, 0
        flourish.Parent = workspace

        createParticleEmitter(flourish, targetColor, 1.2 * scale, "burst")
        TweenService:Create(flourish, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(4, 4, 4) * scale,
            Transparency = 1
        }):Play()
        Debris:AddItem(flourish, 0.6)
    end

    return coreEmitter
end

return Effects
