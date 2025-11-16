--// Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

--// Storage (Fixed: Added connections table for cleanup)
local savedCFrame = nil
local savedPositions = {}
local noclipConnection = nil
local consoleLogs = {}
local isConsoleOpen = false
local connections = {} -- Store all connections to prevent memory leaks

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

--// Notification System (Fixed: No duplicate UI creation)
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
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
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
    
    TweenService:Create(main, TweenInfo.new(0.3), {Position = UDim2.new(1, -310, 1, -90)}):Play()
    
    task.delay(duration, function()
        if not notif or not notif.Parent then return end
        TweenService:Create(main, TweenInfo.new(0.3), {Position = UDim2.new(1, 10, 1, -90)}):Play()
        task.wait(0.3)
        pcall(function() notif:Destroy() end)
    end)
end

--// Main UI Creation
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
    Size = UDim2.new(0, 850, 0, 450),
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
    Text = "🛠️ Advanced Tool UI v2.0 (Bug Fixed)",
    Size = UDim2.new(1, -170, 1, 0),
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

--// Console Container (Fixed: Start hidden outside)
local ConsoleContainer = createElement("Frame", {
    Name = "ConsoleContainer",
    Size = UDim2.new(0, 250, 1, -40),
    Position = UDim2.new(1, 0, 0, 40), -- Start outside
    BackgroundColor3 = Color3.fromRGB(15, 15, 15),
    BorderSizePixel = 0,
    Visible = false,
    Parent = MainFrame
})

createElement("UICorner", { CornerRadius = UDim.new(0, 8), Parent = ConsoleContainer })

--// Console Header
local ConsoleHeader = createElement("Frame", {
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
    BorderSizePixel = 0,
    Parent = ConsoleContainer
})

createElement("UICorner", { CornerRadius = UDim.new(0, 8), Parent = ConsoleHeader })

