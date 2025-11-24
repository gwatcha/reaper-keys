local action_sequences = require 'command.action_sequences'
local format = require 'utils.format'
local log = require 'log'
local utils = require 'command.utils'

---@param command Command
local function executeCommand(command)
    local action_values = utils.getActionValues(command)
    if not action_values then
        log.error("Could not form executable command for: " .. format.block(command))
        return
    end
  local fn = action_sequences.getFunctionForCommand(command)
  if not fn then
    log.error('Did not find an associated action action_sequence function to execute for the command.')
    return
  end

  fn(table.unpack(action_values))
end

return executeCommand
