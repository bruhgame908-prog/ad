--// Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--// Helpers
local function createElement(className, properties)
    local element = Instance.new(className)
    for property, value in pairs(properties) do
        if property == "Parent" then
            element.Parent = value
        else
            element[property] = value
        end
    end
    return element
end

--// UI Creation
local ScreenGui = createElement("ScreenGui", {
    Name = "AdvancedToolUI",
    Parent = game:GetService("CoreGui"),
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

--// Main Frame
local MainFrame = createElement("Frame", {
    Size = UDim2.new(0, 550, 0, 400),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
    BorderSizePixel = 0,
    Active = true,
    Parent = ScreenGui
})

createElement("UICorner", {
    CornerRadius = UDim.new(0, 8),
    Parent = MainFrame
})

--// Top Bar
local TopBar = createElement("Frame", {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),
    BorderSizePixel = 0,
    Parent = MainFrame
})

createElement("UICorner", {
    CornerRadius = UDim.new(0, 8),
    Parent = TopBar
})

--// Title
local Title = createElement("TextLabel", {
    Text = "🛠️ Advanced Tool UI",
    Size = UDim2.new(1, -90, 1, 0),
    Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TopBar
})

--// Close Button
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

--// Minimize Button
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

--// Tab Container
local TabContainer = createElement("Frame", {
    Size = UDim2.new(0, 130, 1, -40),
    Position = UDim2.new(0, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
    BorderSizePixel = 0,
    Parent = MainFrame
})

createElement("UICorner", {
    CornerRadius = UDim.new(0, 8),
    Parent = TabContainer
})

--// Pages Container
local PagesContainer = createElement("Frame", {
    Size = UDim2.new(1, -130, 1, -40),
    Position = UDim2.new(0, 130, 0, 40),
    BackgroundColor3 = Color3.fromRGB(20, 20, 20),
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = MainFrame
})

--// Functions
local function setupHoverEffects()
    -- Close Button Hover Effects
    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 100, 100)}):Play()
    end)
    
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200, 80, 80)}):Play()
    end)
    
    -- Minimize Button Hover Effects
    MinBtn.MouseEnter:Connect(function()
        TweenService:Create(MinBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(220, 220, 220)}):Play()
    end)
    
    MinBtn.MouseLeave:Connect(function()
        TweenService:Create(MinBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
    end)
end

--// Tabs & Pages Data
local tabs = {"Teleport", "Tools", "Exploit", "Scripts"}
local pagesData = {
    Teleport = {
        {"NoClip", function()
            local char = LocalPlayer.Character
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then 
                        v.CanCollide = false 
                    end
                end
            end
        end},
        {"Teleport Tool", function()
            local tool = Instance.new("Tool")
            tool.Name = "TP Tool"
            tool.RequiresHandle = false
            tool.Activated:Connect(function()
                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = CFrame.new(LocalPlayer:GetMouse().Hit.Position + Vector3.new(0, 5, 0))
                end
            end)
            tool.Parent = LocalPlayer.Backpack
        end}
    },
    Tools = {
        {"Infinite Yield", function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source "))()
        end}
    },
    Exploit = {
        {"Fly GUI", function() 
            loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt "))() 
        end}
    },
    Scripts = {
        {"Load Custom Script", function() 
            loadstring("print('Loaded!')")() 
        end},
        {"Clear Console", function() 
            if rconsoleclear then 
                rconsoleclear() 
            end 
        end}
    }
}

--// Page Management
local tabButtons = {}
local pageFrames = {}
local currentPage = "Teleport"

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
    local buttons = pagesData[pageName] or {}

    for i, data in ipairs(buttons) do
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

        createElement("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = btn
        })

        -- Button hover effects
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 55)}):Play()
        end)
        
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
        end)
        
        btn.MouseButton1Click:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
            wait(0.1)
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
            pcall(data[2])
        end)
    end)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 15)
    end)
end

local function createTabButton(tabName, index)
    local tabBtn = createElement("TextButton", {
        Size = UDim2.new(1, -10, 0, 45),
        Position = UDim2.new(0, 5, 0, 5 + (index - 1) * 50),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 0,
        Text = tabName,
        TextColor3 = Color3.fromRGB(180, 180, 180),
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        Parent = TabContainer
    })

    createElement("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = tabBtn
    })

    tabBtn.MouseButton1Click:Connect(function()
        if currentPage == tabName then return end
        
        local oldPage = pageFrames[currentPage]
        if oldPage then 
            oldPage.Visible = false 
        end
        
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
    end)

    tabButtons[tabName] = tabBtn
end

local function initializeTabs()
    for i, tab in ipairs(tabs) do 
        createTabButton(tab, i) 
    end
    
    createPage("Teleport")
    tabButtons["Teleport"].BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    tabButtons["Teleport"].TextColor3 = Color3.fromRGB(255, 255, 255)
    pageFrames["Teleport"].Visible = true
end

--// Connections
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

local function setupWindowControls()
    local minimized = false
    
    -- Minimize/Maximize
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(PagesContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                               {Size = UDim2.new(0, 0, 1, -40)}):Play()
        else
            TweenService:Create(PagesContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
                               {Size = UDim2.new(1, -130, 1, -40)}):Play()
        end
    end)
    
    -- Close
    CloseBtn.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        wait(0.3)
        ScreenGui:Destroy()
    end)
end

--// Initialize
setupHoverEffects()
initializeTabs()
setupDragging()
setupWindowControls()
