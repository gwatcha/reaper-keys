local log = require('utils.log')
local format = require('utils.format')
local action_sequences = require('command.action_sequences')
local utils = require('command.utils')

local function executeCommand(command)
  local action_values = utils.getActionValues(command)
  if not action_values then
    log.error("Could not form executable command for: " .. format.block(command))
    return
  end

  local functionForCommand = action_sequences.getFunctionForCommand(command)
  if not functionForCommand then
    log.error('Did not find an associated action action_sequence function to execute for the command.')
    return
  end

  functionForCommand(table.unpack(action_values))
end

return executeCommand
