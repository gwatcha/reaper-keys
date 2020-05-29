local runner = require('command.runner')
local state_interface = require('state_machine.state_interface')
local config = require('definitions.config')
local reaper_utils = require('custom_actions.utils')

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
  normal = {
    {
      { 'track_operator', 'track_motion' },
      function(track_operator, track_motion)
        runner.runAction("SaveTrackSelection")
        runner.makeSelectionFromTrackMotion(track_motion, 1)
        runner.runAction(track_operator)
        if type(track_operator) ~= 'table' or not track_operator['setTrackSelection'] then
          runner.runAction("RestoreTrackSelection")
        end
      end
    },
    {
      { 'track_operator', 'number', 'track_motion' },
      function(track_operator, number, track_motion)
        runner.runAction("SaveTrackSelection")
        runner.makeSelectionFromTrackMotion(track_motion, number)
        runner.runAction(track_operator)
        if type(track_operator) ~= 'table' or not track_operator['setTrackSelection'] then
          runner.runAction("RestoreTrackSelection")
        end
      end
    },
    {
      { 'track_operator', 'track_selector' },
      function(track_operator, track_selector)
        runner.runAction("SaveTrackSelection")
        runner.runAction(track_selector)
        runner.runAction(track_operator)
        if type(track_operator) ~= 'table' or not track_operator['setTrackSelection'] then
          runner.runAction("RestoreTrackSelection")
        end
      end
    },
  },
  visual_track = {
    {
      { 'visual_track_command' },
      function(visual_track_command)
        runner.runAction(visual_track_command)
      end
    },
    {
      { 'track_operator' },
      function(track_operator)
        runner.runAction(track_operator)
        state_interface.setModeToNormal()
        if not config['persist_visual_track_selection'] then
          reaper_utils.unselectAllButLastTouchedTrack()
        end
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
        runner.extendTrackSelection(sel_function, args)
      end
    },
    {
      { 'number', 'track_motion' },
      function(number, track_motion)
        local args = {track_motion, number}
        local sel_function = runner.makeSelectionFromTrackMotion
        runner.extendTrackSelection(sel_function, args)
      end
    },
  }
}