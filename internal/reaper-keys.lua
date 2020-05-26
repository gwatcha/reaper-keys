local info = debug.getinfo(1,'S');

local internal_root_path = info.source:match(".*reaper.keys[^\\/]*[\\/]internal[\\/]"):sub(2)
package.path = package.path .. ";" .. internal_root_path .. '?.lua'

local windows_files = internal_root_path:match("\\$")
if windows_files then
  package.path = package.path .. ";" .. internal_root_path .. "..\\definitions\\?.lua"
  package.path = package.path .. ";" .. internal_root_path .. "?\\?.lua"
  package.path = package.path .. ";" .. internal_root_path .. "vendor\\share\\lua\\5.3\\?.lua"
  package.path = package.path .. ";" .. internal_root_path .. "vendor\\share\\lua\\5.3\\?\\init.lua"
else
  package.path = package.path .. ";" .. internal_root_path .. "../definitions/?.lua"
  package.path = package.path .. ";" .. internal_root_path .. "?/?.lua"
  package.path = package.path .. ";" .. internal_root_path .. "vendor/share/lua/5.3/?.lua"
  package.path = package.path .. ";" .. internal_root_path .. "vendor/share/lua/5.3/?/init.lua"
end

local input = require('state_machine')

function doInput(key_press)
  input(key_press)
end

return doInput
