local state_interface = require 'state_machine.state_interface'
local reaper_utils = require 'movement_utils'
local log = require 'utils.log'
local format = require 'utils.format'
local serpent = require 'serpent'

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
    local ok, value, mark

    local proj, _ = reaper.EnumProjects(-1, "")
    ok, value = reaper.GetProjExtState(proj, "marks", register)
    if not ok or not value then return nil end
    ok, mark = serpent.load(value)
    if not ok or not mark or mark.deleted then return nil end
    --- @cast mark Mark
    return mark
end

--- @param register string
--- @param mark Mark
local function updateMark(register, mark)
    local proj, _ = reaper.EnumProjects(-1, "")
    local serialized = serpent.block(mark, { comment = false })
    reaper.SetProjExtState(proj, "marks", register, serialized)
end

local function onMarkDelete(mark)
    if not mark.index then return end
    if mark.type == 'region' then
        reaper.DeleteProjectMarker(0, mark.index, true)
    elseif mark.type == 'timeline_position' then
        reaper.DeleteProjectMarker(0, mark.index, false)
    end
end

local marks = {}

---@param register string
function marks.save(register)
    local existing_mark = getMark(register)
    if existing_mark then onMarkDelete(existing_mark) end

    local time_left, time_right = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
    --- @type Mark
    local mark = {
        left = time_left,
        right = time_right,
        position = reaper.GetCursorPosition(),
        track_position = reaper_utils.getTrackPosition(),
        track_selection = reaper_utils.getSelectedTrackIndices(),
        type = "track_selection",
        register = register
    }

    local mode = state_interface.getMode()
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

    state_interface.setMode('normal')
    local all_marks = {}
    for i = 0, 5000 do
        local ok, val
        ok, register, val = reaper.EnumProjExtState(0, "marks", i)
        if not ok then break end
        ok, mark = serpent.load(val)
        if not ok then break end
        all_marks[register] = mark
    end
    log.trace(("New Marks State: %s"):format(format.block(all_marks)))
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

---@param register string
function marks.recallMarkedRegion(register)
    local mark = getMark(register)
    if not mark then return end

    reaper.GetSet_LoopTimeRange(true, false, mark.left, mark.right, false)
    reaper_utils.scrollToPosition(mark.left)
end

---@param register string
function marks.recallMarkedTracks(register)
    local mark = getMark(register)
    if not mark then return end

    reaper_utils.setCurrentTrack(mark.track_position)
    reaper_utils.setTrackSelection(mark.track_selection)
end

return marks
