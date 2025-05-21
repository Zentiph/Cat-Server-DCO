-- Custom client object initializer by zen

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local CCO_FOLDER = workspace:WaitForChild("CustomClientObjects")

for _, obj in ipairs(CCO_FOLDER:GetChildren()) do
	if not obj:IsA("Folder") then
		continue
	end

	for _, child in ipairs(obj:GetChildren()) do
		if not child:IsA("Folder") or child.Name ~= "Script" then
			continue
		end

		local ccoScript = child:FindFirstChild("CCOScript")
		if not ccoScript then
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
