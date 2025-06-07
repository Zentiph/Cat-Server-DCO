-- Reload client objects on death script by zen

-- Needed to make this because JToH client objects are by default only loaded based on proximity,
-- not on death. But for our purposes, reloading COs on death is a good idea.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local clientParts = workspace:WaitForChild("ClientParts")
local coFolder = ReplicatedStorage:WaitForChild("ClientSidedObjects")

local function reloadClientObjects()
	if clientParts then
		clientParts:ClearAllChildren()
	end

	for _, instance in ipairs(coFolder:GetDescendants()) do
		if instance.Name == "ClientObject" and instance.Parent then
			local clone = instance.Parent:Clone()
			clone.Parent = clientParts

			for _, innerInstance in ipairs(clone:GetDescendants()) do
				if innerInstance:IsA("BasePart") then
					innerInstance.CollisionGroup = "ClientObjects"
				end

				if innerInstance:FindFirstChild("SetCollisionGroup") then
					innerInstance.CollisionGroup = innerInstance.SetCollisionGroup.Value
				end

				if innerInstance.Name == "LightingChanger" or innerInstance:FindFirstChild("Invisible") then
					innerInstance.Transparency = 1
				end
			end

			local scriptRunner =
				script.Parent.Parent:WaitForChild("LocalPartScript"):WaitForChild("ScriptRunner"):Clone() :: LocalScript
			scriptRunner.Parent = player.Character
			for _, module in ipairs(clone:GetDescendants()) do
				if module:IsA("ModuleScript") and module.Name == "ClientObjectScript" then
					task.spawn(function()
						scriptRunner.ExecuteFunction:Fire(module)
					end)
				end
			end
		end
	end
end

player.CharacterAdded:Connect(reloadClientObjects)

if player.Character then
	reloadClientObjects()
end
