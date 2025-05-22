-- By gooodblock and zen

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local DataState = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("DataState"))

local LocalPlayer = Players.LocalPlayer

-- Wait for data to load before accessing keybinds
DataState:WaitUntilLoaded()

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if gameProcessedEvent then
		return
	end

	if input.KeyCode == Enum.KeyCode[LocalPlayer:GetAttribute("QuickResetKeybind")] then
		local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local humanoid = character:FindFirstChild("Humanoid")
		humanoid.Health = 0
	end
end)
