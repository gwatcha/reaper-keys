local serpent = require 'serpent'
local table_io = {}

-- TODO(myrrc): return code
function table_io.write(path, lua_table)
    local file = io.open(path .. '.lua', 'w+')
    if not file then return nil end
    file:write(serpent.block(lua_table, { comment = false }))
    file:close()
end

---@param path string
---@return boolean
---@return string
function table_io.read(path)
    path = path .. '.lua'
    local file = io.open(path, 'r')
    if not file then return false, ("Could not read table file %s. Does it exist?"):format(path) end

    local ok, lua_table = serpent.load(file:read('*all'))
    if not ok then return false, ("%s: %s"):format(path, lua_table) end
    return ok, lua_table
end

return table_io
