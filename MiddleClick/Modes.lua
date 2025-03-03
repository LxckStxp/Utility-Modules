--[[ 
    Modes Module
    Mode Definitions and Execution
--]]

local Modes = {
    Teleport = {
        color = MiddleClickSystem.Settings.Effects.TeleportColor,
        execute = function(statusLabel)
            local target = MiddleClickSystem.State.SelectedTarget
            if target and MiddleClickSystem.LocalPlayer.Character and MiddleClickSystem.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = target.Position + Vector3.new(0, target.Size.Y/2 + 5, 0)
                local currentPos = MiddleClickSystem.LocalPlayer.Character.HumanoidRootPart.Position

                MiddleClickSystem.Effects.createEffect(currentPos, MiddleClickSystem.Settings.Effects.TeleportColor, "teleport")
                task.wait(0.15)
                MiddleClickSystem.LocalPlayer.Character:PivotTo(CFrame.new(targetPos))
                MiddleClickSystem.Effects.createEffect(targetPos, MiddleClickSystem.Settings.Effects.TeleportColor, "teleport")

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
            if target and target:IsA("BasePart") and not MiddleClickSystem.Utils.isHumanoid(target) and not MiddleClickSystem.State.ModifiedParts[target] then
                local original = {
                    CFrame = target.CFrame,
                    Anchored = target.Anchored
                }
                
                MiddleClickSystem.State.ModifiedParts[target] = {type = "remove", props = original}
                
                MiddleClickSystem.Effects.createEffect(target.Position, MiddleClickSystem.Settings.Effects.RemoveColor, "remove")
                target.Anchored = true
                target.CFrame = target.CFrame + Vector3.new(0, MiddleClickSystem.Settings.RemoveDepth, 0)

                statusLabel.Text = "Part removed - Restoring in " .. MiddleClickSystem.Settings.RestoreTime .. "s"

                task.delay(MiddleClickSystem.Settings.RestoreTime, function()
                    if MiddleClickSystem.State.ModifiedParts[target] then
                        target.CFrame = original.CFrame
                        target.Anchored = original.Anchored
                        MiddleClickSystem.Effects.createEffect(target.Position, MiddleClickSystem.Settings.Effects.RestoreColor, "remove")
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

return Modes
