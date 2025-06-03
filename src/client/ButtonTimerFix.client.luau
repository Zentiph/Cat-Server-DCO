-- Button timer fix by zen

-- NOTE: Basically, when dying with a button activated,
--       the timer stays on screen and freezes, taking up space.
--       This is because of how the JToH kit works,
--       as it won't unload client object on death,
--       only when the player is far away.
--       This is a script to fix the button timer issue.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local buttonsFolder = ReplicatedStorage:WaitForChild("ClientSidedObjects"):WaitForChild("Buttons")

local function onCharacterAdded(character: Model)
	local humanoid = character:WaitForChild("Humanoid")

	humanoid.Died:Connect(function()
		-- Remove all button SurfaceGuis (get rid of button timers)
		for _, descendant in pairs(buttonsFolder:GetDescendants()) do
			if descendant:IsA("BasePart") and descendant.Name == "ButtonPart" then
				for _, child in pairs(descendant:GetChildren()) do
					if child:IsA("SurfaceGui") then
						descendant:Destroy()
					end
				end
			end
		end

		-- Remove all cloned labels from EffectGUI
		local effectGui = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("EffectGUI")

		if effectGui and effectGui:FindFirstChild("List") then
			for _, gui in pairs(effectGui.List:GetChildren()) do
				if gui:IsA("TextLabel") or gui:IsA("TextButton") then
					gui:Destroy()
				end
			end
		end
	end)
end

local function onPlayerReady()
	if LocalPlayer.Character then
		onCharacterAdded(LocalPlayer.Character)
	end
	LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
end

onPlayerReady()
