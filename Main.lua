-- VULKAN SIMPLE DESYNC v7.0
-- ПРОСТОЙ РАБОЧИЙ ДИСИНК

getgenv().Vulkan = {
    DesyncEnabled = false,
    Clone = nil,
    OriginalPosition = nil
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ПРОСТОЙ ДИСИНК
function CreateDesync()
    if not player.Character then return end
    
    local character = player.Character
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- Сохраняем позицию
    getgenv().Vulkan.OriginalPosition = root.CFrame
    
    -- Создаем клона
    local clone = character:Clone()
    clone.Name = "DesyncClone"
    clone.Parent = workspace
    
    -- Делаем клона видимым
    for _, part in pairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0
            part.Material = Enum.Material.Neon
            part.Color = Color3.fromRGB(255, 0, 0)
        end
    end
    
    -- Делаем оригинал невидимым
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 1
        end
    end
    
    getgenv().Vulkan.Clone = clone
    
    -- Двигаем клона вместо игрока
    RunService.Stepped:Connect(function()
        if not getgenv().Vulkan.DesyncEnabled then return end
        
        local cloneRoot = clone:FindFirstChild("HumanoidRootPart")
        local realRoot = character:FindFirstChild("HumanoidRootPart")
        
        if cloneRoot and realRoot then
            -- Клон двигается
            cloneRoot.CFrame = realRoot.CFrame
            -- Оригинал стоит на месте
            realRoot.CFrame = getgenv().Vulkan.OriginalPosition
        end
    end)
    
    print("✅ DESYNC ACTIVATED")
end

function RemoveDesync()
    local character = player.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
            end
        end
    end
    
    if getgenv().Vulkan.Clone then
        getgenv().Vulkan.Clone:Destroy()
    end
    
    getgenv().Vulkan.DesyncEnabled = false
    print("❌ DESYNC DEACTIVATED")
end

function ToggleDesync()
    if getgenv().Vulkan.DesyncEnabled then
        RemoveDesync()
    else
        getgenv().Vulkan.DesyncEnabled = true
        CreateDesync()
    end
end

-- ГУИ
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Button = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.Position = UDim2.new(0.4, 0, 0.4, 0)
Frame.Size = UDim2.new(0, 200, 0, 50)
Frame.Active = true
Frame.Draggable = true

Button.Parent = Frame
Button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Button.Size = UDim2.new(1, 0, 1, 0)
Button.Text = "DESYNC: OFF"
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.TextSize = 14

Button.MouseButton1Click:Connect(function()
    ToggleDesync()
    if getgenv().Vulkan.DesyncEnabled then
        Button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        Button.Text = "DESYNC: ON"
    else
        Button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        Button.Text = "DESYNC: OFF"
    end
end)

-- Горячая клавиша
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Q then
        ToggleDesync()
        if getgenv().Vulkan.DesyncEnabled then
            Button.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            Button.Text = "DESYNC: ON"
        else
            Button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            Button.Text = "DESYNC: OFF"
        end
    end
end)

print("🔥 VULKAN DESYNC LOADED")
print("🎯 Press Q to toggle desync")
