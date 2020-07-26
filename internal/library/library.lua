local state_interface = require('state_machine.state_interface')
local reaper_utils = require('custom_actions.utils')

local log = require('utils.log')
local marks = require('library.marks')
local state = require('library.state')

local library = {}
library.marks = marks
library.state = state

function library.matchTrackNameBackward()
  local _, name = reaper.GetUserInputs("Match Backward", 1, "Match String", "")
  local track = reaper_utils.getMatchedTrack(name, false)
  if track then
    state_interface.setLastSearchedTrackNameAndDirection(name, false)
    reaper.SetOnlyTrackSelected(track)
  else
    state_interface.setLastSearchedTrackNameAndDirection("^$", true)
    log.user("No match for " .. name)
  end
end

function library.matchTrackNameForward()
  local _, name = reaper.GetUserInputs("Match Forward", 1, "Match String", "")
  local track = reaper_utils.getMatchedTrack(name, true)
  if track then
    state_interface.setLastSearchedTrackNameAndDirection(name, true)
    reaper.SetOnlyTrackSelected(track)
  else
    state_interface.setLastSearchedTrackNameAndDirection("^$", true)
    log.user("No match for " .. name)
  end
end

function library.repeatTrackNameMatchForward()
  local last_matched, forward = state_interface.getLastSearchedTrackNameAndDirection()
  local track = reaper_utils.getMatchedTrack(last_matched, forward)
  if track then
    reaper.SetOnlyTrackSelected(track)
  end
end

function library.repeatTrackNameMatchBackward()
  local last_searched, forward = state_interface.getLastSearchedTrackNameAndDirection()
  local track = reaper_utils.getMatchedTrack(last_searched, not forward)
  if track then
    reaper.SetOnlyTrackSelected(track)
  end
end

return library
