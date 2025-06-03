-- Heal event script by zen

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HealEvent = ReplicatedStorage:WaitForChild("HealEvent") :: RemoteEvent

local debounceArray = {}

HealEvent.OnServerEvent:Connect(function(player, amount: number)
	if debounceArray[player.Name] then
		return
	end

	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character and character:WaitForChild("Humanoid") :: Humanoid
	if not humanoid then
		return
	end

	-- Make sure the player doesn't heal more than their max HP
	humanoid.Health = math.clamp(humanoid.Health + amount, 0, humanoid.MaxHealth)
	task.delay(0.1, function()
		debounceArray[player.Name] = nil
	end)
end)
