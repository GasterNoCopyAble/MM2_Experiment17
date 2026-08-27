-- Experiment17 MM2 modular v7 | module 07
function FindNearestCoins()
local localRoot = GetRoot(LP)
if not localRoot then return {} end
local candidates = {}
local seenParts = {}
for _, object in ipairs(GetCoinCandidates()) do
local part = GetAdornmentPart(object)
if part and not seenParts[part] then
seenParts[part] = true
local distance = (part.Position - localRoot.Position).Magnitude
if distance <= State.CoinMaxDistance then
candidates[#candidates + 1] = {
Object = object,
Part = part,
Distance = distance,
}
end
end
end
table.sort(candidates, function(a, b)
return a.Distance < b.Distance
end)
return candidates
end
GunESPObject
CachedDroppedGun
CachedDroppedGunDistance = math.huge
CachedNearestCoin
function CleanupGunESP()
if not GunESPObject then return end
if GunESPObject.Highlight then GunESPObject.Highlight:Destroy() end
if GunESPObject.Billboard then GunESPObject.Billboard:Destroy() end
GunESPObject = nil
end
function UpdateGunESP(gun, distance)
if not State.DroppedGunESP or State.ScreenshotMode then
CleanupGunESP()
return
end
local part = GetAdornmentPart(gun)
if not gun or not part then
CleanupGunESP()
return
end
if distance > State.DroppedGunMaxDistance then
CleanupGunESP()
return
end
if not GunESPObject or GunESPObject.Target ~= gun then
CleanupGunESP()
local highlight = Instance.new("Highlight")
highlight.Name = "E17_DroppedGunESP"
highlight.Adornee = gun
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
highlight.FillTransparency = 0.35
highlight.OutlineTransparency = 0
highlight.Parent = part
local gui = Instance.new("BillboardGui")
gui.Name = "E17_DroppedGunLabel"
gui.Adornee = part
gui.AlwaysOnTop = true
gui.Size = UDim2.fromOffset(180, 34)
gui.StudsOffset = Vector3.new(0, 2, 0)
gui.Parent = part
local label = Instance.new("TextLabel")
label.Parent = gui
label.Size = UDim2.fromScale(1, 1)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBold
label.TextSize = 14
label.TextStrokeTransparency = 0.2
label.Text = "DROPPED GUN"
GunESPObject = {
Target = gun,
Highlight = highlight,
Billboard = gui,
Label = label,
}
end
GunESPObject.Highlight.FillColor = State.DroppedGunColor
GunESPObject.Highlight.OutlineColor = State.DroppedGunColor
GunESPObject.Label.TextColor3 = State.DroppedGunColor
GunESPObject.Label.Text = string.format("DROPPED GUN | %d", math.floor(distance + 0.5))
end
function PickupDroppedGun()
if State.GunPickupBusy then return false end
local gun, distance = FindDroppedGun()
local part = GetAdornmentPart(gun)
local root = GetRoot(LP)
if not gun or not part or not root then
Notify("Gun Pickup TP", "Dropped gun not found", "Warning")
return false
end
State.GunPickupBusy = true
State.LastReturnCFrame = root.CFrame
local oldCF = root.CFrame
local oldLinear = root.AssemblyLinearVelocity
local oldAngular = root.AssemblyAngularVelocity
root.CFrame = part.CFrame * CFrame.new(0, 2.2, 0)
root.AssemblyLinearVelocity = Vector3.zero
root.AssemblyAngularVelocity = Vector3.zero
if type(firetouchinterest) == "function" then
pcall(function()
firetouchinterest(root, part, 0)
firetouchinterest(root, part, 1)
end)
end
task.wait(0.18)
root = GetRoot(LP)
if root then
root.CFrame = oldCF
root.AssemblyLinearVelocity = oldLinear
root.AssemblyAngularVelocity = oldAngular
end
State.GunPickupBusy = false
return true
end
CoinObjects = {}
function CleanupCoinObject(object)
local data = CoinObjects[object]
if not data then return end
if data.Highlight then data.Highlight:Destroy() end
if data.Billboard then data.Billboard:Destroy() end
CoinObjects[object] = nil
end
function CleanupCoins()
for object in pairs(CoinObjects) do
CleanupCoinObject(object)
end
end
function UpdateCoinESP(nearestCoins)
if not State.CoinESP or State.ScreenshotMode or State.FPSGuardActive then
CleanupCoins()
return
end
local found = {}
local limit = math.min(State.CoinLimit, State.CoinNearestCount)
for index, item in ipairs(nearestCoins) do
if index > limit then break end
local object = item.Object
local part = item.Part
found[object] = true
local data = CoinObjects[object]
if not data then
local highlight = Instance.new("Highlight")
highlight.Name = "E17_CoinESP"
highlight.Adornee = object
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
highlight.FillTransparency = 0.45
highlight.OutlineTransparency = 0
highlight.Parent = part
local gui = Instance.new("BillboardGui")
gui.Name = "E17_CoinLabel"
gui.Adornee = part
gui.AlwaysOnTop = true
gui.Size = UDim2.fromOffset(110, 24)
gui.StudsOffset = Vector3.new(0, 1.4, 0)
gui.Parent = part
local label = Instance.new("TextLabel")
label.Parent = gui
label.Size = UDim2.fromScale(1, 1)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBold
label.TextSize = 11
label.TextStrokeTransparency = 0.25
data = {
Highlight = highlight,
Billboard = gui,
Label = label,
}
CoinObjects[object] = data
end
data.Highlight.FillColor = State.CoinColor
data.Highlight.OutlineColor = State.CoinColor
data.Label.TextColor3 = State.CoinColor
data.Label.Text = string.format("COIN | %d", math.floor(item.Distance + 0.5))
end
for object in pairs(CoinObjects) do
if not found[object] or not object.Parent then
CleanupCoinObject(object)
end
end
end
task.spawn(function()
local previousGun = nil
while not Library.Unloaded do
local interval = math.max(GetWorldInterval(), 0.08)
task.wait(interval)
local gun, gunDistance = FindDroppedGun()
CachedDroppedGun = gun
CachedDroppedGunDistance = gunDistance or math.huge
if gun ~= previousGun then
if gun and State.GunSpawnNotification then
Notify(
"Gun Spawn",
string.format("Dropped gun found | %d studs", math.floor(CachedDroppedGunDistance + 0.5)),
"Info",
3,
"Gun"
)
end
previousGun = gun
end
if gun
and State.AutoGunPickup
and not State.GunPickupBusy
and CachedDroppedGunDistance <= State.AutoGunPickupRange
and os.clock() - State.LastAutoGunPickup >= 1.2
then
State.LastAutoGunPickup = os.clock()
task.spawn(PickupDroppedGun)
end
UpdateGunESP(gun, CachedDroppedGunDistance)
local nearestCoins = FindNearestCoins()
CachedNearestCoin = nearestCoins[1]
UpdateCoinESP(nearestCoins)
if State.DroppedGunDistanceHUD and gun then
GunHUDText.Text = string.format("Distance: %d studs", math.floor(CachedDroppedGunDistance + 0.5))
elseif State.DroppedGunDistanceHUD then
GunHUDText.Text = "Not dropped"
end
end
end)
Connect(RunService.RenderStepped, function()
if State.ScreenshotMode then
DroppedGunArrowGui.Visible = false
NearestCoinArrowGui.Visible = false
return
end
if State.DroppedGunArrow and CachedDroppedGun then
local part = GetAdornmentPart(CachedDroppedGun)
if part then
SetEdgeArrow(DroppedGunArrowGui, part.Position, State.DroppedGunColor, 0.37)
else
DroppedGunArrowGui.Visible = false
end
else
DroppedGunArrowGui.Visible = false
end
if State.NearestCoinArrow and CachedNearestCoin and CachedNearestCoin.Part then
SetEdgeArrow(NearestCoinArrowGui, CachedNearestCoin.Part.Position, State.CoinColor, 0.33)
else
NearestCoinArrowGui.Visible = false
end
end)
function HasLineOfSight(fromRoot, targetPlayer, targetRoot)
if not fromRoot or not targetPlayer or not targetRoot then return false end
local delta = targetRoot.Position - fromRoot.Position
if delta.Magnitude <= 0.01 then return true end
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude
params.IgnoreWater = true
local exclude = {}
local murderer = GetMurderer()
if murderer and murderer.Character then table.insert(exclude, murderer.Character) end
params.FilterDescendantsInstances = exclude
local result = Workspace:Raycast(fromRoot.Position, delta, params)
return result == nil
or (targetPlayer.Character and result.Instance:IsDescendantOf(targetPlayer.Character))
end
function UpdateThreatHUD(murderer, distance, approachSpeed)
local showThreatHUD = State.MurdererDistanceHUD
or State.MurdererApproachHUD
or State.MurdererDangerBar
or State.MinimalHUD
ThreatHUD.Visible = showThreatHUD and not State.ScreenshotMode
ThreatDangerBack.Visible = State.MurdererDangerBar or State.MinimalHUD
if not showThreatHUD then return end
if murderer and distance then
local lines = {}
if State.MurdererDistanceHUD or State.MinimalHUD then
lines[#lines + 1] = string.format("%s | %d studs", GetStreamerDisplayName(murderer), math.floor(distance + 0.5))
end
if State.MurdererApproachHUD and not State.MinimalHUD then
local direction = approachSpeed > 1 and "CLOSING" or approachSpeed < -1 and "LEAVING" or "STABLE"
lines[#lines + 1] = string.format("%s | %.1f studs/s", direction, math.abs(approachSpeed))
end
ThreatHUDText.Text = table.concat(lines, "\n")
local dangerDistance = math.max(State.MurdererWarningDistance * 2, 50)
local danger = 1 - math.clamp(distance / dangerDistance, 0, 1)
ThreatDangerFill.Size = UDim2.fromScale(danger, 1)
ThreatDangerFill.BackgroundColor3 = Color3.fromHSV((1 - danger) * 0.33, 0.9, 1)
else
ThreatHUDText.Text = "Murderer unavailable"
ThreatDangerFill.Size = UDim2.fromScale(0, 1)
end
end
task.spawn(function()
while not Library.Unloaded do
task.wait(0.10)
local murderer = GetMurderer()
local murderRoot = GetRoot(murderer)
local localRoot = GetRoot(LP)
local now = os.clock()
if murderer and murderer ~= LP and murderRoot and localRoot then
local delta = murderRoot.Position - localRoot.Position
local distance = delta.Magnitude
local approachSpeed = 0
if State.LastMurdererDistance and State.LastMurdererDistanceAt > 0 then
local dt = math.max(now - State.LastMurdererDistanceAt, 0.001)
approachSpeed = (State.LastMurdererDistance - distance) / dt
end
State.MurdererApproachSpeed = approachSpeed
State.LastMurdererDistance = distance
State.LastMurdererDistanceAt = now
if State.MurdererWarning then
if distance <= State.MurdererWarningDistance then
if State.MurdererWarningArmed
and now - State.LastMurdererWarning >= State.MurdererWarningCooldown
then
State.LastMurdererWarning = now
State.MurdererWarningArmed = false
Notify(
"Murderer Warning",
string.format("%s is %d studs away", GetStreamerDisplayName(murderer), math.floor(distance + 0.5)),
"Warning",
2.4,
"Murderer"
)
end
else
State.MurdererWarningArmed = true
end
end
if State.MurdererBehindWarning
and distance <= math.max(State.MurdererWarningDistance * 1.5, 60)
and delta.Magnitude > 0.01
then
local behindDot = localRoot.CFrame.LookVector:Dot(delta.Unit)
if behindDot < -0.35 and now - State.LastBehindWarning >= State.MurdererWarningCooldown then
State.LastBehindWarning = now
Notify(
"Murderer Behind",
string.format("%d studs behind you", math.floor(distance + 0.5)),
"Warning",
2.4,
"Murderer"
)
end
end
if State.MurdererLOSWarning and distance <= 140 then
local towardLocal = localRoot.Position - murderRoot.Position
local lookingDot = towardLocal.Magnitude > 0.01
and murderRoot.CFrame.LookVector:Dot(towardLocal.Unit)
or -1
if lookingDot > 0.70
and HasLineOfSight(murderRoot, LP, localRoot)
and now - State.LastLOSWarning >= State.MurdererWarningCooldown
then
State.LastLOSWarning = now
Notify(
"Murderer Line Of Sight",
"Murderer is facing you with a clear line of sight",
"Warning",
2.4,
"Murderer"
)
end
end
if State.ClosingSpeedWarning
and approachSpeed >= State.ClosingSpeedThreshold
and distance <= 120
and now - State.LastClosingWarning >= State.MurdererWarningCooldown
then
State.LastClosingWarning = now
Notify(
"Murderer Closing Speed",
string.format("Closing at %.1f studs/s", approachSpeed),
"Warning",
2.4,
"Murderer"
)
end
local knife = GetEquippedTool(murderer)
local knifeEquipped = knife and string.lower(knife.Name) == "knife" or false
if State.KnifeEquippedWarning and knifeEquipped and not State.KnifeWasEquipped then
Notify(
"Knife Equipped",
GetStreamerDisplayName(murderer) .. " equipped Knife",
"Warning",
2.5,
"Weapons"
)
end
State.KnifeWasEquipped = knifeEquipped
UpdateThreatHUD(murderer, distance, approachSpeed)
else
State.LastMurdererDistance = nil
State.LastMurdererDistanceAt = 0
State.MurdererApproachSpeed = 0
State.KnifeWasEquipped = false
UpdateThreatHUD(nil, nil, 0)
end
if State.GunEquippedWarning then
for _, owner in ipairs({GetSheriff(), GetHero()}) do
if owner then
local tool = GetEquippedTool(owner)
local equipped = tool and string.lower(tool.Name) == "gun" or false
local was = State.GunOwnersEquipped[owner.Name] == true
if equipped and not was then
Notify(
"Gun Equipped",
GetStreamerDisplayName(owner) .. " equipped Gun",
"Info",
2.5,
"Weapons"
)
end
State.GunOwnersEquipped[owner.Name] = equipped
end
end
end
end
end)
function GetRoleArrowPlayer()
if State.RoleArrowTarget == "Murderer" then return GetMurderer() end
if State.RoleArrowTarget == "Sheriff" then return GetSheriff() end
if State.RoleArrowTarget == "Hero" then return GetHero() end
return nil
end
Connect(RunService.RenderStepped, function()
if State.ScreenshotMode or not State.RoleArrow then
RoleArrowGui.Visible = false
return
end
local player = GetRoleArrowPlayer()
local root = GetRoot(player)
if not player or not root or player == LP then
RoleArrowGui.Visible = false
return
end
RoleArrowGui.TextSize = State.RoleArrowSize
SetEdgeArrow(
RoleArrowGui,
root.Position,
GetRoleColor(player),
State.RoleArrowRadius
)
end)
XRayCache = setmetatable({}, {__mode = "k"})
XRayActive = setmetatable({}, {__mode = "k"})
function RestoreXRayPart(part)
local old = XRayCache[part]
if old ~= nil and part and part.Parent then
pcall(function()
part.LocalTransparencyModifier = old
end)
end
end
