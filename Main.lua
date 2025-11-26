-- VULKAN QUANTUM SCRIPT v4.1 FIXED
-- Fixed draggable GUI and Quantum Desync buttons

getgenv().VulkanQuantum = {
    Settings = {
        Version = "4.1",
        AutoLoad = true,
        Minimized = false,
        QuantumEnabled = false
    },
    Connections = {},
    GUI = nil
}

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

-- Variables
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Quantum Desync Module
local QuantumDesync = {}

function QuantumDesync:Initialize()
    self.QuantumStates = {"Active", "Ghost", "Respawn", "Teleport", "Phase", "Clone"}
    self.CurrentState = "Active"
    self.OriginalCFrame = nil
    self.QuantumClone = nil
end

function QuantumDesync:QuantumStateShift()
    local character = player.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    self.OriginalCFrame = rootPart.CFrame
    
    for i = 1, 6 do
        rootPart.CFrame = self.OriginalCFrame * CFrame.new(
            math.random(-3, 3),
            math.random(-1, 1), 
            math.random(-3, 3)
        )
        RunService.Heartbeat:Wait()
    end
    
    rootPart.CFrame = self.OriginalCFrame
end

function QuantumDesync:CreateQuantumClone()
    local character = player.Character
    if not character then return end
    
    local clone = character:Clone()
    clone.Name = "QuantumClone"
    clone.Parent = workspace
    
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CanCollide = false
        end
    end
    
    for _, part in pairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0.6
            part.Material = Enum.Material.Neon
            part.Color = Color3.fromRGB(0, 255, 255)
        end
    end
    
    self.QuantumClone = clone
    
    self.Connections.CloneMovement = RunService.Stepped:Connect(function()
        if self.QuantumClone and self.QuantumClone.Parent and character and character.Parent then
            local cloneRoot = self.QuantumClone:FindFirstChild("HumanoidRootPart")
            local realRoot = character:FindFirstChild("HumanoidRootPart")
            
            if cloneRoot and realRoot then
                cloneRoot.CFrame = realRoot.CFrame * CFrame.new(0, 0, -3)
            end
        end
    end)
end

function QuantumDesync:ToggleQuantumDesync(state)
    if state then
        self:Initialize()
        self:QuantumStateShift()
        self:CreateQuantumClone()
        getgenv().VulkanQuantum.Settings.QuantumEnabled = true
    else
        if self.Connections.CloneMovement then
            self.Connections.CloneMovement:Disconnect()
        end
        
        local character = player.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                    part.CanCollide = true
                end
            end
        end
        
        if self.QuantumClone then
            self.QuantumClone:Destroy()
            self.QuantumClone = nil
        end
        getgenv().VulkanQuantum.Settings.QuantumEnabled = false
    end
end

