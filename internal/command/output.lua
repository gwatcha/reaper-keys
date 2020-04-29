local output = {}

local save_edit_cursor_action = {'_BR_SAVE_CURSOR_POS_SLOT_16'}
local restore_edit_cursor_action = {'_BR_RESTORE_CURSOR_POS_SLOT_16'}

local set_loop_start_action = {40222, "SetLoopStart"}
local set_loop_end_action = {40223, "SetLoopEnd"}

function output.runReaperCommand(action)
  local repetitions = 1
  if action['repetitions'] then
    repetitions = action['repetitions']
  end

  local id = action[1]
  local numeric_id
  if type(id) == "string" then
    numeric_id = reaper.NamedCommandLookup(id)
  else
    numeric_id = id
  end

  for i=1,repetitions,1 do
    reaper.Main_OnCommand(numeric_id, 0)
  end
end

function output.runReaperCommandNTimes(action, times)
  for i=1,times,1 do
    output.runReaperCommand(timeline_motion)
  end
end

function output.makeSelectionFromPositions(selection_start, selection_end)
  if selection_start > selection_end then
    local tmp = selection_start
    selection_start = selection_end
    selection_end = tmp
  end

  reaper.GetSet_LoopTimeRange(true, false, selection_start, selection_end, false)
end

return output
