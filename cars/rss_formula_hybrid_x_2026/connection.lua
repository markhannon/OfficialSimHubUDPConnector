carId = ac.getCarID(0)
Ignition_RSS = ac.connect({
    ac.StructItem.key(carId .. "_Ignition" .. "_" .. 0),
    Mode = ac.StructItem.int32()
}, true, ac.SharedNamespace.Shared)
FHSystemKey = "Formula_Hybrid_System"
local FHSystemsharedData = {
    ac.StructItem.key(FHSystemKey .. "_" .. 0),
    BrakeMigration = ac.StructItem.float(),
    BrakeMigrationRamp = ac.StructItem.float(),
    DiffEntry = ac.StructItem.int32(),
    DiffMid = ac.StructItem.int32(),
    DiffExit = ac.StructItem.int32(),
    DiffExitSpeed = ac.StructItem.int32(),
    FuelTarget = ac.StructItem.float(),
    StartMode = ac.StructItem.boolean(),
    AntiStall = ac.StructItem.boolean()
}
FHSystem = ac.connect(FHSystemsharedData, true, ac.SharedNamespace.Shared)
FHSystem_Fields = {
    "BrakeMigration", "BrakeMigrationRamp", "DiffEntry", "DiffMid",
    "DiffExit", "DiffExitSpeed", "FuelTarget", "StartMode", "AntiStall"
}

carScript = function (customData)
		customData.IgnitionMode = Ignition_RSS.Mode
		addAllData(FHSystem, FHSystem_Fields, 'FHSystem_', customData)
end