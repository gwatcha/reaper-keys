local feedback = require 'gui.feedback.controller'
local reaper_state = require 'utils.reaper_state'
local utils = require "movement_utils"

local actions = {}

function actions.projectStart() reaper.SetEditCurPos(0, true, false) end

function actions.projectEnd() reaper.SetEditCurPos(reaper.GetProjectLength(0), true, false) end

function actions.firstItemStart()
    local len = reaper.GetProjectLength(0)
    local start = len
    for i = 0, reaper.CountSelectedTracks() - 1 do
        local item = reaper.GetTrackMediaItem(reaper.GetSelectedTrack(0, i), 0)
        if not item then goto next_track end
        local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        if pos < start then start = pos end
        ::next_track::
    end
    if start < len then reaper.SetEditCurPos(start, true, false) end
end

function actions.lastItemEnd()
    local last_end = 0
    for i = 0, reaper.CountSelectedTracks() - 1 do
        local track = reaper.GetSelectedTrack(0, i)
        local items = reaper.GetTrackNumMediaItems(track)
        if items == 0 then goto next_track end
        local item = reaper.GetTrackMediaItem(track, items - 1)
        local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
            + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
        if pos > last_end then last_end = pos end
        ::next_track::
    end
    if last_end > 0 then reaper.SetEditCurPos(last_end, true, false) end
end

function actions.prevItemStart()
    local cur = reaper.GetCursorPosition()
    local start = -1
    for i = 0, reaper.CountSelectedTracks() - 1 do
        local track = reaper.GetSelectedTrack(0, i)
        for j = 0, reaper.GetTrackNumMediaItems(track) - 1 do
            local item = reaper.GetTrackMediaItem(track, j)
            local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
            local len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
            if cur > pos and cur <= len then return reaper.SetEditCurPos(pos, true, false) end
            if cur <= pos then goto next_track end
            if pos > start then start = pos end
        end
        ::next_track::
    end
    if start > -1 then reaper.SetEditCurPos(start, true, false) end
end

---@param to_end integer
local function nextItem(to_end)
    local cur = reaper.GetCursorPosition()
    local proj_end = reaper.GetProjectLength(0)
    local next_pos = proj_end + 1
    for i = 0, reaper.CountSelectedTracks() - 1 do
        local track = reaper.GetSelectedTrack(0, i)
        for j = 0, reaper.GetTrackNumMediaItems(track) - 1 do
            local item = reaper.GetTrackMediaItem(track, j)
            local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
            local len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
            if to_end == 1 and cur >= pos and cur < len then return reaper.SetEditCurPos(pos + len, true, false) end
            pos = pos + to_end * len
            if cur < pos and pos < next_pos then next_pos = pos end
        end
    end
    if next_pos < proj_end + 1 then reaper.SetEditCurPos(next_pos, true, false) end
end

function actions.nextItemStart() nextItem(0) end

function actions.nextItemEnd() nextItem(1) end

function actions.prevBigItemStart()
    local item_positions = utils.getBigItemPositionsOnSelectedTracks()
    local pos = reaper.GetCursorPosition()
    local next_position = nil
    for i, item in pairs(item_positions) do
        if not next_position and item.left < pos and item.right >= pos then
            next_position = item.left
        end

        if next_position and item.left > next_position and item.right >= next_position then
            next_position = item.left
        end

        local next_item = item_positions[i + 1]
        if not next_item or next_item.left >= pos then
            next_position = item.left
            break
        end
    end

    if next_position then reaper.SetEditCurPos(next_position, true, false) end
end

function actions.nextBigItemStart()
    local item_positions = utils.getBigItemPositionsOnSelectedTracks()
    local pos = reaper.GetCursorPosition()
    local next_position = nil
    for _, item_position in pairs(item_positions) do
        if not next_position and pos < item_position.left then
            next_position = item_position.left
        end
        if next_position and item_position.left < next_position then
            next_position = item_position.left
        end
    end
    if next_position then reaper.SetEditCurPos(next_position, true, false) end
end

function actions.nextBigItemEnd()
    local item_positions = utils.getBigItemPositionsOnSelectedTracks()
    local current_position = reaper.GetCursorPosition()
    local next_position = nil
    local tolerance = .002
    for _, item_position in pairs(item_positions) do
        if not next_position and item_position.right - tolerance > current_position then
            next_position = item_position.right
        elseif next_position and item_position.right < next_position and item_position.right > current_position then
            next_position = item_position.right
        end
    end
    if next_position then
        reaper.SetEditCurPos(next_position, true, false)
    end
