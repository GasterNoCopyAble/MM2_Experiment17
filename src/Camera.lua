-- Experiment 17 | Private MM2 modular v7 | Camera
-- Semantic feature module. Loaded by init.lua into one shared runtime environment.

SpectateChoice = nil
SpectateToggle = nil
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
FreecamCF = nil
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
