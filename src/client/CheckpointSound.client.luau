-- Checkpoint sound event player by zen

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CheckpointSound: Sound = ReplicatedStorage:WaitForChild("CheckpointSound")
local CheckpointSoundEvent: RemoteEvent = ReplicatedStorage:WaitForChild("CheckpointSoundEvent")

CheckpointSoundEvent.OnClientEvent:Connect(function()
	local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	local newSound = CheckpointSound:Clone()
	newSound.Parent = humanoidRootPart
	newSound:Play()

	Debris:AddItem(newSound, newSound.TimeLength + 1) -- Clean up sound
end)
