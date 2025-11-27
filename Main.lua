-- VULKAN ULTIMATE DESYNC v10.0
-- ПОЛНЫЙ РАБОЧИЙ КОД ДИСИНКА

--[[
	КОНФИГУРАЦИЯ
--]]
getgenv().VulkanConfig = {
	DesyncEnabled = false,
	Clone = nil,
	OriginalPosition = nil,
	Connections = {},
	GUI = nil,
	Hotkey = Enum.KeyCode.Q,
	CloneColor = Color3.fromRGB(255, 0, 0),
	CloneTransparency = 0.3
}

--[[
	СЕРВИСЫ
--]]
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[[
	ПЕРЕМЕННЫЕ
--]]
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = Workspace.CurrentCamera

--[[
	УТИЛИТЫ
--]]
function VulkanPrint(message)
	print("🔥 VULKAN: " .. message)
end

function VulkanWarn(message)
	warn("⚠️ VULKAN: " .. message)
end

function SafeWait(seconds)
	local start = tick()
	repeat RunService.Heartbeat:Wait() until tick() - start >= seconds
end

--[[
	ОСНОВНЫЕ ФУНКЦИИ ДИСИНКА
--]]
function CreateUltimateDesync()
	-- Проверка персонажа
	if not player or not player.Character then
		VulkanWarn("Player or character not found")
		return false
	end
	
	local character = player.Character
	
	-- Проверка необходимых частей
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	
	if not humanoid then
		VulkanWarn("Humanoid not found in character")
		return false
	end
	
	if not rootPart then
		VulkanWarn("HumanoidRootPart not found")
		return false
	end
	
	if humanoid.Health <= 0 then
		VulkanWarn("Character is dead")
		return false
	end
	
	VulkanPrint("Starting desync creation...")
	
	-- Сохраняем оригинальную позицию
	getgenv().VulkanConfig.OriginalPosition = rootPart.CFrame
	VulkanPrint("Original position saved: " .. tostring(getgenv().VulkanConfig.OriginalPosition))
	
	-- Создаем клона
	VulkanPrint("Cloning character...")
	local clone = character:Clone()
	clone.Name = "VulkanDesyncClone_" .. HttpService:GenerateGUID(false)
	
	-- Очищаем клона от скриптов
	VulkanPrint("Cleaning clone scripts...")
	for _, item in pairs(clone:GetDescendants()) do
		if item:IsA("Script") or item:IsA("LocalScript") then
			item:Destroy()
		end
	end
	
	-- Настраиваем визуал клона
	VulkanPrint("Configuring clone appearance...")
	for _, part in pairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = getgenv().VulkanConfig.CloneTransparency
			part.Material = Enum.Material.Neon
			part.Color = getgenv().VulkanConfig.CloneColor
			part.CanCollide = false
			part.Anchored = false
			
			-- Убираем тени и эффекты
			for _, effect in pairs(part:GetChildren()) do
				if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
					effect:Destroy()
				end
			end
		end
	end
	
	-- Настраиваем человечка клона
	local cloneHumanoid = clone:FindFirstChildOfClass("Humanoid")
	if cloneHumanoid then
		cloneHumanoid.WalkSpeed = humanoid.WalkSpeed
		cloneHumanoid.JumpPower = humanoid.JumpPower
		cloneHumanoid.Health = humanoid.Health
		cloneHumanoid.MaxHealth = humanoid.MaxHealth
		cloneHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end
	
	-- Размещаем клона в мире
	clone.Parent = Workspace
	getgenv().VulkanConfig.Clone = clone
	
	-- Позиционируем клона рядом с оригиналом
	local cloneRoot = clone:FindFirstChild("HumanoidRootPart")
	if cloneRoot then
		cloneRoot.CFrame = rootPart.CFrame * CFrame.new(0, 0, -3)
	end
	
	VulkanPrint("Clone created and positioned")
	
	-- Прячем оригинального персонажа
	VulkanPrint("Hiding original character...")
	for _, part in pairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = 1
			part.CanCollide = false
		end
	end
	
	-- Оставляем небольшую видимость у корневой части для ориентации
	if rootPart then
		rootPart.Transparency = 0.8
		local highlight = Instance.new("SelectionBox")
		highlight.Adornee = rootPart
		highlight.Color3 = Color3.fromRGB(255, 0, 0)
		highlight.Parent = rootPart
		getgenv().VulkanConfig.OriginalHighlight = highlight
	end
	
	VulkanPrint("Original character hidden")
	
	-- Подключаем систему движения
	SetupDesyncMovement(character, clone)
	
	-- Защита от утери клона
	SetupCloneProtection(clone)
	
	VulkanPrint("Ultimate desync activated successfully!")
	return true
