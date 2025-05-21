-- Timezone client object script by zen

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Easing = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Easing"))

local LocalPlayer = Players.LocalPlayer
local TimeZones = script.Parent

local DEFAULT_TIME = "14:00:00"
local DEFAULT_TWEEN_DURATION = 3

local activeZones = {}
local activeTween = nil

local function timeStringToNumber(timeString: string): number
	local hours = tonumber(timeString:sub(1, 2)) or 14
	local minutes = tonumber(timeString:sub(4, 5)) or 0
	local seconds = tonumber(timeString:sub(7, 8)) or 0

	return hours + (minutes / 60) + (seconds / 3600)
end

local function tweenClockTime(fromTime: number, toTime: number, duration: number, easingFunction: ((number) -> number)?)
	if activeTween then
		activeTween:Disconnect()
		activeTween = nil
	end

	local elapsed = 0
	local safeEasingFunction = easingFunction or Easing.easeLinear

	-- Normalize times to be within 0-24
	fromTime %= 24
	toTime %= 24

	local forwardDelta = (toTime - fromTime) % 24
	local backwardDelta = (fromTime - toTime) % 24

	local direction = 1
	local durationTime = forwardDelta

	if backwardDelta < forwardDelta then
		direction = -1
		durationTime = backwardDelta
	end

	duration *= durationTime / 12

	activeTween = RunService.RenderStepped:Connect(function(dt: number)
		elapsed = elapsed + dt
		local alpha = math.clamp(elapsed / duration, 0, 1)

		local currentTime = (fromTime + direction * durationTime * safeEasingFunction(alpha)) % 24

		Lighting.ClockTime = currentTime

		if alpha >= 1 then
			activeTween:Disconnect()
			activeTween = nil
		end
	end)
end

-- Apply the highest priority timezone
local function updateTime()
	local highestPriority = -math.huge
	local bestTime = nil

	local easingStyle = "Linear"
	local easingDirection = "InOut"
	local duration = DEFAULT_TWEEN_DURATION

	for model, data in pairs(activeZones) do
		if data.Priority > highestPriority then
			highestPriority = data.Priority
			bestTime = data.TimeOfDay

			local easingConfig = model:FindFirstChild("Easing")
			if not easingConfig then
				continue
			end

			local style = easingConfig:FindFirstChild("Style")
			local direction = easingConfig:FindFirstChild("Direction")
			local durationValue = easingConfig:FindFirstChild("TransitionDuration")

			if style then
				easingStyle = style.Value
			end
			if direction then
				easingDirection = direction.Value
			end
			if durationValue then
				duration = durationValue.Value
			end
		end
	end

	bestTime = bestTime or DEFAULT_TIME
	local targetTime = timeStringToNumber(bestTime)
	local easingFunction = Easing.getEasingFunction(easingStyle, easingDirection)

	-- Only tween if the time difference is noticeable
	if math.abs(Lighting.ClockTime - targetTime) > 0.01 then
		tweenClockTime(Lighting.ClockTime, targetTime, duration, easingFunction)
	end
	Lighting.TimeOfDay = bestTime
end

return function()
	-- Update zones every frame
	RunService.RenderStepped:Connect(function()
		local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then
			return
		end

		local newActiveZones = {}

		for _, model in ipairs(TimeZones:GetChildren()) do
			local priority = model:FindFirstChild("Priority")
			local zonesFolder = model:FindFirstChild("Zones")
			if not priority or not zonesFolder then
				continue
			end

			for _, obj in ipairs(zonesFolder:GetChildren()) do
				if not obj:IsA("BasePart") and obj.Name ~= "Zone" then
					continue
				end

				local localPosition = obj.CFrame:PointToObjectSpace(humanoidRootPart.Position)
				local halfSize = obj.Size / 2

				-- Check if the player is inside the zone
				if
					math.abs(localPosition.X) <= halfSize.X
					and math.abs(localPosition.Y) <= halfSize.Y
					and math.abs(localPosition.Z) <= halfSize.Z
				then
					local timeValue = model:FindFirstChild("TimeOfDay")
					newActiveZones[model] = {
						Priority = priority.Value,
						TimeOfDay = timeValue and timeValue.Value or "14:00:00",
					}
					break
				end
			end
		end

		-- Update only if a change occurred
		local changed = false
		for model in pairs(activeZones) do
			if not newActiveZones[model] then
				changed = true
				break
			end
		end
		if not changed then
			for model in pairs(newActiveZones) do
				if not activeZones[model] then
					changed = true
					break
				end
			end
		end

		if changed then
			activeZones = newActiveZones
			updateTime()
		end
	end)
end
