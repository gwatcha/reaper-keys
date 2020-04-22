-- i loove including files in lua.
local info = debug.getinfo(1,'S');
local root_path = info.source:match[[.*reaper.keys/internal/]]:sub(2)
package.path = package.path .. ";" .. root_path .. "?.lua"
package.path = package.path .. ";" .. root_path .. "?/?.lua"
package.path = package.path .. ";" .. root_path .. "vendor/share/lua/5.3/?.lua"
package.path = package.path .. ";" .. root_path .. "vendor/share/lua/5.3/?/init.lua"

local state_machine = require('state_machine')

function doInput(key_press)
  state_machine.input(key_press)
end

return doInput
