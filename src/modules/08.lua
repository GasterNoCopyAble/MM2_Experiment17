-- Experiment17 MM2 modular v7 | module 08
function RestoreXRay()
for part in pairs(XRayActive) do
RestoreXRayPart(part)
XRayActive[part] = nil
end
end
function UpdateXRay()
if not State.XRay or State.ScreenshotMode or State.FPSGuardActive then
RestoreXRay()
return
end
Camera = Workspace.CurrentCamera or Camera
if not Camera then return end
local points = {}
local ignore = {}
if LP.Character then
table.insert(ignore, LP.Character)
end
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LP and player.Character and IsAliveFromRoleData(player) then
local root = GetRoot(player)
local head = player.Character:FindFirstChild("Head")
if root then table.insert(points, root.Position) end
if head then table.insert(points, head.Position) end
table.insert(ignore, player.Character)
end
end
local visibleNow = {}
if #points > 0 then
local ok, parts = pcall(function()
return Camera:GetPartsObscuringTarget(points, ignore)
end)
if ok and type(parts) == "table" then
for _, part in ipairs(parts) do
if part
and part:IsA("BasePart")
and part.Parent
and not IsInsideAnyCharacter(part)
then
if XRayCache[part] == nil then
XRayCache[part] = part.LocalTransparencyModifier
end
part.LocalTransparencyModifier = math.max(
XRayCache[part],
State.XRayTransparency
)
visibleNow[part] = true
XRayActive[part] = true
end
end
end
end
for part in pairs(XRayActive) do
if not visibleNow[part] then
RestoreXRayPart(part)
XRayActive[part] = nil
end
end
end
task.spawn(function()
while not Library.Unloaded do
if State.XRay then UpdateXRay() end
task.wait(0.08)
end
end)
OriginalWalkSpeed = 16
OriginalJumpPower = 50
OriginalJumpHeight = 7.2
function CaptureMovementDefaults()
local humanoid = GetHumanoid(LP)
if not humanoid then return end
OriginalWalkSpeed = humanoid.WalkSpeed
OriginalJumpPower = humanoid.JumpPower
OriginalJumpHeight = humanoid.JumpHeight
end
task.defer(CaptureMovementDefaults)
Connect(RunService.Heartbeat, function()
local humanoid = GetHumanoid(LP)
if not humanoid then return end
if State.WalkSpeed and not State.Fly and not State.GhostMode then
humanoid.WalkSpeed = State.WalkSpeedValue
end
if State.JumpHack then
humanoid.JumpPower = State.JumpPowerValue
if not humanoid.UseJumpPower then
humanoid.JumpHeight =
(State.JumpPowerValue ^ 2) / (2 * Workspace.Gravity)
end
end
end)
FlyVelocity
FlyGyro
FlyRoot
function DestroyFlyObjects(root)
if not root then return end
for _, name in ipairs({"E17_FlyVelocity", "E17_FlyGyro"}) do
local object = root:FindFirstChild(name)
if object then object:Destroy() end
end
end
function CleanupFly()
if FlyVelocity then
pcall(function() FlyVelocity:Destroy() end)
FlyVelocity = nil
end
if FlyGyro then
pcall(function() FlyGyro:Destroy() end)
FlyGyro = nil
end
if FlyRoot and FlyRoot.Parent then
DestroyFlyObjects(FlyRoot)
end
FlyRoot = nil
local humanoid = GetHumanoid(LP)
if humanoid then
humanoid.PlatformStand = false
humanoid.AutoRotate = true
humanoid.WalkSpeed = State.WalkSpeed
and State.WalkSpeedValue
or OriginalWalkSpeed
end
end
function EnsureFlyObjects()
local root = GetRoot(LP)
local humanoid = GetHumanoid(LP)
if not root or not humanoid then return false end
if FlyRoot ~= root then
FlyVelocity = nil
FlyGyro = nil
FlyRoot = root
DestroyFlyObjects(root)
end
if not FlyVelocity or FlyVelocity.Parent ~= root then
FlyVelocity = Instance.new("BodyVelocity")
FlyVelocity.Name = "E17_FlyVelocity"
FlyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
FlyVelocity.P = 20000
FlyVelocity.Velocity = Vector3.zero
FlyVelocity.Parent = root
end
if not FlyGyro or FlyGyro.Parent ~= root then
FlyGyro = Instance.new("BodyGyro")
FlyGyro.Name = "E17_FlyGyro"
FlyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
FlyGyro.P = 25000
FlyGyro.D = 800
FlyGyro.CFrame = root.CFrame
FlyGyro.Parent = root
end
return true
end
function IsKeyDown(key)
return UIS:IsKeyDown(key)
end
Connect(RunService.RenderStepped, function()
if not State.Fly or State.GhostMode then
if FlyVelocity or FlyGyro or FlyRoot then CleanupFly() end
return
end
if not EnsureFlyObjects() then return end
local humanoid = GetHumanoid(LP)
local root = GetRoot(LP)
if not humanoid or not root then return end
Camera = Workspace.CurrentCamera or Camera
if not Camera then return end
humanoid.PlatformStand = true
humanoid.AutoRotate = false
local camCF = Camera.CFrame
local move = Vector3.zero
if IsKeyDown(Enum.KeyCode.W) then move += camCF.LookVector end
if IsKeyDown(Enum.KeyCode.S) then move -= camCF.LookVector end
if IsKeyDown(Enum.KeyCode.D) then move += camCF.RightVector end
if IsKeyDown(Enum.KeyCode.A) then move -= camCF.RightVector end
if IsKeyDown(Enum.KeyCode.Space) then move += Vector3.yAxis end
if IsKeyDown(Enum.KeyCode.LeftControl)
or IsKeyDown(Enum.KeyCode.RightControl)
or IsKeyDown(Enum.KeyCode.C)
then
move -= Vector3.yAxis
end
if move.Magnitude < 0.01
and UIS.TouchEnabled
and humanoid.MoveDirection.Magnitude > 0.01
then
move += humanoid.MoveDirection
end
local flatLook = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
local flatRight = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z)
if flatLook.Magnitude > 0.001 then flatLook = flatLook.Unit end
if flatRight.Magnitude > 0.001 then flatRight = flatRight.Unit end
if State.FlyMode == "Upright" or State.FlyMode == "Hover" then
move = Vector3.zero
if IsKeyDown(Enum.KeyCode.W) then move += flatLook end
if IsKeyDown(Enum.KeyCode.S) then move -= flatLook end
if IsKeyDown(Enum.KeyCode.D) then move += flatRight end
if IsKeyDown(Enum.KeyCode.A) then move -= flatRight end
if IsKeyDown(Enum.KeyCode.Space) then move += Vector3.yAxis end
if IsKeyDown(Enum.KeyCode.LeftControl)
or IsKeyDown(Enum.KeyCode.RightControl)
or IsKeyDown(Enum.KeyCode.C)
then
move -= Vector3.yAxis
end
elseif State.FlyMode == "Glide" and move.Magnitude < 0.01 then
move = camCF.LookVector * 0.45
end
if move.Magnitude > 1 then
move = move.Unit
end
FlyVelocity.Velocity = move * State.FlySpeed
if State.FlyMode == "Upright" or State.FlyMode == "Hover" then
local face = flatLook.Magnitude > 0.001 and flatLook or root.CFrame.LookVector
FlyGyro.CFrame = CFrame.lookAt(
root.Position,
root.Position + face,
Vector3.yAxis
)
else
FlyGyro.CFrame = CFrame.lookAt(
root.Position,
root.Position + camCF.LookVector,
camCF.UpVector
)
end
end)
NoclipCache = setmetatable({}, {__mode = "k"})
function ApplyNoclip()
local character = LP.Character
if not character then return end
for _, object in ipairs(character:GetDescendants()) do
if object:IsA("BasePart") then
if NoclipCache[object] == nil then
NoclipCache[object] = object.CanCollide
end
object.CanCollide = false
end
end
end
function RestoreNoclip()
for part, oldValue in pairs(NoclipCache) do
if part and part.Parent then
pcall(function() part.CanCollide = oldValue end)
end
end
table.clear(NoclipCache)
end
Connect(RunService.PreSimulation, function()
if State.Noclip
and not State.TouchFling
and not State.TargetFlingActive
and not State.FlingAllActive
then
ApplyNoclip()
elseif State.Noclip then
RestoreNoclip()
end
end)
function ClickTPAt(screenPosition)
if not State.ClickTP then return end
if State.ClickTPRequireAlt
and not IsKeyDown(Enum.KeyCode.LeftAlt)
and not IsKeyDown(Enum.KeyCode.RightAlt)
then
return
end
local root = GetRoot(LP)
if not root then return end
Camera = Workspace.CurrentCamera or Camera
if not Camera then return end
local ray = Camera:ViewportPointToRay(screenPosition.X, screenPosition.Y)
local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Exclude
local excluded = {Camera}
if LP.Character then table.insert(excluded, LP.Character) end
params.FilterDescendantsInstances = excluded
params.IgnoreWater = false
local result = Workspace:Raycast(
ray.Origin,
ray.Direction * 10000,
params
)
if not result then return end
local target = result.Position + result.Normal * 2.8
local _, yaw, _ = root.CFrame:ToOrientation()
State.LastReturnCFrame = root.CFrame
root.CFrame = CFrame.new(target) * CFrame.Angles(0, yaw, 0)
root.AssemblyLinearVelocity = Vector3.zero
root.AssemblyAngularVelocity = Vector3.zero
end
Connect(UIS.InputBegan, function(input, processed)
if processed or not State.ClickTP then return end
if input.UserInputType == Enum.UserInputType.MouseButton1 then
ClickTPAt(UIS:GetMouseLocation())
end
end)
pcall(function()
Connect(UIS.TouchTapInWorld, function(positions, processed)
if processed or not State.ClickTP or State.ClickTPRequireAlt then return end
local position = positions and positions[1]
if position then ClickTPAt(position) end
end)
end)
GhostModel
GhostRoot
GhostHumanoid
GhostMotorMap = {}
GhostTransparencyCache = setmetatable({}, {__mode = "k"})
function SetRealHidden(hidden)
local character = LP.Character
if not character then return end
for _, object in ipairs(character:GetDescendants()) do
if object:IsA("BasePart") then
if hidden then
if GhostTransparencyCache[object] == nil then
GhostTransparencyCache[object] = object.LocalTransparencyModifier
end
object.LocalTransparencyModifier = 1
else
local old = GhostTransparencyCache[object]
if old ~= nil then object.LocalTransparencyModifier = old end
end
end
end
if not hidden then table.clear(GhostTransparencyCache) end
end
