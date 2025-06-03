-- Spotlight client object script by zen

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local SpotlightToggleEvent = ReplicatedStorage:WaitForChild("SpotlightToggleEvent") :: RemoteEvent

local LocalPlayer = Players.LocalPlayer

local SpotlightChangers = script.Parent.Parent

local RIG_NAMES = { "MoonRig", "MoonBounceRig", "MoonBounceFarRig" }

local enabled = false
local connection = nil
local currentTweens = {}
local debounceArray = {}

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

local moonBounceFarRig = moonRig:Clone()
moonBounceFarRig.Name = "MoonBounceFarRig"
moonBounceFarRig.Parent = workspace

local moonBounceFar = moonLight:Clone()
moonBounceFar.Parent = moonBounceFarRig

local function animateBrightness(target: number, duration: number, disableAfter: boolean?)
	local info = TweenInfo.new(duration, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

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
				local rig = workspace:FindFirstChild(name)
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

local function setSpotlightActiveState(state: boolean, duration: number)
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
		animateBrightness(brightnessTarget, duration, not state)
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
	debounceArray[part] = false

	local duration = part:FindFirstChild("TransitionDuration") :: NumberValue

	if part.Name == "SpotlightActivator" then
		part.Touched:Connect(function(hit: BasePart)
			if not debounceArray[part] and playerTouched(hit) then
				debounceArray[part] = true
				setSpotlightActiveState(true, duration.Value)
				task.delay(0.1, function()
					debounceArray[part] = false
				end)
			end
		end)
	elseif part.Name == "SpotlightDeactivator" then
		part.Touched:Connect(function(hit: BasePart)
			if not debounceArray[part] and playerTouched(hit) then
				debounceArray[part] = true
				setSpotlightActiveState(false, duration.Value)
				task.delay(0.1, function()
					debounceArray[part] = false
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

		local character = LocalPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
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
	SpotlightChangers.ChildAdded:Connect(function(child: Instance)
		if not child:IsA("BasePart") then
			return
		end

		child.Transparency = 1
		addTouchEvent(child)
	end)

	-- Bind existing children to touch event
	for _, child in pairs(SpotlightChangers:GetChildren()) do
		if child:IsA("BasePart") then
			child.Transparency = 1
			addTouchEvent(child)
		end
	end
end
