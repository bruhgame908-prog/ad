--[[
    ADVANCED TOOL UI v3.2 - "วิศวกรตัวจริง แก้บัคครบทุกจุด + เพิ่มฟีเจอร์ใหม่"
    Optimized & Enhanced Version
    วันที่: 16 พฤศจิกายน 2568
--]]

--// ===================================================================
--// 1. SERVICES & INITIALIZATION
--// ===================================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

--// ===================================================================
--// 2. CONFIGURATION
--// ===================================================================

local CONFIG = {
    UI = {
        Size = UDim2.new(0, 560, 0, 420),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor = Color3.fromRGB(18, 18, 18),
        CornerRadius = 10,
        Shadow = true,
    },
    TopBar = {
        Height = 44,
        BackgroundColor = Color3.fromRGB(28, 28, 28),
    },
    Tab = {
        Width = 140,
        ButtonHeight = 48,
        Spacing = 6,
        BackgroundColor = Color3.fromRGB(32, 32, 32),
        SelectedColor = Color3.fromRGB(45, 45, 45),
    },
    ToggleButton = {
        Size = UDim2.new(0, 52, 0, 52),
        Position = UDim2.new(0, 22, 0.5, -26),
        IconOpen = "⚡",
        IconClosed = "▶",
        AutoSavePosition = true,
    },
    Anim = {
        Duration = 0.28,
        Hover = 0.18,
        Click = 0.08,
    },
    Keybind = Enum.KeyCode.F9,
    AutoSave = true,
    SaveFile = "AdvancedToolUI_Save.json"
}

--// ===================================================================
--// 3. UTILITY FUNCTIONS
--// ===================================================================

local Utilities = {
    SafeCall = function(callback, errorMessage)
        local success, result = pcall(callback)
        if not success then
            warn("[AdvancedToolUI Error] " .. (errorMessage or "Unknown error") .. ": " .. tostring(result))
            return false
        end
        return true, result
    end,
    
    CreateSignal = function()
        local connections = {}
        local signal = {}
        
        function signal:Connect(callback)
            local connection = {Connected = true, Disconnect = function() connection.Connected = false end}
            table.insert(connections, connection)
            return connection
        end
        
        function signal:Fire(...)
            for _, connection in ipairs(connections) do
                if connection.Connected then
                    Utilities.SafeCall(function() 
                        -- Callback would go here in actual implementation
                    end)
                end
            end
        end
        
        return signal
    end,
    
    Debounce = function(delay)
        local lastCall = 0
        return function()
            local now = tick()
            if now - lastCall >= delay then
                lastCall = now
                return true
            end
            return false
        end
    end
}

--// ===================================================================
--// 4. UI BUILDER (Enhanced)
--// ===================================================================

local UIBuilder = {}
UIBuilder.__index = UIBuilder

function UIBuilder.new(parent)
    local self = setmetatable({}, UIBuilder)
    self.Parent = parent
    self.Instances = {}
    return self
end

function UIBuilder:Create(className, properties)
    return Utilities.SafeCall(function()
        local instance = Instance.new(className)
        
        for property, value in pairs(properties) do
            if property ~= "Parent" and property ~= "Children" then
                instance[property] = value
            end
        end
        
        if properties.Parent then
            instance.Parent = properties.Parent
        elseif self.Parent then
            instance.Parent = self.Parent
        end
        
        -- Handle child elements
        if properties.Children and type(properties.Children) == "table" then
            for _, childProperties in ipairs(properties.Children) do
                if type(childProperties) == "table" then
                    self:Create(childProperties.ClassName or "Frame", childProperties)
                end
            end
        end
        
        table.insert(self.Instances, instance)
        return instance
    end, "Failed to create " .. className)
end

function UIBuilder:Corner(radius, parent)
    local target = parent or self.Parent
    return self:Create("UICorner", {
        CornerRadius = UDim.new(0, radius),
        Parent = target
    })
end

function UIBuilder:Stroke(thickness, color, parent)
    local target = parent or self.Parent
    return self:Create("UIStroke", {
        Thickness = thickness,
        Color = color,
        Parent = target
    })
