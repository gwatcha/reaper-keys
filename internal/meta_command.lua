local binding_list = require 'gui.binding_list.controller'
local executeCommand = require 'execute_command'
local log = require 'log'
local reaper_state = require 'utils.reaper_state'
local state_machine_default_state = require 'state_machine.default_state'

---@alias MetaFunction fun(state: State, command: Command): State
---@type { [string]: MetaFunction }
local commands = {}

---@param command Command
---@return Action
local function getActionKey(command)
    for i, action_type in pairs(command.action_sequence) do
        if action_type == "command" then return command.action_keys[i] end
    end
    return nil
end

---@param command Command
---@return MetaFunction?
local function getFn(command)
    local name = getActionKey(command)
    if not name then return nil end
    if type(name) == 'table' then name = name[1] end
    return commands[name]
end

---@param state State
---@param command Command
---@return State
function commands.recordMacro(state, command)
    if state.macro_recording then
        state.macro_recording = false
        state.key_sequence = ''
        return state
    end

    local register = command.action_keys[1].register
    if not register then return state end

    local blank_macro = { register = {} }
    reaper_state.setKeys('macros', blank_macro)
    state.macro_register = register
    state.macro_recording = true
    state.key_sequence = ''
    return state
end

---@param state State
---@param command Command
---@return State
function commands.playMacro(state, command)
    local action = getActionKey(command)
    local register = action.register
    if not register then
        log.error("no register for PlayMacro")
        return state_machine_default_state
    end

    local macro_commands = reaper_state.getKey('macros', register) --[[@as table?]]
    if macro_commands then
        local repetitions = action.prefixedRepetitions or 1
        local fn = getFn(command)
        if fn then
            for _ = 1, repetitions do
                for _, macro_command in pairs(macro_commands) do
                    fn(state, macro_command)
                end
            end
        else
            for _ = 1, repetitions do
                for _, macro_command in pairs(macro_commands) do
                    executeCommand(macro_command)
                end
            end
        end

        if state.macro_recording then
            reaper_state.append('macros', state.macro_register, command)
        end
    end

    state.key_sequence = ""
    state.last_command = command
    return state
end

---@param state State
---@param command Command
---@return State
function commands.repeatLastCommand(state, command)
    local repetitions = getActionKey(command).prefixedRepetitions or 1
    local last_command = state.last_command
    local fn = getFn(last_command)

    if fn then
        for _ = 1, repetitions do fn(state, last_command) end
    else
        for _ = 1, repetitions do executeCommand(last_command) end
    end

    if state.macro_recording then
        reaper_state.append('macros', state.macro_register, state.last_command)
    end

    state.key_sequence = ""
    state.last_command = last_command
    return state
end

---@param state State
---@return State
function commands.showBindingList(state, _)
    state.key_sequence = ""
    binding_list.open(state)
    return state
end

---@param state State
---@param command Command
---@return State? new_state
local function executeMetaCommand(state, command)
    local fn = getFn(command)
    if not fn then return nil end
    return fn(state, command)
end

return executeMetaCommand
