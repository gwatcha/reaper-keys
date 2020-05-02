local output = require('command.output')
local log = require('utils.log')
local state_functions = require('state_machine.state_functions')

return {
  all_modes = {
    {
      { 'command' },
      function(action)
        output.runAction(action)
      end
    },
    {
      { 'number', 'command' },
      function(number, action)
        output.runActionNTimes(action, number)
      end
    },
    {
      { 'macro_play', 'register_location' },
      function(macro_play, register_location)
      end
    },
    {
      { 'macro_rec', 'register_location' },
      function(macro_rec, register_location)
      end
    },
    {
      { 'register_key', 'register_location', 'register_action' },
      function(register_key, register_location, register_action)
      end
    },
  },
  normal = {
    {
      { 'timeline_operator', 'timeline_selector' },
      function(timeline_operator, timeline_selector)
        output.runAction(timeline_selector)
        output.runAction(timeline_operator)
      end
    },
    {
      { 'timeline_operator', 'timeline_motion' },
      function(timeline_operator, timeline_motion)
        output.makeSelectionFromMotion(timeline_motion, 1)
        output.runAction(timeline_operator)
      end
    },
    {
      { 'timeline_operator', 'number', 'timeline_motion' },
      function(timeline_operator, number, timeline_motion)
        output.makeSelectionFromMotion(timeline_motion, number)
        output.runAction(timeline_operator)
      end
    },
    {
      { 'timeline_motion' },
      function(timeline_motion)
        output.runAction(timeline_motion)
      end
    },
    {
      { 'number', 'timeline_motion' },
      function(number, timeline_motion)
        output.runActionNTimes(timeline_motion, number)
      end
    },
  },
  visual_timeline = {
    {
      { 'timeline_operator' },
      function(timeline_operator)
        output.runAction(track_motion)
        state_functions.resetToNormal()
      end
    },
    {
      { 'timeline_motion' },
      function(timeline_motion)
      end
    },
    {
      { 'number', 'timeline_motion' },
      function(number, timeline_motion)
      end
    },
  }
}
