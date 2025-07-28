local connection = {}
local DBZKey = ac.getCarID(0) .. "_dbz_cars"
local DBZSharedData = {
  ac.StructItem.key(DBZKey .. "_" .. 0),
  Connected = ac.StructItem.boolean(),
  AntiLagEnabled = ac.StructItem.boolean(),
  AntiLagActive = ac.StructItem.boolean(),
  ALSMode = ac.StructItem.int8(),
}

DBZConnection = ac.connect(DBZSharedData, false, ac.SharedNamespace.Shared)

function connection:carScript(customData)
    addCarData(DBZConnection, DBZSharedData, 'DBZ_', customData)
end

return connection
