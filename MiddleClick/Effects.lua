--[[ 
    Effects Module
    Particle and Visual Effects
--]]

local Effects = {}

function Effects.createParticleEffect(part, color)
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

function Effects.createEffect(position, color, effectType)
    local effect = Instance.new("Part")
    effect.Size = Vector3.new(1.5, 1.5, 1.5)
    effect.Position = position
    effect.Anchored = true
    effect.CanCollide = false
    effect.Transparency = 0.3
    effect.Material = Enum.Material.Neon
    effect.Color = color
    effect.Parent = workspace

    local emitter = Effects.createParticleEffect(effect, color)

    if effectType == "teleport" or effectType == "remove" then
        local ring = Instance.new("Part")
        ring.Size = Vector3.new(3, 0.3, 3)
        ring.CFrame = CFrame.new(position)
        ring.Anchored = true
        ring.CanCollide = false
        ring.Material = Enum.Material.Neon
        ring.Color = color
        ring.Parent = workspace

        MiddleClickSystem.Services.TweenService:Create(ring, TweenInfo.new(0.7), {
            Size = Vector3.new(15, 0.1, 15),
            Transparency = 1
        }):Play()
        MiddleClickSystem.Services.Debris:AddItem(ring, 0.7)
    end

    MiddleClickSystem.Services.TweenService:Create(effect, TweenInfo.new(0.7), {
        Size = Vector3.new(7, 7, 7),
        Transparency = 1
    }):Play()
    MiddleClickSystem.Services.Debris:AddItem(effect, 0.7)

    return emitter
end

return Effects
