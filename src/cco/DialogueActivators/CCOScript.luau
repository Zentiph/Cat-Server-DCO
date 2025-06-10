-- Dialogue activator CCO script by zen

local Players = game:GetService("Players")

local DialogueActivators = workspace:WaitForChild("CustomClientObjects"):WaitForChild("DialogueActivators")

local player = Players.LocalPlayer

local debounceArray = {}

local function addTouchEvent(part: BasePart)
	local activateOnce = part:FindFirstChild("ActivateOnce")
	if not activateOnce or not activateOnce:IsA("BoolValue") then
		warn("[DialogueActivators] Missing BoolValue 'ActivateOnce' in DialogueActivator")
		return
	end

	local dialogueScript = part:FindFirstChild("DialogueScript")
	if not dialogueScript or not dialogueScript:IsA("ModuleScript") then
		warn("[DialogueActivators] Missing ModuleScript 'DialogueScript' in DialogueActivator")
		return
	end

	local dialogueRunner = require(dialogueScript)
	if typeof(dialogueRunner) ~= "function" then
		warn(`[DialogueActivators] DialogueScript returned value of type {typeof(dialogueRunner)}, expected function`)
	end

	debounceArray[part] = false

	part.Touched:Connect(function(hit)
		if not hit.Parent or Players:GetPlayerFromCharacter(hit.Parent) ~= player or debounceArray[part] then
			return
		end

		debounceArray[part] = true

		dialogueRunner()

		if not activateOnce then
			debounceArray[part] = false
		end
	end)
end

return function()
	DialogueActivators.ChildAdded:Connect(function(child)
		if not child:IsA("BasePart") then
			return
		end

		child.Transparency = 1
		addTouchEvent(child)
	end)

	for _, child in pairs(DialogueActivators:GetChildren()) do
		if not child:IsA("BasePart") then
			continue
		end

		child.Transparency = 1
		addTouchEvent(child)
	end
end
