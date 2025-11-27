---@meta

---@alias Context "midi"|"main"|"global"
---@alias Mode "normal"|"visual_track"|"visual_timeline"
---@alias ReaProject number

---@class Command
---@field action_keys Action[]
---@field action_sequence ActionSequence
---@field context Context
---@field mode Mode

---@class State
---@field key_sequence string
---@field macro_recording boolean
---@field mode Mode
---@field last_searched_track_name string
---@field context Context
---@field macro_register string
---@field timeline_selection_side string
---@field last_track_name_search_direction_was_forward boolean
---@field last_command Command
---@field visual_track_pivot_i number

---@class KeyPress
---@field key string
---@field context Context

---@alias KeyCommand { [string]: string | {[1]:string, [2]:KeyCommand[]}}
---@alias Definition { [ActionType]: KeyCommand[]}
