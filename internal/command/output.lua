local output = {}

local save_edit_cursor_action = {'_BR_SAVE_CURSOR_POS_SLOT_16'}
local restore_edit_cursor_action = {'_BR_RESTORE_CURSOR_POS_SLOT_16'}
local set_loop_start_action = {40222, "SetLoopStart"}
local set_loop_end_action = {40223, "SetLoopEnd"}

local ser = require("serpent")
local definitions = require("definitions")
local actions = definitions.read('actions')

function runSubAction(id)
  local numeric_id
  if actions[id] then
    output.runAction(actions[id])
  end
  if type(id) == "string" then
    numeric_id = reaper.NamedCommandLookup(id)
  else
    numeric_id = id
  end
  reaper.Main_OnCommand(numeric_id, 0)
end

function output.runAction(action)
  local sub_actions = action
  local repetitions = 1
  if type(action) == 'table' then
    for i, sub_action in ipairs(action) do
      sub_actions[i] = sub_action
    end

    if action['repetitions'] then
      repetitions = action['repetitions']
    end
  end

  if type(sub_actions) ~= 'table' then
    sub_actions = {sub_actions}
  end

  for i=1,repetitions do
    for _, sub_action in pairs(sub_actions) do
      runSubAction(sub_action)
    end
  end

end

function output.runActionNTimes(action, times)
  for i=1,times,1 do
    output.runAction(action)
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
