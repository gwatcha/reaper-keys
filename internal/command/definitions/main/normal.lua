local cmd = require('command.output')
local log = require('utils.log')
local ser = require("serpent")

return {
  {
    { 'track_motion' },
    function(state, track_motion)
      cmd.runReaperCommand(track_motion)
      return state
    end
  },
  {
    { 'number', 'track_motion' },
    function(state, number, track_motion)
      cmd.runReaperCommandNTimes(track_motion, number)
      return state
    end
  },
  {
    { 'track_operator', 'track_motion' },
    function(state, track_operator, number, track_motion)
      return state
    end
  },
  {
    { 'track_operator', 'number', 'track_motion' },
    function(state, track_operator, number, track_motion)
      return state
    end
  },
  {
    { 'track_operator', 'track_selector' },
    function(state, track_operator, track_selector)
      return state
    end
  },
}
