--[[ 
    Effects Module
    Enhanced Particle and Visual Effects
--]]

local Effects = {}

-- Utility function for particle emitter creation with modern flair
function Effects.createParticleEffect(part, color, intensity)
    local emitter = Instance.new("ParticleEmitter")
    emitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color),
        ColorSequenceKeypoint.new(0.5, color:Lerp(Color3.new(1, 1, 1), 0.3)), -- Subtle fade
        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)) -- Bright white finish
    })
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1 * intensity), -- Larger initial size
        NumberSequenceKeypoint.new(0.3, 0.6 * intensity),
        NumberSequenceKeypoint.new(1, 0)
    })
    emitter.Lifetime = NumberRange.new(0.8, 2) -- Longer lifetime for smoother fade
    emitter.Rate = 100 -- Increased rate for density
    emitter.Speed = NumberRange.new(10, 20)
    emitter.SpreadAngle = Vector2.new(-45, 45) -- Controlled spread for directionality
    emitter.Rotation = NumberRange.new(0, 360) -- Random rotation for variety
    emitter.RotSpeed = NumberRange.new(-100, 100) -- Spin particles
    emitter.Parent = part
    return emitter
end

-- Main effect creation function with enhanced animations
function Effects.createEffect(position, color, effectType)
    local TweenService = MiddleClickSystem.Services.TweenService
    local Debris = MiddleClickSystem.Services.Debris

    -- Core effect part (central burst)
    local effect = Instance.new("Part")
    effect.Shape = Enum.PartType.Ball -- Spherical for modern look
    effect.Size = Vector3.new(2, 2, 2)
    effect.Position = position
    effect.Anchored = true
    effect.CanCollide = false
    effect.Transparency = 0.2
    effect.Material = Enum.Material.ForceField -- Sleek, glowing look
    effect.Color = color
    effect.Parent = workspace

    -- Particle emitter for extra flair
    local emitter = Effects.createParticleEffect(effect, color, 1.5)

    -- Core animation (expand and fade with easing)
    local coreTween = TweenService:Create(effect, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(8, 8, 8),
        Transparency = 1
    })
    coreTween:Play()
    Debris:AddItem(effect, 0.8)

    -- Effect-specific enhancements
    if effectType == "teleport" then
        -- Teleport: Add a vertical beam and swirling ring
        local beam = Instance.new("Part")
        beam.Size = Vector3.new(0.5, 10, 0.5)
        beam.CFrame = CFrame.new(position) * CFrame.Angles(math.rad(90), 0, 0)
        beam.Anchored = true
        beam.CanCollide = false
        beam.Material = Enum.Material.Neon
        beam.Color = color
        beam.Transparency = 0.4
        beam.Parent = workspace

        TweenService:Create(beam, TweenInfo.new(0.6, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
            Size = Vector3.new(0.2, 15, 0.2),
            Transparency = 1
        }):Play()
        Debris:AddItem(beam, 0.6)

        local swirl = Instance.new("Part")
        swirl.Size = Vector3.new(4, 0.2, 4)
        swirl.CFrame = CFrame.new(position)
        swirl.Anchored = true
        swirl.CanCollide = false
        swirl.Material = Enum.Material.Neon
        swirl.Color = color
        swirl.Parent = workspace

        local swirlTween = TweenService:Create(swirl, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            Size = Vector3.new(12, 0.1, 12),
            CFrame = swirl.CFrame * CFrame.Angles(0, math.rad(180), 0), -- Rotate 180 degrees
            Transparency = 1
        })
        swirlTween:Play()
        Debris:AddItem(swirl, 0.7)

    elseif effectType == "remove" then
        -- Remove: Add a collapsing ring and burst effect
        local collapseRing = Instance.new("Part")
        collapseRing.Size = Vector3.new(10, 0.3, 10)
        collapseRing.CFrame = CFrame.new(position)
        collapseRing.Anchored = true
        collapseRing.CanCollide = false
        collapseRing.Material = Enum.Material.Neon
        collapseRing.Color = color
        collapseRing.Transparency = 0.5
        collapseRing.Parent = workspace

        TweenService:Create(collapseRing, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = Vector3.new(1, 0.1, 1),
            Transparency = 1
        }):Play()
        Debris:AddItem(collapseRing, 0.5)

        -- Add a secondary burst of smaller particles
        local burst = Instance.new("Part")
        burst.Size = Vector3.new(1, 1, 1)
        burst.Position = position
        burst.Anchored = true
        burst.CanCollide = false
        burst.Transparency = 0.3
        burst.Material = Enum.Material.Neon
        burst.Color = color
        burst.Parent = workspace

        Effects.createParticleEffect(burst, color, 0.8) -- Smaller, faster particles
        TweenService:Create(burst, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(5, 5, 5),
            Transparency = 1
        }):Play()
        Debris:AddItem(burst, 0.4)
    end

    -- Restore effect (triggered elsewhere but defined here for consistency)
    if effectType == "restore" then
        local rise = Instance.new("Part")
        rise.Size = Vector3.new(3, 3, 3)
        rise.Position = position - Vector3.new(0, 5, 0) -- Start below
        rise.Anchored = true
        rise.CanCollide = false
        rise.Material = Enum.Material.ForceField
        rise.Color = color
        rise.Transparency = 0.6
        rise.Parent = workspace

        TweenService:Create(rise, TweenInfo.new(0.9, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {
            Position = position + Vector3.new(0, 2, 0), -- Rise and overshoot
            Size = Vector3.new(6, 6, 6),
            Transparency = 1
        }):Play()
        Debris:AddItem(rise, 0.9)
    end

    return emitter
end

return Effects
