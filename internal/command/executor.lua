local sequences = require("command.sequences")
local definitions = require("utils.definitions")
local regex_match_entry_types = require("command.constants").regex_match_entry_types
local log = require('utils.log')
local utils = require('command.utils')

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

function executor.dispatchCommand(command)
  local functionForCommand = sequences.getFunctionForCommand(command)
  if functionForCommand then
    local executable_command_parts = makeExecutableCommandParts(command)
    functionForCommand(table.unpack(executable_command_parts))
  else
    log.error('Did not find an associated action sequence function to execute for this command!')
  end
end

function executor.executeCommand(command)
  reaper.Undo_BeginBlock()
  executor.dispatchCommand(command)
  reaper.Undo_EndBlock('reaper-keys: ' .. utils.makeCommandDescription(command), 1)
end

function executor.executeCommandMultipleTimes(command, repetitions)
  reaper.Undo_BeginBlock()
  for i=1,repetitions do
    executor.dispatchCommand(command)
  end
  reaper.Undo_EndBlock('reaper-keys: ' .. repetitions .. " * " .. utils.makeCommandDescription(command), 1)
end

return executor
