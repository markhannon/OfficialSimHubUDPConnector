-- Extension created by Mark Hannon <mark.hannon@gmail.com>
--
-- Collects pit stop related state for every connected car, keyed by
-- driver name, and publishes it as a single JSON string once per second.
-- Sample outputs:
-- {"Mark Hannon":{"Fuel":49.732711791992,"LapCount":0,"IsRepairing":false,"IsChangingTyres":false,"IsRefueling":false,"IsRequestingPitStop":false,"CarIndex":0,"TyreCompound":"S","IsInPitlane":true,"IsInPit":false}}
---@diagnostic disable: param-type-mismatch

PitStopExtension = {}

-- Constant to define minimum time between updates
local MINIMUM_TIME_BETWEEN_UPDATES = 1

-- Accumulated time since the last update
local timeSinceLastUpdate = 0

-- Build the per-car data dictionary keyed by driver name
---@param car ac.StateCar
---@return table
local function carData(car)
    return {
        CarIndex = car.index,
        IsInPitlane = car.isInPitlane,
        IsInPit = car.isInPit,
        IsRequestingPitStop = car.isRequestingPitStop,
        IsRefueling = car.isRefueling,
        IsChangingTyres = car.isChangingTyres,
        IsRepairing = car.isRepairing,
        TyreCompound = ac.getTyresName(car.index, car.compoundIndex),
        Fuel = car.fuel,
        LapCount = car.lapCount,
    }
end

function PitStopExtension:update(dt, customData)
    timeSinceLastUpdate = timeSinceLastUpdate + dt
    if timeSinceLastUpdate < MINIMUM_TIME_BETWEEN_UPDATES then
        return
    end
    timeSinceLastUpdate = 0

    local pitStops = {}
    for _, car in ac.iterateCars() do
        if car.isConnected then
            local name = car:driverName()
            -- Fall back to the car index when the driver name is empty
            if name == nil or name == "" then
                name = "Car" .. car.index
            end
            pitStops[name] = carData(car)
        end
    end

    customData.PitStops = JSON.stringify(pitStops)
end

return PitStopExtension