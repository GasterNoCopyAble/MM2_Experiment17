-- Experiment17 MM2 modular v7 | module 12
ESPAdvancedSection:AddSlider({
Name = "Threat Priority Distance",
Flag = "ESP_ThreatPriorityDistance",
Min = 10,
Max = 250,
Default = 55,
Description = "Distance where Murderer ESP becomes priority ESP.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ESPThreatPriorityDistance = value end,
})
ESPAdvancedSection:AddToggle({
Name = "Velocity ESP",
Flag = "ESP_Velocity",
Default = false,
Description = "Shows player AssemblyLinearVelocity magnitude in studs per second.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ESPVelocity = value end,
})
ESPAdvancedSection:AddToggle({
Name = "Movement Direction Arrow",
Flag = "ESP_MoveDirection",
Default = false,
Description = "Shows a small arrow above onscreen players pointing in their movement direction.",
FPSImpact = {0, 2},
PingImpact = 0,
Callback = function(value) State.ESPMovementDirection = value end,
})
ESPAdvancedSection:AddToggle({
Name = "Jump State ESP",
Flag = "ESP_JumpState",
Default = false,
Description = "Shows Grounded / Jumping / Falling / Climbing state in the info line.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ESPJumpState = value end,
})
ESPAdvancedSection:AddSlider({
Name = "Name Font Size",
Flag = "ESP_NameFontSize",
Min = 8,
Max = 28,
Default = 15,
Description = "Independent font size for DisplayName.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ESPNameTextSize = value end,
})
ESPAdvancedSection:AddSlider({
Name = "Role Font Size",
Flag = "ESP_RoleFontSize",
Min = 8,
Max = 28,
Default = 13,
Description = "Independent font size for role text.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ESPRoleTextSize = value end,
})
ESPAdvancedSection:AddSlider({
Name = "Info Font Size",
Flag = "ESP_InfoFontSize",
Min = 8,
Max = 24,
Default = 12,
Description = "Independent size for HP/distance/weapon/velocity/state.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ESPInfoTextSize = value end,
})
Controls.RoleTrail = ESPHistorySection:AddToggle({
Name = "Role Trail ESP",
Flag = "ESP_RoleTrail",
Default = false,
Description = "Draws recent movement trails for Murderer, Sheriff and Hero.",
FPSImpact = {1, 4},
PingImpact = 0,
Callback = function(value) State.ESPRoleTrail = value end,
})
Controls.PlayerTrailHistory = ESPHistorySection:AddToggle({
Name = "Player Trail History",
Flag = "ESP_PlayerTrailHistory",
Default = false,
Description = "Draws recent movement path for every ESP player.",
FPSImpact = {2, 7},
PingImpact = 0,
Callback = function(value) State.ESPPlayerTrailHistory = value end,
})
ESPHistorySection:AddSlider({
Name = "Trail Seconds",
Flag = "ESP_TrailSeconds",
Min = 1,
Max = 5,
Default = 3,
Description = "How many seconds of movement history trails retain.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ESPTrailSeconds = value end,
})
ESPHistorySection:AddToggle({
Name = "Last Seen Marker",
Flag = "ESP_LastSeen",
Default = false,
Description = "Keeps a fading LAST SEEN marker at the player's last directly visible position.",
FPSImpact = {1, 3},
PingImpact = 0,
Callback = function(value) State.ESPLastSeen = value end,
})
ESPHistorySection:AddSlider({
Name = "Last Seen Time",
Flag = "ESP_LastSeenDuration",
Min = 1,
Max = 10,
Default = 4,
Description = "How long Last Seen markers remain visible.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ESPLastSeenDuration = value end,
})
Controls.Heatmap = ESPHistorySection:AddToggle({
Name = "Murderer Heatmap",
Flag = "ESP_Heatmap",
Default = false,
Description = "Builds a local grid heatmap from recent Murderer positions.",
FPSImpact = {1, 4},
PingImpact = 0,
Callback = function(value)
State.HeatmapESP = value
if not value then ClearHeatmap() end
end,
})
ESPHistorySection:AddToggle({
Name = "Death Marker ESP",
Flag = "ESP_DeathMarker",
Default = false,
Description = "Marks the world position where a player transitions from alive to dead.",
FPSImpact = {0, 2},
PingImpact = 0,
Callback = function(value)
State.DeathMarkerESP = value
if not value then ClearDeathVisuals() end
end,
})
ESPHistorySection:AddToggle({
Name = "Body ESP",
Flag = "ESP_BodyESP",
Default = false,
Description = "Highlights dead character bodies that remain in Workspace.",
FPSImpact = {0, 2},
PingImpact = 0,
Callback = function(value) State.BodyESP = value end,
})
ESPHistorySection:AddToggle({
Name = "Death Time",
Flag = "ESP_DeathTime",
Default = false,
Description = "Adds seconds-since-death to Death Marker ESP.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.DeathTime = value end,
})
Controls.PlayerChams = ChamsSection:AddToggle({
Name = "Player Chams",
Flag = "Chams_Enable",
Default = false,
Description = "Independent Highlight layer with custom fill, outline and occlusion mode.",
FPSImpact = {0, 3},
PingImpact = 0,
Callback = function(value)
State.PlayerChams = value
SyncFeatureBind("Player Chams", value)
end,
})
ChamsSection:AddColorPicker({
Name = "Fill Color",
Flag = "Chams_FillColor",
Default = State.ChamsFillColor,
Description = "Player Chams fill color.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ChamsFillColor = value end,
})
ChamsSection:AddColorPicker({
Name = "Outline Color",
Flag = "Chams_OutlineColor",
Default = State.ChamsOutlineColor,
Description = "Player Chams outline color.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ChamsOutlineColor = value end,
})
ChamsSection:AddSlider({
Name = "Fill Transparency",
Flag = "Chams_FillTransparency",
Min = 0,
Max = 1,
Default = 0.55,
Decimals = 2,
Description = "0 is solid fill; 1 is invisible fill.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ChamsFillTransparency = value end,
})
ChamsSection:AddSlider({
Name = "Outline Transparency",
Flag = "Chams_OutlineTransparency",
Min = 0,
Max = 1,
Default = 0,
Decimals = 2,
Description = "0 is solid outline; 1 hides the outline.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ChamsOutlineTransparency = value end,
})
ChamsSection:AddChoice({
Name = "Depth Mode",
Flag = "Chams_DepthMode",
Values = {"AlwaysOnTop", "VisibleOnly"},
Default = "AlwaysOnTop",
Description = "AlwaysOnTop renders through walls. VisibleOnly respects occlusion.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ChamsDepthMode = value end,
})
Controls.GunESP = GunSection:AddToggle({
Name = "Dropped Gun ESP",
Flag = "World_GunESP",
Default = false,
Description = "Highlights common dropped-gun object names and a dropped Workspace Tool named Gun.",
FPSImpact = {0, 2},
PingImpact = 0,
Callback = function(value)
State.DroppedGunESP = value
SyncFeatureBind("Dropped Gun ESP", value)
if not value then CleanupGunESP() end
end,
})
GunSection:AddColorPicker({
Name = "Gun Color",
Flag = "World_GunColor",
Default = State.DroppedGunColor,
Description = "Dropped Gun ESP color.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.DroppedGunColor = value end,
})
GunSection:AddSlider({
Name = "Gun Max Distance",
Flag = "World_GunDistance",
Min = 100,
Max = 10000,
Default = 5000,
Description = "Dropped gun is hidden beyond this distance.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.DroppedGunMaxDistance = value end,
})
Controls.GunPickup = GunSection:AddButton({
Name = "Gun Pickup TP",
ButtonText = "Pickup",
Description = "Saves your position, teleports to the dropped gun, tries touch pickup, then returns.",
FPSImpact = {0, 1},
PingImpact = {0, 1},
Callback = function() task.spawn(PickupDroppedGun) end,
})
GunSection:AddToggle({
Name = "Dropped Gun Arrow",
Flag = "World_GunArrow",
Default = false,
Description = "Shows an edge-of-screen arrow toward the cached dropped gun.",
FPSImpact = {0, 1},
PingImpact = 0,
Callback = function(value) State.DroppedGunArrow = value end,
})
GunSection:AddToggle({
Name = "Gun Distance HUD",
Flag = "World_GunDistanceHUD",
Default = false,
Description = "Shows the cached dropped gun distance in the HUD.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.DroppedGunDistanceHUD = value end,
})
GunSection:AddToggle({
Name = "Auto Gun Pickup",
Flag = "World_AutoGunPickup",
Default = false,
Description = "When a dropped gun exists inside Auto Pickup Range, runs the same pickup TP automatically.",
FPSImpact = {0, 1},
PingImpact = {0, 1},
Callback = function(value) State.AutoGunPickup = value end,
})
GunSection:AddSlider({
Name = "Auto Pickup Range",
Flag = "World_AutoGunPickupRange",
Min = 25,
Max = 10000,
Default = 5000,
Description = "Maximum distance for Auto Gun Pickup.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.AutoGunPickupRange = value end,
})
GunSection:AddToggle({
Name = "Gun Spawn Notification",
Flag = "World_GunSpawnNotification",
Default = false,
Description = "Notifies when the cached dropped gun changes from absent to present.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.GunSpawnNotification = value end,
})
Controls.CoinESP = CoinSection:AddToggle({
Name = "Coin ESP",
Flag = "World_CoinESP",
Default = false,
Description = "Highlights nearby Workspace objects whose names contain 'coin'. Coin Limit protects FPS.",
FPSImpact = {1, 8},
PingImpact = 0,
Callback = function(value)
State.CoinESP = value
SyncFeatureBind("Coin ESP", value)
if not value then CleanupCoins() end
end,
})
CoinSection:AddColorPicker({
Name = "Coin Color",
Flag = "World_CoinColor",
Default = State.CoinColor,
Description = "Coin ESP color.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.CoinColor = value end,
})
CoinSection:AddSlider({
Name = "Coin Max Distance",
Flag = "World_CoinDistance",
Min = 50,
Max = 5000,
Default = 1500,
Description = "Coins beyond this distance are skipped.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.CoinMaxDistance = value end,
})
Controls.CoinLimitControl = CoinSection:AddSlider({
Name = "Coin Limit",
Flag = "World_CoinLimit",
Min = 10,
Max = 300,
Default = 120,
Description = "Maximum amount of active Coin ESP objects.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.CoinLimit = math.floor(value) end,
})
CoinSection:AddSlider({
Name = "Nearest Coin Count",
Flag = "World_CoinNearestCount",
Min = 1,
Max = 100,
Default = 20,
Description = "Distance filter: only the nearest N coins are allowed to receive Coin ESP.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.CoinNearestCount = math.floor(value) end,
})
CoinSection:AddToggle({
Name = "Nearest Coin Arrow",
Flag = "World_NearestCoinArrow",
Default = false,
Description = "Shows an edge arrow toward the nearest cached coin.",
FPSImpact = {0, 1},
PingImpact = 0,
Callback = function(value) State.NearestCoinArrow = value end,
})
Controls.MurdererWarning = WarningSection:AddToggle({
Name = "Murderer Warning",
Flag = "World_MurdererWarning",
Default = false,
Description = "Shows a notification when a living Murderer enters the selected distance.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value)
State.MurdererWarning = value
State.MurdererWarningArmed = true
SyncFeatureBind("Murderer Warning", value)
end,
})
WarningSection:AddSlider({
Name = "Warning Distance",
Flag = "World_WarningDistance",
Min = 5,
Max = 250,
Default = 35,
Description = "Murderer Warning trigger distance.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.MurdererWarningDistance = value end,
})
WarningSection:AddSlider({
Name = "Warning Cooldown",
Flag = "World_WarningCooldown",
Min = 1,
Max = 10,
Default = 2.5,
Decimals = 1,
Description = "Minimum delay between warning notifications.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.MurdererWarningCooldown = value end,
})
WarningSection:AddToggle({
Name = "Murderer Distance HUD",
Flag = "World_MurdererDistanceHUD",
Default = false,
Description = "Shows Murderer name and current distance in the HUD.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.MurdererDistanceHUD = value end,
})