end

function SetupDesyncMovement(character, clone)
	VulkanPrint("Setting up desync movement...")
	
	-- Отключаем старые соединения
	if getgenv().VulkanConfig.Connections.Movement then
		getgenv().VulkanConfig.Connections.Movement:Disconnect()
	end
	
	-- Создаем новое соединение для движения
	getgenv().VulkanConfig.Connections.Movement = RunService.Stepped:Connect(function()
		if not getgenv().VulkanConfig.DesyncEnabled then return end
		
		local currentCharacter = player.Character
		local currentClone = getgenv().VulkanConfig.Clone
		local originalPos = getgenv().VulkanConfig.OriginalPosition
		
		if not currentCharacter or not currentClone or not originalPos then return end
		
		local currentRoot = currentCharacter:FindFirstChild("HumanoidRootPart")
		local cloneRoot = currentClone:FindFirstChild("HumanoidRootPart")
		
		if currentRoot and cloneRoot then
			-- Сохраняем оригинальную ориентацию
			local _, y, _ = currentRoot.Orientation.Y, currentRoot.Orientation.Y, currentRoot.Orientation.Z
			
			-- Клон повторяет позицию игрока
			cloneRoot.CFrame = currentRoot.CFrame
			
			-- Игрок остается на месте с сохраненной ориентацией
			currentRoot.CFrame = CFrame.new(originalPos.Position) * CFrame.Angles(0, math.rad(y), 0)
			
			-- Синхронизируем состояние человечка
			SyncHumanoidStates(currentCharacter, currentClone)
		end
	end)
	
	VulkanPrint("Movement system activated")
end

function SyncHumanoidStates(character, clone)
	local charHumanoid = character:FindFirstChildOfClass("Humanoid")
	local cloneHumanoid = clone:FindFirstChildOfClass("Humanoid")
	
	if charHumanoid and cloneHumanoid then
		-- Синхронизируем скорость
		cloneHumanoid.WalkSpeed = charHumanoid.WalkSpeed
		cloneHumanoid.JumpPower = charHumanoid.JumpPower
		
		-- Синхронизируем состояние
		local state = charHumanoid:GetState()
		if state ~= cloneHumanoid:GetState() then
			cloneHumanoid:ChangeState(state)
		end
		
		-- Синхронизируем анимации
		SyncAnimations(charHumanoid, cloneHumanoid)
	end
end

function SyncAnimations(charHumanoid, cloneHumanoid)
	-- Базовая синхронизация анимаций (можно расширить)
	local charAnimator = charHumanoid:FindFirstChildOfClass("Animator")
	local cloneAnimator = cloneHumanoid:FindFirstChildOfClass("Animator")
	
	if charAnimator and cloneAnimator then
		-- Здесь можно добавить синхронизацию конкретных анимаций
	end
end

function SetupCloneProtection(clone)
	VulkanPrint("Setting up clone protection...")
	
	-- Защита от удаления клона
	getgenv().VulkanConfig.Connections.CloneProtection = clone.AncestryChanged:Connect(function()
		if not clone.Parent and getgenv().VulkanConfig.DesyncEnabled then
			VulkanWarn("Clone was removed! Attempting to recreate...")
			
			-- Ждем немного перед восстановлением
			SafeWait(0.5)
			
			if getgenv().VulkanConfig.DesyncEnabled then
				local success = CreateUltimateDesync()
				if success then
					VulkanPrint("Clone successfully recreated!")
				else
					VulkanWarn("Failed to recreate clone")
					RemoveDesync()
				end
				UpdateGUI()
			end
		end
	end)
end

