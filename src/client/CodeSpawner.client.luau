-- Code snippet spawner by zen

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local SPAWN_RADIUS = 4
local ACTIVE_DISTANCE = 50
local SPAWN_INTERVAL_SECONDS = 0.8

local CODE_SNIPPETS = {
	-- Services
	'game:GetService("Players")',
	'game:GetService("TweenService")',
	'game:GetService("RunService")',
	'game:GetService("ReplicatedStorage")',

	-- Variables
	"local player = Players.LocalPlayer",
	"local camera = workspace.CurrentCamera",
	"local character = plr.Character",
	"local character = plr.CharacterAdded:Wait()",

	-- Connections
	".Touched:Connect(function(hit)",
	":Connect(function(player)",
	".Heartbeat:Connect(function(deltaTime)",
	".Changed:Connect(onChange)",
	".AncestryChanged:Connect(...)",

	-- Conditions
	'if obj:IsA("Part") then',
	"if not success then retry() end",
	"if value ~= nil then",
	"if debounce then return end",

	-- Tweens & UI
	"TweenService:Create(...)",
	"billboard.AlwaysOnTop = true",
	"TextLabel.TextScaled = true",
	"Vector3.new(0, 3, 0)",
	"UDim2.new(0, 100, 0, 30)",
	"Color3.fromRGB(255, 255, 255)",
	"Vector3.new(0, 3, 0)",

	-- Async & Flow
	"task.wait()",
	"task.spawn(function()",
	"repeat ... until loaded",
	"coroutine.wrap(function()",
	"pcall(function() ... end)",
	"while true do ... end",

	-- Leaderstats & Data
	"DataStore:GetAsync(userId)",
	"DataStore:SetAsync(userId, value)",

	-- Misc
	"for i, v in pairs(children) do",
	"for i = 0, #emitters do",
	"Enum.Font.Code",
	"HumanoidRootPart.Position",
	"Humanoid:MoveTo(...)",
	"event:FireClient(plr)",
}

local LocalPlayer = Players.LocalPlayer

local function spawnSnippet(position: Vector3)
	local base = Instance.new("Part")
	base.Anchored = true
	base.CanCollide = false
	base.Size = Vector3.new(0.1, 0.1, 0.1)
	base.Transparency = 1
	base.Position = position
		+ Vector3.new(
			math.random(-SPAWN_RADIUS, SPAWN_RADIUS),
			math.random(2, 5),
			math.random(-SPAWN_RADIUS, SPAWN_RADIUS)
		)
	base.Parent = workspace

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 100, 0, 30)
	billboard.StudsOffset = Vector3.new(0, 0.5, 0)
	billboard.AlwaysOnTop = false
	billboard.Parent = base

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(143, 129, 174)
	label.TextScaled = true
	label.Font = Enum.Font.Code
	label.Text = CODE_SNIPPETS[math.random(1, #CODE_SNIPPETS)]
	label.Parent = billboard

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 0.7
	stroke.Color = Color3.new(0, 0, 0)
	stroke.Parent = label

	local camera = workspace.CurrentCamera
	local connection = nil
	-- Update size based on distance
	connection = RunService.RenderStepped:Connect(function()
		if not base or not base:IsDescendantOf(workspace) then
			connection:Disconnect()
			return
		end

		local distance = (camera.CFrame.Position - base.Position).Magnitude
		local scale = math.clamp(2 - (distance / 50), 0.8, 4) -- scale between 0.5x and 2x

		billboard.Size = UDim2.new(0, 120 * scale, 0, 40 * scale)
	end)

	local goalPosition = base.Position + Vector3.new(0, math.random(2, 4), 0)
	local tween = TweenService:Create(base, TweenInfo.new(2), { Position = goalPosition })
	tween:Play()

	task.delay(2, function()
		if connection then
			connection:Disconnect()
		end

		local fadeTween = TweenService:Create(
			label,
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ TextTransparency = 1 }
		)
		local strokeFadeTween = TweenService:Create(
			stroke,
			TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Transparency = 1 }
		)

		fadeTween:Play()
		strokeFadeTween:Play()

		fadeTween.Completed:Connect(function()
			base:Destroy()
		end)
	end)
end

-- Main loop
task.spawn(function()
	local target =
		workspace:WaitForChild("Lobby"):WaitForChild("Credits"):WaitForChild("Zentiph"):WaitForChild("BasePart")

	while true do
		local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

		if humanoidRootPart then
			local playerPosition = humanoidRootPart.Position
			local targetPosition = target.Position
			local distance = (playerPosition - targetPosition).Magnitude
			if distance <= ACTIVE_DISTANCE then
				spawnSnippet(targetPosition)
			end
		end

		task.wait(SPAWN_INTERVAL_SECONDS)
	end
end)
