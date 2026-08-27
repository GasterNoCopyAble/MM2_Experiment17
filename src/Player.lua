-- Experiment 17 | Private MM2 modular v7 | Player / movement
-- Semantic feature module. Loaded by init.lua into one shared runtime environment.

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
function DestroyGhost()
if GhostModel then GhostModel:Destroy() end
GhostModel = nil
GhostRoot = nil
GhostHumanoid = nil
table.clear(GhostMotorMap)
end
function BuildGhostMotorMap(realCharacter, clone)
table.clear(GhostMotorMap)
local cloneMotors = {}
for _, object in ipairs(clone:GetDescendants()) do
if object:IsA("Motor6D") then
cloneMotors[object.Name] = cloneMotors[object.Name] or {}
table.insert(cloneMotors[object.Name], object)
end
end
for _, object in ipairs(realCharacter:GetDescendants()) do
if object:IsA("Motor6D") then
local list = cloneMotors[object.Name]
if list and list[1] then
table.insert(GhostMotorMap, {
Real = object,
Ghost = table.remove(list, 1),
})
end
end
end
end
function EnableGhost()
if GhostModel then return true end
local character = LP.Character
local root = GetRoot(LP)
local humanoid = GetHumanoid(LP)
if not character or not root or not humanoid then return false end
local oldArchivable = character.Archivable
character.Archivable = true
local clone = character:Clone()
character.Archivable = oldArchivable
clone.Name = "E17_LocalGhost"
for _, object in ipairs(clone:GetDescendants()) do
if object:IsA("Script") or object:IsA("LocalScript") or object:IsA("Tool") then
object:Destroy()
elseif object:IsA("BasePart") then
object.CanCollide = false
object.CanTouch = false
object.CanQuery = false
object.Massless = true
object.LocalTransparencyModifier = 0
end
end
local ghostRoot = clone:FindFirstChild("HumanoidRootPart")
local ghostHumanoid = clone:FindFirstChildOfClass("Humanoid")
if not ghostRoot or not ghostHumanoid then
clone:Destroy()
return false
end
clone:PivotTo(root.CFrame)
clone.Parent = Workspace
ghostRoot.Anchored = true
ghostHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
BuildGhostMotorMap(character, clone)
GhostModel = clone
GhostRoot = ghostRoot
GhostHumanoid = ghostHumanoid
SetRealHidden(true)
root.AssemblyLinearVelocity = Vector3.zero
root.AssemblyAngularVelocity = Vector3.zero
root.CFrame = root.CFrame + Vector3.new(0, State.GhostHeight, 0)
root.Anchored = true
humanoid.AutoRotate = false
Camera = Workspace.CurrentCamera or Camera
if Camera then Camera.CameraSubject = ghostHumanoid end
return true
end
function DisableGhost(returnToGhost)
local realRoot = GetRoot(LP)
local realHumanoid = GetHumanoid(LP)
local returnCF = GhostRoot and GhostRoot.CFrame or nil
if realRoot then
realRoot.Anchored = false
if returnToGhost and returnCF then
realRoot.CFrame = returnCF + Vector3.new(0, 1.8, 0)
realRoot.AssemblyLinearVelocity = Vector3.zero
realRoot.AssemblyAngularVelocity = Vector3.zero
end
end
if realHumanoid then
realHumanoid.PlatformStand = false
realHumanoid.AutoRotate = true
end
SetRealHidden(false)
Camera = Workspace.CurrentCamera or Camera
if Camera and realHumanoid then Camera.CameraSubject = realHumanoid end
DestroyGhost()
end
Connect(RunService.RenderStepped, function(dt)
if not State.GhostMode then return end
if not GhostModel or not GhostRoot or not GhostRoot.Parent then
if not EnableGhost() then return end
end
local humanoid = GetHumanoid(LP)
if not humanoid then return end
Camera = Workspace.CurrentCamera or Camera
local move = humanoid.MoveDirection
local vertical = 0
if IsKeyDown(Enum.KeyCode.Space) then vertical += 1 end
if IsKeyDown(Enum.KeyCode.LeftControl)
or IsKeyDown(Enum.KeyCode.RightControl)
or IsKeyDown(Enum.KeyCode.C)
then
vertical -= 1
end
local delta = Vector3.new(move.X, 0, move.Z)
+ Vector3.new(0, vertical, 0)
if delta.Magnitude > 1 then delta = delta.Unit end
local position = GhostRoot.Position + delta * State.GhostSpeed * dt
local look = Camera and Camera.CFrame.LookVector or GhostRoot.CFrame.LookVector
local flat = Vector3.new(look.X, 0, look.Z)
local rotation = GhostRoot.CFrame.Rotation
if flat.Magnitude > 0.001 then
rotation = CFrame.lookAt(
Vector3.zero,
flat.Unit,
Vector3.yAxis
).Rotation
end
GhostRoot.CFrame = CFrame.new(position) * rotation
for _, pair in ipairs(GhostMotorMap) do
if pair.Real and pair.Real.Parent and pair.Ghost and pair.Ghost.Parent then
pair.Ghost.Transform = pair.Real.Transform
end
end
end)
