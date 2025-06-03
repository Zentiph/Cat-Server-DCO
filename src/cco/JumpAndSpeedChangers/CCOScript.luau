-- Combined jump and speed changers script by zen

-- NOTE: This is pretty much entirely refactored code from the JToH kit,
-- so I don't really claim ownership/authorship of most of the code here.

local TweenService = game:GetService("TweenService")

local JumpAndSpeedChangers = script.Parent.Parent

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

		local boostLength = part:FindFirstChild("BoostLength") :: NumberValue
		local jumpPower = part:FindFirstChild("JumpPower") :: NumberValue
		local walkSpeed = part:FindFirstChild("WalkSpeed") :: NumberValue

		if not humanoid:FindFirstChild("JumpBoost") then
			local jumpBoost = Instance.new("NumberValue")
			jumpBoost.Parent = humanoid
			jumpBoost.Name = "JumpBoost"
			jumpBoost.Value = boostLength.Value

			tween(humanoid, (instant and 0) or 0.5, { JumpPower = jumpPower.Value })

			task.spawn(function()
				repeat
					jumpBoost.Value -= 0.1
					task.wait(0.1)
				until not jumpBoost or not jumpBoost.Parent or jumpBoost.Value <= 0

				tween(humanoid, (instant and 0) or 0.5, { JumpPower = 50 })

				for _, child in pairs(humanoid:GetChildren()) do
					if child.Name == "JumpBoost" then
						child:Destroy()
					end
				end
			end)
		else
			local jumpBoost = humanoid:FindFirstChild("JumpBoost") :: NumberValue
			jumpBoost.Value = boostLength.Value
		end

		if not humanoid:FindFirstChild("SpeedBoost") then
			local speedBoost = Instance.new("NumberValue")
			speedBoost.Parent = humanoid
			speedBoost.Name = "SpeedBoost"
			speedBoost.Value = boostLength.Value

			tween(humanoid, (instant and 0) or 0.5, { WalkSpeed = walkSpeed.Value })

			task.spawn(function()
				repeat
					speedBoost.Value -= 0.1
					task.wait(0.1)
				until not speedBoost or not speedBoost.Parent or speedBoost.Value <= 0

				tween(humanoid, (instant and 0) or 0.5, { WalkSpeed = 16 })

				for _, child in pairs(humanoid:GetChildren()) do
					if child.Name == "SpeedBoost" then
						child:Destroy()
					end
				end
			end)
		else
			local speedBoost = humanoid:FindFirstChild("SpeedBoost") :: NumberValue
			speedBoost.Value = boostLength.Value
		end
	end)
end

function addTouchEventForRemove(part)
	part.Touched:Connect(function(hit)
		local humanoid = hit.Parent:FindFirstChild("Humanoid") :: Humanoid
		if not humanoid then
			return
		end

		local jumpBoost = humanoid:FindFirstChild("JumpBoost")
		local speedBoost = humanoid:FindFirstChild("SpeedBoost")

		if jumpBoost then
			jumpBoost:Destroy()
		end
		if speedBoost then
			speedBoost:Destroy()
		end
	end)
end

function addTouchEvent(part)
	if part.Name == "JumpAndSpeedBooster" then
		addTouchEventForBooster(part)
	elseif part.Name == "JumpAndSpeedRemover" then
		addTouchEventForRemove(part)
	end
end

return function()
	-- Listen for new parts and bind them to the event
	JumpAndSpeedChangers.ChildAdded:Connect(function(child: Instance)
		if not child:IsA("BasePart") then
			return
		end

		addTouchEvent(child)
	end)

	-- Bind all existing children to the event
	for _, obj in pairs(JumpAndSpeedChangers:GetChildren()) do
		if obj:IsA("BasePart") then
			addTouchEvent(obj)
		end
	end
end
