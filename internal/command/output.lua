local definitions = require("utils.definitions")
local log = require('utils.log')
local ser = require("serpent")
local state_functions = require('state_machine.state_functions')

local output = {}

function runSubAction(id)
  local action = definitions.getAction(id)
  if action then
    output.runAction(action)
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

function output.runAction(action)
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

function output.runActionNTimes(action, times)
  for i=1,times,1 do
    output.runAction(action)
  end
end

function output.makeSelectionFromTimelineMotion(timeline_motion, repetitions)
  local sel_start = reaper.GetCursorPosition()
  output.runActionNTimes(timeline_motion, repetitions)
  local sel_end = reaper.GetCursorPosition()
  local length = sel_end - sel_start
  reaper.MoveEditCursor(length * -1, true)
end

function output.extendTimelineSelection(movement, args)
  movement(table.unpack(args))
  if state_functions.getTimelineSelectionSide() == 'right' then
    output.runAction({"SetTimeSelectionEnd"})
  else
    output.runAction({"SetTimeSelectionStart"})
  end
end

function output.addToTrackSelection(selection_action, args)
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

function output.makeSelectionFromTrackMotion(track_motion, repetitions)
  local num_tracks = reaper.GetNumTracks()

  local initial_track = reaper.GetSelectedTrack(0, 0)
  local first_index = reaper.GetMediaTrackInfo_Value(initial_track, "IP_TRACKNUMBER") - 1

  output.runActionNTimes(track_motion, repetitions)

  local end_track = reaper.GetSelectedTrack(0, 0)
  local second_index = reaper.GetMediaTrackInfo_Value(end_track, "IP_TRACKNUMBER") - 1

  log.info("first i:" .. first_index .. " second i: " .. second_index)

  if first_index > second_index then
    local swp = second_index
    second_index = first_index
    first_index = swp
  end

  for i=first_index,second_index do
    local track = reaper.GetTrack(0, i)
    log.info("making track sel")
    reaper.SetTrackSelected(track, true)
  end
end

return output
