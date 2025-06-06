-- Torso only colliding killbrick client object script by zen

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TorsoCollidingKillbricks = script.Parent.Parent

local DamageEvent = ReplicatedStorage:WaitForChild("DamageEvent") :: RemoteEvent

local LocalPlayer = Players.LocalPlayer

local function playerTouched(touch): boolean
	if not touch.Parent then
		return false
	end
	-- If the player touched this part, return true
	return Players:GetPlayerFromCharacter(touch.Parent) == LocalPlayer
end

local function isTorso(part: BasePart?)
	if not part or not part.Parent then
		return false
	end

	local character = part.Parent
	local humanoid = character:FindFirstChild("Humanoid") :: Humanoid
	if not humanoid then
		return false
	end

	return part.Name == "Torso"
end

local function addTouchEvent(part: BasePart)
	part.Touched:Connect(function(hit)
		if not playerTouched(hit) then
			return
		end

		if not isTorso(hit) then
			return
		end

		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChild("Humanoid") :: Humanoid

		if not humanoid then
			return
		end

		if part:FindFirstChild("torso kills") then
			if
				(
					part.Name == "ButtonActivatedPlatform"
					or (part.Parent and part.Parent.Parent and part.Parent.Parent.Name == "Beat Blocks")
				) and part.CanCollide == false
			then
				return
			end
			if humanoid.Health > 0 and hit.Name ~= "Part" then
				DamageEvent:FireServer("Normal")
			end
		end
		if part:FindFirstChild("torso double") then
			if
				(
					part.Name == "ButtonActivatedPlatform"
					or (part.Parent and part.Parent.Parent and part.Parent.Parent.Name == "Beat Blocks")
				) and part.CanCollide == false
			then
				return
			end
			if humanoid.Health > 0 and hit.Name ~= "Part" then
				DamageEvent:FireServer("DoubleDamage")
			end
		end
		if part:FindFirstChild("torso ouch") then
			if
				(
					part.Name == "ButtonActivatedPlatform"
					or (part.Parent and part.Parent.Parent and part.Parent.Parent.Name == "Beat Blocks")
				) and part.CanCollide == false
			then
				return
			end
			if humanoid.Health > 0 and hit.Name ~= "Part" then
				DamageEvent:FireServer("HighDamage")
			end
		end
		if part:FindFirstChild("torso instakills") then
			if
				(
					part.Name == "ButtonActivatedPlatform"
					or (part.Parent and part.Parent.Parent and part.Parent.Parent.Name == "Beat Blocks")
				) and part.CanCollide == false
			then
				return
			end
			if humanoid.Health > 0 and hit.Name ~= "Part" then
				DamageEvent:FireServer("Instakill")
			end
		end
	end)
end

return function()
	-- Listen for new parts and bind them to the event
	TorsoCollidingKillbricks.ChildAdded:Connect(function(child)
		if not child:IsA("BasePart") then
			return
		end

		addTouchEvent(child)
	end)

	-- Bind all existing children to the event
	for _, child in pairs(TorsoCollidingKillbricks:GetChildren()) do
		if child:IsA("BasePart") then
			addTouchEvent(child)
		end
	end
end
