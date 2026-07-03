-- Blox Fruits NPC Auto Farm + Simple UI Toggle
-- LocalScript inside StarterPlayerScripts
-- Works on NPCs only — not other players

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")

-- ============================================================
-- CONFIG
-- ============================================================
local CONFIG = {
	FARM_RANGE    = 40,      -- studs, radius to search for NPCs
	ATTACK_RANGE  = 8,       -- studs, melee attack range
	WALK_SPEED    = 16,
	LOOP_RATE     = 0.1,     -- seconds between each farm tick
	AUTO_RESPAWN  = true,
}

-- ============================================================
-- STATE
-- ============================================================
local farmEnabled   = false
local currentTarget = nil

-- ============================================================
-- UI
-- ============================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFarmUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = LocalPlayer.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 60)
frame.Position = UDim2.new(0, 16, 0.5, -30)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(60, 60, 80)
stroke.Thickness = 1
stroke.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 0.45, 0)
label.Position = UDim2.new(0, 0, 0, 0)
label.BackgroundTransparency = 1
label.Text = "NPC AUTO FARM"
label.TextColor3 = Color3.fromRGB(180, 180, 200)
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.85, 0, 0.42, 0)
toggleBtn.Position = UDim2.new(0.075, 0, 0.52, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
toggleBtn.Text = "OFF"
toggleBtn.TextColor3 = Color3.fromRGB(180, 60, 60)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = frame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = toggleBtn

local function setToggleVisual(on)
	if on then
		toggleBtn.Text = "ON"
		toggleBtn.TextColor3 = Color3.fromRGB(60, 200, 100)
		TweenService:Create(toggleBtn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(30, 60, 40)
		}):Play()
	else
		toggleBtn.Text = "OFF"
		toggleBtn.TextColor3 = Color3.fromRGB(180, 60, 60)
		TweenService:Create(toggleBtn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(65, 30, 30)
		}):Play()
	end
end

toggleBtn.MouseButton1Click:Connect(function()
	farmEnabled = not farmEnabled
	setToggleVisual(farmEnabled)
	if not farmEnabled then
		currentTarget = nil
		Humanoid:MoveTo(HRP.Position)
	end
end)

-- ============================================================
-- CORE LOGIC
-- ============================================================

local function isNPC(model)
	-- Only target NPCs, never players
	if Players:GetPlayerFromCharacter(model) then return false end
	local hum = model:FindFirstChildOfClass("Humanoid")
	local hrp = model:FindFirstChild("HumanoidRootPart")
	return hum ~= nil and hrp ~= nil and hum.Health > 0
end

local function getNearestNPC()
	local nearest    = nil
	local nearestDist = CONFIG.FARM_RANGE

	for _, obj in ipairs(workspace:GetChildren()) do
		if not isNPC(obj) then continue end
		local dist = (obj.HumanoidRootPart.Position - HRP.Position).Magnitude
		if dist < nearestDist then
			nearestDist = dist
			nearest = obj
		end
	end

	return nearest
end

local function attackTarget(target)
	local hrp = target:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local dist = (hrp.Position - HRP.Position).Magnitude
	if dist <= CONFIG.ATTACK_RANGE then
		-- Simulate a basic tool activation (M1 click)
		-- Your equipped tool fires via UserInputService or a RemoteEvent.
		-- Replace this section with your specific sword/fruit attack remote.
		local tool = Character:FindFirstChildOfClass("Tool")
		if tool and tool:FindFirstChild("Handle") then
			local activateRemote = tool:FindFirstChild("RemoteEvent")
				or tool:FindFirstChild("ClickDetector")
			-- Generic tool activate
			tool:Activate()
		end
	else
		Humanoid:MoveTo(hrp.Position)
	end
end

local function refreshCharacter()
	Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	Humanoid = Character:WaitForChild("Humanoid")
	HRP     = Character:WaitForChild("HumanoidRootPart")
end

if CONFIG.AUTO_RESPAWN then
	LocalPlayer.CharacterAdded:Connect(function(newChar)
		Character = newChar
		Humanoid  = newChar:WaitForChild("Humanoid")
		HRP       = newChar:WaitForChild("HumanoidRootPart")
		currentTarget = nil
		task.wait(2) -- brief grace period after respawn
	end)
end

-- ============================================================
-- FARM LOOP
-- ============================================================
RunService.Heartbeat:Connect(function()
	if not farmEnabled then return end
	if not Character or not HRP or not Humanoid then
		refreshCharacter()
		return
	end
	if Humanoid.Health <= 0 then return end

	-- Validate current target
	if currentTarget then
		local hum = currentTarget:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 or not currentTarget.Parent then
			currentTarget = nil
		end
	end

	-- Find new target if needed
	if not currentTarget then
		currentTarget = getNearestNPC()
	end

	if currentTarget then
		attackTarget(currentTarget)
	end
end)