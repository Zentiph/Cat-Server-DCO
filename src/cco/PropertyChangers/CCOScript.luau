-- Property changer CCO script by zen

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local PropertyChangers = workspace:WaitForChild("CustomClientObjects"):WaitForChild("PropertyChangers")

local LocalPlayer = Players.LocalPlayer

local DEFAULT_TWEEN = false
local DEFAULT_DURATION = 1

local WHITELISTED_PROPERTIES = {
	-- Physics & Collision
	"Anchored",
	"CanCollide",
	"Massless",

	-- Appearance
	"Color",
	"Transparency",
	"Reflectance",
	"Material",
	"MaterialVariant",
	"CastShadow",

	-- GUI
	"Visible",
	"ZIndex",
	"ImageColor3",
	"TextColor3",
	"BackgroundColor3",
	"BackgroundTransparency",
	"TextTransparency",

	-- Lighting
	"Brightness",
	"Range",
	"Color3",
	"Enabled",
}
local NON_TWEENABLE_PROPERTIES = table.freeze({
	Anchored = true,
	CanCollide = true,
	CastShadow = true,
	Massless = true,
	Enabled = true,
	Visible = true,
})

local WHITELISTED_TYPES = table.freeze({
	["number"] = true,
	["boolean"] = true,
	["Color3"] = true,
	["EnumItem"] = true,
})

local debounceArray = {}

type Type = number | boolean | BrickColor | Color3 | EnumItem

local function isTweenableProperty(property: string, value: any)
	return not NON_TWEENABLE_PROPERTIES[property] and typeof(value) ~= "boolean" and typeof(value) ~= "Instance"
end

-- Convert the raw value (string) to the given target type
local function coerceValue(rawValue: string, targetType: string): Type?
	if not WHITELISTED_TYPES[targetType] then
		warn(`[PropertyChanger] Unsupported property type '{targetType}'`)
	end

	if targetType == "number" then
		return tonumber(rawValue)
	end

	if targetType == "boolean" then
		return rawValue == "true"
	end

	if targetType == "BrickColor" then
		warn("[PropertyChanger] BrickColor is not a supported property to change, use Color instead")
	end

	if targetType == "Color3" then
		local r, g, b = rawValue:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
		if r and g and b then
			return Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
		end
	end

	if targetType == "EnumItem" then
		return Enum[rawValue:match("^(%w+)%.(%w+)$")] and Enum[rawValue:match("^(%w+)%.(%w+)$")][rawValue:match("%w+$")]
	end

	return nil
end

local function tweenProperty(target: Instance, property: string, value: Type, duration: number)
	if not isTweenableProperty(property, value) then
		target[property] = value
		return
	end

	local success, tweenOrError = pcall(function()
		return TweenService:Create(
			target,
			TweenInfo.new(duration, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
			{ [property] = value }
		)
	end)

	if success then
		tweenOrError:Play()
	else
		warn(
			`[PropertyChanger] Failed to tween property '{property}' of '{target:GetFullName()}': {tostring(
				tweenOrError
			)}`
		)
		target[property] = value -- Fallback
	end
end

local function addTouchEvent(part: BasePart)
	local target = part:FindFirstChild("Target") :: ObjectValue
	local targetInstance = target and target.Value
	if not targetInstance then
		warn("[PropertyChanger] Missing ObjectValue 'Target' in PropertyChanger")
		return
	end

	if part.Name == "PropertyChanger" then
		debounceArray[part] = false

		local properties = part:FindFirstChild("Properties") :: Folder
		if not properties then
			warn("[PropertyChanger] Missing Folder 'Properties' in PropertyChanger")
			return
		end

		local propertyList = {}

		for _, propertyConfig in pairs(properties:GetChildren()) do
			if not propertyConfig:IsA("Configuration") or propertyConfig.Name ~= "Property" then
				continue
			end

			local propertyName = propertyConfig:FindFirstChild("PropertyName") :: StringValue
			local propertyValue = propertyConfig:FindFirstChild("PropertyValue") :: StringValue
			-- These can be null, just default to no tween and 1 second respectively if null
			local shouldTween = propertyConfig:FindFirstChild("Tween") :: BoolValue?
			local transitionDuration = propertyConfig:FindFirstChild("TransitionDuration") :: NumberValue?

			if not propertyName then
				warn("[PropertyChanger] Missing StringValue 'PropertyName' in PropertyChanger")
				continue
			end
			if not propertyValue then
				warn("[PropertyChanger] Missing StringValue 'PropertyValue' in PropertyChanger")
				continue
			end

			table.insert(propertyList, {
				Name = propertyName.Value,
				Value = propertyValue.Value,
				Tween = shouldTween and shouldTween.Value or DEFAULT_TWEEN,
				Duration = transitionDuration and transitionDuration.Value or DEFAULT_DURATION,
			})
		end

		part.Touched:Connect(function(hit)
			if not hit.Parent or Players:GetPlayerFromCharacter(hit.Parent) ~= LocalPlayer or debounceArray[part] then
				return
			end

			debounceArray[part] = true

			for _, property in pairs(propertyList) do
				local newValue = coerceValue(property.Value, typeof(targetInstance[property.Name]))
				if newValue == nil then
					warn(
						`[PropertyChanger] Could not change property '{property.Name}'`
							.. ` of '{targetInstance:GetFullName()}' to '{property.Value}'`
					)
					continue
				end

				if property.Tween then
					tweenProperty(targetInstance, property.Name, newValue, property.Duration)
				else
					targetInstance[property.Name] = newValue
				end
			end

			task.delay(0.1, function()
				debounceArray[part] = false
			end)
		end)
	elseif part.Name == "PropertyReverter" then
		debounceArray[part] = false

		local shouldTween = part:FindFirstChild("Tween") :: BoolValue?
		local transitionDuration = part:FindFirstChild("TransitionDuration") :: NumberValue?

		local savedProperties = {}
		-- Capture initial instance state
		for _, property in pairs(WHITELISTED_PROPERTIES) do
			local success, value = pcall(function()
				return targetInstance[property]
			end)

			if success and WHITELISTED_TYPES[typeof(value)] then
				savedProperties[property] = value
			end
		end

		part.Touched:Connect(function(hit)
			if not hit.Parent or Players:GetPlayerFromCharacter(hit.Parent) ~= LocalPlayer or debounceArray[part] then
				return
			end

			debounceArray[part] = true

			for property, value in pairs(savedProperties) do
				if shouldTween and shouldTween.Value then
					local duration = transitionDuration and transitionDuration.Value or 1
					tweenProperty(targetInstance, property, value, duration)
				else
					targetInstance[property] = value
				end
			end

			task.delay(0.1, function()
				debounceArray[part] = false
			end)
		end)
	end
end

return function()
	PropertyChangers.ChildAdded:Connect(function(child)
		if not child:IsA("BasePart") then
			return
		end

		child.Transparency = 1
		addTouchEvent(child)
	end)

	for _, child in pairs(PropertyChangers:GetChildren()) do
		if not child:IsA("BasePart") then
			continue
		end

		child.Transparency = 1
		addTouchEvent(child)
	end
end