function RemoveDesync()
	VulkanPrint("Removing desync...")
	
	-- Восстанавливаем видимость оригинального персонажа
	local character = player.Character
	if character then
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Transparency = 0
				part.CanCollide = true
			end
		end
		
		-- Убираем хайлайт
		if getgenv().VulkanConfig.OriginalHighlight then
			getgenv().VulkanConfig.OriginalHighlight:Destroy()
			getgenv().VulkanConfig.OriginalHighlight = nil
		end
	end
	
	-- Удаляем клона
	if getgenv().VulkanConfig.Clone then
		getgenv().VulkanConfig.Clone:Destroy()
		getgenv().VulkanConfig.Clone = nil
	end
	
	-- Отключаем все соединения
	for name, connection in pairs(getgenv().VulkanConfig.Connections) do
		if connection then
			connection:Disconnect()
		end
	end
	getgenv().VulkanConfig.Connections = {}
	
	-- Сбрасываем состояние
	getgenv().VulkanConfig.DesyncEnabled = false
	getgenv().VulkanConfig.OriginalPosition = nil
	
	VulkanPrint("Desync completely removed")
end

function ToggleDesync()
	if getgenv().VulkanConfig.DesyncEnabled then
		RemoveDesync()
	else
		getgenv().VulkanConfig.DesyncEnabled = true
		local success = CreateUltimateDesync()
		if not success then
			getgenv().VulkanConfig.DesyncEnabled = false
			VulkanWarn("Failed to activate desync")
		end
	end
	UpdateGUI()
end

