local default_state = require 'default_state'
local serpent = require 'serpent'

---@alias Context "midi"|"main"|"global"
---@alias Mode "normal"|"visual_track"|"visual_timeline"
---@alias ReaProject number
---@alias TimelineSelectionSide "left"|"right"
--
---@class Command
---@field action_keys Action[]
---@field action_sequence ActionSequence
---@field context Context
---@field mode Mode
--
---@class State
---@field key_sequence string
---@field macro_recording boolean
---@field mode Mode
---@field last_searched_track_name string
---@field context Context
---@field macro_register string
---@field timeline_selection_side TimelineSelectionSide
---@field last_track_name_search_direction_was_forward boolean
---@field last_command Command
---@field visual_track_pivot_i number

local reaper_state = {}
local namespace = "reaper_keys"

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

--- @param name string
--- @param key string
--- @return table?
function reaper_state.getKey(name, key)
    local data = reaper_state.get(name)
    return data and data[key] or nil
end

function reaper_state.setKeys(name, keys)
    local data = reaper_state.get(name)
    if not data then data = {} end
    for key, value in pairs(keys) do data[key] = value end
    reaper_state.set(name, data)
end

local rk_state_table_name = "state"

---@param state State
function reaper_state.setState(state)
    reaper_state.set(rk_state_table_name, state)
end

---@return State
function reaper_state.getState()
    return reaper_state.get(rk_state_table_name) or default_state
end

return reaper_state
