local utils = require "custom_actions.utils"
local movement = {}

function movement.projectStart()
    reaper.SetEditCurPos(0, true, false)
end

function movement.projectEnd()
    reaper.SetEditCurPos(reaper.GetProjectLength(0), true, false)
end

function movement.lastItemEnd()
    local positions = utils.getBigItemPositionsOnSelectedTracks()
    if #positions == 0 then return end
    reaper.SetEditCurPos(positions[#positions].right, true, false)
end

function movement.firstItemStart()
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

function movement.prevBigItemStart()
    moveToPrevItemStart(utils.getBigItemPositionsOnSelectedTracks())
end

function movement.prevItemStart()
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

function movement.nextBigItemStart()
    moveToNextItemStart(utils.getBigItemPositionsOnSelectedTracks())
end

function movement.nextItemStart()
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

function movement.nextBigItemEnd()
    moveToNextItemEnd(utils.getBigItemPositionsOnSelectedTracks())
end

function movement.nextItemEnd()
    moveToNextItemEnd(utils.getItemPositionsOnSelectedTracks())
end

function movement.firstTrack()
    local track = reaper.GetTrack(0, 0)
    if track then reaper.SetOnlyTrackSelected(track) end
end

function movement.lastTrack()
    local num = reaper.GetNumTracks()
    if num == 0 then return end
    local track = reaper.GetTrack(0, num - 1)
    reaper.SetOnlyTrackSelected(track)
end

function movement.trackWithNumber()
    local _, number = reaper.GetUserInputs("Match Forward", 1, "Track Number", "")
    if type(number) ~= 'number' then return end

    local track = reaper.GetTrack(0, number - 1)
    if track then reaper.SetOnlyTrackSelected(track) end
end

function movement.firstTrackWithItem()
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

function movement.snap()
    local pos = reaper.GetCursorPosition()
    local snapped_pos = reaper.SnapToGrid(0, pos)
    reaper.SetEditCurPos(snapped_pos, false, false)
end

return movement
