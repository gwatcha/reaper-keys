local root = debug.getinfo(1, 'S').source:match ".*reaper.keys[^\\/]*[\\/]":sub(2)
if root:match "\\$" then -- windows
    package.path = root .. "internal\\?.lua;" ..
        root .. "vendor\\?.lua;" ..
        root .. "vendor\\scythe\\?.lua"
else
    package.path = root .. "internal/?.lua;" ..
        root .. "vendor/?.lua;" ..
        root .. "vendor/scythe/?.lua"
end
local function errHandler(err) require 'utils.log'.error(("%s\n%s"):format(err, debug.traceback())) end
xpcall(require 'state_machine.state_machine', errHandler)
