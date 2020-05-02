local state_machine_constants = require('state_machine.constants')
local sequences = require("command.sequences")
local definitions = require("utils.definitions")
local regex_match_entry_types = require("command.constants").regex_match_entry_types
local log = require('utils.log')
local utils = require('command.utils')
local ser = require("serpent")

function makeExecutableCommandParts(command)
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

  return executable_command_parts
end

function executeCommand(command, context, mode)
  local functionForCommand = sequences.getFunctionForSequence(command.sequence, context, mode)
  if functionForCommand then
    reaper.Undo_BeginBlock()
    local executable_command_parts = makeExecutableCommandParts(command)
    functionForCommand(table.unpack(executable_command_parts))
    reaper.Undo_EndBlock('reaper-keys: ' .. utils.makeCommandDescription(command), 1)
  else
    log.error('Did not find an associated command function to execute for this command!')
  end
end

return executeCommand
