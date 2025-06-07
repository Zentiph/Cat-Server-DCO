-- Gravity booster script by zen

local TweenService = game:GetService("TweenService")

local GravityChangers = script.Parent.Parent
local gravity = workspace.Gravity
print(gravity)

function tween(instance: Instance, time: number, properties: {})
	TweenService:Create(instance, TweenInfo.new(time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), properties)
		:Play()
end

local function addTouchEventForBooster(part)
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

		local gravityForce: VectorForce
		if humanoidRootPart:FindFirstChild("CustomGravityForce") then
			gravityForce = humanoidRootPart.CustomGravityForce
		else
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
		end

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

function addTouchEventForRemove(part)
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
