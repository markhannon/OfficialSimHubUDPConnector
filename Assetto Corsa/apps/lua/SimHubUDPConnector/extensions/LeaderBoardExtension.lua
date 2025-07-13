-- Extension created by Mark Hannon <mark.hannon@gmail.com>
--
-- Generates leaderboard style properties for SimHub dashboards
-- that are missing from standard data.   Currently sends tyre
-- compound data as this is not available otherwise.
---@diagnostic disable: param-type-mismatch
require("extensions.Extension")

LeaderBoardExtension = {}

function LeaderBoardExtension:new(o)
	o = o or Extension:new(o)
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Constant to define minimum time between updates
local MINIMUM_TIME_BETWEEN_UPDATES = 1

-- helper function to format position with two digits
local function _idx(i)
	return string.format("%02d", tostring(i))
end

-- helper function to split cars table into one with
-- connected cars and one with unconnected cars
local function classifyCars(cars)
	local _connected = {}
	local _unconnected = {}
	for i, carIndex in ipairs(cars) do
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
local function sortCarsByTime(left, right)
	return ac.getCar(left).bestLapTimeMs < ac.getCar(right).bestLapTimeMs
end

-- Sort function to sort a table of car_ids by lapCount + splinePosition
-- Used in race sessions to determine position order.
local function sortCarsByPosition(left, right)
	return (ac.getCar(left).lapCount + ac.getCar(left).splinePosition) >
	(ac.getCar(right).lapCount + ac.getCar(right).splinePosition)
end

-- Table of cars used to store car_id in sorted list
-- Seperate tables for connected and unconnectedCars
local cars = {}
local carsConnected = {}
local carsNotConnected = {}
for i, car in ac.iterateCars() do
	table.insert(cars, car.index)
end

-- Timestamp to delay expensive sort operations
local timeSinceLastUpdate = 0

function LeaderBoardExtension:update(dt, customData)
	timeSinceLastUpdate = timeSinceLastUpdate + dt

	if (timeSinceLastUpdate > MINIMUM_TIME_BETWEEN_UPDATES) then

		-- Create seperate tables of connected and not-connected cars
		carsConnected, carsNotConnected = classifyCars(cars)

		-- Sort the connected car table as per appropriate rules for session.
		if (ac.getSim().raceSessionType == 3) then
			table.sort(carsConnected, sortCarsByPosition)
		else
			table.sort(carsConnected, sortCarsByTime)
		end

		-- Update the tyre data for connected cars
		for i, carIndex in ipairs(carsConnected) do
			car = ac.getCar(carIndex)
			customData["Position_" .. _idx(i) .. "_TyreCompound"] = ac.getTyresName(carIndex, car.compoundIndex)
		end

		-- Clear the tyre data for unconnected cars
		local offset = #carsConnected
		for i, carIndex in ipairs(carsNotConnected) do
			customData["Position_" .. _idx(i+offset) .. "_TyreCompound"] = nil
		end

		timeSinceLastUpdate = 0
	end
end

return LeaderBoardExtension
