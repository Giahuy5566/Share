-- ============================================
-- Auto Jump + Speed Toggle - [FPS] Chụp Nhanh
-- ============================================

if _G.AutoJumpExecuted then return end
_G.AutoJumpExecuted = true

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Cài đặt
local autoJump = false
local speedEnabled = false
local normalSpeed = 16
local boostSpeed = 40

-- ============================================
-- AUTO JUMP
-- ============================================
RunService.Heartbeat:Connect(function()
    if autoJump then
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.FloorMaterial ~= Enum.Material.Air then
                hum.Jump = true
            end
        end
    end
end)

-- ============================================
-- SPEED TOGGLE
-- ============================================
local function setSpeed(value)
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = value
        end
    end
end

-- ============================================
-- GUI ĐƠN GIẢN (Bật/Tắt)
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoJumpGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer.PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 110)
Frame.Position = UDim2.new(0, 10, 0.5, -55)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "⚡ FPS Script"
Title.TextColor3 = Color3.fromRGB(255, 200, 0)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

-- Nút Auto Jump
local JumpBtn = Instance.new("TextButton")
JumpBtn.Size = UDim2.new(0.9, 0, 0, 35)
JumpBtn.Position = UDim2.new(0.05, 0, 0, 35)
JumpBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
JumpBtn.Text = "Auto Jump: TẮT"
JumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpBtn.TextScaled = true
JumpBtn.Font = Enum.Font.GothamBold
JumpBtn.Parent = Frame

local JumpCorner = Instance.new("UICorner")
JumpCorner.CornerRadius = UDim.new(0, 6)
JumpCorner.Parent = JumpBtn

-- Nút Speed Toggle
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.9, 0, 0, 35)
SpeedBtn.Position = UDim2.new(0.05, 0, 0, 75)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
SpeedBtn.Text = "Speed: TẮT"
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.TextScaled = true
SpeedBtn.Font = Enum.Font.GothamBold
SpeedBtn.Parent = Frame

local SpeedCorner = Instance.new("UICorner")
SpeedCorner.CornerRadius = UDim.new(0, 6)
SpeedCorner.Parent = SpeedBtn

-- Sự kiện bấm nút Auto Jump
JumpBtn.MouseButton1Click:Connect(function()
    autoJump = not autoJump
    if autoJump then
        JumpBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        JumpBtn.Text = "Auto Jump: BẬT"
    else
        JumpBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        JumpBtn.Text = "Auto Jump: TẮT"
    end
end)

-- Sự kiện bấm nút Speed
SpeedBtn.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    if speedEnabled then
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        SpeedBtn.Text = "Speed: BẬT"
        setSpeed(boostSpeed)
    else
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        SpeedBtn.Text = "Speed: TẮT"
        setSpeed(normalSpeed)
    end
end)

-- Reset speed khi respawn
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if speedEnabled then
        setSpeed(boostSpeed)
    end
end)

print("[Script] ✅ Đã tải xong! Chúc Bảo Trang chơi vui!")