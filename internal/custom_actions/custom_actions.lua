local utils = require "custom_actions.utils"
local actions = {}

function actions.projectStart() reaper.SetEditCurPos(0, true, false) end

function actions.projectEnd()
    reaper.SetEditCurPos(reaper.GetProjectLength(0), true, false)
end

function actions.firstItemStart()
    local start = nil
    for i = 0, reaper.CountSelectedTracks() - 1 do
        local track = reaper.GetSelectedTrack(0, i)
        if reaper.GetTrackNumMediaItems(track) > 0 then
            local item = reaper.GetTrackMediaItem(track, 0)
            local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
            if not start or pos < start then start = pos end
        end
    end
    if start then reaper.SetEditCurPos(start, true, false) end
end

-- This won't work if last item on track is not the "last" one, imagine [long----[short]--],
-- short is last but ends sooner. However, this is a reasonable limitation as otherwise we
-- need to scan at most all items on all selected tracks
function actions.lastItemEnd()
    local last_end = nil
    for i = 0, reaper.CountSelectedTracks() - 1 do
        local track = reaper.GetSelectedTrack(0, i)
        local items = reaper.GetTrackNumMediaItems(track)
        if items > 0 then
            local item = reaper.GetTrackMediaItem(track, items - 1)
            local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
                + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
            if not last_end or pos > last_end then last_end = pos end
        end
    end
    if last_end then reaper.SetEditCurPos(last_end, true, false) end
end

local function moveToPrevItemStart(item_positions)
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

function actions.prevBigItemStart()
    moveToPrevItemStart(utils.getBigItemPositionsOnSelectedTracks())
end

function actions.prevItemStart()
    moveToPrevItemStart(utils.getItemPositionsOnSelectedTracks())
end

local function moveToNextItemStart(item_positions)
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

function actions.nextBigItemStart()
    moveToNextItemStart(utils.getBigItemPositionsOnSelectedTracks())
end

function actions.nextItemStart()
    moveToNextItemStart(utils.getItemPositionsOnSelectedTracks())
end

local function moveToNextItemEnd(item_positions)
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

function actions.nextBigItemEnd()
    moveToNextItemEnd(utils.getBigItemPositionsOnSelectedTracks())
end

function actions.nextItemEnd()
    moveToNextItemEnd(utils.getItemPositionsOnSelectedTracks())
end

function actions.firstTrack()
    local track = reaper.GetTrack(0, 0)
    if track then reaper.SetOnlyTrackSelected(track) end
end

function actions.lastTrack()
    local num = reaper.GetNumTracks()
    if num == 0 then return end
    local track = reaper.GetTrack(0, num - 1)
    reaper.SetOnlyTrackSelected(track)
end

function actions.trackWithNumber()
    local _, number = reaper.GetUserInputs("Match Forward", 1, "Track Number", "")
    if type(number) ~= 'number' then return end

    local track = reaper.GetTrack(0, number - 1)
    if track then reaper.SetOnlyTrackSelected(track) end
end

function actions.firstTrackWithItem()
    local num = reaper.GetNumTracks()
    if num == 0 then return end
    for i = 0, num - 1 do
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
    local project_end = reaper.GetProjectLength(0)
    reaper.GetSet_LoopTimeRange(true, false, 0, project_end, false)
end

function actions.innerItem()
    local item_positions = utils.getItemPositionsOnSelectedTracks()
    local current_position = reaper.GetCursorPosition()
    for i = #item_positions, 1, -1 do
        local item = item_positions[i]
        if item.left <= current_position and item.right >= current_position then
            reaper.GetSet_LoopTimeRange(true, false, item.left, item.right, false)
            break
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
    if track then
        reaper.SetOnlyTrackSelected(track)
    end
end

function actions.innerRegion()
    local pos = reaper.GetCursorPosition()
    local _, region_id = reaper.GetLastMarkerAndCurRegion(0, pos)
    utils.selectRegion(region_id)
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
    if division and fraction then
        return division / fraction
    elseif division then
        return division
    else
        reaper.MB("Could not parse specified grid division", "Error", 0)
        return nil
    end
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
    local SplitAtTimeSelection = 40061
    reaper.Main_OnCommand(SplitAtTimeSelection, 0)
end

return actions
