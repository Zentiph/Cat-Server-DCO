-- Keybind GUI script by zen

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui

local DataLoadedEvent = ReplicatedStorage:WaitForChild("DataLoadedEvent") :: RemoteEvent
local UpdateKeybindsEvent = ReplicatedStorage:WaitForChild("UpdateKeybindsEvent") :: RemoteEvent

local keybindsFrame = PlayerGui:WaitForChild("ScreenGui"):WaitForChild("Keybinds") :: Frame

local saveStateKeybindButton = keybindsFrame:WaitForChild("SaveStateKeybind") :: TextButton
local loadStateKeybindButton = keybindsFrame:WaitForChild("LoadStateKeybind") :: TextButton
local deleteStateKeybindButton = keybindsFrame:WaitForChild("DeleteStateKeybind") :: TextButton
local deleteAllStatesKeybindButton = keybindsFrame:WaitForChild("DeleteAllStatesKeybind") :: TextButton

local quickResetKeybindButton = keybindsFrame:WaitForChild("QuickResetKeybind") :: TextButton

local resetButton = keybindsFrame:WaitForChild("ResetKeybinds") :: TextButton

local resultLabel = keybindsFrame:WaitForChild("ResultLabel") :: TextLabel

local closeButton = keybindsFrame:WaitForChild("Close") :: TextButton

local keybindListener = nil

local INVALID_KEYBINDS = {
	-- Movement
	Enum.KeyCode.W,
	Enum.KeyCode.A,
	Enum.KeyCode.S,
	Enum.KeyCode.D,
	-- Flip keybind (JToH)
	Enum.KeyCode.F,
}

local usedKeys = {}

local function updateKeybindButtons()
	saveStateKeybindButton.Text = LocalPlayer:GetAttribute("SaveStateKeybind") or "ERROR"
	loadStateKeybindButton.Text = LocalPlayer:GetAttribute("LoadStateKeybind") or "ERROR"
	deleteStateKeybindButton.Text = LocalPlayer:GetAttribute("DeleteStateKeybind") or "ERROR"
	deleteAllStatesKeybindButton.Text = LocalPlayer:GetAttribute("DeleteAllStatesKeybind") or "ERROR"
	quickResetKeybindButton.Text = LocalPlayer:GetAttribute("QuickResetKeybind") or "ERROR"
end

local function updateUsedKeys()
	usedKeys = {}
	usedKeys[saveStateKeybindButton.Text] = true
	usedKeys[loadStateKeybindButton.Text] = true
	usedKeys[deleteStateKeybindButton.Text] = true
	usedKeys[deleteAllStatesKeybindButton.Text] = true
	usedKeys[quickResetKeybindButton.Text] = true
end

for _, button in pairs({
	saveStateKeybindButton,
	loadStateKeybindButton,
	deleteStateKeybindButton,
	deleteAllStatesKeybindButton,
	quickResetKeybindButton,
}) do
	button.MouseButton1Click:Connect(function()
		resultLabel.Text = ""

		if not keybindListener then
			keybindListener = button
			button.Text = "..."
		end
	end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not keybindListener or gameProcessed or input.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end

	for _, keybind in pairs(INVALID_KEYBINDS) do
		if input.KeyCode == keybind then
			updateKeybindButtons()
			updateUsedKeys()
			keybindListener = nil

			resultLabel.TextColor3 = Color3.new(1, 0, 0)
			resultLabel.Text = "That key is already reserved by Roblox."

			return
		end
	end

	for keybind in usedKeys do
		if input.KeyCode == Enum.KeyCode[keybind] then
			updateKeybindButtons()
			updateUsedKeys()
			keybindListener = nil

			resultLabel.TextColor3 = Color3.new(1, 0, 0)
			resultLabel.Text = "That key is currently bound to another action."

			return
		end
	end

	if input.KeyCode == Enum.KeyCode.Escape then
		-- If keybind set canceled, get original one
		keybindListener.Text = LocalPlayer:GetAttribute(keybindListener.Name)
	end

	-- Check for nil again (in case menu was closed)
	if keybindListener == nil then
		return
	end
	keybindListener.Text = input.KeyCode.Name
	keybindListener = nil

	UpdateKeybindsEvent:FireServer(
		saveStateKeybindButton.Text,
		loadStateKeybindButton.Text,
		deleteStateKeybindButton.Text,
		deleteAllStatesKeybindButton.Text,
		quickResetKeybindButton.Text
	)

	resultLabel.TextColor3 = Color3.new(0, 1, 0)
	resultLabel.Text = "Keybind saved!"
end)

resetButton.MouseButton1Click:Connect(function()
	-- Reset to default keybinds
	saveStateKeybindButton.Text = "G"
	loadStateKeybindButton.Text = "R"
	deleteStateKeybindButton.Text = "V"
	deleteAllStatesKeybindButton.Text = "P"
	quickResetKeybindButton.Text = "T"

	updateUsedKeys()
	UpdateKeybindsEvent:FireServer(
		saveStateKeybindButton.Text,
		loadStateKeybindButton.Text,
		deleteStateKeybindButton.Text,
		deleteAllStatesKeybindButton.Text,
		quickResetKeybindButton.Text
	)
end)

closeButton.MouseButton1Click:Connect(function()
	-- End any keybind listening then close and save keybinds
	keybindListener = nil
	keybindsFrame.Visible = false
	updateKeybindButtons()
	updateUsedKeys()
	ContextActionService:UnbindAction("CaptureKeybind")
end)

updateKeybindButtons()
updateUsedKeys()

DataLoadedEvent.OnClientEvent:Connect(function()
	updateKeybindButtons()
	updateUsedKeys()
end)
