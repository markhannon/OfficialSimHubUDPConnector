require("extensions.Extension")

RoadRumbleExtension = {}

function RoadRumbleExtension:new (o)
    o = o or Extension:new(o)
    setmetatable(o, self)
    self.__index = self
    return o
 end

local carState = ac.getCar(0)
local wheelsState = carState.wheels -- required for the Road Rumble Effect
local carPhysics = ac.getCarPhysics(0)
local cspVersion = ac.getPatchVersion()

-- this function is required for the Road Rumble effect
local function getSurface(surfaceId)
	if (surfaceId == 0) then
		do return 'Base' end
	elseif (surfaceId == 1) then
		do return 'ExtraTurf' end
	elseif (surfaceId == 2) then
		do return 'Grass' end
	elseif (surfaceId == 3) then
		do return 'Gravel' end
	elseif (surfaceId == 4) then
		do return 'Kerb' end
	elseif (surfaceId == 5) then
		do return 'Old' end
	elseif (surfaceId == 6) then
		do return 'Sand' end
	elseif (surfaceId == 7) then
		do return 'Ice' end
	elseif (surfaceId == 8) then
		do return 'Snow' end
	else
		do return 'Unknown' end
	end
end
-- end

function RoadRumbleExtension:update(dt, customData)
    -- this part is required for the Road Rumble effect (only SurfaceVibrationGain)
    customData.WheelFLSurfaceVibrationGain = wheelsState[0].surfaceVibrationGain
    customData.WheelFLSurfaceVibrationLength = wheelsState[0].surfaceVibrationLength
    customData.WheelFLTyreOptimumTemperature = wheelsState[0].tyreOptimumTemperature
    customData.WheelFLSlipAngle = wheelsState[0].slipAngle
    customData.WheelFLSpeedDifference = wheelsState[0].speedDifference
    customData.WheelFLTyreCarcassTemperature = carPhysics.wheels[0].tyreCarcassTemperature
    customData.WheelFRSurfaceVibrationGain = wheelsState[1].surfaceVibrationGain
    customData.WheelFRSurfaceVibrationLength = wheelsState[1].surfaceVibrationLength
    customData.WheelFRTyreOptimumTemperature = wheelsState[1].tyreOptimumTemperature
    customData.WheelFRSlipAngle = wheelsState[1].slipAngle
    customData.WheelFRSpeedDifference = wheelsState[1].speedDifference
    customData.WheelFRTyreCarcassTemperature = carPhysics.wheels[1].tyreCarcassTemperature
    customData.WheelRLSurfaceVibrationGain = wheelsState[2].surfaceVibrationGain
    customData.WheelRLSurfaceVibrationLength = wheelsState[2].surfaceVibrationLength
    customData.WheelRLTyreOptimumTemperature = wheelsState[2].tyreOptimumTemperature
    customData.WheelRLSlipAngle = wheelsState[2].slipAngle
    customData.WheelRLSpeedDifference = wheelsState[2].speedDifference
    customData.WheelRLTyreCarcassTemperature = carPhysics.wheels[2].tyreCarcassTemperature
    customData.WheelRRSurfaceVibrationGain = wheelsState[3].surfaceVibrationGain
    customData.WheelRRSurfaceVibrationLength = wheelsState[3].surfaceVibrationLength
    customData.WheelRRTyreOptimumTemperature = wheelsState[3].tyreOptimumTemperature
    customData.WheelRRSlipAngle = wheelsState[3].slipAngle
    customData.WheelRRSpeedDifference = wheelsState[3].speedDifference
    customData.WheelRRTyreCarcassTemperature = carPhysics.wheels[3].tyreCarcassTemperature
    -- end
    ---@diagnostic disable-next-line: param-type-mismatch
	if (cspVersion.versionCompare(cspVersion, "0.2.7") > -1) then
		-- this part is required for the Road Rumble effect
		customData.WheelFLSurface = getSurface(wheelsState[0].surfaceExtendedType)
		customData.WheelFRSurface = getSurface(wheelsState[1].surfaceExtendedType)
		customData.WheelRLSurface = getSurface(wheelsState[2].surfaceExtendedType)
		customData.WheelRRSurface = getSurface(wheelsState[3].surfaceExtendedType)
		-- end
	else
		customData.WheelSurfaceError = "Please upgrade your csp to version 0.2.7 min."
	end
end

return RoadRumbleExtension