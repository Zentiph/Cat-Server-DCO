-- Reset data GUI script by zen

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CloseGui = require(script.Parent:WaitForChild("CloseGui"))

local ResetStatsEvent = ReplicatedStorage:WaitForChild("ResetStatsEvent") :: RemoteEvent

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui

local frame = PlayerGui:WaitForChild("ResetData"):WaitForChild("Frame") :: Frame

local resetButton = frame:WaitForChild("ResetData") :: TextButton
local closeButton = frame:WaitForChild("Close") :: TextButton

resetButton.MouseButton1Click:Connect(function()
	-- Reset the player's data
	ResetStatsEvent:FireServer()
	-- This will kick the user, so we don't need to do anything else
end)

CloseGui:addCloseEvent(closeButton, frame)
