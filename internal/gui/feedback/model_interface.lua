local table_io = require('utils.table_io')

local model_interface = {}

-- TODO test whether reaper_io is faster
local info = debug.getinfo(1,'S');
local root_path = info.source:match[[(.*reaper.keys[^\\/]*[\\/])]]:sub(2)
local feedback_model_path = ""
local windows_files = root_path:match("\\$")
if windows_files then
  feedback_model_path = root_path .. "internal\\gui\\feedback/model_data"
else
  feedback_model_path = root_path .. "internal/gui/feedback/model_data"
end

function model_interface.write(data)
  if not data then
    log.error("No data passed to write to model:: " .. debug.traceback())
  end

  local ok, model = table_io.read(feedback_model_path)
  if not ok or not model then
    model = {}
  end


  for key,value in pairs(data) do
    model[key] = value
  end
  table_io.write(feedback_model_path, model)
end

function model_interface.read()
  local ok, model = table_io.read(feedback_model_path)
  if not ok or not model then
    return {}
  end

  return model
end

return model_interface
