local connection = {}
local carId = ac.getCarID(0)
local ECU_Vorax_Struct = {
	ac.StructItem.key(carId .. "_ext_car_" .. 0),
	connected = ac.StructItem.boolean(),
	oilTemperature = ac.StructItem.float(),
	antirollBarFrontPosition = ac.StructItem.int16(),
	antirollBarRearPosition = ac.StructItem.int16(),
	brakeBiasPosition = ac.StructItem.int16(),
	isIgnitionOn = ac.StructItem.boolean(),
	isElectronicsBooted = ac.StructItem.boolean(),
	isStarterCranking = ac.StructItem.boolean(),
	isEngineStarted = ac.StructItem.boolean(),
	isEngineRunning = ac.StructItem.boolean(),
}
local ECU_Vorax = ac.connect(ECU_Vorax_Struct, true, ac.SharedNamespace.CarScript)

local INPUTS_Vorax_Struct = {
	ac.StructItem.key(carId .. "_ext_input_" .. 0),
	connected = ac.StructItem.boolean(),
	gas = ac.StructItem.float(),
}
local INPUTS_Vorax = ac.connect(INPUTS_Vorax_Struct, true, ac.SharedNamespace.CarScript)

function connection:carScript(customData)
	addCarData(ECU_Vorax, ECU_Vorax_Struct, 'ECU_', customData)
	addCarData(INPUTS_Vorax, INPUTS_Vorax_Struct, 'INPUTS_', customData)
end

return connection