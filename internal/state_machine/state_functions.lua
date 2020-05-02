local state_interface = require('state_machine.state_interface')

local state_functions = {}

function state_functions.resetToNormal()
  state_interface.set(constants['reset_state'])
end

function state_functions.getContext()
  local state = state_interface.get()
  return state['context']
end

function state_functions.getMode()
  local state = state_interface.get()
  return state['mode']
end

function state_functions.getLastCommand()
  local state = state_interface.get()
  return state['last_command']
end

return state_functions