end

function UIBuilder:Shadow(parent)
    local target = parent or self.Parent
    return self:Create("ImageLabel", {
        Size = UDim2.new(1, 20, 1, 20),
        Position = UDim2.new(0, -10, 0, -10),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 451, 451),
        ZIndex = -1,
        Parent = target
    })
end

function UIBuilder:Destroy()
    for _, instance in ipairs(self.Instances) do
        Utilities.SafeCall(function()
            instance:Destroy()
        end, "Failed to destroy instance")
    end
    self.Instances = {}
end

--// ===================================================================
--// 5. ANIMATION MANAGER
--// ===================================================================

local AnimationManager = {
    Tweens = {},
    ActiveAnimations = 0
}

function AnimationManager:CreateTween(target, properties, duration, easingStyle, easingDirection)
    return Utilities.SafeCall(function()
        local tweenInfo = TweenInfo.new(
            duration or CONFIG.Anim.Duration,
            easingStyle or Enum.EasingStyle.Quint,
            easingDirection or Enum.EasingDirection.Out
        )
        
        local tween = TweenService:Create(target, tweenInfo, properties)
        self.Tweens[tween] = true
        self.ActiveAnimations += 1
        
        local connection
        connection = tween.Completed:Connect(function()
            self.Tweens[tween] = nil
            self.ActiveAnimations -= 1
            connection:Disconnect()
        end)
        
        return tween
    end, "Failed to create tween")
end

function AnimationManager:PlayTween(target, properties, duration, easingStyle, easingDirection)
    local tween = self:CreateTween(target, properties, duration, easingStyle, easingDirection)
    if tween then
        tween:Play()
    end
    return tween
end

function AnimationManager:CancelAll()
    for tween in pairs(self.Tweens) do
        Utilities.SafeCall(function()
            tween:Cancel()
        end, "Failed to cancel tween")
    end
    self.Tweens = {}
    self.ActiveAnimations = 0
end

--// ===================================================================
--// 6. DRAG CONTROLLER
--// ===================================================================

local DragController = {}
DragController.__index = DragController

function DragController.new(frame, dragHandle)
    if not frame then return end
    
    local self = setmetatable({}, DragController)
    self.Frame = frame
    self.DragHandle = dragHandle or frame
    self.IsDragging = false
    self.DragStart = nil
    self.StartPosition = nil
    self.Connections = {}
    
    self:Initialize()
    return self
end

function DragController:Initialize()
    -- Mouse/Input events
    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.IsDragging = true
            self.DragStart = input.Position
            self.StartPosition = self.Frame.Position
            
            -- Bring to front
            local gui = self.Frame:FindFirstAncestorOfClass("ScreenGui")
            if gui then
                gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            end
        end
    end
    
    local function onInputChanged(input)
        if self.IsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - self.DragStart
            self.Frame.Position = UDim2.new(
                self.StartPosition.X.Scale,
                self.StartPosition.X.Offset + delta.X,
                self.StartPosition.Y.Scale, 
                self.StartPosition.Y.Offset + delta.Y
            )
        end
    end
    
    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.IsDragging = false
        end
    end
    
    -- Connect events
    table.insert(self.Connections, self.DragHandle.InputBegan:Connect(onInputBegan))
    table.insert(self.Connections, UserInputService.InputChanged:Connect(onInputChanged))
    table.insert(self.Connections, UserInputService.InputEnded:Connect(onInputEnded))
end

function DragController:Destroy()
    for _, connection in ipairs(self.Connections) do
        connection:Disconnect()
    end
    self.Connections = {}
end

--// ===================================================================
--// 7. DATA MANAGER
--// ===================================================================

local DataManager = {
    AutoSave = CONFIG.AutoSave,
    SaveFile = CONFIG.SaveFile
}

function DataManager:Save(data)
    if not self.AutoSave then return true end
    
    return Utilities.SafeCall(function()
        local encoded = HttpService:JSONEncode(data)
        
        -- Create backup if file exists
        if pcall(function() readfile(self.SaveFile) end) then
            local backupFile = self.SaveFile:gsub(".json", "_backup.json")
            writefile(backupFile, readfile(self.SaveFile))
        end
        
        writefile(self.SaveFile, encoded)
        return true
    end, "Failed to save data")
