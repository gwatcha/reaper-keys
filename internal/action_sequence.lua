local actions = require 'definitions.actions'
local movements = require 'movements'
local config = require 'definitions.config'.general
local log = require 'log'
local persist_visual_timeline_selection = require 'definitions.config'.general.persist_visual_timeline_selection
local reaper_utils = require "movement_utils"
local reaper_state = require "reaper_state"

local action_sequences = {}

---@param id ActionPart
local function runPart(id, midi_command)
    if type(id) == "function" then return id() end

    local numeric_id = id
    if type(id) == 'string' then
        local action = actions[id]
        if action then return action_sequences.run(action) end

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
---exposed for binding list
function action_sequences.run(action)
    if type(action) ~= 'table' then
        return runPart(action --[[@as ActionPart]], false)
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

        return fn(register)
    end

    local prefixedRepetitions = action.prefixedRepetitions or 1
    if action.toTrack then
        movements.toTrack(prefixedRepetitions)
        reaper.Main_OnCommand(actions.ScrollToSelectedTracks, 0)
        return
    end

    local midiCommand = action.midiCommand or false
    for _ = 1, (action.repetitions or 1) * prefixedRepetitions do
        for _, sub_action in ipairs(action) do
            if type(sub_action) == 'table' then
                action_sequences.run(sub_action)
            else
                runPart(sub_action, midiCommand)
            end
        end
    end
end

---@param timeline_operator Action
---@param timeline_selector Action
local function timelineOperatorTimelineSelector(timeline_operator, timeline_selector)
    local start_sel, end_sel = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
    action_sequences.run(timeline_selector)
    action_sequences.run(timeline_operator)

    if type(timeline_operator) ~= 'table' or not timeline_operator.setTimeSelection then
        reaper.GetSet_LoopTimeRange(true, false, start_sel, end_sel, false)
    end
end

---@param timeline_operator Action
---@param timeline_motion Action
local function timelineOperatorTimelineMotion(timeline_operator, timeline_motion)
    local start_sel, end_sel = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)

    -- make selection from timeline motion
    local sel_start = reaper.GetCursorPosition()
    action_sequences.run(timeline_motion)
    local sel_end = reaper.GetCursorPosition()
    reaper.SetEditCurPos(sel_start, false, false)
    reaper.GetSet_LoopTimeRange(true, false, sel_start, sel_end, false)

    action_sequences.run(timeline_operator)
    if type(timeline_operator) ~= 'table' or not timeline_operator.setTimeSelection then
        reaper.GetSet_LoopTimeRange(true, false, start_sel, end_sel, false)
    end
end

local function setModeToNormal()
    local state = reaper_state.getState()
    state.key_sequence = ""
    state.context = "main"
    state.mode = "normal"
    state.timeline_selection_side = "left"
    reaper_state.setState(state)
end

---@param timeline_operator Action
local function visualTimelineTimelineOperator(timeline_operator)
    action_sequences.run(timeline_operator)
    setModeToNormal()
    if not persist_visual_timeline_selection then movements.clearTimeSelection() end
end

---@param timeline_motion Action
local function visualTimelineTimelineMotion(timeline_motion)
    -- extend timeline selection
    local left, right = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
    left = left or 0
    right = right or reaper.GetProjectLength()

    action_sequences.run(timeline_motion)
    local pos = reaper.GetCursorPosition()

    local state = reaper_state.getState()

    if state.timeline_selection_side == 'right' then
        if pos <= left then
            state.timeline_selection_side = "left"
            reaper.GetSet_LoopTimeRange(true, false, pos, left, false)
        else
            reaper.GetSet_LoopTimeRange(true, false, left, pos, false)
        end
    else
        if pos >= right then
            state.timeline_selection_side = "right"
            reaper.GetSet_LoopTimeRange(true, false, right, pos, false)
        else
            reaper.GetSet_LoopTimeRange(true, false, pos, right, false)
        end
    end

    reaper_state.setState(state)
end

local function makeSelectionFromTrackMotion(track_motion)
    local first_index = reaper_utils.getTrackPosition()

    action_sequences.run(track_motion)

    local end_track = reaper.GetSelectedTrack(0, 0)
    if not end_track then return end
    local second_index = reaper.GetMediaTrackInfo_Value(end_track, "IP_TRACKNUMBER") - 1

    if first_index > second_index then
        first_index, second_index = second_index, first_index
    end

    for i = first_index, second_index do
        reaper.SetTrackSelected(reaper.GetTrack(0, i), true)
    end
end

---Run action not present in internal/definitions/actions.lua
---@param name string
local function runByName(name)
    reaper.Main_OnCommand(reaper.NamedCommandLookup(name), 0)
end

---@param track_operator Action
---@param track_motion Action
local function trackOperatorTrackMotion(track_operator, track_motion)
    runByName(actions.SaveTrackSelection)

    makeSelectionFromTrackMotion(track_motion)
    action_sequences.run(track_operator)

    if type(track_operator) ~= 'table' or not track_operator.setTrackSelection then
        runByName(actions.RestoreTrackSelection)
    end
end

local function trackOperatorTrackSelector(track_operator, track_selector)
    runByName(actions.SaveTrackSelection)
    action_sequences.run(track_selector)
    action_sequences.run(track_operator)
    if type(track_operator) ~= 'table' or not track_operator.setTrackSelection then
        runByName(actions.RestoreTrackSelection)
    end
end

