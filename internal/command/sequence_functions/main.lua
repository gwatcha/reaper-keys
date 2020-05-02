local output = require('command.output')
local state_functions = require('state_machine.state_functions')

return {
  all_modes = {},
  normal = {
    {
      { 'track_motion' },
      function(track_motion)
        output.runAction(track_motion)
      end
    },
    {
      { 'number', 'track_motion' },
      function(number, track_motion)
        output.runActionNTimes(track_motion, number)
      end
    },
    {
      { 'track_operator', 'track_motion' },
      function(track_operator, number, track_motion)
      end
    },
    {
      { 'track_operator', 'number', 'track_motion' },
      function(track_operator, number, track_motion)
      end
    },
    {
      { 'track_operator', 'track_selector' },
      function(track_operator, track_selector)
        output.runAction(track_selector)
        output.runAction(track_operator)
      end
    },
  },
  visual_track = {
    {
      { 'track_operator' },
      function(track_operator)
        output.runAction(track_operator)
        state_functions.resetToNormal()
      end
    },
    {
      { 'track_selector' },
      function(track_selector)
        output.runAction(track_selector)
      end
    },
    {
      { 'track_motion' },
      function(track_motion)
        local args = {track_motion, 1}
        local sel_function = output.makeSelectionFromTrackMotion
        output.addToTrackSelection(sel_function, args)
      end
    },
    {
      { 'number', 'track_motion' },
      function(number, track_motion)
        local args = {track_motion, number}
        local sel_function = output.makeSelectionFromTrackMotion
        output.addToTrackSelection(sel_function, args)
      end
    },
  }
}
