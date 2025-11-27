-- VULKAN QUANTUM CLONER DESYNC v11.0
-- ТОЧНАЯ КОПИЯ РАБОЧЕГО СКРИПТА ИЗ ВИДЕО

getgenv().Vulkan = {
    DesyncEnabled = false,
    QuantumCloner = nil,
    Clone = nil,
    OriginalPosition = nil
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ПОИСК QUANTUM CLONER В ИНВЕНТАРЕ
function FindQuantumCloner()
    -- Ищем в бэкпаке
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool.Name == "Quantum Cloner" or string.lower(tool.Name):find("quantum") then
                return tool
            end
        end
    end
    
    -- Ищем в руках персонажа
    local character = player.Character
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name == "Quantum Cloner" or string.lower(tool.Name):find("quantum")) then
                return tool
            end
        end
    end
    
    return nil
end

-- АКТИВАЦИЯ QUANTUM CLONER
function ActivateQuantumCloner()
    local cloner = FindQuantumCloner()
    if not cloner then
        warn("❌ Quantum Cloner not found! Make sure you have the tool.")
        return false
    end
    
    local character = player.Character
    if not character then return false end
    
    -- Берем инструмент в руки
    cloner.Parent = character
    
    -- Ждем немного
    wait(0.2)
    
    -- Активируем инструмент (используем его)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:EquipTool(cloner)
        
        -- Имитируем использование (нажатие)
        wait(0.3)
        
        -- Ищем RemoteEvent для активации
        local remote = FindActivationRemote(cloner)
        if remote then
            remote:FireServer()
            print("✅ Quantum Cloner activated via RemoteEvent")
        else
            -- Если нет RemoteEvent, просто используем инструмент
            mouse = game:GetService("Players").LocalPlayer:GetMouse()
            mouse.Button1Down:Wait()
            mouse.Button1Up:Wait()
            print("✅ Quantum Cloner activated via mouse click")
        end
    end
    
    getgenv().Vulkan.QuantumCloner = cloner
    return true
end

