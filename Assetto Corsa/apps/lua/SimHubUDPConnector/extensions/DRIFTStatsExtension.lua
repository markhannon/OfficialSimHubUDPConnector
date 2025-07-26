require("extensions.Extension")

DRIFTStatsExtension = {}

function DRIFTStatsExtension:new (o)
    o = o or Extension:new(o)
    setmetatable(o, self)
    self.__index = self
    return o
 end

local DRIFTKey = "D_R_I_F_T_connect_key"
local DRIFTSharedData = {
  ac.StructItem.key(DRIFTKey),
  Connected = ac.StructItem.boolean(),
  Profiling = ac.StructItem.boolean(),
  FocusedDriverName = ac.StructItem.string(128),
  FocusedCarIndex = ac.StructItem.int16(),
  Stats = ac.StructItem.array(ac.StructItem.string(512),32)
}
StatsConnection = ac.connect(DRIFTSharedData, false, ac.SharedNamespace.Shared)
local prefix = "DRIFTStatsExt"
function DRIFTStatsExtension:update(dt, customData)
    customData[prefix .. "_Profiling"] = StatsConnection.Profiling 
    customData[prefix .. "_FocusedCarIndex"] = StatsConnection.FocusedCarIndex
    customData[prefix .. "_FocusedDriverName"] = StatsConnection.FocusedDriverName
    if StatsConnection.Profiling then
        for index = 0, 32, 1 do
            local jsonData = ffi.string(StatsConnection.Stats[index])
            if jsonData and jsonData:len() > 0 then
                local data = JSON.parse(jsonData)
                if data then
                    for key, value in pairs(data) do
                        customData[prefix .. "_" .. index .. "_" .. key] = value
                    end
                end
            end
        end
    end
end
return DRIFTStatsExtension