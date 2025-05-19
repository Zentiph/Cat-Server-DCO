-- Camera updater by zen

local UpdateCameraEvent = game.ReplicatedStorage:WaitForChild("UpdateCameraEvent")

UpdateCameraEvent.OnClientEvent:Connect(function(cFrame: CFrame)
	local camera = workspace.CurrentCamera

	local originalCameraType = camera.CameraType
	local originalSubject = camera.CameraSubject

	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = cFrame

	task.delay(0.05, function()
		camera.CameraSubject = originalSubject
		camera.CameraType = originalCameraType
	end)
end)
