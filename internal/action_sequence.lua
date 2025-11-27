local actions = require 'definitions.actions'
local clearTimeSelection = require 'movements'.clearTimeSelection
local config = require 'definitions.config'.general
local persist_visual_timeline_selection = require 'definitions.config'.general.persist_visual_timeline_selection
local runner = require 'command.runner'
local state_interface = require 'state_machine.state_interface'

---@param timeline_operator Action
---@param timeline_selector Action
local function timelineOperatorTimelineSelector(timeline_operator, timeline_selector)
    local start_sel, end_sel = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
    runner.runAction(timeline_selector)
    runner.runAction(timeline_operator)

    if type(timeline_operator) ~= 'table' or not timeline_operator.setTimeSelection then
        reaper.GetSet_LoopTimeRange(true, false, start_sel, end_sel, false)
    end
end

---@param timeline_operator Action
---@param timeline_motion Action
local function timelineOperatorTimelineMotion(timeline_operator, timeline_motion)
    local start_sel, end_sel = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
    runner.makeSelectionFromTimelineMotion(timeline_motion, 1)
    runner.runAction(timeline_operator)
    if type(timeline_operator) ~= 'table' or not timeline_operator.setTimeSelection then
        reaper.GetSet_LoopTimeRange(true, false, start_sel, end_sel, false)
    end
end

---@param timeline_operator Action
local function visualTimelineTimelineOperator(timeline_operator)
    runner.runAction(timeline_operator)
    state_interface.setModeToNormal()
    if not persist_visual_timeline_selection then clearTimeSelection() end
end

---@param timeline_motion Action
local function visualTimelineTimelineMotion(timeline_motion)
    runner.extendTimelineSelection(runner.runAction, { timeline_motion })
end

---@param track_operator Action
---@param track_motion Action
local function trackOperatorTrackMotion(track_operator, track_motion)
    runner.runInternalActionByName(actions.SaveTrackSelection)
    runner.makeSelectionFromTrackMotion(track_motion, 1)
    runner.runAction(track_operator)
    if type(track_operator) ~= 'table' or not track_operator.setTrackSelection then
        runner.runInternalActionByName(actions.RestoreTrackSelection)
    end
end

local function trackOperatorTrackSelector(track_operator, track_selector)
    runner.runInternalActionByName(actions.SaveTrackSelection)
    runner.runAction(track_selector)
    runner.runAction(track_operator)
    if type(track_operator) ~= 'table' or not track_operator.setTrackSelection then
        runner.runInternalActionByName(actions.RestoreTrackSelection)
    end
end

---@param track_operator Action
local function visualTrackTrackOperator(track_operator)
    runner.runAction(track_operator)
    state_interface.setModeToNormal()
    if not config.persist_visual_track_selection and (type(track_operator) ~= 'table' or not track_operator.setTrackSelection) then
        local track = reaper.GetLastTouchedTrack()
        if track then reaper.SetOnlyTrackSelected(track) end
    end
end

---@param track_motion Action
local function visualTrackTrackMotion(track_motion)
    runner.extendTrackSelection(runner.makeSelectionFromTrackMotion, { track_motion, 1 })
end

---@param timeline_motion Action
local function visualTrackTimelineMotion(timeline_motion)
    if not config.allow_timeline_movement_in_visual_mode then return end
    runner.runAction(timeline_motion)
end

---@alias VisualType "visual_timeline_command" | "visual_track_command"
---@alias TimelineType "timeline_motion" | "timeline_operator" | "timeline_selector"
---@alias TrackType "track_motion" | "track_operator" | "track_selector"
---@alias ActionType "command" | TimelineType | TrackType | VisualType
---@type ActionType[]
local action_types = {
    "command",
    "timeline_motion",
    "timeline_operator",
    "timeline_selector",
    "track_motion",
    "track_operator",
    "track_selector",
    "visual_timeline_command",
    "visual_track_command"
}

local action_sequences = {}
function action_sequences.getActionTypes() return action_types end

---@alias ActionSequence ActionType[]
---@alias ActionSequenceWithFn { [1]:ActionSequence, [2]:fun(action: Action) }
---@alias ActionModes table<Mode, ActionSequenceWithFn[]>
---@type ActionModes
local pairs_global_midi = {
    normal = {
        { { 'timeline_operator', 'timeline_selector' }, timelineOperatorTimelineSelector },
        { { 'timeline_operator', 'timeline_motion' },   timelineOperatorTimelineMotion },
        { { 'timeline_motion' },                        runner.runAction },
        { { 'command' },                                runner.runAction },
    },
    visual_track = { { { 'command' }, runner.runAction } },
    visual_timeline = {
        { { 'visual_timeline_command' }, runner.runAction },
        { { 'timeline_operator' },       visualTimelineTimelineOperator },
        { { 'timeline_selector' },       runner.runAction },
        { { 'timeline_motion' },         visualTimelineTimelineMotion },
        { { 'command' },                 runner.runAction },
    }
}

---@type ActionModes
local pairs_main = {
    normal = {
        { { 'track_operator', 'track_motion' },         trackOperatorTrackMotion },
        { { 'track_operator', 'track_selector' },       trackOperatorTrackSelector },
        { { 'timeline_operator', 'timeline_selector' }, timelineOperatorTimelineSelector },
        { { 'timeline_operator', 'timeline_motion' },   timelineOperatorTimelineMotion },
        { { 'timeline_motion' },                        runner.runAction },
        { { 'track_motion' },                           runner.runAction },
        { { 'command' },                                runner.runAction },
    },
    visual_track = {
        { { 'visual_track_command' }, runner.runAction },
        { { 'track_operator' },       visualTrackTrackOperator },
        { { 'track_selector' },       runner.runAction },
        { { 'track_motion' },         visualTrackTrackMotion },
        { { 'timeline_motion' },      visualTrackTimelineMotion },
        { { 'command' },              runner.runAction },
    },
    visual_timeline = {
        { { 'visual_timeline_command' }, runner.runAction },
        { { 'timeline_operator' },       visualTimelineTimelineOperator },
        { { 'timeline_selector' },       runner.runAction },
        { { 'timeline_motion' },         visualTimelineTimelineMotion },
        { { 'track_motion' },            runner.runAction },
        { { 'command' },                 runner.runAction },
    }
}

---@alias ActionTypePairs table<Context, ActionModes>
---@type ActionTypePairs
local action_sequences_pairs = {
    global = pairs_global_midi,
    midi = pairs_global_midi,
    main = pairs_main,
}

---@param state State
---@return ActionSequence[]
function action_sequences.getPossibleActionSequences(state)
    local pairs = action_sequences_pairs[state.context][state.mode]
    local sequences = {}
    for _, pair in ipairs(pairs) do
        table.insert(sequences, pair[1])
    end
    return sequences
end

---@param seq1 ActionSequence
---@param seq2 ActionSequence
---@return boolean
local function checkIfActionSequencesAreEqual(seq1, seq2)
    return seq1[1] == seq2[1] and seq1[2] == seq2[2]
end

---@param command Command
---@return fun(action: Action)?
function action_sequences.getFunctionForCommand(command)
    local pairs = action_sequences_pairs[command.context][command.mode]
    for _, pair in ipairs(pairs) do
        if checkIfActionSequencesAreEqual(command.action_sequence, pair[1]) then
            return pair[2]
        end
    end
    return nil
end

return action_sequences
