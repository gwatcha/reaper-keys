local log = require("utils.log")
local format = require('utils.format')

local reaper_util = {}

function getItemPositionsOnSelectedTrack()
  local current_track = reaper.GetSelectedTrack(0, 0)
  local num_items = reaper.GetTrackNumMediaItems(current_track)
  local item_positions = {}
  for i=1,num_items do
    local item = reaper.GetTrackMediaItem(current_track, i-1)
    local start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    item_positions[i] = {left=start, right=start+length}
  end

  return item_positions
end

function getBigItemPositionsOnSelectedTrack()
  local item_positions = getItemPositionsOnSelectedTrack()
  local big_item_positions = {}

  if #item_positions == 0 then
    return big_item_positions
  end

  local j = 1
  big_item_positions[j] = item_positions[1]
  for i=1,#item_positions do
    local next_item = item_positions[i]
    local current_big_item = big_item_positions[j]
    if next_item.left <= current_big_item.right and next_item.right > current_big_item.right then
       current_big_item.right = next_item.right
       big_item_positions[j] = current_big_item
    end

    if next_item.left > current_big_item.right then
      j = j + 1
      big_item_positions[j] = next_item
    end
  end

  return big_item_positions
end

function reaper_util.firstTrack()
  local first_track = reaper.GetTrack(0, 0)
  reaper.SetOnlyTrackSelected(first_track)
end

function reaper_util.lastTrack()
  local num_tracks = reaper.GetNumTracks()
  local last_track = reaper.GetTrack(0, num_tracks-1)
  reaper.SetOnlyTrackSelected(last_track)
end

function reaper_util.selectInnerItem()
  local item_positions = getItemPositionsOnSelectedTrack()
  local current_position = reaper.GetCursorPosition()
  for i,item in pairs(item_positions) do
    if item.left <= current_position and item.right >= current_position then
      reaper.GetSet_LoopTimeRange(true, false, item.left, item.right, false)
      break
    end
  end
end

function reaper_util.selectInnerBigItem()
  local item_positions = getBigItemPositionsOnSelectedTrack()
  local current_position = reaper.GetCursorPosition()
  for i,item in pairs(item_positions) do
    if item.left <= current_position and item.right >= current_position then
      reaper.GetSet_LoopTimeRange(true, false, item.left, item.right, false)
      break
    end
  end
end

function reaper_util.moveToLastItemEnd()
  local item_positions = getBigItemPositionsOnSelectedTrack()
  if #item_positions > 0 then
    local last_item  = item_positions[#item_positions]
    reaper.SetEditCurPos(last_item.right, true, false)
  end
end

function reaper_util.moveToFirstItemStart()
  local item_positions = getBigItemPositionsOnSelectedTrack()
  if #item_positions > 0 then
    local first_item  = item_positions[1]
    reaper.SetEditCurPos(first_item.left, true, false)
  end
end

function moveToPrevItemStart(item_positions)
  local current_position = reaper.GetCursorPosition()
  local next_position = nil
  for i,item in pairs(item_positions) do
    if not next_position and item.left < current_position and item.right >= current_position then
      next_position = item.left
    end

    if next_position and item.left > next_position and item.right >= next_position then
      next_position = item.left
    end

    local next_item = item_positions[i+1]
    if not next_item or next_item.left >= current_position then
      next_position = item.left
      break
    end
  end

  if next_position then
    reaper.SetEditCurPos(next_position, true, false)
  end
end

function reaper_util.moveToPrevBigItemStart()
  moveToPrevItemStart(getBigItemPositionsOnSelectedTrack())
end

function reaper_util.moveToPrevItemStart()
  moveToPrevItemStart(getItemPositionsOnSelectedTrack())
end

function moveToNextItemStart(item_positions)
  local current_position = reaper.GetCursorPosition()
  local next_position = nil
  for i,item_position in pairs(item_positions) do
    if not next_position and current_position < item_position.left  then
      next_position = item_position.left
    end
    if next_position and item_position.left < next_position then
      next_position = item_position.left
    end
  end
  if next_position then
    reaper.SetEditCurPos(next_position, true, false)
  end
end

function reaper_util.moveToNextBigItemStart()
  moveToNextItemStart(getBigItemPositionsOnSelectedTrack())
end

function reaper_util.moveToNextItemStart()
  moveToNextItemStart(getItemPositionsOnSelectedTrack())
end

function moveToNextItemEnd(item_positions)
  local current_position = reaper.GetCursorPosition()
  local next_postition = nil
  for _,item_position in pairs(item_positions) do
    if not next_position and item_position.right > current_position then
      next_position = item_position.right
    end
    if next_position and item_position.right < next_position and item_position.right > current_position then
      next_position = item_position.right
    end
  end
  if next_position then
    reaper.SetEditCurPos(next_position, true, false)
  end
end


function reaper_util.moveToNextBigItemEnd()
  moveToNextItemEnd(getBigItemPositionsOnSelectedTrack())
end

function reaper_util.moveToNextItemEnd()
  moveToNextItemEnd(getItemPositionsOnSelectedTrack())
end

return reaper_util
