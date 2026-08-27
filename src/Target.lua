-- Experiment 17 | Private MM2 modular v7 | Target / teleport / bookmarks
-- Semantic feature module. Loaded by init.lua into one shared runtime environment.

TargetMainChoice = nil
BookmarkChoice = nil
BookmarkNameValue = "Bookmark"
function SaveReturnPosition()
local root = GetRoot(LP)
if root then
State.LastReturnCFrame = root.CFrame
return true
end
return false
end
function TeleportToSelectedTarget(mode)
local target = FindPlayer(State.TargetPlayerName)
local targetRoot = GetRoot(target)
local root = GetRoot(LP)
if not target or not targetRoot or not root then
Notify("Target Teleport", "Selected target is unavailable", "Warning", 3, "Target")
return false
end
State.LastReturnCFrame = root.CFrame
local targetCF
if mode == "Behind" then
local position = (targetRoot.CFrame * CFrame.new(0, 0, 3.5)).Position
targetCF = CFrame.lookAt(position, targetRoot.Position, Vector3.yAxis)
elseif mode == "Front" then
local position = (targetRoot.CFrame * CFrame.new(0, 0, -3.5)).Position
targetCF = CFrame.lookAt(position, targetRoot.Position, Vector3.yAxis)
elseif mode == "Above" then
local position = targetRoot.Position + Vector3.new(0, State.TargetTeleportHeight, 0)
targetCF = CFrame.lookAt(position, targetRoot.Position, Vector3.yAxis)
else
targetCF = targetRoot.CFrame
end
root.CFrame = targetCF
root.AssemblyLinearVelocity = Vector3.zero
root.AssemblyAngularVelocity = Vector3.zero
return true
end
function ReturnToSavedPosition()
local root = GetRoot(LP)
if not root or not State.LastReturnCFrame then
Notify("Return Position", "No saved return position", "Warning")
return false
end
root.CFrame = State.LastReturnCFrame
root.AssemblyLinearVelocity = Vector3.zero
root.AssemblyAngularVelocity = Vector3.zero
return true
end
function GetBookmarkNames()
local names = {"None"}
for name in pairs(State.PositionBookmarks) do
names[#names + 1] = name
end
table.sort(names, function(a, b)
if a == "None" then return true end
if b == "None" then return false end
if a == "Spawn" then return true end
if b == "Spawn" then return false end
return string.lower(a) < string.lower(b)
end)
return names
end
function RefreshBookmarkDropdown()
if BookmarkChoice and BookmarkChoice.SetValues then
BookmarkChoice:SetValues(GetBookmarkNames(), true)
State.SelectedBookmark = BookmarkChoice:Get()
end
end
function SaveBookmark(name, cframe)
name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
if name == "" or name == "None" then
State.BookmarkCounter += 1
name = "Bookmark " .. tostring(State.BookmarkCounter)
end
cframe = cframe or (GetRoot(LP) and GetRoot(LP).CFrame)
if not cframe then return false end
State.PositionBookmarks[name] = cframe
RefreshBookmarkDropdown()
return name
end
function TeleportToBookmark(name)
local cframe = State.PositionBookmarks[name]
local root = GetRoot(LP)
if not cframe or not root then
Notify("Bookmark", "Bookmark is unavailable", "Warning")
return false
end
State.LastReturnCFrame = root.CFrame
root.CFrame = cframe
root.AssemblyLinearVelocity = Vector3.zero
root.AssemblyAngularVelocity = Vector3.zero
return true
end
function ApplyMovementPreset(name)
State.MovementPreset = name
local presets = {
Normal = {Walk = 16, Jump = 50, Fly = 50},
Fast = {Walk = 40, Jump = 90, Fly = 100},
Insane = {Walk = 120, Jump = 180, Fly = 220},
}
local preset = presets[name]
if not preset then return end
State.WalkSpeedValue = preset.Walk
State.JumpPowerValue = preset.Jump
State.FlySpeed = preset.Fly
if Controls.WalkSpeedValue and Controls.WalkSpeedValue.Set then
Controls.WalkSpeedValue:Set(preset.Walk, true)
end
if Controls.JumpPowerValue and Controls.JumpPowerValue.Set then
Controls.JumpPowerValue:Set(preset.Jump, true)
end
if Controls.FlySpeedControl and Controls.FlySpeedControl.Set then
Controls.FlySpeedControl:Set(preset.Fly, true)
end
end
function ApplyESPPreset(name)
State.ESPPreset = name
local presets = {
Minimal = {"DisplayName", "Role", "Distance", "Offscreen Arrows"},
Full = {
"Highlight", "DisplayName", "Role", "Health Text", "Health Bar",
"Distance", "Weapon", "2D Box", "Offscreen Arrows"
},
Performance = {"Highlight", "DisplayName", "Role", "Distance"},
["Role Only"] = {"Highlight", "Role", "Offscreen Arrows"},
}
local values = presets[name]
if not values or not Controls.ESPElements then return end
Controls.ESPElements:Set(values)
end
function ApplyMobilePerformanceProfile()
State.MobilePerformanceProfile = true
State.ESPUpdateRate = "10 Hz"
State.WorldUpdateRate = "1 Hz"
State.CoinLimit = 40
State.CoinNearestCount = 20
State.ESPSkeleton = false
State.ESPPlayerTrailHistory = false
State.ESPRoleTrail = false
State.HeatmapESP = false
State.ESPRoundedBox = false
State.AdaptivePerformance = true
State.AdaptiveFPSMin = 35
if Controls.ESPUpdateRate and Controls.ESPUpdateRate.Set then Controls.ESPUpdateRate:Set("10 Hz", true) end
if Controls.WorldUpdateRate and Controls.WorldUpdateRate.Set then Controls.WorldUpdateRate:Set("1 Hz", true) end
if Controls.CoinLimitControl and Controls.CoinLimitControl.Set then Controls.CoinLimitControl:Set(40, true) end
if Controls.Skeleton and Controls.Skeleton.Set then Controls.Skeleton:Set(false) end
if Controls.PlayerTrailHistory and Controls.PlayerTrailHistory.Set then Controls.PlayerTrailHistory:Set(false) end
if Controls.RoleTrail and Controls.RoleTrail.Set then Controls.RoleTrail:Set(false) end
if Controls.Heatmap and Controls.Heatmap.Set then Controls.Heatmap:Set(false) end
if Controls.RoundedBox and Controls.RoundedBox.Set then Controls.RoundedBox:Set(false) end
if Controls.AdaptivePerformance and Controls.AdaptivePerformance.Set then Controls.AdaptivePerformance:Set(true) end
Notify("Performance", "Mobile performance profile applied", "Success", 3, "Performance")
end
function ApplyScreenshotMode(enabled)
State.ScreenshotMode = enabled == true
Overlay.Visible = not State.ScreenshotMode
HUDRoot.Visible = not State.ScreenshotMode
if Library.Root and Library.Root:IsA("ScreenGui") then
Library.Root.Enabled = not State.ScreenshotMode
end
if TargetTracerDrawing and State.ScreenshotMode then
TargetTracerDrawing.Visible = false
end
if State.ScreenshotMode then
CleanupGunESP()
CleanupCoins()
ClearHeatmap()
pcall(function()
Library:SetMenuVisible(false)
end)
end
end
Connect(RunService.RenderStepped, function()
Camera = Workspace.CurrentCamera or Camera
if not Camera then return end
local target = FindPlayer(State.TargetPlayerName)
local root = GetRoot(target)
local humanoid = GetHumanoid(target)
TargetHUD.Visible = State.TargetLockHUD
and not State.MinimalHUD
and not State.ScreenshotMode
and target ~= nil
and root ~= nil
if TargetHUD.Visible and target and root and humanoid then
local localRoot = GetRoot(LP)
local distance = localRoot and (root.Position - localRoot.Position).Magnitude or 0
local maxHealth = math.max(tonumber(humanoid.MaxHealth) or 100, 1)
local health = math.clamp(tonumber(humanoid.Health) or 0, 0, maxHealth)
TargetHUDText.Text = string.format(
"%s\nRole: %s | HP: %d/%d\nDistance: %d | Speed: %.0f",
GetStreamerDisplayName(target),
tostring(GetRole(target)),
math.floor(health + 0.5),
math.floor(maxHealth + 0.5),
math.floor(distance + 0.5),
root.AssemblyLinearVelocity.Magnitude
)
end
if State.ScreenshotMode then
TargetArrowGui.Visible = false
if TargetTracerDrawing then TargetTracerDrawing.Visible = false end
return
end
if State.TargetArrow and target and root and target ~= LP then
SetEdgeArrow(TargetArrowGui, root.Position, State.ESPTargetColor, 0.36)
else
TargetArrowGui.Visible = false
end
if TargetTracerDrawing then
if State.TargetTracer and root then
local point = Camera:WorldToViewportPoint(root.Position)
if point.Z > 0 then
TargetTracerDrawing.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 8)
TargetTracerDrawing.To = Vector2.new(point.X, point.Y)
TargetTracerDrawing.Color = State.ESPTargetColor
TargetTracerDrawing.Thickness = 2.4
TargetTracerDrawing.Transparency = 1
TargetTracerDrawing.Visible = true
else
TargetTracerDrawing.Visible = false
end
else
TargetTracerDrawing.Visible = false
end
end
GunHUD.Visible = (State.DroppedGunDistanceHUD or State.MinimalHUD)
and not State.ScreenshotMode
if State.MinimalHUD and not State.DroppedGunDistanceHUD then
if CachedDroppedGun then
GunHUDText.Text = string.format("Gun: %d studs", math.floor(CachedDroppedGunDistance + 0.5))
else
GunHUDText.Text = "Gun: not dropped"
end
end
end)
function SaveFreecamBookmark()
Camera = Workspace.CurrentCamera or Camera
if not Camera then return false end
State.FreecamBookmark = State.Freecam and FreecamCF or Camera.CFrame
Notify("Freecam Bookmark", "Camera position saved", "Success")
return true
end
function LoadFreecamBookmark()
if not State.FreecamBookmark then
Notify("Freecam Bookmark", "No camera bookmark saved", "Warning")
return false
end
Camera = Workspace.CurrentCamera or Camera
if not Camera then return false end
if State.Freecam then
FreecamCF = State.FreecamBookmark
local x, y, _ = FreecamCF:ToOrientation()
FreecamPitch = x
FreecamYaw = y
else
Camera.CFrame = State.FreecamBookmark
end
return true
end
