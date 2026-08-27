-- Experiment 17 | Private MM2 modular v7 | ESP
-- Semantic feature module. Loaded by init.lua into one shared runtime environment.

ESPObjects = {}
LastESPFrameUpdate = 0
R15SkeletonPairs = {
{"Head", "UpperTorso"},
{"UpperTorso", "LowerTorso"},
{"UpperTorso", "LeftUpperArm"},
{"LeftUpperArm", "LeftLowerArm"},
{"LeftLowerArm", "LeftHand"},
{"UpperTorso", "RightUpperArm"},
{"RightUpperArm", "RightLowerArm"},
{"RightLowerArm", "RightHand"},
{"LowerTorso", "LeftUpperLeg"},
{"LeftUpperLeg", "LeftLowerLeg"},
{"LeftLowerLeg", "LeftFoot"},
{"LowerTorso", "RightUpperLeg"},
{"RightUpperLeg", "RightLowerLeg"},
{"RightLowerLeg", "RightFoot"},
}
R6SkeletonPairs = {
{"Head", "Torso"},
{"Torso", "Left Arm"},
{"Torso", "Right Arm"},
{"Torso", "Left Leg"},
{"Torso", "Right Leg"},
}
function EscapeRichText(text)
text = tostring(text or "")
text = text:gsub("&", "&amp;")
text = text:gsub("<", "&lt;")
text = text:gsub(">", "&gt;")
return text
end
function IsPlayerVisible(player, targetPart)
Camera = Workspace.CurrentCamera or Camera
if not Camera or not player or not targetPart then return false end
local origin = Camera.CFrame.Position
local delta = targetPart.Position - origin
if delta.Magnitude <= 0.01 then return true end
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude
params.IgnoreWater = true
local exclude = {}
if LP.Character then table.insert(exclude, LP.Character) end
params.FilterDescendantsInstances = exclude
local hit = Workspace:Raycast(origin, delta, params)
return hit == nil
or (player.Character and hit.Instance:IsDescendantOf(player.Character))
end
function GetJumpState(humanoid)
if not humanoid then return "Unknown" end
local state = humanoid:GetState()
if state == Enum.HumanoidStateType.Jumping then return "Jumping" end
if state == Enum.HumanoidStateType.Freefall then return "Falling" end
if state == Enum.HumanoidStateType.Landed then return "Landed" end
if state == Enum.HumanoidStateType.Climbing then return "Climbing" end
if state == Enum.HumanoidStateType.Swimming then return "Swimming" end
if humanoid.FloorMaterial ~= Enum.Material.Air then return "Grounded" end
return state.Name
end
function EnsureDrawingLinePool(pool, count)
if not DrawingAvailable then return end
for i = #pool + 1, count do
local line = TrackDrawing(Drawing.new("Line"))
line.Transparency = 1
line.Thickness = 1
line.Visible = false
pool[i] = line
end
end
function HideLinePool(pool)
for _, line in ipairs(pool or {}) do
line.Visible = false
end
end
function CleanupESPPlayer(player)
local data = ESPObjects[player]
if not data then return end
if data.Highlight then data.Highlight:Destroy() end
if data.Billboard then data.Billboard:Destroy() end
if data.OffscreenArrow then data.OffscreenArrow:Destroy() end
if data.DirectionArrow then data.DirectionArrow:Destroy() end
if data.RoundedBox then data.RoundedBox:Destroy() end
RemoveDrawing(data.Box)
RemoveDrawing(data.Tracer)
RemoveDrawing(data.HealthBack)
RemoveDrawing(data.HealthBar)
RemoveDrawing(data.HeadDot)
RemoveDrawing(data.LastSeenText)
for _, line in ipairs(data.SkeletonLines or {}) do RemoveDrawing(line) end
for _, line in ipairs(data.TrailLines or {}) do RemoveDrawing(line) end
ESPObjects[player] = nil
end
function EnsureESPPlayer(player)
if player == LP then return nil end
local data = ESPObjects[player]
if not data then
data = {
SkeletonLines = {},
TrailLines = {},
TrailPoints = {},
LastTrailSample = 0,
LastVisiblePosition = nil,
LastVisibleTime = 0,
Visible = false,
}
ESPObjects[player] = data
end
local character = player.Character
if not character then return data end
if not data.Highlight or data.Highlight.Parent ~= character then
if data.Highlight then data.Highlight:Destroy() end
local h = Instance.new("Highlight")
h.Name = "E17_ESP_Highlight"
h.Adornee = character
h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
h.FillTransparency = State.ESPHighlightTransparency
h.OutlineTransparency = 0
h.Parent = character
data.Highlight = h
end
local head = character:FindFirstChild("Head")
or character:FindFirstChild("HumanoidRootPart")
if head and (not data.Billboard or data.Billboard.Adornee ~= head) then
if data.Billboard then data.Billboard:Destroy() end
local gui = Instance.new("BillboardGui")
gui.Name = "E17_ESP_Info"
gui.AlwaysOnTop = true
gui.Adornee = head
gui.Size = UDim2.fromOffset(320, 118)
gui.StudsOffset = Vector3.new(0, 3.2, 0)
gui.Parent = head
local label = Instance.new("TextLabel")
label.Name = "Info"
label.Parent = gui
label.Size = UDim2.fromScale(1, 1)
label.BackgroundColor3 = Color3.new(0, 0, 0)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBold
label.TextSize = 14
label.RichText = true
label.TextWrapped = true
label.TextStrokeTransparency = 0.2
label.BorderSizePixel = 0
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 5)
corner.Parent = label
data.Billboard = gui
data.Label = label
end
if not data.OffscreenArrow then
local arrow = Instance.new("TextLabel")
arrow.Name = "ESPArrow_" .. player.Name
arrow.Parent = Overlay
arrow.AnchorPoint = Vector2.new(0.5, 0.5)
arrow.Size = UDim2.fromOffset(30, 30)
arrow.BackgroundTransparency = 1
arrow.Text = "▲"
arrow.Font = Enum.Font.GothamBold
arrow.TextSize = 22
arrow.TextStrokeTransparency = 0.2
arrow.Visible = false
arrow.ZIndex = 76
data.OffscreenArrow = arrow
end
if not data.DirectionArrow then
local arrow = Instance.new("TextLabel")
arrow.Name = "MoveArrow_" .. player.Name
arrow.Parent = Overlay
arrow.AnchorPoint = Vector2.new(0.5, 0.5)
arrow.Size = UDim2.fromOffset(22, 22)
arrow.BackgroundTransparency = 1
arrow.Text = "▲"
arrow.Font = Enum.Font.GothamBold
arrow.TextSize = 15
arrow.TextStrokeTransparency = 0.2
arrow.Visible = false
arrow.ZIndex = 77
data.DirectionArrow = arrow
end
if not data.RoundedBox then
local frame = Instance.new("Frame")
frame.Name = "RoundedESPBox_" .. player.Name
frame.Parent = Overlay
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.Visible = false
frame.ZIndex = 74
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 7)
corner.Parent = frame
local stroke = Instance.new("UIStroke")
stroke.Name = "Stroke"
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Thickness = 1.4
stroke.Transparency = 0
stroke.Parent = frame
data.RoundedBox = frame
data.RoundedStroke = stroke
end
if DrawingAvailable then
if not data.Box then
data.Box = TrackDrawing(Drawing.new("Square"))
data.Box.Filled = false
data.Box.Transparency = 1
end
if not data.Tracer then
data.Tracer = TrackDrawing(Drawing.new("Line"))
data.Tracer.Transparency = 1
end
if not data.HealthBack then
data.HealthBack = TrackDrawing(Drawing.new("Line"))
data.HealthBack.Color = Color3.new(0, 0, 0)
data.HealthBack.Transparency = 1
end
if not data.HealthBar then
data.HealthBar = TrackDrawing(Drawing.new("Line"))
data.HealthBar.Transparency = 1
end
if not data.HeadDot then
data.HeadDot = TrackDrawing(Drawing.new("Circle"))
data.HeadDot.Filled = true
data.HeadDot.NumSides = 24
data.HeadDot.Radius = 3
data.HeadDot.Transparency = 1
end
if not data.LastSeenText then
data.LastSeenText = TrackDrawing(Drawing.new("Text"))
data.LastSeenText.Center = true
data.LastSeenText.Outline = true
data.LastSeenText.Size = 12
data.LastSeenText.Text = "LAST SEEN"
data.LastSeenText.Transparency = 1
end
EnsureDrawingLinePool(data.SkeletonLines, 14)
EnsureDrawingLinePool(data.TrailLines, 30)
end
return data
end
function HideESPVisuals(data)
if data.Highlight then data.Highlight.Enabled = false end
if data.Billboard then data.Billboard.Enabled = false end
if data.OffscreenArrow then data.OffscreenArrow.Visible = false end
if data.DirectionArrow then data.DirectionArrow.Visible = false end
if data.RoundedBox then data.RoundedBox.Visible = false end
if data.Box then data.Box.Visible = false end
if data.Tracer then data.Tracer.Visible = false end
if data.HealthBack then data.HealthBack.Visible = false end
if data.HealthBar then data.HealthBar.Visible = false end
if data.HeadDot then data.HeadDot.Visible = false end
if data.LastSeenText then data.LastSeenText.Visible = false end
HideLinePool(data.SkeletonLines)
HideLinePool(data.TrailLines)
end
function GetScreenBox(character)
local ok, boxCF, boxSize = pcall(function()
return character:GetBoundingBox()
end)
if not ok or not boxCF or not boxSize then return nil end
local hx, hy, hz = boxSize.X / 2, boxSize.Y / 2, boxSize.Z / 2
local offsets = {
Vector3.new(-hx,-hy,-hz), Vector3.new(-hx,-hy,hz),
Vector3.new(-hx,hy,-hz),  Vector3.new(-hx,hy,hz),
Vector3.new(hx,-hy,-hz),  Vector3.new(hx,-hy,hz),
Vector3.new(hx,hy,-hz),   Vector3.new(hx,hy,hz),
}
local minX, minY = math.huge, math.huge
local maxX, maxY = -math.huge, -math.huge
local visibleCount = 0
for _, offset in ipairs(offsets) do
local world = boxCF:PointToWorldSpace(offset)
local point = Camera:WorldToViewportPoint(world)
if point.Z > 0 then
visibleCount += 1
minX = math.min(minX, point.X)
minY = math.min(minY, point.Y)
maxX = math.max(maxX, point.X)
maxY = math.max(maxY, point.Y)
end
end
if visibleCount == 0 then return nil end
return Vector2.new(minX, minY), Vector2.new(maxX - minX, maxY - minY)
end
function DrawSkeleton(data, character, color, alpha, thickness)
if not DrawingAvailable or not State.ESPSkeleton or State.FPSGuardActive then
HideLinePool(data.SkeletonLines)
return
end
local humanoid = character:FindFirstChildOfClass("Humanoid")
local pairsList = humanoid and humanoid.RigType == Enum.HumanoidRigType.R6
and R6SkeletonPairs
or R15SkeletonPairs
EnsureDrawingLinePool(data.SkeletonLines, #pairsList)
for index, pair in ipairs(pairsList) do
local a = character:FindFirstChild(pair[1])
local b = character:FindFirstChild(pair[2])
local line = data.SkeletonLines[index]
if a and b then
local pa = Camera:WorldToViewportPoint(a.Position)
local pb = Camera:WorldToViewportPoint(b.Position)
if pa.Z > 0 and pb.Z > 0 then
line.From = Vector2.new(pa.X, pa.Y)
line.To = Vector2.new(pb.X, pb.Y)
line.Color = color
line.Thickness = thickness
line.Transparency = alpha
line.Visible = true
else
line.Visible = false
end
else
line.Visible = false
end
end
for index = #pairsList + 1, #data.SkeletonLines do
data.SkeletonLines[index].Visible = false
end
end
function UpdateTrail(data, player, root, color, alpha, now)
local role = GetRole(player)
local roleTrail = State.ESPRoleTrail and (role == "Murderer" or role == "Sheriff" or role == "Hero")
local enabled = State.ESPPlayerTrailHistory or roleTrail
if not enabled or State.FPSGuardActive then
HideLinePool(data.TrailLines)
return
end
if now - data.LastTrailSample >= 0.10 then
data.LastTrailSample = now
table.insert(data.TrailPoints, {
Position = root.Position,
Time = now,
})
end
local cutoff = now - State.ESPTrailSeconds
while data.TrailPoints[1] and data.TrailPoints[1].Time < cutoff do
table.remove(data.TrailPoints, 1)
end
local maxSegments = math.min(#data.TrailPoints - 1, 30)
EnsureDrawingLinePool(data.TrailLines, math.max(maxSegments, 0))
for i = 1, maxSegments do
local a = data.TrailPoints[i]
local b = data.TrailPoints[i + 1]
local line = data.TrailLines[i]
local pa = Camera:WorldToViewportPoint(a.Position)
local pb = Camera:WorldToViewportPoint(b.Position)
if pa.Z > 0 and pb.Z > 0 then
local age = math.clamp((now - b.Time) / State.ESPTrailSeconds, 0, 1)
line.From = Vector2.new(pa.X, pa.Y)
line.To = Vector2.new(pb.X, pb.Y)
line.Color = color
line.Thickness = roleTrail and 2 or 1.2
line.Transparency = alpha * (1 - age * 0.78)
line.Visible = true
else
line.Visible = false
end
end
for i = maxSegments + 1, #data.TrailLines do
data.TrailLines[i].Visible = false
end
end
Connect(RunService.RenderStepped, function()
if Library.Unloaded then return end
local now = os.clock()
local interval = GetESPInterval()
if interval > 0 and now - LastESPFrameUpdate < interval then return end
LastESPFrameUpdate = now
Camera = Workspace.CurrentCamera or Camera
if not Camera then return end
Overlay.Visible = not State.ScreenshotMode
HUDRoot.Visible = not State.ScreenshotMode
if not State.ESP or State.ScreenshotMode then
for _, data in pairs(ESPObjects) do
HideESPVisuals(data)
end
return
end
local localRoot = GetRoot(LP)
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LP then
if not IsPlayerESPAllowed(player) then
local existing = ESPObjects[player]
if existing then HideESPVisuals(existing) end
else
local data = EnsureESPPlayer(player)
local character = player.Character
local root = GetRoot(player)
local humanoid = GetHumanoid(player)
if not data or not character or not root or not humanoid then
if data then HideESPVisuals(data) end
else
local distance = localRoot
and (root.Position - localRoot.Position).Magnitude
or math.huge
local pinned = State.PinnedPlayers[player.Name] == true
local alive = IsAliveFromRoleData(player) and humanoid.Health > 0
local inDistance = distance <= State.ESPMaxDistance or pinned
local visible = alive and inDistance
local head = character:FindFirstChild("Head") or root
local sightVisible = false
if State.ESPVisibleCheck or State.ESPLastSeen then
sightVisible = IsPlayerVisible(player, head)
data.Visible = sightVisible
if sightVisible then
data.LastVisiblePosition = root.Position
data.LastVisibleTime = now
end
end
local color = GetRoleColor(player)
local priorityColor = State.PlayerCustomColors[player.Name] ~= nil
or (State.ESPTargetHighlight and State.TargetPlayerName == player.Name)
if State.ESPVisibleCheck and sightVisible and not priorityColor then
color = State.ESPVisibleColor
end
local threatPriority = State.ESPThreatPriority
and GetRole(player) == "Murderer"
and distance <= State.ESPThreatPriorityDistance
if threatPriority then
color = color:Lerp(Color3.new(1, 1, 1), 0.22)
end
local fade = 1
if State.ESPDistanceFade and not pinned then
fade = math.clamp(1 - (distance / math.max(State.ESPMaxDistance, 1)) * 0.78, 0.18, 1)
end
local thickness = State.ESPLineThickness + (threatPriority and 1 or 0)
if data.Highlight then
data.Highlight.Enabled = visible and State.ESPHighlight
data.Highlight.FillColor = color
data.Highlight.OutlineColor = color
data.Highlight.FillTransparency = math.clamp(
State.ESPHighlightTransparency + (1 - fade) * 0.28,
0,
1
)
data.Highlight.OutlineTransparency = 1 - fade
end
if data.Billboard and data.Label then
data.Billboard.Enabled = visible and (
State.ESPNames or State.ESPUsername or State.ESPRole
or State.ESPHealth or State.ESPDistance or State.ESPWeapon
or State.ESPVelocity or State.ESPJumpState
)
data.Label.BackgroundTransparency = State.ESPBackground
and math.clamp(State.ESPBackgroundTransparency + (1 - fade) * 0.3, 0, 1)
or 1
data.Label.TextTransparency = 1 - fade
data.Label.TextStrokeTransparency = math.clamp(0.2 + (1 - fade) * 0.6, 0, 1)
local lines = {}
if State.ESPNames and not (State.StreamerMode and State.StreamerStyle == "Role Only") then
table.insert(lines, string.format(
'<font size="%d"><b>%s</b></font>',
State.ESPNameTextSize + (threatPriority and 2 or 0),
EscapeRichText(GetStreamerDisplayName(player))
))
end
if State.ESPUsername and not State.StreamerMode then
table.insert(lines, string.format(
'<font size="%d">@%s</font>',
State.ESPInfoTextSize,
EscapeRichText(player.Name)
))
end
if State.ESPRole then
table.insert(lines, string.format(
'<font size="%d">[%s]</font>',
State.ESPRoleTextSize,
EscapeRichText(GetRole(player))
))
end
local info = {}
if State.ESPHealth then
local maxHealth = math.max(tonumber(humanoid.MaxHealth) or 100, 1)
local health = math.clamp(tonumber(humanoid.Health) or 0, 0, maxHealth)
local percent = math.floor((health / maxHealth) * 100 + 0.5)
table.insert(info, string.format(
"HP %d/%d (%d%%)",
math.floor(health + 0.5),
math.floor(maxHealth + 0.5),
percent
))
end
if State.ESPDistance then
table.insert(info, string.format("%d studs", math.floor(distance + 0.5)))
end
if State.ESPWeapon then
local tool = GetEquippedTool(player)
if tool then table.insert(info, tool.Name) end
end
if State.ESPVelocity then
table.insert(info, string.format("%.0f s/s", root.AssemblyLinearVelocity.Magnitude))
end
if State.ESPJumpState then
table.insert(info, GetJumpState(humanoid))
end
if #info > 0 then
table.insert(lines, string.format(
'<font size="%d">%s</font>',
State.ESPInfoTextSize,
EscapeRichText(table.concat(info, " | "))
))
end
data.Label.Text = table.concat(lines, "\n")
data.Label.TextColor3 = color
end
local point, onScreen = Camera:WorldToViewportPoint(root.Position)
local boxPos, boxSize = visible and GetScreenBox(character) or nil
if data.OffscreenArrow then
if visible and State.ESPOffscreenArrows and (not onScreen or point.Z <= 0) then
data.OffscreenArrow.TextTransparency = 1 - fade
SetEdgeArrow(data.OffscreenArrow, root.Position, color, 0.42)
else
data.OffscreenArrow.Visible = false
end
end
if data.DirectionArrow then
local velocity = root.AssemblyLinearVelocity
local horizontal = Vector3.new(velocity.X, 0, velocity.Z)
if visible and State.ESPMovementDirection and onScreen and point.Z > 0 and horizontal.Magnitude > 1 then
local future = Camera:WorldToViewportPoint(root.Position + horizontal.Unit * 4)
local delta = Vector2.new(future.X - point.X, future.Y - point.Y)
if delta.Magnitude > 0.1 then
data.DirectionArrow.Position = UDim2.fromOffset(point.X, point.Y - 28)
data.DirectionArrow.Rotation = math.deg(math.atan2(delta.Y, delta.X)) + 90
data.DirectionArrow.TextColor3 = color
data.DirectionArrow.TextTransparency = 1 - fade
data.DirectionArrow.Visible = true
else
data.DirectionArrow.Visible = false
end
else
data.DirectionArrow.Visible = false
end
end
if data.RoundedBox then
if visible and State.ESPBox and State.ESPRoundedBox and boxPos and boxSize then
data.RoundedBox.Position = UDim2.fromOffset(boxPos.X, boxPos.Y)
data.RoundedBox.Size = UDim2.fromOffset(boxSize.X, boxSize.Y)
data.RoundedStroke.Color = color
data.RoundedStroke.Thickness = thickness
data.RoundedStroke.Transparency = 1 - fade
data.RoundedBox.Visible = true
else
data.RoundedBox.Visible = false
end
end
if DrawingAvailable and visible then
if data.Box then
data.Box.Thickness = thickness
data.Box.Transparency = fade
if State.ESPBox and not State.ESPRoundedBox and boxPos and boxSize then
data.Box.Position = boxPos
data.Box.Size = boxSize
data.Box.Color = color
data.Box.Visible = true
else
data.Box.Visible = false
end
end
if data.Tracer then
data.Tracer.Thickness = thickness
data.Tracer.Transparency = fade
if State.ESPTracer and point.Z > 0 then
data.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 10)
data.Tracer.To = Vector2.new(point.X, point.Y)
data.Tracer.Color = color
data.Tracer.Visible = true
else
data.Tracer.Visible = false
end
end
if data.HealthBack and data.HealthBar then
if State.ESPHealthBar and boxPos and boxSize then
local maxHealth = math.max(tonumber(humanoid.MaxHealth) or 100, 1)
local health = math.clamp(tonumber(humanoid.Health) or 0, 0, maxHealth)
local percent = health / maxHealth
local x = boxPos.X - 6
local topY = boxPos.Y
local bottomY = boxPos.Y + boxSize.Y
local healthTopY = bottomY - boxSize.Y * percent
data.HealthBack.From = Vector2.new(x, topY)
data.HealthBack.To = Vector2.new(x, bottomY)
data.HealthBack.Thickness = math.max(3, thickness + 2)
data.HealthBack.Transparency = fade
data.HealthBack.Visible = true
data.HealthBar.From = Vector2.new(x, bottomY)
data.HealthBar.To = Vector2.new(x, healthTopY)
data.HealthBar.Thickness = thickness
data.HealthBar.Color = Color3.fromHSV(percent * 0.33, 0.95, 1)
data.HealthBar.Transparency = fade
data.HealthBar.Visible = true
else
data.HealthBack.Visible = false
data.HealthBar.Visible = false
end
end
if data.HeadDot then
local headPoint = Camera:WorldToViewportPoint(head.Position)
if State.ESPHeadDot and headPoint.Z > 0 then
data.HeadDot.Position = Vector2.new(headPoint.X, headPoint.Y)
data.HeadDot.Color = color
data.HeadDot.Radius = threatPriority and 4 or 3
data.HeadDot.Transparency = fade
data.HeadDot.Visible = true
else
data.HeadDot.Visible = false
end
end
DrawSkeleton(data, character, color, fade, thickness)
UpdateTrail(data, player, root, color, fade, now)
else
if data.Box then data.Box.Visible = false end
if data.Tracer then data.Tracer.Visible = false end
if data.HealthBack then data.HealthBack.Visible = false end
if data.HealthBar then data.HealthBar.Visible = false end
if data.HeadDot then data.HeadDot.Visible = false end
HideLinePool(data.SkeletonLines)
HideLinePool(data.TrailLines)
end
if data.LastSeenText then
if State.ESPLastSeen
and data.LastVisiblePosition
and not sightVisible
and now - data.LastVisibleTime <= State.ESPLastSeenDuration
then
local seen = Camera:WorldToViewportPoint(data.LastVisiblePosition)
if seen.Z > 0 then
data.LastSeenText.Position = Vector2.new(seen.X, seen.Y)
data.LastSeenText.Color = color
data.LastSeenText.Transparency = math.clamp(
1 - ((now - data.LastVisibleTime) / State.ESPLastSeenDuration),
0.15,
1
)
data.LastSeenText.Visible = true
else
data.LastSeenText.Visible = false
end
else
data.LastSeenText.Visible = false
end
end
end
end
end
end
local target = FindPlayer(State.TargetPlayerName)
local targetRoot = GetRoot(target)
if State.TargetArrow and target and targetRoot and target ~= LP then
SetEdgeArrow(TargetArrowGui, targetRoot.Position, State.ESPTargetColor, 0.36)
else
TargetArrowGui.Visible = false
end
if TargetTracerDrawing then
if State.TargetTracer and targetRoot then
local tp = Camera:WorldToViewportPoint(targetRoot.Position)
if tp.Z > 0 then
TargetTracerDrawing.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 8)
TargetTracerDrawing.To = Vector2.new(tp.X, tp.Y)
TargetTracerDrawing.Color = State.ESPTargetColor
TargetTracerDrawing.Thickness = 2.4
TargetTracerDrawing.Transparency = 1
TargetTracerDrawing.Visible = true
else
TargetTracerDrawing.Visible = false
end
else
TargetTracerDrawing.Visible = false
end
end
end)
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
