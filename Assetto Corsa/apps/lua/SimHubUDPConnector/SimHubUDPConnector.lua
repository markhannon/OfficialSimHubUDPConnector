---@diagnostic disable: cast-local-type, duplicate-set-field, lowercase-global, need-check-nil, undefined-field
local appConfig = ac.INIConfig.load(ac.dirname() .. "/config.ini")
local socket = require('shared/socket')
local udp = socket.udp()
local DEBUG_ON = appConfig:get("debug", "log", false)
local customData
local carState = ac.getCar(0)
local cspVersion = ac.getPatchVersion()
local carScript = nil
local extensions = {}
local loadedExtensions = {}

local function loadLuaScript(scriptName, scriptFolder)
	local ret
	scriptPath = ac.dirname() .. "/" .. scriptFolder .. "/" .. scriptName
	if io.fileExists(scriptPath .. ".lua") then
		try(
			function() --try
				ret = require(scriptFolder:replace("/", ".") .. "." .. scriptName)
			end,
			function(err) --catch
				ac.debug("script " .. scriptName .. " ERROR ", err)
			end
		)
	else
		ac.debug("script not found", scriptName .. ".lua")
	end
	return ret
end

local function tryLoadCarConnection()
	local carId = ac.getCarID(0)
	local carFolder = "cars/" .. carId
	carScript = loadLuaScript("connection", carFolder)
end

for index, key in appConfig:iterateValues('extensions', "ext", false) do
	extensions[index] = appConfig:get("extensions", key, '')
end
local function loadExtensions()
	for k, ext in pairs(extensions) do
		loadedExtensions[ext] = loadLuaScript(ext, "extensions")
	end
end

local function contains(list, value)
	if list == nil then return false end
	for _, v in ipairs(list) do
		if v == value then
			return true
		end
	end
	return false
end

local function debugData(data)
	for k, v in pairs(data) do
		ac.debug(k, v)
	end
end

udp:settimeout(0)
udp:setpeername(appConfig:get("UDP", "host", "127.0.0.1"), appConfig:get("UDP", "port", 20777))
loadExtensions()
tryLoadCarConnection()

function addCarData(connection, struct, prefix, to, excludedFields)
	local propName
	for k, _ in pairs(struct) do
		if type(k) == "string" and not contains(excludedFields, k) then
			propName = prefix .. k:sub(1, 1):upper() .. k:sub(2)
			to[propName] = connection[k]
		end
	end
end

function addProp(prefix, obj, fieldName, to)
	local propName = prefix .. fieldName:sub(1, 1):upper() .. fieldName:sub(2)
	to[propName] = obj[fieldName]
end

function script.update(dt)
	if (carState == nil) then return end
	customData = {
		CSPVersion = cspVersion
	}

	for k, ext in pairs(loadedExtensions) do
		ext:update(dt, customData)
	end

	if (carScript ~= nil) then
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
