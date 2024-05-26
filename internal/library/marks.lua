local project_state = require('utils.project_state')
local state_interface = require('state_machine.state_interface')
local reaper_utils = require('custom_actions.utils')
local log = require('utils.log')
local format = require('utils.format')

local marks = {}

---@param mark Mark
local function deleteMarkIndications(mark)
  if not mark.index then return end
  if mark.type == 'region' then
    reaper.DeleteProjectMarker(0, mark.index, true)
  elseif mark.type == 'timeline_position' then
    reaper.DeleteProjectMarker(0, mark.index, false)
  end
end

---@param mark Mark
---@param register string
local function overwriteMark(mark, register)
  local mode = state_interface.getMode()
  if mode == 'visual_timeline' then
    mark['type'] = 'region'
    mark['index'] = reaper.AddProjectMarker(0, true, mark.left, mark.right, register, -1)
  elseif mode == 'visual_track' then
    mark['type'] = 'track_selection'
  else
    mark['type'] = 'timeline_position'
    mark['index'] = reaper.AddProjectMarker(0, false, mark.position, mark.position, register, -1)
  end

  mark['register'] = register
  mark['time'] = os.time()

  local ok, old_mark = project_state.get('marks', register)
  if ok and old_mark then
    deleteMarkIndications(old_mark)
  end

  project_state.overwrite('marks', register, mark)
  state_interface.setMode('normal')

  local _, all_project_marks = project_state.getAll('marks')
  log.trace("New Marks State: " .. format.block(all_project_marks))
end

---@param register string
function marks.save(register)
  local time_left, time_right = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)

  local mark = {
    left = time_left,
    right = time_right,
    position = reaper.GetCursorPosition(),
    track_position = reaper_utils.getTrackPosition(),
    track_selection = reaper_utils.getSelectedTrackIndices(),
  }

  overwriteMark(mark, register)
end

---@param register string
function marks.delete(register)
  local ok, old_mark = project_state.get('marks', register)
  if ok and old_mark then
    deleteMarkIndications(old_mark)
  end

  project_state.delete('marks', register)
end

---@param register string
function marks.recallMarkedTimelinePosition(register)
  local ok, mark = project_state.get('marks', register)
  if not ok or not mark then
    return
  end

  local target_pos = mark.position
  if mark.type == 'region' then
    target_pos = mark.left
  end

  reaper.SetEditCurPos(target_pos, true, false)
end

---@param register string
function marks.recallMarkedRegion(register)
  local ok, mark = project_state.get('marks', register)
  if not ok or not mark then
    return
  end

  reaper.GetSet_LoopTimeRange(true, false, mark.left, mark.right, false)
  reaper_utils.scrollToPosition(mark.left)
end

---@param register string
function marks.recallMarkedTracks(register)
  local ok, mark = project_state.get('marks', register)
  if not ok or not mark then
    return
  end

  reaper_utils.setCurrentTrack(mark.track_position)
  reaper_utils.setTrackSelection(mark.track_selection)
end

return marks
