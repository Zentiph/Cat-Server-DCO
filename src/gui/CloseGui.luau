-- Reusable GUI closer script by zen

local CloseGui = {}

function CloseGui:addCloseEvent(element: TextButton | GuiButton | ImageButton, frame: Frame)
	element.MouseButton1Click:Connect(function()
		-- Close the GUI
		frame.Visible = false
	end)
end

return CloseGui
