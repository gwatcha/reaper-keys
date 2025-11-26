---@meta

---@alias Context "midi"|"main"|"global"

---@alias Mode "normal"|"visual_track"|"visual_timeline"

---@alias ReaProject number

---@class Command
---@field action_keys Action[]
---@field action_sequence string[]
---@field context Context
---@field mode string "normal"|"insert" ?

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

---@class Definition
---@field command KeyCommand[]
---@field timeline_motion KeyCommand[]
---@field timeline_operator KeyCommand[]
---@field timeline_selector KeyCommand[]
---@field track_motion? KeyCommand[] main context only
---@field track_operator? KeyCommand[] main context only
---@field track_selector? KeyCommand[] main context only
---@field visual_timeline_command? KeyCommand[]
---@field visual_track_command? KeyCommand[]  main context only
