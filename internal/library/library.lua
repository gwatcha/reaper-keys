local state_interface = require('state_machine.state_interface')
local reaper_state = require('utils.reaper_state')
local feedback = require('gui.feedback.controller')
-- TODO merge with movements to internal/actions_impl.lua

local function getMatchedTrack(search_name, forward)
  if not search_name then return nil end

  local current_track = reaper.GetSelectedTrack(0, 0)
  local start_i = 0
  if current_track then
    start_i = reaper.GetMediaTrackInfo_Value(current_track, "IP_TRACKNUMBER") - 1
  end

  local num_tracks = reaper.GetNumTracks()
  local tracks_searched = 1
  local next_track_i = start_i
  while tracks_searched < num_tracks do
    if forward == true then
      next_track_i = next_track_i + 1
    else
      next_track_i = next_track_i - 1
    end

    local track = reaper.GetTrack(0, next_track_i)
    if not track then
      if forward == true then
        next_track_i = -1
      else
        next_track_i = num_tracks
      end
    else
      local _, current_name = reaper.GetTrackName(track, "")
      local has_no_name = current_name:match("Track ([0-9]+)", 1)
      current_name = current_name:lower()
      tracks_searched = tracks_searched + 1
      if not has_no_name and current_name:match(search_name:lower()) then
        return track
      end
    end
  end

  return nil
end


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

-- No time selection?
---@type integer
local paste = reaper.NamedCommandLookup("_SWS_AWPASTE")
-- When multiple tracks are selected, paste pastes on last touched track but we
-- want to paste selected track-wise, skipping empty tracks
function library.paste()
    local num = reaper.CountSelectedTracks()
    if num < 2 then return reaper.Main_OnCommand(paste, 0) end
    local sel = {}
    local first = nil
    for i = 0, num - 1 do
        local track = reaper.GetSelectedTrack(0, i)
        if not first and reaper.GetTrackNumMediaItems(track) > 0 then first = track end
        sel[i + 1] = track
    end
    reaper.SetOnlyTrackSelected(first)
    reaper.Main_OnCommand(paste, 0)
    for _, track in ipairs(sel) do reaper.SetTrackSelected(track, true) end
end

return library
