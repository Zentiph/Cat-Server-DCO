-- Stats updating by zen

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Checkpoints = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Checkpoints"))
local Gamemodes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Gamemodes"))

local JumpEvent = ReplicatedStorage:WaitForChild("JumpEvent") :: RemoteEvent
local DeathEvent = ReplicatedStorage:WaitForChild("DeathEvent") :: RemoteEvent
local UpdateStatsEvent = ReplicatedStorage:WaitForChild("UpdateStatsEvent") :: RemoteEvent
local UpdateGamemodeEvent = ReplicatedStorage:WaitForChild("UpdateGamemodeEvent") :: RemoteEvent
local UpdateKeybindsEvent = ReplicatedStorage:WaitForChild("UpdateKeybindsEvent") :: RemoteEvent

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

UpdateGamemodeEvent.OnServerEvent:Connect(function(player: Player, newGamemode: Gamemodes.Gamemode)
	player:SetAttribute("Gamemode", newGamemode)
end)

UpdateKeybindsEvent.OnServerEvent:Connect(
	function(
		player: Player,
		saveStateKeybind: string,
		loadStateKeybind: string,
		deleteStateKeybind: string,
		deleteAllStatesKeybind: string,
		quickResetKeybind: string
	)
		player:SetAttribute("SaveStateKeybind", saveStateKeybind)
		player:SetAttribute("LoadStateKeybind", loadStateKeybind)
		player:SetAttribute("DeleteStateKeybind", deleteStateKeybind)
		player:SetAttribute("DeleteAllStatesKeybind", deleteAllStatesKeybind)
		player:SetAttribute("QuickResetKeybind", quickResetKeybind)
	end
)
