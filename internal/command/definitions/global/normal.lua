local output = require('command.output')
local log = require("utils.log")
local ser = require("serpent")

return {
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
        output.runAction(timeline_selector)
        output.runAction(timeline_operator)
        return state
      end
    },
    {
      { 'timeline_operator', 'timeline_motion' },
      function(state, timeline_operator, timeline_motion)
        output.makeSelectionFromMotion(timeline_motion, 1)
        output.runAction(timeline_operator)
        return state
      end
    },
    {
      { 'timeline_operator', 'number', 'timeline_motion' },
      function(state, timeline_operator, number, timeline_motion)
        output.makeSelectionFromMotion(timeline_motion, number)
        output.runAction(timeline_operator)
        return state
      end
    },
    {
      { 'timeline_motion' },
      function(state, timeline_motion)
        output.runAction(timeline_motion)
        return state
      end
    },
    {
      { 'number', 'timeline_motion' },
      function(state, number, timeline_motion)
        output.runActionNTimes(timeline_motion, number)
        return state
      end
    },
    {
      { 'command' },
      function(state, action)
        output.runAction(action)
        return state
      end
    },
    {
      { 'number', 'command' },
      function(state, number, action)
        output.runActionNTimes(action, number)
        return state
      end
    },
}
