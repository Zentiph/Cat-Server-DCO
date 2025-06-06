-- State saver (all jump tool) by zen

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local DataState = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("DataState"))

local MAX_STATES = 32

local MINIMUM_MARKER_ALPHA = 0.5
local MAXIMUM_MARKER_ALPHA = 0.95
local EXPONENTIAL_GROWTH_FACTOR = 0.25

local TIMEOUT_SECONDS = 0.5

local stateStack = {} -- Stack of saved states
local markerStack = {} -- Stack of corresponding markers

local LocalPlayer = Players.LocalPlayer

local jumpLocked = false
local jumpLockId = 0
local savedJumpPower = 50

-- Use a combination of raycasts and humanoid states to be sure
local function isGrounded(humanoidRootPart: Part)
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local humanoid = character:FindFirstChild("Humanoid") :: Humanoid
	if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
		-- Free-falling, definitely not grounded
		return false
	end

	local origin = humanoidRootPart.Position
	local rayLength = 3.25
	local directions = {
		Vector3.new(0, -rayLength, 0), -- Center
		Vector3.new(1, -rayLength, 0), -- Offset X
		Vector3.new(-1, -rayLength, 0), -- Offset -X
		Vector3.new(0, -rayLength, 1), -- Offset Z
		Vector3.new(0, -rayLength, -1), -- Offset -Z
	}

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = { LocalPlayer.Character }
	params.FilterType = Enum.RaycastFilterType.Exclude

	-- Raycast to below player to check if they're on the ground
	for _, offset in ipairs(directions) do
		if workspace:Raycast(origin + Vector3.new(offset.X, 0, offset.Z), Vector3.new(0, -rayLength, 0), params) then
			return true
		end
	end

	return false
end

local function updateMarkerTransparencies()
	-- Update marker transparency based on recency
	local count = #markerStack
	for i = 1, count do
		-- Exponentially increase transparency (without going fully invisible)
		markerStack[count - i + 1].Transparency = MINIMUM_MARKER_ALPHA
			+ (MAXIMUM_MARKER_ALPHA - MINIMUM_MARKER_ALPHA) * (1 - math.exp(-EXPONENTIAL_GROWTH_FACTOR * i))
	end
end

local function destroyMarker(marker: BasePart)
	-- Flash red quickly
	local flashTween =
		TweenService:Create(marker, TweenInfo.new(0.2, Enum.EasingStyle.Linear), { Color = Color3.new(1, 0, 0) })

	-- Fade out slowly
	local fadeTween = TweenService:Create(
		marker,
		TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Transparency = 1 }
	)

	-- Play tweens and then destroy marker
	flashTween:Play()
	flashTween.Completed:Connect(function()
		fadeTween:Play()
		fadeTween.Completed:Connect(function()
			marker:Destroy()
		end)
	end)
end

