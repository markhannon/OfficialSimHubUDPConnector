local SIM = ac.getSim()
local CAR = ac.getCar(0)
local FuelBase = CAR.fuel
local LastFuel = CAR.fuel
local LastLapCount = 0
local BattLevel = 1
local SOC_DELTA = "0.0"

local connection = {}
local carId = ac.getCarID(0)
local Ignition_RSS = ac.connect({
	ac.StructItem.key(carId .. "_Ignition" .. "_" .. 0),
	Mode = ac.StructItem.int32()
}, true, ac.SharedNamespace.Shared)

MPHystemKey = "RSS_MPH_System"
local MPHSystemsharedData = {
	ac.StructItem.key(MPHystemKey .. "_0"),
	BrakeMigration = ac.StructItem.float(),
	BrakeMigrationRamp = ac.StructItem.float(),
	FuelTarget = ac.StructItem.float(),
	AntiStall = ac.StructItem.boolean(),
	AutoKill = ac.StructItem.boolean(),
	ARB_Front = ac.StructItem.int32(),
	ARB_Rear = ac.StructItem.int32(),
	ThrottleMap = ac.StructItem.int32(),
	PitLimitSpeed = ac.StructItem.int32()
}
MPHSystem = ac.connect(MPHSystemsharedData, false, ac.SharedNamespace.Shared)

function connection:carScript(customData)
	customData.IgnitionMode = Ignition_RSS.Mode
	customData.FuelUsed = script.FuelUsed()
	if SIM.isInMainMenu then
		customData.SetUp_TC_GRIP = CAR.tractionControl2
		customData.SetUp_Wiper = CAR.wiperMode
		customData.SetUp_MAP = CAR.fuelMap
		customData.SetUp_SOC = CAR.mgukDelivery
		customData.SetUp_Pedal = MPHSystem.ThrottleMap
		customData.SetUp_REG = CAR.mgukRecovery
		customData.SetUp_TC_LAT = CAR.tractionControlMode
	end

	if LastLapCount ~= CAR.lapCount then
		LastLapCount = CAR.lapCount
		SOC_DELTA = string.format("%.1f", (CAR.kersCharge - BattLevel) * 100)
		if CAR.kersCharge - BattLevel > 0 then
			SOC_DELTA = "+" .. SOC_DELTA
		end
		BattLevel = CAR.kersCharge
	end

	customData.SOC_DELTA = SOC_DELTA

	addCarData(MPHSystem, MPHSystemsharedData, 'MPHSystem_', customData)
end

function script.FuelUsed()
	if SIM.isInMainMenu or LastFuel < CAR.fuel then
		FuelBase = CAR.fuel
	end

	LastFuel = CAR.fuel
	return FuelBase - CAR.fuel
end

return connection
