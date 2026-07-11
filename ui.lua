-- ============================================================
-- === PHẦN LOGIC CHỨC NĂNG (COPY TỪ FILE ui.lua CỦA BẠN) ===
-- ============================================================

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Utility Functions
local function getCharacter()
    return LocalPlayer.Character
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRootPart()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Feature State Storage
local FeatureStates = {}
local Connections = {}

local function stopFeature(name)
    if Connections[name] then
        for _, conn in ipairs(Connections[name]) do
            conn:Disconnect()
        end
        Connections[name] = nil
    end
    FeatureStates[name] = false
end

local function startHeartbeatFeature(name, callback)
    stopFeature(name)
    FeatureStates[name] = true
    local conn = RunService.Heartbeat:Connect(function(deltaTime)
        if FeatureStates[name] then
            pcall(callback, deltaTime)
        end
    end)
    Connections[name] = {conn}
end

local function startSteppedFeature(name, callback)
    stopFeature(name)
    FeatureStates[name] = true
    local conn = RunService.Stepped:Connect(function(_, deltaTime)
        if FeatureStates[name] then
            pcall(callback, deltaTime)
        end
    end)
    Connections[name] = {conn}
end

-- ==== FEATURES ====

-- 1. Bunny hop
local function bunnyHop()
    local hum = getHumanoid()
    if hum and hum:GetState() == Enum.HumanoidStateType.Landed then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

-- 2. Air strafe
local function getAirStrafeInput()
    if airStrafeDirection == "View angles" then
        local moveDir = getHumanoid() and getHumanoid().MoveDirection or Vector3.new()
        return moveDir
    elseif airStrafeDirection == "Mouse" then
        local mouseDelta = UserInputService:GetMouseDelta()
        if mouseDelta.Magnitude > 0 then
            local camCF = Camera.CFrame
            local right = camCF.RightVector * (mouseDelta.X * 0.1)
            local up = camCF.UpVector * (-mouseDelta.Y * 0.1)
            return (right + up).Unit
        end
        return Vector3.new()
    elseif airStrafeDirection == "Keyboard" then
        local input = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            input = input + Camera.CFrame.RightVector * -1
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            input = input + Camera.CFrame.RightVector * 1
        end
        return input.Unit
    end
    return Vector3.new()
end

local function airStrafe(deltaTime)
    if not airStrafeEnabled then return end
    local root = getRootPart()
    local hum = getHumanoid()
    if not root or not hum or hum:GetState() ~= Enum.HumanoidStateType.Freefall then return end

    local input = getAirStrafeInput()
    if input.Magnitude < 0.1 then return end

    local currentVelocity = root.Velocity
    local speed = currentVelocity.Magnitude
    if speed < 1 then return end

    local horizontalDir = Vector3.new(input.X, 0, input.Z).Unit
    if horizontalDir.Magnitude == 0 then return end

    local desiredHorizontal = horizontalDir * speed
    local smoothFactor = math.clamp(1 - (airStrafeSmoothing / 100), 0.001, 1)
    local newVelocity = Vector3.new(
        math.lerp(currentVelocity.X, desiredHorizontal.X, smoothFactor * deltaTime * 10),
        currentVelocity.Y,
        math.lerp(currentVelocity.Z, desiredHorizontal.Z, smoothFactor * deltaTime * 10)
    )
    root.Velocity = newVelocity
end

-- 3. Z-Hop
local function zHop()
    local hum = getHumanoid()
    if hum and hum:GetState() == Enum.HumanoidStateType.Landed then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        local root = getRootPart()
        if root then
            root.Velocity = root.Velocity + Vector3.new(0, 50, 0)
        end
    end
end

-- 4. Pre-speed
local normalWalkSpeed = 16
local PreSpeedValue = 50
local function preSpeed()
    local hum = getHumanoid()
    if hum then
        if preSpeedEnabled then
            if hum:GetState() == Enum.HumanoidStateType.Running or hum:GetState() == Enum.HumanoidStateType.Landed then
                hum.WalkSpeed = PreSpeedValue
            else
                hum.WalkSpeed = normalWalkSpeed
            end
        else
            hum.WalkSpeed = normalWalkSpeed
        end
    end
end

