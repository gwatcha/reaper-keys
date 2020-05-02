local state_interface= {}

local info = debug.getinfo(1,'S');
local root_path = info.source:match[[[^@]*reaper.keys/]]
local state_file_path = root_path .. "internal/state_machine/state"

local table_io = require("utils.table_io")
local log = require("utils.log")

local state_machine_constants = require("state_machine.constants")

function state_interface.set(state)
  table_io.write(state_file_path, state)
end

function state_interface.get()
    local ok, state = table_io.read(state_file_path)
    if not ok then
      log.error("Could not read state data from file, it may have become corrupted. Resetting.")
      state = state_machine_constants['reset_state']
    end

  return state
end

return state_interface
