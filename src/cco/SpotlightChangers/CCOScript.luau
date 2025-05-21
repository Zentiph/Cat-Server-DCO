-- Spotlight client object script by zen

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Easing = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Easing"))

local LocalPlayer = Players.LocalPlayer

local SpotlightToggleEvent = ReplicatedStorage:WaitForChild("SpotlightToggleEvent") :: RemoteEvent

local RIG_NAMES = { "MoonRig", "MoonBounceRig", "MoonBounceFarRig" }

local enabled = false
local connection = nil
local currentTweens = {}

local moonRig = Instance.new("Part")
moonRig.Name = "MoonRig"
moonRig.Anchored = true
moonRig.CanCollide = false
moonRig.Transparency = 1
moonRig.Size = Vector3.new(1, 1, 1)
moonRig.Orientation = Vector3.new(-90, 0, 0)
moonRig.Parent = workspace

local moonLight = Instance.new("SpotLight")
moonLight.Brightness = 0
moonLight.Range = 1000
moonLight.Angle = 120
moonLight.Shadows = false
moonLight.Color = Color3.fromRGB(220, 230, 255)
moonLight.Parent = moonRig

local moonBounceRig = moonRig:Clone()
moonBounceRig.Name = "MoonBounceRig"
moonBounceRig.Parent = workspace

local moonBounce = moonLight:Clone()
moonBounce.Parent = moonBounceRig

local moonBounceFarRig = moonBounceRig:Clone()
moonBounceFarRig.Name = "MoonBounceFarRig"
moonBounceFarRig.Parent = workspace

local moonBounceFar = moonBounce:Clone()
moonBounceFar.Parent = moonBounceFarRig

local function animateBrightness(
	target: number,
	duration: number,
	easingStyle: string,
	easingDirection: string,
	disableAfter: boolean?
)
	local info = Easing.toTweenInfo(easingStyle, easingDirection, duration)

	-- Cancel existing light tweens
	for _, tween in pairs(currentTweens) do
		tween:Cancel()
	end

	if connection then
		connection:Disconnect()
		connection = nil
	end

	currentTweens = {
		TweenService:Create(moonLight, info, { Brightness = target }),
		TweenService:Create(moonBounce, info, { Brightness = target / 2 }),
		TweenService:Create(moonBounceFar, info, { Brightness = target / 1.5 }),
	}

	for _, tween in pairs(currentTweens) do
		tween:Play()
	end

	if disableAfter then
		connection = currentTweens[1].Completed:Connect(function()
			for _, name in RIG_NAMES do
				local rig = workspace:WaitForChild(name)
				local light = rig and rig:FindFirstChildWhichIsA("SpotLight")
				if light then
					light.Enabled = false
					light.Brightness = 0
				end
			end

			currentTweens = {}
			connection = nil
		end)
	end
end

local function setSpotlightActiveState(state: boolean, duration: number, easingStyle: string?, easingDirection: string?)
	enabled = state

	if state then
		for _, name in RIG_NAMES do
			local rig = workspace:FindFirstChild(name)
			local light = rig and rig:FindFirstChildWhichIsA("SpotLight")
			if light then
				light.Enabled = true
			end
		end
	end

	-- If on, set target brightness to 2, otherwise set target to 0
	local brightnessTarget = state and 2 or 0
	task.spawn(function()
		animateBrightness(brightnessTarget, duration, easingStyle or "Linear", easingDirection or "InOut", not state)
	end)
end

local function playerTouched(touch: BasePart): boolean
	if not touch.Parent then
		return false
	end
	-- If the player touched this part, return true
	return Players:GetPlayerFromCharacter(touch.Parent) == LocalPlayer
end

local function addTouchEvent(part: BasePart)
	local debounce = false

	local easingConfig = part:WaitForChild("Easing")
	if not easingConfig or not easingConfig:IsA("Configuration") then
		return
	end

	local easingStyle = easingConfig:WaitForChild("Style")
	local easingDirection = easingConfig:WaitForChild("Direction")
	local duration = easingConfig:WaitForChild("TransitionDuration")

	if
		not (easingStyle and easingDirection and duration)
		or not easingStyle:IsA("StringValue")
		or not easingDirection:IsA("StringValue")
		or not duration:IsA("NumberValue")
	then
		return
	end

	if part.Name == "SpotlightActivator" then
		part.Touched:Connect(function(hit: BasePart)
			if not debounce and playerTouched(hit) then
				debounce = true
				setSpotlightActiveState(true, duration.Value, easingStyle.Value, easingDirection.Value)
				task.delay(0.25, function()
					debounce = false
				end)
			end
		end)
	elseif part.Name == "SpotlightDeactivator" then
		part.Touched:Connect(function(hit: BasePart)
			if not debounce and playerTouched(hit) then
				debounce = true
				setSpotlightActiveState(false, duration.Value, easingStyle.Value, easingDirection.Value)
				task.delay(0.25, function()
					debounce = false
				end)
			end
		end)
	end
end

local function setUpRuntime()
	RunService.RenderStepped:Connect(function()
		if not enabled then
			return
		end

		local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local humanoidRootPart = character and character:WaitForChild("HumanoidRootPart")
		if not humanoidRootPart then
			return
		end

		moonRig.Position = humanoidRootPart.Position + Vector3.new(0, 50, 0)
		moonBounceRig.Position = humanoidRootPart.Position + Vector3.new(0, 15, 0)
		moonBounceFarRig.Position = humanoidRootPart.Position - Vector3.new(0, 20, 0)
	end)

	SpotlightToggleEvent.Event:Connect(setSpotlightActiveState)
end

return function()
	setUpRuntime()

	-- Listen for new parts and bind them to the event
	script.Parent.ChildAdded:Connect(function(child: Instance)
		if not child:IsA("BasePart") then
			return
		end

		child.Transparency = 1
		addTouchEvent(child)
	end)

	-- Bind existing children to touch event
	for _, obj in pairs(script.Parent:GetChildren()) do
		if obj:IsA("BasePart") then
			obj.Transparency = 1
			addTouchEvent(obj)
		end
	end
end
