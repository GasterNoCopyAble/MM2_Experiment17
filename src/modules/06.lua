-- Experiment17 MM2 modular v7 | module 06
ChamsObjects = {}
function CleanupChamsPlayer(player)
local highlight = ChamsObjects[player]
if highlight then
highlight:Destroy()
ChamsObjects[player] = nil
end
end
function UpdatePlayerChams()
if not State.PlayerChams or State.ScreenshotMode then
for player in pairs(ChamsObjects) do
CleanupChamsPlayer(player)
end
return
end
for player in pairs(ChamsObjects) do
if not IsPlayerESPAllowed(player) then
CleanupChamsPlayer(player)
end
end
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LP and player.Character and IsPlayerESPAllowed(player) then
local highlight = ChamsObjects[player]
if not highlight or highlight.Parent ~= player.Character then
CleanupChamsPlayer(player)
highlight = Instance.new("Highlight")
highlight.Name = "E17_PlayerChams"
highlight.Adornee = player.Character
highlight.Parent = player.Character
ChamsObjects[player] = highlight
end
highlight.FillColor = State.ChamsFillColor
highlight.OutlineColor = State.ChamsOutlineColor
highlight.FillTransparency = State.ChamsFillTransparency
highlight.OutlineTransparency = State.ChamsOutlineTransparency
highlight.DepthMode = State.ChamsDepthMode == "VisibleOnly"
and Enum.HighlightDepthMode.Occluded
or Enum.HighlightDepthMode.AlwaysOnTop
highlight.Enabled = IsAliveFromRoleData(player)
end
end
end
task.spawn(function()
while not Library.Unloaded do
UpdatePlayerChams()
task.wait(0.2)
end
end)
HeatmapCells = {}
HeatmapOrder = {}
DeathMarkers = {}
BodyHighlights = {}
PlayerAliveState = {}
function ClearHeatmap()
for _, part in pairs(HeatmapCells) do
if part and part.Parent then part:Destroy() end
end
table.clear(HeatmapCells)
table.clear(HeatmapOrder)
end
function ClearDeathVisuals()
for player, data in pairs(DeathMarkers) do
if data.Part and data.Part.Parent then data.Part:Destroy() end
DeathMarkers[player] = nil
end
for player, highlight in pairs(BodyHighlights) do
if highlight and highlight.Parent then highlight:Destroy() end
BodyHighlights[player] = nil
end
end
function CreateDeathMarker(player, position)
local old = DeathMarkers[player]
if old and old.Part and old.Part.Parent then old.Part:Destroy() end
local part = Instance.new("Part")
part.Name = "E17_DeathMarker_" .. player.Name
part.Anchored = true
part.CanCollide = false
part.CanTouch = false
part.CanQuery = false
part.Transparency = 1
part.Size = Vector3.new(0.2, 0.2, 0.2)
part.CFrame = CFrame.new(position)
part.Parent = Workspace
local gui = Instance.new("BillboardGui")
gui.AlwaysOnTop = true
gui.Size = UDim2.fromOffset(180, 48)
gui.StudsOffset = Vector3.new(0, 2.5, 0)
gui.Parent = part
local label = Instance.new("TextLabel")
label.Parent = gui
label.Size = UDim2.fromScale(1, 1)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBold
label.TextColor3 = Color3.fromRGB(255, 90, 90)
label.TextStrokeTransparency = 0.15
label.TextSize = 13
label.Text = "☠ " .. GetStreamerDisplayName(player)
DeathMarkers[player] = {
Part = part,
Label = label,
Time = os.clock(),
}
end
function UpdateBodyHighlight(player)
if not State.BodyESP or State.ScreenshotMode then
local old = BodyHighlights[player]
if old then old:Destroy() BodyHighlights[player] = nil end
return
end
local character = player.Character
local humanoid = GetHumanoid(player)
if not character or not humanoid or humanoid.Health > 0 then
local old = BodyHighlights[player]
if old then old:Destroy() BodyHighlights[player] = nil end
return
end
local highlight = BodyHighlights[player]
if not highlight or highlight.Parent ~= character then
if highlight then highlight:Destroy() end
highlight = Instance.new("Highlight")
highlight.Name = "E17_BodyESP"
highlight.Adornee = character
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
highlight.FillColor = Color3.fromRGB(150, 50, 50)
highlight.OutlineColor = Color3.fromRGB(255, 100, 100)
highlight.FillTransparency = 0.55
highlight.OutlineTransparency = 0.1
highlight.Parent = character
BodyHighlights[player] = highlight
end
end
function UpdateHeatmap()
if not State.HeatmapESP or State.ScreenshotMode or State.FPSGuardActive then return end
local murderer = GetMurderer()
local root = GetRoot(murderer)
if not murderer or not root then return end
local size = math.max(State.HeatmapCellSize, 4)
local gx = math.floor(root.Position.X / size + 0.5)
local gz = math.floor(root.Position.Z / size + 0.5)
local key = tostring(gx) .. ":" .. tostring(gz)
local part = HeatmapCells[key]
if not part then
part = Instance.new("Part")
part.Name = "E17_Heat_" .. key
part.Anchored = true
part.CanCollide = false
part.CanTouch = false
part.CanQuery = false
part.Material = Enum.Material.Neon
part.Shape = Enum.PartType.Cylinder
part.Size = Vector3.new(0.18, size * 0.72, size * 0.72)
part.Color = State.ESPMurdererColor
part.Transparency = 0.58
part.CFrame = CFrame.new(root.Position - Vector3.new(0, 2.8, 0))
* CFrame.Angles(0, 0, math.rad(90))
part.Parent = Workspace
part:SetAttribute("E17HeatCount", 1)
HeatmapCells[key] = part
table.insert(HeatmapOrder, key)
while #HeatmapOrder > State.HeatmapMaxCells do
local removeKey = table.remove(HeatmapOrder, 1)
local old = HeatmapCells[removeKey]
if old then old:Destroy() end
HeatmapCells[removeKey] = nil
end
else
local count = (part:GetAttribute("E17HeatCount") or 1) + 1
part:SetAttribute("E17HeatCount", count)
part.Transparency = math.clamp(0.62 - math.min(count, 15) * 0.025, 0.20, 0.62)
local scale = 1 + math.min(count, 12) * 0.025
part.Size = Vector3.new(0.18, size * 0.72 * scale, size * 0.72 * scale)
end
end
task.spawn(function()
while not Library.Unloaded do
task.wait(0.2)
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LP then
local alive = IsCharacterAlive(player)
local previous = PlayerAliveState[player]
if previous == true and not alive then
local root = GetRoot(player)
if State.DeathMarkerESP and root then
CreateDeathMarker(player, root.Position)
end
end
PlayerAliveState[player] = alive
UpdateBodyHighlight(player)
end
end
for player, data in pairs(DeathMarkers) do
if not data.Part or not data.Part.Parent then
DeathMarkers[player] = nil
elseif State.ScreenshotMode or not State.DeathMarkerESP then
data.Part.Parent = nil
data.Part:Destroy()
DeathMarkers[player] = nil
elseif State.DeathTime and data.Label then
data.Label.Text = string.format(
"☠ %s | %.1fs ago",
GetStreamerDisplayName(player),
os.clock() - data.Time
)
elseif data.Label then
data.Label.Text = "☠ " .. GetStreamerDisplayName(player)
end
end
end
end)
task.spawn(function()
while not Library.Unloaded do
UpdateHeatmap()
task.wait(0.45)
end
end)
ResetRoundVisuals = function()
ClearHeatmap()
ClearDeathVisuals()
State.ShootAttempts = 0
if Controls.ShootAttemptLabel and Controls.ShootAttemptLabel.Label then
Controls.ShootAttemptLabel.Label.Text = "Shoot attempts: 0"
end
for _, data in pairs(ESPObjects) do
table.clear(data.TrailPoints or {})
data.LastVisiblePosition = nil
data.LastVisibleTime = 0
HideLinePool(data.TrailLines)
if data.LastSeenText then data.LastSeenText.Visible = false end
end
end
function GetAdornmentPart(object)
if not object then return nil end
if object:IsA("BasePart") then return object end
if object:IsA("Tool") then
return object:FindFirstChild("Handle")
or object:FindFirstChildWhichIsA("BasePart", true)
end
if object:IsA("Model") then
return object.PrimaryPart
or object:FindFirstChildWhichIsA("BasePart", true)
end
return nil
end
function IsDroppedGunCandidate(object)
if not object or IsInsideAnyCharacter(object) then return false end
local lower = string.lower(object.Name)
if lower == "gundrop"
or lower == "droppedgun"
or lower == "dropped gun"
or lower == "sheriffgun"
then
return GetAdornmentPart(object) ~= nil
end
if object:IsA("Tool")
and lower == "gun"
and object:IsDescendantOf(Workspace)
then
return GetAdornmentPart(object) ~= nil
end
return false
end
function IsCoinCandidate(object)
if not object or IsInsideAnyCharacter(object) then return false end
local lower = string.lower(object.Name)
if not string.find(lower, "coin", 1, true) then
return false
end
return GetAdornmentPart(object) ~= nil
end
WorldCache = {
Guns = {},
Coins = {},
}
function ClassifyWorldObject(object)
if not object or not object.Parent then return end
if IsDroppedGunCandidate(object) then
WorldCache.Guns[object] = true
end
if IsCoinCandidate(object) then
WorldCache.Coins[object] = true
end
end
function RemoveWorldObject(object)
WorldCache.Guns[object] = nil
WorldCache.Coins[object] = nil
end
function RebuildWorldCache()
table.clear(WorldCache.Guns)
table.clear(WorldCache.Coins)
for _, object in ipairs(Workspace:GetDescendants()) do
ClassifyWorldObject(object)
end
end
Connect(Workspace.DescendantAdded, function(object)
if State.ObjectCache then
task.defer(function()
if object and object.Parent then
ClassifyWorldObject(object)
end
end)
end
end)
Connect(Workspace.DescendantRemoving, function(object)
RemoveWorldObject(object)
end)
task.defer(RebuildWorldCache)
function GetGunCandidates()
local result = {}
if State.ObjectCache then
for object in pairs(WorldCache.Guns) do
if object and object.Parent and IsDroppedGunCandidate(object) then
result[#result + 1] = object
else
WorldCache.Guns[object] = nil
end
end
else
for _, object in ipairs(Workspace:GetDescendants()) do
if IsDroppedGunCandidate(object) then
result[#result + 1] = object
end
end
end
return result
end
function GetCoinCandidates()
local result = {}
if State.ObjectCache then
for object in pairs(WorldCache.Coins) do
if object and object.Parent and IsCoinCandidate(object) then
result[#result + 1] = object
else
WorldCache.Coins[object] = nil
end
end
else
for _, object in ipairs(Workspace:GetDescendants()) do
if IsCoinCandidate(object) then
result[#result + 1] = object
end
end
end
return result
end
function FindDroppedGun()
local best = nil
local bestDistance = math.huge
local localRoot = GetRoot(LP)
for _, object in ipairs(GetGunCandidates()) do
local part = GetAdornmentPart(object)
if part then
local distance = localRoot
and (part.Position - localRoot.Position).Magnitude
or 0
if distance < bestDistance then
best = object
bestDistance = distance
end
end
end
return best, bestDistance
end
