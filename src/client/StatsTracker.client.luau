-- Stats tracker by zen

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JumpEvent = ReplicatedStorage:WaitForChild("JumpEvent") :: RemoteEvent
local DeathEvent = ReplicatedStorage:WaitForChild("DeathEvent") :: RemoteEvent

local LocalPlayer = Players.LocalPlayer

LocalPlayer.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid

	-- Track jumps
	humanoid.StateChanged:Connect(function(_oldState, newState: Enum.HumanoidStateType)
		if newState == Enum.HumanoidStateType.Jumping then
			JumpEvent:FireServer()
		end
	end)

	-- Track deaths
	humanoid.Died:Connect(function()
		DeathEvent:FireServer()
	end)
end)
