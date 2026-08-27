-- Experiment17 MM2 modular v7 | module 14
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
