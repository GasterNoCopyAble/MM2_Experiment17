-- Experiment17 MM2 modular v7 | module 05
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
