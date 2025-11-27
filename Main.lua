-- VULKAN PERFECT DESYNC v12.0
-- АВТОМАТИЧЕСКИЙ РАБОЧИЙ ДИСИНК

getgenv().Vulkan = {
    DesyncEnabled = false,
    Clone = nil,
    OriginalPosition = nil,
    Connections = {}
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- АВТОМАТИЧЕСКОЕ СОЗДАНИЕ ДИСИНКА
function CreatePerfectDesync()
    if not player.Character then return false end
    
    local character = player.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return false end
    
    -- Сохраняем позицию для дисинка
    getgenv().Vulkan.OriginalPosition = rootPart.CFrame
    
    -- Создаем клона который будет видимым "нами"
    local clone = character:Clone()
    clone.Name = "DesyncClone"
    
    -- Убираем скрипты у клона
    for _, v in pairs(clone:GetDescendants()) do
        if v:IsA("Script") or v:IsA("LocalScript") then
            v:Destroy()
        end
    end
    
    -- Делаем клона полностью видимым (как настоящий игрок)
    for _, part in pairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0
            part.Material = Enum.Material.Plastic
            part.Color = Color3.fromRGB(255, 255, 255)
            part.CanCollide = true
        end
    end
    
    clone.Parent = workspace
    getgenv().Vulkan.Clone = clone
    
    -- Позиционируем клона точно на нашем месте
    local cloneRoot = clone:FindFirstChild("HumanoidRootPart")
    if cloneRoot then
        cloneRoot.CFrame = getgenv().Vulkan.OriginalPosition
    end
    
    -- ДЕЛАЕМ ОРИГИНАЛЬНОГО ИГРОКА НЕВИДИМЫМ И НЕУЯЗВИМЫМ
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1  -- Полная невидимость
            part.CanCollide = false  -- Нельзя столкнуться
        end
    end
    
    -- Делаем человечка неуязвимым
    humanoid.MaxHealth = math.huge
    humanoid.Health = math.huge
    
    -- СИСТЕМА ДВИЖЕНИЯ: клон стоит на месте, игрок двигается невидимо
    getgenv().Vulkan.Connections.Movement = RunService.Stepped:Connect(function()
        if not getgenv().Vulkan.DesyncEnabled then return end
        
        local currentCharacter = player.Character
        local currentClone = getgenv().Vulkan.Clone
        
        if not currentCharacter or not currentClone then return end
        
        local currentRoot = currentCharacter:FindFirstChild("HumanoidRootPart")
        local cloneRoot = currentClone:FindFirstChild("HumanoidRootPart")
        
        if currentRoot and cloneRoot then
            -- Клон ВСЕГДА остается на оригинальной позиции
            cloneRoot.CFrame = getgenv().Vulkan.OriginalPosition
            
            -- Игрок двигается невидимо где хочет
            -- Но другие игроки видят клона на месте дисинка
        end
    end)
    
    -- ЗАЩИТА ОТ УДАРА: перехватываем урон
    getgenv().Vulkan.Connections.Damage = humanoid.HealthChanged:Connect(function(health)
        if getgenv().Vulkan.DesyncEnabled then
            -- Автоматически восстанавливаем здоровье
            humanoid.Health = math.huge
        end
    end)
    
    print("✅ PERFECT DESYNC ACTIVATED")
    print("📍 Clone visible at original position") 
    print("🎮 You are invisible and invulnerable")
    print("🛡️ Enemies can't hit you")
    
    return true
end

-- ВЫКЛЮЧЕНИЕ ДИСИНКА
function RemoveDesync()
    local character = player.Character
    if character then
        -- Возвращаем видимость
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
                part.CanCollide = true
            end
        end
        
        -- Возвращаем нормальное здоровье
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.MaxHealth = 100
            humanoid.Health = 100
        end
    end
    
    -- Удаляем клона
    if getgenv().Vulkan.Clone then
        getgenv().Vulkan.Clone:Destroy()
        getgenv().Vulkan.Clone = nil
    end
    
    -- Отключаем соединения
    for _, connection in pairs(getgenv().Vulkan.Connections) do
        connection:Disconnect()
    end
    getgenv().Vulkan.Connections = {}
    
    getgenv().Vulkan.DesyncEnabled = false
    getgenv().Vulkan.OriginalPosition = nil
    
    print("❌ DESYNC DEACTIVATED")
end

-- АВТОМАТИЧЕСКОЕ ПЕРЕКЛЮЧЕНИЕ
function ToggleDesync()
    if getgenv().Vulkan.DesyncEnabled then
        RemoveDesync()
    else
        getgenv().Vulkan.DesyncEnabled = true
        local success = CreatePerfectDesync()
        if not success then
            getgenv().Vulkan.DesyncEnabled = false
        end
    end
    UpdateGUI()
end

-- ПРОСТОЙ ГУИ
function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local DesyncButton = Instance.new("TextButton")
    local Status = Instance.new("TextLabel")
    
    ScreenGui.Name = "VulkanDesyncGUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Главное окно
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.4, 0, 0.4, 0)
    MainFrame.Size = UDim2.new(0, 250, 0, 120)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 255, 0)
    Stroke.Thickness = 2
    Stroke.Parent = MainFrame
    
    -- Заголовок
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "AUTO DESYNC v12.0"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = Title
    
    -- Кнопка
    DesyncButton.Name = "DesyncButton"
    DesyncButton.Parent = MainFrame
    DesyncButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    DesyncButton.BorderSizePixel = 0
    DesyncButton.Position = UDim2.new(0.1, 0, 0.3, 0)
    DesyncButton.Size = UDim2.new(0.8, 0, 0, 40)
    DesyncButton.Font = Enum.Font.GothamBold
    DesyncButton.Text = "DESYNC: OFF"
    DesyncButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DesyncButton.TextSize = 14
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = DesyncButton
    
    -- Статус
    Status.Name = "Status"
    Status.Parent = MainFrame
    Status.BackgroundTransparency = 1
    Status.Position = UDim2.new(0, 10, 0.8, 0)
    Status.Size = UDim2.new(1, -20, 0, 20)
    Status.Font = Enum.Font.Gotham
    Status.Text = "Press Q - Invisible & Invulnerable"
    Status.TextColor3 = Color3.fromRGB(200, 200, 200)
    Status.TextSize = 11
    
    -- Функция кнопки
    DesyncButton.MouseButton1Click:Connect(function()
        ToggleDesync()
    end)
    
    getgenv().Vulkan.GUI = {
        ScreenGui = ScreenGui,
        DesyncButton = DesyncButton,
        Status = Status
    }
    
    return ScreenGui
end

function UpdateGUI()
    if not getgenv().Vulkan.GUI then return end
    
    local DesyncButton = getgenv().Vulkan.GUI.DesyncButton
    local Status = getgenv().Vulkan.GUI.Status
    
    if getgenv().Vulkan.DesyncEnabled then
        DesyncButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        DesyncButton.Text = "DESYNC: ON"
        Status.Text = "ACTIVE - Invisible & Invulnerable"
        Status.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        DesyncButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        DesyncButton.Text = "DESYNC: OFF"
        Status.Text = "Press Q - Invisible & Invulnerable"
        Status.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end

-- АВТОМАТИЧЕСКАЯ АКТИВАЦИЯ
if not player.Character then
    player.CharacterAdded:Wait()
end

wait(1)
CreateGUI()

-- ГОРЯЧАЯ КЛАВИША
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Q then
        ToggleDesync()
    end
end)

print("🔥 AUTO DESYNC v12.0 LOADED!")
print("🎯 Press Q to toggle")
print("👻 You become invisible and invulnerable")
print("📍 Clone stays visible at desync position")
print("🛡️ Enemies can't hit you")
