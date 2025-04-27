local connection = {}
local carId = ac.getCarID(0)
local Ignition_RSS = ac.connect({
    ac.StructItem.key(carId .. "_Ignition" .. "_" .. 0),
    Mode = ac.StructItem.int32()
}, true, ac.SharedNamespace.Shared)
local GTMSystemKey = carId .. "_GTMSystem"
local ConnectsharedData = {
    ac.StructItem.key(GTMSystemKey .. "_" .. 0),
    KillFlag = ac.StructItem.boolean(),
    AntiStall = ac.StructItem.boolean(),
    AutoStart = ac.StructItem.boolean(),
    FuelTarget = ac.StructItem.float(),
    ThrottleMap = ac.StructItem.int32(),
    EngineStarter = ac.StructItem.boolean(),
}
local GTMSystem = ac.connect(ConnectsharedData, true, ac.SharedNamespace.Shared)
local CarSystemKey = carId .. "_CarSystem"
local CarSystemsharedData = {
    ac.StructItem.key(CarSystemKey .. "_" .. 0),
    EngineBrake = ac.StructItem.int32(),
    LaunchControl = ac.StructItem.boolean()
}
local CarSystem = ac.connect(CarSystemsharedData, true, ac.SharedNamespace.Shared)

function connection:carScript(customData)
    customData.IgnitionMode = Ignition_RSS.Mode
    addCarData(GTMSystem, ConnectsharedData, 'GTMSystem_', customData)
    addCarData(CarSystem, CarSystemsharedData, 'CarSystem_', customData)
end

return connection
