--// Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

--// Storage
local savedCFrame = nil
local savedPositions = {}
local noclipConnection = nil
local consoleLogs = {}
local isConsoleOpen = false

--// Helpers
local function createElement(className, properties)
    local element = Instance.new(className)
    for property, value in pairs(properties) do
        if property == "Parent" then
            element.Parent = value
        else
            pcall(function() element[property] = value end)
        end
    end
    return element
end

--// Notification System (บนขวา)
local function createNotification(title, message, notifType, duration)
    duration = duration or 3
    notifType = notifType or "info"
    
    local colorMap = {
        success = Color3.fromRGB(46, 204, 113),
        error = Color3.fromRGB(231, 76, 60),
        info = Color3.fromRGB(52, 152, 219),
        warning = Color3.fromRGB(241, 196, 15)
    }
    
    local notif = createElement("ScreenGui", {
        Name = "Notification",
        Parent = game:GetService("CoreGui"),
        ResetOnSpawn = false
    })
    
    local main = createElement("Frame", {
        Size = UDim2.new(0, 300, 0, 80),
        Position = UDim2.new(1, 10, 1, -90),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        Parent = notif
    })
    
    createElement("UICorner", { CornerRadius = UDim.new(0, 8), Parent = main })
    createElement("UIStroke", { Color = colorMap[notifType], Thickness = 2, Parent = main })
    
    local icon = createElement("TextLabel", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = notifType == "success" and "✓" or notifType == "error" and "✕" or "ℹ",
        TextColor3 = colorMap[notifType],
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        Parent = main
    })
    
    local titleLabel = createElement("TextLabel", {
        Size = UDim2.new(1, -50, 0, 20),
        Position = UDim2.new(0, 40, 0, 10),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = main
    })
    
    local msgLabel = createElement("TextLabel", {
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 35),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = main
    })
    
    -- Animation
    TweenService:Create(main, TweenInfo.new(0.3), {Position = UDim2.new(1, -310, 1, -90)}):Play()
    
    task.delay(duration, function()
        TweenService:Create(main, TweenInfo.new(0.3), {Position = UDim2.new(1, 10, 1, -90)}):Play()
        task.wait(0.3)
        notif:Destroy()
    end)
end

