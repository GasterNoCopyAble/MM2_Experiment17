-- Experiment17 MM2 modular v7 | module 03
function ShootMurdererSequence(retryRemaining)
if State.ShootInProgress then return false end
if retryRemaining == nil then
retryRemaining = State.ShootRetry and State.ShootRetryCount or 0
end
local role = GetLocalRole()
if role ~= "Sheriff" and role ~= "Hero" then
Notify("Shoot Murderer", "Current role is not Sheriff/Hero", "Warning")
return false
end
local murderer = GetMurderer()
local root = GetRoot(LP)
local targetRoot = GetRoot(murderer)
if not murderer or not root or not targetRoot then return false end
local gun = EquipTool("Gun")
if not gun then
Notify("Shoot Murderer", "Gun was not found", "Warning")
return false
end
State.ShootInProgress = true
local oldCF = root.CFrame
local oldLinear = root.AssemblyLinearVelocity
local oldAngular = root.AssemblyAngularVelocity
Camera = Workspace.CurrentCamera or Camera
local oldCamera = Camera and Camera.CFrame
local oldSilent = State.SilentShot
local oldMouse = UIS:GetMouseLocation()
local ok, err = pcall(function()
local deadline = os.clock() + State.ShootFollowTime
while os.clock() < deadline do
murderer = GetMurderer()
root = GetRoot(LP)
targetRoot = GetRoot(murderer)
if not murderer or not root or not targetRoot then break end
local behind = (targetRoot.CFrame * CFrame.new(
0, 0.15, State.ShootBehindDistance
)).Position
root.CFrame = CFrame.lookAt(
behind,
targetRoot.Position,
Vector3.yAxis
)
root.AssemblyLinearVelocity = Vector3.zero
root.AssemblyAngularVelocity = Vector3.zero
Camera = Workspace.CurrentCamera or Camera
if Camera then
Camera.CFrame = CFrame.lookAt(
Camera.CFrame.Position,
targetRoot.Position,
Vector3.yAxis
)
end
RunService.Heartbeat:Wait()
end
if State.ShootTPDelay > 0 then
task.wait(State.ShootTPDelay)
end
murderer = GetMurderer()
targetRoot = GetRoot(murderer)
if not murderer or not targetRoot then return end
local targetPart = murderer.Character and (
murderer.Character:FindFirstChild(State.SilentPart) or targetRoot
)
if not targetPart then return end
if SilentHookAvailable then State.SilentShot = true end
Camera = Workspace.CurrentCamera or Camera
if Camera then
Camera.CFrame = CFrame.lookAt(
Camera.CFrame.Position,
targetRoot.Position,
Vector3.yAxis
)
if type(mousemoveabs) == "function" then
local point = Camera:WorldToViewportPoint(targetPart.Position)
if point.Z > 0 then
pcall(function() mousemoveabs(point.X, point.Y) end)
RunService.RenderStepped:Wait()
end
end
end
State.ShootAttempts += 1
if Controls.ShootAttemptLabel and Controls.ShootAttemptLabel.Label then
Controls.ShootAttemptLabel.Label.Text = "Shoot attempts: " .. tostring(State.ShootAttempts)
end
if type(mouse1click) == "function" then
mouse1click()
else
gun:Activate()
end
task.wait(State.ShootReturnDelay)
end)
State.SilentShot = oldSilent
root = GetRoot(LP)
if root then
root.CFrame = oldCF
root.AssemblyLinearVelocity = oldLinear
root.AssemblyAngularVelocity = oldAngular
end
Camera = Workspace.CurrentCamera or Camera
if Camera and oldCamera then Camera.CFrame = oldCamera end
if type(mousemoveabs) == "function" then
pcall(function() mousemoveabs(oldMouse.X, oldMouse.Y) end)
end
State.ShootInProgress = false
if not ok then
warn("[Experiment17 MM2] Shoot sequence:", err)
end
if ok
and retryRemaining > 0
and State.ShootRetry
and GetMurderer()
then
task.wait(State.ShootRetryDelay)
return ShootMurdererSequence(retryRemaining - 1)
end
return ok
end
task.spawn(function()
while not Library.Unloaded do
task.wait(0.12)
if State.AutoShootMurderer
and not State.ShootInProgress
and (GetLocalRole() == "Sheriff" or GetLocalRole() == "Hero")
and GetMurderer()
then
local now = os.clock()
if now - State.LastGunShot >= 1.15 then
State.LastGunShot = now
task.spawn(ShootMurdererSequence)
end
end
end
end)
Overlay = Instance.new("Frame")
Overlay.Name = "E17_MM2_Overlay"
Overlay.Parent = Library.Root
Overlay.Size = UDim2.fromScale(1, 1)
Overlay.BackgroundTransparency = 1
Overlay.BorderSizePixel = 0
Overlay.ZIndex = 75
RoleArrowGui = Instance.new("TextLabel")
RoleArrowGui.Name = "RoleArrow"
RoleArrowGui.Parent = Overlay
RoleArrowGui.AnchorPoint = Vector2.new(0.5, 0.5)
RoleArrowGui.Size = UDim2.fromOffset(42, 42)
RoleArrowGui.BackgroundTransparency = 1
RoleArrowGui.Text = "▲"
RoleArrowGui.TextStrokeTransparency = 0.15
RoleArrowGui.Font = Enum.Font.GothamBold
RoleArrowGui.TextSize = 28
RoleArrowGui.Visible = false
RoleArrowGui.ZIndex = 78
DroppedGunArrowGui = Instance.new("TextLabel")
DroppedGunArrowGui.Name = "DroppedGunArrow"
DroppedGunArrowGui.Parent = Overlay
DroppedGunArrowGui.AnchorPoint = Vector2.new(0.5, 0.5)
DroppedGunArrowGui.Size = UDim2.fromOffset(38, 38)
DroppedGunArrowGui.BackgroundTransparency = 1
DroppedGunArrowGui.Text = "▲"
DroppedGunArrowGui.TextStrokeTransparency = 0.15
DroppedGunArrowGui.Font = Enum.Font.GothamBold
DroppedGunArrowGui.TextSize = 24
DroppedGunArrowGui.Visible = false
DroppedGunArrowGui.ZIndex = 78
NearestCoinArrowGui = Instance.new("TextLabel")
NearestCoinArrowGui.Name = "NearestCoinArrow"
NearestCoinArrowGui.Parent = Overlay
NearestCoinArrowGui.AnchorPoint = Vector2.new(0.5, 0.5)
NearestCoinArrowGui.Size = UDim2.fromOffset(34, 34)
NearestCoinArrowGui.BackgroundTransparency = 1
NearestCoinArrowGui.Text = "▲"
NearestCoinArrowGui.TextStrokeTransparency = 0.15
NearestCoinArrowGui.Font = Enum.Font.GothamBold
NearestCoinArrowGui.TextSize = 21
NearestCoinArrowGui.Visible = false
NearestCoinArrowGui.ZIndex = 78
TargetArrowGui = Instance.new("TextLabel")
TargetArrowGui.Name = "TargetArrow"
TargetArrowGui.Parent = Overlay
TargetArrowGui.AnchorPoint = Vector2.new(0.5, 0.5)
TargetArrowGui.Size = UDim2.fromOffset(42, 42)
TargetArrowGui.BackgroundTransparency = 1
TargetArrowGui.Text = "▲"
TargetArrowGui.TextStrokeTransparency = 0.12
TargetArrowGui.Font = Enum.Font.GothamBold
TargetArrowGui.TextSize = 27
TargetArrowGui.Visible = false
TargetArrowGui.ZIndex = 79
TargetTracerDrawing
if DrawingAvailable then
TargetTracerDrawing = TrackDrawing(Drawing.new("Line"))
TargetTracerDrawing.Thickness = 2
TargetTracerDrawing.Transparency = 1
TargetTracerDrawing.Visible = false
end
HUDRoot = Instance.new("Frame")
HUDRoot.Name = "E17_MM2_HUD"
HUDRoot.Parent = Library.Root
HUDRoot.Size = UDim2.fromScale(1, 1)
HUDRoot.BackgroundTransparency = 1
HUDRoot.BorderSizePixel = 0
HUDRoot.ZIndex = 68
HUDScale = Instance.new("UIScale")
HUDScale.Name = "HUDScale"
HUDScale.Parent = HUDRoot
HUDScale.Scale = State.HUDScale
HUDFRAMES = {}
function CreateHUDPanel(name, position, size, title)
local frame = Instance.new("Frame")
frame.Name = name
frame.Parent = HUDRoot
frame.Position = position
frame.Size = size
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
frame.BackgroundTransparency = State.HUDOpacity
frame.BorderSizePixel = 0
frame.Active = true
frame.ZIndex = 69
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = frame
local stroke = Instance.new("UIStroke")
stroke.Thickness = 1
stroke.Transparency = 0.25
stroke.Color = Library.Theme.Outline
stroke.Parent = frame
local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = frame
titleLabel.Position = UDim2.fromOffset(8, 4)
titleLabel.Size = UDim2.new(1, -16, 0, 18)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = title or name
titleLabel.TextColor3 = Library.Theme.Accent
titleLabel.TextSize = 11
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 70
local body = Instance.new("TextLabel")
body.Parent = frame
body.Position = UDim2.fromOffset(8, 24)
body.Size = UDim2.new(1, -16, 1, -30)
body.BackgroundTransparency = 1
body.Text = ""
body.TextColor3 = Library.Theme.Text
body.TextSize = 11
body.Font = Enum.Font.Gotham
body.TextXAlignment = Enum.TextXAlignment.Left
body.TextYAlignment = Enum.TextYAlignment.Top
body.TextWrapped = true
body.ZIndex = 70
HUDFRAMES[#HUDFRAMES + 1] = frame
return frame, body, titleLabel
end
ThreatHUD, ThreatHUDText = CreateHUDPanel(
"ThreatHUD",
UDim2.fromOffset(18, 170),
UDim2.fromOffset(220, 92),
"MURDERER"
)
ThreatDangerBack = Instance.new("Frame")
ThreatDangerBack.Parent = ThreatHUD
ThreatDangerBack.Position = UDim2.new(0, 8, 1, -13)
ThreatDangerBack.Size = UDim2.new(1, -16, 0, 5)
ThreatDangerBack.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
ThreatDangerBack.BorderSizePixel = 0
ThreatDangerBack.ZIndex = 70
Instance.new("UICorner", ThreatDangerBack).CornerRadius = UDim.new(1, 0)
ThreatDangerFill = Instance.new("Frame")
ThreatDangerFill.Parent = ThreatDangerBack
ThreatDangerFill.Size = UDim2.fromScale(0, 1)
ThreatDangerFill.BackgroundColor3 = Color3.fromRGB(60, 220, 110)
ThreatDangerFill.BorderSizePixel = 0
ThreatDangerFill.ZIndex = 71
Instance.new("UICorner", ThreatDangerFill).CornerRadius = UDim.new(1, 0)
GunHUD, GunHUDText = CreateHUDPanel(
"GunHUD",
UDim2.fromOffset(18, 270),
UDim2.fromOffset(220, 58),
"DROPPED GUN"
)
TargetHUD, TargetHUDText = CreateHUDPanel(
"TargetHUD",
UDim2.new(1, -238, 0, 170),
UDim2.fromOffset(220, 92),
"TARGET"
)
function ApplyHUDVisualSettings()
HUDScale.Scale = State.HUDScale
for _, frame in ipairs(HUDFRAMES) do
if frame and frame.Parent then
frame.BackgroundTransparency = State.HUDOpacity
end
end
end
function MakeHUDDraggable(frame)
local dragging = false
local dragType
local startPointer
local startPosition
Connect(frame.InputBegan, function(input)
if not State.HUDEditor then return end
if input.UserInputType ~= Enum.UserInputType.MouseButton1
and input.UserInputType ~= Enum.UserInputType.Touch
then
return
end
dragging = true
dragType = input.UserInputType
startPointer = Vector2.new(input.Position.X, input.Position.Y)
startPosition = frame.Position
end)
Connect(UIS.InputChanged, function(input)
if not dragging or not State.HUDEditor then return end
local valid =
(dragType == Enum.UserInputType.MouseButton1 and input.UserInputType == Enum.UserInputType.MouseMovement)
or
(dragType == Enum.UserInputType.Touch and input.UserInputType == Enum.UserInputType.Touch)
if not valid then return end
local pointer = Vector2.new(input.Position.X, input.Position.Y)
local delta = pointer - startPointer
frame.Position = UDim2.new(
startPosition.X.Scale,
startPosition.X.Offset + delta.X,
startPosition.Y.Scale,
startPosition.Y.Offset + delta.Y
)
end)
Connect(UIS.InputEnded, function(input)
if not dragging then return end
if input.UserInputType == dragType then
dragging = false
dragType = nil
end
end)
end
MakeHUDDraggable(ThreatHUD)
MakeHUDDraggable(GunHUD)
MakeHUDDraggable(TargetHUD)
ThreatHUD.Visible = false
GunHUD.Visible = false
TargetHUD.Visible = false
ApplyHUDVisualSettings()
function RateToInterval(rate, isWorld)
rate = tostring(rate or "")
if rate == "Every Frame" then return 0 end
if rate == "60 Hz" then return 1 / 60 end
if rate == "30 Hz" then return 1 / 30 end
if rate == "20 Hz" then return 1 / 20 end
if rate == "15 Hz" then return 1 / 15 end
if rate == "10 Hz" then return 1 / 10 end
if rate == "5 Hz" then return 1 / 5 end
if rate == "2 Hz" then return 1 / 2 end
if rate == "1 Hz" then return 1 end
return isWorld and 0.5 or (1 / 30)
end
function GetESPInterval()
local interval = RateToInterval(State.ESPUpdateRate, false)
if State.AdaptivePerformance and State.CurrentFPS < State.AdaptiveFPSMin then
if State.CurrentFPS < State.AdaptiveFPSMin - 15 then
interval = math.max(interval, 1 / 10)
else
interval = math.max(interval, 1 / 15)
end
end
if State.FPSGuardActive then
interval = math.max(interval, 1 / 10)
end
return interval
end
