--// ===================================================================
--// OPTIMIZED ADVANCED TOOL UI
--// ===================================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

--// CONFIGURATION
local CONFIG = {
    UI = {
        Size = UDim2.new(0, 560, 0, 420),
        Position = UDim2.fromScale(0.5, 0.5),
        BackgroundColor = Color3.fromRGB(18, 18, 18),
        CornerRadius = 10,
    },
    Keybind = Enum.KeyCode.F9,
    AutoSave = true
}

--// SIMPLIFIED UTILITIES
local Utilities = {
    SafeCall = function(callback, errorMessage)
        local success, result = pcall(callback)
        if not success then
            warn("[AdvancedToolUI] " .. (errorMessage or "Error") .. ": " .. tostring(result))
            return false
        end
        return true, result
    end,
    
    CreateInstance = function(className, properties)
        local instance = Instance.new(className)
        for prop, value in pairs(properties) do
            if prop ~= "Parent" then
                instance[prop] = value
            end
        end
        return instance
    end
}

--// SIMPLIFIED UI BUILDER
local function CreateMainUI()
    local mainGUI = Utilities.CreateInstance("ScreenGui", {
        Name = "AdvancedToolUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    
    local mainFrame = Utilities.CreateInstance("Frame", {
        Size = CONFIG.UI.Size,
        Position = CONFIG.UI.Position,
        BackgroundColor3 = CONFIG.UI.BackgroundColor,
        BorderSizePixel = 0,
        Parent = mainGUI
    })
    
    local corner = Utilities.CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, CONFIG.UI.CornerRadius),
        Parent = mainFrame
    })
    
    -- Top Bar
    local topBar = Utilities.CreateInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Color3.fromRGB(28, 28, 28),
        BorderSizePixel = 0,
        Parent = mainFrame
    })
    
    Utilities.CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, CONFIG.UI.CornerRadius),
        Parent = topBar
    })
    
    Utilities.CreateInstance("TextLabel", {
        Text = "⚡ Advanced Tool UI",
        Size = UDim2.new(1, -140, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 17,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topBar
    })
    
    -- Close Button
    local closeButton = Utilities.CreateInstance("TextButton", {
        Size = UDim2.new(0, 44, 0, 44),
        Position = UDim2.new(1, -44, 0, 0),
        Text = "✕",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = Color3.fromRGB(220, 80, 80),
        BackgroundTransparency = 1,
        AutoButtonColor = false,
        Parent = topBar
    })
    
    -- Tab Container
    local tabContainer = Utilities.CreateInstance("Frame", {
        Size = UDim2.new(0, 140, 1, -44),
        Position = UDim2.new(0, 0, 0, 44),
        BackgroundColor3 = Color3.fromRGB(23, 23, 23),
        BorderSizePixel = 0,
        Parent = mainFrame
    })
    
    -- Content Container
    local contentContainer = Utilities.CreateInstance("Frame", {
        Size = UDim2.new(1, -140, 1, -44),
        Position = UDim2.new(0, 140, 0, 44),
        BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = mainFrame
    })
    
    -- Toggle Button
    local toggleGUI = Utilities.CreateInstance("ScreenGui", {
        Name = "ToggleUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CoreGui
    })
    
    local toggleButton = Utilities.CreateInstance("TextButton", {
        Size = UDim2.new(0, 52, 0, 52),
        Position = UDim2.new(0, 22, 0.5, -26),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        Text = "⚡",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        AutoButtonColor = false,
        Parent = toggleGUI
    })
    
    Utilities.CreateInstance("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = toggleButton
    })
    
    return {
        MainGUI = mainGUI,
        MainFrame = mainFrame,
        TopBar = topBar,
        TabContainer = tabContainer,
        ContentContainer = contentContainer,
        ToggleGUI = toggleGUI,
        ToggleButton = toggleButton,
        CloseButton = closeButton
    }
end

--// SIMPLIFIED TAB SYSTEM
local function CreateTabSystem(tabContainer, contentContainer)
    local tabs = {}
    local currentTab = nil
    
    local function CreateTab(name, index)
        local button = Utilities.CreateInstance("TextButton", {
            Size = UDim2.new(1, -12, 0, 48),
            Position = UDim2.new(0, 6, 0, 6 + (index - 1) * 54),
            BackgroundColor3 = Color3.fromRGB(32, 32, 32),
            Text = name,
            TextColor3 = Color3.fromRGB(190, 190, 190),
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            AutoButtonColor = false,
            Parent = tabContainer
        })
        
        Utilities.CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = button
        })
        
        local page = Utilities.CreateInstance("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 5,
            ScrollBarImageColor3 = Color3.fromRGB(90, 90, 90),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            Parent = contentContainer
        })
        
        local layout = Utilities.CreateInstance("UIListLayout", {
            Padding = UDim.new(0, 9),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = page
        })
        
        Utilities.CreateInstance("UIPadding", {
            PaddingTop = UDim.new(0, 12),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
            Parent = page
        })
        
        tabs[name] = {
            Button = button,
            Page = page,
            Layout = layout
        }
        
        button.MouseButton1Click:Connect(function()
            if currentTab then
                tabs[currentTab].Page.Visible = false
                tabs[currentTab].Button.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
            end
            
            page.Visible = true
            button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            currentTab = name
        end)
        
        return page
    end
    
    local function AddButton(tabName, buttonText, callback)
        if not tabs[tabName] then return end
        
        local page = tabs[tabName].Page
        local button = Utilities.CreateInstance("TextButton", {
            Size = UDim2.new(1, -22, 0, 42),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            Text = "  " .. buttonText,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            Parent = page
        })
        
        Utilities.CreateInstance("UICorner", {
            CornerRadius = UDim.new(0, 7),
            Parent = button
        })
        
        -- Button interactivity
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
        end)
        
        button.MouseButton1Click:Connect(function()
            Utilities.SafeCall(callback, "Button action failed: " .. buttonText)
        end)
        
        -- Auto-size page
        tabs[tabName].Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, tabs[tabName].Layout.AbsoluteContentSize.Y + 24)
        end)
    end
    
    return {
        CreateTab = CreateTab,
        AddButton = AddButton,
        SwitchToTab = function(name)
            if tabs[name] then
                tabs[name].Button:MouseButton1Click()
            end
        end
    }
