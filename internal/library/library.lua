local constants = require('state_machine.constants')
local state_functions = require('state_machine.state_functions')
local executeCommand = require("command.executor")
local log = require('utils.log')

local library = {}

function library.resetToNormal()
  state_interface.set(constants['reset_state'])
end

function library.repeatLastCommand()
  local last_command = state_functions.getLastCommand()
  local context = state_functions.getContext()
  local mode = state_functions.getMode()
  command.executeCommand(last_command, context, mode)
end

function library.openConfig()
end

function library.pasteRegister()
end

function library.playMacro()
end

function library.recordMacro()
end

function library.saveFxChain()
end

function toggleMode(mode)
  local state = state_interface.get()
  if state.mode == mode then
    state.mode = 'normal'
  else
    state.mode = mode
  end
  state_interface.set(state)
end

function library.visualTrackMode()
  toggleMode('visual_track')
end

function library.visualTimelineMode()
  toggleMode('visual_timeline')
end

return library

