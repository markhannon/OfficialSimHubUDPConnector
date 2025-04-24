carId = ac.getCarID(0)
Ignition_RSS = ac.connect({
    ac.StructItem.key(carId .. "_Ignition" .. "_" .. 0),
    Mode = ac.StructItem.int32()
}, true, ac.SharedNamespace.Shared)

local ECUKey = carId .. "_ecu"
local ECUsharedData = {
	ac.StructItem.key(ECUKey .. "_" .. 0),
	HedeSystemMessage = ac.StructItem.int32(),
	AutoClutch = ac.StructItem.int32(),
	DisableIgnitionSequence = ac.StructItem.int32()
}
ECU = ac.connect(ECUsharedData, false, ac.SharedNamespace.Shared)
ECU_Fields = {
    "HedeSystemMessage", "AutoClutch", "DisableIgnitionSequence"
}

carScript = function (customData)
		customData.IgnitionMode = Ignition_RSS.Mode
		addAllData(ECU, ECU_Fields, 'ECU_', customData)
		customData.ECU_Antistall = ac.getCarPhysics(0).scriptControllerInputs[6]
end