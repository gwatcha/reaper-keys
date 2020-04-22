local table_io = {}

local serpent = require("serpent")

function table_io.write(path, lua_table)
  local state_file = io.open(path .. '.lua', 'w+')
  state_file:write(serpent.block(lua_table, { comment = false }))
  state_file:close()
end

function table_io.read(path)
  local full_path = path .. '.lua'
  local file = io.open(full_path, 'r')
  if file then
    ok, lua_table = serpent.load(file:read('*all'))
    if not ok then
      return false, full_path .. ": " .. lua_table
    end

    return ok, lua_table
  end

  return false, "Could not read table file " .. full_path .. ". Does it exist?"
end

return table_io
