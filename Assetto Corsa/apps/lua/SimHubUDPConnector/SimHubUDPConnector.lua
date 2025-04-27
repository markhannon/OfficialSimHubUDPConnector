---@diagnostic disable: cast-local-type, duplicate-set-field, lowercase-global, need-check-nil, undefined-field
local appConfig = ac.INIConfig.load(ac.dirname() .. "/config.ini") ---@type ac.INIConfig
local socket = require('shared/socket')
local udp = socket.udp()
local DEBUG_ON = appConfig:get("debug", "log", false) ---@type boolean
local customData
local carState = ac.getCar(0)
local cspVersion = ac.getPatchVersion()
local carScript = nil
local extensions = {}
local loadedExtensions = {}

---Loads a lua script.
---@param scriptName string
---@param scriptFolder string
---@return unknown ret the loaded script or false.
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

---Check if a list contains a value.
---@param list table?
---@param value string
---@return boolean
local function contains(list, value)
	if list == nil then return false end
	for _, v in ipairs(list) do
		if v == value then
			return true
		end
	end
	return false
end

---Display all the properies in the lua debug app.
---@param data table list of properties to print. Usually that's customData the object sent to simhub.
local function debugData(data)
	for k, v in pairs(data) do
		ac.debug(k, v)
	end
end

udp:settimeout(0)
udp:setpeername(appConfig:get("UDP", "host", "127.0.0.1"), appConfig:get("UDP", "port", 20777))
loadExtensions()
tryLoadCarConnection()

---Add the car script data to a list.
---@param connection any ac.connect connection to the car script.
---@param struct table layout/structure used for the ac.connect.
---@param prefix string a prefix to add to the properties name.
---@param to table list to add the properties to. Usually that's customData the object sent to simhub.
---@param excludedFields table? @Optional a list of fields to exclude from the exported list.
function addCarData(connection, struct, prefix, to, excludedFields)
	local propName
	for k, _ in pairs(struct) do
		if type(k) == "string" and not contains(excludedFields, k) then
			propName = prefix .. k:sub(1, 1):upper() .. k:sub(2)
			to[propName] = connection[k]
		end
	end
end

---Add a property to a list.
---@param prefix string a prefix to add to the properties name.
---@param obj table object that holds the field.
---@param fieldName string name of the field to add as a property.
---@param to any
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
