-- Stats updating by zen

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local JumpEvent = ReplicatedStorage:WaitForChild("JumpEvent")
local DeathEvent = ReplicatedStorage:WaitForChild("DeathEvent")

JumpEvent.OnServerEvent:Connect(function(player: Player)
	local jumps = player:GetAttribute("Jumps")
	if jumps then
		player:SetAttribute("Jumps", jumps + 1)
	end
end)

DeathEvent.OnServerEvent:Connect(function(player: Player)
	local deaths = player:GetAttribute("Deaths")
	if deaths then
		player:SetAttribute("Deaths", deaths + 1)
	end
end)
