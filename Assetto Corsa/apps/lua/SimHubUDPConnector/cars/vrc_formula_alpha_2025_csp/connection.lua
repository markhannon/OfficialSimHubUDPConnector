if not string.startsWith(ac.getCarID(0), "vrc_formula_alpha_2025_csp") then return end

car = ac.getCar(0)

package.path = package.path .. ";content/cars/vrc_formula_alpha_2025_csp/extension/data_override/?.lua"
local can = require("can")
local cphys = ac.getCarPhysics(0)

local connection = {}

function connection:carScript(customData)
        if not can.bus then
                can:connect()
                return
        end

        can.update()

        for k, v in pairs(can.inputs) do
                customData["ECU_" .. k] = cphys.scriptControllerInputs[v[1]]
                if v[2] then customData["ECU_" .. k] = customData["ECU_" .. k] == 1 end
        end
end

return connection
