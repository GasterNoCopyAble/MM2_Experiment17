-- Experiment17 MM2 modular v7 | module 11
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
