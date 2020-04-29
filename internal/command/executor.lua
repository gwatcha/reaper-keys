local state_machine_definitions = require('state_machine.definitions')
local sequences = require("command.sequences")
local log = require('utils.log')
local utils = require('command.utils')

function makeCommandDescription(command)
  local desc = ""
  for _, entry_value  in pairs(command) do
    -- FIXME numbers
    local command_name = entry_value[2]
    if command_name then
      desc = desc .. command_name .. " "
    end
  end

  return desc
end

function executeCommand(state, command)
  local entry_type_sequence = {}
  local entry_value_sequence = {}
  for entry_type, entry_value in pairs(command) do
    table.insert(entry_type_sequence, entry_type)
    table.insert(entry_value_sequence, entry_value)
  end

  local functionForCommand = sequences.getFunctionForCommand(command, state['context'], state['mode'])
  if not functionForCommand then
    functionForCommand = sequences.getFunctionForCommand(command, 'global', state['mode'])
  end

  if functionForCommand then
    reaper.Undo_BeginBlock()
    local new_state = functionForCommand(state, table.unpack(entry_value_sequence))
    reaper.Undo_EndBlock('reaper-keys: ' .. makeCommandDescription(command), 0)
    new_state['key_sequence'] = ""
    return new_state
  end

  log.error('Did not find an associated command function to execute for this command!')
  return state_machine_definitions['reset_state']
end

return executeCommand
