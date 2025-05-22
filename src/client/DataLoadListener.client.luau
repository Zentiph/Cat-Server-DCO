-- Data loaded listener by zen

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataLoadedEvent = ReplicatedStorage:WaitForChild("DataLoadedEvent") :: RemoteEvent
local DataState = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("DataState"))

DataLoadedEvent.OnClientEvent:Connect(function()
	DataState:SetLoaded()
end)
