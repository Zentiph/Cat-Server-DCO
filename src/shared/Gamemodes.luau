-- Gamemode setup and constants by zen

local Gamemodes = {}

Gamemodes.Gamemode = table.freeze({
	Normal = "Normal",
	Speedrun = "Speedrun",
	Hardcore = "Hardcore",
})

local gamemodeArray = {}
for _, gamemode in pairs(Gamemodes.Gamemode) do
	table.insert(gamemodeArray, gamemode)
end

--[[
Get the next gamemode in the list of gamemodes.
If the current gamemode is the last one,
it returns the first one, safely looping around.
]]
function Gamemodes.getNextGamemode(currentGamemode: string): string
	local currentIndex = table.find(gamemodeArray, currentGamemode)

	if currentIndex == #gamemodeArray then
		return gamemodeArray[1]
	else
		return gamemodeArray[currentIndex + 1]
	end
end

--[[
Get the previous gamemode in the list of gamemodes.
If the current gamemode is the last one,
it returns the first one, safely looping around.
]]
function Gamemodes.getPreviousGamemode(currentGamemode: string): string
	local currentIndex = table.find(gamemodeArray, currentGamemode)

	if currentIndex == 1 then
		return gamemodeArray[#gamemodeArray]
	else
		return gamemodeArray[currentIndex - 1]
	end
end

export type Gamemode = "Normal" | "Speedrun" | "Hardcore"

return Gamemodes
