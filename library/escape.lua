local info = debug.getinfo(1,'S');
local root_path = info.source:match[[[^@]*reaper.keys/]]
package.path = package.path .. ";" .. root_path .. "?.lua"