--// UI Creation
local ScreenGui = createElement("ScreenGui", {
    Name = "AdvancedToolUI",
    Parent = game:GetService("CoreGui"),
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

--// Toggle Button
local ToggleUIBtn = createElement("TextButton", {
    Name = "ToggleUIBtn",
    Size = UDim2.new(0, 50, 0, 50),
    Position = UDim2.new(0, 20, 0, 20),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    BorderSizePixel = 0,
    Text = "☰",
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Visible = true,
    Parent = ScreenGui
})

createElement("UICorner", { CornerRadius = UDim.new(0, 8), Parent = ToggleUIBtn })

--// Main Frame
local MainFrame = createElement("Frame", {
    Size = UDim2.new(0, 600, 0, 450),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
    BorderSizePixel = 0,
    Active = true,
    Visible = false,
    Parent = ScreenGui
})

createElement("UICorner", { CornerRadius = UDim.new(0, 8), Parent = MainFrame })

--// Top Bar
local TopBar = createElement("Frame", {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    BorderSizePixel = 0,
    Parent = MainFrame
})

createElement("UICorner", { CornerRadius = UDim.new(0, 8), Parent = TopBar })

--// Title
local Title = createElement("TextLabel", {
    Text = "🛠️ Advanced Tool UI v2.0",
    Size = UDim2.new(1, -130, 1, 0),
    Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TopBar
})

--// Control Buttons
local CloseBtn = createElement("TextButton", {
    Size = UDim2.new(0, 40, 0, 40),
    Position = UDim2.new(1, -40, 0, 0),
    Text = "✕",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = Color3.fromRGB(200, 80, 80),
    BackgroundTransparency = 1,
    Parent = TopBar
})

local MinBtn = createElement("TextButton", {
    Size = UDim2.new(0, 40, 0, 40),
    Position = UDim2.new(1, -80, 0, 0),
    Text = "—",
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = Color3.fromRGB(180, 180, 180),
    BackgroundTransparency = 1,
    Parent = TopBar
})

local ConsoleBtn = createElement("TextButton", {
    Size = UDim2.new(0, 40, 0, 40),
    Position = UDim2.new(1, -120, 0, 0),
    Text = "⧉",
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    TextColor3 = Color3.fromRGB(120, 180, 255),
    BackgroundTransparency = 1,
    Parent = TopBar
})

--// Tab Container
local TabContainer = createElement("Frame", {
    Size = UDim2.new(0, 140, 1, -40),
    Position = UDim2.new(0, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
    BorderSizePixel = 0,
    Parent = MainFrame
})

createElement("UICorner", { CornerRadius = UDim.new(0, 8), Parent = TabContainer })
createElement("UIPadding", { PaddingTop = UDim.new(0, 5), Parent = TabContainer })

--// Pages Container
local PagesContainer = createElement("Frame", {
    Size = UDim2.new(1, -140, 1, -40),
    Position = UDim2.new(0, 140, 0, 40),
    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = MainFrame
})

--// Custom Console
local ConsoleFrame = createElement("Frame", {
    Size = UDim2.new(1, -140, 1, -40),
    Position = UDim2.new(0, 140, 1, 0),
    BackgroundColor3 = Color3.fromRGB(15, 15, 15),
    BorderSizePixel = 0,
    Visible = false,
    Parent = MainFrame
})

createElement("UICorner", { CornerRadius = UDim.new(0, 8), Parent = ConsoleFrame })

local ConsoleOutput = createElement("ScrollingFrame", {
    Size = UDim2.new(1, -10, 1, -50),
    Position = UDim2.new(0, 5, 0, 5),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 6,
    ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
    Parent = ConsoleFrame
})

local ConsoleLayout = createElement("UIListLayout", {
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = ConsoleOutput
})

local function addConsoleLog(message, type)
    type = type or "info"
    local colors = {
        info = Color3.fromRGB(200, 200, 200),
        success = Color3.fromRGB(46, 204, 113),
        error = Color3.fromRGB(231, 76, 60),
        warning = Color3.fromRGB(241, 196, 15)
    }
    
    local log = createElement("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = "[" .. os.date("%H:%M:%S") .. "] " .. message,
        TextColor3 = colors[type],
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = #consoleLogs,
        Parent = ConsoleOutput
    })
    
    table.insert(consoleLogs, log)
    ConsoleOutput.CanvasSize = UDim2.new(0, 0, 0, ConsoleLayout.AbsoluteContentSize.Y + 10)
end

--// Functions
local function setupHoverEffects()
    -- Toggle Button
    ToggleUIBtn.MouseEnter:Connect(function()
        TweenService:Create(ToggleUIBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
    end)
    ToggleUIBtn.MouseLeave:Connect(function()
        TweenService:Create(ToggleUIBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
    end)
    
    -- Control Buttons
    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 100, 100)}):Play()
    end)
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200, 80, 80)}):Play()
    end)
    
    MinBtn.MouseEnter:Connect(function()
        TweenService:Create(MinBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()
    end)
    MinBtn.MouseLeave:Connect(function()
        TweenService:Create(MinBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
    end)
    
    ConsoleBtn.MouseEnter:Connect(function()
        TweenService:Create(ConsoleBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 210, 255)}):Play()
    end)
    ConsoleBtn.MouseLeave:Connect(function()
        TweenService:Create(ConsoleBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(120, 180, 255)}):Play()
    end)
end

local function toggleUI()
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    end
end