-- GUI Creation Function
function CreateVulkanGUI()
    -- Cleanup previous GUI
    if getgenv().VulkanQuantum.GUI then
        getgenv().VulkanQuantum.GUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local TitleBar = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local MinimizeBtn = Instance.new("TextButton")
    local TabButtons = Instance.new("ScrollingFrame")
    local ContentFrame = Instance.new("ScrollingFrame")
    
    ScreenGui.Name = "VulkanQuantumGUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
    MainFrame.Size = UDim2.new(0, 500, 0, 400)
    MainFrame.Active = true
    MainFrame.Draggable = true

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 255, 255)
    Stroke.Thickness = 2
    Stroke.Parent = MainFrame
    
    -- Title Bar
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar
    
    -- Title
    Title.Name = "Title"
    Title.Parent = TitleBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "Vulkan Quantum v4.1"
    Title.TextColor3 = Color3.fromRGB(0, 255, 255)
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Minimize Button
    MinimizeBtn.Name = "MinimizeBtn"
    MinimizeBtn.Parent = TitleBar
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MinimizeBtn.BorderSizePixel = 0
    MinimizeBtn.Position = UDim2.new(1, -35, 0, 5)
    MinimizeBtn.Size = UDim2.new(0, 25, 0, 25)
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.Text = "_"
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.TextSize = 16
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = MinimizeBtn
    
    -- Tab Buttons Scrolling Frame
    TabButtons.Name = "TabButtons"
    TabButtons.Parent = MainFrame
    TabButtons.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabButtons.BorderSizePixel = 0
    TabButtons.Position = UDim2.new(0, 0, 0, 35)
    TabButtons.Size = UDim2.new(0, 130, 0, 365)
    TabButtons.ScrollBarThickness = 3
    TabButtons.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Parent = TabButtons
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 5)
    
    -- Content Frame
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = MainFrame
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Position = UDim2.new(0, 130, 0, 35)
    ContentFrame.Size = UDim2.new(1, -130, 1, -35)
    ContentFrame.ScrollBarThickness = 4
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Parent = ContentFrame
    ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Padding = UDim.new(0, 8)
    
    -- Minimize Functionality
    local minimized = false
    local originalSize = MainFrame.Size
    local minimizedSize = UDim2.new(0, 500, 0, 35)
    
    MinimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            MainFrame.Size = minimizedSize
            TabButtons.Visible = false
            ContentFrame.Visible = false
            getgenv().VulkanQuantum.Settings.Minimized = true
        else
            MainFrame.Size = originalSize
            TabButtons.Visible = true
            ContentFrame.Visible = true
            getgenv().VulkanQuantum.Settings.Minimized = false
        end
    end)

    -- Create Button Function
    local function CreateButton(name, parent, callback)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Parent = parent
        button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        button.BorderSizePixel = 0
        button.Size = UDim2.new(0.9, 0, 0, 40)
        button.Font = Enum.Font.Gotham
        button.Text = name
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 14
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = button
        
        button.MouseButton1Click:Connect(callback)
        return button
    end

    -- Create Section Function
    local function CreateSection(name, parent)
        local section = Instance.new("Frame")
        section.Name = name
        section.Parent = parent
        section.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        section.BorderSizePixel = 0
        section.Size = UDim2.new(0.95, 0, 0, 120)
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = section
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(50, 50, 50)
        stroke.Thickness = 1
        stroke.Parent = section
        
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Parent = section
        title.BackgroundTransparency = 1
        title.Position = UDim2.new(0, 10, 0, 5)
        title.Size = UDim2.new(1, -20, 0, 20)
        title.Font = Enum.Font.GothamBold
        title.Text = name
        title.TextColor3 = Color3.fromRGB(0, 255, 255)
        title.TextSize = 14
        title.TextXAlignment = Enum.TextXAlignment.Left
        
        return section
    end

    -- Create Toggle Button Function
    local function CreateToggle(name, parent, callback)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Name = name
        toggleFrame.Parent = parent
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.Size = UDim2.new(1, -20, 0, 30)
        toggleFrame.Position = UDim2.new(0, 10, 0, 30)
        
        local toggleText = Instance.new("TextLabel")
        toggleText.Name = "Text"
        toggleText.Parent = toggleFrame
        toggleText.BackgroundTransparency = 1
        toggleText.Size = UDim2.new(0.7, 0, 1, 0)
        toggleText.Font = Enum.Font.Gotham
        toggleText.Text = name
        toggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleText.TextSize = 12
        toggleText.TextXAlignment = Enum.TextXAlignment.Left
        
        local toggleButton = Instance.new("TextButton")
        toggleButton.Name = "Toggle"
        toggleButton.Parent = toggleFrame
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        toggleButton.BorderSizePixel = 0
        toggleButton.Position = UDim2.new(0.7, 0, 0, 5)
        toggleButton.Size = UDim2.new(0, 40, 0, 20)
        toggleButton.Font = Enum.Font.GothamBold
        toggleButton.Text = "OFF"
        toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggleButton.TextSize = 10
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 10)
        toggleCorner.Parent = toggleButton
        
        local toggled = false
        
        toggleButton.MouseButton1Click:Connect(function()
            toggled = not toggled
            if toggled then
                toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                toggleButton.Text = "ON"
            else
                toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                toggleButton.Text = "OFF"
            end
            callback(toggled)
        end)
        
        return toggleFrame
    end

    -- Create Tabs
    local quantumTabBtn = CreateButton("Quantum Desync", TabButtons, function()
        -- Clear content
        for _, child in pairs(ContentFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        -- Create Quantum Desync section
        local quantumSection = CreateSection("Quantum Desync", ContentFrame)
        quantumSection.Size = UDim2.new(0.95, 0, 0, 150)
        
        -- Quantum Desync Toggle
        CreateToggle("Quantum Desync", quantumSection, function(state)
            QuantumDesync:ToggleQuantumDesync(state)
        end)
        
        -- Quantum Clone Button
        local cloneBtn = CreateButton("Create Quantum Clone", quantumSection, function()
            QuantumDesync:CreateQuantumClone()
        end)
        cloneBtn.Position = UDim2.new(0, 10, 0, 70)
        cloneBtn.Size = UDim2.new(1, -20, 0, 30)
        
        -- Quantum State Shift Button
        local stateBtn = CreateButton("Quantum State Shift", quantumSection, function()
            QuantumDesync:QuantumStateShift()
        end)
        stateBtn.Position = UDim2.new(0, 10, 0, 110)
        stateBtn.Size = UDim2.new(1, -20, 0, 30)
    end)

    -- Create Combat Tab
    local combatTabBtn = CreateButton("Combat", TabButtons, function()
        for _, child in pairs(ContentFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        local combatSection = CreateSection("Combat Features", ContentFrame)
        combatSection.Size = UDim2.new(0.95, 0, 0, 100)
        
        CreateToggle("Aimbot", combatSection, function(state)
            print("Aimbot: " .. tostring(state))
        end)
    end)

    -- Create Movement Tab
    local movementTabBtn = CreateButton("Movement", TabButtons, function()
        for _, child in pairs(ContentFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        local movementSection = CreateSection("Movement Features", ContentFrame)
        movementSection.Size = UDim2.new(0.95, 0, 0, 100)
        
        CreateToggle("Speed Hack", movementSection, function(state)
            if state then
                player.Character.Humanoid.WalkSpeed = 50
            else
                player.Character.Humanoid.WalkSpeed = 16
            end
        end)
    end)

    -- Auto-click Quantum Desync tab to show content
    quantumTabBtn:Click()

    getgenv().VulkanQuantum.GUI = ScreenGui
    return ScreenGui
end

-- Auto-Load System
function SetupAutoLoad()
    if getgenv().VulkanQuantum.Settings.AutoLoad then
        if not player.Character then
            player.CharacterAdded:Wait()
        end
        
        wait(1)
        CreateVulkanGUI()
        
        if getgenv().VulkanQuantum.Settings.QuantumEnabled then
            QuantumDesync:ToggleQuantumDesync(true)
        end
    end
    
    player.CharacterAdded:Connect(function(character)
        if getgenv().VulkanQuantum.Settings.AutoLoad then
            wait(1)
            if getgenv().VulkanQuantum.Settings.QuantumEnabled then
                QuantumDesync:ApplyQuantumAfterEffects(character)
            end
        end
    end)
end

-- Initialize
function InitializeVulkanQuantum()
    SetupAutoLoad()
    CreateVulkanGUI()
    print("Vulkan Quantum v4.1 loaded successfully!")
end

-- Start the script
InitializeVulkanQuantum()
