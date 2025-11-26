-- VULKAN WORKING DESYNC v5.0
-- РАБОЧИЙ ДИСИНК С КЛОНОМ

getgenv().Vulkan = {
    DesyncEnabled = false,
    Clone = nil,
    OriginalPosition = nil
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- РАБОЧИЙ ДИСИНК МЕТОД
function CreateWorkingDesync()
    if not player.Character then return end
    
    local character = player.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    
    if not root then return end
    
    -- Сохраняем оригинальную позицию для дисинка
    getgenv().Vulkan.OriginalPosition = root.CFrame
    
    -- Создаем клона который будет видимым
    local clone = character:Clone()
    clone.Name = "DesyncClone"
    
    -- Настраиваем клона (полупрозрачный красный)
    for _, part in pairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0.6
            part.Material = Enum.Material.Neon
            part.Color = Color3.fromRGB(255, 50, 50)
            part.CanCollide = false
        end
    end
    
    -- Убираем оригинального персонажа
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CanCollide = false
        end
    end
    
    clone.Parent = workspace
    getgenv().Vulkan.Clone = clone
    
    -- Двигаем клона вместо оригинала
    local connection
    connection = RunService.Stepped:Connect(function()
        if not getgenv().Vulkan.DesyncEnabled or not clone or not clone.Parent then
            connection:Disconnect()
            return
        end
        
        local cloneRoot = clone:FindFirstChild("HumanoidRootPart")
        local realRoot = character:FindFirstChild("HumanoidRootPart")
        
        if cloneRoot and realRoot then
            -- Клон двигается как игрок
            cloneRoot.CFrame = realRoot.CFrame
            
            -- Оригинал стоит на месте (дисинк)
            realRoot.CFrame = getgenv().Vulkan.OriginalPosition
        end
    end)
    
    print("✅ DESYNC ACTIVATED - Clone is visible, original is desynced")
end

function RemoveDesync()
    local character = player.Character
    if character then
        -- Возвращаем видимость оригиналу
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
    print("❌ DESYNC DEACTIVATED")
end

function ToggleDesync()
    if getgenv().Vulkan.DesyncEnabled then
        RemoveDesync()
    else
        getgenv().Vulkan.DesyncEnabled = true
        CreateWorkingDesync()
    end
    UpdateGUI()
end

-- ГУИ С СВОРАЧИВАНИЕМ
function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local TitleBar = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local MinimizeBtn = Instance.new("TextButton")
    local Content = Instance.new("Frame")
    local DesyncButton = Instance.new("TextButton")
    local Status = Instance.new("TextLabel")
    
    ScreenGui.Name = "VulkanDesyncGUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Главное окно
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.4, 0, 0.4, 0)
    MainFrame.Size = UDim2.new(0, 250, 0, 150)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 0, 0)
    Stroke.Thickness = 2
    Stroke.Parent = MainFrame
    
    -- Title Bar
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar
    
    -- Title
    Title.Name = "Title"
    Title.Parent = TitleBar
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "VULKAN DESYNC v5.0"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    
    -- Minimize Button
    MinimizeBtn.Name = "MinimizeBtn"
    MinimizeBtn.Parent = TitleBar
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MinimizeBtn.BorderSizePixel = 0
    MinimizeBtn.Position = UDim2.new(1, -25, 0, 5)
    MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.Text = "_"
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.TextSize = 12
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = MinimizeBtn
    
    -- Content
    Content.Name = "Content"
    Content.Parent = MainFrame
    Content.BackgroundTransparency = 1
    Content.Position = UDim2.new(0, 0, 0, 30)
    Content.Size = UDim2.new(1, 0, 1, -30)
    
    -- Desync Button
    DesyncButton.Name = "DesyncButton"
    DesyncButton.Parent = Content
    DesyncButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    DesyncButton.BorderSizePixel = 0
    DesyncButton.Position = UDim2.new(0.1, 0, 0.2, 0)
    DesyncButton.Size = UDim2.new(0.8, 0, 0, 40)
    DesyncButton.Font = Enum.Font.GothamBold
    DesyncButton.Text = "DESYNC: OFF"
    DesyncButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DesyncButton.TextSize = 14
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = DesyncButton
    
    -- Status
    Status.Name = "Status"
    Status.Parent = Content
    Status.BackgroundTransparency = 1
    Status.Position = UDim2.new(0, 0, 0.7, 0)
    Status.Size = UDim2.new(1, 0, 0, 20)
    Status.Font = Enum.Font.Gotham
    Status.Text = "Press Q or click button"
    Status.TextColor3 = Color3.fromRGB(200, 200, 200)
    Status.TextSize = 12
    
    -- Minimize Function
    local minimized = false
    MinimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            MainFrame.Size = UDim2.new(0, 250, 0, 30)
            Content.Visible = false
        else
            MainFrame.Size = UDim2.new(0, 250, 0, 150)
            Content.Visible = true
        end
    end)
    
    -- Desync Button Function
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
        Status.Text = "DESYNC ACTIVE - Clone visible"
        Status.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        DesyncButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        DesyncButton.Text = "DESYNC: OFF"
        Status.Text = "Ready - Press Q or click"
        Status.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end

-- АКТИВАЦИЯ
if not player.Character then
    player.CharacterAdded:Wait()
end

wait(1)
CreateGUI()

-- Горячая клавиша Q
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Q then
        ToggleDesync()
    end
end)

print("🔥 VULKAN DESYNC v5.0 LOADED!")
print("🎯 Press Q to toggle desync")
print("📌 Red clone = you, original = desynced")
