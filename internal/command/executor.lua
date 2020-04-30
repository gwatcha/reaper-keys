local state_machine_constants = require('state_machine.constants')
local sequences = require("command.sequences")
local definitions = require("utils.definitions")
local log = require('utils.log')
local utils = require('command.utils')
local ser = require("serpent")

function makeCommandDescription(command)
  local desc = ""
  for _, action_name  in pairs(command) do
    -- FIXME numbers
    desc = desc .. action_name .. " "
  end

  return desc
end

function executeCommand(state, command)
  local action_sequence = {}
  local actions = {}
  for action_type, action_name in pairs(command) do
    table.insert(action_sequence, action_type)
    table.insert(actions, definitions.getAction(action_name))
  end

  local functionForCommand = sequences.getFunctionForCommand(command, state['context'], state['mode'])

  if functionForCommand then
    reaper.Undo_BeginBlock()
    local new_state = functionForCommand(state, table.unpack(actions))
    reaper.Undo_EndBlock('reaper-keys: ' .. makeCommandDescription(command), 0)
    new_state['key_sequence'] = ""
    return new_state
  end

  log.error('Did not find an associated command function to execute for this command!')
  return state_machine_constants['reset_state']
end

return executeCommand