--[[
	ГРАФИЧЕСКИЙ ИНТЕРФЕЙС
--]]
function CreateUltimateGUI()
	-- Очистка старого GUI
	if getgenv().VulkanConfig.GUI and getgenv().VulkanConfig.GUI.ScreenGui then
		getgenv().VulkanConfig.GUI.ScreenGui:Destroy()
	end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "VulkanUltimateGUI"
	ScreenGui.Parent = CoreGui
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.ResetOnSpawn = false

	-- Главный контейнер
	local MainContainer = Instance.new("Frame")
	MainContainer.Name = "MainContainer"
	MainContainer.Parent = ScreenGui
	MainContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	MainContainer.BackgroundTransparency = 0.1
	MainContainer.BorderSizePixel = 0
	MainContainer.Position = UDim2.new(0.4, 0, 0.35, 0)
	MainContainer.Size = UDim2.new(0, 320, 0, 200)
	MainContainer.Active = true
	MainContainer.Draggable = true

	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 12)
	MainCorner.Parent = MainContainer

	local MainStroke = Instance.new("UIStroke")
	MainStroke.Color = Color3.fromRGB(255, 50, 50)
	MainStroke.Thickness = 2
	MainStroke.Parent = MainContainer

	-- Эффект тени
	local Shadow = Instance.new("ImageLabel")
	Shadow.Name = "Shadow"
	Shadow.Parent = MainContainer
	Shadow.BackgroundTransparency = 1
	Shadow.Size = UDim2.new(1, 10, 1, 10)
	Shadow.Position = UDim2.new(0, -5, 0, -5)
	Shadow.Image = "rbxassetid://5554237731"
	Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	Shadow.ImageTransparency = 0.8
	Shadow.ScaleType = Enum.ScaleType.Slice
	Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
	Shadow.ZIndex = -1

	-- Панель заголовка
	local TitleBar = Instance.new("Frame")
	TitleBar.Name = "TitleBar"
	TitleBar.Parent = MainContainer
	TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	TitleBar.BorderSizePixel = 0
	TitleBar.Size = UDim2.new(1, 0, 0, 40)

	local TitleCorner = Instance.new("UICorner")
	TitleCorner.CornerRadius = UDim.new(0, 12)
	TitleCorner.Parent = TitleBar

	-- Заголовок
	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Name = "TitleLabel"
	TitleLabel.Parent = TitleBar
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Size = UDim2.new(1, -80, 1, 0)
	TitleLabel.Position = UDim2.new(0, 15, 0, 0)
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.Text = "VULKAN ULTIMATE DESYNC"
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.TextSize = 16
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- Кнопка сворачивания
	local MinimizeButton = Instance.new("TextButton")
	MinimizeButton.Name = "MinimizeButton"
	MinimizeButton.Parent = TitleBar
	MinimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	MinimizeButton.BorderSizePixel = 0
	MinimizeButton.Position = UDim2.new(1, -70, 0, 10)
	MinimizeButton.Size = UDim2.new(0, 25, 0, 20)
	MinimizeButton.Font = Enum.Font.GothamBold
	MinimizeButton.Text = "_"
	MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	MinimizeButton.TextSize = 14

	local MinimizeCorner = Instance.new("UICorner")
	MinimizeCorner.CornerRadius = UDim.new(0, 4)
	MinimizeCorner.Parent = MinimizeButton

	-- Кнопка закрытия
	local CloseButton = Instance.new("TextButton")
	CloseButton.Name = "CloseButton"
	CloseButton.Parent = TitleBar
	CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	CloseButton.BorderSizePixel = 0
	CloseButton.Position = UDim2.new(1, -35, 0, 10)
	CloseButton.Size = UDim2.new(0, 20, 0, 20)
	CloseButton.Font = Enum.Font.GothamBold
	CloseButton.Text = "X"
	CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	CloseButton.TextSize = 12

	local CloseCorner = Instance.new("UICorner")
	CloseCorner.CornerRadius = UDim.new(0, 4)
	CloseCorner.Parent = CloseButton

	-- Контентная область
	local ContentFrame = Instance.new("Frame")
	ContentFrame.Name = "ContentFrame"
	ContentFrame.Parent = MainContainer
	ContentFrame.BackgroundTransparency = 1
	ContentFrame.Position = UDim2.new(0, 0, 0, 40)
	ContentFrame.Size = UDim2.new(1, 0, 1, -40)

	-- Основная кнопка дисинка
	local DesyncButton = Instance.new("TextButton")
	DesyncButton.Name = "DesyncButton"
	DesyncButton.Parent = ContentFrame
	DesyncButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	DesyncButton.BorderSizePixel = 0
	DesyncButton.Position = UDim2.new(0.05, 0, 0.05, 0)
	DesyncButton.Size = UDim2.new(0.9, 0, 0, 50)
	DesyncButton.Font = Enum.Font.GothamBold
	DesyncButton.Text = "DESYNC: OFF"
	DesyncButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	DesyncButton.TextSize = 16

	local ButtonCorner = Instance.new("UICorner")
	ButtonCorner.CornerRadius = UDim.new(0, 8)
	ButtonCorner.Parent = DesyncButton

	local ButtonStroke = Instance.new("UIStroke")
	ButtonStroke.Color = Color3.fromRGB(255, 255, 255)
	ButtonStroke.Thickness = 1
	ButtonStroke.Parent = DesyncButton

	-- Панель статуса
	local StatusFrame = Instance.new("Frame")
	StatusFrame.Name = "StatusFrame"
	StatusFrame.Parent = ContentFrame
	StatusFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	StatusFrame.BorderSizePixel = 0
	StatusFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
	StatusFrame.Size = UDim2.new(0.9, 0, 0, 80)

	local StatusCorner = Instance.new("UICorner")
	StatusCorner.CornerRadius = UDim.new(0, 8)
	StatusCorner.Parent = StatusFrame

	local StatusStroke = Instance.new("UIStroke")
	StatusStroke.Color = Color3.fromRGB(80, 80, 80)
	StatusStroke.Thickness = 1
	StatusStroke.Parent = StatusFrame

	-- Текст статуса
	local StatusLabel = Instance.new("TextLabel")
	StatusLabel.Name = "StatusLabel"
	StatusLabel.Parent = StatusFrame
	StatusLabel.BackgroundTransparency = 1
	StatusLabel.Size = UDim2.new(1, -20, 1, -20)
	StatusLabel.Position = UDim2.new(0, 10, 0, 10)
	StatusLabel.Font = Enum.Font.Gotham
	StatusLabel.Text = "Status: Ready\nHotkey: Q\nVersion: 10.0"
	StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	StatusLabel.TextSize = 12
	StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
	StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
	StatusLabel.TextWrapped = true

	-- ФУНКЦИОНАЛ ГУИ

	-- Сворачивание
	local minimized = false
	MinimizeButton.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			MainContainer.Size = UDim2.new(0, 320, 0, 40)
			ContentFrame.Visible = false
		else
			MainContainer.Size = UDim2.new(0, 320, 0, 200)
			ContentFrame.Visible = true
		end
	end)

	-- Закрытие
	CloseButton.MouseButton1Click:Connect(function()
		ScreenGui:Destroy()
	end)

	-- Кнопка дисинка
	DesyncButton.MouseButton1Click:Connect(function()
		ToggleDesync()
	end)

	-- Эффекты наведения
	DesyncButton.MouseEnter:Connect(function()
		if not getgenv().VulkanConfig.DesyncEnabled then
			TweenService:Create(DesyncButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}):Play()
		end
	end)

	DesyncButton.MouseLeave:Connect(function()
		if not getgenv().VulkanConfig.DesyncEnabled then
			TweenService:Create(DesyncButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}):Play()
		end
	end)

	-- Сохраняем ссылки на элементы GUI
	getgenv().VulkanConfig.GUI = {
		ScreenGui = ScreenGui,
		DesyncButton = DesyncButton,
		StatusLabel = StatusLabel,
		MainContainer = MainContainer,
		ContentFrame = ContentFrame
	}

	VulkanPrint("Ultimate GUI created successfully")
	return ScreenGui
