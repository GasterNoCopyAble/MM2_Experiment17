-- Experiment 17 | Private MM2 modular v7 | UI / keybinds / favorites
-- Semantic feature module. Loaded by init.lua into one shared runtime environment.

Controls.KillAll = MurderSection:AddToggle({
Name = "Kill All",
Flag = "MM2_KillAll",
Default = false,
Description = "Murderer only. Teleports every living player exactly inside your character and repeatedly activates Knife.",
FPSImpact = {0, 3},
PingImpact = {0, 2},
Callback = function(value)
State.KillAll = value
SyncFeatureBind("Kill All", value)
if value and GetLocalRole() ~= "Murderer" then
Notify("Kill All", "Current role is not Murderer", "Warning")
end
end,
})
Controls.ShootMurderer = SheriffSection:AddButton({
Name = "Shoot Murderer",
ButtonText = "Shoot",
Description = "Equips Gun, follows directly behind the moving Murderer while looking at HumanoidRootPart, fires, then restores your old position/camera.",
FPSImpact = {0, 1},
PingImpact = {0, 1},
Callback = function()
task.spawn(ShootMurdererSequence)
end,
})
Controls.AutoShoot = SheriffSection:AddToggle({
Name = "Auto Shoot Murderer",
Flag = "MM2_AutoShoot",
Default = false,
Description = "Automatically runs the full Shoot Murderer sequence while you are Sheriff/Hero.",
FPSImpact = {0, 1},
PingImpact = {0, 1},
Callback = function(value)
State.AutoShootMurderer = value
end,
})
SheriffSection:AddSlider({
Name = "Behind Distance",
Flag = "MM2_BehindDistance",
Min = 2,
Max = 10,
Default = 3.5,
Decimals = 1,
Description = "How many studs behind the Murderer Shoot Murderer follows.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value)
State.ShootBehindDistance = value
end,
})
SheriffSection:AddSlider({
Name = "Aim Follow Time",
Flag = "MM2_FollowTime",
Min = 0.05,
Max = 0.5,
Default = 0.16,
Decimals = 2,
Description = "How long Shoot Murderer tracks the Murderer's moving back before clicking.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value)
State.ShootFollowTime = value
end,
})
SheriffSection:AddSlider({
Name = "Behind TP Delay",
Flag = "MM2_ShootTPDelay",
Min = 0,
Max = 0.5,
Default = 0.04,
Decimals = 2,
Description = "Extra delay after following behind the Murderer and before the shot is fired.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ShootTPDelay = value end,
})
SheriffSection:AddToggle({
Name = "Shoot Retry",
Flag = "MM2_ShootRetry",
Default = false,
Description = "If the Murderer is still alive after the shot, repeat the complete behind/aim/shoot sequence.",
FPSImpact = {0, 1},
PingImpact = {0, 1},
Callback = function(value) State.ShootRetry = value end,
})
SheriffSection:AddSlider({
Name = "Retry Count",
Flag = "MM2_ShootRetryCount",
Min = 1,
Max = 4,
Default = 1,
Description = "Maximum automatic retries after the first Shoot Murderer attempt.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ShootRetryCount = math.floor(value) end,
})
Controls.ShootAttemptLabel = SheriffSection:AddLabel({
Text = "Shoot attempts: 0",
Height = 30,
})
Controls.SilentShot = SilentSection:AddToggle({
Name = "Silent Shot",
Flag = "MM2_SilentShot",
Default = false,
Description = "Redirects Mouse.Hit, Mouse.Target and Mouse.UnitRay to the Murderer without requiring camera aim.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value)
if value and not SilentHookAvailable then
Notify("Silent Shot", "Mouse hook is unavailable", "Error")
return
end
State.SilentShot = value
SyncFeatureBind("Silent Shot", value)
end,
})
SilentSection:AddChoice({
Name = "Target Part",
Flag = "MM2_SilentPart",
Values = {"HumanoidRootPart", "Head"},
Default = "HumanoidRootPart",
Description = "Target part used by Silent Shot and Shoot Murderer.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value)
State.SilentPart = value
end,
})
Controls.ESP = ESPMainSection:AddToggle({
Name = "Enable ESP",
Flag = "ESP_Enable",
Default = false,
Description = "Master player ESP switch. Cost depends mainly on player count and enabled Drawing elements.",
FPSImpact = {1, 7},
PingImpact = 0,
Callback = function(value)
State.ESP = value
SyncFeatureBind("ESP", value)
end,
})
Controls.ESPElements = ESPMainSection:AddMultiDropdown({
Name = "ESP Elements",
Flag = "ESP_Elements",
Values = {
"Highlight",
"DisplayName",
"Username",
"Role",
"Health Text",
"Health Bar",
"Distance",
"Weapon",
"2D Box",
"Tracer",
"Offscreen Arrows",
},
Default = {
"Highlight",
"DisplayName",
"Role",
"Health Text",
"Health Bar",
"Distance",
"Weapon",
"2D Box",
"Offscreen Arrows",
},
Description = "Select the player ESP elements to render.",
FPSImpact = {0, 6},
PingImpact = 0,
Callback = function(values)
local selected = {}
for _, value in ipairs(values) do selected[value] = true end
State.ESPHighlight = selected.Highlight == true
State.ESPNames = selected.DisplayName == true
State.ESPUsername = selected.Username == true
State.ESPRole = selected.Role == true
State.ESPHealth = selected["Health Text"] == true
State.ESPHealthBar = selected["Health Bar"] == true
State.ESPDistance = selected.Distance == true
State.ESPWeapon = selected.Weapon == true
State.ESPBox = selected["2D Box"] == true
State.ESPTracer = selected.Tracer == true
State.ESPOffscreenArrows = selected["Offscreen Arrows"] == true
end,
})
ESPMainSection:AddSlider({
Name = "Max Distance",
Flag = "ESP_MaxDistance",
Min = 100,
Max = 10000,
Default = 2500,
Description = "Players beyond this distance are skipped by ESP.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ESPMaxDistance = value end,
})
ESPStyleSection:AddChoice({
Name = "Color Mode",
Flag = "ESP_ColorMode",
Values = {"Role Colors", "Custom"},
Default = "Role Colors",
Description = "Role Colors uses one color per role. Custom uses one color for every player.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ESPColorMode = value end,
})
ESPStyleSection:AddColorPicker({
Name = "Custom Color",
Flag = "ESP_CustomColor",
Default = State.ESPCustomColor,
Description = "Global player ESP color in Custom mode.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ESPCustomColor = value end,
})
ESPStyleSection:AddColorPicker({
Name = "Murderer Color",
Flag = "ESP_MurdererColor",
Default = State.ESPMurdererColor,
Description = "Role color for Murderer.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ESPMurdererColor = value end,
})
ESPStyleSection:AddColorPicker({
Name = "Sheriff Color",
Flag = "ESP_SheriffColor",
Default = State.ESPSheriffColor,
Description = "Role color for Sheriff.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ESPSheriffColor = value end,
})
ESPStyleSection:AddColorPicker({
Name = "Hero Color",
Flag = "ESP_HeroColor",
Default = State.ESPHeroColor,
Description = "Role color for Hero.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ESPHeroColor = value end,
})
ESPStyleSection:AddColorPicker({
Name = "Innocent Color",
Flag = "ESP_InnocentColor",
Default = State.ESPInnocentColor,
Description = "Role color for Innocent players.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ESPInnocentColor = value end,
})
ESPStyleSection:AddSlider({
Name = "Text Size",
Flag = "ESP_TextSize",
Min = 9,
Max = 24,
Default = 14,
Description = "Billboard text size.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ESPTextSize = value end,
})
ESPStyleSection:AddSlider({
Name = "Line Thickness",
Flag = "ESP_LineThickness",
Min = 1,
Max = 4,
Default = 1.4,
Decimals = 1,
Description = "Thickness for Box, Tracer and Health Bar.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ESPLineThickness = value end,
})
ESPStyleSection:AddSlider({
Name = "Highlight Transparency",
Flag = "ESP_HighlightTransparency",
Min = 0,
Max = 0.95,
Default = 0.66,
Decimals = 2,
Description = "Role Highlight fill transparency.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ESPHighlightTransparency = value end,
})
ESPAdvancedSection:AddChoice({
Name = "ESP Preset",
Flag = "ESP_Preset",
Values = {"Minimal", "Full", "Performance", "Role Only", "Custom"},
Default = "Full",
Description = "Quickly applies a useful ESP element set. Editing elements afterward is effectively Custom.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value)
if value ~= "Custom" then ApplyESPPreset(value) end
end,
})
Controls.Skeleton = ESPAdvancedSection:AddToggle({
Name = "Skeleton ESP",
Flag = "ESP_Skeleton",
Default = false,
Description = "Draws R6/R15 bone lines with the Drawing API.",
FPSImpact = {1, 5},
PingImpact = 0,
Callback = function(value) State.ESPSkeleton = value end,
})
ESPAdvancedSection:AddToggle({
Name = "Head Dot",
Flag = "ESP_HeadDot",
Default = false,
Description = "Draws a small role-colored dot on the player's head.",
FPSImpact = {0, 1},
PingImpact = 0,
Callback = function(value) State.ESPHeadDot = value end,
})
ESPAdvancedSection:AddToggle({
Name = "Visible Check",
Flag = "ESP_VisibleCheck",
Default = false,
Description = "Raycasts from the camera to the player and recolors ESP when the target is directly visible.",
FPSImpact = {1, 4},
PingImpact = 0,
Callback = function(value) State.ESPVisibleCheck = value end,
})
ESPAdvancedSection:AddColorPicker({
Name = "Visible Color",
Flag = "ESP_VisibleColor",
Default = State.ESPVisibleColor,
Description = "Color used for directly visible players when Visible Check is enabled.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ESPVisibleColor = value end,
})
ESPAdvancedSection:AddToggle({
Name = "Distance Fade",
Flag = "ESP_DistanceFade",
Default = false,
Description = "Fades ESP smoothly as the player approaches Max Distance.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ESPDistanceFade = value end,
})
ESPAdvancedSection:AddToggle({
Name = "ESP Background",
Flag = "ESP_Background",
Default = false,
Description = "Adds a dark rounded background behind player text.",
FPSImpact = {0, 1},
PingImpact = 0,
Callback = function(value) State.ESPBackground = value end,
})
ESPAdvancedSection:AddSlider({
Name = "Background Transparency",
Flag = "ESP_BackgroundTransparency",
Min = 0,
Max = 1,
Default = 0.45,
Decimals = 2,
Description = "Text background transparency.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ESPBackgroundTransparency = value end,
})
Controls.RoundedBox = ESPAdvancedSection:AddToggle({
Name = "Rounded Box",
Flag = "ESP_RoundedBox",
Default = false,
Description = "Uses a rounded GuiObject/UIStroke box instead of the normal Drawing square.",
FPSImpact = {0, 2},
PingImpact = 0,
Callback = function(value) State.ESPRoundedBox = value end,
})
ESPAdvancedSection:AddToggle({
Name = "Target Highlight",
Flag = "ESP_TargetHighlight",
Default = true,
Description = "Selected Target gets the dedicated Target Color and bypasses normal role color priority.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ESPTargetHighlight = value end,
})
ESPAdvancedSection:AddColorPicker({
Name = "Target Color",
Flag = "ESP_TargetColor",
Default = State.ESPTargetColor,
Description = "Color for selected Target highlight, arrow and tracer.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ESPTargetColor = value end,
})
ESPAdvancedSection:AddToggle({
Name = "Threat Priority ESP",
Flag = "ESP_ThreatPriority",
Default = false,
Description = "Makes a nearby Murderer brighter and thicker than normal ESP targets.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ESPThreatPriority = value end,
})
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
WarningSection:AddToggle({
Name = "Murderer Approach Speed",
Flag = "World_MurdererApproachHUD",
Default = false,
Description = "Shows whether the Murderer is closing/leaving and the measured studs-per-second rate.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.MurdererApproachHUD = value end,
})
WarningSection:AddToggle({
Name = "Murderer Danger Bar",
Flag = "World_MurdererDangerBar",
Default = false,
Description = "Shows a proximity danger bar in the Murderer HUD.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.MurdererDangerBar = value end,
})
WarningSection:AddToggle({
Name = "Murderer Behind Warning",
Flag = "World_MurdererBehindWarning",
Default = false,
Description = "Warns if a nearby Murderer is substantially behind your facing direction.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.MurdererBehindWarning = value end,
})
WarningSection:AddToggle({
Name = "Murderer LOS Warning",
Flag = "World_MurdererLOSWarning",
Default = false,
Description = "Warns if the Murderer is facing you and a raycast finds a clear line of sight.",
FPSImpact = {0, 1},
PingImpact = 0,
Callback = function(value) State.MurdererLOSWarning = value end,
})
WarningSection:AddToggle({
Name = "Closing Speed Warning",
Flag = "World_ClosingSpeedWarning",
Default = false,
Description = "Warns when the Murderer is closing distance faster than the configured threshold.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ClosingSpeedWarning = value end,
})
WarningSection:AddSlider({
Name = "Closing Speed Threshold",
Flag = "World_ClosingSpeedThreshold",
Min = 5,
Max = 100,
Default = 18,
Description = "Studs per second required to trigger Closing Speed Warning.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ClosingSpeedThreshold = value end,
})
Controls.RoleArrow = RoleArrowSection:AddToggle({
Name = "Role Arrow",
Flag = "World_RoleArrow",
Default = false,
Description = "Shows an edge arrow toward the selected role whenever that player is offscreen.",
FPSImpact = {0, 1},
PingImpact = 0,
Callback = function(value)
State.RoleArrow = value
SyncFeatureBind("Role Arrow", value)
if not value then RoleArrowGui.Visible = false end
end,
})
RoleArrowSection:AddChoice({
Name = "Arrow Target",
Flag = "World_RoleArrowTarget",
Values = {"Murderer", "Sheriff", "Hero"},
Default = "Murderer",
Description = "Role tracked by the dedicated Role Arrow.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.RoleArrowTarget = value end,
})
RoleArrowSection:AddSlider({
Name = "Arrow Size",
Flag = "World_RoleArrowSize",
Min = 16,
Max = 48,
Default = 28,
Description = "Dedicated Role Arrow size.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.RoleArrowSize = value end,
})
Controls.XRay = XRaySection:AddToggle({
Name = "Smart XRay",
Flag = "World_XRay",
Default = false,
Description = "Fades only map parts currently blocking the camera's view to alive players.",
FPSImpact = {1, 4},
PingImpact = 0,
Callback = function(value)
State.XRay = value
SyncFeatureBind("XRay", value)
if value then UpdateXRay() else RestoreXRay() end
end,
})
XRaySection:AddSlider({
Name = "Transparency",
Flag = "World_XRayTransparency",
Min = 0,
Max = 0.95,
Default = 0.72,
Decimals = 2,
Description = "Transparency applied to currently blocking parts.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.XRayTransparency = value end,
})
MovementSection:AddChoice({
Name = "Movement Preset",
Flag = "Player_MovementPreset",
Values = {"Normal", "Fast", "Insane", "Custom"},
Default = "Custom",
Description = "Applies grouped WalkSpeed / JumpPower / FlySpeed values.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value)
ApplyMovementPreset(value)
end,
})
Controls.WalkSpeed = MovementSection:AddToggle({
Name = "WalkSpeed",
Flag = "Player_WalkSpeed",
Default = false,
Description = "Continuously applies the selected Humanoid WalkSpeed.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value)
State.WalkSpeed = value
SyncFeatureBind("WalkSpeed", value)
local humanoid = GetHumanoid(LP)
if humanoid and not value then humanoid.WalkSpeed = OriginalWalkSpeed end
end,
})
Controls.WalkSpeedValue = MovementSection:AddSlider({
Name = "Walk Speed",
Flag = "Player_WalkSpeedValue",
Min = 16,
Max = 250,
Default = 32,
Description = "WalkSpeed value.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.WalkSpeedValue = value end,
})
Controls.JumpHack = MovementSection:AddToggle({
Name = "JumpHack",
Flag = "Player_JumpHack",
Default = false,
Description = "Applies custom JumpPower and supports games using JumpHeight.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value)
State.JumpHack = value
SyncFeatureBind("JumpHack", value)
local humanoid = GetHumanoid(LP)
if humanoid and not value then
humanoid.JumpPower = OriginalJumpPower
humanoid.JumpHeight = OriginalJumpHeight
end
end,
})
Controls.JumpPowerValue = MovementSection:AddSlider({
Name = "Jump Power",
Flag = "Player_JumpPower",
Min = 50,
Max = 300,
Default = 80,
Description = "JumpHack strength.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.JumpPowerValue = value end,
})
Controls.Fly = MovementSection:AddToggle({
Name = "Fly",
Flag = "Player_Fly",
Default = false,
Description = "Camera-direction flight. Body follows the full camera pitch as in the older build.",
FPSImpact = {0, 1},
PingImpact = 0,
Callback = function(value)
State.Fly = value
SyncFeatureBind("Fly", value)
if not value then CleanupFly() end
end,
})
Controls.FlySpeedControl = MovementSection:AddSlider({
Name = "Fly Speed",
Flag = "Player_FlySpeed",
Min = 10,
Max = 350,
Default = 70,
Description = "Flight speed.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.FlySpeed = value end,
})
MovementSection:AddChoice({
Name = "Fly Mode",
Flag = "Player_FlyMode",
Values = {"Camera", "Upright", "Hover", "Glide"},
Default = "Camera",
Description = "Camera follows full camera pitch; Upright/Hover keep the body vertical; Glide keeps forward motion when no input is held.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.FlyMode = value end,
})
Controls.Noclip = MovementSection:AddToggle({
Name = "Noclip",
Flag = "Player_Noclip",
Default = false,
Description = "Disables local character collision. Temporarily releases during fling.",
FPSImpact = {0, 1},
PingImpact = 0,
Callback = function(value)
State.Noclip = value
SyncFeatureBind("Noclip", value)
if value then ApplyNoclip() else RestoreNoclip() end
end,
})
Controls.ClickTP = TeleportSection:AddToggle({
Name = "Click TP",
Flag = "Player_ClickTP",
Default = false,
Description = "Click/tap a world surface to teleport there using a camera raycast; independent from Silent Shot Mouse.Hit.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value)
State.ClickTP = value
SyncFeatureBind("Click TP", value)
end,
})
TeleportSection:AddToggle({
Name = "Require Alt",
Flag = "Player_ClickTPRequireAlt",
Default = false,
Description = "Require LeftAlt/RightAlt before Click TP activates.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.ClickTPRequireAlt = value end,
})
TeleportSection:AddButton({
Name = "Return Position",
ButtonText = "Return",
Description = "Returns to the most recently saved pre-teleport CFrame.",
FPSImpact = 0,
PingImpact = 0,
Callback = ReturnToSavedPosition,
})
BookmarkSection:AddInput({
Name = "Bookmark Name",
Flag = "Player_BookmarkName",
Default = "Bookmark",
Placeholder = "name...",
Description = "Name used by Save Current Position.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) BookmarkNameValue = tostring(value) end,
})
BookmarkSection:AddButton({
Name = "Save Current Position",
ButtonText = "Save",
Description = "Stores the current HumanoidRootPart CFrame in the local bookmark table.",
FPSImpact = 0,
PingImpact = 0,
Callback = function()
local name = SaveBookmark(BookmarkNameValue)
if name then Notify("Bookmark", "Saved: " .. tostring(name), "Success") end
end,
})
BookmarkChoice = BookmarkSection:AddChoice({
Name = "Bookmark",
Flag = "Player_BookmarkChoice",
Values = {"None"},
Default = "None",
Description = "Saved position list. Spawn is refreshed automatically on respawn.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.SelectedBookmark = value end,
})
BookmarkSection:AddButton({
Name = "Teleport Bookmark",
ButtonText = "Teleport",
Description = "Teleports to the selected bookmark while saving Return Position first.",
FPSImpact = 0,
PingImpact = 0,
Callback = function() TeleportToBookmark(State.SelectedBookmark) end,
})
BookmarkSection:AddButton({
Name = "Delete Bookmark",
ButtonText = "Delete",
Description = "Deletes the selected bookmark. Spawn will be recreated on the next respawn.",
FPSImpact = 0,
PingImpact = 0,
Callback = function()
local name = State.SelectedBookmark
if name and name ~= "None" then
State.PositionBookmarks[name] = nil
RefreshBookmarkDropdown()
end
end,
})
Controls.Ghost = GhostSection:AddToggle({
Name = "Invisible Ghost",
Flag = "Player_Ghost",
Default = false,
Description = "Creates a local ghost first, moves the real character over 10k studs upward, hides it locally, and returns it to the ghost when disabled.",
FPSImpact = {1, 4},
PingImpact = 0,
Callback = function(value)
if value then
if not EnableGhost() then
Notify("Invisible Ghost", "Could not create ghost", "Error")
return
end
State.GhostMode = true
else
State.GhostMode = false
DisableGhost(true)
end
SyncFeatureBind("Invisible Ghost", State.GhostMode)
end,
})
GhostSection:AddSlider({
Name = "Real Character Height",
Flag = "Player_GhostHeight",
Min = 10000,
Max = 50000,
Default = 15000,
Description = "How far above the map the real character is placed.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.GhostHeight = value end,
})
GhostSection:AddSlider({
Name = "Ghost Speed",
Flag = "Player_GhostSpeed",
Min = 10,
Max = 250,
Default = 55,
Description = "Local ghost movement speed.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.GhostSpeed = value end,
})
SpectateChoice = SpectateSection:AddChoice({
Name = "Spectate Player",
Flag = "Camera_SpectateTarget",
Values = {"None"},
Default = "None",
Description = "Live player dropdown used by Spectate.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value)
State.SpectateTargetName = value
if State.Spectate then ApplySpectate() end
end,
})
SpectateToggle = SpectateSection:AddToggle({
Name = "Enable Spectate",
Flag = "Camera_Spectate",
Default = false,
Description = "Sets CurrentCamera.CameraSubject to the selected player's Humanoid.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value)
if value and State.Freecam then
State.Freecam = false
StopFreecam()
if Controls.Freecam then Controls.Freecam:Set(false, true) end
SyncFeatureBind("Freecam", false)
end
State.Spectate = value
ApplySpectate()
SyncFeatureBind("Spectate", value)
end,
})
Controls.SpectateMurderer = SpectateSection:AddButton({
Name = "Spectate Murderer",
ButtonText = "Murderer",
Description = "Selects the current living Murderer and enables Spectate.",
FPSImpact = 0,
PingImpact = 0,
Callback = function()
local murderer = GetMurderer()
if not murderer then
Notify("Spectate", "Murderer not found", "Warning")
return
end
SpectateChoice:Set(murderer.Name)
SpectateToggle:Set(true)
end,
})
Controls.Freecam = FreecamSection:AddToggle({
Name = "Freecam",
Flag = "Camera_Freecam",
Default = false,
Description = "Scriptable camera: WASD move, Space/Ctrl vertical, RMB look, Shift speed boost.",
FPSImpact = {0, 1},
PingImpact = 0,
Callback = function(value)
if value and State.Spectate then
State.Spectate = false
ApplySpectate()
if SpectateToggle then SpectateToggle:Set(false, true) end
SyncFeatureBind("Spectate", false)
end
State.Freecam = value
if value then StartFreecam() else StopFreecam() end
SyncFeatureBind("Freecam", value)
end,
})
Controls.FreecamSpeedControl = FreecamSection:AddSlider({
Name = "Freecam Speed",
Flag = "Camera_FreecamSpeed",
Min = 5,
Max = 300,
Default = 60,
Description = "Normal freecam movement speed.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.FreecamSpeed = value end,
})
FreecamSection:AddSlider({
Name = "Shift Boost",
Flag = "Camera_FreecamBoost",
Min = 1,
Max = 10,
Default = 3,
Decimals = 1,
Description = "Speed multiplier while Shift is held.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.FreecamBoost = value end,
})
FreecamSection:AddSlider({
Name = "Mouse Sensitivity",
Flag = "Camera_FreecamSensitivity",
Min = 0.05,
Max = 1,
Default = 0.22,
Decimals = 2,
Description = "RMB freecam mouse-look sensitivity.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.FreecamSensitivity = value end,
})
FreecamSection:AddSlider({
Name = "Freecam FOV",
Flag = "Camera_FreecamFOV",
Min = 30,
Max = 120,
Default = 70,
Description = "Field of view used while Freecam is active.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.FreecamFOV = value end,
})
FreecamSection:AddSlider({
Name = "Mouse Wheel Speed Step",
Flag = "Camera_FreecamWheelStep",
Min = 1,
Max = 50,
Default = 10,
Description = "Amount Freecam Speed changes for each mouse-wheel step.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.FreecamWheelStep = value end,
})
FreecamSection:AddToggle({
Name = "Follow Selected Target",
Flag = "Camera_FreecamFollow",
Default = false,
Description = "Keeps Freecam positioned freely while rotating it toward the selected Target player.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.FreecamFollowPlayer = value end,
})
FreecamBookmarkSection:AddButton({
Name = "Save Freecam Bookmark",
ButtonText = "Save Camera",
Description = "Stores the current Freecam/current camera CFrame.",
FPSImpact = 0,
PingImpact = 0,
Callback = SaveFreecamBookmark,
})
FreecamBookmarkSection:AddButton({
Name = "Load Freecam Bookmark",
ButtonText = "Load Camera",
Description = "Returns Freecam/current camera to the saved camera CFrame.",
FPSImpact = 0,
PingImpact = 0,
Callback = LoadFreecamBookmark,
})
TargetMainChoice = TargetSelectSection:AddChoice({
Name = "Target Player",
Flag = "Target_Player",
Values = {"None"},
Default = "None",
Description = "Main selected player used by Target HUD, arrows, teleport, pin/ignore/whitelist, custom color and Freecam Follow.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value)
State.TargetPlayerName = value
if Controls.TargetCustomColor and Controls.TargetCustomColor.Set then
local color = State.PlayerCustomColors[value]
if typeof(color) ~= "Color3" then color = State.TargetCustomColor end
Controls.TargetCustomColor:Set(color, true)
end
end,
})
TargetESPSection:AddToggle({
Name = "Target Lock HUD",
Flag = "Target_HUD",
Default = false,
Description = "Shows selected target name, role, HP, distance and speed in a dedicated HUD panel.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.TargetLockHUD = value end,
})
TargetESPSection:AddToggle({
Name = "Target Arrow",
Flag = "Target_Arrow",
Default = false,
Description = "Dedicated edge arrow for the selected target.",
FPSImpact = {0, 1},
PingImpact = 0,
Callback = function(value) State.TargetArrow = value end,
})
TargetESPSection:AddToggle({
Name = "Target Tracer",
Flag = "Target_Tracer",
Default = false,
Description = "Dedicated screen-bottom tracer to the selected target.",
FPSImpact = {0, 1},
PingImpact = 0,
Callback = function(value) State.TargetTracer = value end,
})
TargetTeleportSection:AddButton({
Name = "Teleport To Player",
ButtonText = "TP Player",
Description = "Teleports to the selected player's exact CFrame and saves Return Position.",
FPSImpact = 0,
PingImpact = 0,
Callback = function() TeleportToSelectedTarget("Player") end,
})
TargetTeleportSection:AddButton({
Name = "TP Behind Player",
ButtonText = "Behind",
Description = "Teleports behind the selected player and faces their root part.",
FPSImpact = 0,
PingImpact = 0,
Callback = function() TeleportToSelectedTarget("Behind") end,
})
TargetTeleportSection:AddButton({
Name = "TP In Front Player",
ButtonText = "Front",
Description = "Teleports in front of the selected player and faces their root part.",
FPSImpact = 0,
PingImpact = 0,
Callback = function() TeleportToSelectedTarget("Front") end,
})
TargetTeleportSection:AddButton({
Name = "TP Above Player",
ButtonText = "Above",
Description = "Teleports above the selected player at the configured height and faces their root part.",
FPSImpact = 0,
PingImpact = 0,
Callback = function() TeleportToSelectedTarget("Above") end,
})
TargetTeleportSection:AddSlider({
Name = "Above Height",
Flag = "Target_AboveHeight",
Min = 3,
Max = 100,
Default = 8,
Description = "Height used by TP Above Player.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.TargetTeleportHeight = value end,
})
TargetTeleportSection:AddButton({
Name = "Return Position",
ButtonText = "Return",
Description = "Returns to the last position saved by target/bookmark/world teleport actions.",
FPSImpact = 0,
PingImpact = 0,
Callback = ReturnToSavedPosition,
})
PlayerListsSection:AddButton({
Name = "Pin / Unpin Target",
ButtonText = "Toggle Pin",
Description = "Pinned player bypasses Max Distance and keeps normal ESP priority.",
FPSImpact = 0,
PingImpact = 0,
Callback = function()
local name = State.TargetPlayerName
if name ~= "None" then State.PinnedPlayers[name] = not State.PinnedPlayers[name] end
end,
})
PlayerListsSection:AddButton({
Name = "Ignore / Unignore Target",
ButtonText = "Toggle Ignore",
Description = "Ignored player is excluded before ESP/Chams heavy objects are updated.",
FPSImpact = 0,
PingImpact = 0,
Callback = function()
local name = State.TargetPlayerName
if name ~= "None" then State.IgnoredPlayers[name] = not State.IgnoredPlayers[name] end
end,
})
PlayerListsSection:AddButton({
Name = "Whitelist / Remove Target",
ButtonText = "Toggle Whitelist",
Description = "Adds/removes the selected player from the ESP whitelist.",
FPSImpact = 0,
PingImpact = 0,
Callback = function()
local name = State.TargetPlayerName
if name ~= "None" then State.WhitelistedPlayers[name] = not State.WhitelistedPlayers[name] end
end,
})
PlayerListsSection:AddToggle({
Name = "Whitelist Only",
Flag = "Target_WhitelistOnly",
Default = false,
Description = "When enabled, player ESP/Chams only process whitelisted players.",
FPSImpact = {0, -2},
PingImpact = 0,
Callback = function(value) State.WhitelistOnly = value end,
})
Controls.TargetCustomColor = PlayerListsSection:AddColorPicker({
Name = "Custom Player Color",
Flag = "Target_CustomPlayerColor",
Default = State.TargetCustomColor,
Description = "Applies a permanent custom ESP color to the currently selected target player.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value)
State.TargetCustomColor = value
local name = State.TargetPlayerName
if name ~= "None" then State.PlayerCustomColors[name] = value end
end,
})
PlayerListsSection:AddButton({
Name = "Clear Player Color",
ButtonText = "Clear Color",
Description = "Removes the selected player's individual custom ESP color.",
FPSImpact = 0,
PingImpact = 0,
Callback = function()
local name = State.TargetPlayerName
if name ~= "None" then State.PlayerCustomColors[name] = nil end
end,
})
RoundMainSection:AddToggle({
Name = "Round Start Notification",
Flag = "Round_StartNotification",
Default = false,
Description = "Notifies when role data transitions into an active round with a Murderer.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.RoundStartNotification = value end,
})
RoundMainSection:AddToggle({
Name = "Auto Reset Visuals On Round End",
Flag = "Round_AutoResetVisuals",
Default = false,
Description = "Clears trails, Last Seen markers, death markers, heatmap and Shoot Attempt counter when the round ends.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.AutoResetVisualsRoundEnd = value end,
})
RoundMainSection:AddToggle({
Name = "Role Change Notification",
Flag = "Round_RoleChangeNotification",
Default = false,
Description = "Notifies when cached GetPlayerData role values change between refreshes.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.RoleChangeNotification = value end,
})
WeaponEventSection:AddToggle({
Name = "Knife Equipped Warning",
Flag = "Round_KnifeWarning",
Default = false,
Description = "Notifies on the transition where the Murderer equips a Tool named Knife.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.KnifeEquippedWarning = value end,
})
WeaponEventSection:AddToggle({
Name = "Gun Equipped Warning",
Flag = "Round_GunWarning",
Default = false,
Description = "Notifies when the current Sheriff/Hero equips a Tool named Gun.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.GunEquippedWarning = value end,
})
Controls.ScreenshotMode = HUDMainSection:AddToggle({
Name = "Screenshot Mode",
Flag = "HUD_ScreenshotMode",
Default = false,
Description = "Temporarily hides custom ESP/HUD/world visuals and closes the Experiment17 menu without changing feature toggles.",
FPSImpact = {0, -5},
PingImpact = 0,
Callback = function(value)
ApplyScreenshotMode(value)
SyncFeatureBind("Screenshot Mode", value)
end,
})
HUDMainSection:AddToggle({
Name = "Streamer Mode",
Flag = "HUD_StreamerMode",
Default = false,
Description = "Hides usernames and optionally anonymizes DisplayNames in custom HUD/ESP text.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.StreamerMode = value end,
})
HUDMainSection:AddChoice({
Name = "Streamer Style",
Flag = "HUD_StreamerStyle",
Values = {"Hide Usernames", "Anonymous", "Role Only"},
Default = "Hide Usernames",
Description = "Privacy style used by Streamer Mode.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.StreamerStyle = value end,
})
HUDMainSection:AddToggle({
Name = "Minimal HUD Mode",
Flag = "HUD_Minimal",
Default = false,
Description = "Keeps only core Murderer danger/distance and dropped-gun status panels; Target HUD is hidden.",
FPSImpact = {0, -1},
PingImpact = 0,
Callback = function(value) State.MinimalHUD = value end,
})
HUDEditSection:AddToggle({
Name = "HUD Editor",
Flag = "HUD_Editor",
Default = false,
Description = "Allows dragging the Murderer, Gun and Target HUD panels with mouse or touch.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value) State.HUDEditor = value end,
})
HUDEditSection:AddSlider({
Name = "HUD Scale",
Flag = "HUD_Scale",
Min = 0.5,
Max = 1.8,
Default = 1,
Decimals = 2,
Description = "Scale for all custom MM2 HUD panels.",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value)
State.HUDScale = value
ApplyHUDVisualSettings()
end,
})
HUDEditSection:AddSlider({
Name = "HUD Opacity",
Flag = "HUD_Opacity",
Min = 0,
Max = 1,
Default = 0.22,
Decimals = 2,
Description = "Background transparency of custom HUD panels (0 opaque, 1 invisible).",
FPSImpact = 0,
PingImpact = 0,
Callback = function(value)
State.HUDOpacity = value
ApplyHUDVisualSettings()
end,
})
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
