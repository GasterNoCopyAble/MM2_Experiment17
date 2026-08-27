-- Experiment17 MM2 modular v7 | module 09
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
SpectateChoice
SpectateToggle
function BuildPlayerNames()
local values = {"None"}
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LP then
table.insert(values, player.Name)
end
end
table.sort(values, function(a, b)
if a == "None" then return true end
if b == "None" then return false end
return string.lower(a) < string.lower(b)
end)
return values
end
function ApplySpectate()
Camera = Workspace.CurrentCamera or Camera
if not Camera then return false end
if not State.Spectate then
local humanoid = GetHumanoid(LP)
if humanoid then
Camera.CameraType = Enum.CameraType.Custom
Camera.CameraSubject = humanoid
end
return false
end
local target = FindPlayer(State.SpectateTargetName)
local humanoid = GetHumanoid(target)
if not target or not humanoid then return false end
Camera.CameraType = Enum.CameraType.Custom
Camera.CameraSubject = humanoid
return true
end
FreecamOld = {}
FreecamCF
FreecamPitch = 0
FreecamYaw = 0
FreecamLooking = false
function StartFreecam()
Camera = Workspace.CurrentCamera or Camera
if not Camera then return false end
if FreecamCF then return true end
FreecamOld = {
CameraType = Camera.CameraType,
CameraSubject = Camera.CameraSubject,
CFrame = Camera.CFrame,
FOV = Camera.FieldOfView,
MouseBehavior = UIS.MouseBehavior,
}
FreecamCF = Camera.CFrame
local x, y, _ = FreecamCF:ToOrientation()
FreecamPitch = x
FreecamYaw = y
Camera.CameraType = Enum.CameraType.Scriptable
Camera.FieldOfView = State.FreecamFOV
return true
end
function StopFreecam()
Camera = Workspace.CurrentCamera or Camera
FreecamLooking = false
if Camera then
Camera.CameraType = FreecamOld.CameraType or Enum.CameraType.Custom
Camera.CameraSubject = FreecamOld.CameraSubject or GetHumanoid(LP)
if FreecamOld.CFrame then Camera.CFrame = FreecamOld.CFrame end
if FreecamOld.FOV then Camera.FieldOfView = FreecamOld.FOV end
end
UIS.MouseBehavior = FreecamOld.MouseBehavior or Enum.MouseBehavior.Default
FreecamCF = nil
end
Connect(UIS.InputBegan, function(input, processed)
if processed or not State.Freecam then return end
if input.UserInputType == Enum.UserInputType.MouseButton2 then
FreecamLooking = true
UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
end
end)
Connect(UIS.InputEnded, function(input)
if input.UserInputType == Enum.UserInputType.MouseButton2 then
FreecamLooking = false
if State.Freecam then UIS.MouseBehavior = Enum.MouseBehavior.Default end
end
end)
Connect(RunService.RenderStepped, function(dt)
if not State.Freecam then return end
Camera = Workspace.CurrentCamera or Camera
if not Camera then return end
if not FreecamCF and not StartFreecam() then return end
if FreecamLooking and not Library.MenuVisible then
local mouseDelta = UIS:GetMouseDelta()
FreecamYaw -= math.rad(mouseDelta.X * State.FreecamSensitivity)
FreecamPitch = math.clamp(
FreecamPitch - math.rad(mouseDelta.Y * State.FreecamSensitivity),
math.rad(-89),
math.rad(89)
)
end
local rotation = CFrame.fromOrientation(
FreecamPitch,
FreecamYaw,
0
)
local move = Vector3.zero
if IsKeyDown(Enum.KeyCode.W) then move += Vector3.new(0,0,-1) end
if IsKeyDown(Enum.KeyCode.S) then move += Vector3.new(0,0,1) end
if IsKeyDown(Enum.KeyCode.A) then move += Vector3.new(-1,0,0) end
if IsKeyDown(Enum.KeyCode.D) then move += Vector3.new(1,0,0) end
if IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
if IsKeyDown(Enum.KeyCode.LeftControl)
or IsKeyDown(Enum.KeyCode.RightControl)
or IsKeyDown(Enum.KeyCode.C)
then
move += Vector3.new(0,-1,0)
end
if move.Magnitude > 1 then move = move.Unit end
local speed = State.FreecamSpeed
if IsKeyDown(Enum.KeyCode.LeftShift) or IsKeyDown(Enum.KeyCode.RightShift) then
speed *= State.FreecamBoost
end
local position = FreecamCF.Position
+ rotation:VectorToWorldSpace(move) * speed * dt
if State.FreecamFollowPlayer then
local target = FindPlayer(State.TargetPlayerName)
local targetRoot = GetRoot(target)
if targetRoot and (targetRoot.Position - position).Magnitude > 0.01 then
rotation = CFrame.lookAt(
position,
targetRoot.Position,
Vector3.yAxis
).Rotation
local followPitch, followYaw, _ = rotation:ToOrientation()
FreecamPitch = followPitch
FreecamYaw = followYaw
end
end
FreecamCF = CFrame.new(position) * rotation
Camera.CFrame = FreecamCF
Camera.FieldOfView = State.FreecamFOV
end)
Connect(UIS.InputChanged, function(input)
if not State.Freecam or State.ScreenshotMode or Library.MenuVisible then return end
if input.UserInputType == Enum.UserInputType.MouseWheel then
local direction = input.Position.Z > 0 and 1 or -1
State.FreecamSpeed = math.clamp(
State.FreecamSpeed + direction * State.FreecamWheelStep,
5,
300
)
if Controls.FreecamSpeedControl and Controls.FreecamSpeedControl.Set then
Controls.FreecamSpeedControl:Set(State.FreecamSpeed, true)
end
end
end)
AntiFlingCollisionCache = setmetatable({}, {__mode = "k"})
LastCollisionRefresh = 0
function RestoreAntiFlingCollision()
for part, oldValue in pairs(AntiFlingCollisionCache) do
if part and part.Parent then
pcall(function() part.CanCollide = oldValue end)
end
end
table.clear(AntiFlingCollisionCache)
end
function ApplyAntiFlingCollision()
if os.clock() - LastCollisionRefresh < 0.25 then return end
LastCollisionRefresh = os.clock()
for _, player in ipairs(Players:GetPlayers()) do
if player ~= LP and player.Character then
for _, part in ipairs(player.Character:GetDescendants()) do
if part:IsA("BasePart") then
if AntiFlingCollisionCache[part] == nil then
AntiFlingCollisionCache[part] = part.CanCollide
end
part.CanCollide = false
end
end
end
end
end
Connect(RunService.PreSimulation, function()
if not State.AntiFling then return end
local root = GetRoot(LP)
local humanoid = GetHumanoid(LP)
if not root or not humanoid then return end
local intentional = State.TouchFling
or State.TargetFlingActive
or State.FlingAllActive
or State.Fly
or State.GhostMode
if intentional then
RestoreAntiFlingCollision()
return
end
ApplyAntiFlingCollision()
if root.AssemblyAngularVelocity.Magnitude > State.AntiFlingAngularThreshold then
root.AssemblyAngularVelocity = Vector3.zero
end
local velocity = root.AssemblyLinearVelocity
local horizontal = Vector3.new(velocity.X, 0, velocity.Z)
if horizontal.Magnitude > State.AntiFlingLinearThreshold then
local allowed = State.WalkSpeed
and math.min(State.WalkSpeedValue * 1.35, 90)
or 45
local safe = Vector3.zero
if humanoid.MoveDirection.Magnitude > 0.01 then
safe = humanoid.MoveDirection.Unit * allowed
end
root.AssemblyLinearVelocity = Vector3.new(
safe.X,
velocity.Y,
safe.Z
)
end
end)
TouchFlingToken = 0
function HiddenFlingPulse(root, moveOffset)
if not root or not root.Parent then return moveOffset end
local oldVelocity = root.Velocity
root.Velocity = oldVelocity * 10000 + Vector3.new(0, 10000, 0)
RunService.RenderStepped:Wait()
if root and root.Parent then root.Velocity = oldVelocity end
RunService.Stepped:Wait()
if root and root.Parent then
root.Velocity = oldVelocity + Vector3.new(0, moveOffset, 0)
end
return -moveOffset
end
