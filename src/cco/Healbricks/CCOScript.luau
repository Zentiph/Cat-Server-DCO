-- Healbrick client object script by zen

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Healbricks = script.Parent.Parent

local LocalPlayer = Players.LocalPlayer

local HealEvent = ReplicatedStorage:WaitForChild("HealEvent") :: RemoteEvent

local vignette = LocalPlayer:WaitForChild("PlayerGui")
	:WaitForChild("HealGui")
	:WaitForChild("HealFlash")
	:WaitForChild("Vignette") :: ImageLabel

local function playerTouched(touch): boolean
	if not touch.Parent then
		return false
	end
	-- If the player touched this part, return true
	return Players:GetPlayerFromCharacter(touch.Parent) == LocalPlayer
end

local function addTouchEvent(part)
	local healAmount = part:WaitForChild("HealPower")
	if not healAmount or not healAmount:IsA("IntValue") then
		return
	end

	if part.Name ~= "Healbrick" then
		return
	end

	part.Touched:Connect(function(hit)
		if not playerTouched(hit) then
			return
		end
		HealEvent:FireServer(healAmount.Value)

		-- Flash green vignette to mirror taking damage, only if the player is healing
		local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local humanoid = character:FindFirstChild("Humanoid") :: Humanoid

		if humanoid and humanoid.Health >= humanoid.MaxHealth then
			return
		end

		vignette.ImageTransparency = 0

		TweenService:Create(
			vignette,
			TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{ ImageTransparency = 1 }
		):Play()
	end)
end

return function()
	-- Listen for new parts and bind them to the event
	Healbricks.ChildAdded:Connect(function(child)
		if not child:IsA("BasePart") then
			return
		end

		addTouchEvent(child)
	end)

	-- Bind all existing children to the event
	for _, child in pairs(Healbricks:GetChildren()) do
		if child:IsA("BasePart") then
			addTouchEvent(child)
		end
	end
end
