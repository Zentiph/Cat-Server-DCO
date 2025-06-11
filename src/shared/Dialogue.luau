-- Dialogue module by zen

local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local TWEEN_TIME_SECONDS = 0.75
local SPRITE_ANIMATION_MULTIPLIER = 2

local SPRITE_SHIFT_OFFSET_PX = 2

local tweenInfo = TweenInfo.new(TWEEN_TIME_SECONDS, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local dialogueGui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("DialogueGui") :: ScreenGui
local dialogueBox = dialogueGui:WaitForChild("Frame") :: Frame
local dialogueText = dialogueBox:WaitForChild("Text") :: TextLabel
local dialogueName = dialogueBox:WaitForChild("Name") :: TextLabel
local borderBox = dialogueBox:WaitForChild("Border") :: Frame

local spriteBase = dialogueBox:WaitForChild("Sprite") :: ImageLabel

local Dialogue = {}

local dialogueAvailable = Instance.new("BindableEvent")
local dialogueTalking = Instance.new("BindableEvent")

Dialogue.Active = false
Dialogue.Talking = false
Dialogue.__Sprites = {}

--[[
Set the font of the dialogue box.
]]
function Dialogue:SetFont(font: Enum.Font)
	if Dialogue.Talking then
		dialogueTalking.Event:Wait()
	end

	dialogueName.Font = font
	dialogueText.Font = font
end

--[[
Set the font of the dialogue box.
]]
function Dialogue:SetFontFromId(id: number)
	if Dialogue.Talking then
		dialogueTalking.Event:Wait()
	end

	dialogueName.Font = Font.fromId(id)
	dialogueText.Font = Font.fromId(id)
end

--[[
Set the name of the dialogue box.
]]
function Dialogue:SetName(name: string)
	if Dialogue.Talking then
		dialogueTalking.Event:Wait()
	end

	dialogueName.Text = name
end

--[[
Set the name color of the dialogue box.
]]
function Dialogue:SetNameColor(color: Color3)
	if Dialogue.Talking then
		dialogueTalking.Event:Wait()
	end

	dialogueName.TextColor3 = color
end

--[[
Set the text color of the dialogue box.
]]
function Dialogue:SetTextColor(color: Color3)
	if Dialogue.Talking then
		dialogueTalking.Event:Wait()
	end

	dialogueText.TextColor3 = color
end

--[[
Set the background color of the dialogue box.
]]
function Dialogue:SetBackgroundColor(color: Color3)
	if Dialogue.Talking then
		dialogueTalking.Event:Wait()
	end

	dialogueBox.BackgroundColor3 = color
end
--[[
Set the background color sequence of the dialogue box.
]]
function Dialogue:SetBackgroundColorSequence(colorSequence: ColorSequence)
	if Dialogue.Talking then
		dialogueTalking.Event:Wait()
	end

	dialogueBox.BackgroundColor3 = colorSequence
end

--[[
Set the border color of the dialogue box.
]]
function Dialogue:SetBorderColor(color: Color3)
	if Dialogue.Talking then
		dialogueTalking.Event:Wait()
	end

	borderBox.BackgroundColor3 = color
	borderBox.BorderColor3 = color
end

--[[
Set the sprites to be used with the dialogue.
]]
function Dialogue:SetSprites(sprites: { string })
	if Dialogue.Talking then
		dialogueTalking.Event:Wait()
	end

	if #sprites < 1 then
		error("Sprites for dialogue must contain at least one sprite")
	end

	for _, sprite in ipairs(Dialogue.__Sprites) do
		sprite:Destroy()
	end
	table.clear(Dialogue.__Sprites)

	for _, spriteId in ipairs(sprites) do
		local image = spriteBase:Clone()
		image.Parent = spriteBase.Parent
		image.Image = spriteId
		image.Visible = false
		image.Position = spriteBase.Position
		table.insert(Dialogue.__Sprites, image)
	end
	Dialogue.__Sprites[1].Visible = true -- Make first sprite visible
end

--[[
Open the dialogue menu (with a tween).
]]
function Dialogue:Open()
	if Dialogue.Active then
		dialogueAvailable.Event:Wait()
	end

	Dialogue.Active = true
	dialogueBox.Size = UDim2.new(0, 0, 0, 0)
	dialogueBox.Visible = true
	TweenService:Create(dialogueBox, tweenInfo, { Size = UDim2.new(0.658, 0, 0.189, 0) }):Play()
	task.wait(1)
end

--[[
Write text to the dialogue menu.

@param text - The text to write
@param interval - The interval in seconds to wait between each character added
@param sound - The talk sound to play when writing each character
]]
function Dialogue:Write(text: string, interval: number, sound: Sound)
	if Dialogue.Talking then
		dialogueTalking.Event:Wait()
	end

	Dialogue.Talking = true

	local animating = true
	local currentSprite = 1

	task.spawn(function()
		local bounceUp = true

		while animating do
			Dialogue.__Sprites[currentSprite].Visible = false

			-- Go to next sprite, looping around if needed
			currentSprite = (currentSprite % #Dialogue.__Sprites) + 1
			local sprite = Dialogue.__Sprites[currentSprite]
			sprite.Visible = true

			local originalPos = spriteBase.Position
			local targetOffset = UDim2.new(0, 0, 0, bounceUp and -SPRITE_SHIFT_OFFSET_PX or SPRITE_SHIFT_OFFSET_PX)
			bounceUp = not bounceUp

			local tween = TweenService:Create(
				sprite,
				TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Position = originalPos + targetOffset }
			)
			tween:Play()
			tween.Completed:Wait()

			task.wait(interval * SPRITE_ANIMATION_MULTIPLIER)
		end
	end)

	for _, letter in pairs(string.split(text, "")) do
		local charSound = sound:Clone()

		-- Randomize pitch relative to existing pitch
		local speed = charSound.PlaybackSpeed
		charSound.PlaybackSpeed = math.random(90 * speed, 110 * speed) / 100
		charSound.Parent = dialogueGui
		charSound:Play()
		Debris:AddItem(charSound, 1)

		dialogueText.Text ..= letter
		task.wait(interval)
	end

	animating = false

	-- Add time to read
	task.wait(2)

	Dialogue.Talking = false
end

--[[
Clear the dialogue box.
]]
function Dialogue:Clear()
	dialogueText.Text = ""
end

--[[
Close the dialogue menu (with a tween).
]]
function Dialogue.Close()
	Dialogue.Active = false
	dialogueAvailable:Fire()

	local tween = TweenService:Create(dialogueBox, tweenInfo, { Size = UDim2.new(0, 0, 0, 0) })
	tween:Play()
	tween.Completed:Connect(function()
		dialogueBox.Visible = false
	end)
end

return Dialogue
