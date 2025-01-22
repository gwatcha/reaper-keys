local state_interface = require('state_machine.state_interface')
local getMatchedTrack = require('custom_actions.utils').getMatchedTrack
local reaper_state = require('utils.reaper_state')
local feedback = require('gui.feedback.controller')

local library = {
  marks = require('library.marks'),
  state = require('library.state')
}

function library.matchTrackNameBackward()
  local _, name = reaper.GetUserInputs("Match Backward", 1, "Match String", "")
  local track = getMatchedTrack(name, false)
  if track then
    state_interface.setLastSearchedTrackNameAndDirection(name, false)
    reaper.SetOnlyTrackSelected(track)
  else
    state_interface.setLastSearchedTrackNameAndDirection("^$", true)
    feedback.displayMessage("No match for " .. name)
  end
end

function library.matchTrackNameForward()
  local _, name = reaper.GetUserInputs("Match Forward", 1, "Match String", "")
  local track = getMatchedTrack(name, true)
  if track then
    state_interface.setLastSearchedTrackNameAndDirection(name, true)
    reaper.SetOnlyTrackSelected(track)
  else
    state_interface.setLastSearchedTrackNameAndDirection("^$", true)
    feedback.displayMessage("No match for " .. name)
  end
end

function library.repeatTrackNameMatchForward()
  local last_matched, forward = state_interface.getLastSearchedTrackNameAndDirection()
  local track = getMatchedTrack(last_matched, forward)
  if track then
    reaper.SetOnlyTrackSelected(track)
  end
end

function library.repeatTrackNameMatchBackward()
  local last_searched, forward = state_interface.getLastSearchedTrackNameAndDirection()
  local track = getMatchedTrack(last_searched, not forward)
  if track then
    reaper.SetOnlyTrackSelected(track)
  end
end

function library.ResetFeedbackWindow()
  reaper_state.setKeys("feedback", {open = false})
end

return library
