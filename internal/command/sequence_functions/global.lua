local output = require('command.output')
local log = require('utils.log')
local state_functions = require('state_machine.state_functions')
local definitions = require("utils.definitions")

function formatInvalidSequenceMessage(action_sequence)
  return "A '" .. action_sequence  .. "' action sequence has been called, even though these types of sequences should be handled by the state machine."
end

return {
  all_modes = {
    {
      { 'number', 'meta_command', 'register_location' },
      function()
        log.fatal(formatInvalidSequenceMessage(" 'number', 'meta_command', 'register_location' "))
      end
    },
    {
      { 'number', 'meta_command'},
      function()
        log.fatal(formatInvalidSequenceMessage(" 'number', 'meta_command'"))
      end
    },
    {
      { 'meta_command', 'register_location' },
      function()
        log.fatal(formatInvalidSequenceMessage(" 'meta_command', 'register_location' "))
      end
     },
    {
      { 'meta_command'},
      function()
        log.fatal(formatInvalidSequenceMessage(" 'meta_command'"))
      end
    },
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
        output.runAction(timeline_selector)
        output.runAction(timeline_operator)
      end
    },
    {
      { 'timeline_operator', 'timeline_motion' },
      function(timeline_operator, timeline_motion)
        output.makeSelectionFromTimelineMotion(timeline_motion, 1)
        output.runAction(timeline_operator)
      end
    },
    {
      { 'timeline_operator', 'number', 'timeline_motion' },
      function(timeline_operator, number, timeline_motion)
        output.makeSelectionFromTimelineMotion(timeline_motion, number)
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
      { 'visual_timeline_command' },
      function(visual_timeline_command)
        output.runAction(visual_timeline_command)
      end
    },
    {
      { 'timeline_operator' },
      function(timeline_operator)
        output.runAction(timeline_operator)
        state_functions.resetToNormal()
      end
    },
    {
      { 'timeline_selector' },
      function(timeline_selector)
        output.runAction(timeline_selector)
      end
    },
    {
      { 'timeline_motion' },
      function(timeline_motion)
        local args = {timeline_motion}
        local move_function = output.runAction
        output.extendTimelineSelection(move_function, args)
      end
    },
    {
      { 'number', 'timeline_motion' },
      function(number, timeline_motion)
        local args = {timeline_motion, number}
        local move_function = output.runActionNTimes
        output.extendTimelineSelection(move_function, args)
      end
    },
  }
}
