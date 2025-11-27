local getAction = require('utils.get_action')
local log = require 'log'
local reaper_utils = require "movement_utils"
local runner = {}
local scrollToSelectedTracks = require 'definitions.actions'.ScrollToSelectedTracks
local state_interface = require('state_machine.state_interface')
local toTrack = require 'movements'.toTrack

---@param id ActionPart
local function runActionPart(id, midi_command)
  if type(id) == "function" then
    id()
    return
  end

  local numeric_id = id
  if type(id) == 'string' then
    local action = getAction(id)
    if action then
      runner.runAction(action)
      return
    end

    numeric_id = reaper.NamedCommandLookup(id)
    if numeric_id == 0 then
      log.error("Could not find action in reaper or action list for: " .. id)
      return
    end
  end

  if midi_command then
    reaper.MIDIEditor_LastFocused_OnCommand(numeric_id, false)
  else
    reaper.Main_OnCommand(numeric_id, 0)
  end
end

---@param action Action
function runner.runAction(action)
    if type(action) ~= 'table' then
        runActionPart(action --[[@as ActionPart]], false)
        return
    end

    ---@cast action ActionTable
    if action.registerAction then
        local register = action.register
        if not register then
            log.error("no register for register action")
            return
        end
        local fn = action[1]
        if type(fn) ~= 'function' then
            log.error(("expected fun, got %s"):format(fn))
            return
        end

        fn(register)
        return
    end

    local prefixedRepetitions = action.prefixedRepetitions or 1
    if action.toTrack then
        toTrack(prefixedRepetitions)
        reaper.Main_OnCommand(scrollToSelectedTracks, 0)
        return
    end

    local repetitions = action.repetitions or 1
    local midiCommand = action.midiCommand or false
    for _ = 1, repetitions * prefixedRepetitions do
        for _, sub_action in ipairs(action) do
            if type(sub_action) == 'table' then
                runner.runAction(sub_action)
            else
                runActionPart(sub_action, midiCommand)
            end
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
  local left, right = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
  if not left or not right then
    left, right = start_pos, end_pos
  end

  local start_pos = reaper.GetCursorPosition()
  movement(table.unpack(args))
  local end_pos = reaper.GetCursorPosition()

  if state_interface.getTimelineSelectionSide() == 'right' then
    if end_pos <= left then
      state_interface.setTimelineSelectionSide('left')
      reaper.GetSet_LoopTimeRange(true, false, end_pos, left, false)
    else
      reaper.GetSet_LoopTimeRange(true, false, left, end_pos, false)
    end
  else
    if end_pos >= right then
      state_interface.setTimelineSelectionSide('right')
      reaper.GetSet_LoopTimeRange(true, false, right, end_pos, false)
    else
      reaper.GetSet_LoopTimeRange(true, false, end_pos, right, false)
    end
  end
end

function runner.extendTrackSelection(movement, args)
  movement(table.unpack(args))
  local end_pos = reaper_utils.getTrackPosition()
  local pivot_i = state_interface.getVisualTrackPivotIndex()

  reaper.Main_OnCommand(40297, 0) -- UnselectTracks

  local i = end_pos
  while pivot_i ~= i do
    local track = reaper.GetTrack(0, i)
    reaper.SetTrackSelected(track, true)

    if pivot_i > i then
      i = i + 1
    else
      i = i - 1
    end
  end

  local pivot_track = reaper.GetTrack(0, pivot_i)
  reaper.SetTrackSelected(pivot_track, true)
end

function runner.makeSelectionFromTrackMotion(track_motion, repetitions)
  local first_index = reaper_utils.getTrackPosition()
  runner.runActionNTimes(track_motion, repetitions)
  local end_track = reaper.GetSelectedTrack(0, 0)
  if not end_track then
    -- TODO ?
    local selected_tracks = reaper_utils.getSelectedTracks()
    return
  end

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
