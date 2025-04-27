Extension = {}

function Extension:new (o)
   o = o or {}
   setmetatable(o, self)
   self.__index = self
   return o
end

---Update the date sent by the extension.
---@param dt number dt from the main script update.
---@param customData table list of properties. That's customData the object sent to simhub.
function Extension:update(dt, customData)

end