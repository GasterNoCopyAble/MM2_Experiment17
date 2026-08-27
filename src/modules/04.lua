-- Experiment17 MM2 modular v7 | module 04
function GetWorldInterval()
local interval = RateToInterval(State.WorldUpdateRate, true)
if State.AdaptivePerformance and State.CurrentFPS < State.AdaptiveFPSMin then
interval = math.max(interval, 0.75)
end
if State.FPSGuardActive then
interval = math.max(interval, 1.0)
end
return interval
end
Connect(RunService.RenderStepped, function(dt)
State.FPSAccumulator += dt
State.FPSFrames += 1
if State.FPSAccumulator >= 1 then
State.CurrentFPS = State.FPSFrames / State.FPSAccumulator
State.FPSAccumulator = 0
State.FPSFrames = 0
local now = os.clock()
if State.LowFPSWarning
and State.CurrentFPS < State.LowFPSWarningThreshold
and now - State.LastLowFPSWarning >= 8
then
State.LastLowFPSWarning = now
Notify(
"Low FPS Warning",
string.format("FPS: %.0f", State.CurrentFPS),
"Warning",
3,
"Performance"
)
end
if State.FPSGuard then
if State.CurrentFPS < State.FPSGuardThreshold then
State.FPSGuardHighSince = nil
State.FPSGuardLowSince = State.FPSGuardLowSince or now
if not State.FPSGuardActive and now - State.FPSGuardLowSince >= 2 then
State.FPSGuardActive = true
Notify(
"FPS Guard",
"Heavy visuals throttled",
"Warning",
3,
"Performance"
)
end
else
State.FPSGuardLowSince = nil
if State.FPSGuardActive and State.CurrentFPS >= State.FPSGuardThreshold + 8 then
State.FPSGuardHighSince = State.FPSGuardHighSince or now
if now - State.FPSGuardHighSince >= 3 then
State.FPSGuardActive = false
State.FPSGuardHighSince = nil
Notify(
"FPS Guard",
"Normal visual quality restored",
"Success",
3,
"Performance"
)
end
else
State.FPSGuardHighSince = nil
end
end
else
State.FPSGuardActive = false
State.FPSGuardLowSince = nil
State.FPSGuardHighSince = nil
end
end
end)
function SetEdgeArrow(arrow, worldPosition, color, radiusScale)
Camera = Workspace.CurrentCamera or Camera
if not Camera or not arrow then return false end
local point, onScreen = Camera:WorldToViewportPoint(worldPosition)
if onScreen and point.Z > 0 then
arrow.Visible = false
return false
end
local viewport = Camera.ViewportSize
local center = Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
local delta = Vector2.new(point.X, point.Y) - center
if point.Z < 0 then delta = -delta end
if delta.Magnitude < 0.001 then
delta = Vector2.new(0, -1)
else
delta = delta.Unit
end
local radius = math.min(viewport.X, viewport.Y) * (radiusScale or 0.42)
local position = center + delta * radius
arrow.Position = UDim2.fromOffset(position.X, position.Y)
arrow.Rotation = math.deg(math.atan2(delta.Y, delta.X)) + 90
arrow.TextColor3 = color
arrow.Visible = true
return true
end
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