local ConsoleTitle = createElement("TextLabel", {
    Size = UDim2.new(1, -60, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    Text = "Console Log",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = ConsoleHeader
})

--// Clear Console Button (Fixed: Added hover and click)
local ConsoleClearBtn = createElement("TextButton", {
    Size = UDim2.new(0, 25, 0, 25),
    Position = UDim2.new(1, -33, 0, 2),
    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
    BorderSizePixel = 0,
    Text = "🗑️",
    Font = Enum.Font.GothamBold,
    TextSize = 11,
    TextColor3 = Color3.fromRGB(180, 180, 180),
    Parent = ConsoleHeader
})

createElement("UICorner", { CornerRadius = UDim.new(0, 6), Parent = ConsoleClearBtn })

local clearHoverConn = ConsoleClearBtn.MouseEnter:Connect(function()
    TweenService:Create(ConsoleClearBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(55, 55, 55),
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
end)
table.insert(connections, clearHoverConn)

local clearLeaveConn = ConsoleClearBtn.MouseLeave:Connect(function()
    TweenService:Create(ConsoleClearBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        TextColor3 = Color3.fromRGB(180, 180, 180)
    }):Play()
end)
table.insert(connections, clearLeaveConn)

local clearClickConn = ConsoleClearBtn.MouseButton1Click:Connect(function()
    TweenService:Create(ConsoleClearBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
    task.wait(0.1)
    TweenService:Create(ConsoleClearBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
    clearConsoleLogs()
end)
table.insert(connections, clearClickConn)

--// Console Output
local ConsoleOutput = createElement("ScrollingFrame", {
    Name = "ConsoleOutput",
    Size = UDim2.new(1, -10, 1, -40),
    Position = UDim2.new(0, 5, 0, 35),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 6,
    ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
    Parent = ConsoleContainer
})

createElement("UIPadding", { PaddingTop = UDim.new(0, 5), Parent = ConsoleOutput })

local ConsoleLayout = createElement("UIListLayout", {
    Padding = UDim.new(0, 3),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = ConsoleOutput
})

--// NoClip Manager (Fixed: Character Respawn support)
local function toggleNoclip()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then 
        createNotification("Error", "Character not found", "error")
        addConsoleLog("Failed to toggle NoClip: Character not found", "error")
        return 
    end
    
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = true end
        end
        createNotification("NoClip", "Disabled", "warning")
        addConsoleLog("NoClip disabled", "warning")
    else
        noclipConnection = RunService.Stepped:Connect(function()
            local currentChar = LocalPlayer.Character
            if currentChar then
                for _, v in pairs(currentChar:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
        createNotification("NoClip", "Enabled", "success")
        addConsoleLog("NoClip enabled", "success")
    end
end

--// Console Log Functions (Fixed: Limit to 100 logs)
local function addConsoleLog(message, logType)
    logType = logType or "info"
    local colors = {
        info = Color3.fromRGB(200, 200, 200),
        success = Color3.fromRGB(46, 204, 113),
        error = Color3.fromRGB(231, 76, 60),
        warning = Color3.fromRGB(241, 196, 15)
    }
    
    local prefixMap = {
        info = "[INFO]",
        success = "[SUCCESS]",
        error = "[ERROR]",
        warning = "[WARN]"
    }
    
    -- จำกัดจำนวน logs
    if #consoleLogs >= 100 then
        local oldLog = table.remove(consoleLogs, 1)
        if oldLog and oldLog.Destroy then oldLog:Destroy() end
    end
    
    if not ConsoleOutput or not ConsoleOutput.Parent then return end
    
    local logLabel = createElement("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = string.format("[%s] %s %s", os.date("%H:%M:%S"), prefixMap[logType], message),
        TextColor3 = colors[logType],
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = #consoleLogs,
        Parent = ConsoleOutput
    })
    
    table.insert(consoleLogs, logLabel)
    
    if #message > 100 then
        logLabel.Text = string.sub(logLabel.Text, 1, 100) .. "..."
    end
    
    ConsoleOutput.CanvasSize = UDim2.new(0, 0, 0, ConsoleLayout.AbsoluteContentSize.Y + 10)
end

--// Clear Console (Fixed)
local function clearConsoleLogs()
    local logsToRemove = {}
    for _, v in pairs(consoleLogs) do
        table.insert(logsToRemove, v)
    end
    
    for _, v in pairs(logsToRemove) do
        if v and v.Destroy then v:Destroy() end
    end
    
    consoleLogs = {}
    ConsoleOutput.CanvasSize = UDim2.new(0, 0, 0, 0)
    addConsoleLog("Console cleared by user", "warning")
end

--// Functions
local function setupHoverEffects()
    -- Toggle Button
    local toggleEnter = ToggleUIBtn.MouseEnter:Connect(function()
        TweenService:Create(ToggleUIBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
    end)
    local toggleLeave = ToggleUIBtn.MouseLeave:Connect(function()
        TweenService:Create(ToggleUIBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
    end)
    table.insert(connections, toggleEnter)
    table.insert(connections, toggleLeave)
    
    -- Control Buttons
    local closeEnter = CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 100, 100)}):Play()
    end)
    local closeLeave = CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200, 80, 80)}):Play()
    end)
    table.insert(connections, closeEnter)
    table.insert(connections, closeLeave)
    
    local minEnter = MinBtn.MouseEnter:Connect(function()
        TweenService:Create(MinBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()
    end)
    local minLeave = MinBtn.MouseLeave:Connect(function()
        TweenService:Create(MinBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
    end)
    table.insert(connections, minEnter)
    table.insert(connections, minLeave)
    
    local consoleEnter = ConsoleBtn.MouseEnter:Connect(function()
        TweenService:Create(ConsoleBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 210, 255)}):Play()
    end)
    local consoleLeave = ConsoleBtn.MouseLeave:Connect(function()
        TweenService:Create(ConsoleBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(120, 180, 255)}):Play()
    end)
    table.insert(connections, consoleEnter)
    table.insert(connections, consoleLeave)
end

--// Toggle UI (Fixed: Check if UI exists)
local function toggleUI()
    if not MainFrame or not MainFrame.Parent then return end
    
    MainFrame.Visible = not MainFrame.Visible
    if MainFrame.Visible then
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
        addConsoleLog("UI toggled visible", "info")
    else
        addConsoleLog("UI toggled hidden", "info")
    end
end

