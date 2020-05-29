local saved = require('saved')
local state_interface = require('state_machine.state_interface')
local reaper_utils = require('custom_actions.utils')
local log = require('utils.log')
local format = require('utils.format')

local marks = {}

function overwriteMark(mark, register)
  local old_mark = saved.get('marks', register)
  if old_mark and old_mark.type ~= 'track_selection' then
    reaper.DeleteProjectMarkerByIndex(0, old_mark.index)
  end

  if mark.type == 'region' then
    if not mark.left or not mark.right then
      return
    end
    mark.index = reaper.AddProjectMarker(0, true, mark.left, mark.right, register, 0)
  elseif mark.type == 'cursor_position' then
    mark.index = reaper.AddProjectMarker(0, false, mark.position, mark.position, register, 0)
  end

  saved.overwrite('marks', register, mark)
end

function marks.save(register)
  local mark = {}

  local current_position = reaper.GetCursorPosition()
  local mode = state_interface.getMode()
  local track_position = reaper_utils.getTrackPosition()

  if mode == 'visual_timeline' then
    mark.type = 'region'
    mark.left, mark.right = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
    mark.position = mark.left
    state_interface.setMode('normal')
    reaper_utils.unselectAllButLastTouchedTrack()
  elseif mode == 'visual_track' then
    mark.type = 'track_selection'
    mark.position = current_position
    mark.track_position = track_position
    mark.track_selection = reaper_utils.getSelectedTrackIndices()
    state_interface.setMode('normal')
    reaper_utils.unselectAllButLastTouchedTrack()
  else
    mark.type = 'cursor_position'
    mark.position = current_position
    mark.track_position = track_position
  end

  overwriteMark(mark, register)
end

function marks.moveTo(register)
  local mark = saved.get('marks', register)
  if not mark then
    return
  end

  if mark.type == 'track_selection' then
    reaper_utils.setCurrentTrack(mark.track_position)
  else
    reaper.SetEditCurPos(mark.position, true, false)
  end
end

function marks.recall(register)
  local mark = saved.get('marks', register)
  if not mark then
    return
  end

  if mark.type == 'region' then
    reaper.GetSet_LoopTimeRange(true, false, mark.left, mark.right, false)
    reaper_utils.scrollToPosition(mark.left)
    reaper.SetProjectMarker(mark.index, true, mark.left, mark.right, register)
  else
    reaper_utils.setCurrentTrack(mark.track_position)
    if mark.type == 'track_selection' then
      reaper_utils.setTrackSelection(mark.track_selection)
    else
      reaper.SetEditCurPos(mark.position, true, false)
      local track = reaper.GetTrack(0, mark.track_position)
      if track then
        reaper.SetOnlyTrackSelected(track)
      end
    end
  end
end

function marks.delete(register)
  local old_mark = saved.get('marks', register)
  if old_mark and old_mark.type ~= 'track_selection' then
    reaper.DeleteProjectMarkerByIndex(0, old_mark.index)
  end

  saved.clear('marks', register)
end

return marks
