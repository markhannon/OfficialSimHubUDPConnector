local SIM = ac.getSim()
local CAR = ac.getCar(0)
local FuelBase = CAR.fuel
local LastFuel = CAR.fuel
local IGTimer = 0
local BoxDistance = 9999
local BosPos = CAR.pitTransform.position
local StopFlag = false
local PitLimiter = false


local connection = {}
local carId = ac.getCarID(0)
local Ignition_RSS = ac.connect({
	ac.StructItem.key(carId .. "_Ignition" .. "_" .. 0),
	Mode = ac.StructItem.int32()
}, true, ac.SharedNamespace.Shared)

local MPHystemKey = "RSS_MPH_System"
local MPHSystemsharedData = {
	ac.StructItem.key(MPHystemKey .. "_0" ),
	BrakeMigration = ac.StructItem.float(),
	BrakeMigrationRamp = ac.StructItem.float(),
	FuelTarget = ac.StructItem.float(),
	PopupTime = ac.StructItem.float(),
	AntiStall = ac.StructItem.boolean(),
	AutoKill = ac.StructItem.boolean(),
	ARB_Front = ac.StructItem.int32(),
	ARB_Rear =  ac.StructItem.int32(),
	ThrottleMap = ac.StructItem.int32(),
    PitLimitSpeed = ac.StructItem.int32()
}
local MPHSystem = ac.connect(MPHSystemsharedData, false, ac.SharedNamespace.Shared)

function connection:carScript(customData)
	customData.IgnitionMode = Ignition_RSS.Mode
	customData.FuelUsed = script.FuelUsed()
	customData.ReadyToStart = script.ReadyToStart()
	customData.PitBoxDistance = script.PitBoxDistance()

	addCarData(MPHSystem, MPHSystemsharedData, 'MPHSystem_', customData)
end

function script.FuelUsed()
	if SIM.isInMainMenu or LastFuel < CAR.fuel then
		FuelBase = CAR.fuel
	end

	LastFuel = CAR.fuel
	return FuelBase - CAR.fuel
end

function script.ReadyToStart()
	if Ignition_RSS.Mode > 0 then
		IGTimer = IGTimer + ac.getDeltaT()
	else
		IGTimer = 0
	end
	if IGTimer > 2.5 and Ignition_RSS.Mode == 1 and  CAR.gear == 1 then
		return true
	else
		return false
	end
end

function script.PitBoxDistance()
	PitLimiter = CAR.manualPitsSpeedLimiterEnabled and not SIM.isReplayActive or CAR.isInPitlane and true or false

	if PitLimiter and not StopFlag then
		BoxDistance = math.distance(BosPos,CAR.position)
		if Ignition_RSS.Mode ~= 2 then
			StopFlag = true
		end
	else
		BoxDistance = 9999
	end

	if not PitLimiter then
		StopFlag = false
	end

	return BoxDistance
end

return connection
