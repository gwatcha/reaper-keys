local meta_command = {}

local executeCommand = require('command.executor')
local utils = require('command.utils')
local format = require('utils.format')
local saved = require('saved')
local definitions = require('utils.definitions')
local state_machine_constants = require('state_machine.constants')
local getPossibleFutureEntries = require('command.completer')
local sequences = require('command.sequences')
local regex_match_entry_types = require('command.constants').regex_match_entry_types

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

local commands = {
  ["PlayMacro"] = function(state, command)
    local repetitions = 1
    if utils.getActionTypeIndex(command, 'number') then
      repetitions = utils.getActionTypeIndex(command, 'number')
    end

    local register = command.action_keys[1].register

    if not register then
      log.error("Did not get register for RecordMacro, but command was triggered!")
      return state_machine_constants['reset_state']
    end

    local macro_commands = saved.get('macros', register)
    if macro_commands then
      executeMacroCommands(state, command, macro_commands, repetitions)
      if state['macro_recording'] then
        saved.append('macros', state['macro_register'], command)
      end
    end

    local new_state = state
    new_state['last_command'] = command
    return new_state
  end,
  ["RecordMacro"] = function(state, command)
    if not state['macro_recording'] then
      local register = command.action_keys[1].register
      if not register then
        log.error("Did not get register for RecordMacro, but command was triggered!")
        return state_machine_constants['reset_state']
      end

      saved.clear('macros', register)
      state['macro_register'] = register
      state['macro_recording'] = true
    end

    local new_state = state
    return new_state
  end,
  ["StopRecordMacro"] = function(state, command)
    if not state['macro_recording'] then
      log.warn("No macro is recording.")
      return
    else
      state['macro_recording'] = false
    end

    local new_state = state
    return new_state
  end,
  ["RepeatLastCommand"] = function(state, command)
    local num_i = utils.getActionTypeIndex(command, 'number')
    local repetitions = 1
    if num_i then
      repetitions = command.action_values[num_i]
    end

    local last_command = state['last_command']
    executeCommandOrMetaCommand(state, last_command, repetitions)
    if state['macro_recording'] then
      saved.append('macros', state['macro_register'], state['last_command'])
    end

    local new_state = state
    new_state['last_command'] = last_command
    return new_state
  end,
  ["ShowReaperKeysHelp"] = function(state, command)
    local new_state = state

    local action_sequences = sequences.getPossibleActionSequences(state['context'], state['mode'])
    log.user("Mode: " .. state['mode'] .. "   Context: " .. state['context'] .. '\n')

    log.user('Action sequences available: \n' .. format.actionSequences(action_sequences))

    log.user('Bindings available for initial entry: \n')
    local entries = definitions.getPossibleEntries(state['context'])
    local types_seen = {}
    for _,action_sequence in ipairs(action_sequences) do
      local first_action_type = action_sequence[1]
      if not regex_match_entry_types[first_action_type] and not types_seen[first_action_type] then
        log.user('  >> ' .. first_action_type .. ':')
        log.user('  ' .. format.completions(entries[first_action_type]) .. '\n\n')
        types_seen[first_action_type] = true
      end
    end

    return new_state
  end
}

function meta_command.isMetaCommand(command)
  local i = utils.getActionTypeIndex(command, 'command')
  local val = command.action_values[i]
  if type(val) == 'table' and val['metaCommand'] then
    return true
  end
  return false
end

function meta_command.executeMetaCommand(state, command)
  local meta_command_name = ""

  local cmd_i = utils.getActionTypeIndex(command, 'command')
  local meta_command_key = command.action_keys[cmd_i]

  local meta_command_name = meta_command_key
  if type(meta_command_key) ==  'table' then
    meta_command_name = meta_command_key[1]
  end

  if not commands[meta_command_name] then
    log.error('Unknown meta command: ' .. meta_command_name)
    log.error('Available meta commands are: ' .. format.line(commands))
  end

  local new_state = commands[meta_command_name](state, command)
  return new_state
end

return meta_command
