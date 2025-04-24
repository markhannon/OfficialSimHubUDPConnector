carId = ac.getCarID(0)
ECU_FG = ac.connect({
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
}, true, ac.SharedNamespace.CarScript)
ECU_FG_fields = { "connected","displayPage","requestedEngineRPM","throttleBodyPosition","requestedThrottleBodyPosition","deploymentStrat",
"pedalMap","torqueMap","torqueSplit","stintMaxEnergyMJ","stintEnergyMJ","stintEstimatedLapsRemaining","stintLapsCompleted",
"currentEnergyMJPerLap","virtualEnergyTankMJ","brakeBiasLive","brakeBiasPeak","brakeMigration","tcSlipSetting","tcCutSetting",
"tcCut","tcTargetSlip","diffModeCurrent","diffEntry","diffMid","diffExitHispd","damage","gearSync","gearsSynced",
"isBrakeMagicActive","isConstantSpeedLimiterActive","engineBrakeSetting","antirollBarRearPosition","isTCActive","isAntistallActive",
"isEngineStalled","isEngineStarted","isEngineRunning","isStarterCranking","isIgnitionOn","isElectronicsBooted","isEboostActive"}

carScript = function (customData)
    addAllData(ECU_FG, ECU_FG_fields, 'ECU_', customData)
    customData.damage_1 = ECU_FG.damage[0]
    customData.damage_2 = ECU_FG.damage[1]
    customData.damage_3 = ECU_FG.damage[2]
    customData.damage_4 = ECU_FG.damage[3]
    customData.damage_5 = ECU_FG.damage[4]
    customData.damage_6 = ECU_FG.damage[5]
    customData.damage_7 = ECU_FG.damage[6]
    customData.gearSync_1 = ECU_FG.gearSync[0]
    customData.gearSync_2 = ECU_FG.gearSync[1]
    customData.gearSync_3 = ECU_FG.gearSync[2]
    customData.gearSync_4 = ECU_FG.gearSync[3]
    customData.gearSync_5 = ECU_FG.gearSync[4]
    customData.gearSync_6 = ECU_FG.gearSync[5]
    customData.gearSync_7 = ECU_FG.gearSync[6]
    customData.gearSync_8 = ECU_FG.gearSync[7]
    customData.gearSync_9 = ECU_FG.gearSync[8]
end