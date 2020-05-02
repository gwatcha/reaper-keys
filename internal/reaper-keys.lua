local info = debug.getinfo(1,'S');
local root_path = info.source:match[[.*reaper.keys/internal/]]:sub(2)
package.path = package.path .. ";" .. root_path .. "../definitions/?.lua"
package.path = package.path .. ";" .. root_path .. "?.lua"
package.path = package.path .. ";" .. root_path .. "?/?.lua"
package.path = package.path .. ";" .. root_path .. "vendor/share/lua/5.3/?.lua"
package.path = package.path .. ";" .. root_path .. "vendor/share/lua/5.3/?/init.lua"

local input = require('state_machine')

function doInput(key_press)
  input(key_press)
end

return doInput
