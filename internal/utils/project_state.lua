local serpent = require 'serpent'
local project_state = {}

---@param ext string
---@param key string
---@param lua_table table | string
function project_state.overwrite(ext, key, lua_table)
    local current_project, _ = reaper.EnumProjects(-1, "")
    local lua_table_string = serpent.block(lua_table, { comment = false })
    reaper.SetProjExtState(current_project, ext, key, lua_table_string)
end

---@param ext string
function project_state.getAll(ext)
    local keys, max_keys, exists = {}, 5000, false
    for i = 0, max_keys do
        local enum_ok, key, val = reaper.EnumProjExtState(0, ext, i)
        if not enum_ok then break end
        local serpent_ok, lua_table = serpent.load(val)
        if not serpent_ok then return false, keys end

        keys[key] = lua_table
        exists = true
    end

    return exists, keys
end

---@param ext string
---@param key string
function project_state.get(ext, key)
    local current_project, _ = reaper.EnumProjects(-1, "")
    local exists, value = reaper.GetProjExtState(current_project, ext, key)
    if not exists or not value then return false, 'Does not exist' end

    local ok, table = serpent.load(value)
    if not ok or not table or table.deleted then return false, table end
    return ok, table
end

---@param ext string
---@param key string
function project_state.delete(ext, key)
    -- reaper has the function 'DeleteExtState', but it doesn't work for project
    -- state, so I introduce a 'deleted' key to indicate deletion
    local ok, val = project_state.get(ext, key)
    if not ok or val.deleted then return end
    val.deleted = true
    project_state.overwrite(ext, key, val)
end

return project_state
