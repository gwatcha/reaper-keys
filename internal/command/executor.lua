local sequences = require('command.sequences')
local definitions = require('utils.definitions')
local getAction = require('utils.get_action')
local regex_match_entry_types = require('command.constants').regex_match_entry_types
local log = require('utils.log')
local utils = require('command.utils')
local format = require('utils.format')

local executor = {}

function table.shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

function makeExecutableAction(command_part)
  local action_name = ""
  if type(command_part) == 'table' then
    action_name = command_part[1]
  else
    action_name = command_part
  end

  local action = getAction(action_name)
  if not action then
    log.error("Could not find action for " .. format.block(action_name))
    return nil
  end

  if type(command_part) == 'table' then
    local executable_action = table.shallow_copy(command_part)
    for k,v in pairs(action) do executable_action[k] = v end
    return executable_action
  else
    return action
  end
end

function makeExecutableCommandParts(command)
  local executable_command_parts = {}
  for i,action_type in pairs(command.sequence) do
    if regex_match_entry_types[action_type] then
      local value = command.parts[i]
      if action_type == 'number' then value = tonumber(value) end
      table.insert(executable_command_parts, value)
    else
      local executable_action = makeExecutableAction(command.parts[i])
      if not executable_action then
        return nil
      end
      table.insert(executable_command_parts, executable_action)
    end
  end

  return executable_command_parts
end

function executor.dispatchCommand(command)
  local functionForCommand = sequences.getFunctionForCommand(command)
  if not functionForCommand then
    log.error('Did not find an associated action sequence function to execute for this command!')
    return
  end

  local executable_command_parts = makeExecutableCommandParts(command)
  if not executable_command_parts then
    log.error("Could not form command.")
    return
  end

  log.trace('Formed command: ' .. format.block(executable_command_parts))
  functionForCommand(table.unpack(executable_command_parts))
end

function executor.executeCommand(command)
  reaper.Undo_BeginBlock()
  executor.dispatchCommand(command)
  reaper.Undo_EndBlock('reaper-keys: ' .. format.commandDescription(command), 1)
end

function executor.executeCommandMultipleTimes(command, repetitions)
  reaper.Undo_BeginBlock()
  for i=1,repetitions do
    executor.dispatchCommand(command)
  end
  reaper.Undo_EndBlock('reaper-keys: ' .. repetitions .. " * " .. format.commandDescription(command), 1)
end

return executor
