local state_machine_constants = require('state_machine.constants')
local sequences = require("command.sequences")
local definitions = require("utils.definitions")
local regex_match_entry_types = require("command.constants").regex_match_entry_types
local log = require('utils.log')
local utils = require('command.utils')
local ser = require("serpent")

local executor = {}

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

function dispatchCommand(command, context, mode)
  local functionForCommand = sequences.getFunctionForSequence(command.sequence, context, mode)
  if functionForCommand then
    local executable_command_parts = makeExecutableCommandParts(command)
    functionForCommand(table.unpack(executable_command_parts))
    reaper.Undo_EndBlock('reaper-keys: ' .. utils.makeCommandDescription(command), 1)
  else
    log.error('Did not find an associated command function to execute for this command!')
  end
end

function executor.executeCommand(command, context, mode)
  reaper.Undo_BeginBlock()
  dispatchCommand(command, context, mode)
  reaper.Undo_EndBlock('reaper-keys: ' .. utils.makeCommandDescription(command), 1)
end

function executor.executeMacroCommands(commands, context, mode, desc)
  if not commands then
    log.info("This macro has no commands recorded.")
    return nil
  end

  reaper.Undo_BeginBlock()
  for _,command in pairs(commands) do
    dispatchCommand(command, context, mode)
  end
  reaper.Undo_EndBlock('reaper-keys: ' .. desc, 1)
end

return executor
