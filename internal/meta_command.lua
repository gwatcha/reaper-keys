local binding_list = require 'gui.binding_list.controller'
local executeCommand = require 'execute_command'
local log = require 'log'
local reaper_state = require 'utils.reaper_state'
local state_machine_default_state = require 'state_machine.default_state'

---@alias MetaFunction fun(state: State, command: Command): State
---@type { [string]: MetaFunction }
local commands = {}

---@param command Command
---@return Action?
local function getAction(command)
    for i, action_type in pairs(command.action_sequence) do
        if action_type == "command" then return command.action_keys[i] end
    end
    return nil
end

---@param command Command
---@return MetaFunction?
local function getFn(command)
    local key = getAction(command)
    if not key then return nil end
    if type(key) == 'table' then key = key[1] end
    return commands[key]
end

---@param state State
---@param command Command
---@return State
function commands.PlayMacro(state, command)
    local action = getAction(command)
    if not action then
        log.error("no action for PlayMacro" .. require 'utils.format'.block(command))
        return state_machine_default_state
    end
    local register = action.register
    if not register then
        log.error("no register for PlayMacro")
        return state_machine_default_state
    end

    local macro_commands = reaper_state.getKey('macros', register) --[[@as table?]]
    if macro_commands then
        for _ = 1, action.prefixedRepetitions or 1 do
            for _, macro_command in pairs(macro_commands) do
                local fn = getFn(macro_command)
                if fn then
                    fn(state, macro_command)
                else
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
function commands.RecordMacro(state, command)
    if state.macro_recording then
        state.macro_recording = false
        state.key_sequence = ''
        return state
    end
    local register = command.action_keys[1].register
    if not register then return state end

    local blank_macro = {}
    blank_macro[register] = {}
    reaper_state.setKeys('macros', blank_macro)
    state.macro_register = register
    state.macro_recording = true
    state.key_sequence = ''
    return state
end

---@param state State
---@param command Command
---@return State
function commands.RepeatLastCommand(state, command)
    local action = getAction(command)
    if not action then return state_machine_default_state end
    local last_command = state.last_command
    local fn = getFn(last_command)
    local repetitions = action.prefixedRepetitions or 1
    if fn then
        for _ = 1, repetitions do fn(state, last_command) end
    else
        for _ = 1, repetitions do executeCommand(last_command) end
    end

    if state.macro_recording then
        reaper_state.append('macros', state.macro_register, last_command)
    end

    state.key_sequence = ""
    state.last_command = last_command
    return state
end

---@param state State
---@return State
function commands.ShowBindingList(state, _)
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