--// Toggle Console (Fixed: Proper animation)
local function toggleConsole()
    if not ConsoleContainer or not ConsoleContainer.Parent then return end
    
    isConsoleOpen = not isConsoleOpen
    
    if isConsoleOpen then
        ConsoleContainer.Visible = true
        TweenService:Create(ConsoleContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad), 
                           {Position = UDim2.new(1, -250, 0, 40)}):Play()
        TweenService:Create(PagesContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad), 
                           {Size = UDim2.new(1, -390, 1, -40)}):Play()
        addConsoleLog("Console opened", "info")
    else
        TweenService:Create(ConsoleContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad), 
                           {Position = UDim2.new(1, 0, 0, 40)}):Play()
        TweenService:Create(PagesContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad), 
                           {Size = UDim2.new(1, -140, 1, -40)}):Play()
        
        task.wait(0.3)
        ConsoleContainer.Visible = false
        addConsoleLog("Console closed", "info")
    end
end

--// Tabs and Pages
local tabs = {"Teleport", "Tools", "Exploit", "Scripts", "Players", "Settings"}
local pagesData = {
    Teleport = {
        {"Toggle NoClip", toggleNoclip},
        {"Teleport Tool", function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then
                createNotification("Error", "Character not found", "error")
                addConsoleLog("Failed to create TP Tool: Character not found", "error")
                return
            end
            
            local tool = Instance.new("Tool")
            tool.Name = "TP Tool"
            tool.RequiresHandle = false
            tool.ToolTip = "Click to teleport"
            
            local mouse = LocalPlayer:GetMouse()
            tool.Activated:Connect(function()
                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root and mouse and mouse.Hit then
                    root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 5, 0))
                    createNotification("Teleported", "To mouse position", "info")
                    addConsoleLog("Teleported to: " .. tostring(mouse.Hit.Position), "info")
                else
                    addConsoleLog("TP Tool: Invalid mouse hit", "error")
                end
            end)
            
            tool.Parent = LocalPlayer.Backpack
            createNotification("Tool Created", "TP Tool added to backpack", "success")
            addConsoleLog("TP Tool created and added to backpack", "success")
        end},
        {"Copy My Position", function()
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then
                createNotification("Error", "Character not found", "error")
                addConsoleLog("Failed to copy position: Character not found", "error")
                return
            end
            
            local root = char:FindFirstChild("HumanoidRootPart")
            savedCFrame = root.CFrame
            local posStr = string.format("X:%.1f Y:%.1f Z:%.1f", savedCFrame.Position.X, savedCFrame.Position.Y, savedCFrame.Position.Z)
            createNotification("Position Copied", posStr, "success")
            addConsoleLog("Position copied: " .. posStr, "info")
        end},
        {"Paste Position", function()
            if not savedCFrame then
                createNotification("Error", "No saved position", "error")
                addConsoleLog("Failed to paste position: No saved CFrame", "error")
                return
            end
            
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then
                createNotification("Error", "Character not found", "error")
                addConsoleLog("Failed to paste position: Character not found", "error")
                return
            end
            
            local root = char:FindFirstChild("HumanoidRootPart")
            root.CFrame = savedCFrame
            createNotification("Teleported", "To saved position", "success")
            addConsoleLog("Teleported to saved position", "info")
        end}
    },
    Tools = {
        {"Rejoin Game", function()
            createNotification("Rejoining", "Teleporting to server...", "info")
            addConsoleLog("Rejoining game...", "info")
            task.wait(1)
            
            local success, err = pcall(function()
                TeleportService:Teleport(game.PlaceId)
            end)
            
            if not success then
                createNotification("Error", "Failed to rejoin: " .. tostring(err), "error")
                addConsoleLog("Rejoin failed: " .. tostring(err), "error")
            end
        end},
        {"Server Hop", function()
            createNotification("Server Hop", "Looking for new server...", "info")
            addConsoleLog("Server hop initiated", "info")
            task.wait(1)
            
            local success, err = pcall(function()
                TeleportService:Teleport(game.PlaceId)
            end)
            
            if not success then
                createNotification("Error", "Failed to hop: " .. tostring(err), "error")
                addConsoleLog("Server hop failed: " .. tostring(err), "error")
            end
        end},
        {"Infinite Yield", function()
            createNotification("Loading", "Infinite Yield...", "info")
            addConsoleLog("Loading Infinite Yield", "info")
            
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
            end)
            
            if success then
                createNotification("Success", "Infinite Yield loaded", "success")
                addConsoleLog("Infinite Yield loaded successfully", "success")
            else
                createNotification("Error", "Failed to load: " .. tostring(err), "error")
                addConsoleLog("Failed to load Infinite Yield: " .. tostring(err), "error")
            end
        end},
        {"CMD-X", function()
            createNotification("Loading", "CMD-X...", "info")
            addConsoleLog("Loading CMD-X", "info")
            
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source.lua"))()
            end)
            
            if success then
                createNotification("Success", "CMD-X loaded", "success")
                addConsoleLog("CMD-X loaded successfully", "success")
            else
                createNotification("Error", "Failed to load: " .. tostring(err), "error")
                addConsoleLog("Failed to load CMD-X: " .. tostring(err), "error")
            end
        end}
    },
    Exploit = {
        {"Fly GUI v3", function() 
            createNotification("Loading", "Fly GUI v3...", "info")
            addConsoleLog("Loading Fly GUI v3", "info")
            
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
            end)
            
            if success then
                createNotification("Success", "Fly GUI loaded", "success")
                addConsoleLog("Fly GUI v3 loaded successfully", "success")
            else
                createNotification("Error", "Failed to load: " .. tostring(err), "error")
                addConsoleLog("Failed to load Fly GUI v3: " .. tostring(err), "error")
            end
        end},
        {"Dark Hub", function()
            createNotification("Loading", "Dark Hub...", "info")
            addConsoleLog("Loading Dark Hub", "info")
            
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/RandomAdamYT/DarkHub/master/Init", true))()
            end)
            
            if success then
                createNotification("Success", "Dark Hub loaded", "success")
                addConsoleLog("Dark Hub loaded successfully", "success")
            else
                createNotification("Error", "Failed to load: " .. tostring(err), "error")
                addConsoleLog("Failed to load Dark Hub: " .. tostring(err), "error")
            end
        end},
        {"Full Bright", function()
            local lighting = game:GetService("Lighting")
            local success, err = pcall(function()
                lighting.Brightness = 2
                lighting.GlobalShadows = false
                lighting.Ambient = Color3.fromRGB(255, 255, 255)
            end)
            
            if success then
                createNotification("Full Bright", "Enabled", "success")
                addConsoleLog("Full Bright enabled", "success")
            else
                createNotification("Error", "Failed: " .. tostring(err), "error")
                addConsoleLog("Failed to enable Full Bright: " .. tostring(err), "error")
            end
        end}
    },
    Scripts = {
        {"Clear Console", function() 
            clearConsoleLogs()
        end},
        {"Print FPS", function()
            local fps = math.floor(1/RunService.RenderStepped:Wait())
            createNotification("FPS", tostring(fps), "info")
            addConsoleLog("Current FPS: " .. tostring(fps), "info")
        end}
    },
    Players = {
        {"Refresh Players", function()
            updatePlayerList()
            createNotification("Players", "List refreshed", "info")
            addConsoleLog("Player list refreshed", "info")
        end}
    },
    Settings = {
        {"UI Toggle Key: `", function()
            createNotification("Settings", "Press ` or ~ to toggle UI", "info")
        end},
        {"Notification Test", function()
            createNotification("Test", "Notification system working!", "success")
            addConsoleLog("Notification test sent", "success")
        end}
    }
}

