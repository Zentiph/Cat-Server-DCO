-- Stats menu GUI by zen

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CloseGui = require(script.Parent:WaitForChild("CloseGui"))

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui

local statsFrame = PlayerGui:WaitForChild("ScreenGui"):WaitForChild("Stats") :: Frame

local closeButton = statsFrame:WaitForChild("Close") :: TextButton
local versionLabel = statsFrame:WaitForChild("Version") :: TextLabel

versionLabel.Text = `Version: {ReplicatedStorage:WaitForChild("GameVersion").Value}`

CloseGui:addCloseEvent(closeButton, statsFrame)
