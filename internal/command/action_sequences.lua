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

    if type(timeline_operator) ~= 'table' or not timeline_operator['setTimeSelection'] then
        reaper.GetSet_LoopTimeRange(true, false, start_sel, end_sel, false)
    end
end

---@param timeline_operator Action
---@param timeline_motion Action
local function timelineOperatorTimelineMotion(timeline_operator, timeline_motion)
    local start_sel, end_sel = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
    runner.makeSelectionFromTimelineMotion(timeline_motion, 1)
    runner.runAction(timeline_operator)
    if type(timeline_operator) ~= 'table' or not timeline_operator['setTimeSelection'] then
        reaper.GetSet_LoopTimeRange(true, false, start_sel, end_sel, false)
    end
end

---@param action Action
local function visualTimelinetimelineOperator(action)
    runner.runAction(action)
    state_interface.setModeToNormal()
    if not persist_visual_timeline_selection then clearTimeSelection() end
end

---@param action Action
local function visualTimelineTimelineMotion(action)
    runner.extendTimelineSelection(runner.runAction, { action })
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
    if type(track_operator) ~= 'table' or not track_operator['setTrackSelection'] then
        runner.runInternalActionByName(actions.RestoreTrackSelection)
    end
end

local function visualTrackTrackOperator(track_operator)
    runner.runAction(track_operator)
    state_interface.setModeToNormal()
    if not config.persist_visual_track_selection and (type(track_operator) ~= 'table' or not track_operator.setTrackSelection) then
        local track = reaper.GetLastTouchedTrack()
        if track then reaper.SetOnlyTrackSelected(track) end
    end
end

local function visualTrackTrackMotion(track_motion)
    runner.extendTrackSelection(runner.makeSelectionFromTrackMotion, { track_motion, 1 })
end

local function visualTrackTimelineMotion(timeline_motion)
    if not config.allow_timeline_movement_in_visual_mode then return end
    runner.runAction(timeline_motion)
end

---@type {global: ActionModes, main: ActionModes, midi: ActionModes}
local definitions = {
    global = {
        all_modes = { { { 'command' }, runner.runAction }, },
        normal = {
            { { 'timeline_operator', 'timeline_selector' }, timelineOperatorTimelineSelector },
            { { 'timeline_operator', 'timeline_motion' },   timelineOperatorTimelineMotion },
            { { 'timeline_motion' },                        runner.runAction },
        },
        visual_timeline = {
            { { 'visual_timeline_command' }, runner.runAction },
            { { 'timeline_operator' },       visualTimelinetimelineOperator },
            { { 'timeline_selector' },       runner.runAction },
            { { 'timeline_motion' },         visualTimelineTimelineMotion },
        }
    },
    main = {
        all_modes = { { { 'track_motion' }, runner.runAction } },
        normal = {
            { { 'track_operator', 'track_motion' },   trackOperatorTrackMotion },
            { { 'track_operator', 'track_selector' }, trackOperatorTrackSelector },
        },
        visual_track = {
            { { 'visual_track_command' }, runner.runAction },
            { { 'track_operator' },       visualTrackTrackOperator },
            { { 'track_selector' },       runner.runAction },
            { { 'track_motion' },         visualTrackTrackMotion },
            { { 'timeline_motion' },      visualTrackTimelineMotion },
        }
    },
    midi = {}
}

local function concatTables(...)
    local t = {}
    for n = 1, select("#", ...) do
        local arg = select(n, ...)
        if type(arg) == "table" then
            for _, v in ipairs(arg) do
                t[#t + 1] = v
            end
        else
            t[#t + 1] = arg
        end
    end
    return t
end

local pairs_global_midi = {
    normal = concatTables(definitions.global.normal, definitions.global.all_modes),
    visual_track = concatTables(definitions.global.all_modes),
    visual_timeline = concatTables(definitions.global.visual_timeline, definitions.global.all_modes),
}

---Unrolling of following function:
---For each context in Context, for each mode in Mode result is
--- concatTables(
---  definitions[context][mode],
---  definitions.global[mode],
---  definitions[context].all_modes,
---  definitions.global.all_modes)
local action_sequences_pairs = {
    global = pairs_global_midi,
    midi = pairs_global_midi,
    main = {
        normal = concatTables(
            definitions.main.normal,
            definitions.global.normal,
            definitions.main.all_modes,
            definitions.global.all_modes),
        visual_track = concatTables(definitions.main.all_modes, definitions.global.all_modes),
        visual_timeline = concatTables(
            definitions.main.visual_timeline,
            definitions.global.visual_timeline,
            definitions.main.all_modes,
            definitions.global.all_modes),
    },
}

---@param context Context
---@aram mode Mode
---@return ActionSequence[]
local function getPossibleActionSequenceFunctionPairs(context, mode)
    return concatTables(
        definitions[context][mode],
        definitions.global[mode],
        definitions[context].all_modes,
        definitions.global.all_modes
    )
end

local action_sequences = {}

---@param state State
---@return string[][]
function action_sequences.getPossibleActionSequences(state)
    local context, mode = state.context, state.mode
    local pairs = getPossibleActionSequenceFunctionPairs(context, mode)

    local sequences = {}
    for _, pair in ipairs(pairs) do
        table.insert(sequences, pair[1])
    end
    return sequences
end

local function checkIfActionSequencesAreEqual(seq1, seq2)
    if #seq1 ~= #seq2 then return false end
    for i = 1, #seq1 do
        if seq1[i] ~= seq2[i] then
            return false
        end
    end

    return true
end

---@param command Command
---@return fun(action: Action)?
function action_sequences.getFunctionForCommand(command)
    local action_sequence_function_pairs = getPossibleActionSequenceFunctionPairs(command.context, command.mode)

    for _, action_sequence_function_pair in ipairs(action_sequence_function_pairs) do
        local action_sequence = action_sequence_function_pair[1]
        if checkIfActionSequencesAreEqual(command.action_sequence, action_sequence) then
            return action_sequence_function_pair[2]
        end
    end

    return nil
end

function action_sequences.getActionTypes()
    local action_types = {}
    local seen_types = {}
    for _, context_definitions in pairs(definitions) do
        for _, mode_definitions in pairs(context_definitions) do
            for _, action_sequence_function_pair in pairs(mode_definitions) do
                local action_sequence = action_sequence_function_pair[1]
                for _, action_type in pairs(action_sequence) do
                    if not seen_types[action_type] then
                        seen_types[action_type] = true
                        table.insert(action_types, action_type)
                    end
                end
            end
        end
    end

    table.sort(action_types)
    return action_types
end

return action_sequences
