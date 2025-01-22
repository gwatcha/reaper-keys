local log = require 'utils.log'
local utils = require "custom_actions.utils"
local custom_actions = {}

function custom_actions.projectStart()
    reaper.SetEditCurPos(0, true, false)
end

function custom_actions.projectEnd()
    reaper.SetEditCurPos(reaper.GetProjectLength(0), true, false)
end

function custom_actions.lastItemEnd()
    local positions = utils.getBigItemPositionsOnSelectedTracks()
    if #positions == 0 then return end
    reaper.SetEditCurPos(positions[#positions].right, true, false)
end

function custom_actions.firstItemStart()
    local positions = utils.getBigItemPositionsOnSelectedTracks()
    if #positions == 0 then return end
    reaper.SetEditCurPos(positions[1].left, true, false)
end

local function moveToPrevItemStart(item_positions)
    local current_position = reaper.GetCursorPosition()
    local next_position = nil
    for i, item in pairs(item_positions) do
        if not next_position and item.left < current_position and item.right >= current_position then
            next_position = item.left
        end

        if next_position and item.left > next_position and item.right >= next_position then
            next_position = item.left
        end

        local next_item = item_positions[i + 1]
        if not next_item or next_item.left >= current_position then
            next_position = item.left
            break
        end
    end

    if next_position then reaper.SetEditCurPos(next_position, true, false) end
end

function custom_actions.prevBigItemStart()
    moveToPrevItemStart(utils.getBigItemPositionsOnSelectedTracks())
end

function custom_actions.prevItemStart()
    moveToPrevItemStart(utils.getItemPositionsOnSelectedTracks())
end

local function moveToNextItemStart(item_positions)
    local current_position = reaper.GetCursorPosition()
    local next_position = nil
    for _, item_position in pairs(item_positions) do
        if not next_position and current_position < item_position.left then
            next_position = item_position.left
        end
        if next_position and item_position.left < next_position then
            next_position = item_position.left
        end
    end
    if next_position then reaper.SetEditCurPos(next_position, true, false) end
end

function custom_actions.nextBigItemStart()
    moveToNextItemStart(utils.getBigItemPositionsOnSelectedTracks())
end

function custom_actions.nextItemStart()
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

function custom_actions.nextBigItemEnd()
    moveToNextItemEnd(utils.getBigItemPositionsOnSelectedTracks())
end

function custom_actions.nextItemEnd()
    moveToNextItemEnd(utils.getItemPositionsOnSelectedTracks())
end

function custom_actions.firstTrack()
    local track = reaper.GetTrack(0, 0)
    if track then reaper.SetOnlyTrackSelected(track) end
end

function custom_actions.lastTrack()
    local num = reaper.GetNumTracks()
    if num == 0 then return end
    local track = reaper.GetTrack(0, num - 1)
    reaper.SetOnlyTrackSelected(track)
end

function custom_actions.trackWithNumber()
    local _, number = reaper.GetUserInputs("Match Forward", 1, "Track Number", "")
    if type(number) ~= 'number' then return end

    local track = reaper.GetTrack(0, number - 1)
    if track then reaper.SetOnlyTrackSelected(track) end
end

function custom_actions.firstTrackWithItem()
    local num = reaper.GetNumTracks()
    if num == 0 then return end
    for i = 0, num - 1 do
        local track = reaper.GetTrack(0, i)
        if reaper.GetTrackNumMediaItems(track) > 0 then
            reaper.SetOnlyTrackSelected(track)
            return
        end
    end
end

function custom_actions.snap()
    local pos = reaper.GetCursorPosition()
    local snapped_pos = reaper.SnapToGrid(0, pos)
    reaper.SetEditCurPos(snapped_pos, false, false)
end


function custom_actions.innerProjectTimeline()
    local project_end = reaper.GetProjectLength(0)
    reaper.GetSet_LoopTimeRange(true, false, 0, project_end, false)
end

function custom_actions.innerItem()
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

function custom_actions.innerBigItem()
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

function custom_actions.onlyCurrentTrack()
    local track = reaper.GetSelectedTrack(0, 0)
    if track then
        reaper.SetOnlyTrackSelected(track)
    end
end

function custom_actions.innerRegion()
    local current_position = reaper.GetCursorPosition()
    local _, region_id = reaper.GetLastMarkerAndCurRegion(0, current_position)
    utils.selectRegion(region_id)
end


function custom_actions.clearTimeSelection()
    local current_position = reaper.GetCursorPosition()
    reaper.GetSet_LoopTimeRange(true, false, current_position, current_position, false)
end

local function getUserGridDivisionInput()
    local _, num_string = reaper.GetUserInputs("Set Grid Division", 1, "Fraction/Number", "")
    local first_num = num_string:match("[0-9.]+")
    local divider = num_string:match("/([0-9.]+)")

    local division = nil
    if first_num and divider then
        division = first_num / divider
    elseif first_num then
        division = first_num
    else
        log.error("Could not parse specified grid division.")
        return nil
    end

    return division
end

function custom_actions.setMidiGridDivision()
    local division = getUserGridDivisionInput()
    if division then reaper.SetMIDIEditorGrid(0, division) end
end

function custom_actions.clearSelectedTimeline()
    local current_position = reaper.GetCursorPosition()
    reaper.GetSet_LoopTimeRange(true, false, current_position, current_position, false)
end

function custom_actions.setGridDivision()
    local division = getUserGridDivisionInput()
    if division then reaper.SetProjectGrid(0, division) end
end

-- this one avoids splitting all items across tracks in time selection, if no items are selected
function custom_actions.splitItemsAtTimeSelection()
    if reaper.CountSelectedMediaItems(0) == 0 then return end
    local SplitAtTimeSelection = 40061
    reaper.Main_OnCommand(SplitAtTimeSelection, 0)
end

return custom_actions
