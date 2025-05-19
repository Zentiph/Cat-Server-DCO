-- Checkpoint initialization by zen

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Checkpoints = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Checkpoints"))

local RequestTeleportEvent = ReplicatedStorage:WaitForChild("RequestTeleportEvent")

local CHECKPOINT_ANIM_DURATION_SECONDS = 1.4

-- Set up all checkpoints
for _, checkpoint in pairs(Checkpoints.CHECKPOINTS_FOLDER:GetChildren()) do
	-- Set up roman numerals
	local checkpointNumber = tonumber(checkpoint.Name)
	if checkpointNumber then
		local checkpointNumeral = Checkpoints.numberToRoman(checkpointNumber)
		local textLabel = checkpoint:WaitForChild("SurfaceGui"):WaitForChild("TextLabel")
		if textLabel then
			textLabel.Text = checkpointNumeral
		end
	end

	-- Set up touch events
	checkpoint.Touched:Connect(function(hit: Part)
		if not (hit.Parent and hit.Parent:WaitForChild("Humanoid")) then
			return
		end

		local character = hit.Parent
		local player = Players:GetPlayerFromCharacter(character)
		local stage = player.leaderstats.Stage

		-- Only allow player to activate checkpoint if it's the next one
		if checkpointNumber == stage.Value + 1 then
			stage.Value = checkpointNumber
			player.leaderstats.Difficulty.Value = Checkpoints.getDifficultyFromStage(checkpointNumber)

			ReplicatedStorage:WaitForChild("UpdateStageGui"):FireClient(player)

			local originalColor = checkpoint.Color
			local brighterColor = Color3.new(1, 1, 1)

			-- Update farthest progress if this is the farthest so far
			if stage.Value > (player:GetAttribute("FarthestStage") or 0) then
				player:SetAttribute("FarthestStage", stage.Value)
			end

			-- Play sound
			local soundEvent = ReplicatedStorage:WaitForChild("CheckpointSound")
			soundEvent:FireClient(player)

			-- Make white for a brief amount of time
			local tweenInfo =
				TweenInfo.new(0.2 * CHECKPOINT_ANIM_DURATION_SECONDS, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

			local tween = TweenService:Create(checkpoint, tweenInfo, { Color = brighterColor })
			tween:Play()

			-- Revert to original color
			tween.Completed:Connect(function()
				task.delay(0.6 * CHECKPOINT_ANIM_DURATION_SECONDS, function()
					local revertTween = TweenService:Create(checkpoint, tweenInfo, { Color = originalColor })
					revertTween:Play()
				end)
			end)

			-- Create confetti
			local emitters = ReplicatedStorage:WaitForChild("ConfettiEmitters"):GetChildren()
			for i = 1, #emitters do -- Emit all colors
				local chosen = emitters[i]
				local newConfetti = chosen:Clone()
				newConfetti.Parent = checkpoint

				-- Fade away as lifetime diminishes
				newConfetti.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.1, 0),
					NumberSequenceKeypoint.new(0.8, 0),
					NumberSequenceKeypoint.new(1, 1),
				})

				newConfetti:Emit(10)

				task.delay(newConfetti.Lifetime.Min, function()
					newConfetti:Destroy()
				end)
			end
		end
	end)
end

-- On teleport
RequestTeleportEvent.OnServerEvent:Connect(function(player: Player, stageNumber: number)
	if stageNumber <= (tonumber(player:GetAttribute("FarthestStage")) or 0) then
		local leaderstats = player:WaitForChild("leaderstats")
		if not leaderstats then
			warn("Leaderstats not found for player: " .. player.Name)
			return
		end

		leaderstats.Stage.Value = stageNumber
		leaderstats.Difficulty.Value = Checkpoints.getDifficultyFromStage(stageNumber)

		local character = player.Character or player.CharacterAdded:Wait()
		Checkpoints.teleportToCheckpoint(character, stageNumber)
	end
end)