---@param track_operator Action
local function visualTrackTrackOperator(track_operator)
    action_sequences.run(track_operator)
    setModeToNormal()
    if not config.persist_visual_track_selection and
        (type(track_operator) ~= 'table' or not track_operator.setTrackSelection) then
        local track = reaper.GetLastTouchedTrack()
        if track then reaper.SetOnlyTrackSelected(track) end
    end
end

---@param track_motion Action
local function visualTrackTrackMotion(track_motion)
    -- extend track selection
    makeSelectionFromTrackMotion(track_motion)
    local end_pos = reaper_utils.getTrackPosition()
    local pivot_i = reaper_state.getState().visual_track_pivot_i

    reaper.Main_OnCommand(actions.UnselectTracks, 0)

    local i = end_pos
    while pivot_i ~= i do
        reaper.SetTrackSelected(reaper.GetTrack(0, i), true)
        if pivot_i > i then
            i = i + 1
        else
            i = i - 1
        end
    end

    reaper.SetTrackSelected(reaper.GetTrack(0, pivot_i), true)
end

---@param timeline_motion Action
local function visualTrackTimelineMotion(timeline_motion)
    if not config.allow_timeline_movement_in_visual_mode then return end
    action_sequences.run(timeline_motion)
end

---@alias ActionSequence ActionType[]
---@alias ActionSequenceWithFn { [1]:ActionSequence, [2]:fun(action: Action) }
---@alias ActionModes table<Mode, ActionSequenceWithFn[]>
---@type ActionModes
local pairs_global_midi = {
    normal = {
        { { 'timeline_operator', 'timeline_selector' }, timelineOperatorTimelineSelector },
        { { 'timeline_operator', 'timeline_motion' },   timelineOperatorTimelineMotion },
        { { 'timeline_motion' },                        action_sequences.run },
        { { 'command' },                                action_sequences.run },
    },
    visual_track = { { { 'command' }, action_sequences.run } },
    visual_timeline = {
        { { 'visual_timeline_command' }, action_sequences.run },
        { { 'timeline_operator' },       visualTimelineTimelineOperator },
        { { 'timeline_selector' },       action_sequences.run },
        { { 'timeline_motion' },         visualTimelineTimelineMotion },
        { { 'command' },                 action_sequences.run },
    }
}

---@type ActionModes
local pairs_main = {
    normal = {
        { { 'track_operator', 'track_motion' },         trackOperatorTrackMotion },
        { { 'track_operator', 'track_selector' },       trackOperatorTrackSelector },
        { { 'timeline_operator', 'timeline_selector' }, timelineOperatorTimelineSelector },
        { { 'timeline_operator', 'timeline_motion' },   timelineOperatorTimelineMotion },
        { { 'timeline_motion' },                        action_sequences.run },
        { { 'track_motion' },                           action_sequences.run },
        { { 'command' },                                action_sequences.run },
    },
    visual_track = {
        { { 'visual_track_command' }, action_sequences.run },
        { { 'track_operator' },       visualTrackTrackOperator },
        { { 'track_selector' },       action_sequences.run },
        { { 'track_motion' },         visualTrackTrackMotion },
        { { 'timeline_motion' },      visualTrackTimelineMotion },
        { { 'command' },              action_sequences.run },
    },
    visual_timeline = {
        { { 'visual_timeline_command' }, action_sequences.run },
        { { 'timeline_operator' },       visualTimelineTimelineOperator },
        { { 'timeline_selector' },       action_sequences.run },
        { { 'timeline_motion' },         visualTimelineTimelineMotion },
        { { 'track_motion' },            action_sequences.run },
        { { 'command' },                 action_sequences.run },
    }
}

---@alias ActionTypePairs table<Context, ActionModes>
---@type ActionTypePairs
local action_sequences_pairs = {
    global = pairs_global_midi,
    midi = pairs_global_midi,
    main = pairs_main,
}

---@param context Context
---@param mode Mode
---@return ActionType[][]
local function keys(context, mode)
    local pairs = action_sequences_pairs[context][mode]
    local sequences = {}
    for _, pair in ipairs(pairs) do table.insert(sequences, pair[1]) end
    return sequences
end

---@type table<Context, table<Mode, ActionType[][]>>
local action_sequence_keys = {
    global = {
        normal = keys("global", "normal"),
        visual_timeline = keys("global", "visual_timeline"),
        visual_track = keys("global", "visual_track"),
    },
    midi = {
        normal = keys("midi", "normal"),
        visual_timeline = keys("midi", "visual_timeline"),
        visual_track = keys("midi", "visual_track"),
    },
    main = {
        normal = keys("main", "normal"),
        visual_timeline = keys("main", "visual_timeline"),
        visual_track = keys("main", "visual_track"),
    }
}

---@alias VisualType "visual_timeline_command" | "visual_track_command"
---@alias TimelineType "timeline_motion" | "timeline_operator" | "timeline_selector"
---@alias TrackType "track_motion" | "track_operator" | "track_selector"
---@alias ActionType "command" | TimelineType | TrackType | VisualType
return {
    ---@type ActionType[]
    action_types = {
        "command",
        "timeline_motion",
        "timeline_operator",
        "timeline_selector",
        "track_motion",
        "track_operator",
        "track_selector",
        "visual_timeline_command",
        "visual_track_command"
    },
    action_sequence_keys = action_sequence_keys,
    action_sequences_pairs = action_sequences_pairs,
    run = action_sequences.run
}
