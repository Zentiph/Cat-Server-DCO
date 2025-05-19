-- Easing module by zen

-- Special thanks to https://easings.net for easing functions

local BACK_FACTOR = 1.70158
local TWO_THIRDS_PI = 2 * math.pi / 3
local FOUR_NINTHS_PI = 4 * math.pi / 9

local easing = {}

function easing.easeInSine(t: number): number
	return 1 - math.cos((t * math.pi) / 2)
end

function easing.easeOutSine(t: number): number
	return math.sin((t * math.pi) / 2)
end

function easing.easeInOutSine(t: number): number
	return -(math.cos(math.pi * t) - 1) / 2
end

function easing.easeLinear(t: number): number
	return t
end

function easing.easeInQuad(t: number): number
	return t * t
end

function easing.easeOutQuad(t: number): number
	return 1 - (1 - t) * (1 - t)
end

function easing.easeInOutQuad(t: number): number
	if t < 0.5 then
		return 2 * t * t
	end
	return 1 - math.pow(-2 * t + 2, 2) / 2
end

function easing.easeInCubic(t: number): number
	return t * t * t
end

function easing.easeOutCubic(t: number): number
	return 1 - math.pow(1 - t, 3)
end

function easing.easeInOutCubic(t: number): number
	if t < 0.5 then
		return 4 * t * t * t
	end
	return 1 - math.pow(-2 * t + 2, 3) / 2
end

function easing.easeInQuart(t: number): number
	return t * t * t * t
end

function easing.easeOutQuart(t: number): number
	return 1 - math.pow(1 - t, 4)
end

function easing.easeInOutQuart(t: number): number
	if t < 0.5 then
		return 8 * t * t * t * t
	end
	return 1 - math.pow(-2 * t + 2, 4) / 2
end

function easing.easeInQuint(t: number): number
	return t * t * t * t
end

function easing.easeOutQuint(t: number): number
	return 1 - math.pow(1 - t, 5)
end

function easing.easeInOutQuint(t: number): number
	if t < 0.5 then
		return 16 * t * t * t * t * t
	end
	return 1 - math.pow(-2 * t + 2, 5) / 2
end

function easing.easeInExpo(t: number): number
	if t == 0 then
		return 0
	end
	return math.pow(2, 10 * t - 10)
end

function easing.easeOutExpo(t: number): number
	if t == 1 then
		return 1
	end
	return 1 - math.pow(2, -10 * t)
end

function easing.easeInOutExpo(t: number): number
	if t == 0 then
		return 0
	end
	if t == 1 then
		return 1
	end
	if t < 0.5 then
		return math.pow(2, 20 * t - 10) / 2
	end
	return (2 - math.pow(2, -20 * t + 10)) / 2
end

function easing.easeInCirc(t: number): number
	return 1 - math.sqrt(1 - math.pow(t, 2))
end

function easing.easeOutCirc(t: number): number
	return math.sqrt(1 - math.pow(t - 1, 2))
end

function easing.easeInOutCirc(t: number): number
	if t < 0.5 then
		return (1 - math.sqrt(1 - math.pow(2 * t, 2))) / 2
	end
	return (math.sqrt(1 - math.pow(-2 * t + 2, 2)) + 1) / 2
end

function easing.easeInBack(t: number): number
	return (BACK_FACTOR + 1) * t * t * t - BACK_FACTOR * t * t
end

function easing.easeOutBack(t: number): number
	return 1 + (BACK_FACTOR + 1) * math.pow(t - 1, 3) + BACK_FACTOR * math.pow(t - 1, 2)
end

function easing.easeInOutBack(t: number): number
	local backConst = BACK_FACTOR * 1.525
	if t < 0.5 then
		return (math.pow(2 * t, 2) * ((backConst + 1) * 2 * t - backConst)) / 2
	end
	return (math.pow(2 * t - 2, 2) * ((backConst + 1) * (t * 2 - 2) + backConst) + 2) / 2
end

function easing.easeInElastic(t: number): number
	if t == 0 then
		return 0
	end
	if t == 1 then
		return 1
	end
	return -math.pow(2, 10 * t - 10) * math.sin((t * 10 - 10.75) * TWO_THIRDS_PI)
end

function easing.easeOutElastic(t: number): number
	if t == 0 then
		return 0
	end
	if t == 1 then
		return 1
	end
	return math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * TWO_THIRDS_PI) + 1
end

function easing.easeInOutElastic(t: number): number
	if t == 0 then
		return 0
	end
	if t == 1 then
		return 1
	end
	if t < 0.5 then
		return -(math.pow(2, 20 * t - 10) * math.sin((20 * t - 11.125) * FOUR_NINTHS_PI)) / 2
	end
	return (math.pow(2, -20 * t + 10) * math.sin((20 * t - 11.125) * FOUR_NINTHS_PI)) / 2 + 1
end

function easing.easeInBounce(t: number): number
	return 1 - easing.easeOutBounce(1 - t)
end

function easing.easeOutBounce(t: number): number
	local heightFactor = 7.5625
	local durationFactor = 2.75

	if t < 1 / durationFactor then
		return heightFactor * t * t
	end
	if t < 2 / durationFactor then
		t -= 1.5
		return heightFactor * (t / durationFactor) * t + 0.75
	end
	if t < 2.5 / durationFactor then
		t -= 2.25
		return heightFactor * (t / durationFactor) * t + 0.9375
	end
	t -= 2.625
	return heightFactor * (t / durationFactor) * t + 0.984375
end

function easing.easeInOutBounce(t: number): number
	if t < 0.5 then
		return (1 - easing.easeOutBounce(1 - 2 * t)) / 2
	end
	return (1 + easing.easeOutBounce(2 * t - 1)) / 2
end

--[[
Get the easing function based on the easing style and direction.
@param easingStyle - The easing style (e.g., "Linear", "Quad", "Cubic", etc.)
@param easingDirection - The easing direction (e.g., "In", "Out", "InOut")
@return A function that takes a number (0 to 1) and returns the eased value
]]
function easing.getEasingFunction(easingStyle: string, easingDirection: string): (number) -> number
	-- Normalize casing
	easingStyle = easingStyle:sub(1, 1):upper() .. easingStyle:sub(2):lower()
	if easingDirection:lower() == "inout" then
		easingDirection = "InOut"
	else
		easingDirection = easingDirection:sub(1, 1):upper() .. easingDirection:sub(2):lower()
	end

	if easingStyle == "Linear" then
		return easing.easeLinear
	end

	local functionName = "ease" .. easingDirection .. easingStyle
	local func = easing[functionName]
	if typeof(func) == "function" then
		return func
	end

	warn(`Unknown easing function '{functionName}', falling back to linear easing.`)
	return easing.easeLinear
end

--[[
Convert an easing style and direction and duration to a TweenInfo.

@param easingStyle - The easing style (e.g., "Linear", "Quad", "Cubic", etc.)
@param easingDirection - The easing direction (e.g., "In", "Out", "InOut")
@param duration - The duration of the tween in seconds
@return TweenInfo - The TweenInfo object with the specified easing style, direction, and duration
]]
function easing.toTweenInfo(easingStyle: string, easingDirection: string, duration: number): TweenInfo
	local styleEnum = Enum.EasingStyle[easingStyle]
	if not styleEnum then
		styleEnum = Enum.EasingStyle.Linear
	end

	local directionEnum = Enum.EasingDirection[easingDirection]
	if not directionEnum then
		directionEnum = Enum.EasingDirection.InOut
	end

	return TweenInfo.new(duration, styleEnum, directionEnum)
end

return easing
