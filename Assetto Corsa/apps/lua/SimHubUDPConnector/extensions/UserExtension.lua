require("extensions.Extension")

UserExtension = {}

function UserExtension:new (o)
    o = o or Extension:new(o)
    setmetatable(o, self)
    self.__index = self
    return o
 end

local carState = ac.getCar(0)
local sim = ac.getSim()

function UserExtension:update(dt, customData)
    -- here you can add the properies you need 
    -- example :
    -- customData.AmbientTemperature = sim.ambientTemperature
    -- customData.Autoclutch = carState.autoClutch
end

return UserExtension