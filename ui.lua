-- ============================================================
-- PUPPYWARE UI - BẢN MOBILE (TỐI ƯU CHO ĐIỆN THOẠI)
-- Tác giả: [Bạn]
-- ============================================================

local PuppyWare = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- ===== THEME =====
local THEME = {
    Bg = Color3.fromRGB(18, 18, 22),
    BgDark = Color3.fromRGB(12, 12, 16),
    BgLight = Color3.fromRGB(36, 36, 42),
    Accent = Color3.fromRGB(255, 200, 0),
    Text = Color3.fromRGB(235, 235, 240),
    TextDim = Color3.fromRGB(155, 155, 165),
    ToggleOn = Color3.fromRGB(0, 210, 80),
    ToggleOff = Color3.fromRGB(200, 50, 50),
    SliderFill = Color3.fromRGB(0, 150, 255),
    Border = Color3.fromRGB(50, 50, 60),
    Font = Enum.Font.Gotham,
}

-- ===== UTILITY =====
local function getViewport()
    return Camera.ViewportSize
end

-- ===== TẠO UI CHÍNH =====
function PuppyWare:CreateWindow(settings)
    settings = settings or {}
    local self = {}
    self.Name = settings.Name or "PuppyWare"
    self.MenuKey = settings.MenuKey or Enum.KeyCode.Insert
    
    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PuppyWare"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    screenGui.Enabled = true
    self.ScreenGui = screenGui
    
    -- Tính toán kích thước mobile
    local viewport = getViewport()
    local width = math.min(viewport.X - 20, 500)
    local height = math.min(viewport.Y - 40, 600)
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, width, 0, height)
    mainFrame.Position = UDim2.new(0.5, -width/2, 0.5, -height/2)
    mainFrame.BackgroundColor3 = THEME.Bg
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = THEME.Border
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = THEME.BgDark
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = self.Name
    titleLabel.TextColor3 = THEME.Text
    titleLabel.TextScaled = true
    titleLabel.Font = THEME.Font
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Nút đóng
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 36, 0, 36)
    closeBtn.Position = UDim2.new(1, -40, 0, 2)
    closeBtn.BackgroundColor3 = THEME.BgDark
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = THEME.Text
    closeBtn.TextScaled = true
    closeBtn.Font = THEME.Font
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)
    
    -- Tab Bar
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, 0, 0, 44)
    tabBar.Position = UDim2.new(0, 0, 0, 40)
    tabBar.BackgroundColor3 = THEME.BgDark
    tabBar.BorderSizePixel = 0
    tabBar.Parent = mainFrame
    
    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Size = UDim2.new(1, 0, 1, 0)
    tabScroll.BackgroundTransparency = 1
    tabScroll.BorderSizePixel = 0
    tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabScroll.ScrollBarThickness = 0
    tabScroll.Parent = tabBar
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.Parent = tabScroll
    
    -- Content Area
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 1, -84)
    contentFrame.Position = UDim2.new(0, 0, 0, 84)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ClipsDescendants = true
    contentFrame.Parent = mainFrame
    
    -- Kéo thả
    local dragging = false
    local dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- ===== QUẢN LÝ TAB =====
    self.Tabs = {}
    local activeTab = nil
    
    function self:CreateTab(name, icon)
        icon = icon or "rbxassetid://4483345998"
        local tab = {}
        tab.Name = name
        
        -- Nút tab
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 90, 1, 0)
        btn.BackgroundColor3 = THEME.BgDark
        btn.BorderSizePixel = 0
        btn.Text = "  " .. name
        btn.TextColor3 = THEME.TextDim
        btn.TextScaled = true
        btn.Font = THEME.Font
        btn.Parent = tabScroll
        
        local iconImg = Instance.new("ImageLabel")
        iconImg.Size = UDim2.new(0, 18, 0, 18)
        iconImg.Position = UDim2.new(0, 4, 0.5, -9)
        iconImg.BackgroundTransparency = 1
        iconImg.Image = icon
        iconImg.Parent = btn
        
        tabScroll.CanvasSize = UDim2.new(0, #self.Tabs * 96 + 20, 0, 0)
        
        -- Frame chứa nội dung tab
        local tabFrame = Instance.new("Frame")
        tabFrame.Size = UDim2.new(1, 0, 1, 0)
        tabFrame.BackgroundTransparency = 1
        tabFrame.Visible = false
        tabFrame.Parent = contentFrame
        
        -- Bố cục 2 cột (mobile: nếu màn hình nhỏ sẽ xếp dọc)
        local leftCol = Instance.new("ScrollingFrame")
        leftCol.Size = UDim2.new(0.5, -6, 1, 0)
        leftCol.Position = UDim2.new(0, 2, 0, 0)
        leftCol.BackgroundTransparency = 1
        leftCol.BorderSizePixel = 0
        leftCol.ScrollBarThickness = 4
        leftCol.CanvasSize = UDim2.new(0, 0, 0, 0)
        leftCol.Parent = tabFrame
        
        local leftLayout = Instance.new("UIListLayout")
        leftLayout.Padding = UDim.new(0, 8)
        leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        leftLayout.Parent = leftCol
        
        local rightCol = leftCol:Clone()
        rightCol.Position = UDim2.new(0.5, 6, 0, 0)
        rightCol.Parent = tabFrame
        local rightLayout = rightCol:FindFirstChildOfClass("UIListLayout") or Instance.new("UIListLayout")
        rightLayout.Padding = UDim.new(0, 8)
        rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        rightLayout.Parent = rightCol
        
        -- Nếu màn hình quá nhỏ, chuyển thành 1 cột
        if viewport.X < 500 then
            leftCol.Size = UDim2.new(1, -4, 0.5, 0)
            rightCol.Size = UDim2.new(1, -4, 0.5, 0)
            rightCol.Position = UDim2.new(0, 0, 0.5, 0)
        end
        
        tab.LeftCol = leftCol
        tab.RightCol = rightCol
        tab.TabFrame = tabFrame
        tab.Button = btn
        
        -- Hàm tạo Groupbox
        local function createGroupbox(parent, title)
            local group = {}
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(0.96, 0, 0, 0)
            frame.BackgroundColor3 = THEME.BgDark
            frame.BackgroundTransparency = 0.2
            frame.BorderSizePixel = 1
            frame.BorderColor3 = THEME.Border
            frame.ClipsDescendants = true
            frame.Parent = parent
            
            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, 0, 0, 30)
            titleLabel.BackgroundColor3 = THEME.BgLight
            titleLabel.BorderSizePixel = 0
            titleLabel.Text = title
            titleLabel.TextColor3 = THEME.Text
            titleLabel.TextScaled = true
            titleLabel.Font = THEME.Font
            titleLabel.TextXAlignment = Enum.TextXAlignment.Center
            titleLabel.Parent = frame
            
            local content = Instance.new("Frame")
            content.Size = UDim2.new(1, 0, 1, -30)
            content.Position = UDim2.new(0, 0, 0, 30)
            content.BackgroundTransparency = 1
            content.Parent = frame
            
            local contentLayout = Instance.new("UIListLayout")
            contentLayout.Padding = UDim.new(0, 6)
            contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            contentLayout.Parent = content
            
            local function updateHeight()
                local h = 30
                for _, child in ipairs(content:GetChildren()) do
                    if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("TextButton") then
                        h = h + child.Size.Y.Offset + 6
                    end
                end
                frame.Size = UDim2.new(0.96, 0, 0, h + 4)
            end
            
            -- Toggle
            function group:AddToggle(text, default, callback)
                local f = Instance.new("Frame")
                f.Size = UDim2.new(1, -8, 0, 32)  -- Tăng chiều cao cho mobile
                f.BackgroundTransparency = 1
                f.Parent = content
                
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(0.6, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = text
                lbl.TextColor3 = THEME.Text
                lbl.TextScaled = true
                lbl.Font = THEME.Font
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = f
                
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(0.3, 0, 1, 0)
                btn.Position = UDim2.new(0.7, 0, 0, 0)
                btn.BackgroundColor3 = default and THEME.ToggleOn or THEME.ToggleOff
                btn.BorderSizePixel = 0
                btn.Text = default and "ON" or "OFF"
                btn.TextColor3 = THEME.Text
                btn.TextScaled = true
                btn.Font = THEME.Font
                btn.Parent = f
                
                local state = default
                btn.MouseButton1Click:Connect(function()
                    state = not state
                    btn.BackgroundColor3 = state and THEME.ToggleOn or THEME.ToggleOff
                    btn.Text = state and "ON" or "OFF"
                    if callback then callback(state) end
                end)
                updateHeight()
            end
            
            -- Slider
            function group:AddSlider(text, min, max, default, increment, suffix, callback)
                local f = Instance.new("Frame")
                f.Size = UDim2.new(1, -8, 0, 44)
                f.BackgroundTransparency = 1
                f.Parent = content
                
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(0.6, 0, 0.5, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = text
                lbl.TextColor3 = THEME.Text
                lbl.TextScaled = true
                lbl.Font = THEME.Font
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = f
                
                local valLbl = Instance.new("TextLabel")
                valLbl.Size = UDim2.new(0.35, 0, 0.5, 0)
                valLbl.Position = UDim2.new(0.65, 0, 0, 0)
                valLbl.BackgroundTransparency = 1
                valLbl.Text = tostring(default) .. (suffix or "")
                valLbl.TextColor3 = THEME.Text
                valLbl.TextScaled = true
                valLbl.Font = THEME.Font
                valLbl.TextXAlignment = Enum.TextXAlignment.Right
                valLbl.Parent = f
                
                local bg = Instance.new("Frame")
                bg.Size = UDim2.new(1, 0, 0, 8)
                bg.Position = UDim2.new(0, 0, 0.7, 0)
                bg.BackgroundColor3 = THEME.BgLight
                bg.BorderSizePixel = 0
                bg.Parent = f
                
                local fill = Instance.new("Frame")
                fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                fill.BackgroundColor3 = THEME.SliderFill
                fill.BorderSizePixel = 0
                fill.Parent = bg
                
                local dragging = false
                local val = default
                local function update(input)
                    local x = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                    val = min + (max - min) * x
                    val = math.round(val / increment) * increment
                    val = math.clamp(val, min, max)
                    fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
                    valLbl.Text = tostring(val) .. (suffix or "")
                    if callback then callback(val) end
                end
                bg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        update(input)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        update(input)
                    end
                end)
                updateHeight()
            end
            
            -- Dropdown
            function group:AddDropdown(text, options, default, callback)
                local f = Instance.new("Frame")
                f.Size = UDim2.new(1, -8, 0, 32)
                f.BackgroundTransparency = 1
                f.Parent = content
                
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(0.5, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = text
                lbl.TextColor3 = THEME.Text
                lbl.TextScaled = true
                lbl.Font = THEME.Font
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = f
                
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(0.4, 0, 1, 0)
                btn.Position = UDim2.new(0.6, 0, 0, 0)
                btn.BackgroundColor3 = THEME.BgLight
                btn.BorderSizePixel = 0
                btn.Text = default or options[1] or ""
                btn.TextColor3 = THEME.Text
                btn.TextScaled = true
                btn.Font = THEME.Font
                btn.Parent = f
                
                local selected = default or options[1]
                local open = false
                local drop = nil
                btn.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        if drop then drop:Destroy() end
                        drop = Instance.new("Frame")
                        drop.Size = UDim2.new(0.4, 0, 0, #options * 26 + 4)
                        drop.Position = UDim2.new(0.6, 0, 1, 0)
                        drop.BackgroundColor3 = THEME.BgDark
                        drop.BorderSizePixel = 1
                        drop.BorderColor3 = THEME.Border
                        drop.ClipsDescendants = true
                        drop.Parent = f
                        local layout = Instance.new("UIListLayout")
                        layout.Padding = UDim.new(0, 2)
                        layout.Parent = drop
                        for _, opt in ipairs(options) do
                            local optBtn = Instance.new("TextButton")
                            optBtn.Size = UDim2.new(1, 0, 0, 26)
                            optBtn.BackgroundColor3 = THEME.BgLight
                            optBtn.BorderSizePixel = 0
                            optBtn.Text = opt
                            optBtn.TextColor3 = THEME.Text
                            optBtn.TextScaled = true
                            optBtn.Font = THEME.Font
                            optBtn.Parent = drop
                            optBtn.MouseButton1Click:Connect(function()
                                selected = opt
                                btn.Text = opt
                                if callback then callback(opt) end
                                open = false
                                drop:Destroy()
                            end)
                        end
                    else
                        if drop then drop:Destroy() end
                    end
                end)
                updateHeight()
            end
            
            -- Multibox
            function group:AddMultibox(text, options, default, callback)
                -- Tương tự dropdown nhưng cho phép chọn nhiều
                local f = Instance.new("Frame")
                f.Size = UDim2.new(1, -8, 0, 32)
                f.BackgroundTransparency = 1
                f.Parent = content
                
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(0.5, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = text
                lbl.TextColor3 = THEME.Text
                lbl.TextScaled = true
                lbl.Font = THEME.Font
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = f
                
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(0.4, 0, 1, 0)
                btn.Position = UDim2.new(0.6, 0, 0, 0)
                btn.BackgroundColor3 = THEME.BgLight
                btn.BorderSizePixel = 0
                btn.Text = default and table.concat(default, ", ") or ""
                btn.TextColor3 = THEME.Text
                btn.TextScaled = true
                btn.Font = THEME.Font
                btn.Parent = f
                
                local selected = default or {}
                local open = false
                local drop = nil
                btn.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        if drop then drop:Destroy() end
                        drop = Instance.new("Frame")
                        drop.Size = UDim2.new(0.4, 0, 0, #options * 26 + 4)
                        drop.Position = UDim2.new(0.6, 0, 1, 0)
                        drop.BackgroundColor3 = THEME.BgDark
                        drop.BorderSizePixel = 1
                        drop.BorderColor3 = THEME.Border
                        drop.ClipsDescendants = true
                        drop.Parent = f
                        local layout = Instance.new("UIListLayout")
                        layout.Padding = UDim.new(0, 2)
                        layout.Parent = drop
                        for _, opt in ipairs(options) do
                            local optBtn = Instance.new("TextButton")
                            optBtn.Size = UDim2.new(1, 0, 0, 26)
                            optBtn.BackgroundColor3 = THEME.BgLight
                            optBtn.BorderSizePixel = 0
                            optBtn.Text = opt .. (table.find(selected, opt) and " ✅" or "")
                            optBtn.TextColor3 = THEME.Text
                            optBtn.TextScaled = true
                            optBtn.Font = THEME.Font
                            optBtn.Parent = drop
                            optBtn.MouseButton1Click:Connect(function()
                                if table.find(selected, opt) then
                                    table.remove(selected, table.find(selected, opt))
                                else
                                    table.insert(selected, opt)
                                end
                                btn.Text = table.concat(selected, ", ")
                                if callback then callback(selected) end
                                -- Refresh dropdown list
                                for _, child in ipairs(drop:GetChildren()) do
                                    if child:IsA("TextButton") then
                                        local txt = child.Text:gsub(" ✅", "")
                                        child.Text = txt .. (table.find(selected, txt) and " ✅" or "")
                                    end
                                end
                            end)
                        end
                    else
                        if drop then drop:Destroy() end
                    end
                end)
                updateHeight()
            end
            
            -- Keybind
            function group:AddKeybind(text, default, callback)
                local f = Instance.new("Frame")
                f.Size = UDim2.new(1, -8, 0, 32)
                f.BackgroundTransparency = 1
                f.Parent = content
                
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(0.5, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = text
                lbl.TextColor3 = THEME.Text
                lbl.TextScaled = true
                lbl.Font = THEME.Font
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = f
                
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(0.3, 0, 1, 0)
                btn.Position = UDim2.new(0.7, 0, 0, 0)
                btn.BackgroundColor3 = THEME.BgLight
                btn.BorderSizePixel = 0
                btn.Text = default and tostring(default) or "None"
                btn.TextColor3 = THEME.Text
                btn.TextScaled = true
                btn.Font = THEME.Font
                btn.Parent = f
                
                local key = default
                local listening = false
                btn.MouseButton1Click:Connect(function()
                    listening = not listening
                    btn.Text = listening and "Press key..." or (key and tostring(key) or "None")
                    btn.BackgroundColor3 = listening and THEME.Accent or THEME.BgLight
                end)
                UserInputService.InputBegan:Connect(function(input, gp)
                    if listening and not gp then
                        key = input.KeyCode
                        if key ~= Enum.KeyCode.Unknown then
                            listening = false
                            btn.Text = tostring(key)
                            btn.BackgroundColor3 = THEME.BgLight
                            if callback then callback(key) end
                        end
                    end
                end)
                updateHeight()
            end
            
            -- Colorpicker
            function group:AddColorpicker(text, default, callback)
                local f = Instance.new("Frame")
                f.Size = UDim2.new(1, -8, 0, 32)
                f.BackgroundTransparency = 1
                f.Parent = content
                
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(0.6, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = text
                lbl.TextColor3 = THEME.Text
                lbl.TextScaled = true
                lbl.Font = THEME.Font
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = f
                
                local colorBtn = Instance.new("TextButton")
                colorBtn.Size = UDim2.new(0.2, 0, 1, 0)
                colorBtn.Position = UDim2.new(0.8, 0, 0, 0)
                colorBtn.BackgroundColor3 = default or Color3.fromRGB(255,0,0)
                colorBtn.BorderSizePixel = 1
                colorBtn.BorderColor3 = THEME.Border
                colorBtn.Text = ""
                colorBtn.Parent = f
                
                local color = default or Color3.fromRGB(255,0,0)
                colorBtn.MouseButton1Click:Connect(function()
                    local picker = Instance.new("Frame")
                    picker.Size = UDim2.new(0, 180, 0, 180)
                    picker.Position = UDim2.new(0.5, -90, 0.5, -90)
                    picker.BackgroundColor3 = THEME.BgDark
                    picker.BorderSizePixel = 1
                    picker.BorderColor3 = THEME.Border
                    picker.Parent = screenGui
                    
                    local presets = {
                        Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), Color3.fromRGB(0,0,255),
                        Color3.fromRGB(255,255,0), Color3.fromRGB(255,0,255), Color3.fromRGB(0,255,255),
                        Color3.fromRGB(255,255,255), Color3.fromRGB(128,128,128), Color3.fromRGB(0,0,0),
                    }
                    local y = 35
                    for i, c in ipairs(presets) do
                        local b = Instance.new("TextButton")
                        b.Size = UDim2.new(0.2, 0, 0, 22)
                        b.Position = UDim2.new(math.floor((i-1)%3)*0.25 + 0.1, 0, 0, y + math.floor((i-1)/3)*28)
                        b.BackgroundColor3 = c
                        b.BorderSizePixel = 1
                        b.BorderColor3 = THEME.Border
                        b.Text = ""
                        b.Parent = picker
                        b.MouseButton1Click:Connect(function()
                            color = c
                            colorBtn.BackgroundColor3 = c
                            if callback then callback(c) end
                            picker:Destroy()
                        end)
                    end
                    local closeP = Instance.new("TextButton")
                    closeP.Size = UDim2.new(0, 30, 0, 30)
                    closeP.Position = UDim2.new(1, -34, 0, 4)
                    closeP.BackgroundColor3 = THEME.ToggleOff
                    closeP.BorderSizePixel = 0
                    closeP.Text = "X"
                    closeP.TextColor3 = THEME.Text
                    closeP.TextScaled = true
                    closeP.Font = THEME.Font
                    closeP.Parent = picker
                    closeP.MouseButton1Click:Connect(function() picker:Destroy() end)
                end)
                updateHeight()
            end
            
            -- Button
            function group:AddButton(text, callback)
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -8, 0, 32)
                btn.BackgroundColor3 = THEME.Accent
                btn.BorderSizePixel = 0
                btn.Text = text
                btn.TextColor3 = THEME.Text
                btn.TextScaled = true
                btn.Font = THEME.Font
                btn.Parent = content
                btn.MouseButton1Click:Connect(callback or function() end)
                updateHeight()
            end
            
            -- Label
            function group:AddLabel(text)
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, -8, 0, 22)
                lbl.BackgroundTransparency = 1
                lbl.Text = text
                lbl.TextColor3 = THEME.TextDim
                lbl.TextScaled = true
                lbl.Font = THEME.Font
                lbl.Parent = content
                updateHeight()
            end
            
            updateHeight()
            return group
        end
        
        function tab:AddLeftGroupbox(title)
            return createGroupbox(self.LeftCol, title)
        end
        function tab:AddRightGroupbox(title)
            return createGroupbox(self.RightCol, title)
        end
        
        -- Kích hoạt tab
        btn.MouseButton1Click:Connect(function()
            if activeTab then
                activeTab.TabFrame.Visible = false
                activeTab.Button.BackgroundColor3 = THEME.BgDark
                activeTab.Button.TextColor3 = THEME.TextDim
            end
            activeTab = tab
            tab.TabFrame.Visible = true
            tab.Button.BackgroundColor3 = THEME.Accent
            tab.Button.TextColor3 = THEME.Text
        end)
        
        if #self.Tabs == 0 then
            activeTab = tab
            tab.TabFrame.Visible = true
            tab.Button.BackgroundColor3 = THEME.Accent
            tab.Button.TextColor3 = THEME.Text
        end
        
        table.insert(self.Tabs, tab)
        return tab
    end
    
    -- ===== NÚT TOGGLE UI (mobile) =====
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 56, 0, 56)
    toggleBtn.Position = UDim2.new(0, 12, 0.5, -28)
    toggleBtn.BackgroundColor3 = THEME.BgDark
    toggleBtn.BackgroundTransparency = 0.3
    toggleBtn.BorderSizePixel = 1
    toggleBtn.BorderColor3 = THEME.Border
    toggleBtn.Text = "☰"
    toggleBtn.TextColor3 = THEME.Text
    toggleBtn.TextScaled = true
    toggleBtn.Font = THEME.Font
    toggleBtn.Draggable = true
    toggleBtn.Parent = screenGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.3, 0)
    corner.Parent = toggleBtn
    
    toggleBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)
    
    -- Keybind
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == self.MenuKey then
            mainFrame.Visible = not mainFrame.Visible
        end
    end)
    
    -- Lưu mainFrame và screenGui
    self.MainFrame = mainFrame
    self.ScreenGui = screenGui
    
    return self
end

return PuppyWare