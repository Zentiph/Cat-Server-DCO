-- Stage GUI script by leo

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UpdateStagesEvent = ReplicatedStorage:WaitForChild("UpdateStagesEvent") :: RemoteEvent

local StageGUI = script.Parent.Parent:WaitForChild("StageGUI")
local TextLabel = StageGUI.Canvas.Frame.TextLabel :: TextLabel

UpdateStagesEvent.OnClientEvent:Connect(function(value: number)
	print(value)
	TextLabel.Text = "Stage: " .. value
end)
