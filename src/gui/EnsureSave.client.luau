-- Ensure save GUI script by zen

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui

local Checkpoints = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Checkpoints"))
local CloseGui = require(script.Parent:WaitForChild("CloseGui"))

local UpdateStatsEvent = ReplicatedStorage:WaitForChild("UpdateStatsEvent") :: RemoteEvent
local UpdateGamemodeEvent = ReplicatedStorage:WaitForChild("UpdateGamemodeEvent") :: RemoteEvent

local ensureSaveFrame = PlayerGui:WaitForChild("ScreenGui"):WaitForChild("EnsureSave") :: Frame

local saveButton = ensureSaveFrame:WaitForChild("Save") :: TextButton
local closeButton = ensureSaveFrame:WaitForChild("Close") :: TextButton

local settingsFrame = PlayerGui:WaitForChild("ScreenGui"):WaitForChild("Settings") :: Frame

saveButton.MouseButton1Click:Connect(function()
	-- Save gamemode, teleport to start, and close settings
	UpdateGamemodeEvent:FireServer(settingsFrame:FindFirstChild("GamemodeDisplay").Text)

	UpdateStatsEvent:FireServer(0)
	Checkpoints.teleportToCheckpoint(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait(), 0)

	settingsFrame.Visible = false
	ensureSaveFrame.Visible = false
end)

CloseGui:addCloseEvent(closeButton, ensureSaveFrame)
