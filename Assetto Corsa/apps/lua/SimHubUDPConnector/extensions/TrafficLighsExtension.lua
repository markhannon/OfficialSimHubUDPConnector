require("extensions.Extension")

TrafficLighsExtension = {}

function TrafficLighsExtension:new (o)
    o = o or Extension:new(o)
    setmetatable(o, self)
    self.__index = self
    return o
 end

-- local carState = ac.getCar(0)
-- local sim = ac.getSim()

local TLKey = ac.getCarID(0) .. "_trafficLights"
local TLSharedData = {
  ac.StructItem.key(TLKey .. "_" .. 0),
  Connected = ac.StructItem.boolean(),
  Started = ac.StructItem.boolean(),
  Light1On = ac.StructItem.boolean(),
  Light2On = ac.StructItem.boolean(),
  Light3On = ac.StructItem.boolean(),
  Light4On = ac.StructItem.boolean(),
  YellowBlinking = ac.StructItem.boolean(),
}
TLightsConnection = ac.connect(TLSharedData, false, ac.SharedNamespace.Shared)

function TrafficLighsExtension:update(dt, customData)
    customData.TLExt_Connected = TLightsConnection.Connected
    customData.TLExt_Started = TLightsConnection.Started
    customData.TLExt_Light1On = TLightsConnection.Light1On
    customData.TLExt_Light2On = TLightsConnection.Light2On
    customData.TLExt_Light3On = TLightsConnection.Light3On
    customData.TLExt_Light4On = TLightsConnection.Light4On
    customData.TLExt_YellowBlinking = TLightsConnection.YellowBlinking
end

return TrafficLighsExtension