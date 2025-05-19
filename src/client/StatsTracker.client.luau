-- Stats tracker by zen

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JumpEvent: RemoteEvent = ReplicatedStorage:WaitForChild("JumpEvent")
local DeathEvent: RemoteEvent = ReplicatedStorage:WaitForChild("DeathEvent")

local LocalPlayer = Players.LocalPlayer

LocalPlayer.CharacterAdded:Connect(function(character: Model)
	local humanoid = character:WaitForChild("Humanoid")

	-- Track jumps
	humanoid.StateChanged:Connect(function(_, newState: Enum.HumanoidStateType)
		if newState == Enum.HumanoidStateType.Jumping then
			JumpEvent:FireServer()
		end
	end)

	-- Track deaths
	humanoid.Died:Connect(function()
		DeathEvent:FireServer()
	end)
end)
