local connection = {}
local car_connection_struct = {
	ac.StructItem.key(ac.getCarID(0) .. "car_connection" .. 0),
	connected = ac.StructItem.boolean(),
	ignition_on = ac.StructItem.boolean(),
	engine_on = ac.StructItem.boolean(),
	modeValue = ac.StructItem.int16(),
	modeHarvestValue = ac.StructItem.int16(),
	driverDisplayValue = ac.StructItem.int16(),
	antiStallEnabled = ac.StructItem.int16(),
	antiStall = ac.StructItem.boolean(),
	diffEntry = ac.StructItem.int16(),
	diffMid = ac.StructItem.int16(),
	diffExit = ac.StructItem.int16(),
	bmig = ac.StructItem.float(),
	ramp = ac.StructItem.int16(),
	eng_map = ac.StructItem.int16(),
	speedLim = ac.StructItem.int16(),
	bb_bmig = ac.StructItem.float(),
	starter_sequence = ac.StructItem.int16(),
	popUpTime = ac.StructItem.float(),
	throttleMap = ac.StructItem.int16(),
	drsState = ac.StructItem.boolean(),
	kersState = ac.StructItem.boolean(),
	startLEDsTimer = ac.StructItem.float(),
	brakeMagic = ac.StructItem.boolean(),
}
local car_connection = ac.connect(car_connection_struct, true, ac.SharedNamespace.CarScript)

local RAREDATA_struct = {
    ac.StructItem.key('RAREDATA'),
    connected = ac.StructItem.boolean(),
    scriptVersionId = ac.StructItem.int16(),
    drsEnabled = ac.StructItem.boolean(),
    drsAvailable = ac.StructItem.array(ac.StructItem.boolean(),32),
    carAhead = ac.StructItem.array(ac.StructItem.int16(),32),
    carAheadDelta = ac.StructItem.array(ac.StructItem.float(),32),
}
local RAREDATA = ac.connect(RAREDATA_struct,false,ac.SharedNamespace.Shared)

local RAREDATAAIDefaults_Struct = {
    ac.StructItem.key('RAREDATAAIDefaults'),
    aiLevelDefault = ac.StructItem.array(ac.StructItem.float(),32),
    aiAggressionDefault = ac.StructItem.array(ac.StructItem.float(),32),
}
local RAREDATAAIDefaults = ac.connect(RAREDATAAIDefaults_Struct,false,ac.SharedNamespace.Shared)

function connection:carScript(customData)
    addCarData(car_connection, car_connection_struct, 'ECU_', customData)
    addCarData(RAREDATA, RAREDATA_struct, 'RAREDATA_', customData)
    addCarData(RAREDATAAIDefaults, RAREDATAAIDefaults_Struct, 'RAREDATA_AI_', customData)
end

return connection