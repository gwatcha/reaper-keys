local state_machine_definitions = require('state_machine.definitions')
local sequences = require("command.sequences")
local log = require('utils.log')
local utils = require('command.utils')
local ser = require("serpent")

function makeCommandDescription(command)
  local desc = ""
  for _, command_part_name  in pairs(command) do
    -- FIXME numbers
    desc = desc .. command_part_name .. " "
  end

  return desc
end

function executeCommand(state, command)
  local entry_type_sequence = {}
  local command_parts = {}
  for entry_type, command_part_name in pairs(command) do
    table.insert(entry_type_sequence, entry_type)
    table.insert(command_parts, utils.getCommandFromName(command_part_name))
  end

  local functionForCommand = sequences.getFunctionForCommand(command, state['context'], state['mode'])
  if not functionForCommand then
    functionForCommand = sequences.getFunctionForCommand(command, 'global', state['mode'])
  end

  if functionForCommand then
    reaper.Undo_BeginBlock()
    local new_state = functionForCommand(state, table.unpack(command_parts))
    reaper.Undo_EndBlock('reaper-keys: ' .. makeCommandDescription(command), 0)
    new_state['key_sequence'] = ""
    return new_state
  end

  log.error('Did not find an associated command function to execute for this command!')
  return state_machine_definitions['reset_state']
end

return executeCommand
