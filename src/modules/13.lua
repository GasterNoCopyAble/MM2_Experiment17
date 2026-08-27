-- Experiment17 MM2 modular v7 | module 13
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
