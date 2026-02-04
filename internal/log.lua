local log_level = require 'definitions.config'.general.log_level

local idxs = { debug = 2, info = 3, error = 5 }
local function doLog(msg) reaper.ShowConsoleMsg(("%s\n"):format(msg)) end

---@class Logger
---@field debug fun(msg: string)
---@field info fun(msg: string)
---@field error fun(msg: string)
---@type Logger
local log = {
    debug = function(msg) if 2 >= idxs[log_level] then doLog(msg) end end,
    info = function(msg) if 3 >= idxs[log_level] then doLog(msg) end end,
    error = function(msg) if 5 >= idxs[log_level] then doLog(msg) end end,
}

return log
