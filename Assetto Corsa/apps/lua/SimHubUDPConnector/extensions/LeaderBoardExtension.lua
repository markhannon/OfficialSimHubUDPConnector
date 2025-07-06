-- Extension created by Mark Hannon
-- Does not work with replays
---@diagnostic disable: param-type-mismatch
require("extensions.Extension")

LeaderBoardExtension = {}

function LeaderBoardExtension:new(o)
	o = o or Extension:new(o)
	setmetatable(o, self)
	self.__index = self
	return o
end

local lastPitTime = {}
local lastPitLap = {}
local pitTimer = {}
for i, c in ac.iterateCars.leaderboard() do
	lastPitTime[c.index] = 0
	lastPitLap[c.index] = 0
	pitTimer[c.index] = 0
end

local function toIndex(i)
	return string.format("%02d",tostring(i))
end

function LeaderBoardExtension:update(dt, customData)

	for i, c in ac.iterateCars.leaderboard() do

		if (c.isConnected == true) then
			customData["Position_" .. toIndex(i) .. "_IsConnected"] = true
			customData["Position_" .. toIndex(i) .. "_DriverName"] = ac.getDriverName(c.index)
			if (c.isInPit == true and pitTimer[c.index] == 0) then
				ac.console(ac.getDriverName(c.index) .. " entering the pits")
				lastPitLap[c.index] = c.lapCount
			end
			if (c.isInPit == true) then
				pitTimer[c.index] = pitTimer[c.index] + dt
			end
			if (c.isInPit ~= true and pitTimer[c.index] ~= 0) then
				lastPitTime[c.index] = pitTimer[c.index]
				pitTimer[c.index] = 0
				if (c.lapCount > 0) then
					ac.console(ac.getDriverName(c.index) .. " leaving the pits")
					-- customData["Position_" .. toIndex(i) .. "_LastPitTime"] = tonumber(string.format("%.1f", lastPitTime[c.index]))
					customData["Position_" .. toIndex(i) .. "_LastPitTime"] = lastPitTime[c.index]
					customData["Position_" .. toIndex(i) .. "_LastPitLap"] = lastPitLap[c.index]
				end
			end
			customData["Position_" .. toIndex(i) .. "_IsInPit"] = c.isInPit
			customData["Position_" .. toIndex(i) .. "_LapCount"] = c.lapCount
			customData["Position_" .. toIndex(i) .. "_Number"] = ac.getDriverNumber(c.index)
			customData["Position_" .. toIndex(i) .. "_TyreCompound"] = ac.getTyresName(c.index, c.compoundIndex)
		else
			customData["Position_" .. toIndex(i) .. "_IsConnected"] = false
		end
		
	end

end

return LeaderBoardExtension