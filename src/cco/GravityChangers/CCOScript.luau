-- Gravity booster script by zen

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local GravityChangers = script.Parent.Parent
local gravity = workspace.Gravity

local player = Players.LocalPlayer

local debounceArray = {}

local function tween(instance: Instance, time: number, properties: {})
	TweenService:Create(instance, TweenInfo.new(time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), properties)
		:Play()
end

local function findGravityForce(humanoidRootPart: BasePart): VectorForce?
	local gravityForce = humanoidRootPart:FindFirstChild("CustomGravityForce")
	if gravityForce and gravityForce:IsA("VectorForce") then
		return gravityForce
	end

	local attachment = humanoidRootPart:FindFirstChild("GravityAttachment") :: Attachment
	if not attachment then
		attachment = Instance.new("Attachment")
		attachment.Name = "GravityAttachment"
		attachment.Parent = humanoidRootPart
	end

	gravityForce = Instance.new("VectorForce")
	gravityForce.Force = Vector3.new(0, gravity * humanoidRootPart.AssemblyMass, 0)
	gravityForce.Name = "CustomGravityForce"
	gravityForce.Parent = humanoidRootPart
	gravityForce.Attachment0 = attachment
	gravityForce.ApplyAtCenterOfMass = true

	return gravityForce
end

local function addTouchEventForBooster(part: BasePart)
	local instantBoolValue = part:FindFirstChild("Instant") :: BoolValue
	local instant = instantBoolValue and instantBoolValue.Value == true

	part.Touched:Connect(function(hit)
		local humanoid = hit.Parent and hit.Parent:FindFirstChild("Humanoid") :: Humanoid
		if not humanoid then
			return
		end

		local humanoidRootPart = hit.Parent:FindFirstChild("HumanoidRootPart") :: BasePart
		if not humanoidRootPart then
			return
		end

		local boostLength = part:FindFirstChild("BoostLength") :: NumberValue
		local gravityChange = part:FindFirstChild("Gravity")

		local gravityForce = findGravityForce(humanoidRootPart)

		if not humanoid:FindFirstChild("GravityBoost") then
			local gravityBoost = Instance.new("NumberValue")
			gravityBoost.Parent = humanoid
			gravityBoost.Name = "GravityBoost"
			gravityBoost.Value = boostLength.Value

			tween(
				gravityForce,
				(instant and 0) or 0.5,
				{ Force = Vector3.new(0, gravityChange.Value * humanoidRootPart.AssemblyMass, 0) }
			)

			task.spawn(function()
				repeat
					gravityBoost.Value -= 0.1
					task.wait(0.1)
				until not gravityBoost or not gravityBoost.Parent or gravityBoost.Value <= 0

				tween(
					gravityForce,
					(instant and 0) or 0.5,
					{ Force = Vector3.new(0, gravity * humanoidRootPart.AssemblyMass, 0) }
				)

				gravityBoost:Destroy()
				gravityForce:Destroy()
			end)
		else
			local gravityBoost = humanoid:FindFirstChild("GravityBoost") :: NumberValue
			gravityBoost.Value = boostLength.Value
		end
	end)
end

local function addTouchEventForPad(part: BasePart)
	local distance = part:FindFirstChild("Distance") :: NumberValue

	local padClone = part:Clone()
	padClone:ClearAllChildren()

	padClone.Transparency = 1
	padClone.Parent = part

	print("Cloned pad", padClone)

	padClone.Size = padClone.Size + Vector3.new(0.5, distance.Value, 0.5)
	padClone.CFrame = part.CFrame + part.CFrame.UpVector * distance.Value / 2

	padClone.CanCollide = false
	padClone.Anchored = false
	padClone.Massless = true

	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Parent = padClone
	weldConstraint.Part0 = padClone
	weldConstraint.Part1 = part

	padClone.Touched:Connect(function(hit)
		local humanoid = hit.Parent and hit.Parent:FindFirstChild("Humanoid") :: Humanoid
		if not humanoid then
			return
		end

		local humanoidRootPart = hit.Parent:FindFirstChild("HumanoidRootPart") :: BasePart
		if not humanoidRootPart then
			return
		end

		local gravityForce = findGravityForce(humanoidRootPart)
		local gravityChange = part:FindFirstChild("Gravity") :: NumberValue

		if
			Players:GetPlayerFromCharacter(hit.Parent) == player
			and hit.Name ~= "Left Arm"
			and hit.Name ~= "Right Arm"
		then
			if not debounceArray[part] then
				debounceArray[part] = true
				gravityForce.Force = Vector3.new(0, gravityChange.Value * humanoidRootPart.AssemblyMass, 0)
			end
		end
	end)

	padClone.TouchEnded:Connect(function(hit)
		local humanoid = hit.Parent and hit.Parent:FindFirstChild("Humanoid") :: Humanoid
		if not humanoid then
			return
		end

		local humanoidRootPart = hit.Parent:FindFirstChild("HumanoidRootPart") :: BasePart
		if not humanoidRootPart then
			return
		end

		local gravityForce = humanoidRootPart:FindFirstChild("CustomGravityForce") :: VectorForce?

		if
			Players:GetPlayerFromCharacter(hit.Parent) == player
			and hit.Name ~= "Left Arm"
			and hit.Name ~= "Right Arm"
		then
			if humanoid and debounceArray[part] then
				local gravityBoost = humanoid:FindFirstChild("GravityBoost")
				if gravityBoost then
					gravityBoost:Destroy()
				end
				if gravityForce then
					gravityForce:Destroy()
				end

				debounceArray[part] = false
			end
		end
	end)
end

local function addTouchEventForRemove(part: BasePart)
	part.Touched:Connect(function(hit)
		local humanoid = hit.Parent:FindFirstChild("Humanoid") :: Humanoid
		if not humanoid then
			return
		end

		local humanoidRootPart = hit.Parent:FindFirstChild("HumanoidRootPart") :: BasePart
		if not humanoidRootPart then
			return
		end

		local gravityBoost = humanoid:FindFirstChild("GravityBoost")
		local gravityForce = humanoidRootPart:FindFirstChild("CustomGravityForce")

		if gravityBoost then
			gravityBoost:Destroy()
		end
		if gravityForce then
			gravityForce:Destroy()
		end
	end)
end

function addTouchEvent(part)
	if part.Name == "GravityBooster" then
		addTouchEventForBooster(part)
	elseif part.Name == "GravityRemover" then
		addTouchEventForRemove(part)
	elseif part.Name == "GravityBoostPad" then
		addTouchEventForPad(part)
	end
end

return function()
	-- Listen for new parts and bind them to the event
	GravityChangers.ChildAdded:Connect(function(child: Instance)
		if not child:IsA("BasePart") then
			return
		end

		addTouchEvent(child)
	end)

	-- Bind all existing children to the event
	for _, child in pairs(GravityChangers:GetChildren()) do
		if child:IsA("BasePart") then
			addTouchEvent(child)
		end
	end
end
