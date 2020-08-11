local log = require('utils.log')
local serpent = require('serpent')

local reaper_io = {}

function reaper_io.set(ext, key, lua_table, persist)
  local lua_table_string = serpent.block(lua_table, { comment = false })
  reaper.SetExtState(ext, key, lua_table_string, persist)
end

function reaper_io.get(ext, key)
  local string_value = reaper.GetExtState(ext, key)
  if string_value then
    local ok, lua_table = serpent.load(string_value)
    if not ok or not lua_table then
      return false, lua_table
    end

    return ok, lua_table
  end

  return false, 'Does not exist'
end

function reaper_io.delete(ext, key, persist)
  reaper.DeleteExtState(ext, key, persist)
end

return reaper_io
