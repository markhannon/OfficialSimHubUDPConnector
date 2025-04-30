---@diagnostic disable: cast-local-type, duplicate-set-field, lowercase-global, need-check-nil, undefined-field

local AppSettings = ac.storage {
	log = false,
	autoUpdate = true
}

local UDPSettings = table.chain(
	{ host = '127.0.0.1', port = 20777 },
	stringify.tryParse(ac.storage.UDPSettings, {}))
---@diagnostic disable-next-line: inject-field
ac.storage.UDPSettings = stringify(UDPSettings)

local ExtensionsSettings
local ExtensionsSettingsLayout = {
	LegacyDataExtension = true,
	CollisionsExtension = true,
	RoadRumbleExtension = true,
	OnlineOvertakeExtension = false,
	TyreOptimalTempExtension = false,
	WheelExtension = false
}
local manifest = ac.INIConfig.load(ac.dirname() .. '/manifest.ini', ac.INIFormat.Extended)
local appVersion = manifest:get('ABOUT', 'VERSION', "0.0.0")
local socket = require('shared/socket')
local udp = socket.udp()
local debugOn = AppSettings.log and type(AppSettings.log) == "boolean" or
	false ---@type boolean
local customData
local carState = ac.getCar(0)
local cspVersion = ac.getPatchVersion()
local carScript = nil
local detectedExtensions = {} ---@type string[]
local loadedExtensions = {}
local repoVersion = "0.0.0"
local updatingApp = false
---Loads a lua script.
---@param scriptName string
---@param scriptFolder string
---@param silent boolean?
---@return unknown ret the loaded script or false.
local function loadLuaScript(scriptName, scriptFolder, silent)
	local ret
	scriptPath = ac.dirname() .. "/" .. scriptFolder .. "/" .. scriptName
	if io.fileExists(scriptPath .. ".lua") then
		try(
			function() --try
				ret = require(scriptFolder:replace("/", ".") .. "." .. scriptName)
			end,
			function(err) --catch
				print("script " .. scriptName .. " ERROR : " .. err)
			end
		)
	else
		if not silent then
			print("script not found : " .. scriptName .. ".lua")
		end
	end
	return ret
end

local function tryLoadCarConnection()
	local carId = ac.getCarID(0)
	local carFolder = "cars/" .. carId
	carScript = loadLuaScript("connection", carFolder, true)
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