-- Wait for data to load before accessing keybinds
DataState:WaitUntilLoaded()

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then
		return
	end

	-- Save current state
	if input.KeyCode == Enum.KeyCode[LocalPlayer:GetAttribute("SaveStateKeybind")] then
		local humanoidRootPart = LocalPlayer.Character:WaitForChild("HumanoidRootPart")
			or LocalPlayer.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local newState = {
			CFrame = humanoidRootPart.CFrame,
			Velocity = humanoidRootPart.Velocity,
			RotVelocity = humanoidRootPart.RotVelocity,
			Grounded = isGrounded(humanoidRootPart),
		}

		-- Clamp number of states
		if #stateStack >= MAX_STATES then
			local oldestMarker = table.remove(markerStack, 1)
			if oldestMarker and oldestMarker:IsDescendantOf(workspace) then
				oldestMarker:Destroy()
			end
			table.remove(stateStack, 1)
		end

		table.insert(stateStack, newState)

		-- Create marker
		local marker = Instance.new("Part")
		-- Make part slightly smaller than torso
		marker.Size = Vector3.new(1.8, 1.8, 0.8)
		marker.CFrame = humanoidRootPart.CFrame
		marker.Anchored = true
		marker.CanCollide = false
		marker.Material = Enum.Material.Neon
		marker.BrickColor = BrickColor.new("Bright green") -- Start green
		marker.Transparency = 1
		marker.Name = "SavedStateMarker"
		marker.Parent = workspace

		-- Fade in and start green, then change to white and correct transparency
		TweenService:Create(
			marker,
			TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{ Transparency = MINIMUM_MARKER_ALPHA }
		):Play()
		TweenService:Create(
			marker,
			TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
			{ Color = Color3.new(1, 1, 1) }
		):Play()

		table.insert(markerStack, marker)

		updateMarkerTransparencies()

	-- Restore most recent state
	elseif input.KeyCode == Enum.KeyCode[LocalPlayer:GetAttribute("LoadStateKeybind")] then
		local state = stateStack[#stateStack] -- Get the most recent saved state
		if not state then
			return
		end

		local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if not humanoidRootPart or not humanoid then
			return
		end

		-- Lock jump
		if not jumpLocked then
			savedJumpPower = humanoid.JumpPower
		end

		humanoid.Jump = false
		humanoid.JumpPower = 0

		jumpLockId += 1
		local currentLockId = jumpLockId
		jumpLocked = true

		-- Reset motion
		humanoidRootPart.Velocity = Vector3.zero
		humanoidRootPart.RotVelocity = Vector3.zero

		-- Wait for a physics frame to apply above
		RunService.Heartbeat:Wait()

		-- Apply saved state
		humanoidRootPart.CFrame = state.CFrame
		humanoidRootPart.Velocity = state.Velocity
		humanoidRootPart.RotVelocity = state.RotVelocity

		local marker = markerStack[#markerStack]
		if marker and marker:IsDescendantOf(workspace) then
			-- Turn blue on state load
			local flashTween = TweenService:Create(
				marker,
				TweenInfo.new(0.2, Enum.EasingStyle.Linear),
				{ Color = Color3.new(0, 0.35, 1) }
			)

			local fadeTween = TweenService:Create(
				marker,
				TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Color = Color3.new(1, 1, 1) }
			)

			flashTween:Play()
			flashTween.Completed:Connect(function()
				fadeTween:Play()
			end)
		end

		-- If not grounded. temporarily block jumping
		if not state.Grounded then
			-- Wait until character is grounded before allowing jumps
			task.spawn(function()
				local startTime = tick()
				while tick() - startTime < TIMEOUT_SECONDS do
					if isGrounded(humanoidRootPart) then
						break
					end
					humanoid.Jump = false
					RunService.Heartbeat:Wait()
				end

				-- Re-enable jumping
				if jumpLockId == currentLockId then
					humanoid.JumpPower = savedJumpPower
					jumpLocked = false
				end
			end)
		else
			-- Already grounded, re-enable jump
			humanoid.JumpPower = savedJumpPower
			jumpLocked = false
		end

	-- Clear most recent state
	elseif input.KeyCode == Enum.KeyCode[LocalPlayer:GetAttribute("DeleteStateKeybind")] then
		if #stateStack > 0 then
			-- Remove state and marker from data
			table.remove(stateStack)
			local marker = table.remove(markerStack)
			if marker and marker:IsDescendantOf(workspace) then
				destroyMarker(marker)
			end

			updateMarkerTransparencies()
		end

	-- Clear all states
	elseif input.KeyCode == Enum.KeyCode[LocalPlayer:GetAttribute("DeleteAllStatesKeybind")] then
		-- Remove all states from the stack
		for _ = 1, #stateStack do
			table.remove(stateStack)
			local marker = table.remove(markerStack)
			if marker and marker:IsDescendantOf(workspace) then
				destroyMarker(marker)
			end
		end

		updateMarkerTransparencies()
	end
end)

-- Block jump if needed
UserInputService.JumpRequest:Connect(function()
	if jumpLocked then
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.JumpPower = 0
			humanoid.Jump = false
		end
	end
end)
