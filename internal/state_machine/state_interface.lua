local reaper_state = require('utils.reaper_state')
local log = require('utils.log')
local constants = require('state_machine.constants')
local utils = require('command.utils')

local state_interface= {}
local state_table_name = "state"

function state_interface.set(state)
  reaper_state.set(state_table_name, state)
end

function state_interface.setKey(key, value)
  local state = state_interface.get()
  state[key] = value
  state_interface.set(state)
end

function state_interface.getField(field)
  local state = state_interface.get()
  return state[field]
end

function state_interface.get()
    local state = reaper_state.get(state_table_name)
    if not state then
      log.info("Could not read state data. Returning reset state.")
      state = constants['reset_state']
    end
  return state
end

-- FIXME reduntant functions

function state_interface.getLastSearchedTrackNameAndDirection()
  local state = state_interface.get()
  return state['last_searched_track_name'], state['last_track_name_search_direction_was_forward']
end

function state_interface.setLastSearchedTrackNameAndDirection(name, forward)
  local new_state = state_interface.get()
  new_state['last_searched_track_name'] = name
  new_state['last_track_name_search_direction_was_forward'] = forward
  state_interface.set(new_state)
end

function state_interface.checkIfConsistentState(state)
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

function state_interface.setVisualTrackPivotIndex(visual_track_pivot_i)
  local state = state_interface.get()
  state['visual_track_pivot_i'] = visual_track_pivot_i
  state_interface.set(state)
end

function state_interface.getVisualTrackPivotIndex()
  local state = state_interface.get()
  local visual_track_pivot_i = state['visual_track_pivot_i']
  return visual_track_pivot_i
end

function state_interface.setTimelineSelectionSide(left_or_right)
  local state = state_interface.get()
  state['timeline_selection_side'] = left_or_right
  state_interface.set(state)
end

function state_interface.getTimelineSelectionSide()
  local state = state_interface.get()
  return state['timeline_selection_side']
end

function state_interface.getMode()
  local state = state_interface.get()
  return state.mode
end

function state_interface.setMode(mode)
  local state = state_interface.get()
  state.mode = mode
  state_interface.set(state)
end

function state_interface.setModeToNormal()
  local state = state_interface.get()
  state['key_sequence'] = ""
  state['context'] = "main"
  state['mode'] = "normal"
  state['timeline_selection_side'] = "left"
  state_interface.set(state)
end

return state_interface