local function loadExtensions()
	-- Scan for new extensions.
	io.scanDir(ac.dirname() .. "/extensions", function(fileName, fileAttributes, callbackData)
		local extName = fileName:replace(".lua", "")
		if extName ~= "Extension" and extName ~= "SampleUserExtension" then
			if ExtensionsSettingsLayout[extName] == nil then
				ExtensionsSettingsLayout[extName] = false
			end
			detectedExtensions[#detectedExtensions + 1] = extName
		end
	end)
	ExtensionsSettings = ac.storage(ExtensionsSettingsLayout)
	table.sort(detectedExtensions)
	for _, extName in pairs(detectedExtensions) do
		if ExtensionsSettings[extName] then
			loadedExtensions[extName] = loadLuaScript(extName, "extensions")
		end
	end
end

---Display all the properies in the lua debug app.
---@param data table list of properties to print. Usually that's customData the object sent to simhub.
local function debugData(data)
	for k, v in pairs(data) do
		ac.debug(k, v)
	end
end

---Write a file on disk
---@param file string relative path of the file
---@param content string content of the file
---@param folder string destinatin folder
local function writeFile(file, content, folder)
	local filename = folder .. "\\" .. file -- :match("/(.*)")
	filename = filename:replace("/", "\\")
	if not io.dirExists(filename) then
		io.createFileDir(filename)
	end
	-- print(filename)
	if io.save(filename, content) then
		-- print(filename .. " successfully written to disk")
	else
		print("Error writing " .. filename)
	end
end

---Update the app to a specific version
---@param version string
local function updateApp(version)
	updatingApp = true
---@diagnostic disable-next-line: inject-field
	ac.storage.updateToVersion = version
	local urlRelease = "https://github.com/Dasde/SimHubUDPConnector/releases/download/v" ..
		version .. "/SimHubUDPConnector.zip"
	web.get(urlRelease, function(errRelease, responseRelease)
		if errRelease then
			updatingApp = false
			print(errRelease)
			error(errRelease)
		end
		local acFolder = ac.getFolder(ac.FolderID.Root)
		local appFile, appContent
		for _, file in ipairs(io.scanZip(responseRelease.body)) do
			local content = io.loadFromZip(responseRelease.body, file)
			if content then
				if (file:endsWith("SimHubUDPConnector.lua") ) then
					appFile = file
					appContent = content
				else
					writeFile(file, content, acFolder)
				end
			end
		end
		if appContent then
			writeFile(appFile, appContent, acFolder)
		end
	end)
	updatingApp = false
end

local function getLatestVersion()
	local urlManifest =
	"https://raw.githubusercontent.com/Dasde/SimHubUDPConnector/refs/heads/main/Assetto%20Corsa/apps/lua/SimHubUDPConnector/manifest.ini"
	web.get(urlManifest, function(err, response)
		if err then print(error(err)) end
		local repoManifest = response.body
		if not repoManifest then return print('Missing manifest on the repo.') end
		repoVersion = ac.INIConfig.parse(repoManifest, ac.INIFormat.Extended):get('ABOUT', 'VERSION', "0.0.0")
		-- print(repoVersion)
	end)
end

local function checkForUpdate()
	if ac.storage.updateToVersion and ac.storage.updateToVersion:versionCompare(appVersion) == 0 then
		print("App successfully updated to version " .. appVersion)
---@diagnostic disable-next-line: inject-field
		ac.storage.updateToVersion = "0.0.0"
	end
	getLatestVersion()
	if repoVersion:versionCompare(appVersion) <= 0 then
		return
	end
	if AppSettings.autoUpdate then
		updateApp(repoVersion)
	end
end

udp:settimeout(0)
udp:setpeername(UDPSettings.host, UDPSettings.port)
checkForUpdate()
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

	for extName, ext in pairs(loadedExtensions) do
		try(function()
			ext:update(dt, customData)
		end, function(err)
			print("Extension " .. extName .. " generated an error : " .. err)
		end)
	end

	if (carScript ~= nil) then
		try(function()
			carScript:carScript(customData)
		end, function(err)
			print("Car script for " .. ac.getCarID(0) .. " generated an error : " .. err)
		end)
	end
	local jsonData = JSON.stringify(customData)
	udp:send(jsonData)

	-- for debug only
	if debugOn then
		debugData(customData)
		-- ac.debug("jsonData", jsonData)
	end
end

function script.onStop()
	udp:close()
end

function script.windowMain(dt)
	if updatingApp then
		ui.text("Updating app, please wait...")
		ui.newLine()
		ui.icon(ui.Icons.LoadingSpinner, 160)
		ui.newLine()
		return
	end
	ui.tabBar('someTabBarID', function()
		ui.tabItem('Extensions', function()
			for _, extName in pairs(detectedExtensions) do
				local value = ExtensionsSettings[extName]
				if ui.checkbox(extName, value) then
					if debugOn then
						ac.clearDebug()
					end
					customData = {}
					value = not value
					ExtensionsSettings[extName] = value
					if value then
						loadedExtensions[extName] = loadLuaScript(extName, "extensions")
					else
						loadedExtensions[extName] = nil
					end
				end
			end
		end)
		ui.tabItem('Settings', function()
			if ui.checkbox("Debug", debugOn) then
				if debugOn then
					ac.clearDebug()
				end
				debugOn = not debugOn
				AppSettings.log = debugOn
			end
			ui.text("Version " .. appVersion)
			if repoVersion:versionCompare(appVersion) > 0 then
				if not AppSettings.autoUpdate then
					ui.textColored("A new version (" .. repoVersion .. ") is available", rgbm.colors.red)
					if ui.button("Update...") then
						updateApp(repoVersion)
					end
				end
			else
				ui.textColored("The latest version is installed.", rgbm.colors.green)
				if ui.button("Reset app..", ui.ButtonFlags.Confirm) then
					getLatestVersion()
					updateApp(repoVersion)
				end
			end
			if ui.checkbox("Auto-Update", AppSettings.autoUpdate) then
				AppSettings.autoUpdate = not AppSettings.autoUpdate
			end
			ui.text("UDP Settings")
			local hostChanged
			UDPSettings.host, hostChanged = ui.inputText("host", UDPSettings.host,
				ui.InputTextFlags.CharsDecimal and ui.InputTextFlags.CharsNoBlank)
			if hostChanged then
				UDPSettingsChanged = true
			end
			local portChanged, udpPort
			udpPort, portChanged = ui.inputText("port", tostring(UDPSettings.port),
				ui.InputTextFlags.CharsDecimal and ui.InputTextFlags.CharsNoBlank)
			if portChanged then
				ac.debug("port : ", udpPort)
				UDPSettings.port = tonumber(udpPort)
				UDPSettingsChanged = true
			end
			if UDPSettingsChanged then
---@diagnostic disable-next-line: inject-field
				ac.storage.UDPSettings = stringify(UDPSettings)
				if ui.button("Restart UDP connection") then
					udp:close()
					udp:setpeername(UDPSettings.host, UDPSettings.port)
				end
			end
		end)
	end)
end
