local definitions = require("utils.definitions")
local log = require('utils.log')
local ser = require("serpent")

local output = {}

function runSubAction(id)
  local action = definitions.getAction(id)
  if action then
    output.runAction(action)
    return
  end

  if type(id) == "function" then
    id()
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

function output.makeSelectionFromMotion(timeline_motion, repetitions)
  local sel_start = reaper.GetCursorPosition()
  output.runActionNTimes(timeline_motion, repetitions)
  local sel_end = reaper.GetCursorPosition()
  local length = sel_end - sel_start
  reaper.MoveEditCursor(length * -1, true)
end

return output
