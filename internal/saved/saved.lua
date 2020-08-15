local reaper_state = require('utils.reaper_state')
local log = require('utils.log')

local saved = {}

function saved.getAll(name)
  return reaper_state.get(name)
end

function saved.get(name, register)
  return reaper_state.getKey(name, register)
end

function saved.overwriteAll(name, data)
  reaper_state.set(name, data)
end

function saved.overwrite(name, register, new_data)
  local all_data = saved.getAll(name)
  all_data[register] = new_data
  saved.overwriteAll(name, all_data)
end

function saved.append(name, register, new_data)
  local all_data = saved.getAll(name)
  if all_data[register] then
    table.insert(all_data[register], new_data)
  else
    all_data[register] = {new_data}
  end

  saved.overwriteAll(name, all_data)
end

function saved.clear(name, register)
  local all_data = saved.getAll(name)
  all_data[register] = nil
  saved.overwriteAll(name, all_data)
end

return saved
