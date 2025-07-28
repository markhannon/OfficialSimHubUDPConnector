local CAR = ac.getCar(0)
local DrsData = ac.INIConfig.trackData("drs_zones.ini")
local ZonesCount = 0
local DETECTION = {}
local END = {}
local index = 0
local CarPos = 0
local DRSFlag = false
local DRSDetection = false
local INITIALIZED = false

local connection = {}
local carId = ac.getCarID(0)
local Ignition_RSS = ac.connect({
    ac.StructItem.key(carId .. "_Ignition" .. "_" .. 0),
    Mode = ac.StructItem.int32()
}, true, ac.SharedNamespace.Shared)
local FHSystemKey = "Formula_Hybrid_System"
local FHSystemsharedData = {
    ac.StructItem.key(FHSystemKey .. "_" .. 0),
    BrakeMigration = ac.StructItem.float(),
	BrakeMigrationRamp = ac.StructItem.float(),
	DiffEntry = ac.StructItem.int32(),
	DiffMid = ac.StructItem.int32(),
	DiffExit = ac.StructItem.int32(),
	DiffExitSpeed = ac.StructItem.int32(),
	ThrottleMap = ac.StructItem.int32(),
	EngineBrake = ac.StructItem.int32(),
	FuelTarget = ac.StructItem.float(),
	StartMode = ac.StructItem.boolean(),
	AntiStall = ac.StructItem.boolean()
}
local FHSystem = ac.connect(FHSystemsharedData, true, ac.SharedNamespace.Shared)

local function initialize()

    repeat
        DETECTION[index] = DrsData:get('ZONE_'..index, 'DETECTION',-1)
        END[index] = DrsData:get('ZONE_'..index, 'END',-1)
        index = index + 1
    until DrsData:get('ZONE_'..index, 'END',nil) == nil
    ZonesCount = index - 1

    INITIALIZED = true

end

function connection:carScript(customData)
	drs()
    customData.IgnitionMode = Ignition_RSS.Mode
	customData.DRSDetection = DRSDetection
	customData.DRSFlag = DRSFlag
    addCarData(FHSystem, FHSystemsharedData, 'FHSystem_', customData)
end

function drs()
    if not INITIALIZED then initialize() end
    CarPos = CAR.splinePosition
    DRSDetection = false
    if CAR.drsActive then
        DRSFlag = true
    end
    if not CAR.drsAvailable then
        DRSFlag = false
    end

    for i = 0,ZonesCount do
        if CarPos < END[i] and CarPos > DETECTION[i] then
            DRSDetection = true
        end

        if END[i] < DETECTION[i] then
            if CarPos < END[i] or CarPos > DETECTION[i] then
               DRSDetection = true
            end
        end
        if CAR.drsAvailable then
            DRSDetection = true
        end
    end
end

return connection
