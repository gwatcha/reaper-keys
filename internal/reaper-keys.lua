local info = debug.getinfo(1, 'S');

local internal_root_path = info.source:match(".*reaper.keys[^\\/]*[\\/]internal[\\/]"):sub(2)
package.path = package.path .. ";" .. internal_root_path .. '?.lua'

local windows_files = internal_root_path:match("\\$")
if windows_files then
    package.path = package.path .. ";" .. internal_root_path .. "..\\definitions\\?.lua"
    package.path = package.path .. ";" .. internal_root_path .. "?\\?.lua"
    package.path = package.path .. ";" .. internal_root_path .. "vendor\\?.lua"
    package.path = package.path .. ";" .. internal_root_path .. "vendor\\scythe\\?.lua"
else
    package.path = package.path .. ";" .. internal_root_path .. "../definitions/?.lua"
    package.path = package.path .. ";" .. internal_root_path .. "?/?.lua"
    package.path = package.path .. ";" .. internal_root_path .. "vendor/?.lua"
    package.path = package.path .. ";" .. internal_root_path .. "vendor/scythe/?.lua"
end

local input = require('state_machine')
local log = require('utils.log')

local function errorHandler(err)
    log.error(err)
    log.error(debug.traceback())
end

local function doInput(key_press)
    xpcall(input, errorHandler, key_press)
end

return doInput
