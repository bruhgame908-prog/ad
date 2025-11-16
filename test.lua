--// ===================================================================
--// ADVANCED TOOL UI v2.0 - รุ่นที่มั่นคงและง่ายต่อการใช้งาน
--// ===================================================================

-- 1. เตรียม Services ที่จำเป็น
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser") -- เพิ่มสำหรับ Anti-AFK

-- 2. รอผู้เล่นโหลดเสร็จ
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    Players.PlayerAdded:Wait()
    LocalPlayer = Players.LocalPlayer
end

-- 3. การตั้งค่า UI
local CONFIG = {
    UI = {
        Size = UDim2.new(0, 560, 0, 420),
        Position = UDim2.fromScale(0.5, 0.5),
        BackgroundColor = Color3.fromRGB(18, 18, 18),
        CornerRadius = 10,
    },
    Keybind = Enum.KeyCode.F9,
}

--// UI BUILDER - ระบบสร้าง UI อย่างง่ายแต่ปลอดภัย
local UIBuilder = {}
UIBuilder.__index = UIBuilder

function UIBuilder.new(parent)
    local self = setmetatable({}, UIBuilder)
    self.Parent = parent
    return self
end

-- ฟังก์ชันสร้าง Instance พร้อม property
function UIBuilder:Create(className, properties)
    local success, instance = pcall(function()
        local instance = Instance.new(className)
        
        -- ตั้งค่า property ทั้งหมด
        for property, value in pairs(properties) do
            if property ~= "Parent" then
                instance[property] = value
            end
        end
        
        -- ตั้ง parent (ถ้าไม่มีใน properties)
        if properties.Parent then
            instance.Parent = properties.Parent
        elseif self.Parent then
            instance.Parent = self.Parent
        end
        
        return instance
    end)
    
    if success then
        return instance
    else
        warn("Failed to create " .. className .. ": " .. tostring(instance))
        return nil
    end
end

-- ฟังก์ชันสำหรับสร้าง UICorner ง่ายๆ
function UIBuilder:Corner(radius, target)
    local corner = self:Create("UICorner", {
        CornerRadius = UDim.new(0, radius),
        Parent = target or self.Parent
    })
    return corner
end

--// TAB SYSTEM - ระบบจัดการแท็บที่ไม่ซับซ้อน
local TabSystem = {}
TabSystem.__index = TabSystem

function TabSystem.new(tabContainer, contentContainer)
    local self = setmetatable({}, TabSystem)
    self.TabContainer = tabContainer
    self.ContentContainer = contentContainer
    self.Tabs = {} -- เก็บข้อมูลแท็บทั้งหมด {Button, Page}
    self.CurrentTab = nil
    return self
end

-- สร้างแท็บใหม่
function TabSystem:CreateTab(name, index)
    -- ตรวจสอบว่ามีชื่อนี้อยู่แล้วหรือไม่
    if self.Tabs[name] then
        warn("Tab " .. name .. " already exists!")
        return nil
    end
    
    -- สร้างปุ่มแท็บ
    local button = UIBuilder.new(self.TabContainer):Create("TextButton", {
        Size = UDim2.new(1, -12, 0, 48),
        Position = UDim2.new(0, 6, 0, 6 + (index - 1) * 54),
        BackgroundColor3 = Color3.fromRGB(32, 32, 32),
        Text = name,
        TextColor3 = Color3.fromRGB(190, 190, 190),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        AutoButtonColor = false,
    })
    
    -- เพิ่ม UICorner ให้ปุ่ม
    UIBuilder.new(button):Corner(8)
    
    -- สร้างหน้าเนื้อหา (ScrollingFrame)
    local page = UIBuilder.new(self.ContentContainer):Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = Color3.fromRGB(90, 90, 90),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false, -- เริ่มซ่อนไว้
    })
    
    -- เพิ่ม UIListLayout สำหรับจัดเรียงปุ่ม
    local layout = UIBuilder.new(page):Create("UIListLayout", {
        Padding = UDim.new(0, 9),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    
    -- เพิ่ม UIPadding
    UIBuilder.new(page):Create("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
    })
    
    -- เก็บข้อมูลแท็บ
    self.Tabs[name] = {
        Button = button,
        Page = page,
        Layout = layout
    }
    
    -- เชื่อมต่ออีเวนต์คลิกปุ่ม
    button.MouseButton1Click:Connect(function()
        self:SwitchToTab(name)
    end)
    
    -- Auto-size canvas ตามเนื้อหา
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 24)
    end)
    
    return page
end

-- สลับไปแท็บที่ระบุ
function TabSystem:SwitchToTab(name)
    if self.CurrentTab == name then return end -- ไม่ทำอะไรถ้าเป็นแท็บเดิม
    
    -- ซ่อนแท็บปัจจุบัน
    if self.CurrentTab and self.Tabs[self.CurrentTab] then
        self.Tabs[self.CurrentTab].Page.Visible = false
        self.Tabs[self.CurrentTab].Button.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    end
    
    -- แสดงแท็บใหม่
    if self.Tabs[name] then
        self.Tabs[name].Page.Visible = true
        self.Tabs[name].Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        self.CurrentTab = name
    end