end

function DataManager:Load()
    if not self.AutoSave then return {} end
    
    return Utilities.SafeCall(function()
        if not pcall(function() readfile(self.SaveFile) end) then
            return {}
        end
        
        local fileData = readfile(self.SaveFile)
        if fileData and #fileData > 0 then
            return HttpService:JSONDecode(fileData)
        end
        return {}
    end, "Failed to load data") or {}
end

--// ===================================================================
--// 8. TOGGLE MANAGER
--// ===================================================================

local ToggleManager = {}
ToggleManager.__index = ToggleManager

function ToggleManager.new(mainFrame, toggleButton, tabFrame, contentFrame)
    if not mainFrame or not toggleButton then return end
    
    local self = setmetatable({}, ToggleManager)
    self.MainFrame = mainFrame
    self.ToggleButton = toggleButton
    self.TabFrame = tabFrame
    self.ContentFrame = contentFrame
    self.IsVisible = true
    self.IsAnimating = false
    self.DataManager = DataManager
    
    self:Initialize()
    return self
end

function ToggleManager:Initialize()
    -- Toggle on button click
    self.ToggleButton.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Toggle on keybind
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == CONFIG.Keybind then
            self:Toggle()
        end
    end)
    
    -- Load saved position
    if CONFIG.ToggleButton.AutoSavePosition then
        local savedData = self.DataManager:Load()
        if savedData and savedData.TogglePosition then
            self.ToggleButton.Position = UDim2.new(0, savedData.TogglePosition.X, 0, savedData.TogglePosition.Y)
        end
    end
    
    -- Make draggable
    DragController.new(self.ToggleButton)
end

function ToggleManager:Toggle()
    if self.IsAnimating then return end
    self.IsAnimating = true
    
    local shouldHide = self.IsVisible
    
    -- Animate main UI
    local mainTween = AnimationManager:PlayTween(self.MainFrame, {
        BackgroundTransparency = shouldHide and 1 or 0
    })
    
    -- Animate children
    for _, child in ipairs(self.MainFrame:GetDescendants()) do
        if child:IsA("GuiObject") then
            local properties = {BackgroundTransparency = shouldHide and 1 or 0}
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                properties.TextTransparency = shouldHide and 1 or 0
            end
            AnimationManager:PlayTween(child, properties)
        end
    end
    
    -- Animate toggle button
    AnimationManager:PlayTween(self.ToggleButton, {
        BackgroundColor3 = shouldHide and Color3.fromRGB(55, 55, 55) or Color3.fromRGB(30, 30, 30),
        Text = shouldHide and CONFIG.ToggleButton.IconClosed or CONFIG.ToggleButton.IconOpen
    })
    
    -- Handle layout animations
    if shouldHide then
        AnimationManager:PlayTween(self.TabFrame, {Size = UDim2.new(0, 0, 1, -44)})
        AnimationManager:PlayTween(self.ContentFrame, {Size = UDim2.new(0, 0, 1, -44)})
    else
        self.MainFrame.Visible = true
    end
    
    -- Completion handler
    if mainTween then
        mainTween.Completed:Connect(function()
            self.MainFrame.Visible = not shouldHide
            self.IsVisible = not shouldHide
            self.IsAnimating = false
            
            if not shouldHide then
                AnimationManager:PlayTween(self.TabFrame, {Size = UDim2.new(0, 140, 1, -44)})
                AnimationManager:PlayTween(self.ContentFrame, {Size = UDim2.new(1, -140, 1, -44)})
            end
            
            -- Save position
            if CONFIG.ToggleButton.AutoSavePosition then
                self.DataManager:Save({
                    TogglePosition = {
                        X = self.ToggleButton.Position.X.Offset,
                        Y = self.ToggleButton.Position.Y.Offset
                    }
                })
            end
        end)
    else
        self.IsAnimating = false
    end
end

--// ===================================================================
--// 9. TAB SYSTEM (Enhanced)
--// ===================================================================

