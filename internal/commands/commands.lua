local state_machine_definitions = require('state_machine.state_machine_definitions')
local log = require('utils.log')

local commands = {}

function findFunctionForCommand(entry_types, context, mode)

end

function commands.executeCommand(state, entry_types, entry_values)
  if entry_types.len ~= entry_value.len then
    log.error('Number of entry types (' + entry_types.len + ') does not equal number of entry values (' + entry_values.len + ')')
    return state_machine_definitions['reset_state']
  end

  local commandFunction = findFunctionForCommand(entry_types, state[context], state[mode])
  if not commandFunction then
    commandFunction = findFunctionForCommand(entry_types, global, state[mode])
  end

  if not commandFunction then
    log.error('Did not find an associated command function to execute for this command!')
    return state_machine_definitions['reset_state']
  end

  local new_state = commandFunction(unpack(entry_values))
end

local functions = {
  global = {
    normal = require('commands.global.normal') {
      {
        { 'macro_play', 'register_location' },
        function(state, macro_play, register_location)
          return state
        end
      },
      {
        { 'macro_rec', 'register_location' },
        function(state, macro_rec, register_location)
          return state
        end
      },
      {
        { 'register_key', 'register_location', 'register_action' },
        function(state, register_key, register_location, register_action)
          return state
        end
      },
      {
        { 'timeline_operator', 'timeline_selector' },
        function(state, timeline_operator, timeline_selector)
          return state
        end
      },
      {
        { 'timeline_operator', 'timeline_motion' },
        function(state, timeline_operator, timeline_motion)
          return state
        end
      },
      {
        { 'timeline_operator', 'number', 'timeline_motion' },
        function(state, timeline_operator, number, timeline_motion)
          return state
        end
      },
      {
        { 'timeline_motion' },
        function(state, timeline_motion)
          return state
        end
      },
      {
        { 'number', 'timeline_motion' },
        function(state, number, timeline_motion)
          return state
        end
      },
      {
        { 'action' },
        function(state, action)
          return state
        end
      },
      {
        { 'number', 'action' },
        function(state, number, action)
          return state
                               end
      },
    },
    visual_timeline = {
      {
        { 'timeline_operator' },
        function(state, timeline_operator)
          return state
        end
      },
      {
        { 'timeline_motion' },
        function(state, timeline_motion)
          return state
        end
      },
      {
        { 'number', 'timeline_motion' },
        function(state, number, timeline_motion)
          return state
        end
      },
      {
        { 'action' },
        function(state, action)
          return state
        end
      },
      {
        { 'number', 'action' },
        function(state, number, action)
          return state
                               end
      },
    }
  },
  main = {
    normal = {
      {
        { 'track_operator', 'track_selector' },
        function(state, track_operator, track_selector)
          return state
        end
      },
      {
        { 'track_operator', 'number', 'track_motion' },
        function(state, track_operator, number, track_motion)
          return state
                                                       end
      },
    },
    visual_track = {
      {
        { 'track_operator' },
        function(state, track_operator)
          return state
        end
      },
      {
        { 'track_motion' },
        function(state, track_motion)
          return state
        end
      },
      {
        { 'track_selector' },
        function(state, track_selector)
          return state
        end
      },
      {
        { 'number', 'track_motion' },
        function(state, number, track_motion)
          return state
        end
      },
      {
        { 'action' },
        function(state, action)
          return state
        end
      },
      {
        { 'number', 'action' },
        function(state, number, action)
          return state
        end
      },
    },
  },
  midi = {},
}

