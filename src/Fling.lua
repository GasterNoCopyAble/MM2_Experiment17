-- Experiment 17 | Private MM2 modular v7 | Fling / protection
-- Semantic feature module. Loaded by init.lua into one shared runtime environment.

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
function StartTouchFling()
TouchFlingToken += 1
local token = TouchFlingToken
RestoreNoclip()
RestoreAntiFlingCollision()
task.spawn(function()
local moveOffset = 0.1
while State.TouchFling
and token == TouchFlingToken
and not Library.Unloaded
do
RunService.Heartbeat:Wait()
local root = GetRoot(LP)
if root then
moveOffset = HiddenFlingPulse(root, moveOffset)
end
end
end)
end
function StopTouchFling()
TouchFlingToken += 1
local root = GetRoot(LP)
if root then root.AssemblyAngularVelocity = Vector3.zero end
if State.Noclip then task.defer(ApplyNoclip) end
end
function FlingTarget(player)
if State.TargetFlingActive then return false end
if not player or player == LP then
Notify("Target Fling", "Select a target", "Warning")
return false
end
local root = GetRoot(LP)
local targetRoot = GetRoot(player)
if not root or not targetRoot then return false end
State.TargetFlingActive = true
RestoreNoclip()
RestoreAntiFlingCollision()
local oldCF = root.CFrame
local oldLinear = root.AssemblyLinearVelocity
local started = os.clock()
local moveOffset = 0.1
while State.TargetFlingActive
and os.clock() - started < State.TargetFlingDuration
and not Library.Unloaded
do
root = GetRoot(LP)
targetRoot = GetRoot(player)
if not root or not targetRoot or not IsCharacterAlive(player) then
break
end
root.CFrame = targetRoot.CFrame
root.AssemblyAngularVelocity = Vector3.zero
RunService.Heartbeat:Wait()
moveOffset = HiddenFlingPulse(root, moveOffset)
end
root = GetRoot(LP)
if root then
root.CFrame = oldCF
root.AssemblyLinearVelocity = oldLinear
root.AssemblyAngularVelocity = Vector3.zero
end
State.TargetFlingActive = false
if State.Noclip and not State.FlingAllActive then
task.defer(ApplyNoclip)
end
return true
end
function FlingAll()
if State.FlingAllActive then return end
State.FlingAllActive = true
task.spawn(function()
local root = GetRoot(LP)
local oldCF = root and root.CFrame
for _, player in ipairs(Players:GetPlayers()) do
if not State.FlingAllActive or Library.Unloaded then break end
if player ~= LP and IsAliveFromRoleData(player) then
while State.TargetFlingActive do
RunService.Heartbeat:Wait()
end
FlingTarget(player)
task.wait(0.04)
end
end
root = GetRoot(LP)
if root and oldCF then
root.CFrame = oldCF
root.AssemblyLinearVelocity = Vector3.zero
root.AssemblyAngularVelocity = Vector3.zero
end
State.FlingAllActive = false
if State.Noclip then task.defer(ApplyNoclip) end
end)
end
