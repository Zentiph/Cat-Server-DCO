-- Property changer CCO script by zen

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local PropertyChangers = workspace:WaitForChild("CustomClientObjects"):FindFirstChild("PropertyChangers")

local LocalPlayer = Players.LocalPlayer

local WHITELISTED_PROPERTIES = {
	"CastShadow",
	"Color",
	"Reflectance",
	"Transparency",
	"CanCollide",
	"Anchored",
	"Color3",
	"ZIndex",
}
local SUPPORTED_TYPES = table.freeze({
	["number"] = true,
	["boolean"] = true,
	["Color3"] = true,
	["EnumItem"] = true,
})

local debounceArray = {}

type Type = number | boolean | BrickColor | Color3 | EnumItem

local function coerceValue(rawValue: string, targetType: string): Type?
	local coercedValue = rawValue

	-- Convert the raw value (string) to the given target type
	if targetType == "number" then
		coercedValue = tonumber(rawValue)
	elseif targetType == "boolean" then
		coercedValue = rawValue == "true"
	elseif targetType == "BrickColor" then
		warn("[PropertyChanger] BrickColor is not a supported property to change, use Color instead")
		coercedValue = nil
	elseif targetType == "Color3" then
		local r, g, b = rawValue:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
		if r and g and b then
			coercedValue = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
		else
			coercedValue = nil
		end
	elseif targetType == "EnumItem" then
		coercedValue = Enum[rawValue:match("^(%w+)%.(%w+)$")]
			and Enum[rawValue:match("^(%w+)%.(%w+)$")][rawValue:match("%w+$")]
	else
		coercedValue = nil
	end

	return coercedValue
end

local function setProperty(target: Instance, property: string, value: string)
	local success, err = pcall(function()
		local currentValue = target[property]
		target[property] = coerceValue(value, typeof(currentValue))
	end)

	if not success then
		error(
			`[PropertyChanger] Failed to set property '{property}' of {target.ClassName}'`
				.. ` at '{target:GetFullName()}': {tostring(err)}`
		)
	end
end

local function addTouchEvent(part: BasePart)
	debounceArray[part] = false

	local target = part:FindFirstChild("Target") :: ObjectValue
	if not target then
		return
	end

	if part.Name == "PropertyChanger" then
		local properties = part:FindFirstChild("Properties") :: Folder
		if not properties then
			return
		end

		local propertyList = {}

		for _, obj in pairs(properties:GetChildren()) do
			if not obj:IsA("Configuration") or obj.Name ~= "Property" then
				continue
			end

			local propertyName = obj:FindFirstChild("PropertyName") :: StringValue
			local propertyValue = obj:FindFirstChild("PropertyValue") :: StringValue
			local shouldTween = obj:FindFirstChild("Tween") :: BoolValue?
			local transitionDuration = obj:FindFirstChild("TransitionDuration") :: NumberValue?

			if not propertyName or not propertyValue then
				continue
			end

			table.insert(propertyList, {
				Name = propertyName.Value,
				Value = propertyValue.Value,
				Tween = shouldTween and shouldTween.Value or false,
				Duration = transitionDuration and transitionDuration.Value or 1,
			})
		end

		part.Touched:Connect(function(hit)
			if not hit.Parent or Players:GetPlayerFromCharacter(hit.Parent) ~= LocalPlayer or debounceArray[part] then
				return
			end

			debounceArray[part] = true

			for _, property in pairs(propertyList) do
				local currentValue = target.Value[property.Name]
				local newValue = coerceValue(property.Value, typeof(currentValue))

				if newValue == nil then
					continue
				end

				if property.Tween then
					TweenService:Create(
						target.Value,
						TweenInfo.new(property.Duration, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
						{ [property.Name] = newValue }
					):Play()
				else
					setProperty(target.Value, property.Name, property.Value)
				end
			end

			task.delay(0.1, function()
				debounceArray[part] = false
			end)
		end)
	elseif part.Name == "PropertyReverter" then
		local shouldTween = part:FindFirstChild("Tween") :: BoolValue?
		local transitionDuration = part:FindFirstChild("TransitionDuration") :: NumberValue?

		local savedProperties = {}
		local targetInstance = target.Value
		-- Capture initial instance state
		for _, property in pairs(WHITELISTED_PROPERTIES) do
			local success, value = pcall(function()
				return targetInstance[property]
			end)

			if success and SUPPORTED_TYPES[typeof(value)] then
				savedProperties[property] = value
			end
		end

		part.Touched:Connect(function(hit)
			if not hit.Parent or Players:GetPlayerFromCharacter(hit.Parent) ~= LocalPlayer or debounceArray[part] then
				return
			end

			debounceArray[part] = true

			for property, value in pairs(savedProperties) do
				local canTween = shouldTween and shouldTween.Value

				if canTween then
					local duration = transitionDuration and transitionDuration.Value or 1
					TweenService:Create(
						targetInstance,
						TweenInfo.new(duration, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
						{ [property] = value }
					):Play()
				else
					pcall(function()
						targetInstance[property] = value
					end)
				end
			end

			task.delay(0.1, function()
				debounceArray[part] = false
			end)
		end)
	end
end

return function()
	PropertyChangers.ChildAdded:Connect(function(child: Instance)
		if not child:IsA("BasePart") then
			return
		end

		child.Transparency = 1
		addTouchEvent(child)
	end)

	for _, obj in pairs(PropertyChangers:GetChildren()) do
		if obj:IsA("BasePart") then
			obj.Transparency = 1
			addTouchEvent(obj)
		end
	end
end
