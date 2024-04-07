local root = debug.getinfo(1, 'S').source:match ".*reaper.keys[^\\/]*[\\/]":sub(2)
package.path = root:match "\\$" -- windows
    and (root .. "internal\\?.lua;" .. root .. "vendor\\?.lua;" .. root .. "vendor\\scythe\\?.lua")
    or (root .. "internal/?.lua;" .. root .. "vendor/?.lua;" .. root .. "vendor/scythe/?.lua")
local function errHandler(err) require 'utils.log'.error(("%s\n%s"):format(err, debug.traceback())) end
xpcall(require 'state_machine.state_machine', errHandler)
