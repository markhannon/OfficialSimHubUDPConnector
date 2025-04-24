local connection = {}
local carId = ac.getCarID(0)
local Ignition_RSS = ac.connect({
	ac.StructItem.key(carId .. "_Ignition" .. "_" .. 0),
	Mode = ac.StructItem.int32()
}, true, ac.SharedNamespace.Shared)

local OvertakeSystemKey = carId .. "_OvertakeSystem"
local OvertakeSystemharedData = {
	ac.StructItem.key(OvertakeSystemKey .. "_" .. 0),
	SystemAvailable = ac.StructItem.boolean(), -- This is provided for GUI apps and is basically always true.
	status = ac.StructItem.int32(),         -- 0 = Time Out 1 = Cool down 2 = Available 3 = in use
	CoolDown = ac.StructItem.float(),       -- OTS cooldown remaining time
	CoolDownTime = ac.StructItem.float(),
	RemainingTime = ac.StructItem.float(),  -- OTS remaining available time
}
local OvertakeSystem = ac.connect(OvertakeSystemharedData, true, ac.SharedNamespace.Shared)

local RSSSupremeSystemKey = carId .. "_RSSSupremeSystem"
local RSSSupremeSystemsharedData = {
	ac.StructItem.key(RSSSupremeSystemKey .. "_" .. 0),
	FuelMap = ac.StructItem.int32(),
	ThrottleMap = ac.StructItem.int32(),
	Throttleinput = ac.StructItem.float(),
	StartMode = ac.StructItem.boolean(),
	AttackWarning = ac.StructItem.boolean()
}
local RSSSupreme = ac.connect(RSSSupremeSystemsharedData, true, ac.SharedNamespace.Shared)

function connection:carScript(customData)
	customData.IgnitionMode = Ignition_RSS.Mode
	addAllData(OvertakeSystem, OvertakeSystemharedData, 'OvertakeSystem_', customData)
	addAllData(RSSSupreme, RSSSupremeSystemsharedData, 'RSSSupreme_', customData)
end

return connection
