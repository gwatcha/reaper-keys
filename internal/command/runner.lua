local definitions = require("utils.definitions")
local log = require('utils.log')
local state_functions = require('state_machine.state_functions')

local runner = {}

function runSubAction(id)
  local action = definitions.getAction(id)
  if action then
    runner.runAction(action)
    return
  end

  if type(id) == "function" then
    id()
    return
  end

  local numeric_id = id
  if type(id) == "string" then
    numeric_id = reaper.NamedCommandLookup(id)
  end

  if not numeric_id then
    log.fatal("Could not find action with id: " .. id)
    return
  end

  reaper.Main_OnCommand(numeric_id, 0)
end

function runner.runAction(action)
  local sub_actions = action
  if type(action) ~= 'table' then
    sub_actions = {action}
  end

  local repetitions = 1
  if sub_actions['repetitions'] then
    repetitions = action['repetitions']
  end

  for i=1,repetitions do
    for _, sub_action in ipairs(sub_actions) do
      runSubAction(sub_action)
    end
  end

end

function runner.runActionNTimes(action, times)
  for i=1,times,1 do
    runner.runAction(action)
  end
end

function runner.makeSelectionFromTimelineMotion(timeline_motion, repetitions)
  local sel_start = reaper.GetCursorPosition()
  runner.runActionNTimes(timeline_motion, repetitions)
  local sel_end = reaper.GetCursorPosition()
  reaper.SetEditCurPos(sel_start, false, false)

  reaper.GetSet_LoopTimeRange(true, false, sel_start, sel_end, false)
end

function runner.extendTimelineSelection(movement, args)
  local start_pos = reaper.GetCursorPosition()
  movement(table.unpack(args))
  local end_pos = reaper.GetCursorPosition()

  local left, right = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
  if not left or not right then
    left, right = start_pos, end_pos
  end

  if state_functions.getTimelineSelectionSide() == 'right' then
    reaper.GetSet_LoopTimeRange(true, false, left, end_pos, false)
  else
    reaper.GetSet_LoopTimeRange(true, false, end_pos, right, false)
  end
end

function runner.addToTrackSelection(selection_action, args)
  local selected_tracks = {}
  for i=0,reaper.CountSelectedTracks()-1 do
    local track = reaper.GetSelectedTrack(0, i)
    selected_tracks[i] = track
  end

  selection_action(table.unpack(args))

  for _,previously_selected_track in pairs(selected_tracks) do
    reaper.SetTrackSelected(previously_selected_track, true)
  end
end

function runner.makeSelectionFromTrackMotion(track_motion, repetitions)
  local num_tracks = reaper.GetNumTracks()

  local initial_track = reaper.GetSelectedTrack(0, 0)
  local first_index = reaper.GetMediaTrackInfo_Value(initial_track, "IP_TRACKNUMBER") - 1

  runner.runActionNTimes(track_motion, repetitions)

  local end_track = reaper.GetSelectedTrack(0, 0)
  local second_index = reaper.GetMediaTrackInfo_Value(end_track, "IP_TRACKNUMBER") - 1

  if first_index > second_index then
    local swp = second_index
    second_index = first_index
    first_index = swp
  end

  for i=first_index,second_index do
    local track = reaper.GetTrack(0, i)
    reaper.SetTrackSelected(track, true)
  end
end

return runner
