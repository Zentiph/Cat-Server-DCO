-- Stats menu GUI by zen

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CloseGui = require(script.Parent:WaitForChild("CloseGui"))

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui

local statsFrame = PlayerGui:WaitForChild("Stats"):WaitForChild("Frame") :: Frame
local resetDataFrame = PlayerGui:WaitForChild("ResetData"):WaitForChild("Frame") :: Frame

local resetDataButton = statsFrame:WaitForChild("ResetData") :: TextButton
local closeButton = statsFrame:WaitForChild("Close") :: TextButton
local versionLabel = statsFrame:WaitForChild("Version") :: TextLabel

versionLabel.Text = `Version: {ReplicatedStorage:WaitForChild("GameVersion").Value}`

resetDataButton.MouseButton1Click:Connect(function()
	-- Open "ARE YOU SURE?" menu
	resetDataFrame.Visible = true
end)

CloseGui:addCloseEvent(closeButton, statsFrame)
