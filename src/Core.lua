-- Experiment 17 | Private MM2 modular v7 | Core
-- Semantic feature module. Loaded by init.lua into one shared runtime environment.

Players = game:GetService("Players")
ReplicatedStorage = game:GetService("ReplicatedStorage")
RunService = game:GetService("RunService")
UIS = game:GetService("UserInputService")
Workspace = game:GetService("Workspace")
LP = Players.LocalPlayer
Mouse = LP:GetMouse()
Camera = Workspace.CurrentCamera
Library = loadstring(game:HttpGet(
"https://raw.githubusercontent.com/GasterNoCopyAble/Experiment17_GuiLib/main/Experiment17.lua"
))()
CombatTab = Library:CreateTab("Combat")
ESPTab = Library:CreateTab("ESP")
WorldTab = Library:CreateTab("World")
PlayerTab = Library:CreateTab("Player")
CameraTab = Library:CreateTab("Camera")
TargetTab = Library:CreateTab("Target")
RoundTab = Library:CreateTab("Round")
HUDTab = Library:CreateTab("HUD")
PerformanceTab = Library:CreateTab("Performance")
FlingTab = Library:CreateTab("Fling")
MiscTab = Library:CreateTab("Misc")
MurderSection = CombatTab:CreateSection("Murderer", true)
SheriffSection = CombatTab:CreateSection("Sheriff / Hero", true)
SilentSection = CombatTab:CreateSection("Silent Shot", false)
ESPMainSection = ESPTab:CreateSection("Player ESP", true)
ESPStyleSection = ESPTab:CreateSection("ESP Style", false)
ESPAdvancedSection = ESPTab:CreateSection("Advanced ESP", false)
ESPHistorySection = ESPTab:CreateSection("History / Trails", false)
ChamsSection = ESPTab:CreateSection("Player Chams", false)
GunSection = WorldTab:CreateSection("Dropped Gun", true)
CoinSection = WorldTab:CreateSection("Coins", false)
WarningSection = WorldTab:CreateSection("Murderer Warning", false)
RoleArrowSection = WorldTab:CreateSection("Role Arrow", false)
XRaySection = WorldTab:CreateSection("Smart XRay", false)
MovementSection = PlayerTab:CreateSection("Movement", true)
TeleportSection = PlayerTab:CreateSection("Teleport", false)
BookmarkSection = PlayerTab:CreateSection("Position Bookmarks", false)
GhostSection = PlayerTab:CreateSection("Invisible Ghost", false)
SpectateSection = CameraTab:CreateSection("Spectate", true)
FreecamSection = CameraTab:CreateSection("Freecam", false)
FreecamBookmarkSection = CameraTab:CreateSection("Freecam Bookmarks", false)
TargetSelectSection = TargetTab:CreateSection("Target Select", true)
TargetESPSection = TargetTab:CreateSection("Target Visuals", false)
TargetTeleportSection = TargetTab:CreateSection("Target Teleport", false)
PlayerListsSection = TargetTab:CreateSection("Pin / Ignore / Whitelist", false)
RoundMainSection = RoundTab:CreateSection("Round Events", true)
WeaponEventSection = RoundTab:CreateSection("Weapon Events", false)
HUDMainSection = HUDTab:CreateSection("HUD", true)
HUDEditSection = HUDTab:CreateSection("HUD Editor", false)
NotificationFilterSection = HUDTab:CreateSection("Notification Filters", false)
PerformanceMainSection = PerformanceTab:CreateSection("Update Rates", true)
PerformanceGuardSection = PerformanceTab:CreateSection("Adaptive Performance", false)
PerformanceProfileSection = PerformanceTab:CreateSection("Profiles", false)
TouchFlingSection = FlingTab:CreateSection("Touch Fling", true)
TargetFlingSection = FlingTab:CreateSection("Target Fling", true)
ProtectionSection = MiscTab:CreateSection("Protection", true)
KeybindSection = MiscTab:CreateSection("Keybinds", false)
FavoritesSection = MiscTab:CreateSection("Favorites", false)
State = {
Roles = {},
Murderer = nil,
Sheriff = nil,
Hero = nil,
RoleRemote = nil,
KillAll = false,
AutoShootMurderer = false,
ShootInProgress = false,
ShootBehindDistance = 3.5,
ShootFollowTime = 0.16,
ShootReturnDelay = 0.12,
LastKnifeAttack = 0,
LastGunShot = 0,
SilentShot = false,
SilentPart = "HumanoidRootPart",
ESP = false,
ESPHighlight = true,
ESPNames = true,
ESPUsername = false,
ESPRole = true,
ESPHealth = true,
ESPHealthBar = true,
ESPDistance = true,
ESPWeapon = true,
ESPBox = true,
ESPTracer = false,
ESPOffscreenArrows = true,
ESPMaxDistance = 2500,
ESPTextSize = 14,
ESPLineThickness = 1.4,
ESPHighlightTransparency = 0.66,
ESPColorMode = "Role Colors",
ESPCustomColor = Color3.fromRGB(170, 100, 255),
ESPInnocentColor = Color3.fromRGB(60, 225, 100),
ESPMurdererColor = Color3.fromRGB(235, 55, 55),
ESPSheriffColor = Color3.fromRGB(65, 125, 255),
ESPHeroColor = Color3.fromRGB(255, 225, 55),
ESPSkeleton = false,
ESPHeadDot = false,
ESPVisibleCheck = false,
ESPVisibleColor = Color3.fromRGB(80, 255, 180),
ESPDistanceFade = false,
ESPPreset = "Full",
ESPNameTextSize = 15,
ESPRoleTextSize = 13,
ESPInfoTextSize = 12,
ESPBackground = false,
ESPBackgroundTransparency = 0.45,
ESPRoundedBox = false,
ESPTargetHighlight = true,
ESPTargetColor = Color3.fromRGB(255, 120, 40),
ESPThreatPriority = false,
ESPThreatPriorityDistance = 55,
ESPVelocity = false,
ESPMovementDirection = false,
ESPJumpState = false,
ESPLastSeen = false,
ESPLastSeenDuration = 4,
ESPRoleTrail = false,
ESPPlayerTrailHistory = false,
ESPTrailSeconds = 3,
ESPUpdateRate = "30 Hz",
TargetPlayerName = "None",
TargetArrow = false,
TargetTracer = false,
TargetLockHUD = false,
TargetTeleportHeight = 8,
PinnedPlayers = {},
IgnoredPlayers = {},
WhitelistedPlayers = {},
WhitelistOnly = false,
PlayerCustomColors = {},
TargetCustomColor = Color3.fromRGB(255, 180, 55),
PlayerChams = false,
ChamsFillColor = Color3.fromRGB(145, 84, 255),
ChamsOutlineColor = Color3.fromRGB(255, 255, 255),
ChamsFillTransparency = 0.55,
ChamsOutlineTransparency = 0,
ChamsDepthMode = "AlwaysOnTop",
DroppedGunESP = false,
DroppedGunColor = Color3.fromRGB(80, 160, 255),
DroppedGunMaxDistance = 5000,
DroppedGunArrow = false,
DroppedGunDistanceHUD = false,
AutoGunPickup = false,
AutoGunPickupRange = 5000,
GunSpawnNotification = false,
LastKnownGun = nil,
GunPickupBusy = false,
LastAutoGunPickup = 0,
CoinESP = false,
CoinColor = Color3.fromRGB(255, 210, 45),
CoinMaxDistance = 1500,
CoinLimit = 120,
CoinNearestCount = 20,
NearestCoinArrow = false,
MurdererWarning = false,
MurdererWarningDistance = 35,
MurdererWarningCooldown = 2.5,
LastMurdererWarning = 0,
MurdererWarningArmed = true,
MurdererDistanceHUD = false,
MurdererApproachHUD = false,
MurdererDangerBar = false,
MurdererBehindWarning = false,
MurdererLOSWarning = false,
KnifeEquippedWarning = false,
GunEquippedWarning = false,
ClosingSpeedWarning = false,
ClosingSpeedThreshold = 18,
MurdererApproachSpeed = 0,
LastMurdererDistance = nil,
LastMurdererDistanceAt = 0,
LastClosingWarning = 0,
LastBehindWarning = 0,
LastLOSWarning = 0,
KnifeWasEquipped = false,
GunOwnersEquipped = {},
RoleChangeNotification = false,
PreviousRoles = {},
RoleCacheInitialized = false,
RoundStartNotification = false,
AutoResetVisualsRoundEnd = false,
RoundActive = false,
RoundIndex = 0,
RoleArrow = false,
RoleArrowTarget = "Murderer",
RoleArrowSize = 28,
RoleArrowRadius = 0.42,
XRay = false,
XRayTransparency = 0.72,
WalkSpeed = false,
WalkSpeedValue = 32,
JumpHack = false,
JumpPowerValue = 80,
Fly = false,
FlySpeed = 70,
FlyMode = "Camera",
MovementPreset = "Custom",
Noclip = false,
ClickTP = false,
ClickTPRequireAlt = false,
LastReturnCFrame = nil,
PositionBookmarks = {},
SelectedBookmark = "None",
BookmarkCounter = 0,
GhostMode = false,
GhostHeight = 15000,
GhostSpeed = 55,
Spectate = false,
SpectateTargetName = "None",
Freecam = false,
FreecamSpeed = 60,
FreecamBoost = 3,
FreecamSensitivity = 0.22,
FreecamFOV = 70,
FreecamWheelStep = 10,
FreecamFollowPlayer = false,
FreecamBookmark = nil,
WorldUpdateRate = "2 Hz",
AdaptivePerformance = false,
AdaptiveFPSMin = 45,
FPSGuard = false,
FPSGuardThreshold = 30,
FPSGuardActive = false,
LowFPSWarning = false,
LowFPSWarningThreshold = 35,
LastLowFPSWarning = 0,
ObjectCache = true,
CurrentFPS = 60,
FPSAccumulator = 0,
FPSFrames = 0,
FPSGuardLowSince = nil,
FPSGuardHighSince = nil,
MobilePerformanceProfile = false,
ScreenshotMode = false,
StreamerMode = false,
StreamerStyle = "Hide Usernames",
MinimalHUD = false,
HUDEditor = false,
HUDScale = 1,
HUDOpacity = 0.22,
NotificationFilters = {
Round = true,
Role = true,
Murderer = true,
Weapons = true,
Performance = true,
Target = true,
Gun = true,
System = true,
},
HeatmapESP = false,
HeatmapCellSize = 14,
HeatmapMaxCells = 70,
DeathMarkerESP = false,
BodyESP = false,
DeathTime = false,
ShootTPDelay = 0.04,
ShootRetry = false,
ShootRetryCount = 1,
ShootRetryDelay = 0.2,
ShootAttempts = 0,
AntiFling = false,
AntiFlingLinearThreshold = 260,
AntiFlingAngularThreshold = 120,
TouchFling = false,
TargetFlingActive = false,
FlingAllActive = false,
TargetFlingName = "None",
TargetFlingDuration = 0.85,
}
ENV = getgenv and getgenv() or _G
ENV.__E17_MM2_V7_STATE = State
Controls = {}
Connections = {}
DrawingObjects = {}
DrawingAvailable = type(Drawing) == "table" and type(Drawing.new) == "function"
function Connect(signal, callback)
local c = signal:Connect(callback)
Connections[#Connections + 1] = c
return c
end
function TrackDrawing(object)
if object then
DrawingObjects[#DrawingObjects + 1] = object
end
return object
end
function RemoveDrawing(object)
if object then
pcall(function() object:Remove() end)
end
end
function InferNotificationCategory(title)
local lower = string.lower(tostring(title or ""))
if string.find(lower, "round", 1, true) then return "Round" end
if string.find(lower, "role", 1, true) then return "Role" end
if string.find(lower, "murderer", 1, true) then return "Murderer" end
if string.find(lower, "knife", 1, true) or string.find(lower, "weapon", 1, true) then return "Weapons" end
if string.find(lower, "gun", 1, true) then return "Gun" end
if string.find(lower, "fps", 1, true) or string.find(lower, "performance", 1, true) then return "Performance" end
if string.find(lower, "target", 1, true) then return "Target" end
return "System"
end
function Notify(title, text, kind, duration, category)
category = category or InferNotificationCategory(title)
local filters = State.NotificationFilters
if category ~= "System"
and type(filters) == "table"
and filters[category] == false
then
return
end
pcall(function()
Library:Notify({
Title = title,
Text = text,
Type = kind or "Info",
Duration = duration or 4,
})
end)
end
ResetRoundVisuals = function() end
function GetCharacter(player)
return player and player.Character or nil
end
function GetHumanoid(player)
local character = GetCharacter(player)
return character and character:FindFirstChildOfClass("Humanoid") or nil
end
function GetRoot(player)
local character = GetCharacter(player)
if not character then return nil end
return character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
end
function IsCharacterAlive(player)
local humanoid = GetHumanoid(player)
return humanoid and humanoid.Health > 0 or false
end
function FindPlayer(name)
if not name or name == "" or name == "None" then return nil end
return Players:FindFirstChild(name)
end
function IsInsideAnyCharacter(object)
for _, player in ipairs(Players:GetPlayers()) do
local character = player.Character
if character and object:IsDescendantOf(character) then
return true
end
end
return false
end
function GetEquippedTool(player)
local character = GetCharacter(player)
return character and character:FindFirstChildOfClass("Tool") or nil
end
function FindRoleRemote()
if State.RoleRemote and State.RoleRemote.Parent and State.RoleRemote:IsA("RemoteFunction") then
return State.RoleRemote
end
local remote = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
if remote and remote:IsA("RemoteFunction") then
State.RoleRemote = remote
return remote
end
return nil
end
function RefreshRoles()
local remote = FindRoleRemote()
if not remote then return false end
local ok, result = pcall(function()
return remote:InvokeServer()
end)
if not ok or type(result) ~= "table" then
return false
end
local oldRoundActive = State.RoundActive
local oldRoles = State.PreviousRoles
State.Roles = result
State.Murderer = nil
State.Sheriff = nil
State.Hero = nil
local currentRoles = {}
for playerName, info in pairs(result) do
if type(info) == "table" then
local role = tostring(info.Role or "Innocent")
currentRoles[playerName] = role
if role == "Murderer" then
State.Murderer = playerName
elseif role == "Sheriff" then
State.Sheriff = playerName
elseif role == "Hero" then
State.Hero = playerName
end
end
end
local murdererInfo = State.Murderer and result[State.Murderer]
local newRoundActive = State.Murderer ~= nil
and type(murdererInfo) == "table"
and not murdererInfo.Killed
and not murdererInfo.Dead
State.RoundActive = newRoundActive
if State.RoleCacheInitialized and State.RoleChangeNotification then
for playerName, role in pairs(currentRoles) do
local previous = oldRoles[playerName]
if previous and previous ~= role then
local changedPlayer = Players:FindFirstChild(playerName)
local displayName = playerName
if changedPlayer and State.StreamerMode then
if State.StreamerStyle == "Anonymous" then
displayName = "Player " .. tostring(changedPlayer.UserId % 997)
elseif State.StreamerStyle == "Role Only" then
displayName = role
else
displayName = changedPlayer.DisplayName
end
elseif changedPlayer then
displayName = changedPlayer.DisplayName
end
Notify(
"Role Change",
string.format("%s: %s -> %s", displayName, previous, role),
"Info",
3,
"Role"
)
end
end
end
if not oldRoundActive and newRoundActive then
State.RoundIndex += 1
State.ShootAttempts = 0
State.LastMurdererDistance = nil
State.LastMurdererDistanceAt = 0
if State.RoundStartNotification then
Notify(
"Round Start",
"Role: " .. tostring(currentRoles[LP.Name] or "Unknown"),
"Success",
3,
"Round"
)
end
elseif oldRoundActive and not newRoundActive then
if State.AutoResetVisualsRoundEnd then
ResetRoundVisuals()
end
end
State.PreviousRoles = currentRoles
State.RoleCacheInitialized = true
return true
end
function GetRole(player)
if not player then return nil end
local info = State.Roles[player.Name]
return info and info.Role or "Innocent"
end
function GetLocalRole()
return GetRole(LP)
end
function IsAliveFromRoleData(player)
if not player then return false end
local info = State.Roles[player.Name]
if type(info) == "table" and (info.Killed or info.Dead) then
return false
end
return IsCharacterAlive(player)
end
function GetMurderer()
local player = FindPlayer(State.Murderer)
return player and IsAliveFromRoleData(player) and player or nil
end
function GetSheriff()
local player = FindPlayer(State.Sheriff)
return player and IsAliveFromRoleData(player) and player or nil
end
function GetHero()
local player = FindPlayer(State.Hero)
return player and IsAliveFromRoleData(player) and player or nil
end
task.spawn(function()
while not Library.Unloaded do
RefreshRoles()
task.wait(0.25)
end
end)
task.spawn(RefreshRoles)
function GetRoleColor(player)
if not player then
return State.ESPCustomColor
end
local custom = State.PlayerCustomColors[player.Name]
if typeof(custom) == "Color3" then
return custom
end
if State.ESPTargetHighlight
and State.TargetPlayerName == player.Name
then
return State.ESPTargetColor
end
if State.ESPColorMode == "Custom" then
return State.ESPCustomColor
end
local role = GetRole(player)
if role == "Murderer" then return State.ESPMurdererColor end
if role == "Sheriff" then return State.ESPSheriffColor end
if role == "Hero" then return State.ESPHeroColor end
return State.ESPInnocentColor
end
function IsPlayerESPAllowed(player)
if not player or player == LP then return false end
if State.IgnoredPlayers[player.Name] then return false end
if State.WhitelistOnly and not State.WhitelistedPlayers[player.Name] then return false end
return true
end
function GetStreamerDisplayName(player)
if not State.StreamerMode then
return player.DisplayName
end
if State.StreamerStyle == "Anonymous" then
return "Player " .. tostring(player.UserId % 997)
elseif State.StreamerStyle == "Role Only" then
return tostring(GetRole(player))
end
return player.DisplayName
end
function FindTool(toolName)
local character = LP.Character
if character then
local tool = character:FindFirstChild(toolName)
if tool and tool:IsA("Tool") then return tool end
end
local backpack = LP:FindFirstChildOfClass("Backpack")
if backpack then
local tool = backpack:FindFirstChild(toolName)
if tool and tool:IsA("Tool") then return tool end
end
return nil
end
function EquipTool(toolName)
local tool = FindTool(toolName)
if not tool then return nil end
if tool.Parent ~= LP.Character then
local humanoid = GetHumanoid(LP)
if humanoid then
pcall(function() humanoid:EquipTool(tool) end)
task.wait()
end
end
return tool
end
function ActivateTool(toolName)
local tool = EquipTool(toolName)
if not tool then return false end
pcall(function() tool:Activate() end)
return true
end
BindControlsByFeature = {}
function RefreshKeybindList()
pcall(function() Library:RefreshKeybindList() end)
end
function SyncFeatureBind(featureName, active)
local bind = BindControlsByFeature[featureName]
local entry = bind and bind.RegistryEntry
if entry then
entry.Active = active == true
RefreshKeybindList()
end
end
