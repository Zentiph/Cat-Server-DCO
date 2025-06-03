-- Checkpoints module by zen

local Players = game:GetService("Players")

local Checkpoints = {}

Checkpoints.CHECKPOINTS_FOLDER = workspace:WaitForChild("CustomClientObjects"):WaitForChild("Checkpoints")
Checkpoints.CHECKPOINT_START_VALUE = 0

local function updateCamera(cFrame: CFrame)
	local camera = workspace.CurrentCamera

	local originalCameraType = camera.CameraType
	local originalSubject = camera.CameraSubject

	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = cFrame

	task.delay(0.05, function()
		camera.CameraSubject = originalSubject
		camera.CameraType = originalCameraType
	end)
end

--[[
Get the difficulty name of the stage number.

@param stageNumber - The stage number to get the difficulty of
@return The name of the difficulty of the given stage
]]
function Checkpoints.getDifficultyFromStage(stageNumber: number): string
	-- NOTE: Update these values based on when stages end
	if stageNumber == 0 then
		return "Lobby"
	end
	if 1 <= stageNumber and stageNumber <= 10 then
		return "Easy"
	end
	if 11 <= stageNumber and stageNumber <= 20 then
		return "Medium"
	end
	if 21 <= stageNumber and stageNumber <= 30 then
		return "Hard"
	end
	if 31 <= stageNumber and stageNumber <= 40 then
		return "Difficult"
	end
	if 41 <= stageNumber and stageNumber <= 50 then
		return "Challenging"
	end
	if 51 <= stageNumber and stageNumber <= 60 then
		return "Intense"
	end
	if 61 <= stageNumber and stageNumber <= 70 then
		return "Remorseless"
	end
	if 71 <= stageNumber and stageNumber <= 80 then
		return "Insane"
	end
	if 81 <= stageNumber and stageNumber <= 90 then
		return "Extreme"
	end
	if 91 <= stageNumber and stageNumber <= 100 then
		return "Terrifying"
	end
	if 101 <= stageNumber and stageNumber <= 110 then
		return "Catastrophic"
	end
	if 111 <= stageNumber and stageNumber <= 120 then
		return "Horrific"
	end
	if 121 <= stageNumber and stageNumber <= 130 then
		return "Unreal"
	end
	if 131 <= stageNumber and stageNumber <= 140 then
		return "Nil"
	end
	if 141 <= stageNumber and stageNumber <= 150 then
		return "Heart of the Void"
	end
	return "Invalid stage number!"
end

--[[
Teleport the player to a checkpoint number.

@param character - The character of the player to teleport
@param checkpointNumber - The checkpoint number to teleport to
]]
function Checkpoints.teleportToCheckpoint(character: Model, checkpointNumber: number)
	if checkpointNumber < Checkpoints.CHECKPOINT_START_VALUE then
		warn(
			`Checkpoint number ({checkpointNumber}) is less than the start value ({Checkpoints.CHECKPOINT_START_VALUE}), not teleporting.`
		)
		return
	end

	local player = Players:GetPlayerFromCharacter(character)

	if checkpointNumber > (tonumber(player:GetAttribute("FarthestStage")) or 0) then
		return
	end

	local checkpointPart = nil

	-- Find the checkpoint part with the given stage number
	for _, child in pairs(Checkpoints.CHECKPOINTS_FOLDER:GetChildren()) do
		if not child:IsA("BasePart") or child.Name ~= "Checkpoint" then
			continue
		end

		local stageNumber = child:FindFirstChild("StageNumber")
		if not stageNumber or not stageNumber:IsA("IntValue") then
			continue
		end

		if stageNumber.Value == checkpointNumber then
			checkpointPart = child
			break
		end
	end

	if not checkpointPart then
		warn(`Checkpoint part not found for stage {checkpointNumber}`)
		return
	end

	local checkpointCFrame = checkpointPart.CFrame
	local offset = CFrame.new(0, 3, 0) -- Place player a few studs above
	local rotationOffset = CFrame.Angles(0, math.rad(90), 0)

	-- Update player position and orientation to match checkpoint's
	local finalCFrame = checkpointCFrame * rotationOffset * offset

	-- Make character jump to break out of client objects
	local humanoid = character:FindFirstChild("Humanoid") :: Humanoid
	humanoid.Jump = true

	task.wait(0.05) -- Wait for jump first

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") :: Part
	humanoidRootPart.CFrame = finalCFrame
	updateCamera(finalCFrame)
end

local NUMBERS_TO_NUMERALS = {
	{ 1000, "M" },
	{ 900, "CM" },
	{ 500, "D" },
	{ 400, "CD" },
	{ 100, "C" },
	{ 90, "XC" },
	{ 50, "L" },
	{ 40, "XL" },
	{ 10, "X" },
	{ 9, "IX" },
	{ 5, "V" },
	{ 4, "IV" },
	{ 1, "I" },
}

--[[
Convert an integer to a roman numeral.

@param num - Number to convert
@return Roman numeral
]]
function Checkpoints.numberToRoman(num: number): string
	local roman = ""

	for _, pair in ipairs(NUMBERS_TO_NUMERALS) do
		local value, numeral = pair[1], pair[2]
		while num >= value do
			roman ..= numeral
			num -= value
		end
	end

	return roman
end

return Checkpoints
