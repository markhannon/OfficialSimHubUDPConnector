local connection = {}
local carId = ac.getCarID(0)
local ECU_FG_Struct = {
	connected = ac.StructItem.boolean(),
	displayPage = ac.StructItem.int16(),
	requestedEngineRPM = ac.StructItem.float(),
	throttleBodyPosition = ac.StructItem.float(),
	requestedThrottleBodyPosition = ac.StructItem.float(),
	deploymentStrat = ac.StructItem.float(),
	pedalMap = ac.StructItem.float(),
	torqueMap = ac.StructItem.int16(),
	torqueSplit = ac.StructItem.int16(),
	stintMaxEnergyMJ = ac.StructItem.float(),
	stintEnergyMJ = ac.StructItem.float(),
	stintEstimatedLapsRemaining = ac.StructItem.float(),
	stintLapsCompleted = ac.StructItem.float(),
	currentEnergyMJPerLap = ac.StructItem.float(),
	virtualEnergyTankMJ = ac.StructItem.float(),
	brakeBiasLive = ac.StructItem.float(),
	brakeBiasPeak = ac.StructItem.float(),
	brakeMigration = ac.StructItem.float(),
	tcSlipSetting = ac.StructItem.int16(),
	tcCutSetting = ac.StructItem.int16(),
	tcCut = ac.StructItem.float(),
	tcTargetSlip = ac.StructItem.float(),
	diffModeCurrent = ac.StructItem.float(),
	diffEntry = ac.StructItem.float(),
	diffMid = ac.StructItem.float(),
	diffExitHispd = ac.StructItem.float(),
	damage = ac.StructItem.array(ac.StructItem.float(), 7),
	gearSync = ac.StructItem.array(ac.StructItem.boolean(), 9),
	gearsSynced = ac.StructItem.boolean(),
	isBrakeMagicActive = ac.StructItem.boolean(),
	isConstantSpeedLimiterActive = ac.StructItem.boolean(),
	engineBrakeSetting = ac.StructItem.int16(),
	antirollBarRearPosition = ac.StructItem.int16(),
	isTCActive = ac.StructItem.boolean(),
	isAntistallActive = ac.StructItem.boolean(),
	isEngineStalled = ac.StructItem.boolean(),
	isEngineStarted = ac.StructItem.boolean(),
	isEngineRunning = ac.StructItem.boolean(),
	isStarterCranking = ac.StructItem.boolean(),
	isIgnitionOn = ac.StructItem.boolean(),
	isElectronicsBooted = ac.StructItem.boolean(),
	isEboostActive = ac.StructItem.boolean(),
}
local ECU_FG = ac.connect(ECU_FG_Struct, true, ac.SharedNamespace.CarScript)

function connection:carScript(customData)
	addAllData(ECU_FG, ECU_FG_Struct, 'ECU_', customData)
	customData.ECU_Damage = nil
	customData.ECU_Damage_1 = ECU_FG.damage[0]
	customData.ECU_Damage_2 = ECU_FG.damage[1]
	customData.ECU_Damage_3 = ECU_FG.damage[2]
	customData.ECU_Damage_4 = ECU_FG.damage[3]
	customData.ECU_Damage_5 = ECU_FG.damage[4]
	customData.ECU_Damage_6 = ECU_FG.damage[5]
	customData.ECU_Damage_7 = ECU_FG.damage[6]
	customData.ECU_GearSync = nil
	customData.ECU_GearSync_1 = ECU_FG.gearSync[0]
	customData.ECU_GearSync_2 = ECU_FG.gearSync[1]
	customData.ECU_GearSync_3 = ECU_FG.gearSync[2]
	customData.ECU_GearSync_4 = ECU_FG.gearSync[3]
	customData.ECU_GearSync_5 = ECU_FG.gearSync[4]
	customData.ECU_GearSync_6 = ECU_FG.gearSync[5]
	customData.ECU_GearSync_7 = ECU_FG.gearSync[6]
	customData.ECU_GearSync_8 = ECU_FG.gearSync[7]
	customData.ECU_GearSync_9 = ECU_FG.gearSync[8]
end

return connection