local function toggleConsole()
    isConsoleOpen = not isConsoleOpen
    ConsoleFrame.Visible = isConsoleOpen
    PagesContainer.Visible = not isConsoleOpen
    
    if isConsoleOpen then
        TweenService:Create(ConsoleFrame, TweenInfo.new(0.3), {Position = UDim2.new(0, 140, 0, 40)}):Play()
    else
        TweenService:Create(ConsoleFrame, TweenInfo.new(0.3), {Position = UDim2.new(0, 140, 1, 0)}):Play()
    end
end

--// Tabs and Pages
local tabs = {"Teleport", "Tools", "Exploit", "Scripts", "Players", "Settings"}
local pagesData = {
    Teleport = {
        {"Toggle NoClip", function()
            local char = LocalPlayer.Character
            if not char then 
                createNotification("Error", "Character not found", "error")
                return 
            end
            
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = true end
                end
                createNotification("NoClip", "Disabled", "warning")
            else
                noclipConnection = RunService.Stepped:Connect(function()
                    for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end)
                createNotification("NoClip", "Enabled", "success")
            end
        end},
        {"Teleport Tool", function()
            local tool = Instance.new("Tool")
            tool.Name = "TP Tool"
            tool.RequiresHandle = false
            tool.ToolTip = "Click to teleport"
            local mouse = LocalPlayer:GetMouse()
            tool.Activated:Connect(function()
                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root and mouse.Hit then
                    root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 5, 0))
                    createNotification("Teleported", "To mouse position", "info")
                end
            end)
            tool.Parent = LocalPlayer.Backpack
            createNotification("Tool Created", "TP Tool added to backpack", "success")
        end},
        {"Copy My Position", function()
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                savedCFrame = root.CFrame
                createNotification("Position Copied", tostring(savedCFrame.Position), "success")
                addConsoleLog("Position copied: " .. tostring(savedCFrame.Position), "info")
            end
        end},
        {"Paste Position", function()
            if savedCFrame then
                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = savedCFrame
                    createNotification("Teleported", "To saved position", "success")
                end
            else
                createNotification("Error", "No saved position", "error")
            end
        end}
    },
    Tools = {
        {"Rejoin Game", function()
            createNotification("Rejoining", "Teleporting to server...", "info")
            task.wait(1)
            TeleportService:Teleport(game.PlaceId)
        end},
        {"Infinite Yield", function()
            createNotification("Loading", "Infinite Yield...", "info")
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        end},
        {"CMD-X", function()
            createNotification("Loading", "CMD-X...", "info")
            loadstring(game:HttpGet("https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source.lua"))()
        end}
    },
    Exploit = {
        {"Fly GUI v3", function() 
            createNotification("Loading", "Fly GUI v3...", "info")
            loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))() 
        end},
        {"Dark Hub", function()
            createNotification("Loading", "Dark Hub...", "info")
            loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomAdamYT/DarkHub/master/Init", true))()
        end}
    },
    Scripts = {
        {"Load Custom Script", function() 
            local scriptInput = createElement("TextBox", {
                Size = UDim2.new(1, -20, 0, 40),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                Text = "Enter script URL or code...",
                TextColor3 = Color3.fromRGB(200, 200, 200),
                Font = Enum.Font.Gotham,
                TextSize = 12,
                Parent = pageFrames["Scripts"]
            })
            -- Implementation would need a dedicated input system
            createNotification("Info", "Use loadstring() in console", "info")
        end},
        {"Clear Console", function() 
            for _, v in pairs(consoleLogs) do v:Destroy() end
            consoleLogs = {}
            createNotification("Console", "Cleared", "warning")
        end}
    },
    Players = {
        {"Refresh Players", function()
            -- Implementation would refresh player list
            createNotification("Players", "List refreshed", "info")
        end}
        -- Player list buttons will be dynamically generated
    },
    Settings = {
        {"UI Toggle Key: `", function()
            createNotification("Settings", "Press ` or ~ to toggle UI", "info")
        end},
        {"Notification Test", function()
            createNotification("Test", "Notification system working!", "success")
        end}
    }
}

