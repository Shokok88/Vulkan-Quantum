-- VULKAN ADVANCED DESYNC v9.0
-- ПОЛНЫЙ РАБОЧИЙ ДИСИНК С ВСЕМИ ФУНКЦИЯМИ

getgenv().Vulkan = {
    DesyncEnabled = false,
    Clone = nil,
    OriginalPosition = nil,
    Connections = {},
    GUI = nil
}

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ОСНОВНАЯ ФУНКЦИЯ ДИСИНКА
function CreateAdvancedDesync()
    if not player.Character then
        warn("❌ Character not found")
        return false
    end
    
    local character = player.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then
        warn("❌ Humanoid or RootPart not found")
        return false
    end
    
    if humanoid.Health <= 0 then
        warn("❌ Character is dead")
        return false
    end
    
    -- Сохраняем оригинальную позицию
    getgenv().Vulkan.OriginalPosition = rootPart.CFrame
    
    -- Создаем клона
    local clone = character:Clone()
    clone.Name = "VulkanDesyncClone"
    
    -- Убираем ненужные скрипты у клона
    for _, v in pairs(clone:GetDescendants()) do
        if v:IsA("Script") or v:IsA("LocalScript") then
            v:Destroy()
        end
    end
    
    -- Настраиваем внешность клона
    for _, part in pairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0.4
            part.Material = Enum.Material.Neon
            part.Color = Color3.fromRGB(255, 50, 50)
            part.CanCollide = false
            part.Anchored = false
        end
    end
    
    -- Настраиваем человечка клона
    local cloneHumanoid = clone:FindFirstChildOfClass("Humanoid")
    if cloneHumanoid then
        cloneHumanoid.WalkSpeed = humanoid.WalkSpeed
        cloneHumanoid.JumpPower = humanoid.JumpPower
        cloneHumanoid.Health = humanoid.Health
        cloneHumanoid.MaxHealth = humanoid.MaxHealth
    end
    
    clone.Parent = Workspace
    getgenv().Vulkan.Clone = clone
    
    -- Прячем оригинального персонажа
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CanCollide = false
        end
    end
    
    -- Оставляем только тень у оригинала
    local originalHumanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if originalHumanoidRootPart then
        originalHumanoidRootPart.Transparency = 0.9
    end
    
    -- Подключаем движение клона
    getgenv().Vulkan.Connections.DesyncMovement = RunService.Stepped:Connect(function()
        if not getgenv().Vulkan.DesyncEnabled then return end
        
        local currentCharacter = player.Character
        local currentClone = getgenv().Vulkan.Clone
        
        if not currentCharacter or not currentClone then return end
        
        local currentRoot = currentCharacter:FindFirstChild("HumanoidRootPart")
        local cloneRoot = currentClone:FindFirstChild("HumanoidRootPart")
        local originalPos = getgenv().Vulkan.OriginalPosition
        
        if currentRoot and cloneRoot and originalPos then
            -- Клон повторяет движения игрока
            cloneRoot.CFrame = currentRoot.CFrame
            
            -- Игрок остается на оригинальной позиции (дисинк)
            currentRoot.CFrame = originalPos
            
            -- Синхронизируем анимации
            local currentHumanoid = currentCharacter:FindFirstChildOfClass("Humanoid")
            local cloneHumanoid = currentClone:FindFirstChildOfClass("Humanoid")
            
            if currentHumanoid and cloneHumanoid then
                cloneHumanoid.WalkSpeed = currentHumanoid.WalkSpeed
                cloneHumanoid.JumpPower = currentHumanoid.JumpPower
                
                -- Синхронизируем состояние
                if currentHumanoid:GetState() == Enum.HumanoidStateType.Running then
                    cloneHumanoid:ChangeState(Enum.HumanoidStateType.Running)
                elseif currentHumanoid:GetState() == Enum.HumanoidStateType.Jumping then
                    cloneHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end)
    
    -- Защита от утери клона
    getgenv().Vulkan.Connections.CloneProtection = clone.AncestryChanged:Connect(function()
        if not clone.Parent then
            warn("⚠️ Clone was removed, recreating...")
            RemoveDesync()
            wait(0.5)
            if getgenv().Vulkan.DesyncEnabled then
                CreateAdvancedDesync()
            end
        end
    end)
    
    print("✅ ADVANCED DESYNC ACTIVATED")
    print("📍 Original position saved")
    print("🎮 Clone is now visible")
    print("🔧 Movement synced")
    
    return true
end

