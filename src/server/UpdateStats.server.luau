-- Stats updating by zen

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Checkpoints = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Checkpoints"))

local JumpEvent = ReplicatedStorage:WaitForChild("JumpEvent")
local DeathEvent = ReplicatedStorage:WaitForChild("DeathEvent")
local UpdateStatsEvent = ReplicatedStorage:WaitForChild("UpdateStatsEvent")

JumpEvent.OnServerEvent:Connect(function(player: Player)
	local jumps = player:GetAttribute("Jumps")
	if jumps then
		player:SetAttribute("Jumps", jumps + 1)
	end
end)

DeathEvent.OnServerEvent:Connect(function(player: Player)
	local deaths = player:GetAttribute("Deaths")
	if deaths then
		player:SetAttribute("Deaths", deaths + 1)
	end
end)

UpdateStatsEvent.OnServerEvent:Connect(function(player: Player, checkpointNumber: number)
	local leaderstats = player:WaitForChild("leaderstats")
	if not leaderstats then
		warn(`Leaderstats not found for player: {player.Name}`)
		return
	end

	leaderstats.Stage.Value = checkpointNumber
	leaderstats.Difficulty.Value = Checkpoints.getDifficultyFromStage(checkpointNumber)
	-- Update farthest progress if this is the farthest so far
	if leaderstats.Stage.Value > (player:GetAttribute("FarthestStage") or 0) then
		player:SetAttribute("FarthestStage", leaderstats.Stage.Value)
	end
end)
