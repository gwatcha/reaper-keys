local meta_command = {}

local action_list = require('gui.action_list')
local executeCommand = require('command.executor')
local utils = require('command.utils')
local format = require('utils.format')
local saved = require('saved')
local definitions = require('utils.definitions')
local state_machine_constants = require('state_machine.constants')
local action_sequences = require('command.action_sequences')
local log = require('utils.log')

function executeMacroCommands(state, command, macro_commands, repetitions)
  for i=1,repetitions do
    for i,macro_command in pairs(macro_commands) do
      if meta_command.isMetaCommand(macro_command) then
        meta_command.executeMetaCommand(state, macro_command)
      else
        executeCommand(macro_command)
      end
    end
  end
end

function executeCommandOrMetaCommand(state, command, repetitions)
  for i=1,repetitions do
    if meta_command.isMetaCommand(command) then
      meta_command.executeMetaCommand(state, command)
    else
      executeCommand(command)
    end
  end
end

local meta_commands = {
  ["PlayMacro"] = function(state, command)
    local cmd_i = utils.getActionTypeIndex(command, 'command')
    local register = command.action_keys[cmd_i]['register']
    if not register then
      log.error("Did not get register for PlayMacro, but command was triggered!")
      return state_machine_constants['reset_state']
    end

    local repetitions = 1
    if command.action_keys[cmd_i]['prefixedRepetitions'] then
      repetitions = command.action_keys[cmd_i]['prefixedRepetitions']
    end

    local macro_commands = saved.get('macros', register)
    if macro_commands then
      executeMacroCommands(state, command, macro_commands, repetitions)
      if state['macro_recording'] then
        saved.append('macros', state['macro_register'], command)
      end
    end

    local new_state = state
    new_state['key_sequence'] = ""
    new_state['last_command'] = command
    return new_state
  end,
  ["RecordMacro"] = function(state, command)
    if state['macro_recording'] then
      state['macro_recording'] = false
      state['key_sequence'] = ""
    else
      local register = command.action_keys[1]['register']
      if register then
        saved.clear('macros', register)
        state['macro_register'] = register
        state['macro_recording'] = true
        state['key_sequence'] = ""
      end
    end

    return state
  end,
  ["RepeatLastCommand"] = function(state, command)
    local cmd_i = utils.getActionTypeIndex(command, 'command')
    local repetitions = 1
    if command.action_keys[cmd_i]['prefixedRepetitions'] then
      repetitions = command.action_keys[cmd_i]['prefixedRepetitions']
    end

    local last_command = state['last_command']
    executeCommandOrMetaCommand(state, last_command, repetitions)
    if state['macro_recording'] then
      saved.append('macros', state['macro_register'], state['last_command'])
    end

    local new_state = state
    new_state['last_command'] = last_command
    new_state['key_sequence'] = ""
    return new_state
  end,
  ["ShowReaperKeysHelp"] = function(state, command)
    local new_state = state

    local action_sequences = action_sequences.getPossibleActionSequences(state['context'], state['mode'])
    log.user("Mode: " .. state['mode'] .. "   Context: " .. state['context'] .. '\n')

    log.user('Action sequences available: \n' .. format.actionSequences(action_sequences))

    log.user('Bindings available for initial entry: \n')
    local entries = definitions.getPossibleEntries(state['context'])
    local types_seen = {}
    for _,action_sequence in ipairs(action_sequences) do
      local first_action_type = action_sequence[1]
      if not types_seen[first_action_type] then
        log.user('  >> ' .. first_action_type .. ':')
        log.user('  ' .. format.completions(entries[first_action_type]) .. '\n\n')
        types_seen[first_action_type] = true
      end
    end

    new_state['key_sequence'] = ""
    return new_state
  end,
  ["ShowReaperKeysActionList"] = function(state, command)
    action_list.open()
    local new_state = state
    new_state['key_sequence'] = ""
    return new_state
  end
}

function getMetaCommandFunctionForCommand(command)
  local cmd_i = utils.getActionTypeIndex(command, 'command')
  local command_key = command.action_keys[cmd_i]
  if not command_key  then
    return nil
  end

  local meta_command_name = command_key
  if type(command_key) ==  'table' then
    meta_command_name = command_key[1]
  end

  if not meta_commands[meta_command_name] then
    return nil
  end

  return meta_commands[meta_command_name]
end

function meta_command.isMetaCommand(command)
  if getMetaCommandFunctionForCommand(command) then
    return true
  end
  return false
end

function meta_command.executeMetaCommand(state, command)
  local meta_command_function = getMetaCommandFunctionForCommand(command)
  if not meta_command_function then
    log.warn('Unknown meta command: ' .. format.block(command))
    log.warn('Available meta commands are: ' .. format.line(meta_commands))
    return state_machine_constants['reset_state']
  end

  local new_state = meta_command_function(state, command)
  return new_state
end

return meta_command