-- ФУНКЦИЯ ВЫКЛЮЧЕНИЯ ДИСИНКА
function RemoveDesync()
    -- Восстанавливаем оригинального персонажа
    local character = player.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
                part.CanCollide = true
            end
        end
    end
    
    -- Удаляем клона
    if getgenv().Vulkan.Clone then
        getgenv().Vulkan.Clone:Destroy()
        getgenv().Vulkan.Clone = nil
    end
    
    -- Отключаем соединения
    for name, connection in pairs(getgenv().Vulkan.Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    getgenv().Vulkan.Connections = {}
    
    getgenv().Vulkan.DesyncEnabled = false
    getgenv().Vulkan.OriginalPosition = nil
    
    print("❌ DESYNC DEACTIVATED")
end

-- ПЕРЕКЛЮЧЕНИЕ ДИСИНКА
function ToggleDesync()
    if getgenv().Vulkan.DesyncEnabled then
        RemoveDesync()
    else
        getgenv().Vulkan.DesyncEnabled = true
        local success = CreateAdvancedDesync()
        if not success then
            getgenv().Vulkan.DesyncEnabled = false
            warn("❌ Failed to activate desync")
        end
    end
    UpdateGUI()
end

-- ОБНОВЛЕНИЕ ГУИ
function UpdateGUI()
    if not getgenv().Vulkan.GUI then return end
    
    local DesyncButton = getgenv().Vulkan.GUI.DesyncButton
    local StatusLabel = getgenv().Vulkan.GUI.StatusLabel
    
    if getgenv().Vulkan.DesyncEnabled then
        DesyncButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        DesyncButton.Text = "DESYNC: ON"
        StatusLabel.Text = "Status: Active - Clone Visible"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        DesyncButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        DesyncButton.Text = "DESYNC: OFF"
        StatusLabel.Text = "Status: Ready - Press Q"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

-- СОЗДАНИЕ ГРАФИЧЕСКОГО ИНТЕРФЕЙСА
function CreateAdvancedGUI()
    -- Удаляем старый GUI
    if getgenv().Vulkan.GUI and getgenv().Vulkan.GUI.ScreenGui then
        getgenv().Vulkan.GUI.ScreenGui:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local TitleBar = Instance.new("Frame")
    local TitleLabel = Instance.new("TextLabel")
    local MinimizeButton = Instance.new("TextButton")
    local ContentFrame = Instance.new("Frame")
    local DesyncButton = Instance.new("TextButton")
    local StatusLabel = Instance.new("TextLabel")
    local InfoLabel = Instance.new("TextLabel")
    
    ScreenGui.Name = "VulkanAdvancedGUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Основной фрейм
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
    MainFrame.Size = UDim2.new(0, 280, 0, 160)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(255, 50, 50)
    MainStroke.Thickness = 2
    MainStroke.Parent = MainFrame
    
    -- Панель заголовка
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 32)
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar
    
    -- Заголовок
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Parent = TitleBar
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Size = UDim2.new(1, -40, 1, 0)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = "VULKAN DESYNC v9.0"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    
    -- Кнопка сворачивания
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Parent = TitleBar
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Position = UDim2.new(1, -30, 0, 6)
    MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.Text = "_"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.TextSize = 14
    
    local MinimizeCorner = Instance.new("UICorner")
    MinimizeCorner.CornerRadius = UDim.new(0, 4)
    MinimizeCorner.Parent = MinimizeButton
    
    -- Контент
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = MainFrame
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Position = UDim2.new(0, 0, 0, 32)
    ContentFrame.Size = UDim2.new(1, 0, 1, -32)
    
    -- Кнопка дисинка
    DesyncButton.Name = "DesyncButton"
    DesyncButton.Parent = ContentFrame
    DesyncButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    DesyncButton.BorderSizePixel = 0
    DesyncButton.Position = UDim2.new(0.05, 0, 0.1, 0)
    DesyncButton.Size = UDim2.new(0.9, 0, 0, 40)
    DesyncButton.Font = Enum.Font.GothamBold
    DesyncButton.Text = "DESYNC: OFF"
    DesyncButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DesyncButton.TextSize = 14
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = DesyncButton
    
    -- Статус
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Parent = ContentFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 10, 0, 60)
    StatusLabel.Size = UDim2.new(1, -20, 0, 20)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "Status: Ready - Press Q"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusLabel.TextSize = 12
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Инфо
    InfoLabel.Name = "InfoLabel"
    InfoLabel.Parent = ContentFrame
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Position = UDim2.new(0, 10, 0, 85)
    InfoLabel.Size = UDim2.new(1, -20, 0, 40)
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.Text = "Creates red clone that moves\nOriginal stays invisible in place\nHotkey: Q"
    InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    InfoLabel.TextSize = 10
    InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
    
    -- Функционал сворачивания
    local minimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            MainFrame.Size = UDim2.new(0, 280, 0, 32)
            ContentFrame.Visible = false
        else
            MainFrame.Size = UDim2.new(0, 280, 0, 160)
            ContentFrame.Visible = true
        end
    end)
    
    -- Функция кнопки дисинка
    DesyncButton.MouseButton1Click:Connect(function()
        ToggleDesync()
    end)
    
    -- Сохраняем ссылки на элементы GUI
    getgenv().Vulkan.GUI = {
        ScreenGui = ScreenGui,
        DesyncButton = DesyncButton,
        StatusLabel = StatusLabel
    }
    
    return ScreenGui
end

-- АВТОМАТИЧЕСКАЯ ЗАГРУЗКА
function InitializeVulkan()
    -- Ждем загрузки персонажа
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    
    wait(2) -- Даем время на полную загрузку
    
    -- Создаем GUI
    CreateAdvancedGUI()
    
    -- Настраиваем горячую клавишу
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.Q then
            ToggleDesync()
        end
    end)
    
    -- Защита от потери персонажа
    player.CharacterAdded:Connect(function(character)
        if getgenv().Vulkan.DesyncEnabled then
            wait(1)
            RemoveDesync()
            wait(0.5)
            getgenv().Vulkan.DesyncEnabled = true
            CreateAdvancedDesync()
            UpdateGUI()
        end
    end)
    
    print("🔥 VULKAN ADVANCED DESYNC v9.0 LOADED!")
    print("🎯 Press Q to toggle desync")
    print("📌 Red clone = visible, original = desynced")
    print("🔧 Advanced movement synchronization")
end

-- ЗАПУСК
InitializeVulkan()