end

--// FEATURES - ฟีเจอร์ที่เราจะเพิ่มทีละอัน
local Features = {
    NoClip = {
        Enabled = false,
        Connection = nil,
        
        Toggle = function()
            Features.NoClip.Enabled = not Features.NoClip.Enabled
            
            if Features.NoClip.Enabled then
                -- เปิด NoClip
                local character = LocalPlayer.Character
                if character then
                    -- ปิด collision สำหรับพาร์ทที่มีอยู่
                    for _, part in ipairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                    
                    -- ติดตามพาร์ทใหม่ที่เพิ่มเข้ามา
                    Features.NoClip.Connection = character.DescendantAdded:Connect(function(descendant)
                        if descendant:IsA("BasePart") then
                            descendant.CanCollide = false
                        end
                    end)
                    
                    print("✅ NoClip: Enabled")
                else
                    warn("Character not found!")
                    Features.NoClip.Enabled = false
                end
            else
                -- ปิด NoClip
                if Features.NoClip.Connection then
                    Features.NoClip.Connection:Disconnect()
                    Features.NoClip.Connection = nil
                end
                
                local character = LocalPlayer.Character
                if character then
                    for _, part in ipairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end
                
                print("❌ NoClip: Disabled")
            end
        end
    },
    
    SpeedHack = function(speed)
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local newSpeed = speed or 100
                humanoid.WalkSpeed = newSpeed
                print("🏃 Speed set to: " .. newSpeed)
            else
                warn("Humanoid not found!")
            end
        else
            warn("Character not found!")
        end
    end,
    
    AntiAFK = {
        Enabled = false,
        Connection = nil,
        
        Toggle = function()
            Features.AntiAFK.Enabled = not Features.AntiAFK.Enabled
            
            if Features.AntiAFK.Enabled then
                -- เปิด Anti-AFK
                Features.AntiAFK.Connection = LocalPlayer.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
                print("✅ Anti-AFK: Enabled")
            else
                -- ปิด Anti-AFK
                if Features.AntiAFK.Connection then
                    Features.AntiAFK.Connection:Disconnect()
                    Features.AntiAFK.Connection = nil
                end
                print("❌ Anti-AFK: Disabled")
            end
        end
    }
}

--// MAIN UI - สร้าง UI หลักทั้งหมด
local function CreateMainUI()
    -- ScreenGui หลัก
    local mainGUI = Instance.new("ScreenGui")
    mainGUI.Name = "AdvancedToolUI"
    mainGUI.ResetOnSpawn = false
    mainGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    mainGUI.Parent = CoreGui
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = CONFIG.UI.Size
    mainFrame.Position = CONFIG.UI.Position
    mainFrame.BackgroundColor3 = CONFIG.UI.BackgroundColor
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true -- สำหรับ drag
    mainFrame.Parent = mainGUI
    
    -- UICorner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, CONFIG.UI.CornerRadius)
    corner.Parent = mainFrame
    
    -- Top Bar
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 44)
    topBar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame
    
    -- TopBar UICorner (เฉพาะมุมบน)
    local topBarCorner = Instance.new("UICorner")
    topBarCorner.CornerRadius = UDim.new(0, CONFIG.UI.CornerRadius)
    topBarCorner.Parent = topBar
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = "⚡ Advanced Tool UI v2.0"
    title.Size = UDim2.new(1, -140, 1, 0)
    title.Position = UDim2.new(0, 16, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 17
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topBar
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 44, 0, 44)
    closeButton.Position = UDim2.new(1, -44, 0, 0)
    closeButton.Text = "✕"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 20
    closeButton.TextColor3 = Color3.fromRGB(220, 80, 80)
    closeButton.BackgroundTransparency = 1
    closeButton.AutoButtonColor = false
    closeButton.Parent = topBar
    
    -- Tab Container
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 140, 1, -44)
    tabContainer.Position = UDim2.new(0, 0, 0, 44)
    tabContainer.BackgroundColor3 = Color3.fromRGB(23, 23, 23)
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame
    
    -- Content Container
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -140, 1, -44)
    contentContainer.Position = UDim2.new(0, 140, 0, 44)
    contentContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    contentContainer.BorderSizePixel = 0
    contentContainer.ClipsDescendants = true
    contentContainer.Parent = mainFrame
    
    -- Toggle Button (ปุ่มเปิด-ปิด UI)
    local toggleGUI = Instance.new("ScreenGui")
    toggleGUI.Name = "ToggleUI"
    toggleGUI.ResetOnSpawn = false
    toggleGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    toggleGUI.Parent = CoreGui
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 52, 0, 52)
    toggleButton.Position = UDim2.new(0, 22, 0.5, -26)
    toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    toggleButton.Text = "⚡"
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 22
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.AutoButtonColor = false
    toggleButton.Parent = toggleGUI
    
    -- Toggle Button UICorner
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 10)
    toggleCorner.Parent = toggleButton
    
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

