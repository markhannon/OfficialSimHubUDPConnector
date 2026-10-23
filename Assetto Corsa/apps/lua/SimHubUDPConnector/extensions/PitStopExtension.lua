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
        LapCount = car.lapCount,
    }
end

-- Per-car stint tracking state keyed by car index
local stintState = {}

-- Build the per-car stint data: laps since the last pit stop and the
-- seconds spent in the pit box (car.isInPit) during the last/current stop
---@param car ac.StateCar
---@param elapsed number seconds since the previous update
---@return table
local function stintData(car, elapsed)
    local state = stintState[car.index]
    if state == nil then
        state = { pitLapCount = car.lapCount, secondsInPit = 0, wasInPit = false }
        stintState[car.index] = state
    end

    if car.isInPit then
        if not state.wasInPit then
            -- New stop: restart the timer
            state.secondsInPit = 0
        end
        state.secondsInPit = state.secondsInPit + elapsed
    elseif state.wasInPit then
        -- Stop finished: the stint starts from the current lap
        state.pitLapCount = car.lapCount
    end
    state.wasInPit = car.isInPit

    return {
        CarIndex = car.index,
        LapsSincePit = math.max(0, car.lapCount - state.pitLapCount),
        SecondsLastPit = state.secondsInPit,
    }
end

function PitStopExtension:update(dt, customData)
    timeSinceLastUpdate = timeSinceLastUpdate + dt
    if timeSinceLastUpdate < MINIMUM_TIME_BETWEEN_UPDATES then
        return
    end
    local elapsed = timeSinceLastUpdate
    timeSinceLastUpdate = 0

    local pitStops = {}
    local stints = {}
    for _, car in ac.iterateCars() do
        if car.isConnected then
            local name = car:driverName()
            -- Fall back to the car index when the driver name is empty
            if name == nil or name == "" then
                name = "Car" .. car.index
            end
            pitStops[name] = carData(car)
            stints[name] = stintData(car, elapsed)
        end
    end

    customData.PitStops = JSON.stringify(pitStops)
    customData.StintData = JSON.stringify(stints)
end

return PitStopExtension