local TabSystem = {}
TabSystem.__index = TabSystem

function TabSystem.new(tabContainer, contentContainer, tabData)
    if not tabContainer or not contentContainer then return end
    
    local self = setmetatable({}, TabSystem)
    self.TabContainer = tabContainer
    self.ContentContainer = contentContainer
    self.TabData = tabData or {}
    self.Buttons = {}
    self.Pages = {}
    self.CurrentTab = nil
    self.Builder = UIBuilder.new(tabContainer)
    
    return self
end

function TabSystem:CreateTab(tabName, index)
    if not tabName or self.Buttons[tabName] then return end
    
    local button = self.Builder:Create("TextButton", {
        Size = UDim2.new(1, -12, 0, CONFIG.Tab.ButtonHeight),
        Position = UDim2.new(0, 6, 0, 6 + (index - 1) * (CONFIG.Tab.ButtonHeight + CONFIG.Tab.Spacing)),
        BackgroundColor3 = CONFIG.Tab.BackgroundColor,
        Text = tabName,
        TextColor3 = Color3.fromRGB(190, 190, 190),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        AutoButtonColor = false,
        Parent = self.TabContainer
    })
    
    if not button then return end
    
    self.Builder:Corner(8, button)
    self.Buttons[tabName] = button
    
    -- Add interactivity
    button.MouseEnter:Connect(function()
        if self.CurrentTab ~= tabName then
            AnimationManager:PlayTween(button, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
        end
    end)
    
    button.MouseLeave:Connect(function()
        if self.CurrentTab ~= tabName then
            AnimationManager:PlayTween(button, {BackgroundColor3 = CONFIG.Tab.BackgroundColor})
        end
    end)
    
    button.MouseButton1Down:Connect(function()
        AnimationManager:PlayTween(button, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}, 0.1)
    end)
    
    button.MouseButton1Click:Connect(function()
        self:SwitchToTab(tabName)
    end)
end

function TabSystem:CreatePage(tabName)
    if self.Pages[tabName] or not self.TabData[tabName] then return end
    
    local page = self.Builder:Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = Color3.fromRGB(90, 90, 90),
        ScrollBarImageTransparency = 0.5,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        Parent = self.ContentContainer
    })
    
    if not page then return end
    
    local layout = self.Builder:Create("UIListLayout", {
        Padding = UDim.new(0, 9),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = page
    })
    
    self.Builder:Create("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = page
    })
    
    -- Create page buttons
    for i, buttonInfo in ipairs(self.TabData[tabName]) do
        local buttonText, buttonCallback = buttonInfo[1], buttonInfo[2]
        if type(buttonText) == "string" and type(buttonCallback) == "function" then
            local button = self.Builder:Create("TextButton", {
                Size = UDim2.new(1, -22, 0, 42),
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                Text = "  " .. buttonText,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                LayoutOrder = i,
                Parent = page
            })
            
            if button then
                self.Builder:Corner(7, button)
                
                -- Button interactivity
                button.MouseEnter:Connect(function()
                    AnimationManager:PlayTween(button, {BackgroundColor3 = Color3.fromRGB(55, 55, 55)})
                end)
                
                button.MouseLeave:Connect(function()
                    AnimationManager:PlayTween(button, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
                end)
                
                button.MouseButton1Down:Connect(function()
                    AnimationManager:PlayTween(button, {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}, 0.1)
                end)
                
                button.MouseButton1Click:Connect(function()
                    Utilities.SafeCall(buttonCallback, "Button action failed: " .. buttonText)
                end)
            end
        end
    end
    
    -- Auto-size canvas
    if layout then
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 24)
        end)
    end
    
    self.Pages[tabName] = page
end

