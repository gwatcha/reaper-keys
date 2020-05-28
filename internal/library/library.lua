local state_functions = require('state_machine.state_functions')
local custom_actions = require('custom_actions')
local reaper_util = require('custom_actions.utils')

local log = require('utils.log')
local marks = require('library.marks')

local library = {}
library.marks = marks

function library.setModeNormal()
  state_functions.setMode('normal')
end

function library.setModeVisualTrack()
  local NextTrack = 40285
  local PrevTrack = 40286

  local first_track = reaper.GetSelectedTrack(0, 0)
  if not first_track then
    -- get the implicitly selected track
    reaper.Main_OnCommand(NextTrack, 0)
    reaper.Main_OnCommand(PrevTrack, 0)
  end
  first_track = reaper.GetSelectedTrack(0, 0)
  reaper.SetOnlyTrackSelected(first_track)

  local visual_track_pivot_i = reaper.GetMediaTrackInfo_Value(first_track, "IP_TRACKNUMBER") - 1

  state_functions.setMode('visual_track')
  state_functions.setVisualTrackPivotIndex(visual_track_pivot_i)
end

function library.setModeVisualTimeline()
  local current_position = reaper.GetCursorPosition()
  reaper.GetSet_LoopTimeRange(true, false, current_position, current_position, false)
  state_functions.setMode('visual_timeline')

  if state_functions.getTimelineSelectionSide() == 'left' then
    state_functions.setTimelineSelectionSide('right')
  end
end

function library.switchTimelineSelectionSide()
  local go_to_start_of_selection = 40630
  local go_to_end_of_selection = 40631

  if state_functions.getTimelineSelectionSide() == 'right' then
    reaper.Main_OnCommand(go_to_start_of_selection, 0)
    state_functions.setTimelineSelectionSide('left')
  else
    reaper.Main_OnCommand(go_to_end_of_selection, 0)
    state_functions.setTimelineSelectionSide('right')
  end
end

function library.matchTrackNameBackward()
  local _, name = reaper.GetUserInputs("Match Backward", 1, "Match String", "")
  local track = reaper_util.getMatchedTrack(name, false)
  if track then
    state_functions.setLastSearchedTrackNameAndDirection(name, false)
    reaper.SetOnlyTrackSelected(track)
  else
    state_functions.setLastSearchedTrackNameAndDirection("^$", true)
    log.user("No match for " .. name)
  end
end

function library.matchTrackNameForward()
  local _, name = reaper.GetUserInputs("Match Forward", 1, "Match String", "")
  local track = reaper_util.getMatchedTrack(name, true)
  if track then
    state_functions.setLastSearchedTrackNameAndDirection(name, true)
    reaper.SetOnlyTrackSelected(track)
  else
    state_functions.setLastSearchedTrackNameAndDirection("^$", true)
    log.user("No match for " .. name)
  end
end

function library.repeatTrackNameMatchForward()
  local last_matched, forward = state_functions.getLastSearchedTrackNameAndDirection()
  local track = reaper_util.getMatchedTrack(last_matched, forward)
  if track then
    reaper.SetOnlyTrackSelected(track)
  end
end

function library.repeatTrackNameMatchBackward()
  local last_searched, forward = state_functions.getLastSearchedTrackNameAndDirection()
  local track = reaper_util.getMatchedTrack(last_searched, not forward)
  if track then
    reaper.SetOnlyTrackSelected(track)
  end
end

return library
