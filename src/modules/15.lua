-- Experiment17 MM2 modular v7 | module 15
NotificationFilterSection:AddMultiDropdown({
Name = "Allowed Notifications",
Flag = "HUD_NotificationFilters",
Values = {"Round", "Role", "Murderer", "Weapons", "Performance", "Target", "Gun"},
Default = {"Round", "Role", "Murderer", "Weapons", "Performance", "Target", "Gun"},
Description = "Filters event notifications. System/load notifications are always allowed.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(values)
for _, name in ipairs({"Round", "Role", "Murderer", "Weapons", "Performance", "Target", "Gun"}) do
State.NotificationFilters[name] = false
end
for _, name in ipairs(values) do
State.NotificationFilters[name] = true
end
end,
})
Controls.ESPUpdateRate = PerformanceMainSection:AddChoice({
Name = "ESP Update Rate",
Flag = "Perf_ESPRate",
Values = {"Every Frame", "60 Hz", "30 Hz", "20 Hz", "15 Hz", "10 Hz"},
Default = "30 Hz",
Description = "Controls the complete player ESP update cadence.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ESPUpdateRate = value end,
})
Controls.WorldUpdateRate = PerformanceMainSection:AddChoice({
Name = "World ESP Update Rate",
Flag = "Perf_WorldRate",
Values = {"10 Hz", "5 Hz", "2 Hz", "1 Hz"},
Default = "2 Hz",
Description = "Controls cached Gun/Coin discovery and world ESP refresh cadence.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.WorldUpdateRate = value end,
})
PerformanceMainSection:AddToggle({
Name = "Object Cache",
Flag = "Perf_ObjectCache",
Default = true,
Description = "Uses DescendantAdded/Removing cache for Gun/Coin candidates instead of full Workspace:GetDescendants scans every update.",
FPSImpact = {0, -5},
PingImpact = 0,
Callback = function(value)
State.ObjectCache = value
if value then RebuildWorldCache() end
end,
})
Controls.AdaptivePerformance = PerformanceGuardSection:AddToggle({
Name = "Adaptive Performance",
Flag = "Perf_Adaptive",
Default = false,
Description = "Automatically lowers effective ESP/world update cadence when measured FPS falls below the target.",
FPSImpact = {0, -5},
PingImpact = 0,
Callback = function(value) State.AdaptivePerformance = value end,
})
PerformanceGuardSection:AddSlider({
Name = "Adaptive FPS Target",
Flag = "Perf_AdaptiveTarget",
Min = 20,
Max = 120,
Default = 45,
Description = "FPS target used by Adaptive Performance.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.AdaptiveFPSMin = value end,
})
PerformanceGuardSection:AddToggle({
Name = "FPS Guard",
Flag = "Perf_FPSGuard",
Default = false,
Description = "After sustained low FPS, throttles ESP and suppresses heavy Skeleton/Trail/Coin/Heatmap visuals until FPS recovers.",
FPSImpact = {0, -8},
PingImpact = 0,
Callback = function(value) State.FPSGuard = value end,
})
PerformanceGuardSection:AddSlider({
Name = "FPS Guard Threshold",
Flag = "Perf_FPSGuardThreshold",
Min = 15,
Max = 90,
Default = 30,
Description = "FPS below this threshold for about 2 seconds activates FPS Guard.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.FPSGuardThreshold = value end,
})
PerformanceGuardSection:AddToggle({
Name = "Low FPS Warning",
Flag = "Perf_LowFPSWarning",
Default = false,
Description = "Shows a throttled notification when measured FPS falls below the selected warning threshold.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.LowFPSWarning = value end,
})
PerformanceGuardSection:AddSlider({
Name = "Low FPS Threshold",
Flag = "Perf_LowFPSThreshold",
Min = 15,
Max = 90,
Default = 35,
Description = "Threshold used by Low FPS Warning.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.LowFPSWarningThreshold = value end,
})
PerformanceProfileSection:AddButton({
Name = "Mobile Performance Profile",
ButtonText = "Apply Mobile",
Description = "Applies 10 Hz ESP, 1 Hz world update, 40 coin limit, disables heavy trails/skeleton/heatmap/rounded box, and enables Adaptive Performance.",
FPSImpact = {0, -10},
PingImpact = 0,
Callback = ApplyMobilePerformanceProfile,
})
Controls.TouchFling = TouchFlingSection:AddToggle({
Name = "Touch Fling",
Flag = "Fling_Touch",
Default = false,
Description = "Uses the supplied working short Velocity pulse pattern. No angular spin mover is used.",
FPSImpact = {0, 1},
PingImpact = 0,
Callback = function(value)
State.TouchFling = value
if value then StartTouchFling() else StopTouchFling() end
SyncFeatureBind("Touch Fling", value)
end,
})
TargetFlingChoice = TargetFlingSection:AddChoice({
Name = "Target Player",
Flag = "Fling_TargetPlayer",
Values = {"None"},
Default = "None",
Description = "Live player list; automatically updates on join/leave.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.TargetFlingName = value end,
})
TargetFlingSection:AddSlider({
Name = "Fling Duration",
Flag = "Fling_TargetDuration",
Min = 0.15,
Max = 3,
Default = 0.85,
Decimals = 2,
Description = "How long Target Fling stays exactly overlapped with the selected player.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.TargetFlingDuration = value end,
})
Controls.FlingTarget = TargetFlingSection:AddButton({
Name = "Fling Target",
ButtonText = "Fling",
Description = "Teleports exactly inside the selected player and applies hidden Velocity pulses, without diagonal orbit/spin.",
FPSImpact = {0, 1},
PingImpact = 0,
Callback = function()
local target = FindPlayer(State.TargetFlingName)
task.spawn(function() FlingTarget(target) end)
end,
})
Controls.FlingAll = TargetFlingSection:AddButton({
Name = "Fling All",
ButtonText = "All",
Description = "Sequentially applies Target Fling to every living player, then returns to the original position.",
FPSImpact = {0, 2},
PingImpact = 0,
Callback = FlingAll,
})
TargetFlingSection:AddButton({
Name = "Stop Fling",
ButtonText = "Stop",
Description = "Stops Target Fling or Fling All.",
FPSImpact = 0,
PingImpact = 0,
Callback = function()
State.TargetFlingActive = false
State.FlingAllActive = false
end,
})
Controls.AntiFling = ProtectionSection:AddToggle({
Name = "Anti Fling",
Flag = "Protection_AntiFling",
Default = false,
Description = "Disables local collision with other characters and clamps abnormal horizontal/spin velocity. Never restores a saved CFrame.",
FPSImpact = {0, 1},
PingImpact = 0,
Callback = function(value)
State.AntiFling = value
if not value then RestoreAntiFlingCollision() end
SyncFeatureBind("Anti Fling", value)
end,
})
ProtectionSection:AddSlider({
Name = "Linear Threshold",
Flag = "Protection_AntiFlingLinear",
Min = 100,
Max = 1000,
Default = 260,
Description = "Horizontal velocity above this is treated as fling-like.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.AntiFlingLinearThreshold = value end,
})
ProtectionSection:AddSlider({
Name = "Angular Threshold",
Flag = "Protection_AntiFlingAngular",
Min = 30,
Max = 1000,
Default = 120,
Description = "Angular velocity magnitude above this is reset.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.AntiFlingAngularThreshold = value end,
})
function RefreshPlayerDropdowns()
local values = BuildPlayerNames()
if SpectateChoice and SpectateChoice.SetValues then
SpectateChoice:SetValues(values, true)
State.SpectateTargetName = SpectateChoice:Get()
end
if TargetFlingChoice and TargetFlingChoice.SetValues then
TargetFlingChoice:SetValues(values, true)
State.TargetFlingName = TargetFlingChoice:Get()
end
if TargetMainChoice and TargetMainChoice.SetValues then
TargetMainChoice:SetValues(values, true)
State.TargetPlayerName = TargetMainChoice:Get()
end
end
Connect(Players.PlayerAdded, function()
task.defer(RefreshPlayerDropdowns)
end)
Connect(Players.PlayerRemoving, function(player)
CleanupESPPlayer(player)
CleanupChamsPlayer(player)
State.PinnedPlayers[player.Name] = nil
State.IgnoredPlayers[player.Name] = nil
State.WhitelistedPlayers[player.Name] = nil
State.PlayerCustomColors[player.Name] = nil
State.GunOwnersEquipped[player.Name] = nil
PlayerAliveState[player] = nil
local marker = DeathMarkers[player]
if marker and marker.Part and marker.Part.Parent then marker.Part:Destroy() end
DeathMarkers[player] = nil
task.defer(RefreshPlayerDropdowns)
end)
task.defer(RefreshPlayerDropdowns)
task.defer(function()
local root = GetRoot(LP)
if root then
State.PositionBookmarks.Spawn = root.CFrame
RefreshBookmarkDropdown()
end
end)
Library.Settings.KeybindListEnabled = true
builtInKeybindListToggle =
Library.ControlsByFlag and Library.ControlsByFlag.UI_KeybindList
if builtInKeybindListToggle and builtInKeybindListToggle.Set then
builtInKeybindListToggle:Set(true, false)
end
function AddToggleBind(name, flag, key, control, description)
local bind = KeybindSection:AddKeybind({
Name = name,
Flag = flag,
Default = key,
Mode = "Toggle",
Description = description,
FPSImpact = 0,
PingImpact = 0,
OnTriggered = function(active)
if type(active) == "boolean" and control and control.Set then
control:Set(active)
end
end,
})
BindControlsByFeature[name] = bind
if bind.RegistryEntry and control and control.Get then
bind.RegistryEntry.Active = control:Get() == true
end
return bind
end
AddToggleBind("Fly", "Bind_Fly", "F", Controls.Fly, "Toggle Fly.")
AddToggleBind("ESP", "Bind_ESP", "E", Controls.ESP, "Toggle Player ESP.")
AddToggleBind("XRay", "Bind_XRay", "X", Controls.XRay, "Toggle Smart XRay.")
AddToggleBind("Noclip", "Bind_Noclip", "N", Controls.Noclip, "Toggle Noclip.")
AddToggleBind("WalkSpeed", "Bind_WalkSpeed", "V", Controls.WalkSpeed, "Toggle WalkSpeed.")
AddToggleBind("JumpHack", "Bind_JumpHack", "J", Controls.JumpHack, "Toggle JumpHack.")
AddToggleBind("Click TP", "Bind_ClickTP", "T", Controls.ClickTP, "Toggle Click TP.")
AddToggleBind("Invisible Ghost", "Bind_Ghost", "Z", Controls.Ghost, "Toggle Invisible Ghost.")
AddToggleBind("Anti Fling", "Bind_AntiFling", "G", Controls.AntiFling, "Toggle Anti Fling.")
AddToggleBind("Touch Fling", "Bind_TouchFling", "B", Controls.TouchFling, "Toggle Touch Fling.")
AddToggleBind("Kill All", "Bind_KillAll", "K", Controls.KillAll, "Toggle Murderer Kill All.")
AddToggleBind("Silent Shot", "Bind_SilentShot", "Q", Controls.SilentShot, "Toggle Silent Shot.")
AddToggleBind("Player Chams", "Bind_Chams", "Comma", Controls.PlayerChams, "Toggle Player Chams.")
AddToggleBind("Dropped Gun ESP", "Bind_GunESP", "Y", Controls.GunESP, "Toggle Dropped Gun ESP.")
AddToggleBind("Coin ESP", "Bind_CoinESP", "O", Controls.CoinESP, "Toggle Coin ESP.")
AddToggleBind("Murderer Warning", "Bind_Warning", "M", Controls.MurdererWarning, "Toggle Murderer Warning.")
AddToggleBind("Role Arrow", "Bind_RoleArrow", "I", Controls.RoleArrow, "Toggle Role Arrow.")
AddToggleBind("Spectate", "Bind_Spectate", "P", SpectateToggle, "Toggle Spectate.")
AddToggleBind("Freecam", "Bind_Freecam", "U", Controls.Freecam, "Toggle Freecam.")
AddToggleBind("Screenshot Mode", "Bind_ScreenshotMode", "F8", Controls.ScreenshotMode, "Temporarily hide custom visuals/HUD and close the menu.")
KeybindSection:AddKeybind({
Name = "Shoot Murderer",
Flag = "Bind_ShootMurderer",
Default = "R",
Mode = "Press",
Description = "Run Shoot Murderer once.",
FPSImpact = 0,
PingImpact = 0,
OnTriggered = function() task.spawn(ShootMurdererSequence) end,
})
KeybindSection:AddKeybind({
Name = "Fling Target",
Flag = "Bind_FlingTarget",
Default = "H",
Mode = "Press",
Description = "Fling selected target once.",
FPSImpact = 0,
PingImpact = 0,
OnTriggered = function()
local target = FindPlayer(State.TargetFlingName)
task.spawn(function() FlingTarget(target) end)
end,
})
KeybindSection:AddKeybind({
Name = "Fling All",
Flag = "Bind_FlingAll",
Default = "L",
Mode = "Press",
Description = "Run Fling All once.",
FPSImpact = 0,
PingImpact = 0,
OnTriggered = FlingAll,
})
RefreshKeybindList()
