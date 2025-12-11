local reaper_state = require('reaper_state')

local model = {}

local data_namespace = "feedback"

function model.getKey(key)
  return reaper_state.getKey(data_namespace, key)
end

function model.setKeys(data)
  return reaper_state.setKeys(data_namespace, data)
end

function model.get()
  return reaper_state.get(data_namespace)
end

return model

