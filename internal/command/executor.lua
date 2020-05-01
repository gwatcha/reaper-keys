local state_machine_constants = require('state_machine.constants')
local sequences = require("command.sequences")
local definitions = require("utils.definitions")
local regex_match_entry_types = require("command.definitions.regex_match_entry_types")
local log = require('utils.log')
local utils = require('command.utils')
local ser = require("serpent")

function executeCommand(state, command)
  local executable_command_parts = {}
  for i,action_type in pairs(command.sequence) do
    if regex_match_entry_types[action_type] then
      local value = command.parts[i]
      if action_type == 'number' then value = tonumber(value) end
      table.insert(executable_command_parts, value)
    else
      table.insert(executable_command_parts, definitions.getAction(command.parts[i]))
    end
  end

  local functionForCommand = sequences.getFunctionForSequence(command.sequence, state['context'], state['mode'])

  if functionForCommand then
    reaper.Undo_BeginBlock()
    local new_state = functionForCommand(state, table.unpack(executable_command_parts))
    reaper.Undo_EndBlock('reaper-keys: ' .. utils.makeCommandDescription(command), 1)
    new_state['key_sequence'] = ""
    return new_state
  end

  log.error('Did not find an associated command function to execute for this command!')
  return state_machine_constants['reset_state']
end

return executeCommand