local tabButtons = {}
local pageFrames = {}
local currentPage = "Teleport"

--// Create Player List
local function updatePlayerList()
    local page = pageFrames["Players"]
    if not page then return end
    
    -- Clear existing player buttons
    for _, child in pairs(page:GetChildren() do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local index = 1
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local btn = createElement("TextButton", {
                Size = UDim2.new(1, -20, 0, 35),
                Position = UDim2.new(0, 10, 0, (index - 1) * 40),
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                BorderSizePixel = 0,
                Text = "  " .. player.Name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = page
            })
            
            createElement("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })
            
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                -- Add player actions here
                createNotification("Player Selected", player.Name, "info")
            end)
            
            index = index + 1
        end
    end
end

--// Page Creation
local function createPage(pageName)
    if pageFrames[pageName] then return end
    
    local page = createElement("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 8,
        ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
        Visible = false,
        Parent = PagesContainer
    })

    local layout = createElement("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = page
    })

    pageFrames[pageName] = page
    
    -- Add buttons for this page
    if pagesData[pageName] then
        for i, data in ipairs(pagesData[pageName]) do
            local btn = createElement("TextButton", {
                Size = UDim2.new(1, -20, 0, 40),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                BorderSizePixel = 0,
                Text = "  " .. data[1],
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = i,
                Parent = page
            })

            createElement("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })

            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
                task.wait(0.1)
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
                pcall(data[2])
            end)
        end
    end

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 15)
    end)
end

--// Tab Button Creation
local function createTabButton(tabName, index)
    local tabBtn = createElement("TextButton", {
        Size = UDim2.new(1, -10, 0, 45),
        Position = UDim2.new(0, 5, 0, (index - 1) * 50),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 0,
        Text = tabName,
        TextColor3 = Color3.fromRGB(180, 180, 180),
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        Parent = TabContainer
    })

    createElement("UICorner", { CornerRadius = UDim.new(0, 6), Parent = tabBtn })

    tabBtn.MouseButton1Click:Connect(function()
        if currentPage == tabName then return end
        
        local oldPage = pageFrames[currentPage]
        if oldPage then oldPage.Visible = false end
        
        currentPage = tabName
        
        for _, btn in pairs(tabButtons) do
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        
        tabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        createPage(tabName)
        local page = pageFrames[tabName]
        page.Visible = true
        
        if tabName == "Players" then
            updatePlayerList()
        end
    end)

    tabButtons[tabName] = tabBtn
end

--// Initialize Tabs
local function initializeTabs()
    for i, tab in ipairs(tabs) do 
        createTabButton(tab, i) 
    end
    
    createPage("Teleport")
    tabButtons["Teleport"].BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    tabButtons["Teleport"].TextColor3 = Color3.fromRGB(255, 255, 255)
    pageFrames["Teleport"].Visible = true
end

--// Dragging System
local function setupDragging()
    local dragging, dragStart, startPos
    
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

--// Window Controls
local function setupWindowControls()
    local minimized = false
    
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        PagesContainer.Visible = not minimized
        TabContainer.Visible = not minimized
        
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                           {Size = UDim2.new(0, 600, 0, minimized and 40 or 450)}):Play()
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        task.wait(0.3)
        ScreenGui:Destroy()
    end)
    
    ConsoleBtn.MouseButton1Click:Connect(function()
        toggleConsole()
    end)
end

--// Keybind
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Backquote then
        toggleUI()
    end
end)

--// Initialize
setupHoverEffects()
initializeTabs()
setupDragging()
setupWindowControls()
ToggleUIBtn.MouseButton1Click:Connect(toggleUI)

--// Welcome Notification
task.wait(1)
createNotification("Welcome", "Advanced UI Loaded! Press ` to toggle", "success", 4)
addConsoleLog("UI initialized successfully", "success")