end

function actions.firstTrack()
    local track = reaper.GetTrack(0, 0)
    if track then reaper.SetOnlyTrackSelected(track) end
end

function actions.lastTrack()
    local num = reaper.GetNumTracks()
    if num ~= 0 then reaper.SetOnlyTrackSelected(reaper.GetTrack(0, num - 1)) end
end

function actions.toTrack(num)
    if num == 0 then return end
    local track = reaper.GetTrack(0, num - 1)
    if track then reaper.SetOnlyTrackSelected(track) end
end

function actions.trackWithNumber()
    local ok, str = reaper.GetUserInputs("Match Forward", 1, "Track Number", "")
    if not ok then return end
    local num = tonumber(str)
    if num < 1 then return end
    local track = reaper.GetTrack(0, num - 1)
    if track then reaper.SetOnlyTrackSelected(track) end
end

function actions.firstTrackWithItem()
    for i = 0, reaper.GetNumTracks() - 1 do
        local track = reaper.GetTrack(0, i)
        if reaper.GetTrackNumMediaItems(track) > 0 then
            return reaper.SetOnlyTrackSelected(track)
        end
    end
end

function actions.snap()
    local pos = reaper.GetCursorPosition()
    local snapped_pos = reaper.SnapToGrid(0, pos)
    reaper.SetEditCurPos(snapped_pos, false, false)
end

function actions.innerProjectTimeline()
    local len = reaper.GetProjectLength(0)
    reaper.GetSet_LoopTimeRange(true, false, 0, len, false)
end

function actions.innerItem()
    local item_positions = utils.getItemPositionsOnSelectedTracks()
    local cur = reaper.GetCursorPosition()
    for i = #item_positions, 1, -1 do
        local item = item_positions[i]
        if item.left <= cur and item.right >= cur then
            return reaper.GetSet_LoopTimeRange(true, false, item.left, item.right, false)
        end
    end
end

function actions.innerBigItem()
    local item_positions = utils.getBigItemPositionsOnSelectedTracks()
    local current_position = reaper.GetCursorPosition()
    for i = #item_positions, 1, -1 do
        local item = item_positions[i]
        if item.left <= current_position and item.right >= current_position then
            reaper.GetSet_LoopTimeRange(true, false, item.left, item.right, false)
            break
        end
    end
end

function actions.onlyCurrentTrack()
    local track = reaper.GetSelectedTrack(0, 0)
    if track then reaper.SetOnlyTrackSelected(track) end
end

function actions.innerRegion()
    local _, region_id = reaper.GetLastMarkerAndCurRegion(0, reaper.GetCursorPosition())
    local ok, is_region, start_pos, end_pos, _, _ = reaper.EnumProjectMarkers(region_id)
    if ok and is_region then reaper.GetSet_LoopTimeRange(true, false, start_pos, end_pos, false) end
end

function actions.clearTimeSelection()
    local pos = reaper.GetCursorPosition()
    reaper.GetSet_LoopTimeRange(true, false, pos, pos, false)
end

local function getUserGridDivisionInput()
    local ok, str = reaper.GetUserInputs("Set Grid Division", 1, "Fraction/Number", "")
    if not ok then return end
    local division = str:match("[0-9.]+")
    local fraction = str:match("/([0-9.]+)")
    if division and fraction and fraction ~= 0 then return division / fraction end
    if division and not fraction then return division end
    reaper.MB("Could not parse specified grid division " .. str, "Error", 0)
    return nil
end

function actions.setMidiGridDivision()
    local division = getUserGridDivisionInput()
    if division then reaper.SetMIDIEditorGrid(0, division) end
end

function actions.setGridDivision()
    local division = getUserGridDivisionInput()
    if division then reaper.SetProjectGrid(0, division) end
end

function actions.clearSelectedTimeline()
    local pos = reaper.GetCursorPosition()
    reaper.GetSet_LoopTimeRange(true, false, pos, pos, false)
end

-- this one avoids splitting all items across tracks in time selection, if no items are selected
function actions.splitItemsAtTimeSelection()
    if reaper.CountSelectedMediaItems(0) == 0 then return end
    reaper.Main_OnCommand(40061, 0) -- split at time selection
end