local tabButtons = {}
local pageFrames = {}
local currentPage = "Teleport"

--// Create Player List (Fixed: Check TextButton)
local function updatePlayerList()
    local page = pageFrames["Players"]
    if not page then return end
    
    for _, child in pairs(page:GetChildren()) do
        if child:IsA("TextButton") then 
            child:Destroy() 
        end
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
            
            local btnEnter = btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}):Play()
            end)
            local btnLeave = btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
            end)
            local btnClick = btn.MouseButton1Click:Connect(function()
                createNotification("Player Selected", player.Name, "info")
                addConsoleLog("Selected player: " .. player.Name, "info")
            end)
            
            table.insert(connections, btnEnter)
            table.insert(connections, btnLeave)
            table.insert(connections, btnClick)
            
            index = index + 1
        end
    end
end

--// Page Creation (Fixed: Error handling)
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

            local btnEnter = btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}):Play()
            end)
            local btnLeave = btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
            end)
            local btnClick = btn.MouseButton1Click:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
                task.wait(0.1)
                TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
                
                local success, err = pcall(data[2])
                if not success then
                    createNotification("Error", "Button function failed: " .. tostring(err), "error")
                    addConsoleLog("Button error: " .. tostring(err), "error")
                end
            end)
            
            table.insert(connections, btnEnter)
            table.insert(connections, btnLeave)
            table.insert(connections, btnClick)
        end
    end

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if page and page.Parent then
            page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 15)
        end
    end)