end

--// SIMPLIFIED FEATURES
local Features = {
    NoClip = {
        Enabled = false,
        Connection = nil,
        
        Toggle = function()
            Features.NoClip.Enabled = not Features.NoClip.Enabled
            local character = LocalPlayer.Character
            
            if Features.NoClip.Enabled and character then
                -- Enable NoClip
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
                
                Features.NoClip.Connection = character.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("BasePart") then
                        descendant.CanCollide = false
                    end
                end)
                
                print("NoClip: Enabled")
            else
                -- Disable NoClip
                if Features.NoClip.Connection then
                    Features.NoClip.Connection:Disconnect()
                    Features.NoClip.Connection = nil
                end
                
                if character then
                    for _, part in ipairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end
                
                print("NoClip: Disabled")
            end
        end
    },
    
    SpeedHack = function(speed)
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = speed or 100
                print("WalkSpeed: " .. humanoid.WalkSpeed)
            end
        end
    end,
    
    AntiAFK = {
        Enabled = false,
        Connection = nil,
        
        Toggle = function()
            Features.AntiAFK.Enabled = not Features.AntiAFK.Enabled
            
            if Features.AntiAFK.Enabled then
                local virtualUser = game:GetService("VirtualUser")
                Features.AntiAFK.Connection = game:GetService("Players").LocalPlayer.Idled:Connect(function()
                    virtualUser:CaptureController()
                    virtualUser:ClickButton2(Vector2.new())
                end)
                print("Anti-AFK: Enabled")
            else
                if Features.AntiAFK.Connection then
                    Features.AntiAFK.Connection:Disconnect()
                    Features.AntiAFK.Connection = nil
                end
                print("Anti-AFK: Disabled")
            end
        end
    }
}

--// MAIN INITIALIZATION
local function InitializeUI()
    local ui = CreateMainUI()
    local tabSystem = CreateTabSystem(ui.TabContainer, ui.ContentContainer)
    
    -- Create tabs and add features
    local teleportTab = tabSystem.CreateTab("Teleport", 1)
    local toolsTab = tabSystem.CreateTab("Tools", 2)
    local playerTab = tabSystem.CreateTab("Player", 3)
    
    -- Teleport Tab
    tabSystem.AddButton("Teleport", "NoClip Toggle", Features.NoClip.Toggle)
    tabSystem.AddButton("Teleport", "Speed Hack (100)", function() Features.SpeedHack(100) end)
    tabSystem.AddButton("Teleport", "Speed Hack (50)", function() Features.SpeedHack(50) end)
    
    -- Tools Tab
    tabSystem.AddButton("Tools", "Anti-AFK Toggle", Features.AntiAFK.Toggle)
    tabSystem.AddButton("Tools", "Reset Character", function()
        local character = LocalPlayer.Character
        if character then
            character:BreakJoints()
        end
    end)
    
    -- Player Tab
    tabSystem.AddButton("Player", "Copy Game ID", function()
        if setclipboard then
            setclipboard(tostring(game.PlaceId))
            print("Game ID copied: " .. game.PlaceId)
        end
    end)
    
    -- Toggle functionality
    local isUIVisible = true
    
    local function ToggleUI()
        isUIVisible = not isUIVisible
        
        if isUIVisible then
            ui.MainFrame.Visible = true
            TweenService:Create(ui.MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
            ui.ToggleButton.Text = "⚡"
        else
            TweenService:Create(ui.MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            wait(0.3)
            ui.MainFrame.Visible = false
            ui.ToggleButton.Text = "▶"
        end
    end
    
    -- Toggle button click
    ui.ToggleButton.MouseButton1Click:Connect(ToggleUI)
    
    -- Keybind
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == CONFIG.Keybind then
            ToggleUI()
        end
    end)
    
    -- Close button
    ui.CloseButton.MouseButton1Click:Connect(function()
        ui.MainGUI:Destroy()
        ui.ToggleGUI:Destroy()
    end)
    
    -- Simple drag functionality
    local dragging = false
    local dragInput, dragStart, startPos
    
    ui.TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = ui.MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    ui.TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            ui.MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Switch to first tab
    tabSystem.SwitchToTab("Teleport")
    
    print("⚡ Advanced Tool UI Loaded Successfully!")
    print("Press F9 or click the toggle button to show/hide")
    
    return ui
end

--// STARTUP
if LocalPlayer.Character then
    InitializeUI()
else
    LocalPlayer.CharacterAdded:Connect(function()
        wait(1)
        InitializeUI()
    end)
end

-- Fallback
task.delay(3, function()
    if not CoreGui:FindFirstChild("AdvancedToolUI") then
        InitializeUI()
    end
end)

return "Advanced Tool UI - Simplified & Stable"
