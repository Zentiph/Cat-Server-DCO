-- Stage teleport GUI script by zen

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Checkpoints = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Checkpoints"))
local CloseGui = require(script.Parent:WaitForChild("CloseGui"))

local UpdateStatsEvent = ReplicatedStorage:WaitForChild("UpdateStatsEvent") :: RemoteEvent

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui

local frame = PlayerGui:WaitForChild("StageSelect"):WaitForChild("Frame") :: Frame
local teleportButton = frame:WaitForChild("Teleport") :: TextButton
local closeButton = frame:WaitForChild("Close") :: TextButton
local textBox = frame:WaitForChild("TextBox") :: TextBox
local errorLog = frame:WaitForChild("ErrorLog") :: TextLabel

local function numberValid(str: string): boolean
	local num = tonumber(str)
	return num ~= nil and num >= Checkpoints.CHECKPOINT_START_VALUE
end

teleportButton.MouseButton1Click:Connect(function()
	local isValid = numberValid(textBox.Text)
	local stage = tonumber(textBox.Text)

	-- Only teleport if the player has been there before
	if stage then
		if LocalPlayer:GetAttribute("FarthestStage") >= stage and isValid then
			local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
			Checkpoints.teleportToCheckpoint(character, stage)
			UpdateStatsEvent:FireServer(stage)

			teleportButton.Parent.Visible = false
			errorLog.Text = ""
		elseif stage < Checkpoints.CHECKPOINT_START_VALUE then
			errorLog.Text = "Please enter a valid stage number."
		elseif stage > 999 then
			errorLog.Text = "Come on now..."
		else
			errorLog.Text = "You have not made it to that stage yet!"
		end
	else
		errorLog.Text = "Please enter a valid number."
	end
end)

CloseGui:addCloseEvent(closeButton, frame)
