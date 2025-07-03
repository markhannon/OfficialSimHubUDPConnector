require("extensions.Extension")

CollisionsExtension = {}

function CollisionsExtension:new (o)
    o = o or Extension:new(o)
    setmetatable(o, self)
    self.__index = self
    return o
 end

local carState = ac.getCar(0)

function CollisionsExtension:update(dt, customData)
    -- this part is required for the collisions detection
    customData.CollisionPositionX = carState.collisionPosition.x
    customData.CollisionPositionY = carState.collisionPosition.y
    customData.CollisionPositionZ = carState.collisionPosition.z
    customData.CollidedWithId = carState.collidedWith
    customData.CollidedWith = (carState.collidedWith == 0) and 'Track' or
    ((carState.collidedWith > 0) and ac.getDriverName(carState.collidedWith-1) or 'None')
    customData.ColliderSpeed = (carState.collidedWith > 0) and ac.getCar(carState.collidedWith-1).speedKmh or 0
end

return CollisionsExtension