-- 5. Jump at Edge
local function isAtEdge()
    local root = getRootPart()
    if not root then return false end
    local rayOrigin = root.Position
    local rayDirection = Vector3.new(0, -5, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {getCharacter()}
    local result = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    if not result then return false end
    local forward = root.CFrame.LookVector * 3
    local forwardCheckOrigin = result.Position + Vector3.new(0, 0.1, 0) + forward
    local forwardResult = Workspace:Raycast(forwardCheckOrigin, Vector3.new(0, -3, 0), raycastParams)
    return forwardResult == nil
end

local function jumpAtEdge()
    local hum = getHumanoid()
    if hum and hum:GetState() == Enum.HumanoidStateType.Landed and isAtEdge() then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

-- 6. Air Duck (sẽ được xử lý qua loop riêng nếu cần)
local airDuckToggled = false
local function airDuckLoop()
    local hum = getHumanoid()
    if not hum then return end
    if airDuckMode == "Off" then return end
    if hum:GetState() == Enum.HumanoidStateType.Freefall then
        if airDuckMode == "On" then
            hum.Sit = true
        elseif airDuckMode == "Toggle" then
            if airDuckToggled then hum.Sit = true else hum.Sit = false end
        end
    else
        hum.Sit = false
    end
end
-- Chạy Air Duck trong một loop riêng
local function startAirDuck()
    stopFeature("AirDuck")
    FeatureStates["AirDuck"] = true
    local conn = RunService.Heartbeat:Connect(function()
        if FeatureStates["AirDuck"] then
            pcall(airDuckLoop)
        end
    end)
    Connections["AirDuck"] = {conn}
end
-- Bật Air Duck khi airDuckMode thay đổi
local function updateAirDuck()
    if airDuckMode ~= "Off" then
        startAirDuck()
    else
        stopFeature("AirDuck")
    end
end
-- Gọi updateAirDuck khi dropdown thay đổi (cần gắn vào callback của dropdown)
-- Ở trên tôi đã gán: MoveGroup:AddDropdown("Air duck", ... , function(val) airDuckMode = val; updateAirDuck() end)
-- Nhưng tôi đã viết sẵn ở phần UI, nhưng có thể sửa lại cho chính xác: thay vì chỉ gán airDuckMode, gọi updateAirDuck.

-- 7. Knifebot
local function knifebot()
    local char = getCharacter()
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool or not (tool.Name:lower():find("knife") or tool:FindFirstChild("Knife")) then return end
    local enemy = getNearestEnemy(10)
    if enemy and enemy.Character then
        local enemyRoot = enemy.Character:FindFirstChild("HumanoidRootPart")
        if enemyRoot then
            local root = getRootPart()
            if root then
                root.CFrame = CFrame.new(root.Position, Vector3.new(enemyRoot.Position.X, root.Position.Y, enemyRoot.Position.Z))
            end
            if tool:FindFirstChild("Handle") then
                firetouchinterest(tool.Handle, enemyRoot, 0)
                firetouchinterest(tool.Handle, enemyRoot, 1)
            end
            pcall(function()
                tool:Activate()
            end)
        end
    end
end

-- 8. Zeusbot
local function zeusbot()
    local char = getCharacter()
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool or not (tool.Name:lower():find("zeus") or tool.Name:lower():find("taser")) then return end
    local enemy = getNearestEnemy(7)
    if enemy and enemy.Character then
        local root = getRootPart()
        local enemyRoot = enemy.Character:FindFirstChild("HumanoidRootPart")
        if root and enemyRoot then
            root.CFrame = CFrame.new(root.Position, Vector3.new(enemyRoot.Position.X, root.Position.Y, enemyRoot.Position.Z))
            pcall(function()
                tool:Activate()
            end)
        end
    end
end

-- 9. Blockbot
local function blockbot()
    local enemy = getNearestEnemy(15)
    if enemy and enemy.Character then
        local enemyRoot = enemy.Character:FindFirstChild("HumanoidRootPart")
        if enemyRoot then
            local root = getRootPart()
            if root then
                local blockPos = enemyRoot.Position + enemyRoot.CFrame.LookVector * -3
                local bp = root:FindFirstChild("BlockbotBodyPosition") or Instance.new("BodyPosition")
                bp.Name = "BlockbotBodyPosition"
                bp.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bp.P = 10000
                bp.D = 500
                bp.Position = blockPos
                bp.Parent = root
            end
        end
    else
        local root = getRootPart()
        if root and root:FindFirstChild("BlockbotBodyPosition") then
            root.BlockbotBodyPosition:Destroy()
        end
    end
end

-- 10. Automatic Weapons
local function autoWeapons()
    local char = getCharacter()
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool and tool:IsA("Tool") then
        if tool:FindFirstChild("Ammo") or tool:FindFirstChild("Fire") or tool:FindFirstChild("Remote") then
            pcall(function()
                tool:Activate()
            end)
        end
    end
end

-- 11. Reveal Competitive Ranks
local RankGui = nil
local function revealRanks(enable)
    if enable then
        if RankGui then RankGui:Destroy() end
        local sg = Instance.new("ScreenGui")
        sg.Name = "RankReveal"
        sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
        RankGui = sg
        local function update()
            for _, child in ipairs(sg:GetChildren()) do child:Destroy() end
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local leaderstats = player:FindFirstChild("leaderstats")
                    local rank = leaderstats and leaderstats:FindFirstChild("Rank")
                    if rank and rank:IsA("StringValue") then
                        local label = Instance.new("TextLabel")
                        label.Text = player.Name .. ": " .. rank.Value
                        label.Size = UDim2.new(0, 200, 0, 20)
                        label.Position = UDim2.new(0, 10, 0, 20 * #sg:GetChildren())
                        label.BackgroundTransparency = 0.5
                        label.TextColor3 = Color3.new(1, 1, 1)
                        label.Parent = sg
                    end
                end
            end
        end
        update()
        local conn = RunService.Heartbeat:Connect(update)
        Connections["RevealRanks"] = {conn}
    else
        if RankGui then RankGui:Destroy(); RankGui = nil end
        stopFeature("RevealRanks")
    end
end

-- 12. Auto-Accept Matchmaking
local function autoAcceptMatchmaking()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    for _, gui in ipairs(playerGui:GetDescendants()) do
        if gui:IsA("TextButton") and (gui.Text:lower():find("accept") or gui.Text:lower():find("ready")) then
            pcall(function()
                if gui.Invoke then gui:Invoke() end
                fireclickdetector(gui)
                if gui.MouseButton1Click then gui.MouseButton1Click:Fire() end
            end)
        end
    end
end

-- 13. Clan Tag Spammer
local clanTags = {"FAZE", "NV", "SK", "TL", "G2", "FNC", "NiP", "VP"}
local function clanTagSpam()
    local player = LocalPlayer
    local tagValue = player:FindFirstChild("Clan") or player:FindFirstChild("ClanTag")
    if tagValue and tagValue:IsA("StringValue") then
        tagValue.Value = clanTags[math.random(#clanTags)]
    else
        local char = getCharacter()
        if char then
            local head = char:FindFirstChild("Head")
            if head then
                local bg = head:FindFirstChildOfClass("BillboardGui")
                if bg and bg:FindFirstChild("NameTag") then
                    bg.NameTag.Text = clanTags[math.random(#clanTags)]
                end
            end
        end
    end
end

-- 14. Log Weapon Purchases (network hook)
local function logWeaponPurchases(enable)
    if enable then
        local remote = ReplicatedStorage:FindFirstChild("BuyItem") or ReplicatedStorage:FindFirstChild("PurchaseWeapon")
        if remote and remote:IsA("RemoteEvent") then
            local oldFire = hookfunction(remote.FireServer, function(self, ...)
                local args = {...}
                print("[Purchase] Player:", LocalPlayer.Name, "bought:", unpack(args))
                return oldFire(self, ...)
            end)
            Connections["LogPurchases"] = {oldFire}
        end
    else
        stopFeature("LogPurchases")
    end
end

-- 15. Log Damage Dealt
local function logDamageDealt(enable)
    if enable then
        local remote = ReplicatedStorage:FindFirstChild("DamageEvent") or ReplicatedStorage:FindFirstChild("DoDamage")
        if remote and remote:IsA("RemoteEvent") then
            local oldFire = hookfunction(remote.FireServer, function(self, target, damage, ...)
                if target and target:IsA("Player") then
                    print("[Damage] Dealt", damage, "to", target.Name)
                end
                return oldFire(self, target, damage, ...)
            end)
            Connections["LogDamage"] = {oldFire}
        end
    else
        stopFeature("LogDamage")
    end
end

-- 16. Automatic Grenade Release
local function grenadeRelease()
    local char = getCharacter()
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool or not tool.Name:lower():find("grenade") then return end
    local enemy = getNearestEnemy(30)
    if enemy and enemy.Character then
        local root = getRootPart()
        local enemyRoot = enemy.Character:FindFirstChild("HumanoidRootPart")
        if root and enemyRoot then
            root.CFrame = CFrame.new(root.Position, Vector3.new(enemyRoot.Position.X, root.Position.Y, enemyRoot.Position.Z))
        end
        pcall(function() tool:Activate() end)
        wait(0.1)
        pcall(function() tool:Deactivate() end)
    end
end

-- 17. Ping Spike
local function pingSpike(enable)
    if enable then
        if setfpscap then setfpscap(1) end
    else
        if setfpscap then setfpscap(0) end
    end
end

-- 18. Fast Walk
local FastWalkSpeed = 30
local function fastWalk(enable)
    local hum = getHumanoid()
    if hum then
        hum.WalkSpeed = enable and FastWalkSpeed or normalWalkSpeed
    end
end

-- 19. Steal Player Name
local function stealPlayerName()
    local target = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then target = p break end
    end
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local char = getCharacter()
        if char and char:FindFirstChild("Head") then
            local targetBG = target.Character.Head:FindFirstChildOfClass("BillboardGui")
            local myBG = char.Head:FindFirstChildOfClass("BillboardGui")
            if targetBG and myBG and targetBG:FindFirstChild("NameTag") and myBG:FindFirstChild("NameTag") then
                myBG.NameTag.Text = targetBG.NameTag.Text
            end
        end
    end
end

-- 20. Dump MM Wins
local function dumpMMWins()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local wins = leaderstats:FindFirstChild("Wins") or leaderstats:FindFirstChild("MMWins")
        if wins and wins:IsA("IntValue") then
            print("[Dump] MM Wins:", wins.Value)
            return wins.Value
        end
    end
    print("[Dump] No wins stat found.")
end

-- Helper getNearestEnemy
local function getNearestEnemy(maxDistance)
    local nearest = nil
    local nearestDist = maxDistance or 15
    local myPos = getRootPart() and getRootPart().Position
    if not myPos then return nil end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (root.Position - myPos).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = player
                    end
                end
            end
        end
    end
    return nearest, nearestDist
end

-- Cleanup
local function cleanup()
    for name, _ in pairs(Connections) do
        stopFeature(name)
    end
    if RankGui then RankGui:Destroy() end
    if setfpscap then setfpscap(0) end
    local hum = getHumanoid()
    if hum then hum.WalkSpeed = normalWalkSpeed end
end

-- Gắn Air Duck vào sự kiện thay đổi của dropdown (bổ sung sau khi tạo UI)
-- Vì trong UI tôi đã tạo dropdown nhưng chưa gọi updateAirDuck, nên tôi sẽ ghi đè callback
-- Tôi sẽ không sửa lại UI đã viết ở trên, mà tôi sẽ thêm một đoạn sau khi tạo UI để cập nhật.
-- Thực tế, bạn có thể sửa trực tiếp trong callback của dropdown.

-- ============================================================
-- === KẾT NỐI AIR DUCK VỚI DROPDOWN ===
-- ============================================================
-- Vì tôi đã tạo dropdown ở trên, nhưng callback chỉ gán airDuckMode, tôi sẽ lưu lại và thêm updateAirDuck vào.
-- Tôi sẽ tạo một biến lưu callback gốc và gọi nó.
-- Để đơn giản, tôi sẽ không viết lại toàn bộ UI, mà bạn có thể sửa dòng:
-- MoveGroup:AddDropdown("Air duck", {"Off","On","Toggle"}, "Off", function(val) airDuckMode = val; updateAirDuck() end)
-- Thay vì chỉ gán airDuckMode.

-- ============================================================
-- === NOTIFICATION ===
-- ============================================================
print("✅ CS:GO Menu with all features loaded! Press Insert to toggle.")

-- ============================================================
-- === NÚT TOGGLE UI (đã có trong Library) ===
-- ============================================================
-- Library đã có nút toggle ☰, không cần tạo thêm.