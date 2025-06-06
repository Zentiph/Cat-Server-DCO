-- Custom client object initializer by zen

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local ccoFolder = workspace:WaitForChild("CustomClientObjects")

for _, object in ipairs(ccoFolder:GetChildren()) do
	if not object:IsA("Folder") then
		continue
	end

	for _, child in ipairs(object:GetChildren()) do
		if not child:IsA("Folder") or child.Name ~= "Script" then
			continue
		end

		local ccoScript = child:FindFirstChild("CCOScript")
		if not ccoScript or not ccoScript:IsA("ModuleScript") then
			warn(`CCO script not found in '{child:GetFullName()}'`)
			continue
		end

		task.spawn(function()
			local success, result = pcall(function()
				return require(ccoScript)
			end)

			if success then
				print(`Successfully acquired CCO script '{ccoScript:GetFullName()}'`)
				if typeof(result) == "function" then
					result()
				else
					warn(
						`Expected type 'function' return from '{ccoScript:GetFullName()}', got '{typeof(result)}' instead`
					)
				end
			else
				warn(`Error acquiring CCO script '{result}'`)
			end
		end)
	end
end
