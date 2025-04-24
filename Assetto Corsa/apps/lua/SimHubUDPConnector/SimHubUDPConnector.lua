---@diagnostic disable: cast-local-type, duplicate-set-field, lowercase-global, need-check-nil, undefined-field
local appConfig = ac.INIConfig.load(ac.dirname() .. "/config.ini")

local socket = require('shared/socket')
local udp = socket.udp()
udp:settimeout(0)
udp:setpeername(appConfig:get("UDP", "host", "127.0.0.1"), appConfig:get("UDP", "port", 20777))
local DEBUG_ON = appConfig:get("debug", "log", false)
local customData
local carState = ac.getCar(0)
local cspVersion = ac.getPatchVersion()
local carScript = nil

function checkHasCarConnection()
	local carPath, ret
	local success = false
	local carId = ac.getCarID(0)
	carPath = ac.dirname() .. "/cars/" .. carId
	if io.fileExists(carPath .. "/connection.lua") then
		try(
			function() --try
				ret = require("cars." .. carId .. ".connection")
				if ret then
					success = true
					carScript = ret
				end
			end,
			function(err) --catch
				ac.debug("Car script ERROR: " .. err .. "\n" .. carPath)
				success = false
			end
		)
	end
	return success
end

local hasCarConnection = checkHasCarConnection()

local extensions = {} -- = {'LegacyDataExtension', 'CollisionsExtension', 'RoadRumbleExtension'}
local loadedExtensions = {}
function loadExtension(extName)
	local ret
	extPath = ac.dirname() .. "/extensions/" .. extName
	if io.fileExists(extPath .. ".lua") then
		try(
			function() --try
				ret = require("extensions." .. extName)
			end,
			function(err) --catch
				ac.debug("extension " .. extName .. " ERROR ", err)
			end
		)
	else
		ac.debug("extension not found", extName .. ".lua")
	end
	return ret
end

for index, key in appConfig:iterateValues('extensions', "ext", false) do
	extensions[index] = appConfig:get("extensions", key, '')
end
function loadExtensions()
	for k, ext in pairs(extensions) do
		loadedExtensions[ext] = loadExtension(ext)
	end
end

loadExtensions()

function addAllData(connection, struct, prefix, to)
	for k, _ in pairs(struct) do
		if type(k) == "string" then
			local name = prefix .. k:sub(1, 1):upper() .. k:sub(2)
			to[name] = connection[k]
		end
	end
end

local function debugData(data)
	for k, v in pairs(data) do
		ac.debug(k, v)
	end
end

function script.update(dt)
	if (carState == nil) then return end
	customData = {
		CSPVersion = cspVersion
	}

	for k, ext in pairs(loadedExtensions) do
		ext:update(dt, customData)
	end

	if (hasCarConnection) then
		carScript:carScript(customData)
	end
	local jsonData = JSON.stringify(customData)
	udp:send(jsonData)

	-- for debug only
	if DEBUG_ON then
		debugData(customData)
		-- ac.debug("jsonData", jsonData)
	end
end

function script.onStop()
	udp:close()
end
