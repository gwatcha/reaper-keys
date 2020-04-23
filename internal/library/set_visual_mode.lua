local info = debug.getinfo(1,'S')
local scriptPath = info.source:match[[^@?(.*[\\/])[^\\/]-$]]
reaper.SetExtState("reaper-keys", "libPath", scriptPath, true)

return 1
