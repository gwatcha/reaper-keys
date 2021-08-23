local log = require('utils.log')
local format = require('utils.format')
local serpent = require('serpent')

local reaper_state = {}

local namespace = "reaper_keys"

function reaper_state.delete(table_name)
  reaper.DeleteExtState(namespace, table_name, true)
end

function reaper_state.set(table_name, lua_table)
  local lua_table_string = serpent.dump(lua_table, { comment = false })
  reaper.SetExtState(namespace, table_name, lua_table_string, true)
end

function reaper_state.get(table_name)
  local string_value = reaper.GetExtState(namespace, table_name)
  if string_value then
    local ok, ext_value = serpent.load(string_value)
    if not ok or not ext_value or not type(ext_value) == 'table' then
      return nil
    end

    if type(ext_value) ~= 'table' then
      return nil
    end

    return ext_value
  end

  return nil
end

function reaper_state.append(name, key, new_data)
  local all_data = reaper_state.get(name)
  if not all_data then
    all_data = {}
    all_data[key] = new_data
    reaper_state.set(name, all_data)
    return
  end

  if all_data[key] then
    table.insert(all_data[key], new_data)
  else
    all_data[key] = {new_data}
  end
  reaper_state.set(name, all_data)
end

function reaper_state.setKeys(table_name, new_data)
  local saved_table = reaper_state.get(table_name)
  if not saved_table then
    saved_table = {}
  end

  for key,value in pairs(new_data) do
    saved_table[key] = value
  end
  reaper_state.set(table_name, saved_table)
end

function reaper_state.getKey(table_name, key)
  local saved_table = reaper_state.get(table_name)
  if not saved_table then
    return nil
  end
  return saved_table[key]
end

function reaper_state.clearJustOpenedFlag()
  local is_open = reaper.GetExtState(namespace, "reaper_started")
  if is_open == "open" then
    return false
  end

  reaper.SetExtState(namespace, "reaper_started", "open", false)
  return true
end

return reaper_state
