local serpent = require 'serpent'
local reaper_state = {}
local namespace = "reaper_keys"

---@param table_name string
function reaper_state.delete(table_name)
    reaper.DeleteExtState(namespace, table_name, true)
end

---@param table_name string
---@param lua_table table
function reaper_state.set(table_name, lua_table)
    local serialized = serpent.dump(lua_table, { comment = false })
    reaper.SetExtState(namespace, table_name, serialized, true)
end

---retrieve a table from the reaper ext state
---@param table_name string
---@return table|nil ext_value
function reaper_state.get(table_name)
    local state = reaper.GetExtState(namespace, table_name)
    if not state then return nil end
    local ok, table = serpent.load(state)
    if not ok or not table or type(table) ~= 'table' then return nil end
    return table
end

---append a new data to a key in a table
---@param name string
---@param key string
---@param new_data string|table
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
        all_data[key] = { new_data }
    end
    reaper_state.set(name, all_data)
end

---set all the keys in new_data to the table_name in ext_state
---@param table_name string
---@param new_data table
function reaper_state.setKeys(table_name, new_data)
    local saved_table = reaper_state.get(table_name)
    if not saved_table then saved_table = {} end

    for key, value in pairs(new_data) do saved_table[key] = value end
    reaper_state.set(table_name, saved_table)
end

---@param table_name string
---@param key string
---@return nil|table|string
function reaper_state.getKey(table_name, key)
    local saved_table = reaper_state.get(table_name)
    if not saved_table then return nil end
    return saved_table[key]
end

function reaper_state.clearJustOpenedFlag()
    local is_open = reaper.GetExtState(namespace, "reaper_started")
    if is_open == "open" then return false end
    reaper.SetExtState(namespace, "reaper_started", "open", false)
    return true
end

return reaper_state
