-- VULKAN QUANTUM DESYNC ONLY v4.2
-- Только рабочий дисинк, без лишнего мусора

getgenv().Vulkan = {
    DesyncEnabled = false,
    Clone = nil
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- РАБОЧИЙ ДИСИНК
function CreateDesync()
    if not player.Character then return end
    
    local character = player.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not root then return end
    
    -- Сохраняем оригинальную позицию
    local originalPosition = root.Position
    local originalCFrame = root.CFrame
    
    -- Создаем невидимого клона для дисинка
    local clone = character:Clone()
    clone.Name = "DesyncClone"
    
    -- Делаем клона полупрозрачным
    for _, part in pairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0.7
            part.Material = Enum.Material.Neon
            part.Color = Color3.fromRGB(255, 0, 0)
            part.CanCollide = false
        end
    end
    
    clone.Parent = workspace
    getgenv().Vulkan.Clone = clone
    
    -- Делаем оригинального персонажа невидимым
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CanCollide = false
        end
    end
    
    -- Двигаем клона вместо оригинала
    RunService.Stepped:Connect(function()
        if getgenv().Vulkan.DesyncEnabled and clone and clone.Parent then
            local cloneRoot = clone:FindFirstChild("HumanoidRootPart")
            local realRoot = character:FindFirstChild("HumanoidRootPart")
            
            if cloneRoot and realRoot then
                -- Клон повторяет движения, но с небольшим смещением
                cloneRoot.CFrame = realRoot.CFrame
                
                -- Оригинал остается на месте (дисинк)
                realRoot.CFrame = CFrame.new(originalPosition)
            end
        end
    end)
    
    print("✅ Desync activated! Clone created.")
end

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
    end
    
    -- Удаляем клона
    if getgenv().Vulkan.Clone then
        getgenv().Vulkan.Clone:Destroy()
        getgenv().Vulkan.Clone = nil
    end
    
    getgenv().Vulkan.DesyncEnabled = false
    print("❌ Desync deactivated")
end

function ToggleDesync()
    if getgenv().Vulkan.DesyncEnabled then
        RemoveDesync()
    else
        getgenv().Vulkan.DesyncEnabled = true
        CreateDesync()
    end
end

-- ПРОСТОЙ ГУИ ТОЛЬКО С ДИСИНКОМ
function CreateSimpleGUI()
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
    MainFrame.Size = UDim2.new(0, 200, 0, 120)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 0, 0)
    Stroke.Thickness = 2
    Stroke.Parent = MainFrame
    
    -- Заголовок
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "VULKAN DESYNC"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = Title
    
    -- Кнопка дисинка
    DesyncButton.Name = "DesyncButton"
    DesyncButton.Parent = MainFrame
    DesyncButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    DesyncButton.BorderSizePixel = 0
    DesyncButton.Position = UDim2.new(0.1, 0, 0.4, 0)
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
    Status.Position = UDim2.new(0, 0, 0.8, 0)
    Status.Size = UDim2.new(1, 0, 0, 20)
    Status.Font = Enum.Font.Gotham
    Status.Text = "Ready"
    Status.TextColor3 = Color3.fromRGB(0, 255, 0)
    Status.TextSize = 12
    
    -- Функция кнопки
    DesyncButton.MouseButton1Click:Connect(function()
        ToggleDesync()
        
        if getgenv().Vulkan.DesyncEnabled then
            DesyncButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            DesyncButton.Text = "DESYNC: ON"
            Status.Text = "Desync Active"
            Status.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            DesyncButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            DesyncButton.Text = "DESYNC: OFF"
            Status.Text = "Ready"
            Status.TextColor3 = Color3.fromRGB(0, 255, 0)
        end
    end)
    
    print("🎯 Vulkan Desync GUI Loaded!")
    return ScreenGui
end

-- АВТОМАТИЧЕСКАЯ ЗАГРУЗКА
if not player.Character then
    player.CharacterAdded:Wait()
end

wait(1)
CreateSimpleGUI()

-- Горячая клавиша для дисинка (Q)
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Q then
        ToggleDesync()
    end
end)

print("🔥 Vulkan Quantum Desync v4.2 LOADED!")
print("📌 Press Q to toggle desync")
print("📌 Click DESYNC button in GUI")
