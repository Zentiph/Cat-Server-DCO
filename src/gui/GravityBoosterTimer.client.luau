-- JToH style gravity booster timer by zen

local Players = game:GetService("Players")

local player = Players.LocalPlayer

local effectGui = script.Parent.Parent:WaitForChild("EffectGUI") :: ScreenGui
local gravityBoostTimer = effectGui:WaitForChild("GravityBoostTimer") :: TextLabel
local speedBoostTimer = effectGui:WaitForChild("SpeedBoostTimer") :: TextLabel
local jumpBoostTimer = effectGui:WaitForChild("JumpBoostTimer") :: TextLabel

game:GetService("RunService").RenderStepped:Connect(function()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid

	if humanoid and humanoid:FindFirstChild("GravityBoost") then
		local gravityBoost = humanoid.GravityBoost :: NumberValue
		if gravityBoost.Value > 0 and gravityBoost.Value < 1e10 then
			local seconds, milliseconds = math.modf(gravityBoost.Value)
			gravityBoostTimer.Text = string.format("%i.%i", seconds, math.floor(milliseconds * 10))
		else
			gravityBoostTimer.Text = ""
		end
	else
		gravityBoostTimer.Text = ""
	end

	local speedVisible = speedBoostTimer.Text ~= ""
	local jumpVisible = jumpBoostTimer.Text ~= ""

	if not speedVisible then
		jumpBoostTimer.Position = speedBoostTimer.Position
	else
		jumpBoostTimer.Position = UDim2.new(1, 0, 0.9, -35)
	end

	if not jumpVisible then
		gravityBoostTimer.Position = jumpBoostTimer.Position
	elseif not speedVisible then
		gravityBoostTimer.Position = UDim2.new(1, 0, 0.9, -35)
	else
		gravityBoostTimer.Position = UDim2.new(1, 0, 0.8, -35)
	end
end)
