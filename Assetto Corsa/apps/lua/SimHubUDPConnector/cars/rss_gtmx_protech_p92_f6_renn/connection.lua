local connection = {}
local carId = ac.getCarID(0)
local Ignition_RSS = ac.connect({
    ac.StructItem.key(carId .. "_Ignition" .. "_" .. 0),
    Mode = ac.StructItem.int32()
}, true, ac.SharedNamespace.Shared)

local GTMSystemKey = ac.getCarID(0) .. "_GTMSystem"
local ConnectsharedData = {
	ac.StructItem.key(GTMSystemKey .. "_" .. 0),
	AutoKill = ac.StructItem.boolean(),
	AntiStall = ac.StructItem.boolean(),
    AutoStart = ac.StructItem.boolean(),
    ThrottleMap = ac.StructItem.int32(),
    EngineStarter = ac.StructItem.boolean(),
    PitLimitSpeed = ac.StructItem.int32(),
	LaunchControl = ac.StructItem.boolean(),
	ICERunning = ac.StructItem.boolean(),
    AirJackPos = ac.StructItem.float(),
	HeadlightColor = ac.StructItem.int32()
}
local GTMSystem = ac.connect(ConnectsharedData, false, ac.SharedNamespace.Shared)

function connection:carScript(customData)
    customData.IgnitionMode = Ignition_RSS.Mode
    addCarData(GTMSystem, ConnectsharedData, 'GTMSystem_', customData)
end

return connection
