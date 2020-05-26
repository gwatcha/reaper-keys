local log = require('utils.log')
local format = require('utils.format')

local reaper_util = {}

function mergeItemPositionsLists(item_positions_list)
  local merged_list = {}

  function areRemainingItems()
    for i,item_positions in ipairs(item_positions_list) do
      if #item_positions_list[i] ~= 0 then
        return true
      end
    end
    return false
  end

  while areRemainingItems() do
    local next_item = nil
    for i,item_positions in ipairs(item_positions_list) do
      local next_item_for_this_list = item_positions[1]
      if next_item_for_this_list then
        if not next_item or next_item_for_this_list.left < next_item.left then
          next_item = next_item_for_this_list
          selected_list_i = i
        end
      end
    end

    table.insert(merged_list, next_item)
    table.remove(item_positions_list[selected_list_i], 1)
  end

  return merged_list
end

function getItemPositionsOnTracks(tracks)
  local item_positions_lists = {}
  for i=1,#tracks do
    local current_track = tracks[i]
    local item_positions = {}
    local num_items_on_track = reaper.GetTrackNumMediaItems(current_track)

    for j=1,num_items_on_track do
      local item = reaper.GetTrackMediaItem(current_track, j-1)
      local start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      local length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
      item_positions[j] = {left=start, right=start+length}
    end

    item_positions_lists[i] = item_positions
  end

  local merged_list = mergeItemPositionsLists(item_positions_lists)
  return merged_list
end

function getItemPositionsOnSelectedTracks()
  local selected_tracks = {}
  for i=0,reaper.CountSelectedTracks() do
    selected_tracks[i] = reaper.GetSelectedTrack(0, i-1)
  end

  return getItemPositionsOnTracks(selected_tracks)
end

function getBigItemPositionsOnSelectedTracks()
  local item_positions = getItemPositionsOnSelectedTracks()
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


function reaper_util.selectInnerProject()
  local project_end = getProjectEnd()
  reaper.GetSet_LoopTimeRange(true, false, 0, project_end, false)
end

function reaper_util.moveToProjectStart()
  reaper.SetEditCurPos(0, false, false)
end

function getProjectEnd()
  local all_tracks = {}
  for i=0,reaper.GetNumTracks()-1 do
    all_tracks[i] = reaper.GetTrack(0, i)
  end

  local all_items_positions = getItemPositionsOnTracks(all_tracks)
  local furthest_item_end = 0
  for _,item_position in ipairs(all_items_positions) do
    if item_position.right > furthest_item_end then
      furthest_item_end = item_position.right
    end
  end

  return furthest_item_end
end

function reaper_util.moveToProjectEnd()
  reaper.SetEditCurPos(getProjectEnd(), false, false)
end

function reaper_util.selectInnerItem()
  local item_positions = getItemPositionsOnSelectedTracks()
  local current_position = reaper.GetCursorPosition()
  for i,item in pairs(item_positions) do
    if item.left <= current_position and item.right >= current_position then
      reaper.GetSet_LoopTimeRange(true, false, item.left, item.right, false)
      break
    end
  end
end

function reaper_util.selectInnerBigItem()
  local item_positions = getBigItemPositionsOnSelectedTracks()
  local current_position = reaper.GetCursorPosition()
  for i,item in pairs(item_positions) do
    if item.left <= current_position and item.right >= current_position then
      reaper.GetSet_LoopTimeRange(true, false, item.left, item.right, false)
      break
    end
  end
end

function reaper_util.moveToLastItemEnd()
  local item_positions = getBigItemPositionsOnSelectedTracks()
  if #item_positions > 0 then
    local last_item  = item_positions[#item_positions]
    reaper.SetEditCurPos(last_item.right, true, false)
  end
end

function reaper_util.moveToFirstItemStart()
  local item_positions = getBigItemPositionsOnSelectedTracks()
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
  moveToPrevItemStart(getBigItemPositionsOnSelectedTracks())
end

function reaper_util.moveToPrevItemStart()
  moveToPrevItemStart(getItemPositionsOnSelectedTracks())
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
  moveToNextItemStart(getBigItemPositionsOnSelectedTracks())
end

function reaper_util.moveToNextItemStart()
  moveToNextItemStart(getItemPositionsOnSelectedTracks())
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
  moveToNextItemEnd(getBigItemPositionsOnSelectedTracks())
end

function reaper_util.moveToNextItemEnd()
  moveToNextItemEnd(getItemPositionsOnSelectedTracks())
end

function reaper_util.matchTrackName(search_name, forward)
  if not search_name then
    return nil
  end

  local current_track = reaper.GetSelectedTrack(0, 0)
  local start_i = 0
  if current_track then
    start_i = reaper.GetMediaTrackInfo_Value(current_track, "IP_TRACKNUMBER") - 1
  end

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
      local number_if_no_name = current_name:match("Track ([0-9]+)", 1)
      if number_if_no_name then
        current_name = number_if_no_name
      end
      tracks_searched = tracks_searched + 1
      if current_name:match(search_name) then
        return track
      end
    end
  end

  return nil
end

function reaper_util.selectTrackByNumber()
  local _, number = reaper.GetUserInputs("Match Forward", 1, "Track Number", "")
  local track = reaper.GetTrack(0, number-1)
  if track then
    reaper.SetOnlyTrackSelected(track)
  end
end

return reaper_util