function TabSystem:SwitchToTab(tabName)
    if self.CurrentTab == tabName or not self.Pages[tabName] then return end
    
    -- Hide current tab
    if self.CurrentTab and self.Pages[self.CurrentTab] then
        self.Pages[self.CurrentTab].Visible = false
    end
    
    -- Update button states
    for name, button in pairs(self.Buttons) do
        if button then
            button.BackgroundColor3 = CONFIG.Tab.BackgroundColor
            button.TextColor3 = Color3.fromRGB(190, 190, 190)
        end
    end
    
    -- Activate selected tab
    local selectedButton = self.Buttons[tabName]
    if selectedButton then
        selectedButton.BackgroundColor3 = CONFIG.Tab.SelectedColor
        selectedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    
    -- Show new tab
    self:CreatePage(tabName)
    self.Pages[tabName].Visible = true
    self.CurrentTab = tabName
end

function TabSystem:Initialize(tabNames)
    if not tabNames then return end
    
    for i, name in ipairs(tabNames) do
        self:CreateTab(name, i)
    end
    
    if #tabNames > 0 then
        self:SwitchToTab(tabNames[1])
    end
end

--// ===================================================================
--// 10. FEATURE IMPLEMENTATIONS
--// ===================================================================

local Features = {
    NoClip = {
        Enabled = false,
        Connection = nil,
        
        Toggle = function()
            Features.NoClip.Enabled = not Features.NoClip.Enabled
            
            if Features.NoClip.Enabled then
                Features.NoClip:Enable()
            else
                Features.NoClip:Disable()
            end
        end,
        
        Enable = function(self)
            local character = LocalPlayer.Character
            if not character then return end
            
            -- Disable collision for all parts
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            
            -- Monitor for new parts
            self.Connection = character.DescendantAdded:Connect(function(descendant)
                if descendant:IsA("BasePart") then
                    descendant.CanCollide = false
                end
            end)
            
            print("NoClip: Enabled")
        end,
        
        Disable = function(self)
            local character = LocalPlayer.Character
            if not character then return end
            
            -- Re-enable collision
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
            
            if self.Connection then
                self.Connection:Disconnect()
                self.Connection = nil
            end
            
            print("NoClip: Disabled")
        end
    },
    
    TPTool = {
        Create = function()
            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
            if not backpack then return end
            
            -- Remove existing tool
            local existingTool = backpack:FindFirstChild("TP Tool")
            if existingTool then
                existingTool:Destroy()
            end
            
            local tool = Instance.new("Tool")
            tool.Name = "TP Tool"
            tool.RequiresHandle = false
            
            tool.Activated:Connect(function()
                local character = LocalPlayer.Character
                local mouse = LocalPlayer:GetMouse()
                
                if character and mouse then
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    if humanoidRootPart then
                        humanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 5, 0))
                    end
                end
            end)
            
            tool.Parent = backpack
            print("TP Tool: Created in backpack")
        end
    },
    
    SpeedHack = function(speed)
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = speed or 100
                print("WalkSpeed set to: " .. (speed or 100))
            end
        end
    end,
    
    JumpHack = function(power)
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = power or 100
                print("JumpPower set to: " .. (power or 100))
            end
        end
    end,
    
    AntiAFK = {
        Enabled = false,
        Connection = nil,
        
        Toggle = function()
            Features.AntiAFK.Enabled = not Features.AntiAFK.Enabled
            
            if Features.AntiAFK.Enabled then
                Features.AntiAFK:Enable()
            else
                Features.AntiAFK:Disable()
            end
        end,
        
        Enable = function(self)
            local virtualUser = game:GetService("VirtualUser")
            self.Connection = game:GetService("Players").LocalPlayer.Idled:Connect(function()
                virtualUser:CaptureController()
                virtualUser:ClickButton2(Vector2.new())
            end)
            print("Anti-AFK: Enabled")
        end,
        
        Disable = function(self)
            if self.Connection then
                self.Connection:Disconnect()
                self.Connection = nil
            end
            print("Anti-AFK: Disabled")
        end
    }
}

--// ===================================================================
--// 11. MAIN UI INITIALIZATION
--// ===================================================================

