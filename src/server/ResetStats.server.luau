-- Reset stat event by zen

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ResetStatsEvent = ReplicatedStorage:WaitForChild("ResetStatsEvent")

ResetStatsEvent.OnServerEvent:Connect(function(player: Player)
	local leaderstats = player:FindFirstChild("leaderstats")

	if leaderstats and leaderstats:FindFirstChild("Stage") then
		leaderstats.Stage.Value = 0
		player:SetAttribute("FarthestStage", 0)
		player:SetAttribute("Jumps", 0)
		player:SetAttribute("Deaths", 0)
	end

	player:Kick("Your data has successfully been reset! Please rejoin.")
end)
