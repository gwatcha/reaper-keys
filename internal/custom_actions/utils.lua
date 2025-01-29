local utils = {}
-- TODO rename to movement_utils.lua

local function mergeItemPositionsLists(item_positions_list)
  local merged_list = {}

  local function areRemainingItems()
    for i, _ in ipairs(item_positions_list) do
      if #item_positions_list[i] ~= 0 then return true end
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

local function getItemPositionsOnTracks(tracks)
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

function utils.getItemPositionsOnSelectedTracks()
  local selected_tracks = {}
  for i=0,reaper.CountSelectedTracks() do
    selected_tracks[i] = reaper.GetSelectedTrack(0, i-1)
  end

  return getItemPositionsOnTracks(selected_tracks)
end

function utils.getBigItemPositionsOnSelectedTracks()
  local item_positions = utils.getItemPositionsOnSelectedTracks()
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

function utils.getTrackPosition()
  local track = reaper.GetLastTouchedTrack()
  if not track then return 0 end
  return reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER") - 1
end

function utils.getSelectedTracks()
  local selected_tracks = {}
  for i=0, reaper.CountSelectedTracks()-1 do
    local track = reaper.GetSelectedTrack(0, i)
    selected_tracks[i+1] = track
  end
  return selected_tracks
end

function utils.setTrackSelection(indices)
  reaper.Main_OnCommand(40297, 0) -- UnselectTracks
  if not indices then return end
  for _, track_index in ipairs(indices) do
    local track = reaper.GetTrack(0, track_index)
    if track then reaper.SetTrackSelected(track, true) end
  end
  reaper.Main_OnCommand(40913, 0) -- ScrollToSelectedTracks
end

function utils.scrollToPosition(pos)
  local current_position = reaper.GetCursorPosition()
  reaper.SetEditCurPos(pos, true, false)
  reaper.SetEditCurPos(current_position, false, false)
end

function utils.setCurrentTrack(index)
  local previously_selected = utils.getSelectedTrackIndices()
  local previous_position = utils.getTrackPosition()

  local track = reaper.GetTrack(0, index)
  if track then
    reaper.SetOnlyTrackSelected(track)
    local SetFirstSelectedAsLastTouched = 40914
    reaper.Main_OnCommand(SetFirstSelectedAsLastTouched, 0)

    local new_selection = previously_selected
    if previous_position and new_selection then
      for i,selected_track_i in ipairs(new_selection) do
        if selected_track_i == previous_position then
          table.remove(new_selection, i)
        end
      end
    end
    table.insert(new_selection, index)
    utils.setTrackSelection(new_selection)
  end
end

function utils.getSelectedTrackIndices()
    local idxs = {}
    for i = 0, reaper.CountSelectedTracks() - 1 do
        idxs[i + 1] = reaper.GetMediaTrackInfo_Value(
            reaper.GetSelectedTrack(0, i), "IP_TRACKNUMBER") - 1
    end
    return idxs
end

return utils
