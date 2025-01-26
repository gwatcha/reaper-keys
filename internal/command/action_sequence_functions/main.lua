local runner = require('command.runner')
local state_interface = require('state_machine.state_interface')
local config = require 'definitions.config'.general

local function normalTrackMotion(track_operator, track_motion)
    runner.runAction("SaveTrackSelection")
    runner.makeSelectionFromTrackMotion(track_motion, 1)
    runner.runAction(track_operator)
    if type(track_operator) ~= 'table' or not track_operator['setTrackSelection'] then
        runner.runAction("RestoreTrackSelection")
    end
end

local function normalTrackSelector(track_operator, track_selector)
    runner.runAction("SaveTrackSelection")
    runner.runAction(track_selector)
    runner.runAction(track_operator)
    if type(track_operator) ~= 'table' or not track_operator['setTrackSelection'] then
        runner.runAction("RestoreTrackSelection")
    end
end

local function visualTrackTrackOperator(track_operator)
    runner.runAction(track_operator)
    state_interface.setModeToNormal()
    if not config.persist_visual_track_selection and (type(track_operator) ~= 'table' or not track_operator['setTrackSelection']) then
        local track = reaper.GetLastTouchedTrack()
        if track then reaper.SetOnlyTrackSelected(track) end
    end
end

local function visualTrackTrackMotion(track_motion)
    local args = { track_motion, 1 }
    local sel_function = runner.makeSelectionFromTrackMotion
    runner.extendTrackSelection(sel_function, args)
end

local function visualTrackTimelineMotion(timeline_motion)
    if config.allow_timeline_movement_in_visual_mode then
        runner.runAction(timeline_motion)
    end
end

---@type ActionModes
return {
    all_modes = { { { 'track_motion' }, runner.runAction } },
    normal = {
        { { 'track_operator', 'track_motion' },   normalTrackMotion },
        { { 'track_operator', 'track_selector' }, normalTrackSelector },
    },
    visual_track = {
        { { 'visual_track_command' }, runner.runAction },
        { { 'track_operator' },       visualTrackTrackOperator },
        { { 'track_selector' },       runner.runAction },
        { { 'track_motion' },         visualTrackTrackMotion },
        { { 'timeline_motion' },      visualTrackTimelineMotion },
    }
}