end

--// Tab Button Creation (Fixed: Store connections)
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

    local tabConnection = tabBtn.MouseButton1Click:Connect(function()
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
        if page then page.Visible = true end
        
        if tabName == "Players" then
            updatePlayerList()
        end
    end)
    
    table.insert(connections, tabConnection)
    tabButtons[tabName] = tabBtn
end

--// Initialize Tabs (Fixed: Safety checks)
local function initializeTabs()
    for i, tab in ipairs(tabs) do 
        createTabButton(tab, i) 
    end
    
    createPage("Teleport")
    if tabButtons["Teleport"] then
        tabButtons["Teleport"].BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        tabButtons["Teleport"].TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    if pageFrames["Teleport"] then
        pageFrames["Teleport"].Visible = true
    end
end

--// Dragging System (Fixed: Store connections & safety checks)
local function setupDragging()
    local dragging, dragStart, startPos
    
    local startConn = TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    local changeConn = UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            if MainFrame and MainFrame.Parent then
                MainFrame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end
    end)
    
    local endConn = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    table.insert(connections, startConn)
    table.insert(connections, changeConn)
    table.insert(connections, endConn)
end

--// Window Controls (Fixed: Store connections)
local function setupWindowControls()
    local minimized = false
    
    local minConn = MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        PagesContainer.Visible = not minimized
        TabContainer.Visible = not minimized
        
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                           {Size = UDim2.new(0, 850, 0, minimized and 40 or 450)}):Play()
        
        addConsoleLog(minimized and "UI minimized" or "UI restored", "info")
    end)
    
    local closeConn = CloseBtn.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        task.wait(0.3)
        pcall(function() ScreenGui:Destroy() end)
    end)
    
    local consoleConn = ConsoleBtn.MouseButton1Click:Connect(function()
        toggleConsole()
    end)
    
    table.insert(connections, minConn)
    table.insert(connections, closeConn)
    table.insert(connections, consoleConn)
end

--// Keybind (Fixed: Check if UI exists)
local keybindConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Backquote then
        toggleUI()
    end
end)
table.insert(connections, keybindConn)

--// Character Respawn Handler (NEW: Fixes NoClip on respawn)
local charAddedConn = LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5) -- Wait for character to load
    
    if noclipConnection then
        -- Re-enable NoClip if it was active
        noclipConnection:Disconnect()
        noclipConnection = RunService.Stepped:Connect(function()
            for _, v in pairs(character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end)
        addConsoleLog("Character respawned - NoClip re-enabled", "info")
    else
        addConsoleLog("Character respawned", "info")
    end
    
    -- Re-setup position copy/paste
    savedCFrame = nil
end)
table.insert(connections, charAddedConn)

--// Cleanup Handler (NEW: Prevents memory leaks on destroy)
local cleanupConn = ScreenGui.Destroying:Connect(function()
    -- Disconnect all connections
    for _, conn in pairs(connections) do
        if conn and conn.Disconnect then
            pcall(function() conn:Disconnect() end)
        end
    end
    
    -- Disconnect NoClip
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    -- Clear console logs
    clearConsoleLogs()
    
    -- Reset storage
    savedCFrame = nil
    savedPositions = {}
    consoleLogs = {}
    connections = {}
end)
table.insert(connections, cleanupConn)

--// Initialize
setupHoverEffects()
initializeTabs()
setupDragging()
setupWindowControls()
ToggleUIBtn.MouseButton1Click:Connect(toggleUI)
addConsoleLog("UI initialized successfully", "success")
addConsoleLog("Console system ready", "info")
addConsoleLog("Character respawn handler connected", "info")
addConsoleLog("Cleanup handler connected", "info")

--// Welcome Notification
task.wait(1)
createNotification("Welcome", "Advanced UI Loaded! Press ` to toggle", "success", 4)
