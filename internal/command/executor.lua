local log = require('utils.log')
local format = require('utils.format')
local sequences = require('command.sequences')

local executor = {}

function executeCommand(command)
  local functionForCommand = sequences.getFunctionForCommand(command)
  if not functionForCommand then
    log.error('Did not find an associated action sequence function to execute for the command.')
    return
  end
  functionForCommand(table.unpack(command.action_values))
end

return executeCommand
