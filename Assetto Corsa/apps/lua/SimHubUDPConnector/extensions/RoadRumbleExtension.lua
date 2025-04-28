require("extensions.Extension")

RoadRumbleExtension = {}

function RoadRumbleExtension:new(o)
    o = o or Extension:new(o)
    setmetatable(o, self)
    self.__index = self
    return o
end

local carState = ac.getCar(0)
local wheelsState = carState.wheels ---@type ac.StateWheel
local carPhysics = ac.getCarPhysics(0)
-- local cspVersion = ac.getPatchVersion()

---Returns the surface name.
---@param surfaceId integer
---@return string surfaceName
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
    customData.WheelFLSurfaceVibrationGain = wheelsState[0].surfaceVibrationGain
    customData.WheelFLSurfaceVibrationLength = wheelsState[0].surfaceVibrationLength
    customData.WheelFRSurfaceVibrationGain = wheelsState[1].surfaceVibrationGain
    customData.WheelFRSurfaceVibrationLength = wheelsState[1].surfaceVibrationLength
    customData.WheelRLSurfaceVibrationGain = wheelsState[2].surfaceVibrationGain
    customData.WheelRLSurfaceVibrationLength = wheelsState[2].surfaceVibrationLength
    customData.WheelRRSurfaceVibrationGain = wheelsState[3].surfaceVibrationGain
    customData.WheelRRSurfaceVibrationLength = wheelsState[3].surfaceVibrationLength
    if ac.getPatchVersionCode() >= 3334 then
        -- if (cspVersion:versionCompare("0.2.7") > -1) then
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
