local utils = require("custom_actions.utils")

local movement = {}

function movement.projectStart()
  reaper.SetEditCurPos(0, true, false)
end

function movement.projectEnd()
  local project_end = reaper.GetProjectLength(0)
  reaper.SetEditCurPos(project_end, true, false)
end

function movement.lastItemEnd()
  local item_positions = utils.getBigItemPositionsOnSelectedTracks()
  if #item_positions > 0 then
    local last_item  = item_positions[#item_positions]
    reaper.SetEditCurPos(last_item.right, true, false)
  end
end

function movement.firstItemStart()
  local item_positions = utils.getBigItemPositionsOnSelectedTracks()
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

function movement.prevBigItemStart()
  moveToPrevItemStart(utils.getBigItemPositionsOnSelectedTracks())
end

function movement.prevItemStart()
  moveToPrevItemStart(utils.getItemPositionsOnSelectedTracks())
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

function movement.nextBigItemStart()
  moveToNextItemStart(utils.getBigItemPositionsOnSelectedTracks())
end

function movement.nextItemStart()
  moveToNextItemStart(utils.getItemPositionsOnSelectedTracks())
end

function moveToNextItemEnd(item_positions)
  local current_position = reaper.GetCursorPosition()
  local next_position = nil
  local tolerance = .002
  for _,item_position in pairs(item_positions) do
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
  local first_track = reaper.GetTrack(0, 0)
  reaper.SetOnlyTrackSelected(first_track)
end

function movement.lastTrack()
  local num_tracks = reaper.GetNumTracks()
  local last_track = reaper.GetTrack(0, num_tracks-1)
  reaper.SetOnlyTrackSelected(last_track)
end

function movement.trackWithNumber()
  local _, number = reaper.GetUserInputs("Match Forward", 1, "Track Number", "")
  local track = reaper.GetTrack(0, number-1)
  if track then
    reaper.SetOnlyTrackSelected(track)
  end
end

return movement
