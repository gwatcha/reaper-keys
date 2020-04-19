local state_interface= {}

local serpent = require("serpent")
local info = debug.getinfo(1,'S');
local root_path = info.source:match[[.*vimper/]]:sub(2)
local state_file_path = root_path .. "state_machine/state"

local table_io = require("utils.table_io")

local default_state = {
  key_sequence = "",
  last_time = os.time(),
  last_action = "", -- TODO limit to vimper actions or all actions?
  last_context = "main",
  mode = 0,
  macro_recording = false,
  macro_register = "",
}

function state_interface.set(state)
  table_io.write(state_file_path, state)
end

function state_interface.get()
    local ok, state = table_io.read(state_file_path)
    if not ok then
      log.warn("Could not read state data from file, it may have become corrupted.")
      state = default_state
    end

  return state
end

return state_interface
