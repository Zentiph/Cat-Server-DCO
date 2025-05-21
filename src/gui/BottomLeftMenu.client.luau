-- Bottom left menu GUI script by zen

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui") :: PlayerGui

local frame = PlayerGui:WaitForChild("BottomLeftMenu"):WaitForChild("Frame") :: Frame

local selectStageButton = frame:WaitForChild("LoadStage") :: TextButton
local statsButton = frame:WaitForChild("Stats") :: TextButton
-- TODO: EVENTUALLY
-- local settingsButton = frame:WaitForChild("Settings") :: TextButton

local stageSelectFrame = PlayerGui:WaitForChild("StageSelect"):WaitForChild("Frame") :: Frame
local statsFrame = PlayerGui:WaitForChild("Stats"):WaitForChild("Frame") :: Frame
-- local settingsFrame = PlayerGui:WaitForChild("Settings"):WaitForChild("Frame") :: Frame

selectStageButton.MouseButton1Click:Connect(function()
	-- Flip visibility
	stageSelectFrame.Visible = not stageSelectFrame.Visible
	if statsFrame then
		statsFrame.Visible = false
	end
	--[[
   if settingsFrame then
      settingsFrame.Visible = false
   end
   ]]
end)

statsButton.MouseButton1Click:Connect(function()
	-- Get all stats
	local farthestStage = LocalPlayer:GetAttribute("FarthestStage")
	local deaths = LocalPlayer:GetAttribute("Deaths")
	local jumps = LocalPlayer:GetAttribute("Jumps")

	-- Update the GUI with the stats
	if farthestStage then
		statsFrame:WaitForChild("FarthestStage").Text = `Farthest Stage: {farthestStage}`
	end
	if deaths then
		statsFrame:WaitForChild("Deaths").Text = `Deaths: {deaths}`
	end
	if jumps then
		statsFrame:WaitForChild("Jumps").Text = `Jumps: {jumps}`
	end

	-- Flip visibility
	statsFrame.Visible = not statsFrame.Visible
	-- Close other menu
	if stageSelectFrame then
		stageSelectFrame.Visible = false
	end
end)
