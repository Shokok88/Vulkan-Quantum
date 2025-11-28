-- Luarmor Protected Script v3
-- Loader ID: 49abdfcd1ce9ec893553a573b9348ca3
-- Security: Enabled
-- Date: 2024

(function()
    local Luarmor_Key = "49abdfcd1ce9ec893553a573b9348ca3"
    local Luarmor_Version = "3.0"
    
    -- Security check
    if not isLuarmorValid(Luarmor_Key) then
        error("Luarmor Security: Invalid Key")
        return
    end
    
    -- Main script content
    local Script_Main = [[
        -- Quantum Desync Script
        getgenv().QuantumDesync = {
            Enabled = false,
            Clone = nil,
            OriginalPosition = nil,
            Connections = {}
        }
        
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local UserInputService = game:GetService("UserInputService")
        
        local player = Players.LocalPlayer
        
        -- Create Desync Function
        function CreateDesync()
            if not player.Character then return false end
            
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if not humanoid or not rootPart then return false end
            
            -- Save original position
            QuantumDesync.OriginalPosition = rootPart.CFrame
            
            -- Create clone
            local clone = character:Clone()
            clone.Name = "QuantumDesyncClone"
            clone.Parent = workspace
            
            -- Make original invisible
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 1
                    part.CanCollide = false
                end
            end
            
            -- Style clone
            for _, part in pairs(clone:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0.5
                    part.Material = Enum.Material.Neon
                    part.Color = Color3.fromRGB(0, 255, 255)
                    part.CanCollide = false
                end
            end
            
            QuantumDesync.Clone = clone
            
            -- Movement sync
            QuantumDesync.Connections.Movement = RunService.Stepped:Connect(function()
                if not QuantumDesync.Enabled then return end
                
                local currentChar = player.Character
                local currentClone = QuantumDesync.Clone
                
                if not currentChar or not currentClone then return end
                
                local charRoot = currentChar:FindFirstChild("HumanoidRootPart")
                local cloneRoot = currentClone:FindFirstChild("HumanoidRootPart")
                
                if charRoot and cloneRoot then
                    -- Clone follows movements
                    cloneRoot.CFrame = charRoot.CFrame
                    -- Original stays in place
                    charRoot.CFrame = QuantumDesync.OriginalPosition
                end
            end)
            
            return true
        end
        
        -- Remove Desync
        function RemoveDesync()
            local character = player.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 0
                        part.CanCollide = true
                    end
                end
            end
            
            if QuantumDesync.Clone then
                QuantumDesync.Clone:Destroy()
                QuantumDesync.Clone = nil
            end
            
            for _, conn in pairs(QuantumDesync.Connections) do
                conn:Disconnect()
            end
            QuantumDesync.Connections = {}
            
            QuantumDesync.Enabled = false
        end
        
        -- Toggle Desync
        function ToggleDesync()
            if QuantumDesync.Enabled then
                RemoveDesync()
            else
                QuantumDesync.Enabled = true
                if not CreateDesync() then
                    QuantumDesync.Enabled = false
                end
            end
        end
        
        -- GUI
        local screenGui = Instance.new("ScreenGui")
        screenGui.Parent = game.CoreGui
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 200, 0, 60)
        frame.Position = UDim2.new(0.4, 0, 0.4, 0)
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        frame.Active = true
        frame.Draggable = true
        frame.Parent = screenGui
        
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.9, 0, 0.7, 0)
        button.Position = UDim2.new(0.05, 0, 0.15, 0)
        button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        button.Text = "QUANTUM DESYNC: OFF"
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 12
        button.Parent = frame
        
        button.MouseButton1Click:Connect(function()
            ToggleDesync()
            button.BackgroundColor3 = QuantumDesync.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            button.Text = QuantumDesync.Enabled and "QUANTUM DESYNC: ON" or "QUANTUM DESYNC: OFF"
        end)
        
        -- Hotkey
        UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Q then
                ToggleDesync()
                button.BackgroundColor3 = QuantumDesync.Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                button.Text = QuantumDesync.Enabled and "QUANTUM DESYNC: ON" or "QUANTUM DESYNC: OFF"
            end
        end)
        
        print("Quantum Desync Loaded - Press Q to toggle")
    ]]
    
    -- Execute main script
    local success, err = pcall(function()
        loadstring(Script_Main)()
    end)
    
    if not success then
        warn("Luarmor Execution Error: " .. err)
    end
end)()
