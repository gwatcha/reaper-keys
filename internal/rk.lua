local root = debug.getinfo(1, 'S').source:match ".*reaper.keys[^\\/]*[\\/]":sub(2)
package.path = root .. "internal/?.lua;" .. root .. "vendor/?.lua;" .. root .. "vendor/scythe/?.lua"
local function msgh(err) require 'utils.log'.error(err, debug.traceback()) end
xpcall(require 'state_machine.state_machine', msgh)
