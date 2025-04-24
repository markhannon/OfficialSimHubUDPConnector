carId = ac.getCarID(0)
Ignition_RSS = ac.connect({
    ac.StructItem.key(carId .. "_Ignition" .. "_" .. 0),
    Mode = ac.StructItem.int32()
}, true, ac.SharedNamespace.Shared)
GTMSystemKey = carId .. "_GTMSystem"
local ConnectsharedData = {
    ac.StructItem.key(GTMSystemKey .. "_" .. 0),
    KillFlag = ac.StructItem.boolean(),
    AntiStall = ac.StructItem.boolean(),
    AutoStart = ac.StructItem.boolean(),
    FuelTarget = ac.StructItem.float(),
    ThrottleMap = ac.StructItem.int32(),
    EngineStarter = ac.StructItem.boolean(),
    AutoClutch = ac.StructItem.boolean()
}
GTMSystem = ac.connect(ConnectsharedData, true, ac.SharedNamespace.Shared)
GTMSystem_Fields = {
    "KillFlag", "AntiStall", "AutoStart",
    "FuelTarget", "ThrottleMap",
    "EngineStarter", "AutoClutch"
}
CarSystemKey = carId .. "_CarSystem"
local CarSystemsharedData = {
    ac.StructItem.key(CarSystemKey .. "_" .. 0),
    EngineBrake = ac.StructItem.int32(),
    LaunchControl = ac.StructItem.boolean()
}
CarSystem = ac.connect(CarSystemsharedData, true, ac.SharedNamespace.Shared)
CarSystem_Fields = {
    "EngineBrake", "LaunchControl"
}

carScript = function (customData)
		customData.IgnitionMode = Ignition_RSS.Mode
		addAllData(GTMSystem, GTMSystem_Fields, 'GTMSystem_', customData)
		addAllData(CarSystem, CarSystem_Fields, 'CarSystem_', customData)
end