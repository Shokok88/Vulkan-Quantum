-- VULKAN QUANTUM CLONER DESYNC v6.0
-- РАБОЧИЙ ДИСИНК С QUANTUM CLONER

getgenv().Vulkan = {
    DesyncEnabled = false,
    OriginalPosition = nil,
    Clone = nil,
    QuantumCloner = nil
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ПОИСК QUANTUM CLONER В ИНВЕНТАРЕ
function FindQuantumCloner()
    local character = player.Character
    if not character then return nil end
    
    -- Ищем в инвентаре
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if string.lower(tool.Name):find("quantum") or string.lower(tool.Name):find("cloner") then
                return tool
            end
        end
    end
    
    -- Ищем в руках
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and (string.lower(tool.Name):find("quantum") or string.lower(tool.Name):find("cloner")) then
            return tool
        end
    end
    
    return nil
end

-- АКТИВАЦИЯ QUANTUM CLONER
function ActivateQuantumCloner()
    local character = player.Character
    if not character then return false end
    
    -- Ищем клонер
    local cloner = FindQuantumCloner()
    if not cloner then
        warn("❌ Quantum Cloner not found in inventory!")
        return false
    end
    
    getgenv().Vulkan.QuantumCloner = cloner
    
    -- Берем в руки
    cloner.Parent = character
    
    -- Активируем (используем)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:EquipTool(cloner)
        
        -- Имитируем использование
        wait(0.5)
        if cloner:FindFirstChild("Handle") then
            -- Вызываем создание клона через инструмент
            local remote = FindRemoteEvent(cloner)
            if remote then
                remote:FireServer()
            end
        end
    end
    
    return true
end

-- ПОИСК REMOTE EVENT В ИНСТРУМЕНТЕ
function FindRemoteEvent(tool)
    for _, obj in pairs(tool:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            return obj
        end
    end
    return nil
end

-- ОСНОВНОЙ ДИСИНК
function CreateQuantumDesync()
    if not player.Character then return false end
    
    local character = player.Character
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    
    -- Активируем клонер
    if not ActivateQuantumCloner() then
        return false
    end
    
    -- Ждем создания клона игрой
    wait(1)
    
    -- Ищем созданного игрой клона
    local gameClone = FindGameClone()
    if not gameClone then
        warn("❌ Game didn't create clone")
        return false
    end
    
    getgenv().Vulkan.Clone = gameClone
    getgenv().Vulkan.OriginalPosition = root.CFrame
    
    -- Делаем оригинал невидимым
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
            part.CanCollide = false
        end
    end
    
    -- Настраиваем игрового клона (делаем его видимым как "оригинал")
    for _, part in pairs(gameClone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0
            part.Material = Enum.Material.ForceField
            part.Color = Color3.fromRGB(0, 255, 255)
            part.CanCollide = true
        end
    end
    
    -- ПЕРЕМЕЩАЕМ ИГРОКА В ПОЗИЦИЮ КЛОНА
    root.CFrame = gameClone.HumanoidRootPart.CFrame
    
    print("✅ QUANTUM DESYNC ACTIVATED!")
    print("📍 Player moved to clone position")
    print("🎮 Clone is now the visible character")
    
    return true
end

-- ПОИСК КЛОНА СОЗДАННОГО ИГРОЙ
function FindGameClone()
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= player.Character then
            if obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                if string.lower(obj.Name):find("clone") or obj.Name == "QuantumClone" then
                    return obj
                end
            end
        end
    end
    
    -- Если не нашли по имени, ищем любого другого персонажа кроме нашего
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= player.Character then
            if obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                return obj
            end
        end
    end
    
    return nil
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
        if not CreateQuantumDesync() then
            getgenv().Vulkan.DesyncEnabled = false
        end
    end
    UpdateGUI()
end

-- ГУИ
function CreateGUI()
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local TitleBar = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local MinimizeBtn = Instance.new("TextButton")
    local Content = Instance.new("Frame")
    local DesyncButton = Instance.new("TextButton")
    local Status = Instance.new("TextLabel")
    local Info = Instance.new("TextLabel")
    
    ScreenGui.Name = "VulkanQuantumGUI"
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Главное окно
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.4, 0, 0.4, 0)
    MainFrame.Size = UDim2.new(0, 300, 0, 180)
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
    Title.Text = "QUANTUM CLONER DESYNC"
    Title.TextColor3 = Color3.fromRGB(0, 255, 255)
    Title.TextSize = 12
    
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
    DesyncButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    DesyncButton.BorderSizePixel = 0
    DesyncButton.Position = UDim2.new(0.1, 0, 0.1, 0)
    DesyncButton.Size = UDim2.new(0.8, 0, 0, 40)
    DesyncButton.Font = Enum.Font.GothamBold
    DesyncButton.Text = "ACTIVATE QUANTUM DESYNC"
    DesyncButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DesyncButton.TextSize = 12
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = DesyncButton
    
    -- Status
    Status.Name = "Status"
    Status.Parent = Content
    Status.BackgroundTransparency = 1
    Status.Position = UDim2.new(0, 0, 0.4, 0)
    Status.Size = UDim2.new(1, 0, 0, 20)
    Status.Font = Enum.Font.Gotham
    Status.Text = "Requires Quantum Cloner tool"
    Status.TextColor3 = Color3.fromRGB(200, 200, 200)
    Status.TextSize = 11
    
    -- Info
    Info.Name = "Info"
    Info.Parent = Content
    Info.BackgroundTransparency = 1
    Info.Position = UDim2.new(0, 0, 0.6, 0)
    Info.Size = UDim2.new(1, 0, 0, 40)
    Info.Font = Enum.Font.Gotham
    Info.Text = "Uses game's Quantum Cloner tool\nMoves you to clone position\nHotkey: Q"
    Info.TextColor3 = Color3.fromRGB(150, 150, 150)
    Info.TextSize = 10
    Info.TextYAlignment = Enum.TextYAlignment.Top
    
    -- Minimize Function
    local minimized = false
    MinimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            MainFrame.Size = UDim2.new(0, 300, 0, 30)
            Content.Visible = false
        else
            MainFrame.Size = UDim2.new(0, 300, 0, 180)
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
        DesyncButton.Text = "QUANTUM DESYNC ACTIVE"
        Status.Text = "You are now the clone!"
        Status.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        DesyncButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        DesyncButton.Text = "ACTIVATE QUANTUM DESYNC"
        Status.Text = "Requires Quantum Cloner tool"
        Status.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end

-- АКТИВАЦИЯ
if not player.Character then
    player.CharacterAdded:Wait()
end

wait(2)
CreateGUI()

-- Горячая клавиша Q
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Q then
        ToggleDesync()
    end
end)

print("🔥 QUANTUM CLONER DESYNC v6.0 LOADED!")
print("📌 Make sure you have Quantum Cloner tool!")
print("🎮 Press Q to activate")
