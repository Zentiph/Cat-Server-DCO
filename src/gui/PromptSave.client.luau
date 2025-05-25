-- Save prompt GUI script by zen

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui

local CloseGui = require(script.Parent:WaitForChild("CloseGui"))

local promptSaveFrame = PlayerGui:WaitForChild("ScreenGui"):WaitForChild("PromptSave") :: Frame

local exitButton = promptSaveFrame:WaitForChild("Exit") :: TextButton
local closeButton = promptSaveFrame:WaitForChild("Close") :: TextButton

local settingsFrame = PlayerGui:WaitForChild("ScreenGui"):WaitForChild("Settings") :: Frame

exitButton.MouseButton1Click:Connect(function()
	-- Close settings without save
	settingsFrame.Visible = false
	promptSaveFrame.Visible = false
end)

CloseGui:addCloseEvent(closeButton, promptSaveFrame)
