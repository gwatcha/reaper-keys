local utils = require("custom_actions.utils")

local selection = {}

function selection.innerProjectTimeline()
  local project_end = reaper.GetProjectLength(0)
  reaper.GetSet_LoopTimeRange(true, false, 0, project_end, false)
end

function selection.innerItem()
  local item_positions = utils.getItemPositionsOnSelectedTracks()
  local current_position = reaper.GetCursorPosition()
  for i,item in pairs(item_positions) do
    if item.left <= current_position and item.right >= current_position then
      reaper.GetSet_LoopTimeRange(true, false, item.left, item.right, false)
      break
    end
  end
end

function selection.innerBigItem()
  local item_positions = utils.getBigItemPositionsOnSelectedTracks()
  local current_position = reaper.GetCursorPosition()
  for i,item in pairs(item_positions) do
    if item.left <= current_position and item.right >= current_position then
      reaper.GetSet_LoopTimeRange(true, false, item.left, item.right, false)
      break
    end
  end
end

function selection.onlyCurrentTrack()
  local track = reaper.GetSelectedTrack(0, 0)
  if track then
    reaper.SetOnlyTrackSelected(track)
  end
end

function selection.innerRegion()
  local current_position = reaper.GetCursorPosition()
  _, region_id = reaper.GetLastMarkerAndCurRegion(0, current_position)
  utils.selectRegion(region_id)
end

return selection
