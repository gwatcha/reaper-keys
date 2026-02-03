local log = require 'log'
local log_level = require 'definitions.config'.general.log_level
local reaper_state = require 'reaper_state'
local reaper_utils = require 'movement_utils'
local serpent = require 'serpent'

-- marks.lua is referenced in definitions.actions so we can't require it here
local ScrollToSelectedTracks = 40913
local SetFirstSelectedTrackAsLastTouchedTrack = 40914
local UnselectTracks = 40297

---@class Mark
---@field type "region"|"timeline_position"|"track_selection"
---@field register string
---@field position number
---@field left number
---@field right number
---@field track_position number
---@field track_selection table
---@field deleted? boolean
---@field index? integer

--- @param register string
--- @return Mark?
local function getMark(register)
    local ok, value = reaper.GetProjExtState(0, "marks", register)
    if not ok or not value then return nil end
    local mark
    ok, mark = serpent.load(value)
    if not ok or not mark or mark.deleted then return nil end
    --- @cast mark Mark
    return mark
end

--- @param register string
--- @param mark Mark
local function updateMark(register, mark)
    reaper.SetProjExtState(0, "marks", register, serpent.block(mark, { comment = false }))
end

local function onMarkDelete(mark)
    if not mark or not mark.index then return end
    if mark.type == 'region' then
        reaper.DeleteProjectMarker(0, mark.index, true)
    elseif mark.type == 'timeline_position' then
        reaper.DeleteProjectMarker(0, mark.index, false)
    end
end

local function getSelectedTrackIndices()
    local idxs = {}
    for i = 0, reaper.CountSelectedTracks() - 1 do
        idxs[i + 1] = reaper.GetMediaTrackInfo_Value(
            reaper.GetSelectedTrack(0, i), "IP_TRACKNUMBER") - 1
    end
    return idxs
end

local marks = {}

---@param register string
function marks.save(register)
    onMarkDelete(getMark(register))

    local left, right = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
    --- @type Mark
    local mark = {
        left = left,
        right = right,
        position = reaper.GetCursorPosition(),
        track_position = reaper_utils.getTrackPosition(),
        track_selection = getSelectedTrackIndices(),
        type = "track_selection",
        register = register
    }

    local state = reaper_state.getState()
    local mode = state.mode
    if mode == 'visual_timeline' then
        mark.type = 'region'
        mark.index = reaper.AddProjectMarker(0, true, mark.left, mark.right, register, -1)
    elseif mode == 'visual_track' then
        mark.type = 'track_selection'
    else
        mark.type = 'timeline_position'
        mark.index = reaper.AddProjectMarker(0, false, mark.position, mark.position, register, -1)
    end

    updateMark(register, mark)

    state.mode = "normal"
    reaper_state.setState(state)

    if log_level ~= "trace" then return end
    local all_marks = {}
    for i = 0, 5000 do
        local ok, val
        ok, register, val = reaper.EnumProjExtState(0, "marks", i)
        if not ok then break end
        ok, mark = serpent.load(val)
        if not ok then break end
        all_marks[register] = mark
    end
    log.trace(("new Marks State: %s"):format(serpent.block(all_marks, { comment = false })))
end

---@param register string
function marks.delete(register)
    local mark = getMark(register)
    if not mark then return end
    mark.deleted = true
    onMarkDelete(mark)
    updateMark(register, mark)
end

---@param register string
function marks.recallMarkedTimelinePosition(register)
    local mark = getMark(register)
    if not mark then return end

    local pos = mark.position
    if mark.type == 'region' then pos = mark.left end
    reaper.SetEditCurPos(pos, true, false)
end

local function scrollToPosition(pos)
  local current_position = reaper.GetCursorPosition()
  reaper.SetEditCurPos(pos, true, false)
  reaper.SetEditCurPos(current_position, false, false)
end

---@param register string
function marks.recallMarkedRegion(register)
    local mark = getMark(register)
    if not mark then return end

    reaper.GetSet_LoopTimeRange(true, false, mark.left, mark.right, false)
    scrollToPosition(mark.left)
end

local function setTrackSelection(index)
    reaper.Main_OnCommand(UnselectTracks, 0)
    if not index then return end
    for _, track_index in ipairs(index) do
        local track = reaper.GetTrack(0, track_index)
        if track then reaper.SetTrackSelected(track, true) end
    end
    reaper.Main_OnCommand(ScrollToSelectedTracks, 0)
end

local function setCurrentTrack(index)
  local previously_selected = getSelectedTrackIndices()
  local previous_position = reaper_utils.getTrackPosition()

  local track = reaper.GetTrack(0, index)
  if track then
    reaper.SetOnlyTrackSelected(track)
    reaper.Main_OnCommand(SetFirstSelectedTrackAsLastTouchedTrack, 0)

    local new_selection = previously_selected
    if previous_position and new_selection then
      for i,selected_track_i in ipairs(new_selection) do
        if selected_track_i == previous_position then
          table.remove(new_selection, i)
        end
      end
    end
    table.insert(new_selection, index)
    setTrackSelection(new_selection)
  end
end

---@param register string
function marks.recallMarkedTracks(register)
    local mark = getMark(register)
    if not mark then return end
    setCurrentTrack(mark.track_position)
    setTrackSelection(mark.track_position)
end

return marks
