-- Ensure save GUI script by zen

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui

local CloseGui = require(script.Parent:WaitForChild("CloseGui"))

local UpdateGamemodeEvent = ReplicatedStorage:WaitForChild("UpdateGamemodeEvent") :: RemoteEvent

local ensureSaveFrame = PlayerGui:WaitForChild("ScreenGui"):WaitForChild("EnsureSave") :: Frame

local saveButton = ensureSaveFrame:WaitForChild("Save") :: TextButton
local closeButton = ensureSaveFrame:WaitForChild("Close") :: TextButton

local settingsFrame = PlayerGui:WaitForChild("ScreenGui"):WaitForChild("Settings") :: Frame

saveButton.MouseButton1Click:Connect(function()
	-- Close settings and save gamemode
	UpdateGamemodeEvent:FireServer(settingsFrame:WaitForChild("GamemodeDisplay").Text)

	settingsFrame.Visible = false
	ensureSaveFrame.Visible = false
end)

CloseGui:addCloseEvent(closeButton, ensureSaveFrame)
