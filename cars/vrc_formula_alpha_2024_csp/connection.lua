carId = ac.getCarID(0)
ECU_FA = ac.connect({
    ac.StructItem.key(carId .. "_ecu_" .. 0),
    connected = ac.StructItem.boolean(),
    displayPage = ac.StructItem.int16(),
    qsActiveIndex = ac.StructItem.int16(),
    requestedEngineRPM = ac.StructItem.float(),
    throttleBodyPosition = ac.StructItem.float(),
    requestedThrottleBodyPosition = ac.StructItem.float(),
    deploymentStrat = ac.StructItem.float(),
    rpm = ac.StructItem.int16(),
    torqueMap = ac.StructItem.int16(),
    torqueSplit = ac.StructItem.int16(),
    kersTorqueLevel = ac.StructItem.float(),
    kersInput = ac.StructItem.float(),
    kersCharge = ac.StructItem.float(),
    kersCurrentKJ = ac.StructItem.float(),
    kersOverrideCurrentKJ = ac.StructItem.float(),
    kersRechargeMode = ac.StructItem.boolean(),
    kersRecoveryLevel = ac.StructItem.float(),
    kersLapRechargeMJ = ac.StructItem.float(),
    brakeBiasLive = ac.StructItem.float(),
    brakeBiasPeak = ac.StructItem.float(),
    brakeBiasOffset = ac.StructItem.float(),
    brakeMigration = ac.StructItem.float(),
    brakeShapeMap = ac.StructItem.int16(),
    brakeBiasOffsetPosition = ac.StructItem.int16(),
    fuelUsePerLap = ac.StructItem.float(),
    fuelUseTarget = ac.StructItem.float(),
    diffModeCurrent = ac.StructItem.float(),
    differentialEntry = ac.StructItem.float(),
    differentialMid = ac.StructItem.float(),
    differentialExitHispd = ac.StructItem.float(),
    differentialMidHispdSwitch = ac.StructItem.int16(),
    damage = ac.StructItem.array(ac.StructItem.float(), 7),
    gearSync = ac.StructItem.array(ac.StructItem.boolean(), 9),
    gearsSynced = ac.StructItem.boolean(),
    mguhPriority = ac.StructItem.float(),
    isBrakeMagicActive = ac.StructItem.boolean(),
    isConstantSpeedLimiterActive = ac.StructItem.boolean(),
    engineBrakeSetting = ac.StructItem.int16(),
    antirollBarRearPosition = ac.StructItem.int16(),
    isAntistallActive = ac.StructItem.boolean(),
    isEngineStalled = ac.StructItem.boolean(),
    isEngineStarted = ac.StructItem.boolean(),
    isEngineRunning = ac.StructItem.boolean(),
    isStarterCranking = ac.StructItem.boolean(),
    isSteeringWheelConnected = ac.StructItem.boolean(),
    isIgnitionOn = ac.StructItem.boolean(),
    isElectronicsBooted = ac.StructItem.boolean(),
    isEboostActive = ac.StructItem.boolean(),
    isKersAntiActive = ac.StructItem.boolean(),
    isPitSpeedLimiterActive = ac.StructItem.boolean(),
    pitSpeedLimit = ac.StructItem.int16(),
    puMode = ac.StructItem.int16(),
    drsAvailable = ac.StructItem.boolean(),
    drsActive = ac.StructItem.boolean(),
    driverTargetStintLaps = ac.StructItem.int16(),
    driverTargetLapTime = ac.StructItem.int32(),
}, true, ac.SharedNamespace.CarScript)
ECU_FA_fields = { "connected", "displayPage", "qsActiveIndex", "requestedEngineRPM", "throttleBodyPosition",
    "requestedThrottleBodyPosition", "deploymentStrat",
    "rpm", "torqueMap", "torqueSplit", "kersTorqueLevel", "kersInput", "kersCharge", "kersCurrentKJ",
    "kersOverrideCurrentKJ", "kersRechargeMode", "kersRecoveryLevel",
    "kersLapRechargeMJ", "brakeBiasLive", "brakeBiasPeak", "brakeBiasOffset", "brakeMigration", "brakeShapeMap",
    "brakeBiasOffsetPosition", "fuelUsePerLap", "fuelUseTarget",
    "diffModeCurrent", "differentialEntry", "differentialMid", "differentialExitHispd", "differentialMidHispdSwitch",
    "gearsSynced", "mguhPriority", "isBrakeMagicActive",
    "isConstantSpeedLimiterActive", "engineBrakeSetting", "antirollBarRearPosition", "isAntistallActive",
    "isEngineStalled", "isEngineStarted", "isEngineRunning", "isStarterCranking",
    "isSteeringWheelConnected", "isIgnitionOn", "isElectronicsBooted", "isEboostActive", "isKersAntiActive",
    "isPitSpeedLimiterActive", "pitSpeedLimit", "puMode", "drsAvailable",
    "drsActive", "driverTargetStintLaps", "driverTargetLapTime" }

carScript = function (customData)
    addAllData(ECU_FA, ECU_FA_fields, 'ECU_', customData)
    customData.damage_1 = ECU_FA.damage[0]
    customData.damage_2 = ECU_FA.damage[1]
    customData.damage_3 = ECU_FA.damage[2]
    customData.damage_4 = ECU_FA.damage[3]
    customData.damage_5 = ECU_FA.damage[4]
    customData.damage_6 = ECU_FA.damage[5]
    customData.damage_7 = ECU_FA.damage[6]
    customData.gearSync_1 = ECU_FA.gearSync[0]
    customData.gearSync_2 = ECU_FA.gearSync[1]
    customData.gearSync_3 = ECU_FA.gearSync[2]
    customData.gearSync_4 = ECU_FA.gearSync[3]
    customData.gearSync_5 = ECU_FA.gearSync[4]
    customData.gearSync_6 = ECU_FA.gearSync[5]
    customData.gearSync_7 = ECU_FA.gearSync[6]
    customData.gearSync_8 = ECU_FA.gearSync[7]
    customData.gearSync_9 = ECU_FA.gearSync[8]
end