local function InitializeAdvancedUI()
    -- Create main GUI
    local mainGUI = UIBuilder.new(CoreGui):Create("ScreenGui", {
        Name = "AdvancedToolUI_v3",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    if not mainGUI then
        warn("Failed to create main GUI")
        return
    end

    -- Main container
    local mainFrame = UIBuilder.new(mainGUI):Create("Frame", {
        Size = CONFIG.UI.Size,
        Position = CONFIG.UI.Position,
        AnchorPoint = CONFIG.UI.AnchorPoint,
        BackgroundColor3 = CONFIG.UI.BackgroundColor,
        BorderSizePixel = 0,
        Active = true,
        Visible = true
    })
    
    if not mainFrame then return end

    UIBuilder.new(mainFrame):Corner(CONFIG.UI.CornerRadius)
    if CONFIG.UI.Shadow then
        UIBuilder.new(mainFrame):Shadow()
    end

    -- Top navigation bar
    local topBar = UIBuilder.new(mainFrame):Create("Frame", {
        Size = UDim2.new(1, 0, 0, CONFIG.TopBar.Height),
        BackgroundColor3 = CONFIG.TopBar.BackgroundColor,
        BorderSizePixel = 0
    })
    
    UIBuilder.new(topBar):Corner(CONFIG.UI.CornerRadius, topBar)

    -- Title
    UIBuilder.new(topBar):Create("TextLabel", {
        Text = "⚡ Advanced Tool UI v3.2",
        Size = UDim2.new(1, -140, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 17,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Control buttons
    local closeButton = UIBuilder.new(topBar):Create("TextButton", {
        Size = UDim2.new(0, 44, 0, 44),
        Position = UDim2.new(1, -44, 0, 0),
        Text = "✕",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = Color3.fromRGB(220, 80, 80),
        BackgroundTransparency = 1,
        AutoButtonColor = false
    })

    local minimizeButton = UIBuilder.new(topBar):Create("TextButton", {
        Size = UDim2.new(0, 44, 0, 44),
        Position = UDim2.new(1, -88, 0, 0),
        Text = "−",
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        TextColor3 = Color3.fromRGB(180, 180, 180),
        BackgroundTransparency = 1,
        AutoButtonColor = false
    })

    local consoleButton = UIBuilder.new(topBar):Create("TextButton", {
        Size = UDim2.new(0, 44, 0, 44),
        Position = UDim2.new(1, -132, 0, 0),
        Text = "📝",
        Font = Enum.Font.GothamBold,
        TextSize = 17,
        TextColor3 = Color3.fromRGB(180, 180, 180),
        BackgroundTransparency = 1,
        AutoButtonColor = false
    })

    -- Tab navigation
    local tabContainer = UIBuilder.new(mainFrame):Create("Frame", {
        Size = UDim2.new(0, 140, 1, -44),
        Position = UDim2.new(0, 0, 0, 44),
        BackgroundColor3 = Color3.fromRGB(23, 23, 23),
        BorderSizePixel = 0
    })

    -- Content area
    local contentContainer = UIBuilder.new(mainFrame):Create("Frame", {
        Size = UDim2.new(1, -140, 1, -44),
        Position = UDim2.new(0, 140, 0, 44),
        BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        BorderSizePixel = 0,
        ClipsDescendants = true
    })

    -- Define tab structure
    local tabStructure = {
        Teleport = {
            {"NoClip (Toggle)", Features.NoClip.Toggle},
            {"TP Tool", Features.TPTool.Create},
            {"Speed Hack (100)", function() Features.SpeedHack(100) end},
            {"Jump Hack (100)", function() Features.JumpHack(100) end}
        },
        Tools = {
            {"Infinite Yield", function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
            end},
            {"Dex Explorer", function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/UI-Libraries/main/Dex/Dex"))()
            end},
            {"Simple Spy", function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua"))()
            end}
        },
        Player = {
            {"Reset Character", function()
                local character = LocalPlayer.Character
                if character then
                    character:BreakJoints()
                end
            end},
            {"Fly GUI", function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
            end},
            {"Anti-AFK (Toggle)", Features.AntiAFK.Toggle}
        },
        Server = {
            {"Rejoin Server", function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end},
            {"Server Hop", function()
                -- Placeholder for server hop functionality
                print("Server Hop: Feature in development")
            end},
            {"Copy Game ID", function()
                if setclipboard then
                    setclipboard(tostring(game.PlaceId))
                    print("Game ID copied to clipboard: " .. game.PlaceId)
                end
            end}
        }
    }

    -- Initialize tab system
    local tabSystem = TabSystem.new(tabContainer, contentContainer, tabStructure)
    tabSystem:Initialize({"Teleport", "Tools", "Player", "Server"})

    -- Make window draggable
    DragController.new(mainFrame, topBar)

    -- Create toggle UI
    local toggleGUI = UIBuilder.new(CoreGui):Create("ScreenGui", {
        Name = "ToggleUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    local toggleButton = UIBuilder.new(toggleGUI):Create("TextButton", {
        Size = CONFIG.ToggleButton.Size,
        Position = CONFIG.ToggleButton.Position,
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        Text = CONFIG.ToggleButton.IconOpen,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        AutoButtonColor = false
    })
    
    if toggleButton then
        UIBuilder.new(toggleButton):Corner(10)
        UIBuilder.new(toggleButton):Stroke(2.5, Color3.fromRGB(80, 80, 80))
        
        -- Initialize toggle system
        local toggleSystem = ToggleManager.new(mainFrame, toggleButton, tabContainer, contentContainer)
        
        -- Control button functionality
        closeButton.MouseButton1Click:Connect(function()
            local closeTween = AnimationManager:PlayTween(mainFrame, {BackgroundTransparency = 1})
            if closeTween then
                closeTween.Completed:Connect(function()
                    mainGUI:Destroy()
                    toggleGUI:Destroy()
                    AnimationManager:CancelAll()
                end)
            else
                mainGUI:Destroy()
                toggleGUI:Destroy()
                AnimationManager:CancelAll()
            end
        end)

        local isMinimized = false
        minimizeButton.MouseButton1Click:Connect(function()
            isMinimized = not isMinimized
            local targetSize = isMinimized and UDim2.new(0, 0, 1, -44) or UDim2.new(0, 140, 1, -44)
            AnimationManager:PlayTween(tabContainer, {Size = targetSize})
            AnimationManager:PlayTween(contentContainer, {
                Size = isMinimized and targetSize or UDim2.new(1, -140, 1, -44)
            })
        end)

        consoleButton.MouseButton1Click:Connect(function()
            -- Console functionality
            print("⚡ Advanced Tool UI v3.2 - Debug Console")
            print("Game: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)
            print("Player: " .. LocalPlayer.Name)
            print("Place ID: " .. game.PlaceId)
            print("FPS: " .. tostring(1/RunService.RenderStepped:Wait()))
        end)

        -- Control button hover effects
        local controlButtons = {
            {closeButton, Color3.fromRGB(255, 100, 100), Color3.fromRGB(220, 80, 80)},
            {minimizeButton, Color3.fromRGB(220, 220, 220), Color3.fromRGB(180, 180, 180)},
            {consoleButton, Color3.fromRGB(100, 180, 255), Color3.fromRGB(180, 180, 180)}
        }
        
        for _, buttonConfig in ipairs(controlButtons) do
            local button, hoverColor, normalColor = buttonConfig[1], buttonConfig[2], buttonConfig[3]
            if button then
                button.MouseEnter:Connect(function()
                    AnimationManager:PlayTween(button, {TextColor3 = hoverColor})
                end)
                
                button.MouseLeave:Connect(function()
                    AnimationManager:PlayTween(button, {TextColor3 = normalColor})
                end)
            end
        end

        print("⚡ Advanced Tool UI v3.2 loaded successfully!")
        print("Press F9 or click the ⚡ button to toggle UI")
        print("Toggle button position is automatically saved")
    end
end

--// ===================================================================
--// 12. STARTUP SEQUENCE
--// ===================================================================

-- Wait for player to be ready
if LocalPlayer.Character then
    InitializeAdvancedUI()
else
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(2) -- Wait for character to fully load
        InitializeAdvancedUI()
    end)
end

-- Fallback initialization
task.delay(5, function()
    if not CoreGui:FindFirstChild("AdvancedToolUI_v3") then
        InitializeAdvancedUI()
    end
end)

return "Advanced Tool UI v3.2 - Optimized & Ready"
