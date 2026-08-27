-- Experiment 17 | Private MM2 modular v7 | Combat
-- Semantic feature module. Loaded by init.lua into one shared runtime environment.

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
