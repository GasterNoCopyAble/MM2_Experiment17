-- Experiment17 MM2 modular v7 | module 02
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
function BringPlayerExact(player, targetCF)
if not player or player == LP or not IsAliveFromRoleData(player) then
return false
end
local character = player.Character
if not character then return false end
return pcall(function() character:PivotTo(targetCF) end)
end
function BringAllInsideLocal()
local root = GetRoot(LP)
if not root then return end
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LP and IsAliveFromRoleData(player) then
BringPlayerExact(player, root.CFrame)
end
end
end
task.spawn(function()
while not Library.Unloaded do
task.wait(0.08)
if State.KillAll and GetLocalRole() == "Murderer" then
BringAllInsideLocal()
local now = os.clock()
if now - State.LastKnifeAttack >= 0.14 then
State.LastKnifeAttack = now
ActivateTool("Knife")
end
end
end
end)
function GetSilentTargetPart()
if not State.SilentShot then return nil end
local role = GetLocalRole()
if role ~= "Sheriff" and role ~= "Hero" then return nil end
local murderer = GetMurderer()
local character = murderer and murderer.Character
if not character then return nil end
return character:FindFirstChild(State.SilentPart)
or character:FindFirstChild("HumanoidRootPart")
or character:FindFirstChild("Head")
end
State.GetSilentTargetPart = GetSilentTargetPart
function InstallSilentHook()
if ENV.__E17_MM2_V7_SILENT_HOOK then return true end
if not hookmetamethod or not newcclosure then return false end
local oldIndex
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
local current = ENV.__E17_MM2_V7_STATE
if current and current.SilentShot and self == Mouse then
local part = current.GetSilentTargetPart and current.GetSilentTargetPart()
if part then
if key == "Hit" then
return part.CFrame
elseif key == "Target" then
return part
elseif key == "UnitRay" then
local cam = Workspace.CurrentCamera
if cam then
local origin = cam.CFrame.Position
local direction = (part.Position - origin).Unit
return Ray.new(origin, direction * 10000)
end
end
end
end
return oldIndex(self, key)
end))
ENV.__E17_MM2_V7_SILENT_HOOK = true
return true
end
SilentHookAvailable = InstallSilentHook()
