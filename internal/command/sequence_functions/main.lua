local runner = require('command.runner')
local state_functions = require('state_machine.state_functions')

return {
  all_modes = {
    {
      { 'track_motion' },
      function(track_motion)
        runner.runAction(track_motion)
      end
    },
    {
      { 'number', 'track_motion' },
      function(number, track_motion)
        runner.runActionNTimes(track_motion, number)
      end
    },
  },
  visual_timeline = {
    {
      { 'track_selector' },
      function(track_operator, track_selector)
        runner.runAction(track_selector)
      end
    },
  },
  normal = {
    {
      { 'track_operator', 'track_motion' },
      function(track_operator, track_motion)
        runner.makeSelectionFromTrackMotion(track_motion, 1)
        runner.runAction(track_operator)
      end
    },
    {
      { 'track_operator', 'number', 'track_motion' },
      function(track_operator, number, track_motion)
        runner.makeSelectionFromTrackMotion(track_motion, number)
        runner.runAction(track_operator)
      end
    },
    {
      { 'track_operator', 'track_selector' },
      function(track_operator, track_selector)
        runner.runAction(track_selector)
        runner.runAction(track_operator)
      end
    },
  },
  visual_track = {
    {
      { 'track_operator' },
      function(track_operator)
        runner.runAction(track_operator)
        state_functions.resetToNormal()
      end
    },
    {
      { 'track_selector' },
      function(track_selector)
        runner.runAction(track_selector)
      end
    },
    {
      { 'track_motion' },
      function(track_motion)
        local args = {track_motion, 1}
        local sel_function = runner.makeSelectionFromTrackMotion
        runner.addToTrackSelection(sel_function, args)
      end
    },
    {
      { 'number', 'track_motion' },
      function(number, track_motion)
        local args = {track_motion, number}
        local sel_function = runner.makeSelectionFromTrackMotion
        runner.addToTrackSelection(sel_function, args)
      end
    },
  }
}