---@type integer
local paste = reaper.NamedCommandLookup("_SWS_AWPASTE")
-- Paste selected track-wise, skipping empty tracks.
-- SWS pastes on last touched track which is usually the bottom selected one
function actions.paste()
    local num = reaper.CountSelectedTracks()
    if num < 2 then return reaper.Main_OnCommand(paste, 0) end
    local selected = {}
    local first = nil
    for i = 0, num - 1 do
        local track = reaper.GetSelectedTrack(0, i)
        selected[i + 1] = track
        if not first and reaper.GetTrackNumMediaItems(track) > 0 then first = track end
    end
    if first then reaper.SetOnlyTrackSelected(first) end
    reaper.Main_OnCommand(paste, 0)
    for _, track in ipairs(selected) do reaper.SetTrackSelected(track, true) end
end

function actions.setModeNormal()
    local state = reaper_state.getState()
    state.mode = "normal"
    reaper_state.setState(state)
end

function actions.setModeVisualTrack()
    local track = reaper.GetLastTouchedTrack()
    if not track then return end
    reaper.SetOnlyTrackSelected(track)

    local state = reaper_state.getState()
    state.mode = "visual_track"
    state.visual_track_pivot_i = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER") - 1
    reaper_state.setState(state)
end

function actions.setModeVisualTimeline()
    local state = reaper_state.getState()
    state.mode = "visual_timeline"
    state.timeline_selection_side = "right"
    reaper_state.setState(state)
end

function actions.switchTimelineSelectionSide()
    local state = reaper_state.getState()

    if state.timeline_selection_side == 'right' then
        reaper.Main_OnCommand(40630, 0) -- GoToStartOfSelection
        state.timeline_selection_side = "left"
    else
        reaper.Main_OnCommand(40631, 0) -- GoToEndOfSelection
        state.timeline_selection_side = "right"
    end

    reaper_state.setState(state)
end

---@param name string
---@param forward boolean
local function getMatchedTrack(name, forward)
    if not name then return nil end

    local current_track = reaper.GetSelectedTrack(0, 0)
    local start_i = current_track
        and reaper.GetMediaTrackInfo_Value(current_track, "IP_TRACKNUMBER") - 1
        or 0

    local num_tracks = reaper.GetNumTracks()
    local tracks_searched = 1
    local next_track_i = start_i

    while tracks_searched < num_tracks do
        if forward == true then
            next_track_i = next_track_i + 1
        else
            next_track_i = next_track_i - 1
        end

        local track = reaper.GetTrack(0, next_track_i)
        if not track then
            if forward == true then
                next_track_i = -1
            else
                next_track_i = num_tracks
            end
        else
            local _, current_name = reaper.GetTrackName(track, "")
            local has_no_name = current_name:match("Track ([0-9]+)", 1)
            current_name = current_name:lower()
            tracks_searched = tracks_searched + 1
            if not has_no_name and current_name:match(name:lower()) then
                return track
            end
        end
    end

    return nil
end

function actions.matchTrackNameBackward()
    local _, name = reaper.GetUserInputs("Match Backward", 1, "Match String", "")
    local track = getMatchedTrack(name, false)
    local state = reaper_state.getState()

    if track then
        state.last_searched_track_name = name
        state.last_track_name_search_direction_was_forward = false
        reaper.SetOnlyTrackSelected(track)
    else
        state.last_searched_track_name = "^$"
        state.last_track_name_search_direction_was_forward = true
        feedback.displayMessage(("No match for %s"):format(name))
    end

    reaper_state.setState(state)
end

function actions.matchTrackNameForward()
    local _, name = reaper.GetUserInputs("Match Forward", 1, "Match String", "")
    local track = getMatchedTrack(name, true)
    local state = reaper_state.getState()

    if track then
        state.last_searched_track_name = name
        state.last_track_name_search_direction_was_forward = true
        reaper.SetOnlyTrackSelected(track)
    else
        state.last_searched_track_name = "^$"
        state.last_track_name_search_direction_was_forward = true
        feedback.displayMessage(("No match for %s"):format(name))
    end

    reaper_state.setState(state)
end

function actions.repeatTrackNameMatchForward()
    local state = reaper_state.getState()
    local track = getMatchedTrack(state.last_searched_track_name, state.last_track_name_search_direction_was_forward)
    if track then reaper.SetOnlyTrackSelected(track) end
end

function actions.repeatTrackNameMatchBackward()
    local state = reaper_state.getState()
    local track = getMatchedTrack(state.last_searched_track_name, not state.last_track_name_search_direction_was_forward)
    if track then reaper.SetOnlyTrackSelected(track) end
end

function actions.ResetFeedbackWindow()
    reaper_state.clearFeedbackOpen()
end

return actions
