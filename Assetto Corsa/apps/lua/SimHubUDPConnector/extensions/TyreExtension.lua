-- Extension created by Mark Hannon <mark.hannon@gmail.com>
--
-- Does not work with replays
-- 
-- Compute the optimal tyre temperature
-- Generates leaderboard style properties for SimHub dashboards
-- that are missing from standard data.   Currently sends tyre
-- compound data as this is not available otherwise. 
---@diagnostic disable: param-type-mismatch

TyreExtension = {}

local carState = ac.getCar(0)
local carsUtils = require('shared/sim/cars') -- required for tyre.ini data
local wheelsState = carState.wheels ---@type ac.StateWheel

---Return an estimated maximumOptimalTemperature based on compoundName
---and the basic minimalOptimalTemperature.   Simple algorithm based on
---name of the compound and known characteristics.
---
---@param compoundName string name of the compound
---@param minTemp number minimalOptimalTemperature
---@return number|nil maximumOptimalTemperature
local function maximumOptimalTemperature(compoundName, minTemp)
	if (compoundName == nil) then
		-- in replays those values are nil
		return nil
	end
	if string.find(compoundName, "Street") then
		return minTemp + 10
	elseif string.find(compoundName, "Intermediate") then
		return minTemp + 10
	elseif string.find(compoundName, "Wet") then
		return minTemp + 10
	elseif string.find(compoundName, "Super") then
		return minTemp + 15
	elseif string.find(compoundName, 'Soft') then
		return minTemp + 20
	elseif string.find(compoundName, 'Medium') then
		return minTemp + 20
	elseif string.find(compoundName, 'Hard') then
		return minTemp + 25
	else
		return minTemp + 30
	end
end
--- END

-- Constant to define minimum time between updates
local MINIMUM_TIME_BETWEEN_UPDATES = 0.2

-- helper function to format position with two digits
local function _idx(i)
	return string.format("%02d", tostring(i))
end

local function hasValidBestLapTime(bestLapTimeMs)
	return bestLapTimeMs ~= nil and bestLapTimeMs > 0
end

local function isRaceSession()
	return ac.getSim().raceSessionType == 3
end

local function makeLeaderboardEntry(car)
	return {
		car = car,
		driverName = ac.getDriverName(car.index) or "",
		bestLapTimeMs = car.bestLapTimeMs
	}
end

local function hasDriverName(entry)
	return entry.driverName ~= ""
end

local function shouldIncludePracticeQualifyingEntry(entry)
	if not hasDriverName(entry) then
		return false
	end

	return entry.car.isConnected or hasValidBestLapTime(entry.bestLapTimeMs)
end

local function sortPracticeQualifyingEntries(entries)
	table.sort(entries, function(left, right)
		local leftHasValidTime = hasValidBestLapTime(left.bestLapTimeMs)
		local rightHasValidTime = hasValidBestLapTime(right.bestLapTimeMs)

		if leftHasValidTime ~= rightHasValidTime then
			return leftHasValidTime
		end

		if leftHasValidTime and rightHasValidTime and left.bestLapTimeMs ~= right.bestLapTimeMs then
			return left.bestLapTimeMs < right.bestLapTimeMs
		end

		if left.car.isConnected ~= right.car.isConnected then
			return left.car.isConnected
		end

		if left.driverName ~= right.driverName then
			return left.driverName < right.driverName
		end

		return left.car.index < right.car.index
	end)
end

local function buildLeaderboardEntries()
	local entries = {}
	for i, car in ac.iterateCars.leaderboard() do
		local entry = makeLeaderboardEntry(car)
		if isRaceSession() then
			table.insert(entries, entry)
		elseif shouldIncludePracticeQualifyingEntry(entry) then
			table.insert(entries, entry)
		end
	end

	if not isRaceSession() then
		sortPracticeQualifyingEntries(entries)
	end

	return entries
end

-- Timestamp to delay expensive sort operations
local timeSinceLastUpdate = 0
local lastPublishedLeaderboardCount = 0

function TyreExtension:update(dt, customData)
	customData.TyreCompound = ac.getTyresName(0, carState.compoundIndex)
	customData.IdealPressureFront = carsUtils.getTyreConfigValue(carState.compoundIndex, true, "PRESSURE_IDEAL", 0)
	customData.IdealPressureRear = carsUtils.getTyreConfigValue(carState.compoundIndex, false, "PRESSURE_IDEAL", 0)
	customData.MinimumOptimalTemperature = wheelsState[0].tyreOptimumTemperature
	customData.MaximumOptimalTemperature = maximumOptimalTemperature(customData.TyreCompound,
		customData.MinimumOptimalTemperature)
	if ac.getPatchVersionCode() >= 3334 then
		-- if (cspVersion:versionCompare("0.2.7") > -1) then
		-- TemperatureMultiplier shows fraction of optimum grip
		customData.WheelFLTemperatureMultiplier = wheelsState[0].temperatureMultiplier
		customData.WheelFRTemperatureMultiplier = wheelsState[1].temperatureMultiplier
		customData.WheelRLTemperatureMultiplier = wheelsState[2].temperatureMultiplier
		customData.WheelRRTemperatureMultiplier = wheelsState[3].temperatureMultiplier
		-- IsHot shows if the tyres is considered hot
		customData.WheelFLIsHot = wheelsState[0].isHot
		customData.WheelFRIsHot = wheelsState[1].isHot
		customData.WheelRLIsHot = wheelsState[2].isHot
		customData.WheelRRIsHot = wheelsState[3].isHot
	else
		customData.TyreOptimalTempExtensionError = "Please upgrade your csp to version 0.2.7 min."
	end

	-- Leaderboard
	timeSinceLastUpdate = timeSinceLastUpdate + dt
	if (timeSinceLastUpdate > MINIMUM_TIME_BETWEEN_UPDATES) then
		local leaderboardEntries = buildLeaderboardEntries()

		for i, entry in ipairs(leaderboardEntries) do
			customData["Position_" .. _idx(i) .. "_TyreCompound"] = ac.getTyresName(entry.car.index,
				entry.car.compoundIndex)
		end

		for i = #leaderboardEntries + 1, lastPublishedLeaderboardCount do
			customData["Position_" .. _idx(i) .. "_TyreCompound"] = nil
		end

		lastPublishedLeaderboardCount = #leaderboardEntries
		timeSinceLastUpdate = 0
	end
end

return TyreExtension
