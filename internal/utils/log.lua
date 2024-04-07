local Msg = require 'scythe.public.message'.Msg
local level = require 'definitions.config'.log_level
local levels = { "trace", "debug", "info", "warn", "error", "fatal" }
local idxs = { trace = 1, debug = 2, info = 3, warn = 4, error = 5, fatal = 6 }
local log = {}
for i, mode in ipairs(levels) do
    log[mode] = function(...) if i >= idxs[level] then Msg(...) end end
end
return log
