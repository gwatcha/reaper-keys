local state_functions = require('state_machine.state_functions')

local library = {}

function library.setModeNormal()
  state_functions.setMode('normal')
end

function library.setModeVisualTrack()
  local first_track = reaper.GetSelectedTrack(0, 0)
  reaper.SetOnlyTrackSelected(first_track)
  state_functions.setMode('visual_track')
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

return library
