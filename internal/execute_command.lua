local action_sequences = require 'command.action_sequences'
local actions = require 'definitions.actions'
local log = require 'log'

local function shallowCopy(t)
    local t2 = {}
    for k, v in pairs(t) do t2[k] = v end
    return t2
end

---@param action_key Action
---@return Action?
local function getActionValue(action_key)
    if type(action_key) ~= 'table' then
        action_key = { action_key }
    end

    local action_name = action_key[1]
    local action = actions[action_name]
    if not action then
        log.error("Could not find action for " .. action_name)
        return nil
    end
    local action_value = shallowCopy(action_key)

    if type(action) == 'table' then
        for k, v in pairs(action) do action_value[k] = v end
    else
        action_value[1] = action
    end
    return action_value
end

---@param command Command
local function executeCommand(command)
    local action_values = {}
    for i, _ in pairs(command.action_sequence) do
        local action_value = getActionValue(command.action_keys[i])
        if not action_value then return end
        table.insert(action_values, action_value)
    end

    local fn = action_sequences.getFunctionForCommand(command)
    if not fn then
        return log.error('Did not find an associated action action_sequence function to execute for the command')
    end
    fn(table.unpack(action_values))
end

return executeCommand
