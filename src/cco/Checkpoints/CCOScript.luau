-- Checkpoint client object script by zen

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Checkpoints = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Checkpoints"))

local CheckpointSound = ReplicatedStorage:WaitForChild("CheckpointSound") :: Sound
local UpdateStatsEvent = ReplicatedStorage:WaitForChild("UpdateStatsEvent") :: RemoteEvent

local CheckpointsFolder = script.Parent.Parent

local debounceArray = {}

local CHECKPOINT_ANIM_DURATION_SECONDS = 1.4

local function tweenCheckpointColor(checkpoint: BasePart)
	local originalColor = checkpoint.Color

	-- Make white for a brief amount of time
	local tweenInfo =
		TweenInfo.new(0.2 * CHECKPOINT_ANIM_DURATION_SECONDS, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local tween = TweenService:Create(checkpoint, tweenInfo, { Color = Color3.new(1, 1, 1) })
	tween:Play()

	-- Revert to original color
	tween.Completed:Connect(function()
		task.delay(0.6 * CHECKPOINT_ANIM_DURATION_SECONDS, function()
			local revertTween = TweenService:Create(checkpoint, tweenInfo, { Color = originalColor })
			revertTween:Play()
		end)
	end)
end

local function spawnConfetti(checkpoint: BasePart)
	local emitters = ReplicatedStorage:WaitForChild("ConfettiEmitters"):GetChildren()
	for i = 1, #emitters do -- Emit all colors
		local newConfetti = emitters[i]:Clone()
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

local function setNameToRoman(checkpoint: BasePart)
	local checkpointNumber = checkpoint:WaitForChild("StageNumber")
	if not checkpointNumber or not checkpointNumber:IsA("IntValue") then
		warn(`StageNumber not found or not an IntValue in {checkpoint.Name}`)
		return
	end

	local checkpointNumeral = Checkpoints.numberToRoman(checkpointNumber.Value)
	local surfaceGui = checkpoint:FindFirstChild("SurfaceGui")
	local textLabel = surfaceGui and surfaceGui:WaitForChild("TextLabel")

	if not textLabel then
		warn(`TextLabel not found in SurfaceGui of {checkpoint.Name}`)
	end

	textLabel.Text = checkpointNumeral
end

local function addTouchEvent(checkpoint: BasePart)
	debounceArray[checkpoint] = false

	checkpoint.Touched:Connect(function(hit: BasePart)
		if debounceArray[checkpoint] then
			return
		end

		local character = hit.Parent

		if not character or not character:WaitForChild("Humanoid") then
			return
		end

		local player = Players:GetPlayerFromCharacter(character)
		if not player then
			return
		end

		local leaderstats = player:WaitForChild("leaderstats")
		if not leaderstats then
			warn(`Leaderstats not found for player: {player.Name}`)
			return
		end

		local stage = leaderstats.Stage
		if not stage or not stage:IsA("IntValue") then
			warn(`Stage not found or not an IntValue in leaderstats of {player.Name}`)
			return
		end

		local checkpointNumber = checkpoint:WaitForChild("StageNumber")
		if not checkpointNumber or not checkpointNumber:IsA("IntValue") then
			warn(`StageNumber not found or not an IntValue in {checkpoint.Name}`)
			return
		end

		-- Only allow player to activate checkpoint if it's the next one
		if checkpointNumber.Value == stage.Value + 1 then
			debounceArray[checkpoint] = true

			UpdateStatsEvent:FireServer(checkpointNumber.Value)

			CheckpointSound:Play()
			tweenCheckpointColor(checkpoint)
			spawnConfetti(checkpoint)

			task.delay(CHECKPOINT_ANIM_DURATION_SECONDS, function()
				debounceArray[checkpoint] = false
			end)
		end
	end)
end

return function()
	if not CheckpointsFolder then
		warn("Checkpoint CCOScript parent not found")
		return
	end

	-- Listen for new parts and bind them to the event
	CheckpointsFolder.ChildAdded:Connect(function(child: Instance)
		if not child:IsA("BasePart") then
			return
		end

		setNameToRoman(child)
		addTouchEvent(child)
	end)

	-- Bind existing children to touch event
	for _, obj in pairs(CheckpointsFolder:GetChildren()) do
		if obj:IsA("BasePart") then
			setNameToRoman(obj)
			addTouchEvent(obj)
		end
	end
end
