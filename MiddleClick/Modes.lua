--[[ 
    Modes Module
    Mode Logic for Middle Click Utility
    Version: 3.3
--]]

local Modes = {}

-- Access MiddleClickSystem
local MCS = getfenv(1).MiddleClickSystem or getgenv().MiddleClickSystem
if not MCS then error("MiddleClickSystem not found.") return end

-- Ensure State exists
MCS.State = MCS.State or {}

Modes.Teleport = {
    color = MCS.Settings.Effects.TeleportColor,
    execute = function(status)
        if not status or type(status.Text) ~= "string" then warn("Invalid status for Teleport.") return end

        local target = MCS.State.Target
        local char = MCS.Player.Character
        if not (target and char and char.HumanoidRootPart) then
            status.Text = "Teleport failed - No target or character!"
            return
        end

        local pos = target.Position + Vector3.new(0, target.Size.Y/2 + 5)
        local startPos = char.HumanoidRootPart.Position

        MCS.Effects.createEffect(startPos, MCS.Settings.Effects.TeleportColor, "teleport", char.HumanoidRootPart)
        task.wait(0.15)
        char:PivotTo(CFrame.new(pos))
        MCS.Effects.createEffect(pos, MCS.Settings.Effects.TeleportColor, "teleport", target)

        status.Text = "Teleported to target!"
        task.delay(1.5, function()
            if MCS.State.Mode == "Teleport" then status.Text = "Mode: Teleport - Ready" end
        end)
    end
}

Modes["Temporary Remove"] = {
    color = MCS.Settings.Effects.RemoveColor,
    execute = function(status)
        if not status or type(status.Text) ~= "string" then warn("Invalid status for Remove.") return end

        local target = MCS.State.Target
        if not (target and target:IsA("BasePart") and not MCS.Utils.isHumanoid(target) and not MCS.State.ModifiedParts[target]) then
            status.Text = "Remove failed - Invalid target or already modified!"
            return
        end

        local original = {CFrame = target.CFrame, Anchored = target.Anchored}
        MCS.State.ModifiedParts[target] = {type = "remove", props = original}

        MCS.Effects.createEffect(target.Position, MCS.Settings.Effects.RemoveColor, "remove", target)
        target.Anchored, target.CFrame = true, target.CFrame + Vector3.new(0, MCS.Settings.RemoveDepth, 0)

        status.Text = "Wall removed - Restoring in " .. MCS.Settings.RestoreTime .. "s"
        task.delay(MCS.Settings.RestoreTime, function()
            if MCS.State.ModifiedParts[target] then
                target.CFrame, target.Anchored = original.CFrame, original.Anchored
                MCS.Effects.createEffect(target.Position, MCS.Settings.Effects.RestoreColor, "restore", target)
                MCS.State.ModifiedParts[target] = nil
                if MCS.State.Mode == "Temporary Remove" then status.Text = "Mode: Temporary Remove - Ready" end
            end
        end)
    end
}

return Modes
