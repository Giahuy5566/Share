-- made By Hypol-X
local Library = loadstring(game:HttpGetAsync("https://pastefy.app/YoX4PJmf/raw"))()

-- // 2. Set Whitelisted Users for Paid Access
Library.WhitelistedUsers = {
    "Username",
    "Username1",
    "Username2",
    "Username3",
    "Username4"-- Limitless Whitelist You Can Add another too usernames for Paid Access Tabs Feaures.
}

-- // 3. Create Main Window
local Window = Library:CreateWindow({
    Title = "ZyronX Ui Library",
    Subtitle = "Made By Hypol-X",
    SubtitleColor = Color3.fromRGB(190, 140, 255),
-- Edit the Logo Image ID below (This renders inside the Topbar)
    Logo = "rbxassetid://82367817676382",
    LogoSize = 32, -- Adjust the size of the Topbar Logo here independently

-- // SPHERE TOGGLE CONFIGURATION //
    SphereText = false, -- Set to true to prioritize text over the image
    SphereWords = "ZX", -- Custom text to display if SphereText is true
    SphereImage = "rbxassetid://82367817676382",
    SphereIconSize = 38 -- Adjust the size of the Sphere Icon here independently
})


local MainTab = Window:CreateTab("Main", true, false)

-- Pages
local M_Page1 = MainTab:CreatePage("Page 1")
local M_Page2 = MainTab:CreatePage("Page 2")

-- Page 1 Sections
local CombatCard = M_Page1:CreateSection("Combat")


CombatCard:AddToggle("Aimbot", false, 
    function(state)
    
    end, {
})

CombatCard:AddDropdown("Target Part", {
    "Head", "Torso", "Left Arm", "Right Arm", "Legs", "HumanoidRootPart"
}, false, function(selected) print("Target:", selected) end, {
    Title = "Target Body Part",
    Description = "Select which specific part of the opponent's body the aimbot will lock onto.",
    Example = "Selecting 'Head' maximizes damage, but 'Torso' offers a more stable hit rate on moving targets."
})

local MovementCard = M_Page1:CreateSection("Movement")
MovementCard:AddSlider("Walk Speed", 16, 150, 16, function(val) print("Speed:", val) end, {
    Title = "Walk Speed Adjustment",
    Description = "Modifies your character's base movement speed. Extremely high values might trigger server anti-cheat kicks."
})
MovementCard:AddButton("Teleport to Spawn", function() print("Teleported") end)

local VisualsCard = M_Page1:CreateSection("Visuals")
VisualsCard:AddDropdown("ESP Filters", {
    "Players", "NPCs", "Items", "Vehicles", "Chests", "Ammunition", "Objectives", "Explosives", "Traps"
}, true, function(selected) print("ESP:", unpack(selected)) end, {
    Title = "ESP Filtering Engine",
    Description = "Multi-select categories to highlight through walls. Use the real-time search bar to quickly find filters in large lists.",
    Example = "Select 'Players' and 'Explosives' for tactical awareness."
})
VisualsCard:AddColorPicker("ESP Color", Color3.fromRGB(255, 0, 0),
    function(color)
    end, {})

local MiscCard = M_Page1:CreateSection("Miscellaneous")
MiscCard:AddTextbox("Discord Webhook", "Enter link...", function(text) print("Webhook:", text) end, {
    Title = "Log Webhook",
    Description = "Input a Discord Webhook URL to automatically forward in-game logs and kill-feed data to your private server."
})

-- Page 2 Sections
local UtilitiesCard = M_Page2:CreateSection("Utilities")
UtilitiesCard:AddCopyButton("Copy Example Word", "Example", {
    Title = "Copy To Clipboard",
    Description = "A built-in utility allowing you to quickly port specific string configurations locally to your machine.",
    Example = "Clicking this will natively push 'Example' to your OS Clipboard."
})

local UICustomCard = M_Page2:CreateSection("UI Customization")
UICustomCard:AddColorPicker("Hub Title Color", Color3.fromRGB(255, 255, 255), function(color) Window.Title.TextColor3 = color end, {
    Title = "Dynamic Interface Theming",
    Description = "Drag the color wheel to alter the accent colors of your GUI in real-time.",
    Example = "Try changing this to match your game's atmosphere."
})

local NotifCard = M_Page2:CreateSection("Notifications Tests")
NotifCard:AddToggle("Toggle Notification", false, function(state)
    if state then
    Library:Notify({
        Title = "Toggle Fired",
        Description = "You've summoned a custom notification via toggle.",
        Duration = 3
    })
    end
    end)

NotifCard:AddButton("Button Notification", function()
    Library:Notify({
        Title = "Action Executed",
        Description = "Notification created perfectly on click.",
        Duration = 3
    })
    end)

-- // ========================================== //
-- // SETTINGS TAB
-- // ========================================== //
local SettingsTab = Window:CreateTab("Settings", false, false)

local S_Page1 = SettingsTab:CreatePage("Settings")

local AppearanceCard = S_Page1:CreateSection("UI Config")
AppearanceCard:AddToggle("Transparency Toggle", false, function(state)
    Window:SetTransparency(state and 0.2 or 0)
    end, {
        Title = "Glass Architecture",
        Description = "Overrides main window background for a sleek 0.2 transparency visual."
    })

local SavesCard = S_Page1:CreateSection("Config")
SavesCard:AddConfigManager("zyronxSavers") -- zyronxSavers ITS A FILES NAME IF YOU WANT TO MAKE SCRIPT OUT OF THIS CONFIG CHANGE THE NAMES ANYTHING. THAN zyronxSavers

-- // ========================================== //
-- // PREMIUM TAB (Whitelisted Only)
-- // ========================================== //
local PremiumTab = Window:CreateTab("Pro Configs", false, true)

local P_Page1 = PremiumTab:CreatePage("Page 1")

local ProCard = P_Page1:CreateSection("Pro Capabilities")
ProCard:AddToggle("Premium Override", false, function(state) print("Override:", state) end, {
    Title = "Premium Override",
    Description = "An exclusive toggle switch lever for unlocking premium modules.",
    Example = "Activate to bypass security checks and unlock additional execution tools."
})
ProCard:AddButton("Execute Example Script", function() print("Executing Script...") end, {
    Title = "Execute Script",
    Description = "A working example button that runs privileged developer code.",
    Example = "Clicking this instantly runs the preset custom script block below."
})