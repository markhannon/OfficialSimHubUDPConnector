-- Extension created by Mark Hannon <mark.hannon@gmail.com>
--
-- Generates leaderboard style properties for SimHub dashboards
---@diagnostic disable: param-type-mismatch
require("extensions.Extension")

LeaderBoardExtension = {}

function LeaderBoardExtension:new(o)
	o = o or Extension:new(o)
	setmetatable(o, self)
	self.__index = self
	return o
end

-- helper function to format position with two digits
local function _idx(i)
	return string.format("%02d", tostring(i))
end

-- Lap of the last pit stop (indexed by car_id)
local lastPitLap = {}
-- Number of seconds in the last pit stop (indexed by car_id)
local lastPitTime = {}
-- Number of seconds in pit for this stop (indexed by car_id)
local thisPitTime = {}
-- Number of times car has pitted (indexed by car_id)
local pitStops = {}

-- Table of cars used to store car_id in sorted list
local allCars = {}

local connectedCars = {}
local unconnectedCars = {}

for i, c in ac.iterateCars() do
	table.insert(allCars, c.index)
	lastPitLap[c.index] = 0
	lastPitTime[c.index] = 0
	thisPitTime[c.index] = 0
	pitStops[c.index] = 0
end

-- Filter function to remove all non connected cars from table
local function filterConnectedCars(allCars)
	local _connected = {}
	local _unconnected = {}
	for i, carIndex in ipairs(allCars) do
		if (ac.getCar(carIndex).isConnected == true) then
			table.insert(_connected, carIndex)
		else
			table.insert(_unconnected, carIndex)
		end
	end
	return _connected, _unconnected
end

-- Sort function to sort a table of car_ids by bestLapTimeMs
-- Used in practice and qualify sessions
local function sortCarsByBestLapTimeMs(left, right)
	return ac.getCar(left).bestLapTimeMs < ac.getCar(right).bestLapTimeMs
end

-- Sort function to sort a table of car_ids by totalSpline.
-- Used in race sessions
local function sortCarsByTotalSpline(left, right)
	return (ac.getCar(left).lapCount + ac.getCar(left).splinePosition) >
		(ac.getCar(right).lapCount + ac.getCar(right).splinePosition)
end

-- Timestamp to delay expensive sort operations
local timeSinceLastUpdate = 0

-- Minimum time between updates
local minimumTimeBetweenUpdates = 0.3

function LeaderBoardExtension:update(dt, customData)
	timeSinceLastUpdate = timeSinceLastUpdate + dt
	for i, c in ac.iterateCars() do
		if (c.isInPit == true and thisPitTime[c.index] == 0) then
			lastPitLap[c.index] = c.lapCount
			pitStops[c.index] = pitStops[c.index] + 1
		end
		if (c.isInPit == true) then
			thisPitTime[c.index] = thisPitTime[c.index] + dt
		end
		if (c.isInPit ~= true and thisPitTime[c.index] ~= 0) then
			lastPitTime[c.index] = thisPitTime[c.index]
			thisPitTime[c.index] = 0
		end
	end
	if (timeSinceLastUpdate > minimumTimeBetweenUpdates) then
		connectedCars, unconnectedCars = filterConnectedCars(allCars)
		if (ac.getSessionName(ac.getSim().currentSessionIndex) == 'Race') then
			table.sort(connectedCars, sortCarsByTotalSpline)
			customData.LeaderBoardExtensionSession = 'Race'
		else
			table.sort(connectedCars, sortCarsByBestLapTimeMs)
			customData.LeaderBoardExtensionSession = 'Practice or Qualify'
		end

		for i, carIndex in ipairs(connectedCars) do
			car = ac.getCar(carIndex)
			customData["Position_" .. _idx(i) .. "_IsConnected"] = true
			customData["Position_" .. _idx(i) .. "_DriverName"] = ac.getDriverName(carIndex)
			customData["Position_" .. _idx(i) .. "_Number"] = ac.getDriverNumber(carIndex)
			customData["Position_" .. _idx(i) .. "_IsInPit"] = car.isInPit
			customData["Position_" .. _idx(i) .. "_LapCount"] = car.lapCount
			customData["Position_" .. _idx(i) .. "_TyreCompound"] = ac.getTyresName(carIndex, car.compoundIndex)
			customData["Position_" .. _idx(i) .. "_LastPitTime"] = math.floor(lastPitTime[carIndex]+0.5)
			customData["Position_" .. _idx(i) .. "_LastPitLap"] = lastPitLap[carIndex]
			customData["Position_" .. _idx(i) .. "_PitStops"] = pitStops[carIndex]
		end

		local offset = #connectedCars
		for i, carIndex in ipairs(unconnectedCars) do
			customData["Position_" .. _idx(i+offset) .. "_IsConnected"] = false
			customData["Position_" .. _idx(i+offset) .. "_DriverName"] = nil
			customData["Position_" .. _idx(i+offset) .. "_Number"] = nil
			customData["Position_" .. _idx(i+offset) .. "_IsInPit"] = nil
			customData["Position_" .. _idx(i+offset) .. "_LapCount"] = nil
			customData["Position_" .. _idx(i+offset) .. "_TyreCompound"] = nil
			customData["Position_" .. _idx(i+offset) .. "_LastPitTime"] = nil
			customData["Position_" .. _idx(i+offset) .. "_LastPitLap"] = nil
			customData["Position_" .. _idx(i+offset) .. "_PitStops"] = nil
		end

		timeSinceLastUpdate = 0
	end
end

return LeaderBoardExtension