--// INITIALIZE UI - เชื่อมทุกอย่างเข้าด้วยกัน
local function InitializeUI()
    -- 1. สร้าง UI หลัก
    local ui = CreateMainUI()
    
    -- 2. สร้างระบบแท็บ
    local tabSystem = TabSystem.new(ui.TabContainer, ui.ContentContainer)
    
    -- 3. สร้างแท็บต่างๆ
    tabSystem:CreateTab("🏃 Teleport", 1)
    tabSystem:CreateTab("🛠️ Tools", 2)
    tabSystem:CreateTab("👤 Player", 3)
    tabSystem:CreateTab("🌐 Server", 4)
    
    -- 4. เพิ่มปุ่มฟีเจอร์ในแต่ละแท็บ
    
    -- แท็บ Teleport
    local teleportTab = tabSystem.Tabs["🏃 Teleport"].Page
    local noclipButton = UIBuilder.new(teleportTab):Create("TextButton", {
        Size = UDim2.new(1, -22, 0, 42),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Text = "  NoClip Toggle (F1)",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
    })
    UIBuilder.new(noclipButton):Corner(7)
    noclipButton.MouseButton1Click:Connect(Features.NoClip.Toggle)
    
    local speedButton = UIBuilder.new(teleportTab):Create("TextButton", {
        Size = UDim2.new(1, -22, 0, 42),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Text = "  Speed Hack (100)",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
    })
    UIBuilder.new(speedButton):Corner(7)
    speedButton.MouseButton1Click:Connect(function()
        Features.SpeedHack(100)
    end)
    
    -- แท็บ Tools
    local toolsTab = tabSystem.Tabs["🛠️ Tools"].Page
    local antiafkButton = UIBuilder.new(toolsTab):Create("TextButton", {
        Size = UDim2.new(1, -22, 0, 42),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Text = "  Anti-AFK Toggle",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
    })
    UIBuilder.new(antiafkButton):Corner(7)
    antiafkButton.MouseButton1Click:Connect(Features.AntiAFK.Toggle)
    
    -- 5. สลับไปแท็บแรก
    tabSystem:SwitchToTab("🏃 Teleport")
    
    -- 6. ฟังก์ชันเปิด-ปิด UI
    local isVisible = true
    
    local function ToggleUI()
        isVisible = not isVisible
        ui.MainFrame.Visible = isVisible
        
        -- อนิเมชันเล็กน้อย
        if isVisible then
            TweenService:Create(ui.MainFrame, TweenInfo.new(0.3), {
                BackgroundTransparency = 0
            }):Play()
            ui.ToggleButton.Text = "⚡"
        else
            TweenService:Create(ui.MainFrame, TweenInfo.new(0.3), {
                BackgroundTransparency = 1
            }):Play()
            ui.ToggleButton.Text = "▶"
        end
    end
    
    -- 7. เชื่อมต่ออีเวนต์ต่างๆ
    
    -- ปุ่ม Toggle
    ui.ToggleButton.MouseButton1Click:Connect(ToggleUI)
    
    -- ปุ่ม Close
    ui.CloseButton.MouseButton1Click:Connect(function()
        ui.MainGUI:Destroy()
        ui.ToggleGUI:Destroy()
        print("✅ UI ปิดแล้ว")
    end)
    
    -- Keybind F9
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end -- ไม่ทำอะไรถ้ากำลังพิมพ์
        if input.KeyCode == CONFIG.Keybind then
            ToggleUI()
        end
    end)
    
    -- 8. ระบบลากหน้าต่าง (ง่ายๆ แต่ได้ผล)
    local dragging = false
    local dragStart, startPos
    
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
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            ui.MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    print("⚡ Advanced Tool UI v2.0 loaded successfully!")
    print("Press F9 or click the ⚡ button to toggle UI")
    
    return ui
end

--// STARTUP - เริ่มต้น UI เมื่อพร้อม
if LocalPlayer.Character then
    -- ถ้าผู้เล่นโหลดเสร็จแล้ว
    wait(0.5) -- รอนิดหน่อย
    InitializeUI()
else
    -- รอผู้เล่นโหลด
    LocalPlayer.CharacterAdded:Connect(function()
        wait(1) -- รอให้ character โหลดเต็มที่
        InitializeUI()
    end)
end

-- Fallback ถ้า 3 วิแล้วยังไม่โหลด
task.delay(3, function()
    if not CoreGui:FindFirstChild("AdvancedToolUI") then
        warn("⚠️ UI not loaded automatically, trying fallback...")
        InitializeUI()
    end
end)

return "Advanced Tool UI v2.0 - Successfully Loaded!"