end

function UpdateGUI()
	if not getgenv().VulkanConfig.GUI then return end
	
	local DesyncButton = getgenv().VulkanConfig.GUI.DesyncButton
	local StatusLabel = getgenv().VulkanConfig.GUI.StatusLabel
	
	if getgenv().VulkanConfig.DesyncEnabled then
		DesyncButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
		DesyncButton.Text = "DESYNC: ACTIVE"
		StatusLabel.Text = "Status: DESYNC ACTIVE\n• Red clone is visible\n• Original is desynced\n• Hotkey: Q"
		StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
	else
		DesyncButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
		DesyncButton.Text = "DESYNC: OFF"
		StatusLabel.Text = "Status: Ready\nHotkey: Q\nVersion: 10.0"
		StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	end
end

--[[
	ИНИЦИАЛИЗАЦИЯ СИСТЕМЫ
--]]
function InitializeVulkanSystem()
	VulkanPrint("Initializing Vulkan Ultimate Desync System...")
	
	-- Ожидание загрузки игрока
	if not player then
		VulkanWarn("Player not found, waiting...")
		repeat RunService.Heartbeat:Wait() until player
	end
	
	-- Ожидание загрузки персонажа
	if not player.Character then
		VulkanPrint("Waiting for character...")
		player.CharacterAdded:Wait()
	end
	
	SafeWait(2) -- Даем время на полную загрузку
	
	-- Создание GUI
	VulkanPrint("Creating user interface...")
	CreateUltimateGUI()
	
	-- Настройка горячих клавиш
	VulkanPrint("Setting up hotkeys...")
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if input.KeyCode == getgenv().VulkanConfig.Hotkey then
			ToggleDesync()
		end
	end)
	
	-- Обработка смены персонажа
	player.CharacterAdded:Connect(function(character)
		VulkanPrint("Character added, setting up protection...")
		
		if getgenv().VulkanConfig.DesyncEnabled then
			VulkanPrint("Recreating desync for new character...")
			SafeWait(1)
			RemoveDesync()
			SafeWait(0.5)
			getgenv().VulkanConfig.DesyncEnabled = true
			local success = CreateUltimateDesync()
			if success then
				VulkanPrint("Desync successfully recreated for new character")
			else
				VulkanWarn("Failed to recreate desync for new character")
				getgenv().VulkanConfig.DesyncEnabled = false
			end
			UpdateGUI()
		end
	end)
	
	-- Защита от утери персонажа
	player.CharacterRemoving:Connect(function(character)
		if getgenv().VulkanConfig.DesyncEnabled then
			VulkanPrint("Character removing, cleaning up...")
			RemoveDesync()
		end
	end)
	
	VulkanPrint("========================================")
	VulkanPrint("VULKAN ULTIMATE DESYNC v10.0 LOADED!")
	VulkanPrint("Hotkey: Q")
	VulkanPrint("Features: Advanced Desync, Clone System")
	VulkanPrint("Protection: Auto-recovery, State sync")
	VulkanPrint("========================================")
end

--[[
	АВТОМАТИЧЕСКИЙ ЗАПУСК
--]]
-- Задержка для гарантированной загрузки игры
SafeWait(3)

-- Запуск системы
local success, err = pcall(function()
	InitializeVulkanSystem()
end)

if not success then
	warn("❌ VULKAN CRITICAL ERROR: " .. tostring(err))
	VulkanPrint("Attempting recovery...")
	
	-- Попытка восстановления
	SafeWait(2)
	InitializeVulkanSystem()
end
