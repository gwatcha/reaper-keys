local definitions = require("utils.definitions")

local output = {}

function runSubAction(id)
  local action = definitions.getAction(id)
  if action then
    output.runAction(action)
    return
  end

  local numeric_id = id
  if type(id) == "string" then
    numeric_id = reaper.NamedCommandLookup(id)
  end

  if not numeric_id then
    log.fatal("Could not find action with id: " .. id)
    return
  end

  reaper.Main_OnCommand(numeric_id, 0)
end

function output.runAction(action)
  local sub_actions = action
  if type(action) ~= 'table' then
    sub_actions = {action}
  end

  local repetitions = 1
  if sub_actions['repetitions'] then
    repetitions = action['repetitions']
  end

  for i=1,repetitions do
    for _, sub_action in ipairs(sub_actions) do
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
