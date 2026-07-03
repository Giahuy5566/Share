-- fov_visualizer_mobile_v2.lua
-- Place in StarterPlayerScripts
-- ADDED: ON/OFF toggle button for the FOV circle overlay

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local config = {
	radius       = 120,
	smoothing    = 0.15,
	targetPart   = "Head",
	color        = Color3.fromRGB(0, 255, 136),
	fillAlpha    = 0.78,
	ringWidth    = 2,
	visible      = true,
	toggleKey    = Enum.KeyCode.F4,
}

local gui = Instance.new("ScreenGui")
gui.Name             = "FOVVisualizer"
gui.ResetOnSpawn     = false
gui.IgnoreGuiInset   = true
gui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
gui.Parent           = playerGui

local canvas = Instance.new("Frame")
canvas.Size                   = UDim2.fromScale(1, 1)
canvas.BackgroundTransparency = 1
canvas.Parent                 = gui

-- FOV Ring
local ring = Instance.new("Frame")
ring.AnchorPoint            = Vector2.new(0.5, 0.5)
ring.BackgroundTransparency = 1
ring.BorderSizePixel        = 0
ring.Parent                 = canvas
Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)

local stroke = Instance.new("UIStroke", ring)
stroke.Color     = config.color
stroke.Thickness = config.ringWidth

local fill = Instance.new("Frame")
fill.AnchorPoint            = Vector2.new(0.5, 0.5)
fill.BackgroundColor3       = config.color
fill.BackgroundTransparency = config.fillAlpha
fill.BorderSizePixel        = 0
fill.Parent                 = canvas
Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

-- Crosshair
local function makeLine(w, h)
	local f = Instance.new("Frame")
	f.AnchorPoint            = Vector2.new(0.5, 0.5)
	f.Size                   = UDim2.new(0, w, 0, h)
	f.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
	f.BackgroundTransparency = 0.3
	f.BorderSizePixel        = 0
	f.Parent                 = canvas
	return f
end
local crossH = makeLine(14, 1)
local crossV = makeLine(1, 14)

-- Target dot
local dot = Instance.new("Frame")
dot.Name                    = "TargetDot"
dot.Size                    = UDim2.new(0, 10, 0, 10)
dot.AnchorPoint             = Vector2.new(0.5, 0.5)
dot.BackgroundColor3        = Color3.fromRGB(255, 60, 60)
dot.BackgroundTransparency  = 0
dot.BorderSizePixel         = 0
dot.Visible                 = false
dot.ZIndex                  = 10
dot.Parent                  = canvas
Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

local dotStroke = Instance.new("UIStroke", dot)
dotStroke.Color     = Color3.fromRGB(255, 255, 255)
dotStroke.Thickness = 1.5

-- Panel
local PANEL_W, ROW_H, PAD = 220, 52, 12

local panel = Instance.new("Frame")
panel.Name                   = "Panel"
panel.AnchorPoint            = Vector2.new(1, 0)
panel.Position               = UDim2.new(1, -PAD, 0, PAD)
panel.Size                   = UDim2.new(0, PANEL_W, 0, 0)
panel.BackgroundColor3       = Color3.fromRGB(10, 10, 10)
panel.BackgroundTransparency = 0.1
panel.BorderSizePixel        = 0
panel.ClipsDescendants       = true
panel.Parent                 = canvas
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

local layout = Instance.new("UIListLayout", panel)
layout.Padding             = UDim.new(0, 6)
layout.FillDirection       = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder           = Enum.SortOrder.LayoutOrder

local uipad = Instance.new("UIPadding", panel)
uipad.PaddingTop    = UDim.new(0, PAD)
uipad.PaddingBottom = UDim.new(0, PAD)
uipad.PaddingLeft   = UDim.new(0, PAD)
uipad.PaddingRight  = UDim.new(0, PAD)

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	panel.Size = UDim2.new(0, PANEL_W, 0, layout.AbsoluteContentSize.Y + PAD * 2)
end)

-- Helpers
local function makeLabel(text, parent, order)
	local l = Instance.new("TextLabel")
	l.Size                   = UDim2.new(1, 0, 0, 18)
	l.BackgroundTransparency = 1
	l.Text                   = text
	l.TextColor3             = Color3.fromRGB(120, 120, 120)
	l.TextSize               = 11
	l.Font                   = Enum.Font.Code
	l.TextXAlignment         = Enum.TextXAlignment.Left
	l.LayoutOrder            = order or 0
	l.Parent                 = parent
	return l
end

