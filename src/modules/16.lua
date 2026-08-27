-- Experiment17 MM2 modular v7 | module 16
CoreFavorites = {
Controls.KillAll,
Controls.ShootMurderer,
Controls.ESP,
Controls.PlayerChams,
Controls.GunESP,
Controls.GunPickup,
Controls.CoinESP,
Controls.MurdererWarning,
Controls.RoleArrow,
Controls.XRay,
Controls.ScreenshotMode,
Controls.Skeleton,
Controls.Heatmap,
Controls.WalkSpeed,
Controls.JumpHack,
Controls.Fly,
Controls.Noclip,
Controls.ClickTP,
Controls.Ghost,
SpectateToggle,
Controls.Freecam,
Controls.AntiFling,
Controls.TouchFling,
Controls.FlingTarget,
Controls.FlingAll,
}
FavoritesSection:AddParagraph({
Text = "Every normal Experiment17 control already supports the native ★ Favorites panel. Right-click a function to add/remove it. These are bulk shortcuts.",
Height = 68,
})
FavoritesSection:AddButton({
Name = "Add Core Favorites",
ButtonText = "Add",
Description = "Adds the main MM2/ESP/Player/Camera/Fling functions to the native ★ Favorites panel.",
FPSImpact = 0,
PingImpact = 0,
Callback = function()
for _, control in ipairs(CoreFavorites) do
if control then Library:SetFavorite(control, true) end
end
Notify("Favorites", "Core functions added", "Success")
end,
})
FavoritesSection:AddButton({
Name = "Clear Favorites",
ButtonText = "Clear",
Description = "Clears the native ★ Favorites panel.",
FPSImpact = 0,
PingImpact = 0,
Callback = function()
local order = table.clone(Library.FavoriteOrder or {})
for _, control in ipairs(order) do
Library:SetFavorite(control, false)
end
end,
})
Connect(LP.CharacterAdded, function(character)
FlyVelocity = nil
FlyGyro = nil
FlyRoot = nil
RestoreNoclip()
RestoreAntiFlingCollision()
RestoreXRay()
if GhostModel or State.GhostMode then
State.GhostMode = false
DisableGhost(false)
if Controls.Ghost then
Controls.Ghost:Set(false, true)
end
SyncFeatureBind("Invisible Ghost", false)
end
local humanoid = character:WaitForChild("Humanoid", 10)
local root = character:WaitForChild("HumanoidRootPart", 10)
if not humanoid or not root then return end
task.wait(0.15)
DestroyFlyObjects(root)
humanoid.PlatformStand = false
humanoid.AutoRotate = true
CaptureMovementDefaults()
State.PositionBookmarks.Spawn = root.CFrame
task.defer(RefreshBookmarkDropdown)
if State.Noclip then task.defer(ApplyNoclip) end
if State.Fly then task.defer(EnsureFlyObjects) end
if State.XRay then task.defer(UpdateXRay) end
if State.Spectate then task.defer(ApplySpectate) end
task.defer(RefreshPlayerDropdowns)
task.defer(RefreshKeybindList)
end)
Cleaned = false
function CleanupAll()
if Cleaned then return end
Cleaned = true
State.KillAll = false
State.AutoShootMurderer = false
State.SilentShot = false
State.ESP = false
State.PlayerChams = false
State.DroppedGunESP = false
State.CoinESP = false
State.MurdererWarning = false
State.RoleArrow = false
State.XRay = false
State.Fly = false
State.Noclip = false
State.ClickTP = false
State.GhostMode = false
State.Spectate = false
State.Freecam = false
State.AntiFling = false
State.TouchFling = false
State.TargetFlingActive = false
State.FlingAllActive = false
State.ScreenshotMode = false
State.TargetArrow = false
State.TargetTracer = false
State.HeatmapESP = false
State.DeathMarkerESP = false
State.BodyESP = false
CleanupFly()
RestoreNoclip()
RestoreAntiFlingCollision()
RestoreXRay()
CleanupGunESP()
CleanupCoins()
ClearHeatmap()
ClearDeathVisuals()
StopTouchFling()
StopFreecam()
if GhostModel then
DisableGhost(false)
end
for player in pairs(ESPObjects) do
CleanupESPPlayer(player)
end
for player in pairs(ChamsObjects) do
CleanupChamsPlayer(player)
end
if RoleArrowGui and RoleArrowGui.Parent then
RoleArrowGui:Destroy()
end
if Overlay and Overlay.Parent then
Overlay:Destroy()
end
if HUDRoot and HUDRoot.Parent then
HUDRoot:Destroy()
end
for _, connection in ipairs(Connections) do
pcall(function() connection:Disconnect() end)
end
table.clear(Connections)
for _, object in ipairs(DrawingObjects) do
RemoveDrawing(object)
end
table.clear(DrawingObjects)
end
RawUnload = Library.Unload
if type(RawUnload) == "function" and not Library.__E17MM2V7UnloadWrapped then
Library.__E17MM2V7UnloadWrapped = true
function Library:Unload(...)
CleanupAll()
return RawUnload(self, ...)
end
end
task.delay(1, function()
RefreshRoles()
RefreshPlayerDropdowns()
RefreshBookmarkDropdown()
RefreshKeybindList()
Notify(
"Experiment 17 | Private MM2 v7",
"Loaded | Role: " .. tostring(GetLocalRole() or "Unknown"),
"Success"
)
if not DrawingAvailable then
Notify(
"Drawing API",
"2D Box / Tracer / Health Bar unavailable; Highlight, text and arrows still work.",
"Warning",
5
)
end
if not SilentHookAvailable then
Notify(
"Silent Shot",
"Mouse hook unavailable in this environment.",
"Warning",
5
)
end
end)
