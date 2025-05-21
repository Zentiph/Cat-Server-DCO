-- Datastores and leaderstats by gooodblock, leo, and zen

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Checkpoints = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Checkpoints"))

local checkpointData = DataStoreService:GetDataStore("Player_Checkpoint_Data")

local MAX_RETRIES = 3

-- Load data on player join
Players.PlayerAdded:Connect(function(player: Player)
	local success, data
	local retries = 0

	repeat
		success, data = pcall(function()
			return checkpointData:GetAsync(player.UserId)
		end)

		if not success then
			retries += 1
			task.wait(1)
		end
	until success or retries >= MAX_RETRIES

	if not success then
		error(`Data failed to load after {retries} attempts.`)
	end

	-- Set up leaderstats
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local stage = Instance.new("IntValue")
	stage.Name = "Stage"
	stage.Parent = leaderstats

	local difficulty = Instance.new("StringValue")
	difficulty.Name = "Difficulty"
	difficulty.Parent = leaderstats

	-- Default values
	local currentStage = 0
	local farthestStage = 0
	local jumpCount = 0
	local deathCount = 0

	if data ~= nil then
		currentStage = data.CurrentStage or 0
		farthestStage = data.FarthestStage or currentStage
		jumpCount = data.Jumps or 0
		deathCount = data.Deaths or 0

		print(
			`Data loaded successfully \{CurrentStage: {currentStage}, FarthestStage: {farthestStage}, Jumps: {jumpCount}, Deaths: {deathCount}}.`
		)
	else
		warn("No data was found, using default values.")
	end

	stage.Value = currentStage
	difficulty.Value = Checkpoints.getDifficultyFromStage(currentStage)

	player:SetAttribute("FarthestStage", farthestStage)
	player:SetAttribute("Jumps", jumpCount)
	player:SetAttribute("Deaths", deathCount)

	-- Teleport the player to their last visited checkpoint
	player.CharacterAdded:Connect(function(character: Model)
		task.defer(function()
			Checkpoints.teleportToCheckpoint(character, stage.Value)
		end)
	end)

	-- If the character loaded before the teleport handler was added, manually teleport
	if player.Character then
		task.defer(function()
			Checkpoints.teleportToCheckpoint(player.Character, stage.Value)
		end)
	end
end)

-- Save data on player leave
Players.PlayerRemoving:Connect(function(player: Player)
	local success, _failure
	local retries = 0

	repeat
		success, _failure = pcall(function()
			local leaderstats = player:WaitForChild("leaderstats")

			return checkpointData:SetAsync(player.UserId, {
				CurrentStage = leaderstats.Stage.Value,
				FarthestStage = player:GetAttribute("FarthestStage") or leaderstats.Stage.Value,
				Jumps = player:GetAttribute("Jumps") or 0,
				Deaths = player:GetAttribute("Deaths") or 0,
			})
		end)

		if not success then
			retries += 1
			task.wait(1)
		end
	until success or retries >= MAX_RETRIES

	if not success then
		error(`Data failed to load after {retries} attempts.`)
	end

	if success then
		print("Data saved!")
	end
end)
