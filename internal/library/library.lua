local state_interface = require('state_machine.state_interface')
local custom_actions = require('custom_actions')
local reaper_utils = require('custom_actions.utils')

local log = require('utils.log')
local marks = require('library.marks')

local library = {}
library.marks = marks

function library.setModeNormal()
  state_interface.setMode('normal')
end

function library.setModeVisualTrack()
  local current_track = reaper.GetLastTouchedTrack()
  reaper.SetOnlyTrackSelected(current_track)

  local visual_track_pivot_i = reaper.GetMediaTrackInfo_Value(current_track, "IP_TRACKNUMBER") - 1

  state_interface.setMode('visual_track')
  state_interface.setVisualTrackPivotIndex(visual_track_pivot_i)
end

function library.setModeVisualTimeline()
  local current_position = reaper.GetCursorPosition()
  reaper.GetSet_LoopTimeRange(true, false, current_position, current_position, false)
  state_interface.setMode('visual_timeline')

  if state_interface.getTimelineSelectionSide() == 'left' then
    state_interface.setTimelineSelectionSide('right')
  end
end

function library.switchTimelineSelectionSide()
  local go_to_start_of_selection = 40630
  local go_to_end_of_selection = 40631

  if state_interface.getTimelineSelectionSide() == 'right' then
    reaper.Main_OnCommand(go_to_start_of_selection, 0)
    state_interface.setTimelineSelectionSide('left')
  else
    reaper.Main_OnCommand(go_to_end_of_selection, 0)
    state_interface.setTimelineSelectionSide('right')
  end
end

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
