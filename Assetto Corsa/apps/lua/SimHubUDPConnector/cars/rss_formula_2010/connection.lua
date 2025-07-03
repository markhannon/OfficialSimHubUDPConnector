local connection = {}
local carId = ac.getCarID(0)
local Ignition_RSS = ac.connect({
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
local ECU = ac.connect(ECUsharedData, true, ac.SharedNamespace.Shared)

function connection:carScript(customData)
    customData.IgnitionMode = Ignition_RSS.Mode
    addCarData(ECU, ECUsharedData, 'ECU_', customData)
end

return connection
