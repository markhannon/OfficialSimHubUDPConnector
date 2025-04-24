carId = ac.getCarID(0)
ECU_Pageau = ac.connect({
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
}, true, ac.SharedNamespace.CarScript)
ECU_Pageau_fields = {
	"connected", "oilTemperature", "antirollBarFrontPosition", "antirollBarRearPosition",
	"brakeBiasPosition", "isIgnitionOn", "isElectronicsBooted", "isStarterCranking",
	"isEngineStarted", "isEngineRunning",
}

INPUTS_Pageau = ac.connect({
	ac.StructItem.key(carId .. "_ext_input_" .. 0),
	connected = ac.StructItem.boolean(),
	gas = ac.StructItem.float(),
}, true, ac.SharedNamespace.CarScript)
INPUTS_Pageau_fields = {
	"connected", "gas"
}

carScript = function(customData)
	addAllData(ECU_Pageau, ECU_Pageau_fields, 'ECU_', customData)
	addAllData(INPUTS_Pageau, INPUTS_Pageau_fields, 'INPUTS_', customData)
end
