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
local function set(table_name, lua_table)
    local serialized = serpent.dump(lua_table, { comment = false })
    reaper.SetExtState(namespace, table_name, serialized, true)
end

---retrieve a table from the reaper ext state
---@param table_name string
---@return table|nil ext_value
local function get(table_name)
    local state = reaper.GetExtState(namespace, table_name)
    if not state then return nil end
    local ok, table = serpent.load(state)
    if not ok or not table or type(table) ~= 'table' then return nil end
    return table
end

local function getKey(name, key)
    local data = get(name)
    return data and data[key] or nil
end

local function setKeys(name, keys)
    local data = get(name)
    if not data then data = {} end
    for key, value in pairs(keys) do data[key] = value end
    set(name, data)
end

---@param register string
---@return table?
function reaper_state.getMacro(register)
    return getKey('macros', register) --[[@as table?]]
end

---@param register string
function reaper_state.clearMacro(register)
    local blank_macro = {}
    blank_macro[register] = {}
    setKeys("macros", blank_macro)
end

---@param register string
---@param command Command
function reaper_state.appendToMacro(register, command)
    local all_data = get("macros")
    if not all_data then
        all_data = {}
        all_data[register] = command
        set("macros", all_data)
        return
    end

    if all_data[register] then
        table.insert(all_data[register], command)
    else
        all_data[register] = { command }
    end
    set("macros", all_data)
end

local rk_state_table_name = "state"

---@param state State
function reaper_state.setState(state)
    set(rk_state_table_name, state)
end

---@return State
function reaper_state.getState()
    return get(rk_state_table_name) or default_state
end

local binding_list_table_name = "binding_list"

function reaper_state.getBindingList()
    return get(binding_list_table_name)
end

function reaper_state.setBindingList(state)
    set(binding_list_table_name, state)
end

local feedback_table_name = "feedback"

function reaper_state.getFeedback()
    return get(feedback_table_name)
end

function reaper_state.getFeedbackKey(key)
    return getKey(feedback_table_name, key)
end

function reaper_state.setFeedbackKeys(keys)
    setKeys(feedback_table_name, keys)
end

function reaper_state.clearJustOpenedFlag()
    local is_open = reaper.GetExtState(namespace, "reaper_started")
    if is_open == "open" then return false end
    reaper.SetExtState(namespace, "reaper_started", "open", false)
    return true
end

function reaper_state.clearFeedbackOpen()
    setKeys(feedback_table_name, {open = false})
end

return reaper_state
