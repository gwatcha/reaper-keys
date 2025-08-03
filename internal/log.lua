local log_level = require 'definitions.config'.general.log_level

---@class Logger
---@field trace fun(msg: string)
---@field debug fun(msg: string)
---@field info fun(msg: string)
---@field warn fun(msg: string)
---@field error fun(msg: string)
---@field fatal fun(msg: string)

local idxs = { trace = 1, debug = 2, info = 3, warn = 4, error = 5, fatal = 6 }
local function doLog(msg) reaper.ShowConsoleMsg(("%s\n"):format(msg)) end

---@type Logger
local log = {
    trace = function(msg) if 1 >= idxs[log_level] then doLog(msg) end end,
    debug = function(msg) if 2 >= idxs[log_level] then doLog(msg) end end,
    info = function(msg) if 3 >= idxs[log_level] then doLog(msg) end end,
    warn = function(msg) if 4 >= idxs[log_level] then doLog(msg) end end,
    error = function(msg) if 5 >= idxs[log_level] then doLog(msg) end end,
    fatal = function(msg) if 6 >= idxs[log_level] then doLog(msg) end end
}

return log