local function makeSlider(labelTxt, min, max, default, color, order, callback)
	local container = Instance.new("Frame")
	container.Size                   = UDim2.new(1, 0, 0, ROW_H)
	container.BackgroundTransparency = 1
	container.LayoutOrder            = order
	container.Parent                 = panel

	local lbl = makeLabel(labelTxt, container)
	lbl.Size = UDim2.new(0.62, 0, 0, 18)

	local valLbl = Instance.new("TextLabel")
	valLbl.Size                   = UDim2.new(0.38, 0, 0, 18)
	valLbl.Position               = UDim2.new(0.62, 0, 0, 0)
	valLbl.BackgroundTransparency = 1
	valLbl.Text                   = tostring(default)
	valLbl.TextColor3             = color
	valLbl.TextSize               = 11
	valLbl.Font                   = Enum.Font.Code
	valLbl.TextXAlignment         = Enum.TextXAlignment.Right
	valLbl.Parent                 = container

	local track = Instance.new("Frame")
	track.Size                   = UDim2.new(1, 0, 0, 28)
	track.Position               = UDim2.new(0, 0, 0, 20)
	track.BackgroundColor3       = Color3.fromRGB(35, 35, 35)
	track.BackgroundTransparency = 0
	track.BorderSizePixel        = 0
	track.Parent                 = container
	Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

	local fillBar = Instance.new("Frame")
	fillBar.Size            = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fillBar.BackgroundColor3 = color
	fillBar.BorderSizePixel  = 0
	fillBar.Parent           = track
	Instance.new("UICorner", fillBar).CornerRadius = UDim.new(1, 0)

	local thumb = Instance.new("Frame")
	thumb.Size                   = UDim2.new(0, 22, 0, 22)
	thumb.AnchorPoint            = Vector2.new(0.5, 0.5)
	thumb.Position               = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
	thumb.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
	thumb.BorderSizePixel        = 0
	thumb.Parent                 = track
	Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

	local dragging = false

	local function update(inputPos)
		local rel   = math.clamp((inputPos.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		local value = math.floor(min + rel * (max - min))
		local ratio = (value - min) / (max - min)
		fillBar.Size   = UDim2.new(ratio, 0, 1, 0)
		thumb.Position = UDim2.new(ratio, 0, 0.5, 0)
		valLbl.Text    = tostring(value)
		callback(value)
	end

	track.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.Touch
		or inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			update(inp.Position)
		end
	end)
	UserInputService.InputChanged:Connect(function(inp)
		if not dragging then return end
		if inp.UserInputType == Enum.UserInputType.Touch
		or inp.UserInputType == Enum.UserInputType.MouseMovement then
			update(inp.Position)
		end
	end)
	UserInputService.InputEnded:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.Touch
		or inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

-- Part Selector (ORDER 1)
local parts      = { "Head", "Torso", "HumanoidRootPart" }
local partLabels = { Head = "HEAD", Torso = "TORSO", HumanoidRootPart = "ROOT" }

local selectorRow = Instance.new("Frame")
selectorRow.Size                   = UDim2.new(1, 0, 0, ROW_H)
selectorRow.BackgroundTransparency = 1
selectorRow.LayoutOrder            = 1
selectorRow.Parent                 = panel
makeLabel("TARGET PART", selectorRow)

local btnRow = Instance.new("Frame")
btnRow.Size                   = UDim2.new(1, 0, 0, 30)
btnRow.Position               = UDim2.new(0, 0, 0, 18)
btnRow.BackgroundTransparency = 1
btnRow.Parent                 = selectorRow

local btnLayout = Instance.new("UIListLayout", btnRow)
btnLayout.FillDirection     = Enum.FillDirection.Horizontal
btnLayout.Padding           = UDim.new(0, 4)
btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local partBtns = {}
local function selectPart(partName)
	config.targetPart = partName
	for p, btn in pairs(partBtns) do
		if p == partName then
			btn.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
			btn.TextColor3       = Color3.fromRGB(0, 0, 0)
		else
			btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			btn.TextColor3       = Color3.fromRGB(180, 180, 180)
		end
	end
end
for _, part in ipairs(parts) do
	local btn = Instance.new("TextButton")
	btn.Size             = UDim2.new(0, 60, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	btn.BorderSizePixel  = 0
	btn.Text             = partLabels[part]
	btn.TextColor3       = Color3.fromRGB(180, 180, 180)
	btn.TextSize         = 10
	btn.Font             = Enum.Font.GothamBold
	btn.Parent           = btnRow
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	partBtns[part] = btn
	btn.Activated:Connect(function() selectPart(part) end)
end
selectPart("Head")

-- Smoothing Slider (ORDER 2)
makeSlider("SMOOTH", 0, 95, 15, Color3.fromRGB(255, 180, 0), 2, function(v)
	config.smoothing = v / 100
end)

-- Radius Slider (ORDER 3)
makeSlider("FOV RADIUS", 20, 300, 120, Color3.fromRGB(0, 255, 136), 3, function(v)
	config.radius = v
end)

-- Fill Alpha Slider (ORDER 4)
makeSlider("FILL ALPHA", 0, 95, 78, Color3.fromRGB(0, 255, 136), 4, function(v)
	config.fillAlpha = v / 100
end)

-- Ring Width Slider (ORDER 5)
makeSlider("RING WIDTH", 1, 6, 2, Color3.fromRGB(0, 255, 136), 5, function(v)
	config.ringWidth = v
	stroke.Thickness = v
end)

-- ── CIRCLE TOGGLE BUTTON (ORDER 6) ───────────────────────────
local circleToggle = Instance.new("TextButton")
circleToggle.Size             = UDim2.new(1, 0, 0, 44)
circleToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
circleToggle.BorderSizePixel  = 0
circleToggle.Text             = "●  CIRCLE  ON"
circleToggle.TextColor3       = Color3.fromRGB(0, 0, 0)
circleToggle.TextSize         = 14
circleToggle.Font             = Enum.Font.GothamBold
circleToggle.LayoutOrder      = 6
circleToggle.Parent           = panel
Instance.new("UICorner", circleToggle).CornerRadius = UDim.new(0, 8)

local function applyCircleState()
	local on = config.visible
	ring.Visible   = on
	fill.Visible   = on
	crossH.Visible = on
	crossV.Visible = on
	if on then
		circleToggle.Text             = "●  CIRCLE  ON"
		circleToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
		circleToggle.TextColor3       = Color3.fromRGB(0, 0, 0)
	else
		circleToggle.Text             = "○  CIRCLE  OFF"
		circleToggle.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
		circleToggle.TextColor3       = Color3.fromRGB(160, 160, 160)
	end
end

circleToggle.Activated:Connect(function()
	config.visible = not config.visible
	applyCircleState()
end)

-- F4 keyboard mirror
UserInputService.InputBegan:Connect(function(inp, processed)
	if processed then return end
	if inp.KeyCode == config.toggleKey then
		config.visible = not config.visible
		applyCircleState()
	end
end)

applyCircleState()

-- Smooth dot position
local smoothX, smoothY = 0, 0

-- RenderStepped
RunService.RenderStepped:Connect(function()
	local camera   = workspace.CurrentCamera
	local vp       = camera.ViewportSize
	local cx, cy   = vp.X / 2, vp.Y / 2
	local diameter = config.radius * 2

	ring.Position = UDim2.new(0, cx, 0, cy)
	ring.Size     = UDim2.new(0, diameter, 0, diameter)
	fill.Position = UDim2.new(0, cx, 0, cy)
	fill.Size     = UDim2.new(0, diameter, 0, diameter)
	fill.BackgroundTransparency = config.fillAlpha

	crossH.Position = UDim2.new(0, cx, 0, cy)
	crossV.Position = UDim2.new(0, cx, 0, cy)

	-- Nearest target dot inside FOV radius
	local closestDist   = math.huge
	local closestScreen = nil

	for _, p in ipairs(Players:GetPlayers()) do
		if p == player then continue end
		local char = p.Character
		if not char then continue end
		local part = char:FindFirstChild(config.targetPart)
		if not part then continue end
		local screenPos, onScreen = camera:WorldToScreenPoint(part.Position)
		if not onScreen then continue end
		local dx   = screenPos.X - cx
		local dy   = screenPos.Y - cy
		local dist = math.sqrt(dx * dx + dy * dy)
		if dist < config.radius and dist < closestDist then
			closestDist   = dist
			closestScreen = screenPos
		end
	end

	local lerpFactor = 1 - config.smoothing
	if closestScreen then
		smoothX = smoothX + (closestScreen.X - smoothX) * lerpFactor
		smoothY = smoothY + (closestScreen.Y - smoothY) * lerpFactor
		dot.Visible  = config.visible
		dot.Position = UDim2.new(0, smoothX, 0, smoothY)
	else
		dot.Visible = false
		smoothX, smoothY = cx, cy
	end
end)