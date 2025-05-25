-- Settings GUI script by zen

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Gamemodes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Gamemodes"))

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui

local DataLoadedEvent = ReplicatedStorage:WaitForChild("DataLoadedEvent") :: RemoteEvent
local UpdateGamemodeEvent = ReplicatedStorage:WaitForChild("UpdateGamemodeEvent") :: RemoteEvent

local settingsFrame = PlayerGui:WaitForChild("ScreenGui"):WaitForChild("Settings") :: Frame

local gamemodeLeftButton = settingsFrame:WaitForChild("GamemodeLeft") :: TextButton
local gamemodeRightButton = settingsFrame:WaitForChild("GamemodeRight") :: TextButton
local gamemodeLabel = settingsFrame:WaitForChild("GamemodeDisplay") :: TextLabel

local setKeybindsButton = settingsFrame:WaitForChild("SetKeybinds") :: TextButton
local applySettingsButton = settingsFrame:WaitForChild("Apply") :: TextButton

local resetDataButton = settingsFrame:WaitForChild("ResetData") :: TextButton
local closeButton = settingsFrame:WaitForChild("Close") :: TextButton

local keybindsFrame = PlayerGui:WaitForChild("ScreenGui"):WaitForChild("Keybinds") :: Frame
local promptSaveFrame = PlayerGui:WaitForChild("ScreenGui"):WaitForChild("PromptSave") :: Frame
local ensureSaveFrame = PlayerGui:WaitForChild("ScreenGui"):WaitForChild("EnsureSave") :: Frame
local resetDataFrame = PlayerGui:WaitForChild("ScreenGui"):WaitForChild("ResetData") :: Frame

gamemodeLeftButton.MouseButton1Click:Connect(function()
	-- Change gamemode to the previous one
	local currentGamemode = gamemodeLabel.Text
	local newGamemode = Gamemodes.getPreviousGamemode(currentGamemode)
	gamemodeLabel.Text = newGamemode
end)

gamemodeRightButton.MouseButton1Click:Connect(function()
	-- Change gamemode to the previous one
	local currentGamemode = gamemodeLabel.Text
	local newGamemode = Gamemodes.getNextGamemode(currentGamemode)
	gamemodeLabel.Text = newGamemode
end)

setKeybindsButton.MouseButton1Click:Connect(function()
	-- Open keybinds menu
	keybindsFrame.Visible = true
end)

applySettingsButton.MouseButton1Click:Connect(function()
	-- Warn player about reset if gamemode changed to a different one (other than normal)
	if
		gamemodeLabel.Text ~= LocalPlayer:GetAttribute("Gamemode")
		and gamemodeLabel.Text ~= Gamemodes.Gamemode.Normal
	then
		ensureSaveFrame.Visible = true
	else
		UpdateGamemodeEvent:FireServer(settingsFrame:WaitForChild("GamemodeDisplay").Text)

		settingsFrame.Visible = false
	end
end)

resetDataButton.MouseButton1Click:Connect(function()
	-- Open "ARE YOU SURE?" menu
	resetDataFrame.Visible = true
end)

closeButton.MouseButton1Click:Connect(function()
	-- If unsaved changes, prompt the user to save
	if gamemodeLabel.Text ~= LocalPlayer:GetAttribute("Gamemode") then
		promptSaveFrame.Visible = true
	else
		settingsFrame.Visible = false
	end
end)

-- Set up initial values after player data loaded
DataLoadedEvent.OnClientEvent:Connect(function()
	local currentGamemode = LocalPlayer:GetAttribute("Gamemode") :: string
	if currentGamemode then
		gamemodeLabel.Text = currentGamemode
	else
		error("Gamemode attribute not found.")
	end
end)
