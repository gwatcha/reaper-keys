local runner = require('command.runner')
local log = require('utils.log')
local state_functions = require('state_machine.state_functions')
local definitions = require("utils.definitions")

function invalidSequenceCall(...)
  log.error("An action sequence without a command function was called (likely contians a 'meta_command' type).")
  log.trace(debug.trace())
end

return {
  all_modes = {
    {{ 'number', 'meta_command', 'register_location' }, invalidSequenceCall},
    {{ 'meta_command', 'register_location' }, invalidSequenceCall},
    {{ 'meta_command'}, invalidSequenceCall},
    {
      { 'command' },
      function(action)
        runner.runAction(action)
      end
    },
    {
      { 'number', 'command' },
      function(number, action)
        runner.runActionNTimes(action, number)
      end
    },
    {
      { 'register_action', 'register_location' },
      function(register_action, register_location)
        register_action(register_location)
      end
    },
  },
  normal = {
    {
      { 'timeline_operator', 'timeline_selector' },
      function(timeline_operator, timeline_selector)
        runner.runAction(timeline_selector)
        runner.runAction(timeline_operator)
      end
    },
    {
      { 'timeline_operator', 'timeline_motion' },
      function(timeline_operator, timeline_motion)
        runner.makeSelectionFromTimelineMotion(timeline_motion, 1)
        runner.runAction(timeline_operator)
      end
    },
    {
      { 'timeline_operator', 'number', 'timeline_motion' },
      function(timeline_operator, number, timeline_motion)
        runner.makeSelectionFromTimelineMotion(timeline_motion, number)
        runner.runAction(timeline_operator)
      end
    },
    {
      { 'timeline_motion' },
      function(timeline_motion)
        runner.runAction(timeline_motion)
      end
    },
    {
      { 'number', 'timeline_motion' },
      function(number, timeline_motion)
        runner.runActionNTimes(timeline_motion, number)
      end
    },
  },
  visual_timeline = {
    {
      { 'visual_timeline_command' },
      function(visual_timeline_command)
        runner.runAction(visual_timeline_command)
      end
    },
    {
      { 'timeline_operator' },
      function(timeline_operator)
        runner.runAction(timeline_operator)
        state_functions.resetToNormal()
      end
    },
    {
      { 'timeline_selector' },
      function(timeline_selector)
        runner.runAction(timeline_selector)
      end
    },
    {
      { 'timeline_motion' },
      function(timeline_motion)
        local args = {timeline_motion}
        local move_function = runner.runAction
        runner.extendTimelineSelection(move_function, args)
      end
    },
    {
      { 'number', 'timeline_motion' },
      function(number, timeline_motion)
        local args = {timeline_motion, number}
        local move_function = runner.runActionNTimes
        runner.extendTimelineSelection(move_function, args)
      end
    },
  }
}
