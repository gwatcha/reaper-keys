local state_interface = require('state_machine.state_interface')
local reaper_state = require('utils.reaper_state')
local utils = require('command.utils')
local format = require('utils.format')
local meta_command = require('command.meta_command')
local executeCommand = require('command.executor')
local config_match = require 'definitions.config'.general.repeatable_commands_action_type_match

function utils.qualifiesAsRepeatableCommand(command)
    for _, action_type in ipairs(command.action_sequence) do
        for _, action_type_match in ipairs(config_match) do
            if action_type:find(action_type_match) then
                return true
            end
        end
    end
    return false
end

local function handleCommand(state, command)
    reaper.Undo_BeginBlock2(0)
    local new_state = state

    if meta_command.isMetaCommand(command) then
        new_state = meta_command.executeMetaCommand(state, command)
    else
        executeCommand(command)
        -- internal commands may have changed the state
        if not state_interface.checkIfConsistentState(state) then
            new_state = state_interface.get()
        end

        if utils.qualifiesAsRepeatableCommand(command) then
            new_state.last_command = command
        end

        if new_state.macro_recording then
            reaper_state.append('macros', state.macro_register, command)
        end

        new_state.key_sequence = ""
    end

    local description = format.commandDescription(command)
    reaper.Undo_EndBlock2(0, ('reaper-keys: %s'):format(description), 1)
    return new_state, description
end

return handleCommand