-- ПОИСК REMOTEEVENT ДЛЯ АКТИВАЦИИ
function FindActivationRemote(tool)
    for _, obj in pairs(tool:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            return obj
        end
    end
    return nil
end

-- ПОИСК СОЗДАННОГО ИГРОЙ КЛОНА
function FindGameClone()
    wait(1) -- Даем время на создание клона
    
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj ~= player.Character then
            local humanoid = obj:FindFirstChildOfClass("Humanoid")
            local rootPart = obj:FindFirstChild("HumanoidRootPart")
            
            if humanoid and rootPart then
                -- Ищем клона по имени или по близости
                if obj.Name:find("Clone") or obj.Name:find("Quantum") then
                    return obj
                end
                
                -- Или ищем любого другого персонажа рядом
                local charRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if charRoot and (rootPart.Position - charRoot.Position).Magnitude < 10 then
                    return obj
                end
            end
        end
    end
    return nil
end

-- ОСНОВНАЯ ФУНКЦИЯ ДИСИНКА
function CreateQuantumDesync()
    if not player.Character then return false end
    
    local character = player.Character
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    -- Сохраняем позицию где создается клон
    getgenv().Vulkan.OriginalPosition = rootPart.Position
    
    -- Активируем Quantum Cloner
    if not ActivateQuantumCloner() then
        return false
    end
    
    -- Ищем созданного игрой клона
    local gameClone = FindGameClone()
    if not gameClone then
        warn("❌ Game didn't create a clone")
        return false
    end
    
    getgenv().Vulkan.Clone = gameClone
    print("✅ Game clone found:", gameClone.Name)
    
    -- ДЕЛАЕМ ГЛАВНУЮ ВЕЩЬ: ИГРОК ПЕРЕМЕЩАЕТСЯ В ДРУГОЕ МЕСТО, А КЛОН ОСТАЕТСЯ НА МЕСТЕ
    -- Это создает иллюзию что противник видит клона вместо тебя
    
    -- Телепортируем игрока в случайное место рядом (или туда куда нужно)
    local randomOffset = Vector3.new(
        math.random(-10, 10),
        0,
        math.random(-10, 10)
    )
    
    local newPosition = rootPart.Position + randomOffset
    rootPart.CFrame = CFrame.new(newPosition)
    
    print("🎮 Player teleported to new position")
    print("📍 Clone remains at original position")
    
    -- Настраиваем клона чтобы он выглядел как настоящий игрок
    for _, part in pairs(gameClone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0  -- Делаем полностью видимым
            part.Material = Enum.Material.Plastic
        end
    end
    
    -- Можно добавить эффекты чтобы отличать клона
    local cloneRoot = gameClone:FindFirstChild("HumanoidRootPart")
    if cloneRoot then
        local highlight = Instance.new("Highlight")
        highlight.FillColor = Color3.fromRGB(0, 255, 255)
        highlight.OutlineColor = Color3.fromRGB(0, 200, 255)
        highlight.Parent = gameClone
    end
    
    return true
end

-- ВЫКЛЮЧЕНИЕ ДИСИНКА
function RemoveDesync()
    -- Удаляем клона если он есть
    if getgenv().Vulkan.Clone then
        getgenv().Vulkan.Clone:Destroy()
        getgenv().Vulkan.Clone = nil
    end
    
    -- Возвращаем инструмент в инвентарь
    if getgenv().Vulkan.QuantumCloner then
        getgenv().Vulkan.QuantumCloner.Parent = player.Backpack
        getgenv().Vulkan.QuantumCloner = nil
    end
    
    getgenv().Vulkan.DesyncEnabled = false
    getgenv().Vulkan.OriginalPosition = nil
    
    print("❌ Quantum Desync deactivated")
end

function ToggleDesync()
    if getgenv().Vulkan.DesyncEnabled then
        RemoveDesync()
    else
        getgenv().Vulkan.DesyncEnabled = true
        local success = CreateQuantumDesync()
        if not success then
            getgenv().Vulkan.DesyncEnabled = false
            warn("❌ Failed to activate Quantum Desync")
        end
    end
    UpdateGUI()
end

-- ПРОСТОЙ ГУИ
function CreateSimpleGUI()
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local TitleBar = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
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
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar
    
    -- Title
    Title.Name = "Title"
    Title.Parent = TitleBar
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "QUANTUM DESYNC"
    Title.TextColor3 = Color3.fromRGB(0, 255, 255)
    Title.TextSize = 14
    
    -- Desync Button
    DesyncButton.Name = "DesyncButton"
    DesyncButton.Parent = MainFrame
    DesyncButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    DesyncButton.BorderSizePixel = 0
    DesyncButton.Position = UDim2.new(0.1, 0, 0.25, 0)
    DesyncButton.Size = UDim2.new(0.8, 0, 0, 40)
    DesyncButton.Font = Enum.Font.GothamBold
    DesyncButton.Text = "USE QUANTUM DESYNC"
    DesyncButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DesyncButton.TextSize = 12
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = DesyncButton
    
    -- Status
    Status.Name = "Status"
    Status.Parent = MainFrame
    Status.BackgroundTransparency = 1
    Status.Position = UDim2.new(0, 10, 0.55, 0)
    Status.Size = UDim2.new(1, -20, 0, 20)
    Status.Font = Enum.Font.Gotham
    Status.Text = "Requires Quantum Cloner tool"
    Status.TextColor3 = Color3.fromRGB(200, 200, 200)
    Status.TextSize = 11
    
    -- Info
    Info.Name = "Info"
    Info.Parent = MainFrame
    Info.BackgroundTransparency = 1
    Info.Position = UDim2.new(0, 10, 0.7, 0)
    Info.Size = UDim2.new(1, -20, 0, 40)
    Info.Font = Enum.Font.Gotham
    Info.Text = "• Uses Quantum Cloner tool\n• Creates decoy clone\n• You teleport away\n• Enemies see the clone"
    Info.TextColor3 = Color3.fromRGB(150, 150, 150)
    Info.TextSize = 10
    Info.TextYAlignment = Enum.TextYAlignment.Top
    
    -- Button functionality
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
        Status.Text = "Clone created - You are hidden"
        Status.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        DesyncButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        DesyncButton.Text = "USE QUANTUM DESYNC"
        Status.Text = "Requires Quantum Cloner tool"
        Status.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end

-- АКТИВАЦИЯ
if not player.Character then
    player.CharacterAdded:Wait()
end

wait(2)
CreateSimpleGUI()

-- Горячая клавиша
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Q then
        ToggleDesync()
    end
end)

print("🔥 QUANTUM DESYNC v11.0 LOADED!")
print("📌 You NEED Quantum Cloner tool for this to work!")
print("🎮 Press Q to activate")
print("💡 Creates clone at your position, teleports you away")
