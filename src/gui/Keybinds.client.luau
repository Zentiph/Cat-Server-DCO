-- Keybind GUI script by zen

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui

local DataLoadedEvent = ReplicatedStorage:WaitForChild("DataLoadedEvent") :: RemoteEvent
local UpdateKeybindsEvent = ReplicatedStorage:WaitForChild("UpdateKeybindsEvent") :: RemoteEvent

local keybindsFrame = PlayerGui:WaitForChild("Keybinds"):WaitForChild("Frame") :: Frame

local saveStateKeybindButton = keybindsFrame:WaitForChild("SaveStateKeybind") :: TextButton
local loadStateKeybindButton = keybindsFrame:WaitForChild("LoadStateKeybind") :: TextButton
local deleteStateKeybindButton = keybindsFrame:WaitForChild("DeleteStateKeybind") :: TextButton
local deleteAllStatesKeybindButton = keybindsFrame:WaitForChild("DeleteAllStatesKeybind") :: TextButton

local quickResetKeybindButton = keybindsFrame:WaitForChild("QuickResetKeybind") :: TextButton

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

local function updateKeybindButtons()
	saveStateKeybindButton.Text = LocalPlayer:GetAttribute("SaveStateKeybind") or ""
	loadStateKeybindButton.Text = LocalPlayer:GetAttribute("LoadStateKeybind") or ""
	deleteStateKeybindButton.Text = LocalPlayer:GetAttribute("DeleteStateKeybind") or ""
	deleteAllStatesKeybindButton.Text = LocalPlayer:GetAttribute("DeleteAllStatesKeybind") or ""
	quickResetKeybindButton.Text = LocalPlayer:GetAttribute("QuickResetKeybind") or ""
end

for _, button in pairs({
	saveStateKeybindButton,
	loadStateKeybindButton,
	deleteStateKeybindButton,
	deleteAllStatesKeybindButton,
	quickResetKeybindButton,
}) do
	button.MouseButton1Click:Connect(function()
		if not keybindListener then
			keybindListener = button
			button.Text = "..."
		end
	end)
end

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
	if not keybindListener or gameProcessed or input.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end

	for _, keybind in pairs(INVALID_KEYBINDS) do
		if input.KeyCode == keybind then
			updateKeybindButtons()
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
end)

closeButton.MouseButton1Click:Connect(function()
	-- End any keybind listening then close and save keybinds
	keybindListener = nil
	keybindsFrame.Visible = false
	updateKeybindButtons()
end)

updateKeybindButtons()

DataLoadedEvent.OnClientEvent:Connect(function()
	updateKeybindButtons()
end)
