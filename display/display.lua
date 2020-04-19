local display = {}

local libPath = reaper.GetExtState("Scythe v3", "libPath")
if not libPath or libPath == "" then
  reaper.MB("Couldn't load the Scythe library. Please install 'Scythe library v3' from ReaPack, then run 'Script: Scythe_Set v3 library path.lua' in your Action List.", "Whoops!", 0)
  return
end
loadfile(libPath .. "scythe.lua")()

config_display = require("display.config")

function display.showConfig()
  config_display()
end

return display

