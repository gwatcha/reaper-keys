-- local operator = require("operator")
-- local motion = require("motion")
-- local action = require("action")
local str = require("string")
local log = require("utils.log")

function runCommand(command_id)
end

function runReaperCommand(command_id)
  local numeric_id = command_id
  if type(command_id) == "string" then
    numeric_id = reaper.NamedCommandLookup(command_id)
  end
  reaper.Main_OnCommand(numeric_id, 0)
end

function dispatch(command, specified_repetitions, state)
  reaper.Undo_BeginBlock()
  local new_state = state

  local command_ids = command[1]

  local repetitions = specified_repetitions
  if command["times"] then
    repetitions = repetitions * command["times"]
  end

  local is_command_sequence = type(command_ids) == "table"
  for i=1, repetitions, 1 do
    if is_command_sequence then
      for _, command_id in ipairs(command_ids) do
        runReaperCommand(command_id)
      end
      else
        runReaperCommand(command_ids)
    end
  end


  local command_name = command[2]
  local command_desc = command_name
  if repetitions > 1 then
    command_desc = command_name .. ' * ' .. repetitions
  end
  reaper.Undo_EndBlock('vimper: ' .. command_desc, 0)

  new_state["key_sequence"] = ""
  return new_state
end

return dispatch
