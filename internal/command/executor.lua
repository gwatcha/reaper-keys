local log = require('utils.log')
local format = require('utils.format')
local sequences = require('command.sequences')
local utils = require('command.utils')

function executeCommand(command)
  local action_values = utils.getActionValues(command)
  if not action_values then
    log.error("Could not form executable command for: " .. format.block(command))
    return
  end

  local functionForCommand = sequences.getFunctionForCommand(command)
  if not functionForCommand then
    log.error('Did not find an associated action sequence function to execute for the command.')
    return
  end

  functionForCommand(table.unpack(action_values))
end

return executeCommand
