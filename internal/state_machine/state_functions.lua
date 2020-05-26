local state_interface = require('state_machine.state_interface')
local constants = require('state_machine.constants')
local utils = require('command.utils')

local state_functions = {}

function state_functions.getLastSearchedTrackNameAndDirection()
  local state = state_interface.get()
  return state['last_searched_track_name'], state['last_track_name_search_direction_was_forward']
end

function state_functions.setLastSearchedTrackNameAndDirection(name, forward)
  local new_state = state_interface.get()
  new_state['last_searched_track_name'] = name
  new_state['last_track_name_search_direction_was_forward'] = forward
  state_interface.set(new_state)
end

function state_functions.checkIfConsistentState(state)
  local current_state = state_interface.get()
  for k,value in pairs(current_state) do
    if k == 'last_command' then
      if not utils.checkIfCommandsAreEqual(state.last_command, current_state.last_command) then
        return false
      end
    elseif value ~= state[k] then
        return false
    end
  end
  return true
end

function state_functions.setTimelineSelectionSide(left_or_right)
  local state = state_interface.get()
  state['timeline_selection_side'] = left_or_right
  state_interface.set(state)
end

function state_functions.getTimelineSelectionSide()
  local state = state_interface.get()
  return state['timeline_selection_side']
end

function state_functions.getMode()
  local state = state_interface.get()
  return state.mode
end

function state_functions.setMode(mode)
  local state = state_interface.get()
  state.mode = mode
  state_interface.set(state)
end

function state_functions.setModeToNormal()
  local state = state_interface.get()
  state['key_sequence'] = ""
  state['context'] = "main"
  state['mode'] = "normal"
  state['timeline_selection_side'] = "left"
  state_interface.set(state)
end

function state_functions.resetFully()
  state_interface.set(constants['reset_state'])
end

return state_functions
