local state_interface = require('state_machine.state_interface')
local state = {}

function state.setModeNormal()
  state_interface.setMode('normal')
end

function state.setModeVisualTrack()
  local current_track = reaper.GetLastTouchedTrack()
  if current_track then
    reaper.SetOnlyTrackSelected(current_track)

    local visual_track_pivot_index = reaper.GetMediaTrackInfo_Value(current_track, "IP_TRACKNUMBER") - 1

    state_interface.setMode('visual_track')
    state_interface.setVisualTrackPivotIndex(visual_track_pivot_index)
  end
end

function state.setModeVisualTimeline()
  state_interface.setMode('visual_timeline')
  if state_interface.getTimelineSelectionSide() == 'left' then
    state_interface.setTimelineSelectionSide('right')
  end
end

function state.switchTimelineSelectionSide()
  local GoToStartOfSelection = 40630
  local GoToEndOfSelection = 40631

  if state_interface.getTimelineSelectionSide() == 'right' then
    reaper.Main_OnCommand(GoToStartOfSelection, 0)
    state_interface.setTimelineSelectionSide('left')
  else
    reaper.Main_OnCommand(GoToEndOfSelection, 0)
    state_interface.setTimelineSelectionSide('right')
  end
end

return state
